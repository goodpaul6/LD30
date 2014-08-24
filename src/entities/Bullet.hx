package entities;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.masks.Circle;

/**
 * ...
 * @author Epitome Games
 */
class Bullet extends Entity
{
	private static var _img : Image = Image.createCircle(_radius, 0x888888);
	
	private static inline var _radius = 5;
	private static inline var _velX = 600;
	
	private var _dir : Int;
	
	public function new(x : Float, y : Float, dir : Int) 
	{
		var img : Image;
		super(x, y, img = _img);
		img.centerOrigin();
		_dir = dir;
		mask = new Circle(_radius);
	}	
	
	public override function update()
	{
		super.update();
		moveBy(_dir * _velX * HXP.elapsed, 0, ["wall", "player"]);
	}
	
	public override function moveCollideX(e : Entity) : Bool
	{
		if (e.type == "player")
			Reg.health -= 1;
		
		scene.remove(this);
		return false;
	}
}