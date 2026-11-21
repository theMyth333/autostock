# AutoStock

A hands-on masterclass for building an **Inventory Management Application** using **SAP Cloud Application Programming Model (CAP)**. You will go from zero to a fully deployed, secured application on SAP BTP — one unit at a time.

---

## What You Will Build

A car inventory system that allows dealerships to track vehicles — their make, model, pricing, and availability status. By the end of the masterclass you will have:

- A CDS data model backed by PostgreSQL
- An OData V4 service with custom validation logic
- A SAP Fiori Elements UI with list and object pages
- A fully deployed multi-module MTA app on SAP BTP Cloud Foundry
- Role-based access control using XSUAA

---

## How to Approach This Training

Each unit is a **separate branch** that builds on the previous one. Work through them in order:

1. **Checkout the branch** for the unit you are starting.
2. **Read the README** on that branch — it has everything you need: pre-requisites, step-by-step instructions, concept explanations, and exercises.
3. **Follow the instructions** to build the feature yourself from scratch.
4. **Complete the exercises** at the end of the README before moving to the next unit.

> Do not jump ahead. Each unit assumes the output of the previous one.

---

## Units

| Unit | Branch | Topic |
|------|--------|-------|
| 00 | [`00-project-setup`](https://github.com/theMyth333/autostock/tree/00-project-setup) | Project Setup — initialise a CAP project with SQLite |
| 01 | [`01-data-modelling`](https://github.com/theMyth333/autostock/tree/01-data-modelling) | Data Modelling — define entities, aspects, and seed data |
| 02 | [`02-serivce-design`](https://github.com/theMyth333/autostock/tree/02-serivce-design) | Service Design — expose an OData V4 API with business logic |
| 03 | [`03-frontend-app`](https://github.com/theMyth333/autostock/tree/03-frontend-app) | Frontend App — build a Fiori Elements UI with annotations |
| 04 | [`04-deployment`](https://github.com/theMyth333/autostock/tree/04-deployment) | Deployment — deploy to SAP BTP Cloud Foundry with PostgreSQL |
| 05 | [`05-authorisation`](https://github.com/theMyth333/autostock/tree/05-authorisation) | Authorisation — secure the app with XSUAA and role collections |

---

## Pre-requisites

Before starting Unit 00, make sure you have the following installed:

- [Node.js](https://nodejs.org/) v18 or higher
- [Visual Studio Code](https://code.visualstudio.com/)
- [SQLite](https://www.sqlite.org/)
- `@sap/cds-dk` — `npm install -g @sap/cds-dk`
- **SAP CDS Language Support** VS Code extension
- A [SAP BTP Trial Account](https://www.sap.com/products/technology-platform/trial.html) *(required from Unit 04 onwards)*

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/theMyth333/autostock.git
cd autostock

# Start with Unit 00
git checkout 00-project-setup
```

Then open the `README.md` on that branch and follow the instructions.
