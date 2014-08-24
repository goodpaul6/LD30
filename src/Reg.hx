/**
 * ...
 * @author Epitome Games
 */
class Reg
{
	private static var _health : Int = 10;
	public static var health(get_health, set_health) : Int;
	
	private static function get_health() : Int
	{
		return _health;
	}
	
	private static function set_health(h : Int) : Int 
	{
		_health = h;
		return h;
	}
	
	private function new() 
	{
	}
}