const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const supplierSchema = new Schema({
    user_id: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    supplier_name: {
        type: String,
        required: true
    },
    supplier_email: {
        type: String,
        required: true,
        unique: true
    },
    supplier_phone: {
        type: String,
        required: true
    },
    supplier_NIC: {
        type: String,
        required: true,
        unique: true
    },
    created_by: {
        type: Schema.Types.ObjectId,
        ref: 'Collector'
    },
    isActive: {
        type: Boolean,
        default: false
    }
}, { timestamps: true });

const Supplier = mongoose.model('Supplier', supplierSchema);

module.exports = Supplier;