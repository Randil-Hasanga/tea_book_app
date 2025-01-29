const express = require('express');
const deliveryController = require('../controllers/deliveryController')
const router = express.Router();

router
    .get('/', deliveryController.getDeliveries)
    .get('/recent/:collectorId', deliveryController.getRecentDeliveriesForCurrentMonthByCollectedBy)
    .get('/recent/supplier/:supplierId', deliveryController.getRecentDeliveriesForCurrentMonthBySuppliedBy)
    .get('/supplier/', deliveryController.getDeliveriesBySupplier)
    .post('/', deliveryController.createDelivery)
    .delete('/:deliveryId', deliveryController.deleteDelivery)

module.exports = router;