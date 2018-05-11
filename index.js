'use strict'

// Constants
const express = require('express');
const logger = require('winston');
const callbackToPromise = require('promise-callback');
const fs = require('fs');
const os = require('os');

const HOSTNAME = os.hostname();
const PORT = process.env.PORT || 8080;
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';

// App
const app = express();

var hasFailure=false;
var packageVersion;
var startupConfig;
var startupSecret;

app.get('/', function (req, res) {
  if (packageVersion == '1.0.1' || hasFailure) {
    res.sendStatus(500);
  } else {
    var envConfig = process.env.ENV_CONFIG;
    var envSecret = process.env.ENV_SECRET;

    var runtimeConfig;
    try {
      var fileContents = fs.readFileSync('./config/config.json');
      runtimeConfig = JSON.parse(fileContents).configValue;
    } catch (err) {
      // Here you get the error when the file was not found,
      // but you also get any other error
    }

    var runtimeSecret;
    try {
      var fileContents = fs.readFileSync('./secret/secret.json');
      runtimeSecret = JSON.parse(fileContents).secretValue;
    } catch (err) {
      // Here you get the error when the file was not found,
      // but you also get any other error
    }

    res.write(`hostname = ${HOSTNAME}\n`);
    res.write(`packageVersion = ${packageVersion}\n`);
    res.write(`envConfig = ${envConfig}\n`);
    res.write(`envSecret = ${envSecret}\n`);
    res.write(`startupConfig = ${startupConfig}\n`);
    res.write(`startupSecret = ${startupSecret}\n`);
    res.write(`runtimeConfig = ${runtimeConfig}\n`);
    res.write(`runtimeSecret = ${runtimeSecret}\n`);
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
    var fileContents = fs.readFileSync('./config/config.json');
    startupConfig = JSON.parse(fileContents).configValue;
  } catch (err) {
    // Here you get the error when the file was not found,
    // but you also get any other error
  }

  try {
    var fileContents = fs.readFileSync('./secret/secret.json');
    startupSecret = JSON.parse(fileContents).secretValue;
  } catch (err) {
    // Here you get the error when the file was not found,
    // but you also get any other error
  }

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
