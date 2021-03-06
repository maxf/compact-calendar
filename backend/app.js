var require;

(function() {
'use strict';

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
    console.log('Received: ', request.url);
    response.setHeader('Access-Control-Allow-Origin', '*');

    dispatcher.dispatch(request, response);
  } catch(err) {
    console.log('ERROR: ', err);
  }
}

//== Dispatcher

dispatcher.setStatic('resources');


dispatcher.onGet('/collections', (req, res) => {
  dataBase.listCollections({}).toArray((err, items) => {
    res.writeHead(200, {'Content-Type': 'application/json'});
    let body = JSON.stringify(items);
    res.end(body);
    console.log('sending 200: ', body);
  });
});

dispatcher.onGet('/'+COLLECTIONNAME+'/', (req, res) => {
  collection.find({}).toArray((err, docs) => {
    res.writeHead(200, {'Content-Type': 'application/json'});
    let body = JSON.stringify(docs[0]);
    res.end(body);
    console.log('sending 200: ', body);
  });
});

dispatcher.onPost('/'+COLLECTIONNAME+'/', (req, res) => {
  if (Object.keys(req.params).length) {
    console.log('POST params: ', req.params);
/*
    let documentArray = [];
    try {
      for (let param in req.params) {
        console.log('param: ', param, req.params[param]);
        documentArray.push(JSON.parse(req.params[param]));
      }
    } catch (e) {
      res.writeHead(400, {'Content-Type': 'application/json'});
      res.end(JSON.stringify({'error': 'invalid JSON'}));
      return;
    }
    console.log('documentArray: ', documentArray);
    collection.insertMany(documentArray, (err, result) => {
*/
    collection.insert(req.params, (err, result) => {
      res.writeHead(200, {'Content-Type': 'application/json'});
      res.end(JSON.stringify(result));
    });
  }
});

dispatcher.onPost('/'+COLLECTIONNAME+'/clear/', (req, res) => {
  collection.drop(() => {
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify({status: 'cleared'}));
  });
});



//== Main ==


MongoClient.connect(DBURL, (err, db) => {
  assert.equal(null, err);
  dataBase = db;
  collection = db.collection(COLLECTIONNAME);
  server.listen(PORT, () => {
    console.log('Server listening on: http://localhost:%s', PORT);
  });
});

}());
