const Collector = require('../models/collector');

const collectorService = {
    async getCollectors(filters = {}) { // can use for get deleted collectors also
        try {
            const collectors = await Collector.find(filters);
            return collectors;
        } catch (error) {
            console.error('Error fetching collectors:', error.message);
            throw new Error('Could not fetch collectors');
        }
    },
    async createCollector(data) {
        try {
            const collector = new Collector(data);
            await collector.save();
            return collector;
        } catch (error) {
            console.error('Error creating collector:', error.message);
            throw new Error('Could not create collector');
        }
    },
    async updateCollector(id, data) { // can use for soft delete also
        try {
            const collector = await Collector.findByIdAndUpdate(
                id,
                data,
                { new: true, runValidators: true }
            );
            if (!collector) {
                throw new Error('Collector not found');
            }
            return collector;
        } catch (error) {
            console.error('Error updating collector:', error.message);
            throw new Error('Could not update collector');
        }
    }
    

}

module.exports = collectorService;