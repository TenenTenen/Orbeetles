package;

import flixel.util.FlxTimer;
import flixel.group.FlxGroup;
import flixel.FlxBasic;
import flixel.effects.particles.FlxEmitter;
import flixel.system.frontEnds.BitmapFrontEnd;
import flixel.FlxCamera;
import flash.ui.Mouse;
import sprite.Moon;
import sprite.LaserMoon;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.util.FlxPath;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxVector;

import flixel.FlxCamera.FlxCameraFollowStyle;
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
import sprite.Enemy;
import sprite.MissileMoon;
import flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{

	var CENTER:FlxPoint = new FlxPoint(FlxG.width/2, FlxG.height/2);

	var planet:Moon;

	var mouseLocationSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);

	var isSubOrbitMode = false;

	var selectedBody:FlxSprite;
	var selectedBodyMidpoint:FlxPoint;

	var currentEditingMoon:Moon;

	var moons:FlxTypedGroup<Moon> = new FlxTypedGroup<Moon>();
	var orbits:FlxTypedGroup<OrbitPath> = new FlxTypedGroup<OrbitPath>();
	var bullets:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var lasers:FlxTypedGroup<FlxEmitter> = new FlxTypedGroup<FlxEmitter>();
	var enemies:FlxTypedGroup<Enemy> = new FlxTypedGroup<Enemy>();

	var isMoving:Bool = false;

	var displayOrbitPaths = true;
	var useCirclesForPath = false;

	var moonTypeToBuild:MoonType = MISSILE;
	var bulletMoonIcon:FlxSprite;
	var laserMoonIcon:FlxSprite;

	var bg1:FlxSprite;
	var bg2:FlxSprite;

	var mainCam:FlxCamera;
	var uiCam:FlxCamera;
	var uiGroup:FlxGroup = new FlxGroup();

	override public function create()
	{
		super.create();
		FlxG.mouse.useSystemCursor = true;

		mainCam = new FlxCamera(0, 0, Std.int(FlxG.width*1.5), FlxG.height);
		mainCam.x = 0 - (mainCam.width - FlxG.width)/2;
		uiCam = new FlxCamera();
		uiCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.reset(mainCam);
		FlxG.cameras.add(uiCam);
		FlxCamera.defaultCameras = [mainCam];

		planet = new Moon(PLANET, null);
		planet.x = CENTER.x - planet.width/2;
		planet.y = CENTER.y - planet.width/2;
		FlxG.camera.follow(planet, FlxCameraFollowStyle.LOCKON, 0.25);

		planet.angularVelocity = -2;
		planet.color = FlxColor.CYAN.getLightened(0.5);
		selectedBody = planet;

		FlxG.sound.playMusic(AssetPaths.drone__ogg);
		FlxG.sound.music.fadeIn(3, 0, 0.2);

		bg1 = new FlxSprite().loadGraphic(AssetPaths.backdrop_layer0__png);
		bg2 = new FlxSprite().loadGraphic(AssetPaths.backdrop_layer1__png);
		bg1.scale.set(1.2, 1.2);
		bg2.scale.set(1.3, 1.3);
		bg2.alpha = 0.5;
		bg1.angularVelocity = 0.33;
		bg2.angularVelocity = 0.54;
		bg1.x = FlxG.width/2-bg1.width/2;
		bg2.x = FlxG.width/2-bg2.width/2;
		add(bg1);
		add(bg2);

		add(orbits);
		add(moons);
		add(enemies);
		add(bullets);
		add(planet);

		var info = new FlxText(0, 0, 0, "Hold [SPACE], then Click and drag to add/edit moons", 12);
		var info2 = new FlxText(0, 0, 0, "Select a moon to orbit by clicking on it, or click away to select the main planet", 12);
		var reset = new FlxText(0, 0, 0, "[R] to reset", 12);
		var enemy = new FlxText(0, 0, 0, "[E] to spawn enemy", 12);
		var start = new FlxText(0, 0, 0, "[ENTER] to start/stop all", 14);
		var type = new FlxText(0, 0, 0, "select\nmoon type", 11);
		type.alignment = FlxTextAlign.CENTER;

		var orbitVis = new FlxText(0, 0, 0, "[W] to toggle orbit path visible", 12);
		var orbitType = new FlxText(0, 0, 0, "[Q] to toggle orbit path type (dots / circle)", 12);

		var s = new FlxSprite().makeGraphic(80, 40, FlxColor.GRAY.getDarkened(0.5));
		bulletMoonIcon = new FlxSprite().makeGraphic(40, 40,FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawCircle(bulletMoonIcon, 20, 20, 10, FlxColor.RED.getLightened());      
		FlxSpriteUtil.drawRect(bulletMoonIcon, 2, 2, 36, 36, FlxColor.TRANSPARENT, {color: FlxColor.WHITE, thickness: 2});      
		laserMoonIcon = new FlxSprite().makeGraphic(40, 40,FlxColor.TRANSPARENT, true);   
		FlxSpriteUtil.drawCircle(laserMoonIcon, 20, 20, 10, FlxColor.YELLOW.getLightened());
		//s.scrollFactor.set(0, 0);   
		//bulletMoonIcon.scrollFactor.set(0, 0);   
		//laserMoonIcon.scrollFactor.set(0, 0);   
		s.x = FlxG.width - s.width;
		s.x -= 12;
		s.y += 12;
		bulletMoonIcon.x = s.x;
		bulletMoonIcon.y = s.y;
		laserMoonIcon.x= bulletMoonIcon.x + bulletMoonIcon.width;
		laserMoonIcon.y= s.y;
		type.y = s.y + s.height + 4;
		type.x = s.x+s.width/2 - type.frameWidth/2;

		add(uiGroup);
		uiGroup.add(s);
		uiGroup.add(bulletMoonIcon);
		uiGroup.add(laserMoonIcon);
		uiGroup.add(info);
		uiGroup.add(info2);
		uiGroup.add(reset);
		uiGroup.add(enemy);
		uiGroup.add(start);
		uiGroup.add(orbitVis);
		uiGroup.add(orbitType);
		uiGroup.add(type);
		info.screenCenter(); 
		info2.screenCenter(); 
		info.y = FlxG.height - 48;
		info2.screenCenter();
		info2.y = info.y + 24;
		reset.setPosition(10, 10);
		orbitVis.setPosition(reset.x, reset.y + 18);
		orbitType.setPosition(orbitVis.x, orbitVis.y + 18);
		enemy.setPosition(orbitType.x, orbitType.y + 18);
		start.setPosition(enemy.x, enemy.y + 18);
		// info.scrollFactor.set(0,0);
		// info2.scrollFactor.set(0,0);
		// reset.scrollFactor.set(0,0);
		// enemy.scrollFactor.set(0,0);
		// start.scrollFactor.set(0,0);
		// orbitType.scrollFactor.set(0,0);
		// orbitVis.scrollFactor.set(0,0);
		// type.scrollFactor.set(0,0);

		uiGroup.forEach(b -> b.cameras = [uiCam]);
		uiGroup.cameras = [uiCam];

	}

	public function addBullet(bullet:FlxSprite){
		trace("bullet");
		bullets.add(bullet);
	}


	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		mouseLocationSprite.setPosition(FlxG.mouse.x, FlxG.mouse.y);

		for(moon in moons){
			for(moon in moons){
				if(moon.parentMoon != null){
					if(Std.is(moon, MissileMoon)){
						cast(moon, MissileMoon).tryShoot(enemies);
					}
					if(Std.is(moon, LaserMoon)){
						cast(moon, LaserMoon).tryShoot(enemies);
					}
				}
			}
		}

		FlxG.overlap(bullets, enemies, (b, e)->{
			bullets.remove(b);
			enemies.remove(e);
		});

		FlxG.overlap(lasers, enemies, (l, e)->{
			enemies.remove(e);
		});

		if(FlxG.mouse.justPressed){
			var selected:FlxSprite = null;
			if(bulletMoonIcon.getHitbox().containsPoint(FlxG.mouse.getPositionInCameraView(uiCam))){
				selected = bulletMoonIcon;
				moonTypeToBuild = MISSILE;
			}
			if(laserMoonIcon.getHitbox().containsPoint(FlxG.mouse.getPositionInCameraView(uiCam))){
				selected = laserMoonIcon;
				moonTypeToBuild = LASER;
			}

			if(selected != null){
				bulletMoonIcon.makeGraphic(40, 40,FlxColor.TRANSPARENT, true);
				FlxSpriteUtil.drawCircle(bulletMoonIcon, 20, 20, 10, FlxColor.RED.getLightened());      
				laserMoonIcon.makeGraphic(40, 40,FlxColor.TRANSPARENT, true);   
				FlxSpriteUtil.drawCircle(laserMoonIcon, 20, 20, 10, FlxColor.YELLOW.getLightened());
				FlxSpriteUtil.drawRect(selected, 2, 2, 36, 36, FlxColor.TRANSPARENT, {color: FlxColor.WHITE, thickness: 2});
				addNewMoon();
			}else{
				if(currentEditingMoon != null){
					currentEditingMoon.isEditing = false;
					currentEditingMoon.orbitPath.showCircle();
					currentEditingMoon = null;
					return;
				}
			}
		}
		if(currentEditingMoon != null){
			var distFromBodyToMouse = getDistFromMouseClampedToRange();
			currentEditingMoon.orbitPath.setRadius(distFromBodyToMouse);
			currentEditingMoon.setPositionToClosestWaypoint();
			updateVisibltOrbits();
		}else{
			if(FlxG.mouse.justPressed){
				var somethingSelected = false;
				for(moon in moons){
					if(FlxG.mouse.overlaps(moon)){
						somethingSelected = true;
						if(selectedBody == moon){
							break;
						}
						selectedBody = moon;
						trace(Type.getClassName(Type.getClass(moon)), moon.speed);
						uiCam.flash(0x80FFFFFF, 0.3, null, true);
						FlxG.sound.play(AssetPaths.shutter_1__ogg, 0.5);
						new FlxTimer().start(0.1, (_) -> 
							FlxG.camera.follow(selectedBody, FlxCameraFollowStyle.LOCKON, 0.04)
						);
						break;
					}
				}
				if(!somethingSelected && selectedBody != planet){
					somethingSelected = true;
					selectedBody = planet;
					uiCam.flash(0x80FFFFFF, 0.3, null, true);
					FlxG.sound.play(AssetPaths.shutter_1__ogg, 0.5);
					new FlxTimer().start(0.1, (_) -> 
						FlxG.camera.follow(selectedBody, FlxCameraFollowStyle.LOCKON, 0.04)
					);
				}
			}
		}
		
		if(FlxG.keys.justPressed.ENTER){
			if(isMoving){
				isMoving = false;
				for(moon in moons){
					if(moon.isMoving){
						moon.stopMoon();
					}
				}
			}else{
				isMoving = true;
				for(moon in moons){
					if(!moon.isMoving){
						moon.startMoon();
					}
				}
			}
		}

		if(FlxG.keys.justPressed.W){
			displayOrbitPaths = !displayOrbitPaths;
			if(!displayOrbitPaths){
				orbits.visible = false;
			}else{
				orbits.visible = true;
			}
		}

		if(FlxG.keys.justPressed.Q){
			useCirclesForPath = !useCirclesForPath;
			if(!useCirclesForPath){
				orbits.forEach(o -> o.showDots());
			}else{
				orbits.forEach(o -> o.showCircle());
			}
		}

		if(FlxG.keys.justPressed.E){
			spawnEnemy();
		}


		if(FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT){
			moonTypeToBuild = moonTypeToBuild == LASER ? MISSILE : LASER;
			bulletMoonIcon.makeGraphic(40, 40,FlxColor.TRANSPARENT, true);
			FlxSpriteUtil.drawCircle(bulletMoonIcon, 20, 20, 10, FlxColor.RED.getLightened());      
			laserMoonIcon.makeGraphic(40, 40,FlxColor.TRANSPARENT, true);   
			FlxSpriteUtil.drawCircle(laserMoonIcon, 20, 20, 10, FlxColor.YELLOW.getLightened());

			var selected = moonTypeToBuild == LASER ? laserMoonIcon : bulletMoonIcon;
			FlxSpriteUtil.drawRect(selected, 2, 2, 36, 36, FlxColor.TRANSPARENT, {color: FlxColor.WHITE, thickness: 2});      

		}

		if(FlxG.keys.justPressed.Z){
			FlxG.camera.zoom -= 0.25;
		}

		if(FlxG.keys.justPressed.X){
			FlxG.camera.zoom += 0.25;
		}

		if(FlxG.keys.justPressed.R){
			FlxG.resetState();
		}

		if(FlxG.keys.justPressed.B){
			FlxTween.tween(mainCam, {x:  0 - (mainCam.width - FlxG.width)/2 - 100}, 0.5);
		}

		if(FlxG.keys.justPressed.V){
			FlxTween.tween(mainCam, {x:  0 - (mainCam.width - FlxG.width)/2}, 0.5);
		}

	}

	function getDistFromMouseClampedToRange(){
		selectedBodyMidpoint = selectedBody == planet ? planet.getMidpoint(selectedBodyMidpoint) : selectedBody.getMidpoint(selectedBodyMidpoint);
		var distFromBodyToMouse = selectedBodyMidpoint.distanceTo(FlxG.mouse.getPosition());
		var minOrbitDist = selectedBody == planet ? planet.width/2 + 100 : cast(selectedBody, Moon).getMinOrbitDist();
		var maxOrbitDist = selectedBody == planet ? 100*5+minOrbitDist : cast(selectedBody, Moon).getMaxOrbitDist();
		distFromBodyToMouse =  Math.min(Math.max(distFromBodyToMouse, minOrbitDist), maxOrbitDist);
		return roundTo(distFromBodyToMouse, selectedBody == planet ? 100 : cast(selectedBody, Moon).orbitStep);
	}

	function addNewMoon(){
		var distFromBodyToMouse = getDistFromMouseClampedToRange();
		var parentBody = selectedBody == planet ? null : cast(selectedBody);
		//use either planet x/y or, 0, 0 for sattelites
		var o = new OrbitPath(distFromBodyToMouse, selectedBody == planet ? selectedBodyMidpoint.x : 0, selectedBody == planet ? selectedBodyMidpoint.y : 0, parentBody);
		useCirclesForPath ? o.showCircle() : o.showDots();
		var moon:Moon;
		if(parentBody == null){
			moon = new Moon(MoonType.IRON, o);
		}else{
			if(moonTypeToBuild == MISSILE){
				var m = new MissileMoon(o, parentBody);
				m.shootCallBack = addBullet;
				moon=m;
			}else{
				var m = new LaserMoon(o, parentBody);
				lasers.add(m.laserEmitter);
				moon = m;
			}
		}
		orbits.add(o);
		moons.add(moon);
		currentEditingMoon = moon;
	}

	function updateVisibltOrbits(){
		var orbitsAccountedFor:Array<OrbitPath> = [];
        orbits.forEach(o->{
			if(orbitsAccountedFor.indexOf(o) != -1){
				return;
			}
			for(other in orbits){
				if(orbitsAccountedFor.indexOf(other) != -1){
					continue;
				}
				if(o == other){
					continue;
				}
				if(o.orbitRadius == other.orbitRadius && o.parentMoon == other.parentMoon){
					other.visible = false;
					orbitsAccountedFor.push(other);
				}
			}
			o.visible = true;
			orbitsAccountedFor.push(o);
			return;
		});
    }

	public function spawnEnemy(){
		var v = FlxVector.get(1, 1);
		v.degrees = Random.float(0, 355);
		v.length = CENTER.distanceTo(FlxPoint.weak(0, 0));
		var e:Enemy = new Enemy(FlxPoint.get(CENTER.x+v.x, CENTER.y+v.y), CENTER);
		enemies.add(e);
	}

	public static function roundTo(value:Float, to:Float):Float {
		return Math.round(value / to) * to;
	}

	


	
}
