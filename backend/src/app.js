const express = require('express');
const cors = require('cors');
const path = require('path');
const rateLimit = require('express-rate-limit');

// Load env
require('fs').existsSync(path.join(__dirname, '../.env')) && require('fs').readFileSync(path.join(__dirname, '../.env'), 'utf8').split('\n').forEach(line => {
  const [k, v] = line.split('=');
  if (k && v && !process.env[k]) process.env[k] = v.trim();
});

// Initialize database
require('./initDb');

const app = express();
const PORT = process.env.PORT || 3000;

// Rate limiting
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
  message: { code: 429, message: '请求过于频繁，请稍后再试' }
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { code: 429, message: '登录请求过于频繁，请稍后再试' }
});

const uploadLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { code: 429, message: '上传请求过于频繁，请稍后再试' }
});

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Static files (uploads)
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Routes
app.use('/api/auth', authLimiter, require('./routes/auth'));
app.use('/api/patients', generalLimiter, require('./routes/patients'));
app.use('/api/examinations', generalLimiter, require('./routes/examinations'));
app.use('/api/images', uploadLimiter, require('./routes/images'));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ code: 200, message: '医疗影像管理系统运行正常', timestamp: new Date().toISOString() });
});

// Serve frontend build
const distPath = path.join(__dirname, '../../frontend/dist');
if (require('fs').existsSync(distPath)) {
  app.use(express.static(distPath));
  app.get('*', generalLimiter, (req, res, next) => {
    if (req.path.startsWith('/api') || req.path.startsWith('/uploads')) return next();
    res.sendFile(path.join(distPath, 'index.html'));
  });
}

// Error handler
app.use((err, req, res, next) => {
  console.error(err.message);
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({ code: 400, message: '文件大小超过限制(50MB)' });
  }
  res.status(500).json({ code: 500, message: err.message || '服务器内部错误' });
});

app.listen(PORT, () => {
  console.log(`医疗影像管理系统后端服务启动，端口: ${PORT}`);
});

module.exports = app;
