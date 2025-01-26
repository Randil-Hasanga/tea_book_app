const supplierService = require('../services/supplierService');

const supplierController = {
    getSuppliers: async (req, res) => {
        try {
            const { id, isActive } = req.query;
            let filters = {};
            if (id) {
                filters._id = id;
            }
            if (isActive) {
                filters.isActive = isActive === 'true';
            }
            const suppliers = await supplierService.getSuppliers(filters);

            res.status(200).json({ message: 'Suppliers fetched successfully', data: suppliers });
        } catch (error) {
            res.status(500).json({ message: 'Error fetching suppliers', error: error.message });
        }
    },
    createSupplier: async (req, res) => {
        try {
            const supplier = await supplierService.createSupplier(req.body);
            res.status(201).json({ message: 'Supplier created successfully', data: supplier });
        } catch (error) {
            res.status(500).json({ message: 'Error creating supplier', error: error.message });
        }
    },
    updateSupplier: async (req, res) => {
        try {
            const supplier = await supplierService.updateSupplier(req.params.id, req.body);
            res.status(200).json({ message: 'Supplier updated successfully', data: supplier });
        } catch (error) {
            res.status(500).json({ message: 'Error updating supplier', error: error.message });
        }
    }
}

module.exports = supplierController;