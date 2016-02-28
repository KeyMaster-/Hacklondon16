
import luxe.Input;
import pusher.Pusher;
import pusher.channels.Channel;
import jQuery.JQueryStatic;
import phoenix.geometry.Geometry;
import luxe.Entity;
import luxe.Mesh;
import luxe.Vector;

typedef Player = Geometry;

class Main extends luxe.Game {
    var pusher:Pusher;
    var channel:Channel;
    var socket_id:String = '';

    var players:Map<String, Player>;

    var waiting_for_turn:Bool = true;
        ////
    var map:Entity;
    var geom:Geometry;

    var mesh : Mesh;
    var ship : Mesh;

    var map_x: Array<Float>;
    var map_z: Array<Float>;

    var screen_mouse : Vector;
    var view_mouse : Vector;
    var world_mouse : Vector;

    override function config(config:luxe.AppConfig) {
        config.preload.textures.push({ id:'assets/Box002DiffuseMap.jpg' });
        config.preload.texts.push({ id:'assets/Scrab.obj' });

        return config;

    } //config

    override function ready() {
        Luxe.camera.view.set_perspective({
            far:1000,
            near:0.1,
            fov: 90,
            aspect : Luxe.screen.w/Luxe.screen.h
        });

        connect_input();

        for(x in 0...100) {
            for(y in 0...50) {
                var geom = Luxe.draw.ngon({
                    r:1,
                    sides:6,
                    solid:true,
                    x:(1 + Math.cos(Math.PI / 3)) * x + x * 0.1,
                    y:(y * 2 + (x % 2)) * Math.sin(Math.PI / 3) + y * 0.1, //A bit of offset
                    depth:10
                });
                geom.transform.rotation.setFromEuler(new Vector(Math.PI / 2, 0, 0));
                geom.locked = true;
            }
        }

            //move up and back a bit
        Luxe.camera.pos.set_xyz(0,100,0);

        Luxe.camera.rotation.setFromEuler(new Vector(-1.2,0,0));

        var tex2 = Luxe.resources.texture('assets/Box002DiffuseMap.jpg');

        ship = new Mesh({ file:'assets/Scrab.obj', texture:tex2});

        ship.transform.pos.set_xyz(-241.5,21,-121);

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
            player.transform.pos.x = Std.int(player_data.x) * 64;
            player.transform.pos.y = Std.int(player_data.y) * 64;
        }
    }

    function player_removed(data) {
        if(players.exists(data.id)) { 
            var player = players.get(data.id);
            player.drop();
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
            case Key.key_q:
                countHex();
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

    function countHex() {
        map_x = [];
        map_z = [];

        var init_x = -241.5;
        var init_z = -121;
        for(i in 1... 63) {
            if(!(i%2 ==0)) {
                for(v in 0...36) {
                    map_x.push(init_x+13.45*(i+6.5));
                    map_z.push(init_z+3.88*(i+1));
                    
                }
            } else {
                for(v in 0...37) {
                    map_x.push(init_x+13.45*i);
                    map_z.push(init_z+3.88*(i));
                    ship.pos.set_xyz(init_x+13.45*i,21,init_z+3.88*i);
                    trace(i);
                    trace(v);
                }
            }
        }
    }

    override function onmousedown(e:MouseEvent) {
        var mouse_ray = Luxe.camera.view.screen_point_to_ray(Luxe.screen.mid);
        var world_pos = Luxe.utils.geometry.intersect_ray_plane(mouse_ray.origin, mouse_ray.dir, new Vector(0, 1, 0), new Vector(0, 0, 0));
        trace(world_pos);
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