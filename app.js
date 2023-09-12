require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');
var passport = require('passport');
var LocalStrategy = require('passport-local');
var crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 8888;
let sql;

app.use(bodyParser.json());
app.use(express.static('static'));

// Create a MySQL connection
app.use(async (req, res, next) => {
  sql = await mysql.createConnection({
    host: process.env.db_host,
    user: process.env.db_user,
    password: process.env.db_password,
    database: process.env.db_database,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
  });
  next();
});

app.set('view engine', 'ejs');

passport.use(new LocalStrategy(async (username, password, cb) => {
  console.log(1)
  try {
    const results = await sql.execute('SELECT * FROM users WHERE username = ?', [ username ]);
    crypto.pbkdf2(password, row.salt, 310000, 32, 'sha256', function(err, hashedPassword) {
      if (err) { return cb(err); }
      if (!crypto.timingSafeEqual(row.hashed_password, hashedPassword)) {
        return cb(null, false, { message: 'Incorrect username or password.' });
      }
      return cb(null, row);
    });
  } catch(err) {
    return res.status(500).json({ error: `auth error: ${err}` });
  }
}));

passport.serializeUser(function(user, cb) {
  process.nextTick(function() {
    cb(null, { id: user.id, username: user.username });
  });
});

passport.deserializeUser(function(user, cb) {
  process.nextTick(function() {
    return cb(null, user);
  });
});


app.get('/login', function(req, res, next) {
  res.render('login');
});

app.post('/login/password', passport.authenticate('local', {
  successReturnToOrRedirect: '/',
  failureRedirect: '/login',
  failureMessage: true
}));

app.post('/logout', function(req, res, next) {
  req.logout(function(err) {
    if (err) { return next(err); }
    res.redirect('/');
  });
});


// POST /events - Create a new event
app.post('/api/events/', async (req, res) => {
  const events = req.body;
  console.log('/api/events/', events)
  await sql.execute('DELETE from events;');
  if (events.length === 0) { return res.status(201).json({ status: "OK (empty payload)" }) };

  const placeholders = events.map(() => '(?, ?, ?, ?, ?)').join(', ');
  const values = [].concat(...events.map(e => [e.id, e.start, e.duration, e.title, e.last_updated]));
  try {
    await sql.query(
      `INSERT INTO events (id, start, duration, title, last_updated) VALUES ${placeholders}`,
      values
    );
    return res.status(201).json({ status: "OK" });
  } catch (err) {
    console.log('err', err);
    return res.status(500).json({ error: `POST /api/events/ error: ${err}` });
  }
});

app.get('/api/events/', async (req, res) => {
  try {
    results = await sql.query('SELECT id, start, duration, title, last_updated FROM events');
    res.json(results[0]);
  } catch (err) {
    res.status(500).json({ error: `Database error: ${err}` });
  }
});


app.get('/api/lastsync/', async (req, res) => {
  try {
    results = await sql.query('SELECT last_sync FROM meta');
    res.json(results[0][0].last_sync);
  } catch (err) {
    res.status(500).json({ error: `Database error ${err}` });
  }
});

app.post('/api/lastsync/', async (req, res) => {
  await sql.execute('DELETE from meta;');
  const timestamp = parseInt(req.body.timestamp, 10);
  console.log('timestamp', timestamp);
  try {
    sql.execute('INSERT INTO meta (last_sync) VALUES (?)', [timestamp]);
    res.status(200).json({ message: 'success' });
  } catch (err) {
    res.status(500).json({ error: `POST /api/lastsync error: ${err}` });
  }
});


// ======== INDEX ===========

app.get('/', (req, res) => {
  res.sendFile('index.html',  { root: __dirname + '/static'});
});

// ======== START ===========

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
