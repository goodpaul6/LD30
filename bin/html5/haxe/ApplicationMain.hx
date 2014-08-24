#if !macro
import Main;
import haxe.Resource;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.media.Sound;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLLoaderDataFormat;
import flash.Lib;
import js.html.Element;
import js.html.AudioElement;

class ApplicationMain {
	private static var completed:Int;
	private static var preloader:com.haxepunk.Preloader;
	private static var total:Int;

	public static var loaders:Map <String, Loader>;
	public static var urlLoaders:Map <String, URLLoader>;
	private static var loaderStack:Array<String>;
	private static var urlLoaderStack:Array<String>;
	// Embed data preloading
	@:noCompletion public static var embeds:Int = 0;
	@:noCompletion public static function loadEmbed(o:Element) {
		embeds++;
		var f = null;
		f = function(_) {
			o.removeEventListener("load", f);
			if (--embeds == 0) preload();
		}
		o.addEventListener("load", f);
	}
	
	public static function main() {
		if (embeds == 0) preload();
	}

	private static function preload() {
		completed = 0;
		loaders = new Map <String, Loader>();
		urlLoaders = new Map <String, URLLoader>();
		total = 0;
		
		flash.Lib.current.loaderInfo = flash.display.LoaderInfo.create (null);
		
		flash.Lib.stage.frameRate = 60;
		// preloader:
		Lib.current.addChild(preloader = new com.haxepunk.Preloader());
		preloader.onInit();
		
		// assets
		loadFile("graphics/debug/console_debug.png");
		loadFile("graphics/debug/console_hidden.png");
		loadFile("graphics/debug/console_logo.png");
		loadFile("graphics/debug/console_output.png");
		loadFile("graphics/debug/console_pause.png");
		loadFile("graphics/debug/console_play.png");
		loadFile("graphics/debug/console_step.png");
		loadFile("graphics/debug/console_visible.png");
		loadFile("graphics/preloader/haxepunk.png");
		loadFile("font/04B_03__.ttf.png");
		loadFile("graphics/guard_line_of_sight.png");
		loadFile("graphics/guard_seen.png");
		loadFile("graphics/guard_sheet.png");
		loadFile("graphics/laser.png");
		loadFile("graphics/laser_line.png");
		loadFile("graphics/player.png");
		loadFile("graphics/player_sheet.png");
		loadFile("graphics/tileset.png");
		loadBinary("maps/prison.tmx");
		
		// bitmaps:
		var resourcePrefix = "NME_:bitmap_";
		for (resourceName in Resource.listNames()) {
			if (StringTools.startsWith (resourceName, resourcePrefix)) {
				var type = Type.resolveClass(StringTools.replace (resourceName.substring(resourcePrefix.length), "_", "."));
				if (type != null) {
					total++;
					#if bitfive_logLoading
						flash.Lib.trace("Loading " + Std.string(type));
					#end
					var instance = Type.createInstance (type, [ 0, 0, true, 0x00FFFFFF, bitmapClass_onComplete ]);
				}
			}
		}
		
		if (total != 0) {
			loaderStack = [];
			for (p in loaders.keys()) loaderStack.push(p);
			urlLoaderStack = [];
			for (p in urlLoaders.keys()) urlLoaderStack.push(p);
			//
			for (i in 0 ... 8) nextLoader();
		} else begin();
	}
	
	private static function nextLoader() {
		if (loaderStack.length != 0) {
			var p:String = loaderStack.shift(),
				o:Loader = loaders.get(p);
			#if bitfive_logLoading
				flash.Lib.trace("Loading " + p);
				o.contentLoaderInfo.addEventListener("complete", function(e) {
					flash.Lib.trace("Loaded " + p);
					loader_onComplete(e);
				});
			#else
				o.contentLoaderInfo.addEventListener("complete", loader_onComplete);
			#end
			o.load(new URLRequest(p));
		} else if (urlLoaderStack.length != 0) {
			var p:String = urlLoaderStack.shift(),
				o:URLLoader = urlLoaders.get(p);
			#if bitfive_logLoading
				flash.Lib.trace("Loading " + p);
				o.addEventListener("complete", function(e) {
					flash.Lib.trace("Loaded " + p);
					loader_onComplete(e);
				});
			#else
				o.addEventListener("complete", loader_onComplete);
			#end
			o.load(new URLRequest(p));
		}
	}
	
	private static function loadFile(p:String):Void {
		loaders.set(p, new Loader());
		total++;
	}
	
	private static function loadBinary(p:String):Void {
		var o:URLLoader = new URLLoader();
		o.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoaders.set(p, o);
		total++;
	}
	
	private static function loadSound(p:String):Void {
		return;
		var i:Int = p.lastIndexOf("."), // extension separator location
			c:Dynamic = untyped flash.media.Sound, // sound class
			s:String, // perceived sound filename (*.mp3)
			o:AudioElement, // audio node
			m:Bool = Lib.mobile,
			f:Dynamic->Void = null, // event listener
			q:String = "canplaythrough"; // preload event
		// not a valid sound path:
		if (i == -1) return;
		// wrong audio type:
		if (!c.canPlayType || !c.canPlayType(p.substr(i + 1))) return;
		// form perceived path:
		s = p.substr(0, i) + ".mp3";
		// already loaded?
		if (c.library.exists(s)) return;
		#if bitfive_logLoading
			flash.Lib.trace("Loading " + p);
		#end
		total++;
		c.library.set(s, o = untyped __js__("new Audio(p)"));
		f = function(_) {
			#if bitfive_logLoading
				flash.Lib.trace("Loaded " + p);
			#end
			if (!m) o.removeEventListener(q, f);
			preloader.onUpdate(++completed, total);
			if (completed == total) begin();
		};
		// do not auto-preload sounds on mobile:
		if (m) f(null); else o.addEventListener(q, f);
	}

	private static function begin():Void {
		preloader.addEventListener(Event.COMPLETE, preloader_onComplete);
		preloader.onLoaded();
	}
	
	private static function bitmapClass_onComplete(instance:BitmapData):Void {
		completed++;
		var classType = Type.getClass (instance);
		Reflect.setField(classType, "preload", instance);
		if (completed == total) begin();
	}

	private static function loader_onComplete(event:Event):Void {
		completed ++;
		preloader.onUpdate (completed, total);
		if (completed == total) begin();
		else nextLoader();
	}

	private static function preloader_onComplete(event:Event):Void {
		preloader.removeEventListener(Event.COMPLETE, preloader_onComplete);
		Lib.current.removeChild(preloader);
		preloader = null;
		if (Reflect.field(Main, "main") == null) {
			var mainDisplayObj = Type.createInstance(DocumentClass, []);
			if (Std.is(mainDisplayObj, flash.display.DisplayObject))
				flash.Lib.current.addChild(cast mainDisplayObj);
		} else {
			Reflect.callMethod(Main, Reflect.field (Main, "main"), []);
		}
	}
}

@:build(DocumentClass.build())
class DocumentClass extends Main {
	@:keep public function new() {
		super();
	}
}

#else // macro
import haxe.macro.Context;
import haxe.macro.Expr;

class DocumentClass {
	
	macro public static function build ():Array<Field> {
		var classType = Context.getLocalClass().get();
		var searchTypes = classType;
		while (searchTypes.superClass != null) {
			if(searchTypes.pack.length == 2
			&& searchTypes.pack[1] == "display"
			&& searchTypes.name == "DisplayObject") {
				var fields = Context.getBuildFields();
				var method = macro {
					return flash.Lib.current.stage;
				}
				fields.push( {
					name: "get_stage",
					access: [ APrivate, AOverride ],
					kind: FFun( {
						args: [],
						expr: method,
						params: [],
						ret: macro :flash.display.Stage
					}), pos: Context.currentPos() });
				return fields;
			}
			searchTypes = searchTypes.superClass.t.get();
		}
		return null;
	}
	
}
#end