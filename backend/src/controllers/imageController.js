const path = require('path');
const fs = require('fs');
const { getDb } = require('../db');

function getImagePath(filename) {
  return path.join(__dirname, '../../uploads', filename);
}

function listImages(req, res) {
  const { examination_id, page = 1, page_size = 20 } = req.query;
  const db = getDb();
  const offset = (parseInt(page) - 1) * parseInt(page_size);

  let where = '';
  const params = [];
  if (examination_id) {
    where = 'WHERE i.examination_id = ?';
    params.push(examination_id);
  }

  const total = db.prepare(`SELECT COUNT(*) as count FROM images i ${where}`).get(...params).count;
  const rows = db.prepare(`
    SELECT i.*, e.exam_no, e.exam_type, p.name as patient_name,
      u.real_name as uploader_name
    FROM images i
    LEFT JOIN examinations e ON i.examination_id = e.id
    LEFT JOIN patients p ON e.patient_id = p.id
    LEFT JOIN users u ON i.uploaded_by = u.id
    ${where}
    ORDER BY i.upload_date DESC
    LIMIT ? OFFSET ?
  `).all(...params, parseInt(page_size), offset);

  res.json({ code: 200, data: { total, rows, page: parseInt(page), page_size: parseInt(page_size) } });
}

function uploadImages(req, res) {
  const { examination_id, description } = req.body;
  if (!examination_id) {
    return res.status(400).json({ code: 400, message: '检查ID不能为空' });
  }

  const db = getDb();
  const exam = db.prepare('SELECT id FROM examinations WHERE id = ?').get(examination_id);
  if (!exam) {
    return res.status(404).json({ code: 404, message: '检查记录不存在' });
  }

  if (!req.files || req.files.length === 0) {
    return res.status(400).json({ code: 400, message: '请选择要上传的图像文件' });
  }

  const insertImage = db.prepare(`
    INSERT INTO images (examination_id, filename, original_name, file_path, file_size, image_type, uploaded_by, description)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const inserted = [];
  for (const file of req.files) {
    const ext = path.extname(file.originalname).toLowerCase().replace('.', '');
    const result = insertImage.run(
      examination_id,
      file.filename,
      file.originalname,
      file.path,
      file.size,
      ext,
      req.user.id,
      description || ''
    );
    inserted.push({ id: result.lastInsertRowid, filename: file.filename, original_name: file.originalname });
  }

  // Update examination status to completed if uploading images
  db.prepare("UPDATE examinations SET status='completed', updated_at=CURRENT_TIMESTAMP WHERE id=?").run(examination_id);

  res.json({ code: 200, message: `成功上传 ${inserted.length} 张图像`, data: inserted });
}

function getImage(req, res) {
  const db = getDb();
  const image = db.prepare('SELECT * FROM images WHERE id = ?').get(req.params.id);
  if (!image) {
    return res.status(404).json({ code: 404, message: '图像不存在' });
  }
  res.json({ code: 200, data: image });
}

function serveImage(req, res) {
  const db = getDb();
  const image = db.prepare('SELECT * FROM images WHERE id = ?').get(req.params.id);
  if (!image) {
    return res.status(404).json({ code: 404, message: '图像不存在' });
  }

  const filePath = getImagePath(image.filename);
  if (!fs.existsSync(filePath)) {
    return res.status(404).json({ code: 404, message: '图像文件不存在' });
  }

  res.sendFile(filePath);
}

function deleteImage(req, res) {
  const db = getDb();
  const image = db.prepare('SELECT * FROM images WHERE id = ?').get(req.params.id);
  if (!image) {
    return res.status(404).json({ code: 404, message: '图像不存在' });
  }

  // Delete file from disk
  const filePath = getImagePath(image.filename);
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }

  db.prepare('DELETE FROM images WHERE id = ?').run(req.params.id);
  res.json({ code: 200, message: '删除成功' });
}

function getStats(req, res) {
  const db = getDb();
  const patientCount = db.prepare('SELECT COUNT(*) as count FROM patients').get().count;
  const examCount = db.prepare('SELECT COUNT(*) as count FROM examinations').get().count;
  const imageCount = db.prepare('SELECT COUNT(*) as count FROM images').get().count;
  const pendingCount = db.prepare("SELECT COUNT(*) as count FROM examinations WHERE status='pending'").get().count;
  const completedCount = db.prepare("SELECT COUNT(*) as count FROM examinations WHERE status='completed'").get().count;

  const recentExams = db.prepare(`
    SELECT e.id, e.exam_no, e.exam_type, e.exam_date, e.status,
      p.name as patient_name, p.patient_no
    FROM examinations e
    LEFT JOIN patients p ON e.patient_id = p.id
    ORDER BY e.created_at DESC
    LIMIT 5
  `).all();

  const examTypeStats = db.prepare(`
    SELECT exam_type, COUNT(*) as count FROM examinations GROUP BY exam_type
  `).all();

  res.json({
    code: 200,
    data: {
      patient_count: patientCount,
      exam_count: examCount,
      image_count: imageCount,
      pending_count: pendingCount,
      completed_count: completedCount,
      recent_exams: recentExams,
      exam_type_stats: examTypeStats
    }
  });
}

module.exports = { listImages, uploadImages, getImage, serveImage, deleteImage, getStats };
