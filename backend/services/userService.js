const User = require('../models/user'); // Adjust the path to your User model

const userService = {
    login: async (cred) => {
        const { email, password } = cred;

        try {
            // Find the user by email
            const user = await User.findOne({ email });
            if (!user) {
                throw new Error('Invalid email or password');
            }

            // Compare the provided password with the stored hashed password
            if (password !== user.password) {
                throw new Error('Invalid email or password');
            }

            // Determine the dashboard based on the user's role
            let role;
            switch (user.role) {
                case 'supplier':
                    role = 'supplier_role';
                    break;
                case 'collector':
                    role = 'collector_role';
                    break;
                case 'admin':
                    role = 'admin_role';
                    break;
                default:
                    throw new Error('User role not recognized');
            }
            // Return the user and dashboard route
            return {
                message: 'Login successful',
                role: role,
                user: {
                    id: user._id,
                    email: user.email,
                    role: user.role,
                },
            };
        } catch (error) {
            console.error('Error during login:', error.message);
            throw new Error('Login failed: ' + error.message);
        }
    },
};

module.exports = userService;
