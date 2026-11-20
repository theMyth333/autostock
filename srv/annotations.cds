annotate InventoryService.Cars with @odata.draft.enabled;

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

// List Page Annotations

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

annotate InventoryService.Cars with @UI.SelectionFields: [
    make,
    model,
    modelYear,
    status
];


// Object Page Annotations

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