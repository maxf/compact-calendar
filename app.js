const express = require('express');
const app = express();
const PORT = process.env.PORT || 8888;

app.use(express.static('static'));

// ======== INDEX ===========

app.get('/', (req, res) => {
  res.sendFile('index.html',  { root: __dirname + '/static'});
});

// ======== START ===========

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
