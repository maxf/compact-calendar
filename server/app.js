require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');

const app = express();
const PORT = process.env.PORT || 8888;

app.use(bodyParser.json());

// Create a MySQL connection pool
const pool = mysql.createPool({
  host: process.env.host,
  user: process.env.user,
  password: process.env.password,
  database: process.env.database,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// POST /events - Create a new event
app.post('/events', (req, res) => {
    const event = req.body;
    pool.execute(
        'INSERT INTO events (start, duration, title) VALUES (?, ?, ?)',
        [event.start, event.duration, event.title],
        (err, results) => {
            if (err) {
                res.status(500).json({ error: 'Database error' });
            } else {
                event.id = results.insertId;
                res.status(201).json(event);
            }
        }
    );
});

// GET /events - Get all events
app.get('/events', (req, res) => {
    pool.query('SELECT * FROM events', (err, results) => {
        if (err) {
            res.status(500).json({ error: 'Database error' });
        } else {
            res.json(results);
        }
    });
});

// GET /events/:id - Get a specific event by its ID
app.get('/events/:id', (req, res) => {
    const eventId = req.params.id;
    pool.query('SELECT * FROM events WHERE id = ?', [eventId], (err, results) => {
        if (err) {
            res.status(500).json({ error: 'Database error' });
        } else if (results.length === 0) {
            res.status(404).json({ error: 'Event not found' });
        } else {
            res.json(results[0]);
        }
    });
});

// PUT /events/:id - Update a specific event by its ID
app.put('/events/:id', (req, res) => {
    const eventId = req.params.id;
    const updatedEvent = req.body;
    pool.execute(
        'UPDATE events SET start = ?, duration = ?, title = ? WHERE id = ?',
        [updatedEvent.start, updatedEvent.duration, updatedEvent.title, eventId],
        (err) => {
            if (err) {
                res.status(500).json({ error: 'Database error' });
            } else {
                res.json(updatedEvent);
            }
        }
    );
});

// DELETE /events/:id - Delete a specific event by its ID
app.delete('/events/:id', (req, res) => {
    const eventId = req.params.id;
    pool.execute('DELETE FROM events WHERE id = ?', [eventId], (err, results) => {
        if (err) {
            res.status(500).json({ error: 'Database error' });
        } else if (results.affectedRows === 0) {
            res.status(404).json({ error: 'Event not found' });
        } else {
            res.json({ message: 'Event deleted' });
        }
    });
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
