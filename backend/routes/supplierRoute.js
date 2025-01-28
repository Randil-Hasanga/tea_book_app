const express = require('express');
const supplierController = require('../controllers/supplierController');
const router = express.Router();

router
    .get('/', supplierController.getSuppliers)
    .get('/createdBy/:collector_id', supplierController.getSuppliersByCreatedBy)
    .post('/', supplierController.createSupplier)
    .patch('/:id', supplierController.updateSupplier)

module.exports = router;