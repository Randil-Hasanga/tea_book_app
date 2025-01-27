const userService = require('../services/userService');

const userController = {
    login: async (req, res) => {
        try {
            const { email, password } = req.body;

            // Ensure email and password are provided
            if (!email || !password) {
                return res.status(400).json({ message: 'Email and password are required' });
            }

            // Call the login service with credentials
            const loginResponse = await userService.login({ email, password });

            // Send the response to the client
            res.status(200).json(loginResponse);
        } catch (error) {
            console.error('Login error:', error.message);
            res.status(401).json({ message: error.message });
        }
    },
};

module.exports = userController;
