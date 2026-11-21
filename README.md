# Unit 00 - Project Setup

## Pre-requisites

Ensure the following tools are installed on your machine before starting:

| Tool | Purpose | Version |
|------|---------|---------|
| [Node.js](https://nodejs.org/) | JavaScript runtime for CAP | v18 or higher |
| [Visual Studio Code](https://code.visualstudio.com/) | Code editor | Latest |
| [SQLite](https://www.sqlite.org/) | Local development database | Latest |
| `@sap/cds-dk` | CAP development toolkit (CLI) | Latest |

**VS Code Extensions:**
- **SAP CDS Language Support** — syntax highlighting, code completion, and validation for `.cds` files

**Install `@sap/cds-dk` globally:**

```bash
npm install -g @sap/cds-dk
```

**Verify your installation:**

```bash
node --version
npm --version
cds --version
```

---

## Instructions

### 1. Initialise the CAP project

```bash
cds init autostock
cd autostock
```

This creates the standard CAP project scaffold with `app/`, `db/`, and `srv/` directories.

### 2. Add Node.js runtime support

```bash
cds add nodejs
```

This configures the project to run as a Node.js application.

### 3. Add SQLite for local development

```bash
cds add sqlite
```

This adds `@cap-js/sqlite` as a dev dependency — a local in-memory/file database you can use without any cloud services.

### 4. Install dependencies

```bash
npm install
```

Your `package.json` should look like this after setup:

```json
{
  "name": "autostock",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {
    "@sap/cds": "^10"
  },
  "devDependencies": {
    "@cap-js/sqlite": "^3"
  },
  "scripts": {
    "start": "cds-serve"
  },
  "private": true
}
```

### 5. Start the development server

```bash
npm start
```

Open your browser and navigate to `http://localhost:4004`. You should see the CAP welcome page. There are no services yet — that comes in the next unit.

---

## Project Structure

```
autostock/
│
├── app/          ← UI applications go here
│
├── db/           ← Data models (CDS schema files) go here
│
├── srv/          ← Service definitions and logic go here
│
├── package.json
│
└── README.md
```

---

## Concepts

### What is SAP CAP?

SAP Cloud Application Programming Model (CAP) is a framework for building enterprise-grade services and applications on SAP BTP. It follows a **model-driven approach**: you define your data model and services in a high-level language (CDS), and CAP generates the boilerplate — OData APIs, database tables, CRUD operations — automatically.

### What is CDS?

**Core Data Services (CDS)** is the declarative language used by CAP to define:
- **Data models** (entities, relationships)
- **Services** (which entities to expose and how)
- **Annotations** (UI metadata, access control)

### Why SQLite for local development?

SQLite is a file-based database that requires zero configuration. It lets you develop and test your CAP app locally without setting up a cloud database. When you deploy to SAP BTP, you switch to PostgreSQL or SAP HANA — CAP handles the difference transparently.

### The Three-Layer Architecture

CAP enforces a clean separation of concerns across three layers:

| Layer | Folder | Purpose |
|-------|--------|---------|
| Persistence | `db/` | Data models and seed data |
| Service | `srv/` | Business logic and API exposure |
| Presentation | `app/` | UI applications |

---

## Exercises

1. **Explore the CDS CLI:** Run `cds help` in your terminal and read through the available commands. Try `cds version` to see all installed CAP components.

2. **Customise the project:** Open `package.json` and add a `"dev"` script that runs `cds watch` (which auto-reloads on file changes). Verify it works with `npm run dev`.

3. **Understand the scaffold:** Delete the `app/`, `db/`, and `srv/` folders and re-run `cds init` in a temporary directory. Compare the output to understand exactly what `cds init` generates.

4. **Install the VS Code extension:** Install the **SAP CDS Language Support** extension, create a blank file `db/schema.cds`, and type `entity` to see code completion in action.
