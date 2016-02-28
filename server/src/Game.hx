package ;
import js.Node.console;

@:expose
class Game {
    var players:Map<String, Player>;

    public function new() {
        players = new Map();
    }

    public function add_player(socket_id:String) {
        players.set(socket_id, new Player(0, 0));
        console.log('INFO: Added player $socket_id');
    }

    public function remove_player(socket_id:String) {
        players.remove(socket_id);
        console.log('INFO: Removed player $socket_id');
    }

    public function move_player(socket_id:String, dir:Int) {
        var player = players.get(socket_id);
        switch(dir) {
            case 0:
                player.x--;
            case 1:
                player.y--;
            case 2:
                player.x++;
            case 3:
                player.y++;
        }
    }

    public function get_state():State {
        var info = {
            players:[]
        }
        for(key in players.keys()) {
            var player = players.get(key);
            info.players.push({
                id:key,
                x:player.x,
                y:player.y
            });
        }
        return info;
    }
}

typedef State = {
    players:Array<PlayerInfo>
}

typedef PlayerInfo = {
    id:String,
    x:Int,
    y:Int
}