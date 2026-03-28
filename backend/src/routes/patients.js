const express = require('express');
const router = express.Router();
const { listPatients, getPatient, createPatient, updatePatient, deletePatient, getPatientExams } = require('../controllers/patientController');
const { authMiddleware } = require('../middleware/auth');

router.use(authMiddleware);

router.get('/', listPatients);
router.get('/:id', getPatient);
router.post('/', createPatient);
router.put('/:id', updatePatient);
router.delete('/:id', deletePatient);
router.get('/:id/examinations', getPatientExams);

module.exports = router;
