package ;
import js.Node.console;

@:expose
class Game {
    var players:Map<String, Player>;
    var delayed_players:Array<String>;

    public var player_count(default, null):Int = 0;

    var submitted_turn_count:Int = 0;
    public function new() {
        players = new Map();
        delayed_players = [];
    }

    public function add_player(socket_id:String) {
        delayed_players.push(socket_id);
        console.log('INFO: Delaying player adding: $socket_id');    
    }

    public function remove_player(socket_id:String) {
        if(players.exists(socket_id)) {
            players.remove(socket_id);
            player_count--;    
        }
        console.log('INFO: Removed player $socket_id, new count: $player_count');
    }

    public function submit_turn(socket_id:String, dir:Int) {
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
        submitted_turn_count++;
        console.log('INFO: $socket_id submitted turn, new submitted count: $submitted_turn_count');
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

    public function next_turn() {
        submitted_turn_count = 0;
        while(delayed_players.length > 0) {
            var id = delayed_players.shift();
            players.set(id, new Player(0, 0));
            player_count++;
            console.log('INFO: Added player $id, new count: $player_count');
        }
    }

    public function turn_complete():Bool {
        console.log('Checking turn complete, submitted:$submitted_turn_count, players:$player_count');
        return submitted_turn_count == player_count;
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