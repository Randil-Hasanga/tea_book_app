const Collector = require('../models/collector');
const User = require('../models/user');

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
        const session = await Collector.startSession();
        session.startTransaction();
        try {
            const {
                collector_name,
                collector_email,
                collector_password,
                collector_phone,
                collector_NIC,
                created_by,
                isActive
            } = data;

            const user = new User({
                email: collector_email,
                password: collector_password,
                role: 'collector'
            });
            await user.save({ session });

            const user_id = user._id;

            const collector = new Collector({
                user_id,
                collector_name,
                collector_email,
                collector_phone,
                collector_NIC,
                created_by,
                isActive,
            });
            await collector.save({ session });

            await session.commitTransaction();
            session.endSession();

            return collector;
        } catch (error) {
            await session.abortTransaction();
            session.endSession();

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