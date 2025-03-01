const mongoose = require('mongoose');

const imageSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ''
  },
  image: {
    data: Buffer,
    contentType: String
  },
}, {
  timestamps: true
});

const Image = mongoose.model('Image', imageSchema);

module.exports = Image;