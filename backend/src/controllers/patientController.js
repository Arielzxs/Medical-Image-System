const { getDb } = require('../db');

function listPatients(req, res) {
  const { page = 1, page_size = 10, keyword = '' } = req.query;
  const offset = (parseInt(page) - 1) * parseInt(page_size);
  const db = getDb();

  const search = `%${keyword}%`;
  const total = db.prepare(`
    SELECT COUNT(*) as count FROM patients
    WHERE name LIKE ? OR patient_no LIKE ? OR phone LIKE ?
  `).get(search, search, search).count;

  const rows = db.prepare(`
    SELECT p.*, u.real_name as doctor_name
    FROM patients p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.name LIKE ? OR p.patient_no LIKE ? OR p.phone LIKE ?
    ORDER BY p.created_at DESC
    LIMIT ? OFFSET ?
  `).all(search, search, search, parseInt(page_size), offset);

  res.json({ code: 200, data: { total, rows, page: parseInt(page), page_size: parseInt(page_size) } });
}

function getPatient(req, res) {
  const db = getDb();
  const patient = db.prepare(`
    SELECT p.*, u.real_name as doctor_name
    FROM patients p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.id = ?
  `).get(req.params.id);
  if (!patient) {
    return res.status(404).json({ code: 404, message: '患者不存在' });
  }
  res.json({ code: 200, data: patient });
}

function createPatient(req, res) {
  const { patient_no, name, gender, birth_date, id_card, phone, address, medical_history } = req.body;
  if (!name) {
    return res.status(400).json({ code: 400, message: '患者姓名不能为空' });
  }

  const db = getDb();

  // Auto-generate patient_no if not provided
  let pNo = patient_no;
  if (!pNo) {
    const count = db.prepare('SELECT COUNT(*) as count FROM patients').get().count;
    pNo = `P${new Date().getFullYear()}${String(count + 1).padStart(4, '0')}`;
  } else {
    const existing = db.prepare('SELECT id FROM patients WHERE patient_no = ?').get(pNo);
    if (existing) {
      return res.status(400).json({ code: 400, message: '病历号已存在' });
    }
  }

  const result = db.prepare(`
    INSERT INTO patients (patient_no, name, gender, birth_date, id_card, phone, address, medical_history, created_by)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(pNo, name, gender, birth_date, id_card, phone, address, medical_history, req.user.id);

  res.json({ code: 200, message: '创建成功', data: { id: result.lastInsertRowid, patient_no: pNo } });
}

function updatePatient(req, res) {
  const { name, gender, birth_date, id_card, phone, address, medical_history } = req.body;
  const db = getDb();
  const patient = db.prepare('SELECT id FROM patients WHERE id = ?').get(req.params.id);
  if (!patient) {
    return res.status(404).json({ code: 404, message: '患者不存在' });
  }

  db.prepare(`
    UPDATE patients SET name=?, gender=?, birth_date=?, id_card=?, phone=?, address=?, medical_history=?, updated_at=CURRENT_TIMESTAMP
    WHERE id=?
  `).run(name, gender, birth_date, id_card, phone, address, medical_history, req.params.id);

  res.json({ code: 200, message: '更新成功' });
}

function deletePatient(req, res) {
  const db = getDb();
  const patient = db.prepare('SELECT id FROM patients WHERE id = ?').get(req.params.id);
  if (!patient) {
    return res.status(404).json({ code: 404, message: '患者不存在' });
  }
  db.prepare('DELETE FROM patients WHERE id = ?').run(req.params.id);
  res.json({ code: 200, message: '删除成功' });
}

function getPatientExams(req, res) {
  const db = getDb();
  const exams = db.prepare(`
    SELECT e.*, u.real_name as doctor_name,
      (SELECT COUNT(*) FROM images WHERE examination_id = e.id) as image_count
    FROM examinations e
    LEFT JOIN users u ON e.doctor_id = u.id
    WHERE e.patient_id = ?
    ORDER BY e.exam_date DESC
  `).all(req.params.id);
  res.json({ code: 200, data: exams });
}

module.exports = { listPatients, getPatient, createPatient, updatePatient, deletePatient, getPatientExams };
