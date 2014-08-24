package entities;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import openfl.geom.Point;

/**
 * ...
 * @author Epitome Games
 */
class Player extends Entity
{
	private static inline var _accelX = 120;
	private static inline var _accelY = 50;
	private static inline var _jumpImpulse = 16;
	private static inline var _cloneTime = 16;
	
	private var _velX : Float;
	private var _velY : Float;
	
	private var _grounded : Bool;
	private var _anim : Spritemap;
	
	private var _clone : Bool;
	private var _cloneTimeLeft : Float;
	
	private var _cloneTimeLeftText : Text;
	
	private var _canClone : Bool;
	
	private var _hasKey : Bool;
	
	public function new(x : Float, y : Float, clone : Bool = false) 
	{
		super(x, y, (clone ? new Graphiclist([_anim = new Spritemap("graphics/player_sheet.png", 32, 32), _cloneTimeLeftText = new Text("15")]) : 
		_anim = new Spritemap("graphics/player_sheet.png", 32, 32)));
		
		if (clone)
		{
			_anim.alpha = 0.5;
			_cloneTimeLeft =  _cloneTime;
			_cloneTimeLeftText.x = _anim.width / 2;
			_cloneTimeLeftText.y = -10;
			_cloneTimeLeftText.centerOrigin();
			_cloneTimeLeftText.color = 0xFF0000;
		}
		else
			_cloneTimeLeftText = null;
		
		_canClone = false;
			
		_anim.add("idle", [0,1], 4, true);
		_anim.add("run", [2, 3, 4, 5], 6, true);
		_anim.add("air_up", [6]);
		_anim.add("air_down", [7]);
		
		_clone = clone;
		
		_velX = 0;
		_velY = 0;
		setHitbox(16, 32, -8);
		type = "player";
		name = clone ? "clone" : "normal";
		
		_hasKey = false;
		
		_grounded = false;
	}
	
	public function takeKey() : Bool
	{
		if (_hasKey)
		{
			_hasKey = false;
			return true;
		}
		return false;
	}
	
	public function giveKeyIfNone() : Bool
	{
		if (_clone)
			return false;
		
		if (_hasKey)
			return false;
		_hasKey = true;
		return true;
	}
	
	public override function update()
	{
		super.update();
		
		scene.camera.x += (x - scene.camera.x - HXP.halfWidth) * HXP.elapsed;
		scene.camera.y += (y - scene.camera.y - HXP.halfHeight) * HXP.elapsed;
		
		if (_clone)
		{
			if (_cloneTimeLeft >= 0)
				_cloneTimeLeft -= HXP.elapsed;
			
			if (_cloneTimeLeft <= 0)
				scene.remove(this);
			_cloneTimeLeftText.text = Std.string(Math.floor(_cloneTimeLeft));
		}
		if (Input.check(_clone ? Key.LEFT : Key.A))
		{
			_anim.flipped = true;
			_anim.play("run");
			_velX -= _accelX * HXP.elapsed;
		}
		else if (Input.check(_clone ? Key.RIGHT : Key.D))			
		{	
			_anim.flipped = false;
			_anim.play("run");
			_velX += _accelX * HXP.elapsed;
		}	
		else
		{
			if(_grounded)
				_anim.play("idle");
		}
		
		if (_canClone && Input.pressed(Key.I))
			scene.add(new Player(x - 16, y, true));
			
		if (!_clone)
		{
			var players : Array<Entity> = [];
			scene.getType("player", players);
			var cloneExists : Bool = false;
			var clone : Entity = null;
			
			for (player in players)
			{
				if (player.name == "clone")
				{	
					cloneExists = true;
					clone = player;
				}
			}
			
			if (cloneExists)
			{	
				_canClone = false;
				if (Input.pressed(Key.O))
					scene.remove(clone);
			}
			else
				_canClone = true;
		}
		else
			_canClone = false;
		
		_velX *= 0.7;
			
		var collE : Entity = collideTypes(["wall", "player", "guard", "laser"], x, y + 5);
		if (collE != null)
		{
			if (collE.type == "laser")
			{
				if (Input.pressed((_clone ? Key.DOWN : Key.S)))
					cast(collE, Laser).disableForDuration(11);
			}
			_grounded = true;
		}
		else
			_grounded = false;
		
		if (_grounded && Input.pressed(_clone ? Key.UP : Key.W))
		{	
			_velY -= _jumpImpulse;
			_grounded = false;
		}
		
		if (!_grounded)
		{
			if (_velY < 0)
				_anim.play("air_up");
			else
				_anim.play("air_down");
				
			_velY += _accelY * HXP.elapsed;
		}
		moveBy(_velX, _velY, ["wall", "player", "guard", "laser", "key"]);
	}
	
	public override function moveCollideX(e : Entity) : Bool
	{
		if (_clone && e.type == "key")
			e.moveBy(_velX, 0, ["wall", "player", "guard", "laser"]);
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