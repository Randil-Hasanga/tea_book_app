const express = require('express');
const priceController = require('../controllers/priceController');
const router = express.Router();

router
    .post('/', priceController.assignPrice)

module.exports = router;