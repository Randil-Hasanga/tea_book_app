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
    }
}

module.exports = deliveryService;