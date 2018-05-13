'use strict'

// Constants
const express = require('express');
const logger = require('winston');
const callbackToPromise = require('promise-callback');
const fs = require('fs');
const os = require('os');
const util = require('util');

const HOSTNAME = os.hostname();
const PORT = process.env.PORT || 8080;
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';
const READINESS_TIMEOUT = process.env.READINESS_TIMEOUT || 1000;

// App
const app = express();
var largeMemoryChunk;
var hasFailure=false;
var packageVersion;
var startupConfig;
var startupSecret;

function formatBytes(bytes,decimals) {
  if(bytes == 0) return '0 Bytes';
  var k = 1024,
      dm = decimals || 2,
      sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
      i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
}

app.get('/', function (req, res) {
  if (packageVersion == '1.0.1' || hasFailure) {
    res.sendStatus(500);
  } else {
    var envConfig = process.env.ENV_CONFIG;
    var envSecret = process.env.ENV_SECRET;

    var runtimeConfig;
    try {
      var fileContents = fs.readFileSync('/tmp/configmap/configmap.json');
      runtimeConfig = fileContents;
    } catch (err) {
      // Here you get the error when the file was not found,
      // but you also get any other error
    }

    var runtimeSecret;
    try {
      var fileContents = fs.readFileSync('/tmp/secret/secret.json');
      runtimeSecret = fileContents;
    } catch (err) {
      // Here you get the error when the file was not found,
      // but you also get any other error
    }

    var containerMemoryUsage;
    try {
      var fileContents = fs.readFileSync('/sys/fs/cgroup/memory/memory.usage_in_bytes');
      containerMemoryUsage = fileContents;
    } catch (err) {
      // Here you get the error when the file was not found,
      // but you also get any other error
    }

    var containerMemoryLimit;
    try {
      var fileContents = fs.readFileSync('/sys/fs/cgroup/memory/memory.limit_in_bytes');
      containerMemoryLimit = fileContents;
    } catch (err) {
      // Here you get the error when the file was not found,
      // but you also get any other error
    }

    var hostTotalMem = os.totalmem();
    var hostFreeMem = os.freemem();
    var memoryUsage = process.memoryUsage()

    res.write(`hostname = ${HOSTNAME}\n`);
    res.write(`packageVersion = ${packageVersion}\n`);
    res.write(`*************Configuration******\n`);
    res.write(`envConfig = ${envConfig}\n`);
    res.write(`envSecret = ${envSecret}\n`);
    res.write(`startupConfig = ${startupConfig}\n`);
    res.write(`startupSecret = ${startupSecret}\n`);
    res.write(`runtimeConfig = ${runtimeConfig}\n`);
    res.write(`runtimeSecret = ${runtimeSecret}\n`);
    res.write(`**************Memory************\n`);
    res.write(`Host totalMem = ${formatBytes(hostTotalMem)}\n`);
    res.write(`Host freeMem = ${formatBytes(hostFreeMem)}\n`);
    res.write(`Container usage = ${formatBytes(containerMemoryUsage)}\n`);
    res.write(`Container limit = ${formatBytes(containerMemoryLimit)}\n`);
    res.write(`rss = ${formatBytes(memoryUsage.rss)}\n`);
    res.write(`heapTotal = ${formatBytes(memoryUsage.heapTotal)}\n`);
    res.write(`heapUsed = ${formatBytes(memoryUsage.heapUsed)}\n`);
    
    res.end(`\n`);
  }
});

app.get('/kill', function (req, res) {
  if (packageVersion == '1.0.1' || hasFailure) {
    res.sendStatus(500);
  } else {
    hasFailure=true;
    res.send('Killing server\n');
    logger.info('Killing server');
  }
});

app.get('/small-leak', function (req, res) {
  if (packageVersion == '1.0.1' || hasFailure) {
    res.sendStatus(500);
  } else {
    largeMemoryChunk=(new Array(67108864)).join('*');
    res.send('Leaking memory\n');
    logger.info('Leaking memory');
  }
});

app.get('/big-leak', function (req, res) {
  if (packageVersion == '1.0.1' || hasFailure) {
    res.sendStatus(500);
  } else {
    largeMemoryChunk=(new Array(100663296)).join('*');
    res.send('Leaking memory\n');
    logger.info('Leaking memory');
  }
});

// health check
app.get('/healthz', (req, res, next) => {
  if (packageVersion == '1.0.1' || hasFailure) {
    res.sendStatus(500);
  } else {
    res.sendStatus(200);
  }
})

//Startup
app.listen(PORT, () => {
  try {
     var fileContents = fs.readFileSync('./package.json');
     packageVersion = JSON.parse(fileContents).version;
  } catch (err) {
    // Here you get the error when the file was not found,
    // but you also get any other error
  }  

  try {
    var fileContents = fs.readFileSync('/tmp/configmap/configmap.json');
    startupConfig = fileContents;
  } catch (err) {
    // Here you get the error when the file was not found,
    // but you also get any other error
  }

  try {
    var fileContents = fs.readFileSync('/tmp/secret/secret.json');
    startupSecret = fileContents;
  } catch (err) {
    // Here you get the error when the file was not found,
    // but you also get any other error
  }

  setTimeout(function() {
    fs.writeFile('/tmp/ready', 'alive!', 'utf8', function (err) {
      logger.info(`App is ready after delay of ${READINESS_TIMEOUT}ms!`);
    });
  }, READINESS_TIMEOUT);

  logger.info(`Example app listening on port ${PORT}!`);
})

// graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received');

  // close server first
  callbackToPromise(app.close)
    // exit process
    .then(() => {
      logger.info('Succesfull graceful shutdown');
      process.exit(0);
    })
    .catch((err) => {
      logger.error('Server close');
      process.exit(-1);
    })
})
