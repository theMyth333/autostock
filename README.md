# Unit 04 - Deployment to SAP BTP Cloud Foundry

## Pre-requisites

**Accounts:**
- SAP BTP Trial Account — sign up at [https://account.hana.ondemand.com/](https://account.hana.ondemand.com/)
- Cloud Foundry environment enabled in your trial subaccount

**CLI Tools:**

| Tool | Install | Verify |
|------|---------|--------|
| Cloud Foundry CLI | [Download](https://github.com/cloudfoundry/cli/releases) | `cf --version` |
| MBT Build Tool | `npm install -g mbt` | `mbt --version` |
| GNU Make | Pre-installed on Mac/Linux; Windows: via [chocolatey](https://chocolatey.org/) `choco install make` | `make --version` |

**Verify all tools before starting:**

```bash
node --version
npm --version
cds --version
cf --version
mbt --version
make --version
```

**BTP PostgreSQL service:** Your trial subaccount must have the `postgresql-db` service available in the marketplace. Confirm with:

```bash
cf marketplace -e postgresql-db
```

---

## Instructions

### 1. Add PostgreSQL support for production

```bash
cds add postgres --for production
```

This adds `@cap-js/postgres` as a production dependency and configures CAP to use PostgreSQL when `NODE_ENV=production`.

### 2. Generate the MTA deployment descriptor

```bash
cds add mta
```

This creates `mta.yaml` — the Multi-Target Application descriptor that defines all modules and services for Cloud Foundry deployment.

### 3. Update the PostgreSQL service plan

Open `mta.yaml` and find the `autostock-postgres` resource. Change `service-plan` from `free` to `trial`:

```yaml
resources:
  - name: autostock-postgres
    type: org.cloudfoundry.managed-service
    parameters:
      service: postgresql-db
      service-plan: trial     # ← change this
```

### 4. Add the App Router

The App Router is a reverse proxy that sits in front of your app and routes requests to the correct backend:

```bash
cds add approuter
```

This creates `app/router/` with a `package.json` and `xs-app.json`.

### 5. Configure `xs-app.json`

Update `app/router/xs-app.json` to route OData requests to the backend service and serve the UI statically:

```json
{
  "welcomeFile": "/index.html",
  "authenticationMethod": "none",
  "routes": [
    {
      "source": "^/odata/(.*)$",
      "target": "/odata/$1",
      "destination": "srv-api",
      "authenticationType": "none",
      "csrfProtection": false
    },
    {
      "source": "^/(.*)$",
      "target": "/$1",
      "localDir": "resources",
      "authenticationType": "none"
    }
  ]
}
```

### 6. Update `mta.yaml` with the approuter module

Your `mta.yaml` should include these three modules:

```yaml
modules:
  - name: autostock-srv
    type: nodejs
    path: gen/srv
    provides:
      - name: srv-api
        properties:
          srv-url: ${default-url}
    requires:
      - name: autostock-postgres

  - name: autostock-postgres-deployer
    type: nodejs
    path: gen/pg
    parameters:
      no-route: true
      no-start: true
      tasks:
        - name: deploy-to-postgresql
          command: npm start
    requires:
      - name: autostock-postgres

  - name: autostock
    type: approuter.nodejs
    path: app/router
    build-parameters:
      builder: custom
      commands:
        - npm install --prefix ../autostock
        - npm run build --prefix ../autostock
    requires:
      - name: srv-api
        group: destinations
        properties:
          name: srv-api
          url: ~{srv-url}
          forwardAuthToken: true
```

### 7. Build the UI5 app

```bash
cd app/autostock
npx ui5 build --all --clean-dest --dest dist
cd ../..
```

### 8. Build the CAP backend for production

```bash
cds build --production
```

This generates the `gen/` folder with compiled artefacts for deployment.

### 9. Build the MTA archive

```bash
mbt build -t .
```

This creates `autostock_1.0.0.mtar` — the deployable archive containing all modules.

### 10. Log in to Cloud Foundry

```bash
cf login -a https://api.cf.us10-001.hana.ondemand.com
```

Enter your BTP email and password when prompted. Verify your target:

```bash
cf target
```

### 11. Deploy to BTP

```bash
cf deploy .\autostock_1.0.0.mtar
```

Deployment takes a few minutes. When complete, find your app URL with:

```bash
cf apps
```

---

## Project Structure

```
autostock/
├── app/
│   ├── autostock/          ← UI5 Fiori app
│   └── router/             ← App Router (new)
│       ├── package.json
│       └── xs-app.json
├── db/
├── srv/
├── gen/                    ← generated build artefacts (git-ignored)
├── mta.yaml                ← MTA deployment descriptor (new)
├── autostock_1.0.0.mtar    ← deployable archive (git-ignored)
└── package.json
```

---

## Concepts

### Multi-Target Application (MTA)

An MTA is a collection of modules (microservices, UIs, jobs) that are deployed together as a unit to Cloud Foundry. The `mta.yaml` descriptor defines:

- **Modules** — deployable units (Node.js apps, approuter, database deployers)
- **Resources** — CF services consumed by modules (PostgreSQL, XSUAA, etc.)
- **Dependencies** — which modules need which resources, and what values are passed between them (like service URLs)

### The App Router

In a production CAP deployment, the App Router (`@sap/approuter`) is the single entry point for all HTTP traffic:

```
Browser → App Router → CAP Backend (OData)
                    → Static files (UI5 app)
```

It handles:
- Request routing based on URL patterns (`xs-app.json`)
- Serving static UI files from `resources/`
- Forwarding API calls to the backend destination (`srv-api`)
- Authentication (covered in Unit 05)

### `cds build --production`

This command transforms your CAP project into deployable artefacts in `gen/`:
- `gen/srv/` — compiled Node.js service ready to run on CF
- `gen/pg/` — PostgreSQL schema deployer

It strips development-only files and resolves all CDS imports into self-contained bundles.

### CF Destinations

In `mta.yaml`, the approuter module references `srv-api` as a destination. This is how Cloud Foundry services discover each other at runtime — the backend `provides` its URL under the name `srv-api`, and the approuter `requires` it and uses `~{srv-url}` to inject it at deploy time.

---

## Exercises

1. **Monitor your deployment:** After deploying, run `cf logs autostock-srv --recent` to see the application startup logs. Identify where CAP connects to PostgreSQL.

2. **Scale the service:** Run `cf scale autostock-srv -i 2` to run two instances of your backend. Test that the app still works, then scale back to 1.

3. **Inspect services:** Run `cf services` to list all provisioned services. Find your PostgreSQL instance and note its `bound apps`.

4. **Update and re-deploy:** Make a small change (e.g., add a field title annotation), rebuild with `mbt build -t .`, and re-deploy. Observe that only changed modules are updated — MTA is incremental.
