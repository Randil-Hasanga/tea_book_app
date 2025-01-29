const salaryService = require('../services/salaryService');
const salaryController = {

    getSalaries: async (req, res) => {
        try {
            const { supplierId } = req.params;
            const salary = await salaryService.getSalaries(supplierId);
            res.json(salary);
        } catch (error) {
            res.status(500).json({ message: 'Error fetching salary', error: error.message });
        }
    },
    getSalaryForSupplier: async (req, res) => {
        try {
            const { supplierId } = req.params;
            const salary = await salaryService.getSalaryForSupplier(supplierId);
            res.status(200).json({ message: 'Salary fetched successfully', data: salary });
        } catch (error) {
            res.status(500).json({ message: 'Error fetching salary', error: error.message });
        }
    }
}

module.exports = salaryController;