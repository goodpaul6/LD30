package entities;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Image;
import com.haxepunk.Mask;

/**
 * ...
 * @author Epitome Games
 */
class Door extends Entity
{
	public function new(x : Float, y : Float) 
	{
		super(x, y, new Image("graphics/door.png"));
		setHitbox(32, 64);
		type = "door";
	}
}