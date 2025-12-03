const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Configure multer for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}-${uuidv4()}${ext}`);
  },
});

const upload = multer({ storage });

// In-memory database
let activities = [];

// ============ API ROUTES ============

// GET all activities
app.get('/api/activities', (req, res) => {
  const { search } = req.query;

  let result = [...activities];

  if (search) {
    const query = search.toLowerCase();
    result = result.filter(activity =>
      activity.location?.address?.toLowerCase().includes(query) ||
      activity.description?.toLowerCase().includes(query)
    );
  }

  // Sort by timestamp descending
  result.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

  res.json(result);
});

// GET single activity
app.get('/api/activities/:id', (req, res) => {
  const activity = activities.find(a => a.id === req.params.id);

  if (!activity) {
    return res.status(404).json({ error: 'Activity not found' });
  }

  res.json(activity);
});

// POST create activity
app.post('/api/activities', (req, res) => {
  const activity = {
    ...req.body,
    id: req.body.id || uuidv4(),
    isSynced: true,
    createdAt: new Date().toISOString(),
  };

  activities.push(activity);

  console.log(`Activity created: ${activity.id}`);
  res.status(201).json(activity);
});

// PUT update activity
app.put('/api/activities/:id', (req, res) => {
  const index = activities.findIndex(a => a.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ error: 'Activity not found' });
  }

  activities[index] = {
    ...activities[index],
    ...req.body,
    updatedAt: new Date().toISOString(),
  };

  res.json(activities[index]);
});

// DELETE activity
app.delete('/api/activities/:id', (req, res) => {
  const index = activities.findIndex(a => a.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ error: 'Activity not found' });
  }

  activities.splice(index, 1);

  console.log(`Activity deleted: ${req.params.id}`);
  res.status(204).send();
});

// POST upload image
app.post('/api/upload', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  const url = `http://localhost:${PORT}/uploads/${req.file.filename}`;

  console.log(`Image uploaded: ${req.file.filename}`);
  res.json({ url });
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Create uploads directory
const fs = require('fs');
if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

// Start server
app.listen(PORT, () => {
  console.log(`🚀 SmartTracker API running at http://localhost:${PORT}`);
  console.log(`📚 Endpoints:`);
  console.log(`   GET    /api/activities`);
  console.log(`   POST   /api/activities`);
  console.log(`   DELETE /api/activities/:id`);
  console.log(`   POST   /api/upload`);
});