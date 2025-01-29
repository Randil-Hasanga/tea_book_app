const express = require('express');
const salaryController = require('../controllers/salaryController');
const router = express.Router();

router
    .get('/:supplierId', salaryController.getNetWeightForMonth);

module.exports = router;