const express = require('express');
const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const router = express.Router();
const { listImages, uploadImages, getImage, serveImage, deleteImage, getStats } = require('../controllers/imageController');
const { authMiddleware } = require('../middleware/auth');

const UPLOADS_DIR = path.join(__dirname, '../../uploads');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOADS_DIR);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${uuidv4()}${ext}`);
  }
});

const fileFilter = (req, file, cb) => {
  const allowed = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.dcm', '.tiff', '.tif', '.webp'];
  const ext = path.extname(file.originalname).toLowerCase();
  if (allowed.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error('不支持的文件格式，请上传图像文件'));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 50 * 1024 * 1024 } // 50MB
});

router.use(authMiddleware);

router.get('/stats', getStats);
router.get('/', listImages);
router.post('/upload', upload.array('files', 20), uploadImages);
router.get('/:id', getImage);
router.get('/:id/file', serveImage);
router.delete('/:id', deleteImage);

module.exports = router;
