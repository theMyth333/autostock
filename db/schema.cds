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
