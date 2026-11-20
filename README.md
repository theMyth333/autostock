## Unit 0 - Project Setup

1. create new file inside db as "schema.cds"
2. copy the following. 

~~~
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
~~~

3. Understand concepts
    - namespace
    - aspects
    - entity
    - data type

4. complile and validate
```
cds compile db --to sql --dialect sqlite
```

5. create data folder inside db and create csv file,  autostock.inventory-Cars (namespace-entity.csv)
```
ID,vin,make,model,modelYear,color,price,currency,status
11111111-1111-1111-1111-111111111111,MA1AB2CD3EF456789,Toyota,Innova Crysta,2024,White,2500000,INR,AVAILABLE
22222222-2222-2222-2222-222222222222,MA2BC3DE4FG567890,Hyundai,Creta,2023,Black,1500000,INR,AVAILABLE
33333333-3333-3333-3333-333333333333,MA3CD4EF5GH678901,Honda,City,2022,Silver,1200000,INR,SOLD
44444444-4444-4444-4444-444444444444,MA4DE5FG6HI789012,Maruti,Baleno,2024,Red,850000,INR,AVAILABLE
55555555-5555-5555-5555-555555555555,MA5EF6GH7IJ890123,Tata,Nexon,2023,Blue,1100000,INR,RESERVED
```
6. create actual table in sqlite
```
cds deploy --to sqlite:db.sqlite
```

7. inspect SQLite database
`sqlite3 db.sqlite`
`.tables`
```
select * from autostock_inventory_Cars;
```


#### Project Structure

~~~
autostock/
├── app/
├── db/
│   ├── schema.cds
│   └── data/
│       └── autostock.inventory-Cars.csv
├── srv/
├── db.sqlite
└── package.json
~~~

