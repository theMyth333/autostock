const cds = require("@sap/cds");

module.exports = class InventoryService extends cds.ApplicationService {
  init() {
    const { Cars } = this.entities;

    this.before("CREATE", "Cars", async (req) => {
      const { vin, price } = req.data;

      if (!vin) {
        req.error(400, "VIN is mandatory", "vin");
      }

      if (vin && vin.length !== 17) {
        req.error(400, "VIN must contain 17 characters", "vin");
      }

      if (price === undefined || price === null || Number(price) <= 0) {
        req.error(400, "Selling price must be greater than zero", "price");
      }

      if (vin) {
        const existingCar = await cds
          .tx(req)
          .run(SELECT.one.from(Cars).where({ vin: vin }));

        if (existingCar) {
          req.error(400, "A car with this VIN already exists", "vin");
        }
      }
    });

    this.before("UPDATE", "Cars", async (req) => {
      const { vin, price } = req.data;
      // Validate selling price
      if (price === undefined || price === null || Number(price) <= 0) {
        req.error(400, "Selling price must be greater than zero", "price");
      }
    });
    
    return super.init();
  }
};
