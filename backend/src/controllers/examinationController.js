const { getDb } = require('../db');

function listExaminations(req, res) {
  const { page = 1, page_size = 10, keyword = '', status = '', exam_type = '' } = req.query;
  const offset = (parseInt(page) - 1) * parseInt(page_size);
  const db = getDb();

  const search = `%${keyword}%`;
  let whereClause = 'WHERE (p.name LIKE ? OR e.exam_no LIKE ?)';
  const params = [search, search];

  if (status) {
    whereClause += ' AND e.status = ?';
    params.push(status);
  }
  if (exam_type) {
    whereClause += ' AND e.exam_type = ?';
    params.push(exam_type);
  }

  const countSql = `
    SELECT COUNT(*) as count FROM examinations e
    LEFT JOIN patients p ON e.patient_id = p.id
    ${whereClause}
  `;
  const total = db.prepare(countSql).get(...params).count;

  const rowsSql = `
    SELECT e.*, p.name as patient_name, p.patient_no, p.gender,
      u.real_name as doctor_name,
      (SELECT COUNT(*) FROM images WHERE examination_id = e.id) as image_count
    FROM examinations e
    LEFT JOIN patients p ON e.patient_id = p.id
    LEFT JOIN users u ON e.doctor_id = u.id
    ${whereClause}
    ORDER BY e.exam_date DESC, e.id DESC
    LIMIT ? OFFSET ?
  `;
  const rows = db.prepare(rowsSql).all(...params, parseInt(page_size), offset);

  res.json({ code: 200, data: { total, rows, page: parseInt(page), page_size: parseInt(page_size) } });
}

function getExamination(req, res) {
  const db = getDb();
  const exam = db.prepare(`
    SELECT e.*, p.name as patient_name, p.patient_no, p.gender, p.birth_date,
      u.real_name as doctor_name
    FROM examinations e
    LEFT JOIN patients p ON e.patient_id = p.id
    LEFT JOIN users u ON e.doctor_id = u.id
    WHERE e.id = ?
  `).get(req.params.id);

  if (!exam) {
    return res.status(404).json({ code: 404, message: '检查记录不存在' });
  }

  const images = db.prepare(`
    SELECT i.*, u.real_name as uploader_name
    FROM images i
    LEFT JOIN users u ON i.uploaded_by = u.id
    WHERE i.examination_id = ?
    ORDER BY i.upload_date
  `).all(req.params.id);

  res.json({ code: 200, data: { ...exam, images } });
}

function createExamination(req, res) {
  const { patient_id, exam_type, exam_date, body_part, equipment, doctor_id, description } = req.body;
  if (!patient_id || !exam_type || !exam_date) {
    return res.status(400).json({ code: 400, message: '患者ID、检查类型和检查日期不能为空' });
  }

  const db = getDb();
  const count = db.prepare('SELECT COUNT(*) as count FROM examinations').get().count;
  const exam_no = `E${new Date().getFullYear()}${String(count + 1).padStart(5, '0')}`;

  const result = db.prepare(`
    INSERT INTO examinations (exam_no, patient_id, exam_type, exam_date, body_part, equipment, doctor_id, description, status)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending')
  `).run(exam_no, patient_id, exam_type, exam_date, body_part, equipment, doctor_id || req.user.id, description);

  res.json({ code: 200, message: '创建成功', data: { id: result.lastInsertRowid, exam_no } });
}

function updateExamination(req, res) {
  const { exam_type, exam_date, body_part, equipment, doctor_id, status, description, diagnosis } = req.body;
  const db = getDb();
  const exam = db.prepare('SELECT id FROM examinations WHERE id = ?').get(req.params.id);
  if (!exam) {
    return res.status(404).json({ code: 404, message: '检查记录不存在' });
  }

  db.prepare(`
    UPDATE examinations SET exam_type=?, exam_date=?, body_part=?, equipment=?, doctor_id=?,
      status=?, description=?, diagnosis=?, updated_at=CURRENT_TIMESTAMP
    WHERE id=?
  `).run(exam_type, exam_date, body_part, equipment, doctor_id, status, description, diagnosis, req.params.id);

  res.json({ code: 200, message: '更新成功' });
}

function deleteExamination(req, res) {
  const db = getDb();
  const exam = db.prepare('SELECT id FROM examinations WHERE id = ?').get(req.params.id);
  if (!exam) {
    return res.status(404).json({ code: 404, message: '检查记录不存在' });
  }
  db.prepare('DELETE FROM images WHERE examination_id = ?').run(req.params.id);
  db.prepare('DELETE FROM examinations WHERE id = ?').run(req.params.id);
  res.json({ code: 200, message: '删除成功' });
}

module.exports = { listExaminations, getExamination, createExamination, updateExamination, deleteExamination };
