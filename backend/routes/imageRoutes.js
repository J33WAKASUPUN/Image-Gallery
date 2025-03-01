const express = require('express');
const router = express.Router();
const multer = require('multer');
const { protect } = require('../middleware/auth');
const { uploadImage, getUserImages, deleteImage } = require('../controllers/imageController');

const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

router.post('/', protect, upload.single('image'), uploadImage);
router.get('/', protect, getUserImages);
router.delete('/:id', protect, deleteImage);

module.exports = router;