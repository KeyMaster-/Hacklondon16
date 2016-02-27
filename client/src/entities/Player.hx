package entities;

import luxe.Vector;
import luxe.Visual;
import luxe.options.VisualOptions;
import luxe.Input;

class Player extends Visual{
	var hp = 100;
	var isPlayer:Bool;

	override function init() {
		super.init();
		if(isPlayer) {
			connect_input();
		}

		
		for(vertex in geometry.vertices) {
			trace(vertex);
			vertex.pos.x -= size.x/2;
			vertex.pos.y -= size.y/2;
		}


		trace("Im traaaacinng. They hatin.");
	}

	override function update(delta:Float) {

		if(Luxe.input.inputdown('up')) {

			transform.pos.x += delta* 64;

		} else if(Luxe.input.inputdown('down')) {
			transform.pos.x -= delta*64;
		
		} else if(Luxe.input.inputdown('right')) {
			rotation_z += delta*64;
		} else if(Luxe.input.inputdown('left')) {
			rotation_z -= delta*64;
		}

	}


	public function new(_options:VisualOptions, _isPlayer:Bool) {
		super(_options);
		isPlayer = _isPlayer;
	}

	//Tell the player that they have been hit.
	public function takeHit(hit:Int) {
		hp = hp-hit;
	}

	//Initialize accelaration or deceleration.
	public function accelerate(x:Int) {
		//rotation_x += x;
	}

	//Rotate based on arrows.
	public function rotate(x:Int) {
		rotation_z += x;
	}

	public function connect_input() {

		Luxe.input.bind_key('up', Key.up);
		Luxe.input.bind_key('up', Key.key_w);

		Luxe.input.bind_key('down', Key.down);
		Luxe.input.bind_key('down', Key.key_s);

		Luxe.input.bind_key('left', Key.left);
		Luxe.input.bind_key('left', Key.key_a);

		Luxe.input.bind_key('right', Key.right);
		Luxe.input.bind_key('right', Key.key_d);

		Luxe.input.bind_key('SHOOT', Key.space);

	}

}