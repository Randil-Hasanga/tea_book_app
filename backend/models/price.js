const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const priceSchema = new Schema({
    year: {
        type: Number,
        required: true
    },
    month: {
        type: Number,
        required: true
    },
    price: {
        type: Number,
        required: true
    }
}, { timestamps: true });

const Price = mongoose.model('Price', priceSchema);

module.exports = Price;