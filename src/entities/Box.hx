package entities;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

/**
 * ...
 * @author Epitome Games
 */
class Box extends Entity
{	
	private static var _img : Image = new Image("graphics/box.png");
	
	private var _velY : Float;
	
	public function new(x : Float, y : Float) 
	{
		super(x, y, _img);
		setHitboxTo(_img);
		_velY = 0;
		type = "box";
	}
	
	public override function update() 
	{
		super.update();
		
		var e : Entity = collideTypes(["wall", "player", "guard", "laser"], x, y + 1);
		
		if (e != null)
		{
			_velY = 0;
			_grounded = true;
		}
		else
		{
			_velY += _accelY * HXP.elapsed;
			_grounded = false;
		}
		
		moveBy(0, _velY);
	}
}