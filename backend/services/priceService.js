const Price = require('../models/price');
const Salary = require('../models/salary');
const mongoose = require('mongoose');

const priceService = {
    assignPrice: async (price) => {
        const session = await mongoose.startSession();
        session.startTransaction();
    
        try {
            const { year, month, price: unitPrice } = price;

            // Check if price already exists for the given month and year
            const existingPrice = await Price.findOne({ year, month }).session(session);

            if (existingPrice) {
                // Update existing price
                existingPrice.price = unitPrice;
                await existingPrice.save({ session });
            } else {
                // Insert a new price document
                await new Price(price).save({ session });
            }

            // Update salaries based on the new price
            await Salary.updateMany(
                { year, month },
                [
                    {
                        $set: {
                            salary: { $multiply: ["$tea_delivered", unitPrice] }
                        }
                    }
                ],
                { session }
            );
    
            // Commit the transaction
            await session.commitTransaction();
            session.endSession();
    
            return { message: "Price assigned and salaries updated successfully" };
        } catch (error) {
            await session.abortTransaction();
            session.endSession();
            console.error('Transaction failed:', error);
            throw error;
        }
    }
}

module.exports = priceService;
