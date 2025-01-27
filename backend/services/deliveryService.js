const Delivery = require('../models/delivery');
const Salary = require('../models/salary')

const deliveryService = {
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