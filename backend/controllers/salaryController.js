const salaryService = require('../services/salaryService');
const salaryController = {
    getNetWeightForMonth: async (req, res) => {
        try {
            const { supplierId } = req.params;
            const salary = await salaryService.getNetWeightForMonth(supplierId);
            res.status(200).json({ message: 'Salary fetched successfully', data: salary });
        } catch (error) {
            res.status(500).json({ message: 'Error fetching salary', error: error.message });
        }
    }
}

module.exports = salaryController;