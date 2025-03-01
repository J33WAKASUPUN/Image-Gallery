const Image = require('../models/Image');

// Upload image
const uploadImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No image file provided' });
    }

    const image = new Image({
      userId: req.user._id,
      title: req.body.title || 'Untitled',
      description: req.body.description || '',
      image: {
        data: req.file.buffer,
        contentType: req.file.mimetype
      }
    });

    await image.save();
    console.log(`Image uploaded successfully. ID: ${image._id}`);

    res.status(201).json({
      _id: image._id,
      title: image.title,
      description: image.description,
      imageUrl: `data:${image.image.contentType};base64,${image.image.data.toString('base64')}`,
      createdAt: image.createdAt
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Get all images for a user
const getUserImages = async (req, res) => {
  try {
    const images = await Image.find({ userId: req.user._id })
      .sort({ createdAt: -1 });
    
    console.log(`Found ${images.length} images for user ${req.user._id}`);

    const formattedImages = images.map(image => ({
      _id: image._id,
      title: image.title,
      description: image.description,
      imageUrl: `data:${image.image.contentType};base64,${image.image.data.toString('base64')}`,
      createdAt: image.createdAt
    }));

    res.json(formattedImages);
  } catch (error) {
    console.error('Get images error:', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// Delete image
const deleteImage = async (req, res) => {
  try {
    console.log(`Attempting to delete image with ID: ${req.params.id}`);
    
    const image = await Image.findById(req.params.id);

    if (!image) {
      console.log(`Image not found with ID: ${req.params.id}`);
      return res.status(404).json({ message: 'Image not found' });
    }

    if (image.userId.toString() !== req.user._id.toString()) {
      console.log(`Unauthorized deletion attempt. User: ${req.user._id}, Image owner: ${image.userId}`);
      return res.status(403).json({ message: 'Not authorized' });
    }

    // Use findByIdAndDelete instead of remove
    const deletedImage = await Image.findByIdAndDelete(req.params.id);
    
    if (deletedImage) {
      console.log(`Image successfully deleted. ID: ${req.params.id}`);
      res.json({ message: 'Image deleted successfully' });
    } else {
      console.log(`Failed to delete image. ID: ${req.params.id}`);
      res.status(500).json({ message: 'Failed to delete image' });
    }
  } catch (error) {
    console.error('Delete error:', error);
    res.status(500).json({ 
      message: 'Server Error',
      error: error.message 
    });
  }
};

module.exports = {
  uploadImage,
  getUserImages,
  deleteImage
};