const express = require('express');
const collectorController = require('../controllers/collectorController');
const router = express.Router();


router
    .get('/', collectorController.getCollectors)
    .post('/', collectorController.createCollector)
    .patch('/:id', collectorController.updateCollector)

module.exports = router;