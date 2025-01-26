const deliveryService = require('../services/deliveryService');

const deliveryController = {
    createDelivery: async (req, res) => {
        try {
            const delivery = await deliveryService.createDelivery(req.body);
            res.status(201).json({ message: 'Delivery created successfully', data: delivery });
        } catch (error) {
            res.status(500).json({ message: 'Error creating delivery', error: error.message });
        }
    },
}

module.exports = deliveryController;