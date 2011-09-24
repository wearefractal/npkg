var log = require('node-log')
log.setName('TestApp')
var fusker = require('fusker');

fusker.config.dir = __dirname;
fusker.config.banLength = 1;
fusker.config.verbose = true;
fusker.http.detect('csrf', 'xss', 'sqli', 'lfi', '404');
fusker.http.punish('blacklist', 'bush');
fusker.socket.detect('xss', 'sqli', 'lfi');
fusker.socket.punish('blacklist');

var server = fusker.http.createServer(8080);
var io = fusker.socket.listen(server);

io.sockets.on('connection', function(socket) {
  socket.emit('HelloClient', 'o hay thar client');
  
  socket.on('TestObject', function(msg) {
    return console.log('HelloServer1! Contents: ' + msg);
  });
  socket.on('TestObject', function(msg) {
    return console.log('HelloServer2! Contents: ' + msg);
  });
  socket.on('TestObject', function(msg) {
    return console.log('HelloServer3! Contents: ' + msg);
  });
  
  /* Uncomment the attack senders in index.html to test these */;
  socket.on('TestSQL', function(msg) {
    return console.log('SQL Handled! Contents: ' + msg);
  });
  
  socket.on('TestLFI', function(msg) {
    return console.log('LFI Handled! Contents: ' + msg);
  });
  
  socket.on('TestXSS', function(msg) {
    return console.log('XSS Handled! Contents: ' + msg);
  });
});
