const Salary = require('../models/salary');

const SalaryService = {
    getNetWeightForMonth: async (supplier_id) => {
        try {
            const date = new Date();
            const year = date.getFullYear();
            const month = date.getMonth() + 1;
            
            let salary = await Salary.findOne({
                supplier_id,
                year,
                month,
            });
            return salary;
        } catch (error) {
            console.error('Error fetching suppliers:', error.message);
            throw new Error('Could not fetch suppliers');
        }
    }
};

module.exports = SalaryService;