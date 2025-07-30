const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Database connection
// const pool = new Pool({
//   user: process.env.DB_USER || 'vacation_user',
//   host: process.env.DB_HOST || 'db',
//   database: process.env.DB_NAME || 'vacation_db',
//   password: process.env.DB_PASSWORD || 'vacation_password',
//   port: process.env.DB_PORT || 5432,
// });
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'db',
  database: process.env.DB_NAME || 'dreamvacation',
  password: process.env.DB_PASSWORD || 'password',
  port: process.env.DB_PORT || 5432,
});

// Initialize database table
async function initDB() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS destinations (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('Database initialized');
  } catch (err) {
    console.error('Database initialization error:', err);
  }
}

// Routes
// app.get('/', (req, res) => {
//   res.json({ message: 'Dream Vacation API is running!' });
// });

// // GET /destinations - Fetch all destinations
// app.get('/destinations', async (req, res) => {
//   try {
//     const result = await pool.query('SELECT * FROM destinations ORDER BY created_at DESC');
//     res.json(result.rows);
//   } catch (err) {
//     console.error('Error fetching destinations:', err);
//     res.status(500).json({ error: 'Internal server error' });
//   }
// });

// // POST /destinations - Add a new destination
// app.post('/destinations', async (req, res) => {
//   try {
//     const { name } = req.body;
    
//     if (!name) {
//       return res.status(400).json({ error: 'Destination name is required' });
//     }

//     const result = await pool.query(
//       'INSERT INTO destinations (name) VALUES ($1) RETURNING *',
//       [name]
//     );
    
//     res.status(201).json(result.rows[0]);
//   } catch (err) {
//     console.error('Error adding destination:', err);
//     res.status(500).json({ error: 'Internal server error' });
//   }
// });
// Test route
app.get('/', (req, res) => {
  res.json({ message: 'Dream Vacation API is running!' });
});

// GET /api/destinations - Fetch all destinations
app.get('/api/destinations', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM destinations ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching destinations:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/destinations - Add a new destination
app.post('/api/destinations', async (req, res) => {
  const { country } = req.body;
  
  if (!country) {
    return res.status(400).json({ error: 'Country is required' });
  }

  try {
    // For now, let's add a simple destination without external API
    const result = await pool.query(
      'INSERT INTO destinations (country, capital, population, region) VALUES ($1, $2, $3, $4) RETURNING *',
      [country, 'Unknown', 0, 'Unknown']
    );
    
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error adding destination:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /api/destinations/:id - Delete a destination
app.delete('/api/destinations/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM destinations WHERE id = $1', [id]);
    res.status(204).send();
  } catch (err) {
    console.error('Error deleting destination:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Start server
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
  initDB();
});