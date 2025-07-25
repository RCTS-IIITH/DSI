import multer from 'multer';
import path from 'path';

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/'); // Save to uploads/ directory
  },
  filename: function (req, file, cb) {
    // Unique filename: timestamp-originalname
    cb(null, Date.now() + '-' + file.originalname);
  }
});

export const upload = multer({ storage });