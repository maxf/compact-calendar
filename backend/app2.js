/* jshint node: true */
"use strict";

const PORT=8080;


const http = require('http');
const dispatcher = require('httpdispatcher');
const MongoClient = require('mongodb').MongoClient;
const assert = require('assert');
const server = http.createServer(handleRequest);

const dbUrl = 'mongodb://localhost:27017/compact-calendar';
var dataBase;
var collection;

var getCalendarData = function(callback) {
  collection.find({}).toArray((err, docs) => {
    assert.equal(err, null);
    callback(docs);
  });
};


var clearCalendarData = function(callback) {
  collection.find({}).toArray((err, docs) => {
    assert.equal(err, null);
    console.dir(docs);
//    collection.remove(docs, (err, result) => {
//      console.log(err,result);
      callback();
//    });
  });
};


var postCalendarData = function(calendarData, callback) {
  console.log("CAL",calendarData);
  const calDataObj = JSON.parse(calendarData);
  collection.insert(calDataObj, function(err, result) {
    callback(result);
  });
};

function handleRequest(request, response){
  try {
    console.log(request.url);
    dispatcher.dispatch(request, response);
  } catch(err) {
    console.log("ERROR: ", err);
  }
}

dispatcher.setStatic('resources');

dispatcher.onGet("/get", (req, res) => {
  getCalendarData((docs) => {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end(JSON.stringify(docs));
  });
});

dispatcher.onGet("/clear", (req, res) => {
  clearCalendarData(() => {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('cleared');
  });
});

dispatcher.onPost("/post", (req, res) => {
  if (req.params.calendarData) {
    postCalendarData(req.params.calendarData, (docs) => {
      res.writeHead(200, {'Content-Type': 'text/plain'});
      res.end(JSON.stringify(docs));
    });
  } else {
    res.writeHead(400, {'Content-Type': 'text/plain'});
    res.end("missing parameter");
  }
});


//== Main ==


MongoClient.connect(dbUrl, (err, db) => {
  assert.equal(null, err);
  dataBase = db;
  collection = db.collection('documents');
  server.listen(PORT, () => {
    console.log("Server listening on: http://localhost:%s", PORT);
  });
});
