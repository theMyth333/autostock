## Unit 2 - Service Design 

### Pre-requisites
1. Install Bruno/Postman

### Instructions

## Creating OData V4 service

1. create srv/inventory-service.cds
```
using { autostock.inventory as db } from '../db/schema';

service InventoryService {

    entity Cars as projection on db.Cars;

}
```

Concepts
- Importing database model
- defining service 
- creating projection

2. compile
```
cds compile srv --to edmx
```
3. npm start to see the web json preview
4. use bruno to see get, post and patch, delete
`http://localhost:4004/odata/v4/inventory/Cars`

## Creating Behaviour 

1. Understand CAP Event Handlers before, on, after. CRUD is take care by CAP.
2. create new file inventory-service.js with 
```
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

test the read by id and the console log

3. Now add logic to CREATE event on before hook

Validating VIN
```
 const { vin, price } = req.data;

    // Validate VIN
    if (!vin) {
        req.error(400, 'VIN is mandatory', 'vin');
    }

    // Validate VIN length
    if (vin && vin.length !== 17) {
        req.error(400, 'VIN must contain 17 characters', 'vin');
    }
```
Validate Selling Price
```
    // Validate selling price
    if (price === undefined || price === null || Number(price) <= 0) {
        req.error(400, 'Selling price must be greater than zero', 'price');
    }
```

Check Duplicate VIN
```
    // Check duplicate VIN
    if (vin) {

        const existingCar = await cds.tx(req).run(
            SELECT.one
                .from(Cars)
                .where({ vin: vin })
        );

        if (existingCar) {
            req.error(400, 'A car with this VIN already exists', 'vin');
        }

    }
```

4. Add logic to update
```
 this.before("UPDATE", "Cars", async (req) => {
      const { vin, price } = req.data;
      // Validate selling price
      if (price === undefined || price === null || Number(price) <= 0) {
        req.error(400, "Selling price must be greater than zero", "price");
      }
    });
```