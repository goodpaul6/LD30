package entities;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;

/**
 * ...
 * @author Epitome Games
 */
class Laser extends Entity
{
	private static inline var _activeTime = 3;
	private static inline var _shootCooldown = 0.08;
	
	private var _length : Int;
	
	private var _dir : Int;
	private var _seenPlayer : Bool;
	private var _active : Bool;
	
	private var _timer : Float;
	
	private var _shootTimer : Float;
	private var _laserImg : Image;
	
	private var _disableDurEntity : Entity;
	private var _disableDurText : Text;
	
	private var _disabled : Bool;
	
	public function new(x : Float, y : Float, dir : Int, length : Int) 
	{
		var body : Image;
		_length = length;
		super(x, y, new Graphiclist([_laserImg = new Image("graphics/laser_line.png"), body = new Image("graphics/laser.png")]));
		body.y = -14;
		body.flipped = (dir == 1 ? false : true);
		body.x = (dir == 1 ? 0 : -32);
		_laserImg.scaledWidth = length;
		_laserImg.flipped = (dir == 1 ? false : true);
		_laserImg.x = (dir == 1 ? 0 : -_length);
		setHitbox(32, 16, (dir == 1 ? 0 : 32), 8);
		_dir = dir;
		_seenPlayer = false;
		_active = true;
		_timer = _activeTime;
		_shootTimer = 0;
		_disableDurText = null;
		_disableDurEntity = null;
		type = "laser";
	}
	
	public function disableForDuration(dur : Float)
	{
		if (!_disabled)
		{
			_active = false;
			_timer = dur;
		
			_disableDurEntity = scene.addGraphic(_disableDurText = new Text(Std.string(Math.floor(dur))));
			_disableDurText.centerOrigin();
			_disableDurText.x = (_dir == 1 ? x + width + 10 : x - width - 10);
			_disableDurText.y = y;
			_disableDurText.color = 0xFF0000;
			_disabled = true;
		}
	}
	
	public override function update()
	{
		super.update();
		
		if (!_seenPlayer)
		{
			if (_disableDurEntity != null)
				_disableDurText.text = Std.string(Math.floor(_timer));
			
			if (_timer >= 0)
				_timer -= HXP.elapsed;
			else
			{
				_timer = _activeTime;
				_active = !_active;
				
				if (_disableDurEntity != null)
				{
					scene.remove(_disableDurEntity);
					_disableDurEntity = null;
					_disableDurText = null;
					_disabled = false;
				}
			}
			
			if (!_active)
				_laserImg.visible = false;
			else
			{
				_laserImg.visible = true;
				
				var e : Entity = scene.collideRect("player", (_dir == 1 ? x : x - _length), y, _length, height);
				if (e != null)
				{
					if(e.name == "normal")
						_seenPlayer = true;
				}
			}
		}
		else
		{
			var e : Entity = scene.collideRect("player", (_dir == 1 ? x : x - _length), y, _length, height);
			if (e != null)
			{
				if (e.name == "normal")
				{
					if (_shootTimer <= 0)
					{
						scene.add(new Bullet((_dir == 1 ? x + 32 : x - 32), y, _dir));
						_shootTimer = _shootCooldown;
					}
					else
						_shootTimer -= HXP.elapsed;
				}
				else
					_seenPlayer = false;
			}
			else
			{
				_seenPlayer = false;
				_active = true;
				_timer = _activeTime;
			}
		}
	}
}