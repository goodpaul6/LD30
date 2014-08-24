import com.haxepunk.Engine;
import com.haxepunk.HXP;

class Main extends Engine
{
	public function new()
	{
		super(800, 600, 60, true);
	}
	
	public override function init()
	{
#if debug
		HXP.console.enable();
#end
		HXP.scene = new MainScene();
	}
	
	public static function main() 
	{ 
		new Main(); 
	}
}