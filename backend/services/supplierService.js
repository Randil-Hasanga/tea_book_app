const Supplier = require('../models/supplier');

const supplierService = {
    async getSuppliers(filters = {}) { // can use for get deleted collectors also
        try {
            const suppliers = await Supplier.find(filters);
            return suppliers;
        } catch (error) {
            console.error('Error fetching suppliers:', error.message);
            throw new Error('Could not fetch suppliers');
        }
    },
    async createSupplier(data) {
        try {
            const supplier = new Supplier(data);
            await supplier.save();
            return supplier;
        } catch (error) {
            console.error('Error creating collector:', error.message);
            throw new Error('Could not create collector');
        }
    },
    async updateSupplier(id, data) { // can use for soft delete also
        try {
            const supplier = await Supplier.findByIdAndUpdate(
                id,
                data,
                { new: true, runValidators: true }
            );
            if (!supplier) {
                throw new Error('Supplier not found');
            }
            return supplier;
        } catch (error) {
            console.error('Error updating supplier:', error.message);
            throw new Error('Could not update supplier');
        }
    }
}

module.exports = supplierService;