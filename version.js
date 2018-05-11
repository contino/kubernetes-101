var fs = require('fs')
var filePath = './package.json'
var newVersion = process.argv[2]
var find = new RegExp('\\"version\\"\\s*:\\s*\\".*\\"', 'g')
var replacement = '"version": "' + newVersion + '"'

fs.readFile(filePath, 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }

  var result = data.replace(find, replacement);

  //var test = data.replace(new RegExp('\\"version\\"', 'g'), replacement);
  //console.log(test)

  fs.writeFile(filePath, result, 'utf8', function (err) {
     if (err) return console.log(err);
  });
});