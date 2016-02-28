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

var trigger_next_turn = function() {
    game.next_turn();
    pusher.trigger( 'presence-hacklondon16', 'game_state', game.get_state()); //At the end of a turn, existing players may have changed position/attacked, and new players may have joined
    pusher.trigger('presence-hacklondon16', 'next_turn', {});
}

app.post( '/client_message', function( req, res ) {
    switch(req.body.event_id) {
        case '0':
            var move_dir = req.body.move_dir;
            var socket_id = req.body.socket_id;
            game.submit_turn(socket_id, +move_dir);
            if(game.turn_complete()) {
                console.log('INFO: Sending turn info');
                trigger_next_turn();                
            }
            else {
                console.log('INFO: Still waiting for input from some players');
            }
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
        if(game.player_count == 0) {
            trigger_next_turn();
        }
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