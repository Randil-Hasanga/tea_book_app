const priceService = require('../services/priceService');

const priceController = {
    assignPrice: async (req, res) => {
        try {
            // Parse query parameters
            const price = parseFloat(req.query.price);
            const month = parseInt(req.query.month);
            const year = parseInt(req.query.year);
    
            // Validate inputs
            if (isNaN(price) || isNaN(month) || isNaN(year)) {
                return res.status(400).json({ message: 'Invalid price, month, or year' });
            }
    
            // Call the assignPrice function (ensure it accepts month & year)
            const newPrice = await priceService.assignPrice({ price, month, year });
    
            res.status(201).json({ message: 'Price assigned successfully', data: newPrice });
        } catch (error) {
            res.status(500).json({ message: 'Error assigning price', error: error.message });
        }
    }
    
}

module.exports = priceController;