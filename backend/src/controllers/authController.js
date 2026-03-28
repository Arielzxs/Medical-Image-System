const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getDb } = require('../db');

const JWT_SECRET = process.env.JWT_SECRET || 'medical_image_system_secret_key_2025';

function login(req, res) {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ code: 400, message: '用户名和密码不能为空' });
  }

  const db = getDb();
  const user = db.prepare('SELECT * FROM users WHERE username = ?').get(username);
  if (!user) {
    return res.status(401).json({ code: 401, message: '用户名或密码错误' });
  }

  const valid = bcrypt.compareSync(password, user.password);
  if (!valid) {
    return res.status(401).json({ code: 401, message: '用户名或密码错误' });
  }

  const token = jwt.sign(
    { id: user.id, username: user.username, role: user.role, real_name: user.real_name },
    JWT_SECRET,
    { expiresIn: '8h' }
  );

  res.json({
    code: 200,
    message: '登录成功',
    data: {
      token,
      user: {
        id: user.id,
        username: user.username,
        real_name: user.real_name,
        role: user.role,
        department: user.department
      }
    }
  });
}

function getProfile(req, res) {
  const db = getDb();
  const user = db.prepare('SELECT id, username, real_name, role, department, created_at FROM users WHERE id = ?').get(req.user.id);
  if (!user) {
    return res.status(404).json({ code: 404, message: '用户不存在' });
  }
  res.json({ code: 200, data: user });
}

function updateProfile(req, res) {
  const { real_name, department } = req.body;
  const db = getDb();
  db.prepare('UPDATE users SET real_name = ?, department = ? WHERE id = ?')
    .run(real_name, department, req.user.id);
  res.json({ code: 200, message: '更新成功' });
}

function changePassword(req, res) {
  const { old_password, new_password } = req.body;
  if (!old_password || !new_password) {
    return res.status(400).json({ code: 400, message: '请输入旧密码和新密码' });
  }

  const db = getDb();
  const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.user.id);
  if (!bcrypt.compareSync(old_password, user.password)) {
    return res.status(400).json({ code: 400, message: '旧密码错误' });
  }

  const hashed = bcrypt.hashSync(new_password, 10);
  db.prepare('UPDATE users SET password = ? WHERE id = ?').run(hashed, req.user.id);
  res.json({ code: 200, message: '密码修改成功' });
}

// Admin: list all users
function listUsers(req, res) {
  const db = getDb();
  const users = db.prepare('SELECT id, username, real_name, role, department, created_at FROM users ORDER BY id').all();
  res.json({ code: 200, data: users });
}

// Admin: create user
function createUser(req, res) {
  const { username, password, real_name, role, department } = req.body;
  if (!username || !password) {
    return res.status(400).json({ code: 400, message: '用户名和密码不能为空' });
  }
  const db = getDb();
  const existing = db.prepare('SELECT id FROM users WHERE username = ?').get(username);
  if (existing) {
    return res.status(400).json({ code: 400, message: '用户名已存在' });
  }
  const hashed = bcrypt.hashSync(password, 10);
  const result = db.prepare('INSERT INTO users (username, password, real_name, role, department) VALUES (?, ?, ?, ?, ?)')
    .run(username, hashed, real_name || '', role || 'doctor', department || '');
  res.json({ code: 200, message: '创建成功', data: { id: result.lastInsertRowid } });
}

// Admin: delete user
function deleteUser(req, res) {
  const { id } = req.params;
  if (parseInt(id) === req.user.id) {
    return res.status(400).json({ code: 400, message: '不能删除当前登录用户' });
  }
  const db = getDb();
  db.prepare('DELETE FROM users WHERE id = ?').run(id);
  res.json({ code: 200, message: '删除成功' });
}

module.exports = { login, getProfile, updateProfile, changePassword, listUsers, createUser, deleteUser };
