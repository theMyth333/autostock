# Unit 02 - Service Design

## Pre-requisites

- Completed **Unit 01 - Data Modelling** with a working schema and seed data
- [Bruno](https://www.usebruno.com/) or [Postman](https://www.postman.com/) installed for testing REST/OData APIs
- Node.js and npm available

---

## Instructions

### Part 1 — Exposing the OData Service

#### 1. Create the service definition

Create a new file `srv/inventory-service.cds`:

```cds
using { autostock.inventory as db } from '../db/schema';

service InventoryService {

    entity Cars as projection on db.Cars;

}
```

#### 2. Compile to EDMX (OData metadata)

```bash
cds compile srv --to edmx
```

This outputs the OData service metadata document. It's a good way to verify your service is well-formed before running it.

#### 3. Start the server

```bash
npm start
```

Open `http://localhost:4004` in your browser. You should see the CAP index page listing `InventoryService`. Click the link to explore the JSON metadata and entity sets.

#### 4. Test the API with Bruno/Postman

Use the following endpoint to try all CRUD operations:

```
http://localhost:4004/odata/v4/inventory/Cars
```

| Operation | Method | URL |
|-----------|--------|-----|
| List all cars | GET | `/odata/v4/inventory/Cars` |
| Get single car | GET | `/odata/v4/inventory/Cars(<uuid>)` |
| Create a car | POST | `/odata/v4/inventory/Cars` |
| Update a car | PATCH | `/odata/v4/inventory/Cars(<uuid>)` |
| Delete a car | DELETE | `/odata/v4/inventory/Cars(<uuid>)` |

**Example POST body:**

```json
{
  "vin": "WBA4E1C5XHG123456",
  "make": "BMW",
  "model": "3 Series",
  "modelYear": 2023,
  "color": "Alpine White",
  "price": 4500000,
  "currency": "INR",
  "status": "AVAILABLE"
}
```

---

### Part 2 — Adding Business Logic with Event Handlers

#### 5. Create the service implementation

Create `srv/inventory-service.js`. Start with just a READ handler to understand the structure:

```js
const cds = require("@sap/cds");

module.exports = class InventoryService extends cds.ApplicationService {
  init() {
    const { Cars } = this.entities;

    this.before("READ", "Cars", async (req) => {
      console.log("Event:", req.event);
      console.log("Request Data:", req.data);
      console.log("Target:", req.target.name);
    });

    return super.init();
  }
};
```

Restart the server and make a GET request. Watch the console output — you'll see the event lifecycle in action.

#### 6. Add CREATE validation

Extend the `init()` method with a `before("CREATE")` handler. Build it up step by step:

**Step 1 — Validate VIN is present and correct length:**

```js
this.before("CREATE", "Cars", async (req) => {
  const { vin, price } = req.data;

  if (!vin) {
    req.error(400, 'VIN is mandatory', 'vin');
  }

  if (vin && vin.length !== 17) {
    req.error(400, 'VIN must contain 17 characters', 'vin');
  }
```

**Step 2 — Validate selling price:**

```js
  if (price === undefined || price === null || Number(price) <= 0) {
    req.error(400, 'Selling price must be greater than zero', 'price');
  }
```

**Step 3 — Check for duplicate VIN:**

```js
  if (vin) {
    const existingCar = await cds.tx(req).run(
      SELECT.one.from(Cars).where({ vin: vin })
    );

    if (existingCar) {
      req.error(400, 'A car with this VIN already exists', 'vin');
    }
  }
});
```

#### 7. Add UPDATE validation

```js
this.before("UPDATE", "Cars", async (req) => {
  const { price } = req.data;

  if (price === undefined || price === null || Number(price) <= 0) {
    req.error(400, "Selling price must be greater than zero", "price");
  }
});
```

#### 8. Complete service implementation

Your final `srv/inventory-service.js`:

```js
const cds = require("@sap/cds");

module.exports = class InventoryService extends cds.ApplicationService {
  init() {
    const { Cars } = this.entities;

    this.before("CREATE", "Cars", async (req) => {
      const { vin, price } = req.data;

      if (!vin) {
        req.error(400, "VIN is mandatory", "vin");
      }

      if (vin && vin.length !== 17) {
        req.error(400, "VIN must contain 17 characters", "vin");
      }

      if (price === undefined || price === null || Number(price) <= 0) {
        req.error(400, "Selling price must be greater than zero", "price");
      }

      if (vin) {
        const existingCar = await cds
          .tx(req)
          .run(SELECT.one.from(Cars).where({ vin: vin }));

        if (existingCar) {
          req.error(400, "A car with this VIN already exists", "vin");
        }
      }
    });

    this.before("UPDATE", "Cars", async (req) => {
      const { price } = req.data;

      if (price === undefined || price === null || Number(price) <= 0) {
        req.error(400, "Selling price must be greater than zero", "price");
      }
    });

    return super.init();
  }
};
```

Test your validations by sending invalid requests through Bruno/Postman and observing the error responses.

---

## Project Structure

```
autostock/
├── app/
├── db/
│   ├── schema.cds
│   └── data/
│       └── autostock.inventory-Cars.csv
├── srv/
│   ├── inventory-service.cds   ← service definition
│   └── inventory-service.js    ← service implementation
├── db.sqlite
└── package.json
```

---

## Concepts

### Service Definition vs. Service Implementation

CAP separates **what** you expose from **how** you behave:

- `.cds` file — declares the service shape (entities, actions, functions). This is enough to get a fully working CRUD API.
- `.js` file — adds custom business logic on top. Without it, CAP's generic handlers handle everything.

### Projection

A projection exposes a database entity through a service, optionally filtering or transforming fields:

```cds
entity Cars as projection on db.Cars;
```

This means the `Cars` entity in the service mirrors `db.Cars` exactly. You can restrict fields: `entity Cars as select from db.Cars { vin, make, model }` to hide sensitive data.

### CAP Event Handlers: before / on / after

CAP's request lifecycle has three phases:

| Phase | When it runs | Typical use |
|-------|-------------|-------------|
| `before` | Before the database operation | Validation, enrichment |
| `on` | Instead of the default operation | Full custom handling |
| `after` | After the database operation | Transform results, trigger side-effects |

You almost never need `on` — CAP's generic handlers (SELECT, INSERT, UPDATE, DELETE) are correct and efficient. Use `before` for validation and `after` for post-processing.

### `req.error` vs `req.reject`

- `req.error(code, message, field)` — collects an error but continues processing. Multiple errors can accumulate.
- `req.reject(code, message)` — immediately stops processing and returns an error response.

For field-level validation, `req.error` is preferred because it can surface multiple issues at once to the client.

### OData Query Options

OData supports powerful server-side filtering and sorting via URL parameters:

```
GET /Cars?$filter=status eq 'AVAILABLE'
GET /Cars?$orderby=price desc
GET /Cars?$select=make,model,price
GET /Cars?$top=10&$skip=20
```

CAP implements all standard OData query options automatically — no extra code needed.

---

## Exercises

1. **Add a DELETE handler:** Add a `before("DELETE")` handler that prevents deletion of cars with status `SOLD`. Use `SELECT.one.from(Cars)` to fetch the car first, then check its status.

2. **Add an `after` handler:** Add an `after("READ", "Cars")` handler that logs how many records were returned. Use `Array.isArray(req.data) ? req.data.length : 1` to handle both single and collection reads.

3. **Custom action:** Define a custom action in `inventory-service.cds`:
   ```cds
   action markAsSold(carId: UUID) returns Cars;
   ```
   Then implement it in the `.js` file using `this.on("markAsSold", async (req) => { ... })` to update the car's status to `SOLD`.

4. **OData filtering:** Use Bruno/Postman to query only `AVAILABLE` cars using an OData `$filter` parameter. Try combining filters with `and` and sorting with `$orderby`.
