package pusher.channels;

extern class Channel {
    public function bind(event_name:String, callback:Dynamic->Void):Void;
}