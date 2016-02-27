
import luxe.Input;
import pusher.Pusher;
import pusher.channels.Channel;
import jQuery.JQueryStatic;
import phoenix.geometry.Geometry;

class Main extends luxe.Game {
    var pusher:Pusher;
    var channel:Channel;
    var socketId:String = '';

    var geom:Geometry;

    override function config(config:luxe.AppConfig) {

        return config;

    } //config

    override function ready() {
        geom = Luxe.draw.box({
            x:Luxe.screen.mid.x,
            y:Luxe.screen.mid.y,
            w:64,
            h:64
        });

        pusher = new Pusher('6c115190175e44fca398');
        channel = pusher.subscribe('hacklondon16');
        channel.bind('turn_result', function(data) {
            switch(data.move_dir) {
                case '0':
                    geom.transform.pos.x -= 64;
                case '1':
                    geom.transform.pos.y -= 64;
                case '2':
                    geom.transform.pos.x += 64;
                case '3':
                    geom.transform.pos.y += 64;
            }
        });

        pusher.connection.bind('connected', function(_) {
            socketId = pusher.connection.socket_id;
            send_ajax(MessageId.joined, { });
        });
    } //ready

        //callback stub for a player joining, create new player object here
    function player_joined() {

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
        trace('sending $id');
        data.socket_id = socketId;
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

    override function update(dt:Float) {

    } //update


} //Main

@:enum
abstract MessageId(Int) from Int to Int {
    var joined = 0;
    var left = 1;
    var moved = 2;
}