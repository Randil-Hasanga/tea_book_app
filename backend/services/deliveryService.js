const Delivery = require('../models/delivery');
const Salary = require('../models/salary')

const deliveryService = {
    getDeliveries: async (collectorId, month, year) => {
        try {
            // Calculate the start and end dates for the month
            const startDate = new Date(year, month - 1, 1); // First day of the month
            const endDate = new Date(year, month, 0, 23, 59, 59, 999); // Last day of the month
    
            const deliveries = await Delivery.find({
                collected_by: collectorId, // Filter by collector
                createdAt: {
                    $gte: startDate, // Created at or after the start date
                    $lt: endDate // Created before the end date
                }
            })
                .populate('collected_by') // Populate the 'collected_by' field
                .populate('supplied_by', 'supplier_name supplier_email supplier_phone'); // Populate 'supplied_by' with specific fields
    
            return deliveries;
        } catch (error) {
            console.error('Error getting deliveries:', error.message);
            throw new Error('Could not get deliveries');
        }
    },
    getRecentDeliveriesForCurrentMonthByCollectedBy: async (collectorId) => {
        try {
            // Get the current month and year
            const currentDate = new Date();
            const currentMonth = currentDate.getMonth() + 1; // Months are zero-indexed, so add 1
            const currentYear = currentDate.getFullYear();
    
            // Find deliveries based on the current month and year
            const deliveries = await Delivery.find({
                collected_by: collectorId,
                createdAt: {
                    $gte: new Date(currentYear, currentMonth - 1, 1), // Start of the current month
                    $lt: new Date(currentYear, currentMonth, 0),      // End of the current month
                },
            })
            .populate('collected_by')  // Populate the 'collected_by' field
            .populate('supplied_by', 'supplier_name supplier_email supplier_phone')  // Populate the 'supplied_by' field
    
            // Sort deliveries by createdAt (newest to oldest) and limit to 5 results
            const sortedAndLimitedDeliveries = deliveries
                .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)) // Sort from newest to oldest
                .slice(0, 3); // Limit to 5 results
    
            return sortedAndLimitedDeliveries;
        } catch (error) {
            console.error('Error fetching recent deliveries:', error.message);
            throw new Error('Could not get recent deliveries');
        }
    },
    getRecentDeliveriesForCurrentMonthBySuppliedBy: async (supplierId) => {
        try {
            // Get the current month and year
            const currentDate = new Date();
            const currentMonth = currentDate.getMonth() + 1; // Months are zero-indexed, so add 1
            const currentYear = currentDate.getFullYear();
    
            // Find deliveries based on the current month and year
            const deliveries = await Delivery.find({
                supplied_by: supplierId,
                createdAt: {
                    $gte: new Date(currentYear, currentMonth - 1, 1), // Start of the current month
                    $lt: new Date(currentYear, currentMonth, 0),      // End of the current month
                },
            })
            .populate('collected_by')  // Populate the 'collected_by' field
            .populate('supplied_by', 'supplier_name supplier_email supplier_phone')  // Populate the 'supplied_by' field
    
            // Sort deliveries by createdAt (newest to oldest) and limit to 5 results
            const sortedAndLimitedDeliveries = deliveries
                .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)) // Sort from newest to oldest
                .slice(0, 3); // Limit to 5 results
    
            return sortedAndLimitedDeliveries;
        } catch (error) {
            console.error('Error fetching recent deliveries:', error.message);
            throw new Error('Could not get recent deliveries');
        }
    },    
    getDeliveriesBySupplier: async (supplierId, month, year) => {
        try {
            // Calculate the start and end dates for the month
            const startDate = new Date(year, month - 1, 1); // First day of the month
            const endDate = new Date(year, month, 0, 23, 59, 59, 999); // Last day of the month
    
            const deliveries = await Delivery.find({
                supplied_by: supplierId, // Filter by collector
                createdAt: {
                    $gte: startDate, // Created at or after the start date
                    $lt: endDate // Created before the end date
                }
            })
                .populate('collected_by') // Populate the 'collected_by' field
                .populate('supplied_by', 'supplier_name supplier_email supplier_phone'); // Populate 'supplied_by' with specific fields
    
            return deliveries;
        } catch (error) {
            console.error('Error getting deliveries:', error.message);
            throw new Error('Could not get deliveries');
        }
    },
    createDelivery: async (data) => {
        const session = await Delivery.startSession();
        session.startTransaction();

        try {
            const delivery = new Delivery(data);
            await delivery.save({ session });

            const { supplied_by, net_weight } = data;
            const supplier_id = supplied_by;

            const date = new Date();
            const year = date.getFullYear();
            const month = date.getMonth() + 1; // Adjust for zero-based month index

            let salary = await Salary.findOne({
                supplier_id,
                year,
                month,
            }).session(session);

            if (salary) {
                salary.tea_delivered += net_weight;
            } else {
                salary = new Salary({
                    supplier_id,
                    year,
                    month,
                    tea_delivered: net_weight,
                });
            }
            await salary.save({ session });

            await session.commitTransaction();
            session.endSession();

            return delivery;
        } catch (error) {
            await session.abortTransaction();
            session.endSession();
            console.error('Error creating delivery:', error.message);
            throw new Error('Could not create delivery');
        }
    },
    deleteDelivery: async (deliveryId) => {
        const session = await Delivery.startSession();
        session.startTransaction();

        try {
            // Find the existing delivery
            const existingDelivery = await Delivery.findById(deliveryId).session(session);
            if (!existingDelivery) {
                throw new Error("Delivery not found");
            }

            const { net_weight, supplied_by: supplierId, createdAt } = existingDelivery;

            // Get the year and month from the delivery's creation date
            const date = new Date(createdAt);
            const year = date.getFullYear();
            const month = date.getMonth() + 1; // Adjust for zero-based month index

            // Find the salary record
            const salary = await Salary.findOne({
                supplier_id: supplierId,
                year,
                month,
            }).session(session);

            if (!salary) {
                throw new Error("Salary record not found");
            }

            // Adjust the tea_delivered in the salary
            salary.tea_delivered -= net_weight;

            // Prevent negative values for tea_delivered
            if (salary.tea_delivered < 0) {
                salary.tea_delivered = 0;
            }

            await salary.save({ session });

            // Delete the delivery
            await Delivery.findByIdAndDelete(deliveryId).session(session);

            await session.commitTransaction();
            session.endSession();

            return { message: "Delivery deleted and salary updated successfully" };
        } catch (error) {
            await session.abortTransaction();
            session.endSession();

            console.error("Error deleting delivery:", error.message);
            throw new Error("Could not delete delivery");
        }
    }
}

module.exports = deliveryService;