package entities;
import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.HXP;

/**
 * ...
 * @author Epitome Games
 */
class Guard extends Entity
{	
	private static inline var _velX = 100;
	private static inline var _accelY = 30;
	private static inline var _seenVelX = 250;
	private static inline var _viewLength = 150;
	
	private var _seenPlayer : Bool;
	private var _dir : Int;
	
	private var _velY : Float;
	private var _grounded : Bool;
	
	private var _anim : Spritemap;
	
	private var _viewRect : Entity;
	private var _viewImage : Image;
	
	private var _exclaim : Entity;
	
	public function new(x : Float, y : Float, dir : Int) 
	{
		super(x, y, _anim = new Spritemap("graphics/guard_sheet.png", 32, 32));
		_anim.add("walk", [0, 1, 2, 3], 6);
		_anim.add("angry_run", [4, 5, 6, 7], 12);
		
		_velY = 0;
		_grounded = false;
		
		_viewRect = null;
		_dir = dir;
		_seenPlayer = false;
		setHitbox(16, 32, -8);
	
		_exclaim = null;
		
		type = "guard";
	}
	
	public override function update()
	{
		super.update();
		
		if (_viewRect == null)
		{
			_viewRect = scene.addGraphic(_viewImage = new Image("graphics/guard_line_of_sight.png"));
			_viewImage.alpha = 0.1;
			return;
		}
		
		if (!_seenPlayer)
		{
			if (collide("wall", x + (_velX * HXP.elapsed) * _dir + 16 * _dir, y + 1) == null)
				_dir *= -1;
		}
		
		var p : Entity = scene.collideRect("player", (_dir == 1 ? right : left - _viewLength), y - height / 2, _viewLength, height * 2);
		
		if (p != null)
		{	
			_seenPlayer = true;
			_anim.play("angry_run");
			if (_exclaim == null)
			{	
				var img : Image;
				_exclaim = scene.addGraphic(img = new Image("graphics/guard_seen.png"));
				img.centerOrigin();
			}
		}
		else
		{
			if (_exclaim != null)
			{
				scene.remove(_exclaim);
				_exclaim = null;
			}
			_seenPlayer = false;
			_anim.play("walk");
		}
		
		if (_dir == 1)
		{
			_viewRect.x = right;
			_anim.flipped = false;
			_viewImage.flipped = false;
		}
		else
		{	
			_viewRect.x = left - _viewLength;
			_anim.flipped = true;
			_viewImage.flipped = true;
		}
		
		if (_seenPlayer)
			_viewImage.color = 0xFF0000;
		
		_viewRect.y = y;
		
		if (_exclaim != null)
		{
			_exclaim.x = centerX;
			_exclaim.y = top - 16;
		}
		
		if (!_grounded)
			_velY += _accelY * HXP.elapsed;
			
		if (collideTypes(["wall", "player"], x, y + 1) != null)
			_grounded = true;
		else
			_grounded = false;
		
		moveBy(_dir * (_seenPlayer ? _seenVelX : _velX) * HXP.elapsed, _velY, ["wall", "player"]);
	}
	
	public override function moveCollideX(e : Entity) : Bool
	{
		if(e.type != "player")
			_dir *= -1;
		else
		{
			if (e.name == "clone")
				scene.remove(e);
			else
			{
				// TODO: End Game
			}
		}
		return true;
	}
	
	public override function moveCollideY(e : Entity) : Bool
	{
		_velY = 0;
		if (Math.abs(e.top - bottom) < 5)
			_grounded = true;
		return true;
	}
}