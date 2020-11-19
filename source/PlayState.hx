package;

import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.util.FlxPath;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxVector;

import flixel.text.FlxText.FlxTextAlign;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxSort;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.group.FlxSpriteGroup;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import sprite.OrbitPath;
import sprite.ChildOrbitPath;

class PlayState extends FlxState
{

	var CENTER:FlxPoint = new FlxPoint(FlxG.width/2, FlxG.height/2);

	var planet:FlxSprite;
	var moon:FlxSprite;
	var moon2:FlxSprite;

	var moonWayPoints:FlxGroup;
	var moonWayPoints2:FlxGroup;

	var orbitDisplayGroup:FlxTypedGroup<OrbitPath>;

	var orbits:Array<OrbitPath> = [];
	var subOrbits:Array<OrbitPath> = [];
	var activeOrbit:OrbitPath = null;

	var mouseLocationSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);

	var isSubOrbitMode = false;

	override public function create()
	{
		super.create();
		FlxG.mouse.useSystemCursor = true;
		planet = new FlxSprite(CENTER.x, CENTER.y);
		planet.makeGraphic(90, 90, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawCircle(planet, -1, -1, -1, FlxColor.CYAN);
		planet.x -= planet.width/2;
		planet.y -= planet.height/2;

		orbitDisplayGroup = new FlxTypedGroup<OrbitPath>();

		add(orbitDisplayGroup);
		add(planet);

		var info = new FlxText(0, 0, 0, "Click and drag to set orbit. Release to confirm", 16);
		var info2 = new FlxText(0, 0, 0, "(sub-orbit: press and hold a number key to select moon)", 14);
		var reset = new FlxText(0, 0, 0, "[R] to reset", 12);
		add(info);
		add(info2);
		add(reset);
		info.screenCenter(); 
		info2.screenCenter(); 
		info.y = FlxG.height - 48;
		info2.screenCenter();
		info2.y = info.y + 24;
		reset.setPosition(10, 10);
		info.scrollFactor.set(0,0);
		info2.scrollFactor.set(0,0);
		reset.scrollFactor.set(0,0);

	}


	function getEllipticalPoints(center:FlxPoint, distA:Float, distB:Float, wayPointMode:Bool = false):Array<FlxPoint>{
		var points = [];

		var circumfrence:Float =2*Math.PI*Math.sqrt((distA * distA + distB * distB) / (2 * 1.0));  
		var numPoints =  Math.floor(circumfrence / (wayPointMode ? 40 : 6));
		for(i in 0...numPoints){
			var t = (2*Math.PI/numPoints)*i;
			var x = distA*Math.cos(t);
			var y = distB*Math.sin(t);
			var p = new FlxPoint(center.x + x, center.y + y);
			p.rotate(center, 45);
			points.push(p);
			
		}

		return points;
	}


	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		mouseLocationSprite.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		
		var selectedOrbit = getOrbitNum();
		if(selectedOrbit >= orbits.length){
			return;
		}

		if(selectedOrbit != -1){
			trace(
				"hey"
			);
			if(FlxG.camera.target != orbits[selectedOrbit].moon){
				FlxG.camera.follow(orbits[selectedOrbit].moon, FlxCameraFollowStyle.LOCKON, 0.1);
			}
		}else{
			if(FlxG.camera.target != planet){
				FlxG.camera.follow(planet, FlxCameraFollowStyle.LOCKON, 0.1);
			}
		}

		if(FlxG.mouse.justPressed){
			if(selectedOrbit != -1){
				var o = new ChildOrbitPath(roundTo(FlxMath.distanceBetween(orbits[selectedOrbit].moon, mouseLocationSprite), 10), orbits[selectedOrbit].moon);
				activeOrbit = o;
				orbitDisplayGroup.add(o);
				subOrbits.push(activeOrbit);
			}else{
				var o = new OrbitPath(roundTo(FlxMath.distanceBetween(planet, mouseLocationSprite), 25), CENTER.x, CENTER.y);
				activeOrbit = o;
				orbitDisplayGroup.add(o);
				orbits.push(activeOrbit);
			}
		}else if(FlxG.mouse.pressed){
			if(activeOrbit != null){
				trace("change");
				activeOrbit.setRadius(roundTo(FlxMath.distanceBetween(selectedOrbit != -1 ? orbits[selectedOrbit].moon : planet, mouseLocationSprite), selectedOrbit != -1 ? 10 : 25));
			}
		}

		if(FlxG.mouse.justReleased){
			activeOrbit.computeActualPath();
			activeOrbit.startMoon();
			activeOrbit = null;

		}

		if(FlxG.keys.justPressed.R){
			FlxG.resetState();
		}

		
	}

	public function getOrbitNum(){
		if(FlxG.keys.pressed.ONE){
			return 0;
		}

		if(FlxG.keys.pressed.TWO){
			return 1;
		}

		if(FlxG.keys.pressed.THREE){
			return 2;
		}

		if(FlxG.keys.pressed.FOUR){
			return 3;
		}

		if(FlxG.keys.pressed.FIVE){
			return 4;
		}

		if(FlxG.keys.pressed.SIX){
			return 5;
		}

		if(FlxG.keys.pressed.SEVEN){
			return 6;
		}

		if(FlxG.keys.pressed.EIGHT){
			return 7;
		}

		if(FlxG.keys.pressed.NINE){
			return 8;
		}

		return -1;
	}

	public static function roundTo(value:Float, to:Float):Float {
		return Math.round(value / to) * to;
	}

	


	
}
