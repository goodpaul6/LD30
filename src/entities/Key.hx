package entities;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;

/**
 * ...
 * @author Epitome Games
 */
class Key extends Entity
{	
	private static inline var _accelY = 30;
	
	private var _grounded : Bool;
	private var _velY : Float;
	
	public function new(x : Float, y : Float) 
	{
		super(x, y, new Image("graphics/key.png"));
		setHitbox(20, 10);
		_velY = 0;
		_grounded = false;
		type = "key";
	}	
	
	
	public override function update() 
	{
		super.update();
		
		var e : Entity = collideTypes(["wall", "player", "guard", "laser"], x, y + 1);
		
		if (e != null)
		{
			_velY = 0;
			_grounded = true;
			
			if (e.type == "player")
			{
				if (e.name == "normal")
				{
					if (cast(e, Player).giveKeyIfNone())
						scene.remove(this);
				}
			}
		}
		else
		{
			_velY += _accelY * HXP.elapsed;
			_grounded = false;
		}
		
		moveBy(0, _velY);
	}
}