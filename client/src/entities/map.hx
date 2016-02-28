
import luxe.Input;
import pusher.Pusher;
import pusher.channels.Channel;
import jQuery.JQueryStatic;
import phoenix.geometry.Geometry;
import entities.Player;
import luxe.Color;
import luxe.Vector;
import luxe.Entity;
import luxe.components.render.MeshComponent;
import luxe.Mesh;
import phoenix.Batcher;

class Main extends luxe.Game {
    var pusher:Pusher;
    var channel:Channel;
    var socketId:String = '';
    var map:Entity;
    var geom:Geometry;

    var mesh : Mesh;
    var ship : Mesh;

    //rotation of the camera
    var x: Float;
    var y: Float;
    var z: Float;

    //position of the camera
    var pos_x: Float;
    var pos_y: Float;
    var pos_z: Float;

    var map_x: Array<Float>;
    var map_z: Array<Float>;

    var screen_mouse : Vector;
    var view_mouse : Vector;
    var world_mouse : Vector;

    override function config(config:luxe.AppConfig) {

        config.preload.textures.push({ id:'assets/Armored panel red Large.jpg' });
        config.preload.texts.push({ id:'assets/Map50x100(Win)2.obj' });

        config.preload.textures.push({ id:'assets/Box002DiffuseMap.jpg' });
        config.preload.texts.push({ id:'assets/Scrab.obj' });

        config.render.depth = 200;
        return config;
    } //config

    override function ready() {
        //Luxe.renderer.clear_color.set(1,1,1,1);
        Luxe.camera.view.set_perspective({
            far:200,
            near:0.1,
            fov: 90,
            aspect : Luxe.screen.w/Luxe.screen.h
        });
        x = 0;
        y = 0;
        z = 0;

        pos_x = 0.0;
        pos_y = 30.0;
        pos_z = 0.0;

            //move up and back a bit
        Luxe.camera.pos.set_xyz(-242,51,-60);
        Luxe.camera.rotation.setFromEuler(new Vector(-0.63,0,0));
            //load a texture
        var tex = Luxe.resources.texture('assets/Armored panel red Large.jpg');
            //create the mesh
        mesh = new Mesh({ file:'assets/Map50x100(Win)2.obj', texture:tex});
        
        
        mesh.transform.pos.set_xy(1,0);

        var tex2 = Luxe.resources.texture('assets/Box002DiffuseMap.jpg');

        ship = new Mesh({ file:'assets/Scrab.obj', texture:tex2});

        ship.transform.pos.set_xyz(-241.5,21,-121);
        /*geom = Luxe.draw.box({
            x:Luxe.screen.mid.x,
            y:Luxe.screen.mid.y,
            w:64,
            h:64
        });
    
        var x = new Player({
            name: 'a sprite',
            pos: Luxe.screen.mid,
            color: new Color().rgb(0xf231acc),
            size: new Vector(128,128)
        }, true);
        */


        
        pusher = new Pusher('6c115190175e44fca398');
        channel = pusher.subscribe('hacklondon16');
        /*channel.bind('turn_result', function(data) {
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
        });*/

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
                Luxe.camera.pos.set_xyz(pos_x -= 1,pos_y,pos_z);
            case Key.up:
                Luxe.camera.pos.set_xyz(pos_x ,pos_y += 1,pos_z);
            case Key.right:
                Luxe.camera.pos.set_xyz(pos_x += 1,pos_y,pos_z);
            case Key.down:
                Luxe.camera.pos.set_xyz(pos_x,pos_y -= 1,pos_z);
            case Key.key_k:
                Luxe.camera.pos.set_xyz(pos_x,pos_y,pos_z += 1);
            case Key.key_m:
                Luxe.camera.pos.set_xyz(pos_x ,pos_y ,pos_z -= 1);
            case Key.key_d:
                Luxe.camera.rotation.setFromEuler(new Vector(x+=0.01,y,z));
            case Key.key_c:
                Luxe.camera.rotation.setFromEuler(new Vector(x-=0.01,y,z));
            case Key.key_w:
                Luxe.camera.rotation.setFromEuler(new Vector(x,y+=0.01,z));
            case Key.key_e:
                Luxe.camera.rotation.setFromEuler(new Vector(x,y-=0.01,z));
            case Key.key_a:
                Luxe.camera.rotation.setFromEuler(new Vector(x,y,z+=0.01));
            case Key.key_z:
                Luxe.camera.rotation.setFromEuler(new Vector(x,y,z-=0.01));
            case Key.key_q:
                countHex();
        }
        trace("x: " + pos_x + " y: " + pos_y + " z: " + pos_z);
        trace("tilt x: " + x + " tilt y: " + y + " tilt z: " + z);


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

    function getMapReady() {

        

    }

    public function connect_input() {

        Luxe.input.bind_key('up', Key.up);
        Luxe.input.bind_key('up_rotate', Key.key_w);

        Luxe.input.bind_key('down', Key.down);
        Luxe.input.bind_key('down_rotate', Key.key_s);

        Luxe.input.bind_key('left', Key.left);
        Luxe.input.bind_key('left_rotate', Key.key_a);

        Luxe.input.bind_key('right', Key.right);
        Luxe.input.bind_key('right_rotate', Key.key_d);

        Luxe.input.bind_key('SHOOT', Key.space);

    }

    function countHex() {
        map_x = [];
        map_z = [];

        var init_x = 241.5;
        var init_z = -121;
        for(i in 1... 63) {
            if(!(i%2 ==0)) {
                for(v in 0...36) {
                    map_x.push(init_x+13.45*(x+6.5));
                    map_z.push(init_z+3.88*(i+1));
                    
                }
            } else {
                for(v in 0...37) {
                    map_x.push(init_x+13.45*x);
                    map_z.push(init_z+3.88*(i));
                    ship.pos.set_xyz(init_x+13.45*x,21,init_z+3.88*i);
                    trace(i);
                    trace(v);
                }
            }
        }
    }

    override function onmousemove( e:MouseEvent ) {

        screen_mouse = e.pos;
        world_mouse = Luxe.camera.screen_point_to_world( e.pos );
        view_mouse = Luxe.camera.world_point_to_screen( world_mouse );

        trace(screen_mouse);
        trace(world_mouse);
        trace(view_mouse);
    }


} //Main

@:enum
abstract MessageId(Int) from Int to Int {
    var joined = 0;
    var left = 1;
    var moved = 2;
}


