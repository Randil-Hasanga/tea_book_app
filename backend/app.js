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

// Use Routes
app.use('/collector', collectorRoute);
app.use('/supplier', supplierRoute);
app.use('/delivery', deliveryRoute);

module.exports = app;
