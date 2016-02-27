package pusher;

extern class Connection {
    public function bind(event_name:String, callback:Dynamic->Void):Void;
    public var socket_id:String;
}