sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"autostock/test/integration/pages/CarsList.gen",
	"autostock/test/integration/pages/CarsObjectPage.gen"
], function (JourneyRunner, CarsListGenerated, CarsObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('autostock') + '/test/flpSandbox.html#autostock-tile',
        pages: {
			onTheCarsListGenerated: CarsListGenerated,
			onTheCarsObjectPageGenerated: CarsObjectPageGenerated
        },
        async: true
    });

    return runner;
});

