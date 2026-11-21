# Unit 01 - Data Modelling

## Pre-requisites

- Completed **Unit 00 - Project Setup** with a working CAP project
- SQLite installed and accessible from the terminal (`sqlite3 --version`)
- VS Code with SAP CDS Language Support extension

---

## Instructions

### 1. Create the database schema

Create a new file `db/schema.cds` and add the following:

```cds
namespace autostock.inventory;

using { cuid, managed } from '@sap/cds/common';

entity Cars : cuid, managed {

    vin        : String(17) not null;
    make       : String(50) not null;
    model      : String(50) not null;
    modelYear  : Integer;
    color      : String(30);

    price      : Decimal(12,2);
    currency   : String(3);

    status     : String(20) default 'AVAILABLE';

}
```

### 2. Compile the schema to SQL

Validate that your CDS model compiles correctly and inspect the generated SQL:

```bash
cds compile db --to sql --dialect sqlite
```

This prints the SQL `CREATE TABLE` statements to the console. You should see a table called `autostock_inventory_Cars` — notice how CAP converts the namespace and entity name into a table name.

### 3. Create seed data

Create the folder `db/data/` and inside it create a CSV file named exactly:

```
autostock.inventory-Cars.csv
```

> The naming convention is `<namespace>-<EntityName>.csv`. CAP uses this to automatically load data when deploying.

Paste the following content:

```csv
ID,vin,make,model,modelYear,color,price,currency,status
11111111-1111-1111-1111-111111111111,MA1AB2CD3EF456789,Toyota,Innova Crysta,2024,White,2500000,INR,AVAILABLE
22222222-2222-2222-2222-222222222222,MA2BC3DE4FG567890,Hyundai,Creta,2023,Black,1500000,INR,AVAILABLE
33333333-3333-3333-3333-333333333333,MA3CD4EF5GH678901,Honda,City,2022,Silver,1200000,INR,SOLD
44444444-4444-4444-4444-444444444444,MA4DE5FG6HI789012,Maruti,Baleno,2024,Red,850000,INR,AVAILABLE
55555555-5555-5555-5555-555555555555,MA5EF6GH7IJ890123,Tata,Nexon,2023,Blue,1100000,INR,RESERVED
```

### 4. Deploy to SQLite

This creates a local `db.sqlite` file and loads your seed data:

```bash
cds deploy --to sqlite:db.sqlite
```

### 5. Inspect the database

Open an interactive SQLite session to verify your data:

```bash
sqlite3 db.sqlite
```

Inside the session:

```sql
.tables
SELECT * FROM autostock_inventory_Cars;
.quit
```

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
├── db.sqlite
└── package.json
```

---

## Concepts

### Namespace

A namespace groups your entities to avoid naming collisions, especially when multiple teams or packages work together:

```cds
namespace autostock.inventory;
```

All entities in this file are automatically prefixed with `autostock.inventory`. When CAP generates a database table, it converts `autostock.inventory.Cars` → `autostock_inventory_Cars`.

### Aspects: `cuid` and `managed`

Aspects are reusable mixins — they add pre-defined fields to your entity without you having to declare them manually.

- **`cuid`** — adds a `ID: UUID` primary key field. CAP auto-generates a UUID when a new record is created.
- **`managed`** — adds four audit fields: `createdAt`, `createdBy`, `modifiedAt`, `modifiedBy`. CAP fills these automatically.

```cds
entity Cars : cuid, managed { ... }
```

You inherit both aspects by listing them after the colon, separated by commas.

### Entity

An entity is a CDS concept that maps directly to a database table. Each property inside the entity becomes a column:

```cds
entity Cars {
    vin   : String(17) not null;  // VARCHAR(17) NOT NULL
    price : Decimal(12,2);        // DECIMAL(12,2)
    status: String(20) default 'AVAILABLE';  // with a default value
}
```

### Data Types

| CDS Type | SQL Equivalent | Use |
|----------|---------------|-----|
| `String(n)` | VARCHAR(n) | Text with max length |
| `Integer` | INTEGER | Whole numbers |
| `Decimal(p,s)` | DECIMAL(p,s) | Precise numbers (prices) |
| `Boolean` | BOOLEAN | True/false |
| `Date` | DATE | Calendar dates |
| `UUID` | CHAR(36) | Unique identifiers |

### CSV Seed Data

CAP automatically loads CSV files from `db/data/` when you run `cds deploy`. The file name must match the fully-qualified entity name: `<namespace>-<Entity>.csv`. This is a development convenience — in production, real data comes from users via the API.

---

## Exercises

1. **Add a new field:** Add a `mileage : Integer` field to the `Cars` entity. Re-deploy and verify the column appears in SQLite with `.schema autostock_inventory_Cars`.

2. **Add a new entity:** Create a `Dealers` entity in the same schema with fields: `name`, `city`, `contactEmail`. Add a few rows to a seed CSV file for it.

3. **Experiment with constraints:** Try removing `not null` from the `make` field, re-deploying, and inserting a row without a `make` value via SQLite. Then add the constraint back and see what happens.

4. **Explore `managed` fields:** After deploying, insert a new car record via SQLite and query it. Notice that `createdAt` and `modifiedAt` are `NULL` — these are only populated by the CAP runtime (via the service layer), not by raw SQL inserts. This demonstrates why the service layer matters.
