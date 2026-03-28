const { getDb } = require('./db');
const bcrypt = require('bcryptjs');

function initDb() {
  const db = getDb();

  // Users table
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      real_name TEXT,
      role TEXT DEFAULT 'doctor',
      department TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Patients table
  db.exec(`
    CREATE TABLE IF NOT EXISTS patients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      patient_no TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL,
      gender TEXT,
      birth_date TEXT,
      id_card TEXT,
      phone TEXT,
      address TEXT,
      medical_history TEXT,
      created_by INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (created_by) REFERENCES users(id)
    )
  `);

  // Examinations table
  db.exec(`
    CREATE TABLE IF NOT EXISTS examinations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      exam_no TEXT UNIQUE NOT NULL,
      patient_id INTEGER NOT NULL,
      exam_type TEXT NOT NULL,
      exam_date TEXT NOT NULL,
      body_part TEXT,
      equipment TEXT,
      doctor_id INTEGER,
      status TEXT DEFAULT 'pending',
      description TEXT,
      diagnosis TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (patient_id) REFERENCES patients(id),
      FOREIGN KEY (doctor_id) REFERENCES users(id)
    )
  `);

  // Images table
  db.exec(`
    CREATE TABLE IF NOT EXISTS images (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      examination_id INTEGER NOT NULL,
      filename TEXT NOT NULL,
      original_name TEXT NOT NULL,
      file_path TEXT NOT NULL,
      file_size INTEGER,
      image_type TEXT,
      upload_date DATETIME DEFAULT CURRENT_TIMESTAMP,
      uploaded_by INTEGER,
      description TEXT,
      FOREIGN KEY (examination_id) REFERENCES examinations(id),
      FOREIGN KEY (uploaded_by) REFERENCES users(id)
    )
  `);

  // Insert default admin user if not exists
  const existingAdmin = db.prepare('SELECT id FROM users WHERE username = ?').get('admin');
  if (!existingAdmin) {
    const hashedPassword = bcrypt.hashSync('admin123', 10);
    db.prepare(`
      INSERT INTO users (username, password, real_name, role, department)
      VALUES (?, ?, ?, ?, ?)
    `).run('admin', hashedPassword, '系统管理员', 'admin', '信息科');

    // Insert sample doctor
    const doctorPassword = bcrypt.hashSync('doctor123', 10);
    db.prepare(`
      INSERT INTO users (username, password, real_name, role, department)
      VALUES (?, ?, ?, ?, ?)
    `).run('doctor1', doctorPassword, '张医生', 'doctor', '放射科');

    // Insert sample patients
    const insertPatient = db.prepare(`
      INSERT INTO patients (patient_no, name, gender, birth_date, id_card, phone, address, medical_history, created_by)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    insertPatient.run('P2025001', '李明', '男', '1985-03-15', '110101198503150012', '13812345678', '北京市海淀区', '高血压病史', 1);
    insertPatient.run('P2025002', '王芳', '女', '1990-07-22', '110101199007220023', '13987654321', '北京市朝阳区', '无特殊病史', 1);
    insertPatient.run('P2025003', '赵强', '男', '1975-11-08', '110101197511080034', '13711112222', '北京市西城区', '糖尿病史', 1);

    // Insert sample examinations
    const insertExam = db.prepare(`
      INSERT INTO examinations (exam_no, patient_id, exam_type, exam_date, body_part, equipment, doctor_id, status, description, diagnosis)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    insertExam.run('E2025001', 1, 'CT', '2025-03-10', '胸部', 'CT扫描仪-西门子', 2, 'completed', '胸部CT平扫', '双肺未见明显异常');
    insertExam.run('E2025002', 2, 'MRI', '2025-03-15', '头颅', 'MRI扫描仪-GE', 2, 'completed', '头颅MRI平扫+增强', '未见异常信号');
    insertExam.run('E2025003', 3, 'X-Ray', '2025-03-20', '腰椎', 'DR设备', 2, 'pending', '腰椎正侧位', null);
  }

  console.log('数据库初始化完成');
}

initDb();
