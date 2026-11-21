# Unit 03 - Frontend App (SAP Fiori Elements)

## Pre-requisites

- Completed **Unit 02 - Service Design** with a running OData service
- VS Code with the **SAP Fiori Tools - Extension Pack** installed
  - Install from VS Code marketplace: search `SAP Fiori Tools`
- **Yeoman** generator (installed alongside Fiori Tools)
- Node.js v18 or higher

---

## Instructions

### Part 1 — Generate the Fiori Elements App

#### 1. Open the Fiori Application Generator

In VS Code, open the Command Palette (`Ctrl+Shift+P`) and type:

```
Fiori: Open Application Generator
```

Configure it as follows:

| Setting | Value |
|---------|-------|
| Application Type | SAP Fiori |
| Floorplan | List Report Object Page |
| Data source | Use a Local CAP Project |
| CAP project folder path | _(auto-detected)_ |
| OData service | `InventoryService (Node.js)` |
| Main entity | `Cars` |
| Navigation entity | _(none)_ |
| Table type | Responsive Table |
| Module name | `autostock` |

The generator creates the full app scaffold inside `app/autostock/`.

#### 2. Start the app with live reload

```bash
npm run watch-autostock
```

This starts both the CAP backend and the Fiori preview. Open the URL shown in the terminal (usually `http://localhost:4004/autostock/webapp/index.html`).

---

### Part 2 — Adding UI Annotations

Annotations tell the Fiori framework how to render your data. Create `srv/annotations.cds`.

#### 3. Add field title annotations

These replace technical field names with human-readable labels throughout the UI:

```cds
using { InventoryService } from './inventory-service';

annotate InventoryService.Cars with {

    vin        @title: 'Vehicle Identification Number';
    make       @title: 'Manufacturer';
    model      @title: 'Car Model';
    modelYear  @title: 'Manufacturing Year';
    color      @title: 'Exterior Color';
    price      @title: 'Selling Price';
    currency   @title: 'Currency';
    status     @title: 'Inventory Status';

};
```

Save and watch the app reload — column headers update immediately.

#### 4. Configure the List Page columns

```cds
annotate InventoryService.Cars with @UI.LineItem: [
    { $Type: 'UI.DataField', Value: make,      Label: 'Manufacturer' },
    { $Type: 'UI.DataField', Value: model,     Label: 'Model' },
    { $Type: 'UI.DataField', Value: modelYear, Label: 'Year' },
    { $Type: 'UI.DataField', Value: price,     Label: 'Price' },
    { $Type: 'UI.DataField', Value: status,    Label: 'Status' }
];
```

#### 5. Add filter bar fields

```cds
annotate InventoryService.Cars with @UI.SelectionFields: [
    make,
    model,
    modelYear,
    status
];
```

Verify the compiled EDMX is correct:

```bash
cds compile srv --to edmx
```

#### 6. Configure the Object Page header

When the user clicks a row, they see the Object Page. Configure the header:

```cds
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
```

#### 7. Configure the Object Page sections (Facets)

```cds
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

#### 8. Enable draft editing

Draft allows users to save partial edits without committing to the database. Add this single annotation to unlock Create/Edit/Delete in the UI:

```cds
annotate InventoryService.Cars with @odata.draft.enabled;
```

After adding this, restart the server. You should now see **Create**, **Edit**, and **Delete** buttons in the Fiori app.

---

## Project Structure

```
autostock/
├── app/
│   ├── autostock/              ← generated Fiori Elements app
│   │   ├── webapp/
│   │   │   ├── manifest.json
│   │   │   └── index.html
│   │   ├── annotations.cds
│   │   └── ui5.yaml
│   └── services.cds            ← references app-level annotations
├── db/
│   ├── schema.cds
│   └── data/
│       └── autostock.inventory-Cars.csv
├── srv/
│   ├── annotations.cds         ← UI annotations (created in this unit)
│   ├── inventory-service.cds
│   └── inventory-service.js
└── package.json
```

---

## Concepts

### Fiori Elements vs. Freestyle UI5

SAP Fiori offers two development approaches:

| Fiori Elements | Freestyle UI5 |
|----------------|--------------|
| Annotation-driven, low code | Full programmatic control |
| UI generated from metadata | Custom HTML/JS/CSS |
| Consistent SAP UX out of the box | Fully customisable |
| Fast to build, automatic updates | More effort, more flexibility |

For standard business apps (list/detail, forms, tables), Fiori Elements is the recommended approach. The UI adapts automatically to annotation changes — no JavaScript required.

### CDS Annotations

Annotations add metadata to your CDS model without changing its structure. They follow the `@` prefix syntax:

```cds
annotate Entity with @Annotation: value;
```

SAP's OData vocabulary defines standard annotations for UI (`@UI.*`), capabilities (`@Capabilities.*`), and more. The Fiori runtime reads these annotations at runtime to render the correct UI components.

### `@UI.LineItem`

Defines which columns appear in the list table. Each entry is a `DataField` pointing to an entity property:

```cds
@UI.LineItem: [
    { $Type: 'UI.DataField', Value: fieldName, Label: 'Display Label' }
]
```

### `@UI.Facets` and `@UI.FieldGroup`

Together, these define the Object Page layout:
- **Facets** define the sections (tabs or panels)
- **FieldGroup** defines the fields inside each section

They are linked by the `Target` property in Facets referencing a named FieldGroup (`#GroupName`).

### Draft Capability (`@odata.draft.enabled`)

CAP's draft mechanism stores in-progress edits in a separate draft table alongside the active table. The user can:
- Create/edit without immediately committing
- Navigate away and return to continue editing
- Discard changes if needed

Enabling draft is a single annotation — CAP generates all the necessary OData draft actions automatically.

---

## Exercises

1. **Add a new column:** Add the `vin` field to `@UI.LineItem` so it appears as a column in the list. Consider its position in the array relative to other fields.

2. **Add a filter:** Add `color` to `@UI.SelectionFields` and test filtering the list by colour.

3. **Add a third Object Page section:** Create a new `@UI.FieldGroup #Identification` containing only the `vin` field, and add a corresponding `@UI.ReferenceFacet` entry in `@UI.Facets`.

4. **Explore criticality:** SAP Fiori can colour-code status fields. Research the `@UI.Criticality` annotation and add it to the `status` field so `AVAILABLE` appears green, `RESERVED` orange, and `SOLD` red. You may need to introduce a computed field or use a value mapping.
