const express = require('express');
const deliveryController = require('../controllers/deliveryController')
const router = express.Router();

router
    .get('/', deliveryController.getDeliveries)
    .get('/recent/:collectorId', deliveryController.getRecentDeliveriesForCurrentMonthByCollectedBy)
    .get('/recent/supplier/:supplierId', deliveryController.getRecentDeliveriesForCurrentMonthBySuppliedBy)
    .post('/', deliveryController.createDelivery)
    .delete('/:deliveryId', deliveryController.deleteDelivery)

module.exports = router;