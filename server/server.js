const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const { OAuth2Client } = require('google-auth-library');
const cors = require('cors');

const app = express();
app.use(cors()); 
app.use(bodyParser.json());


mongoose.connect('mongodb://localhost:27017/flutter_app', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log(' MongoDB connected'))
.catch((err) => console.error(' MongoDB connection error:', err));


const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String },
  provider: { type: String, default: 'local' },
});

const User = mongoose.model('User', userSchema);


const JWT_SECRET = 'a316cf34f574fd65da64061c7f105704dd1b55f80052f6a8065677708ac2385f5e978b5d951935ca061564cf887ef1954cc5969e114df0da49be3dc5d14310c6f8549a'; 
const GOOGLE_CLIENT_ID = '.apps.googleusercontent.com';
const client = new OAuth2Client(GOOGLE_CLIENT_ID);

function generateToken(user) {
  return jwt.sign({ id: user._id, email: user.email }, JWT_SECRET, { expiresIn: '1h' });
}


app.get('/Users', async (req, res) => {
    try {
      const users = await User.find({}, { password: 0 }); 
      res.json(users);
    } catch (err) {
      res.status(500).json({ error: 'Internal server error' });
    }
  });
  

app.post('/signup', async (req, res) => {
  const { email, password } = req.body;

  try {
    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(400).json({ message: 'User already exists. Please log in.' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = new User({
      email,
      password: hashedPassword,
      provider: 'local',
    });

    await newUser.save();
    const token = generateToken(newUser);

    res.json({ token, message: 'Signup successful.' });
  } catch (err) {
    res.status(500).json({ message: 'Server error during signup.' });
  }
});


app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user || user.provider !== 'local') {
      return res.status(400).json({ message: 'Invalid email or password.' });
    }

    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(400).json({ message: 'Invalid email or password.' });
    }

    const token = generateToken(user);
    res.json({ token, message: 'Login successful.' });
  } catch (err) {
    res.status(500).json({ message: 'Server error during login.' });
  }
});


app.post('/google-signin', async (req, res) => {
  const { token } = req.body;

  try {
    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: GOOGLE_CLIENT_ID,
    });

    const { email } = ticket.getPayload();

    let user = await User.findOne({ email });

    if (!user) {
      user = new User({
        email,
        provider: 'google',
      });
      await user.save();
    }

    const jwtToken = generateToken(user);
    res.json({ token: jwtToken, message: 'Google sign-in successful.' });
  } catch (err) {
    res.status(400).json({ message: 'Google sign-in failed.' });
  }
});


const PORT = 5000;
app.listen(PORT, () => {
  console.log(` Server running on http://localhost:${PORT}`);
});
