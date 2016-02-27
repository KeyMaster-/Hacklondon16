package pusher;
import pusher.channels.Channel;

@:native("Pusher")
extern class Pusher {
    public function new(app_key:String);
    public function subscribe(name:String):Channel;
    public var connection:Connection;
}