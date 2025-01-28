const Supplier = require('../models/supplier');
const User = require('../models/user');

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
    async getSuppliersByCreatedBy(collector_id) {
        try {
            // Fetch suppliers created by the given collector ID
            const suppliers = await Supplier.find({ created_by: collector_id });

            // Get the count of suppliers
            const count = suppliers.length;

            return {
                count, // Total number of suppliers
                suppliers, // Array of supplier objects
            };
        } catch (error) {
            console.error('Error fetching suppliers:', error.message);
            throw new Error('Could not fetch suppliers');
        }
    },
    async createSupplier(data) {
        const session = await Supplier.startSession();
        session.startTransaction();
        try {
            const {
                supplier_name,
                supplier_email,
                supplier_password,
                supplier_phone,
                supplier_NIC,
                created_by,
                isActive
            } = data;

            const user = new User({
                email: supplier_email,
                password: supplier_password,
                role: 'supplier'
            });
            await user.save({ session });

            const user_id = user._id;

            const supplier = new Supplier({
                user_id,
                supplier_name,
                supplier_email,
                supplier_phone,
                supplier_NIC,
                created_by,
                isActive,
            });
            await supplier.save({ session });

            await session.commitTransaction();
            session.endSession();

            return supplier;
        } catch (error) {
            await session.abortTransaction();
            session.endSession();

            console.error('Error creating supplier:', error.message);
            throw new Error('Could not create supplier');
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