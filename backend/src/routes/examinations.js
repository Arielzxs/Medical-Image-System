const express = require('express');
const router = express.Router();
const { listExaminations, getExamination, createExamination, updateExamination, deleteExamination } = require('../controllers/examinationController');
const { authMiddleware } = require('../middleware/auth');

router.use(authMiddleware);

router.get('/', listExaminations);
router.get('/:id', getExamination);
router.post('/', createExamination);
router.put('/:id', updateExamination);
router.delete('/:id', deleteExamination);

module.exports = router;
