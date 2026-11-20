using { autostock.inventory as db } from '../db/schema';

service InventoryService {

    entity Cars as projection on db.Cars;

}