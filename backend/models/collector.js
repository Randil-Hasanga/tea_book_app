const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const collectorSchema = new Schema({
    collector_name: {
        type: String,
        required: true
    },
    collector_email: {
        type: String,
        required: true,
        unique: true
    },
    collector_password: {
        type: String,
        required: true
    },
    collector_phone: {
        type: String,
        required: true
    },
    collector_NIC: {
        type: String,
        required: true,
        unique: true
    },
    created_by: {
        type: Schema.Types.ObjectId
    },
    isActive: {
        type: Boolean,
        default: false
    }
}, { timestamps: true });

const Collector = mongoose.model('Collector', collectorSchema);

module.exports = Collector;