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
    updateDelivery: async (req, res) => {
        try {
            const { deliveryId } = req.params;
            const updatedData = req.body;
            const delivery = await deliveryService.updateDelivery(deliveryId, updatedData);
            res.json({ message: 'Delivery updated successfully', data: delivery });
        } catch (error) {
            res.status(500).json({ message: 'Error updating delivery', error: error.message });
        }
    },
    deleteDelivery: async (req, res) => {
        try {
            const { deliveryId } = req.params;
            await deliveryService.deleteDelivery(deliveryId);
            res.json({ message: 'Delivery deleted successfully' });
        } catch (error) {
            res.status(500).json({ message: 'Error deleting delivery', error: error.message });
        }
    }
}

module.exports = deliveryController;