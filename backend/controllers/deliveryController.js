const { get } = require('mongoose');
const deliveryService = require('../services/deliveryService');

const deliveryController = {
    getDeliveries: async (req, res) => {
        try {
            // Get collectorId, month, and year from query parameters
            const { collectorId, month, year } = req.query;
    
            // Validate required parameters
            if (!collectorId) {
                return res.status(400).json({ message: 'Collector ID is required' });
            }
    
            if (!month || !year) {
                return res.status(400).json({ message: 'Month and year are required' });
            }
    
            // Convert month and year to integers
            const parsedMonth = parseInt(month, 10);
            const parsedYear = parseInt(year, 10);
    
            // Ensure valid month and year
            if (isNaN(parsedMonth) || isNaN(parsedYear)) {
                return res.status(400).json({ message: 'Invalid month or year' });
            }
    
            // Call the service function to get deliveries for the specific collector and month/year
            const deliveries = await deliveryService.getDeliveries(collectorId, parsedMonth, parsedYear);
    
            // If no deliveries are found, return a 404 response
            if (!deliveries || deliveries.length === 0) {
                return res.status(404).json({ message: 'No deliveries found for this collector' });
            }
    
            // Return the filtered deliveries
            res.json(deliveries);
        } catch (error) {
            // Handle any errors
            res.status(500).json({ message: 'Error getting deliveries', error: error.message });
        }
    },
    getRecentDeliveriesForCurrentMonthByCollectedBy: async (req,res) => {
        try {
            const { collectorId } = req.params;
            const deliveries = await deliveryService.getRecentDeliveriesForCurrentMonthByCollectedBy(collectorId);
            res.json(deliveries);
        } catch (error) {
            res.status(500).json({ message: 'Error getting recent deliveries', error: error.message });
        }
    },
    getRecentDeliveriesForCurrentMonthBySuppliedBy: async (req,res) => {
        try {
            const { supplierId } = req.params;
            const deliveries = await deliveryService.getRecentDeliveriesForCurrentMonthBySuppliedBy(supplierId);
            res.json(deliveries);
        } catch (error) {
            res.status(500).json({ message: 'Error getting recent deliveries', error: error.message });
        }
    },
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