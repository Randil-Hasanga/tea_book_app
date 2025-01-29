const express = require('express');
const salaryController = require('../controllers/salaryController');
const router = express.Router();

router
    .get('/:supplierId', salaryController.getSalaryForSupplier)
    .get('/all/:supplierId', salaryController.getSalaries)

module.exports = router;