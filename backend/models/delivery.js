const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const deliverySchema = new Schema({
    supplied_by: {
        type: Schema.Types.ObjectId,
        ref: 'Supplier',
        required: true
    },
    collected_by: {
        type: Schema.Types.ObjectId,
        ref: 'Collector',
        required: true
    },
    total_weight: {
        type: Number,
        required: true
    },
    bag_weight: {
        type: Number,
        required: true
    },
    net_weight: {
        type: Number,
        required: true
    }
}, { timestamps: true });

const Delivery = mongoose.model('Delivery', deliverySchema);

module.exports = Delivery;