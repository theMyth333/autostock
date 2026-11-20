using { autostock.inventory as db } from '../db/schema';

service InventoryService {

    @restrict: [
        { grant: 'READ', to: 'Viewer' },
        { grant: '*', to: 'Admin' }
    ]
    entity Cars as projection on db.Cars;

}