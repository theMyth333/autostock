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


