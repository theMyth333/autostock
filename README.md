# Unit 05 - Authorisation with XSUAA

## Pre-requisites

- Completed **Unit 04 - Deployment** with a working deployed app on BTP Cloud Foundry
- BTP Trial Account with CF CLI authenticated (`cf target` shows your org and space)
- MBT build tool (`mbt --version`)
- Understanding of the app's `mta.yaml` and `xs-app.json` from the previous unit

---

## Instructions

### 1. Add XSUAA to the project

```bash
cds add xsuaa
```

This adds `@sap/xssec` and `passport` as dependencies and updates `package.json` with the XSUAA configuration.

### 2. Create the security descriptor

Create `xs-security.json` in the project root. This defines the **scopes** (permissions) and **role templates** for your application:

```json
{
  "scopes": [
    {
      "name": "$XSAPPNAME.Viewer",
      "description": "View inventory"
    },
    {
      "name": "$XSAPPNAME.Admin",
      "description": "Manage inventory"
    }
  ],
  "attributes": [],
  "role-templates": [
    {
      "name": "Viewer",
      "description": "View inventory",
      "scope-references": [
        "$XSAPPNAME.Viewer"
      ]
    },
    {
      "name": "Admin",
      "description": "Manage inventory",
      "scope-references": [
        "$XSAPPNAME.Admin"
      ]
    }
  ]
}
```

### 3. Add access restrictions to the service

Update `srv/inventory-service.cds` to restrict access by role:

```cds
using { autostock.inventory as db } from '../db/schema';

service InventoryService {

    @restrict: [
        { grant: 'READ', to: 'Viewer' },
        { grant: '*',    to: 'Admin' }
    ]
    entity Cars as projection on db.Cars;

}
```

This means:
- Users with the `Viewer` role can only read cars
- Users with the `Admin` role can read, create, update, and delete

### 4. Secure the App Router

Update `app/router/xs-app.json` to enforce XSUAA authentication on all routes:

```json
{
  "welcomeFile": "/index.html",
  "authenticationMethod": "route",
  "routes": [
    {
      "source": "^/odata/(.*)$",
      "target": "/odata/$1",
      "destination": "srv-api",
      "authenticationType": "xsuaa",
      "csrfProtection": false
    },
    {
      "source": "^/(.*)$",
      "target": "/$1",
      "localDir": "resources",
      "authenticationType": "xsuaa"
    }
  ]
}
```

Key changes from Unit 04:
- `"authenticationMethod": "route"` — authentication is enforced per route
- `"authenticationType": "xsuaa"` — uses SAP's OAuth 2.0 service

### 5. Update `mta.yaml` to provision and bind XSUAA

Add the XSUAA service as a resource and bind it to both the backend and the approuter:

```yaml
modules:
  - name: autostock-srv
    # ... existing config ...
    requires:
      - name: autostock-postgres
      - name: autostock-auth    # ← add this

  - name: autostock
    # ... existing approuter config ...
    requires:
      - name: srv-api
        group: destinations
        properties:
          name: srv-api
          url: ~{srv-url}
          forwardAuthToken: true
      - name: autostock-auth    # ← add this

resources:
  - name: autostock-postgres
    # ... existing postgres config ...

  - name: autostock-auth        # ← add this entire resource
    type: org.cloudfoundry.managed-service
    parameters:
      service: xsuaa
      service-plan: application
      path: ./xs-security.json
      config:
        xsappname: autostock-${org}-${space}
        tenant-mode: dedicated
        oauth2-configuration:
          credential-types:
            - "binding-secret"
            - "x509"
          redirect-uris:
            - https://*~{app-api/app-uri}/**
    requires:
      - name: app-api
```

### 6. Validate before building

```bash
npx cds compile srv --to edmx
npx cds build --production
```

Check the output for errors. The compiled EDMX should reflect the `@restrict` annotations.

### 7. Build the MTA archive

```bash
mbt build -t .
```

### 8. Deploy to BTP

```bash
cf deploy .\autostock_1.0.0.mtar
```

After deployment, the app will redirect to the SAP Identity Provider login page when accessed.

### 9. Create and assign Role Collections in BTP Cockpit

1. Open your **BTP Subaccount** in the browser
2. Go to **Security → Role Collections**
3. Create a new Role Collection named `Inventory Viewer`
   - Add the role `Viewer` from application `autostock-<org>-<space>`
4. Create a second Role Collection named `Inventory Admin`
   - Add the role `Admin` from the same application
5. Go to **Security → Users**
6. Find your user and assign both Role Collections
7. Log out and back in, then access the app — you should be authenticated and authorised

---

## Project Structure

```
autostock/
├── app/
│   ├── autostock/
│   └── router/
│       ├── package.json
│       └── xs-app.json        ← updated: authenticationMethod: route
├── db/
├── srv/
│   ├── annotations.cds
│   ├── inventory-service.cds  ← updated: @restrict annotations
│   └── inventory-service.js
├── mta.yaml                   ← updated: autostock-auth resource added
├── xs-security.json           ← new: XSUAA security descriptor
└── package.json
```

---

## Concepts

### What is XSUAA?

**XSUAA (Extended Services for User Account and Authentication)** is SAP BTP's OAuth 2.0 / OpenID Connect service. It handles:

- **Authentication** — verifying who the user is (via SAP Identity Provider or custom IdP)
- **Authorisation** — determining what the user is allowed to do (via scopes and role collections)

When your app is behind XSUAA, every request carries a **JWT token** that contains the user's identity and assigned scopes. CAP reads these scopes automatically and enforces the `@restrict` annotations you defined.

### Scopes, Roles, and Role Collections

The security model has three layers:

```
Scope → Role Template → Role Collection → User
```

| Concept | Defined in | Purpose |
|---------|-----------|---------|
| **Scope** | `xs-security.json` | The lowest-level permission (e.g., `Viewer`, `Admin`) |
| **Role Template** | `xs-security.json` | Groups scopes into a named role |
| **Role Collection** | BTP Cockpit | Groups role templates; assigned to users |

The `$XSAPPNAME` prefix in scope names ensures scopes are unique across applications in the same subaccount.

### `@restrict` Annotation

CAP's `@restrict` annotation enforces authorisation at the entity level:

```cds
@restrict: [
    { grant: 'READ',              to: 'Viewer' },
    { grant: ['CREATE','UPDATE'], to: 'Editor' },
    { grant: '*',                 to: 'Admin' }
]
```

- `grant` accepts HTTP verbs (`READ`, `CREATE`, `UPDATE`, `DELETE`) or `'*'` for all
- `to` references a role name defined in `xs-security.json`
- CAP checks the user's JWT for matching scopes at runtime — no custom handler code needed

### JWT Token Flow

```
User → App Router → XSUAA (login)
                         ↓
                    JWT token issued
                         ↓
User → App Router (token attached) → CAP Backend
                                          ↓
                                    @restrict check
                                          ↓
                                    Response / 403
```

The App Router passes the JWT as an `Authorization: Bearer <token>` header to the backend. CAP's XSUAA middleware validates the token and makes the user's scopes available to the `@restrict` framework.

### Why `forwardAuthToken: true`?

In `mta.yaml`, the approuter destination is configured with `forwardAuthToken: true`. This tells the approuter to include the user's JWT when proxying requests to the backend — without it, the backend would receive unauthenticated requests.

---

## Exercises

1. **Test authorisation failure:** Temporarily remove the `Admin` role collection from your user, re-login, and try to create a car. You should receive a 403 Forbidden response. Re-assign the role collection and confirm access is restored.

2. **Add an `Editor` role:** Add a new scope `$XSAPPNAME.Editor` and role template `Editor` to `xs-security.json`. Update the `@restrict` annotation to allow `Editor` to do `CREATE` and `UPDATE` but not `DELETE`. Re-deploy and test.

3. **Inspect the JWT:** Use `cf ssh autostock-srv` (if available) or add a temporary `after("READ")` handler that logs `req.user` to see the decoded token contents including user ID and scopes.

4. **Multi-user scenario:** If you have a second BTP user available (e.g., a colleague on the same trial), assign them only the `Viewer` role collection and ask them to try editing a car. Confirm the UI hides the edit/delete buttons for restricted users.
