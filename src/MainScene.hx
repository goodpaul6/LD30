import com.haxepunk.Scene;
import com.haxepunk.tmx.TmxEntity;
import com.haxepunk.tmx.TmxMap;
import entities.Guard;
import entities.Key;
import entities.Laser;
import entities.Player;
import entities.Wall;

class MainScene extends Scene
{
	private var _level : TmxEntity;
	
	/*private var _levels : Array<Array<Array<Int>>>= 
	[
		[
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
			[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 9, 1],
			[1, 8, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1],
			[1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 5, 0, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
			[1, 6, 0, 0, 0, 0, 0, 0, 0, 1, 6, 0, 0, 0, 0, 0, 0, 4, 1],
			[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		]
	];
	
	private function loadEntitiesFromArray(idx : Int)
	{
		for (column in 0..._levels[idx - 1].length)
		{
			for (row in 0..._levels[idx - 1][column].length)
			{
				var obj : Int = _levels[idx - 1][column][row];
				
				switch(obj)
				{
				case 1:
					add(new Wall(row * 32, column * 32));
				case 4:
					add(new Laser(row * 32 + 32, column * 32 + 15, -1));
				case 5:
					add(new Laser(row * 32, column * 32 + 15, 1));
				case 6:
					add(new Guard(row * 32, column * 32, 1));
				case 8:
					add(new Player(row * 32, column * 32));
				case 9:
					add(new Player(row * 32, column * 32, true));
				}
			}
		}
	}*/
	
	public function new()
	{
		super();
		var map : TmxMap = TmxMap.loadFromFile("maps/prison.tmx");
		

		for (object in map.getObjectGroup("Objects").objects)
		{
			if (object.name == "player")
				add(new Player(object.x, object.y));
			if (object.name == "guard")
				add(new Guard(object.x, object.y, 1));
			if (object.name == "laser right")
				add(new Laser(object.x, object.y, 1, object.width));
			if (object.name == "laser left")
				add(new Laser(object.x + object.width, object.y, -1, object.width));
			if (object.name == "key")
				add(new Key(object.x, object.y));
		}
		
		for (collider in map.getObjectGroup("Collision").objects)
			add(new Wall(collider.x, collider.y, collider.width, collider.height));
	
		_level = new TmxEntity(map);
		
		_level.loadGraphic("graphics/tileset.png", ["Main"]);
		
		add(_level);
	}
}