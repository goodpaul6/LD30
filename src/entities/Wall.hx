package entities;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

/**
 * ...
 * @author Epitome Games
 */
class Wall extends Entity
{	
	public function new(x : Float, y : Float, w : Int, h : Int) 
	{
		super(x, y);
		setHitbox(w, h);
		type = "wall";
	}	
}