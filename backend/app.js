const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();

app.use(express.static(path.join(__dirname, "public")));
app.use(cors());
app.use(express.json());

// Route imports
const collectorRoute = require('./routes/collectorRoute');
const supplierRoute = require('./routes/supplierRoute');
const deliveryRoute = require('./routes/deliveryRoute');
const userRoute = require('./routes/userRoute');
const salaryRoute = require('./routes/salaryRoute');
const priceRoute = require('./routes/priceRoute');

// Use Routes
app.use('/collector', collectorRoute);
app.use('/supplier', supplierRoute);
app.use('/delivery', deliveryRoute);
app.use('/user', userRoute);
app.use('/salary', salaryRoute);
app.use('/price', priceRoute);

module.exports = app;
