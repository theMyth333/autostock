## Unit 3 - Frontend - UI5 Fiori Elements App

### Pre-requisites 
- SAP Fiori Tools - Extension Pack for vs code
- yeoman generator


### Instructions

#### Fiori Elements App
1. Go to fior app generator
2. Use local cap project => auto selects cap project and OData Service
3. Main Entity Cars. Automatically no. Table Type Responsive
4. Explore the app folder
5. Npm run watch-autostock

#### Annotations
6. Add Title annotations
```
annotate InventoryService.Cars with {

    vin @title: 'Vehicle Identification Number';

    make @title: 'Manufacturer';

    model @title: 'Car Model';

    modelYear @title: 'Manufacturing Year';

    color @title: 'Exterior Color';

    price @title: 'Selling Price';

    currency @title: 'Currency';

    status @title: 'Inventory Status';

};
```

7. Add List Page Annotations
```
annotate InventoryService.Cars with @UI.LineItem: [
    {
        $Type: 'UI.DataField',
        Value: make,
        Label: 'Manufacturer'
    },
    {
        $Type: 'UI.DataField',
        Value: model,
        Label: 'Model'
    },
    {
        $Type: 'UI.DataField',
        Value: modelYear,
        Label: 'Year'
    },
    {
        $Type: 'UI.DataField',
        Value: price,
        Label: 'Price'
    },
    {
        $Type: 'UI.DataField',
        Value: status,
        Label: 'Status'
    }
];
```

```
annotate InventoryService.Cars with @UI.SelectionFields: [
    make,
    model,
    modelYear,
    status
];
```

CHeck cds compile srv --to edmx

8. Add Object Page annotations
```
annotate InventoryService.Cars with @UI.Identification: [
    {
        $Type: 'UI.DataField',
        Value: vin,
        Label: 'VIN'
    },
    {
        $Type: 'UI.DataField',
        Value: make,
        Label: 'Manufacturer'
    },
    {
        $Type: 'UI.DataField',
        Value: model,
        Label: 'Model'
    },
    {
        $Type: 'UI.DataField',
        Value: price,
        Label: 'Selling Price'
    }
];
```
```

annotate InventoryService.Cars with @UI.HeaderInfo: {
    TypeName: 'Car',
    TypeNamePlural: 'Cars',
    Title: {
        $Type: 'UI.DataField',
        Value: model
    },
    Description: {
        $Type: 'UI.DataField',
        Value: make
    }
};

annotate InventoryService.Cars with @UI.Facets: [
    {
        $Type: 'UI.ReferenceFacet',
        ID: 'CarDetails',
        Label: 'Car Details',
        Target: '@UI.FieldGroup#CarDetails'
    },
    {
        $Type: 'UI.ReferenceFacet',
        ID: 'Pricing',
        Label: 'Pricing and Inventory',
        Target: '@UI.FieldGroup#Pricing'
    }
];

annotate InventoryService.Cars with @UI.FieldGroup #CarDetails: {
    Data: [
        { Value: vin },
        { Value: make },
        { Value: model },
        { Value: modelYear },
        { Value: color }
    ]
};

annotate InventoryService.Cars with @UI.FieldGroup #Pricing: {
    Data: [
        { Value: price },
        { Value: currency },
        { Value: status }
    ]
};
```

check live reload of fiori app in each change 

9. Add draft capability 
```
annotate InventoryService.Cars with @odata.draft.enabled;
```

### Project Structure

### Concepts

### Exercises
