var express = require('express');
var http = require('http');
var Pusher = require('pusher');
var bodyParser = require('body-parser');



var app = express();
app.use( bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
})); 

var pusher = new Pusher( { appId: '183536', key: '6c115190175e44fca398', secret: '4a71aaff95cc029df07f' } );

app.use('/', express.static(__dirname + '/public'));

app.post( '/client_message', function( req, res ) {
    switch(req.body.event_id) {
        case '0':
            console.log('player joined!');
            break;
        case '1':
            console.log('player disconnected!');
            break;
        case '2':
            var move_dir = req.body.move_dir;
            var socket_id = req.body.socket_id;
            pusher.trigger( 'hacklondon16', 'turn_result', { move_dir:move_dir });//, socketId );
    }
    res.end();
});

app.post('/presence', function( req, res) {
    console.log(req.body);
    res.end();
});

var port = process.env.PORT || 80;

var server = http.createServer(app);
server.listen(port, function() {
    console.log('Express server listening on port ' + port);
});