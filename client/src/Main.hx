
import luxe.Input;
import pusher.Pusher;
import pusher.channels.Channel;
import jQuery.JQueryStatic;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import luxe.Entity;
import luxe.Mesh;
import luxe.Vector;
import entities.Player;
import phoenix.Batcher;
import luxe.Color;

class Main extends luxe.Game {
    var pusher:Pusher;
    var channel:Channel;
    var socket_id:String = '';

    var players:Map<String, Player>;

    var waiting_for_turn:Bool = true;

    var ship : Mesh;

    override function config(config:luxe.AppConfig) {
        config.preload.textures.push({ id:'assets/Scrab Diffuse Map.jpg' });
        config.preload.texts.push({ id:'assets/Scrab.obj' });
        config.render.depth = 16;
        return config;

    } //config

    override function ready() {
        Luxe.camera.view.set_perspective({
            far:1000,
            near:0.1,
            fov: 90,
            aspect : Luxe.screen.w/Luxe.screen.h
        });

        var vertex_color = new Color(1, 1, 1, 1);

        for(x in 0...100) {
            for(z in 0...50) {
                var geom = new Geometry({
                    batcher:Luxe.renderer.batcher,
                    primitive_type:PrimitiveType.triangle_strip
                });

                geom.vertices.push(new Vertex(new Vector(-0.45, 0, -0.45), vertex_color));
                geom.vertices.push(new Vertex(new Vector(-0.45, 0, 0.45), vertex_color));
                geom.vertices.push(new Vertex(new Vector(0.45, 0, -0.45), vertex_color));
                geom.vertices.push(new Vertex(new Vector(0.45, 0, 0.45), vertex_color));
                
                geom.transform.pos.x = x;
                geom.transform.pos.z = z;
                geom.locked = true;
            }
        }

        connect_input();

            //move up and back a bit
        Luxe.camera.pos.set_xyz(0,100,0);

        Luxe.camera.rotation.setFromEuler(new Vector(-1.2,0,0));

        players = new Map();

        pusher = new Pusher('6c115190175e44fca398');
        channel = pusher.subscribe('presence-hacklondon16');
        channel.bind('game_state', game_state);
        channel.bind('player_removed', player_removed);
        channel.bind('next_turn', next_turn);

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
            player.transform.pos.x = player_data.x;
            player.transform.pos.z = player_data.y;
        }
    }

    function player_removed(data) {
        if(players.exists(data.id)) { 
            var player = players.get(data.id);
            player.destroy();
            players.remove(data.id);
            trace('Player removed: ' + data.id);
        }
        else {
            trace('Player removed didn\'t exist in this game');
        }
        
    }

    function next_turn(_) {
        trace('new turn');
        waiting_for_turn = false;
    }

    function create_player():Player {
        var player = new entities.Player(0, 0, 'assets/Scrab.obj', 'assets/Scrab Diffuse Map.jpg');
        player.transform.pos.set_xyz(0, 1, 0);
        return player;
    }

    override function onkeydown(e:KeyEvent) {
        var move_dir:Int = -1;
        switch(e.keycode) {
            case Key.key_j:
                move_dir = 0;
            case Key.key_i:
                move_dir = 1;
            case Key.key_l:
                move_dir = 2;
            case Key.key_k:
                move_dir = 3;
        }

        if(move_dir != -1 && !waiting_for_turn) {
            trace('Sending move');
            send_ajax(MessageId.turn_submit, {
                move_dir:move_dir
            });
            waiting_for_turn = true;
        }
    }

    override public function update(dt:Float) {
        var move = 40 * dt * Luxe.camera.pos.y / 80;
        if(Luxe.input.inputdown('cam_left')) {
            Luxe.camera.pos.x -= 40 * dt;
        }
        else if(Luxe.input.inputdown('cam_right')) {
            Luxe.camera.pos.x += 40 * dt;
        }
        if(Luxe.input.inputdown('cam_up')) {
            Luxe.camera.pos.z -= 40 * dt;
        }
        else if(Luxe.input.inputdown('cam_down')) {
            Luxe.camera.pos.z += 40 * dt;
        }
    }

    override public function onmousewheel(event:MouseEvent) {
        Luxe.camera.pos.y += event.yrel * 0.3;
        trace(Luxe.camera.pos.y);
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

    public function connect_input() {

        Luxe.input.bind_key('cam_up', Key.up);

        Luxe.input.bind_key('cam_down', Key.down);

        Luxe.input.bind_key('cam_left', Key.left);

        Luxe.input.bind_key('cam_right', Key.right);

        Luxe.input.bind_key('SHOOT', Key.space);

    }

    override function onmousedown(e:MouseEvent) {
        var mouse_ray = Luxe.camera.view.screen_point_to_ray(e.pos);
        var world_pos = Luxe.utils.geometry.intersect_ray_plane(mouse_ray.origin, mouse_ray.dir, new Vector(0, 1, 0), new Vector(0, 0, 0));
        var tile_x = Math.floor(world_pos.x + 0.5);
        var tile_y = Math.floor(world_pos.z + 0.5);
    }

} //Main

@:enum
abstract MessageId(Int) from Int to Int {
    var turn_submit = 0;
}

typedef State = {
    players:Array<PlayerInfo>
}

typedef PlayerInfo = {
    id:String,
    x:Int,
    y:Int
}