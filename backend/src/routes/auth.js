const express = require('express');
const router = express.Router();
const { login, getProfile, updateProfile, changePassword, listUsers, createUser, deleteUser } = require('../controllers/authController');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

router.post('/login', login);
router.get('/profile', authMiddleware, getProfile);
router.put('/profile', authMiddleware, updateProfile);
router.put('/password', authMiddleware, changePassword);

// Admin routes
router.get('/users', authMiddleware, adminMiddleware, listUsers);
router.post('/users', authMiddleware, adminMiddleware, createUser);
router.delete('/users/:id', authMiddleware, adminMiddleware, deleteUser);

module.exports = router;
