
import luxe.Input;
import pusher.Pusher;
import pusher.channels.Channel;
import jQuery.JQueryStatic;
import phoenix.geometry.Geometry;

typedef Player = Geometry;

class Main extends luxe.Game {
    var pusher:Pusher;
    var channel:Channel;
    var socket_id:String = '';

    var players:Map<String, Player>;

    override function config(config:luxe.AppConfig) {

        return config;

    } //config

    override function ready() {
        players = new Map();

        pusher = new Pusher('6c115190175e44fca398');
        channel = pusher.subscribe('presence-hacklondon16');
        channel.bind('game_state', game_state);
        channel.bind('player_removed', player_removed);

        pusher.connection.bind('connected', function(_) {
            socket_id = pusher.connection.socket_id;
        });
    } //ready

    function game_state(data) {
        var data_array = cast(data.players, Array<Dynamic>);
        for(player_data in data_array) {
            if(!players.exists(player_data.id)) {
                players.set(player_data.id, create_player());
            }
            var player = players.get(player_data.id);
            player.transform.pos.x = Std.int(player_data.x) * 64;
            player.transform.pos.y = Std.int(player_data.y) * 64;
        }
    }

    function player_removed(data) {
        var player = players.get(data.id);
        player.drop();
        players.remove(data.id);
        trace('Player removed: ' + data.id);
    }

    function create_player():Player {
        return Luxe.draw.box({
            x:0,
            y:0,
            w:64,
            h:64
        });
    }

    override function onkeydown(e:KeyEvent) {
        var move_dir:Int = -1;
        switch(e.keycode) {
            case Key.left:
                move_dir = 0;
            case Key.up:
                move_dir = 1;
            case Key.right:
                move_dir = 2;
            case Key.down:
                move_dir = 3;
        }

        if(move_dir != -1) {
            send_ajax(MessageId.moved, {
                move_dir:move_dir
            });
        }
    }

    function send_ajax(id:MessageId, data:Dynamic) {
        data.socket_id = socket_id;
        data.event_id = id;
        JQueryStatic.ajax({
            url: '/client_message',
            type: 'post',
            data: data
        });
    }

    override function onkeyup( e:KeyEvent ) {
        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup
} //Main

@:enum
abstract MessageId(Int) from Int to Int {
    var joined = 0;
    var left = 1;
    var moved = 2;
}


typedef State = {
    players:Array<PlayerInfo>
}

typedef PlayerInfo = {
    id:String,
    x:Int,
    y:Int
}