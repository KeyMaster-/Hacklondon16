var game_module = require('./game');
var express = require('express');
var http = require('http');
var Pusher = require('pusher');
var bodyParser = require('body-parser');

var game = new game_module.Game();

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
            game.add_player(req.body.socket_id);
            break;
        case '2':
            var move_dir = req.body.move_dir;
            var socket_id = req.body.socket_id;
            game.move_player(socket_id, +move_dir);
            console.log('INFO: Sending turn info');
            pusher.trigger( 'presence-hacklondon16', 'game_state', game.get_state());
    }
    res.end();
});

app.post( '/pusher/auth', function( req, res ) {
    var socketId = req.body.socket_id;
    var channel = req.body.channel_name;
    var presenceData = {
        user_id: socketId
    };
    var auth = pusher.authenticate( socketId, channel, presenceData );
    res.send( auth );
});

app.post('/presence', function( req, res) {
    if(req.body.events[0].name == 'member_added') {
        console.log('presence member add event');
        game.add_player(req.body.events[0].user_id);
        pusher.trigger( 'presence-hacklondon16', 'game_state', game.get_state());
    }
    else if(req.body.events[0].name == 'member_removed') {
        game.remove_player(req.body.events[0].user_id);
        pusher.trigger('presence-hacklondon16', 'player_removed', {id:req.body.events[0].user_id});
    }

    res.end();
});

var port = process.env.PORT || 80;

var server = http.createServer(app);
server.listen(port, function() {

    console.log('Express server listening on port ' + port);
});