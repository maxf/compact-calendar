/* jshint node: true */
"use strict";

const PORT = 8080;
const DBNAME = 'compact-calendar';
const COLLECTIONNAME = 'documents';
const DBURL = 'mongodb://localhost:27017/' + DBNAME;


const http = require('http');
const dispatcher = require('httpdispatcher');
const MongoClient = require('mongodb').MongoClient;
const assert = require('assert');
const server = http.createServer(handleRequest);

var dataBase;
var collection;

var getCalendarData = function(callback) {
  collection.find({}).toArray((err, docs) => {
    assert.equal(err, null);
    callback(docs);
  });
};

var clearCalendarData = function(callback) {
  collection.drop((err, reply) => {
    callback(reply);
  });
};

var postCalendarData = function(calendarData, callback) {
  console.log("CAL",calendarData);
  const calDataObj = JSON.parse(calendarData);
  collection.drop((err, reply) => {
    collection.insert(calDataObj, (err, result) => {
      callback(result);
    });
  });
};

function handleRequest(request, response){
  try {
    console.log(request.url);
    response.setHeader('Access-Control-Allow-Origin', '*');

    dispatcher.dispatch(request, response);
  } catch(err) {
    console.log("ERROR: ", err);
  }
}

//== Dispatcher

dispatcher.setStatic('resources');


dispatcher.onGet("/collections", (req, res) => {
  var collections = dataBase.listCollections({}).toArray(function(err, items) {
    res.writeHead(200, {'Content-Type': 'application/json'});
    console.log(items);
    res.end(JSON.stringify(items));
  });
});

dispatcher.onGet('/'+COLLECTIONNAME+'/', (req, res) => {
  getCalendarData((docs) => {
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify(docs));
  });
});

dispatcher.onPost("/clear", (req, res) => {
  clearCalendarData((reply) => {
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end('cleared: '+reply);
  });
});

dispatcher.onPost('/'+COLLECTIONNAME+'/', (req, res) => {
  console.log(req.params);
  // each POST parameter will be uploaded as one document
  let documentArray = [];
  for (let postItem in req.params) { documentArray.push(JSON.parse(req.params[postItem])); }
  console.log(documentArray);
  collection.insertMany(documentArray, (err, result) => {
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify(result));
  });
});


//== Main ==


MongoClient.connect(DBURL, (err, db) => {
  assert.equal(null, err);
  dataBase = db;
  collection = db.collection(COLLECTIONNAME);
  server.listen(PORT, () => {
    console.log("Server listening on: http://localhost:%s", PORT);
  });
});
