const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Generate JWT Token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '30d',
  });
};

// @desc    Register a new user
// @route   POST /api/users
// @access  Public
const registerUser = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Check if user exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Create user with profile picture
    const user = new User({
      name,
      email,
      password,
    });

    // If profile picture is uploaded
    if (req.file) {
      user.profilePicture = {
        data: req.file.buffer,
        contentType: req.file.mimetype
      };
    }

    await user.save();

    // Convert profile picture to base64 for response
    let profilePictureBase64 = '';
    if (user.profilePicture && user.profilePicture.data) {
      profilePictureBase64 = `data:${user.profilePicture.contentType};base64,${user.profilePicture.data.toString('base64')}`;
    }

    res.status(201).json({
      _id: user._id,
      name: user.name,
      email: user.email,
      profilePicture: profilePictureBase64,
      token: generateToken(user._id),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Auth user & get token
// @route   POST /api/users/login
// @access  Public
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const user = await User.findOne({ email });

    // Check if user exists and password matches
    if (user && (await user.matchPassword(password))) {
      // Convert profile picture to base64 for response
      let profilePictureBase64 = '';
      if (user.profilePicture && user.profilePicture.data) {
        profilePictureBase64 = `data:${user.profilePicture.contentType};base64,${user.profilePicture.data.toString('base64')}`;
      }
      
      res.json({
        _id: user._id,
        name: user.name,
        email: user.email,
        profilePicture: profilePictureBase64,
        token: generateToken(user._id),
      });
    } else {
      res.status(401).json({ message: 'Invalid email or password' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Get user profile
// @route   GET /api/users/profile
// @access  Private
const getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);

    if (user) {
      // Convert profile picture to base64 for response
      let profilePictureBase64 = '';
      if (user.profilePicture && user.profilePicture.data) {
        profilePictureBase64 = `data:${user.profilePicture.contentType};base64,${user.profilePicture.data.toString('base64')}`;
      }
      
      res.json({
        _id: user._id,
        name: user.name,
        email: user.email,
        profilePicture: profilePictureBase64,
      });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  registerUser,
  loginUser,
  getUserProfile,
};