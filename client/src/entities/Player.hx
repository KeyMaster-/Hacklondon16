package entities;

import luxe.Vector;
import luxe.Entity;
import luxe.options.VisualOptions;
import luxe.Input;
import luxe.components.render.MeshComponent;

class Player extends Entity {
	var hex_x:Int;
	var hex_y:Int;

	var obj_id:String;
	var tex_id:String;

	public function new(_x:Int, _y:Int, _obj_id:String, _tex_id:String) {
		super({});

		obj_id = _obj_id;
		tex_id = _tex_id;

	}

	override function init() {
		super.init();
		add(new MeshComponent({
			file:obj_id,
			texture:Luxe.resources.texture(tex_id),
			depth:2
		}));
	}

	override function update(delta:Float) {

	}
}