const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const salarySchema = new Schema({
    supplier_id: {
        type: Schema.Types.ObjectId,
        ref: 'Supplier',
        required: true
    },
    year: {
        type: Number,
        required: true
    },
    month: {
        type: Number,
        required: true
    },
    tea_delivered:{
        type: Number,
        required: true
    },
    salary: {
        type: Number
    }
}, { timestamps: true });

const Salary = mongoose.model('Salary', salarySchema);

module.exports = Salary;