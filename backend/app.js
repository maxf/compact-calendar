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
  res.end(JSON.stringify(items));
  });
});

dispatcher.onGet('/'+COLLECTIONNAME+'/', (req, res) => {
  collection.find({}).toArray((err, docs) => {
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify(docs));
  });
});

dispatcher.onPost('/'+COLLECTIONNAME+'/', (req, res) => {
  console.log(req.params);
  // each POST parameter will be uploaded as one document
  let documentArray = [];
  try {
    for (let postItem of req.params) {
        documentArray.push(JSON.parse(req.params[postItem]));
    }
  } catch (e) {
    res.writeHead(400, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({'error': 'invalid parameters'}));
    return;
  }
  collection.insertMany(documentArray, (err, result) => {
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify(result));
  });
});

dispatcher.onPost("/clear", (req, res) => {
  collection.drop((err, reply) => {
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end('cleared: '+reply);
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
