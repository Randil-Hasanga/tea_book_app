const collectorService = require('../services/collectorService');

const collectorController = {
    getCollectors: async (req, res) => {
        try {
            const { id, isActive } = req.query;
            let filters = {};
            if (id) {
                filters._id = id;
            }
            if (isActive) {
                filters.isActive = isActive === 'true';
            }
            const collectors = await collectorService.getCollectors(filters);

            res.status(200).json({ message: 'Collectors fetched successfully', data: collectors });
        } catch (error) {
            res.status(500).json({ message: 'Error fetching collectors', error: error.message });
        }
    },
    createCollector: async (req, res) => {
        try {
            const collector = await collectorService.createCollector(req.body);
            res.status(201).json({ message: 'Collector created successfully', data: collector });
        } catch (error) {
            res.status(500).json({ message: 'Error creating collector', error: error.message });
        }
    },
    updateCollector: async (req, res) => {
        try {
            const collector = await collectorService.updateCollector(req.params.id, req.body);
            res.status(200).json({ message: 'Collector updated successfully', data: collector });
        } catch (error) {
            res.status(500).json({ message: 'Error updating collector', error: error.message });
        }
    }
}

module.exports = collectorController;