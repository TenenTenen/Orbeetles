package;

import flixel.tweens.FlxEase;
import flixel.system.debug.Tooltip.TooltipOverlay;
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

import model.Costs;
import model.EnemyWave;
import model.EnemyWaveSpawner;
import model.CostBreakdown;
import sprite.ButtonPanel;
import sprite.Tooltip;
import sprite.DayCounter;

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
import sprite.MoonDisplay;
import flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{

	var CENTER:FlxPoint;

	var planet:Moon;

	var mouseLocationSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);

	var isSubOrbitMode = false;

	var selectedBody:FlxSprite;
	var selectedBodyMidpoint:FlxPoint;

	var currentEditingMoon:Moon;

	var moons:FlxTypedGroup<Moon> = new FlxTypedGroup<Moon>();
	var toolTips:FlxTypedGroup<ToolTip> = new FlxTypedGroup<ToolTip>();
	var orbits:FlxTypedGroup<OrbitPath> = new FlxTypedGroup<OrbitPath>();
	var bullets:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var lasers:FlxTypedGroup<FlxEmitter> = new FlxTypedGroup<FlxEmitter>();
	var enemies:FlxTypedGroup<Enemy> = new FlxTypedGroup<Enemy>();

	var isMoving:Bool = false;

	var displayOrbitPaths = true;
	var useCirclesForPath = false;

	var bg1:FlxSprite;
	var bg2:FlxSprite;

	var mainCam:FlxCamera;
	var uiCam:FlxCamera;
	var uiGroup:FlxGroup = new FlxGroup();
	var buttonPanel:ButtonPanel;
	var moonDisplay:MoonDisplay;
	var dayCounter:DayCounter;

	var enemySpawner:EnemyWaveSpawner;

	override public function create()
	{
		super.create();
		FlxG.mouse.useSystemCursor = true;

		mainCam = new FlxCamera(0, 0, Std.int(FlxG.width*1.25), FlxG.height);
		mainCam.x = 0 - (mainCam.width - FlxG.width)/2;
		mainCam.x -= 35;
		mainCam.antialiasing = true;
		uiCam = new FlxCamera();
		uiCam.antialiasing = true;
		uiCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.reset(mainCam);
		FlxG.cameras.add(uiCam);
		FlxCamera.defaultCameras = [mainCam];
		CENTER = new FlxPoint(FlxG.camera.width/2, FlxG.camera.height/2);

		planet = new Moon(PLANET, null);
		planet.orbitDistFromSurface = 100;
		planet.numOrbits = 6;
		planet.orbitStep = 100;
		planet.x = CENTER.x - planet.width/2;
		planet.y = CENTER.y - planet.height/2;
		//planet.scale.set(1.8, 1.8);
		//planet.updateHitbox();
		
		planet.angularVelocity = -2;
		//planet.color = FlxColor.MAGENTA.getLightened(0.82);
		selectedBody = planet;
		FlxG.camera.follow(selectedBody, FlxCameraFollowStyle.LOCKON, 0.04);
		FlxG.camera.deadzone.set((FlxG.camera.width - selectedBody.width) / 2, (FlxG.camera.height - selectedBody.height) / 2, selectedBody.width, selectedBody.height);
		mainCam.zoom = 0.9;

		FlxG.sound.playMusic(AssetPaths.drone__ogg);
		FlxG.sound.music.fadeIn(3, 0, 0.2);

		bg1 = new FlxSprite().loadGraphic(AssetPaths.backdrop_layer0__png);
		bg2 = new FlxSprite().loadGraphic(AssetPaths.backdrop_layer1__png);
		bg1.scale.set(1.2, 1.2);
		bg2.scale.set(1.3, 1.3);
		bg1.scrollFactor.set(0.2, 0.2);
		bg2.scrollFactor.set(0.6, 0.6);
		bg2.alpha = 0.5;
		bg1.angularVelocity = 0.33;
		bg2.angularVelocity = 0.54;
		bg1.x = FlxG.camera.width/2-bg1.width/2;
		bg1.y = FlxG.camera.height/2-bg1.height/2;
		bg2.x = FlxG.camera.width/2-bg2.width/2;
		bg2.y = FlxG.camera.height/2-bg2.height/2;
		add(bg1);
		add(bg2);

		add(orbits);
		add(moons);
		add(enemies);
		add(bullets);
		add(planet);
		add(toolTips);

		buttonPanel = new ButtonPanel(uiCam);
		add(buttonPanel);

		moonDisplay = new MoonDisplay(uiCam);
		moonDisplay.updateMoon(planet);
		add(moonDisplay);

		dayCounter = new DayCounter(uiCam);
		add(dayCounter);

		enemySpawner = new EnemyWaveSpawner(enemies, planet.getMidpoint());

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

		buttonPanel.handleButtonsHover();
		if(FlxG.mouse.justPressed){

			var buttonWasPressed = false;
			buttonPanel.handleButtonsClick((mType) -> {
				buttonWasPressed = true;
				addNewMoon(mType);
			}, null);

			dayCounter.handleButtonsClick(() -> {
				buttonWasPressed = true;
				startNextWave();
			}, null);

			if(!buttonWasPressed && currentEditingMoon != null){
				FlxG.sound.play(AssetPaths.purchase_register__ogg, 0.5).fadeOut();
				currentEditingMoon.donEditing();
				buttonPanel.allButtonsUp();
				updateVisibleOrbits();
				var moonCost = Costs.data.getCost(currentEditingMoon, moons.members, currentEditingMoon.parentMoon);
				GameData.g.playerCredits -= Std.int(moonCost.totalCost());
				currentEditingMoon = null;
				return;
			}
		}
		if(currentEditingMoon != null){
			var distFromBodyToMouse = getDistFromMouseClampedToRange();
			currentEditingMoon.orbitPath.setRadius(distFromBodyToMouse);
			currentEditingMoon.setPositionToClosestWaypoint();
			currentEditingMoon.updateCost(Costs.data.getCost(currentEditingMoon, moons.members, currentEditingMoon.parentMoon));
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
						buttonPanel.loadButtons(true, [MoonType.MISSILE, MoonType.LASER].indexOf(moon.moonType) != -1);
						moonDisplay.updateMoon(moon);
						trace(Type.getClassName(Type.getClass(moon)), moon.speed);
						uiCam.flash(0x80FFFFFF, 0.3, null, true);
						FlxG.sound.play(AssetPaths.shutter_1__ogg, 0.5);
						new FlxTimer().start(0.1, (_) -> {
							FlxG.camera.follow(selectedBody, FlxCameraFollowStyle.LOCKON, 0.04);
							FlxG.camera.deadzone.set((FlxG.camera.width - selectedBody.width) / 2, (FlxG.camera.height - selectedBody.height) / 2, selectedBody.width, selectedBody.height);
						});
						break;
					}
				}
				if(!somethingSelected && selectedBody != planet){
					somethingSelected = true;
					selectedBody = planet;
					buttonPanel.loadButtons(false);
					moonDisplay.updateMoon(planet);
					uiCam.flash(0x80FFFFFF, 0.3, null, true);
					FlxG.sound.play(AssetPaths.shutter_1__ogg, 0.5);
					new FlxTimer().start(0.1, (_) -> {
						FlxG.camera.follow(selectedBody, FlxCameraFollowStyle.LOCKON, 0.04);
						FlxG.camera.deadzone.set((FlxG.camera.width - selectedBody.width) / 2, (FlxG.camera.height - selectedBody.height) / 2, selectedBody.width, selectedBody.height);
					});
				}
			}
		}

		if(isMoving){
			checkForEndOfWave();
		}

		if(FlxG.keys.justPressed.W){
			displayOrbitPaths = !displayOrbitPaths;
			if(!displayOrbitPaths){
				orbits.visible = false;
			}else{
				orbits.visible = true;
			}
		}

		if(FlxG.keys.justPressed.Z){
			FlxG.camera.zoom -= 0.25;
		}

		if(FlxG.keys.justPressed.X){
			FlxG.camera.zoom += 0.25;
		}


		if(FlxG.keys.justPressed.B){
			//FlxTween.tween(mainCam, {x:  0 - (mainCam.width - FlxG.width)/2 - 150}, 0.5);
		}

		if(FlxG.keys.justPressed.V){
		//	FlxTween.tween(mainCam, {x:  0 - (mainCam.width - FlxG.width)/2}, 0.5);
		}

	}

	function getDistFromMouseClampedToRange(){
		selectedBodyMidpoint = selectedBody == planet ? planet.getMidpoint(selectedBodyMidpoint) : selectedBody.getMidpoint(selectedBodyMidpoint);
		var distFromBodyToMouse = selectedBodyMidpoint.distanceTo(FlxG.mouse.getPosition());
		return findClosest(distFromBodyToMouse, cast(selectedBody, Moon).getOrbitDistances());
	}

	function addNewMoon(moonTypeToBuild:MoonType){
		var distFromBodyToMouse = getDistFromMouseClampedToRange();
		var parentBody:Moon = cast(selectedBody);
		//use either planet x/y or, 0, 0 for sattelites
		var o = new OrbitPath(distFromBodyToMouse, selectedBody == planet ? selectedBodyMidpoint.x : 0, selectedBody == planet ? selectedBodyMidpoint.y : 0, parentBody);
		useCirclesForPath ? o.showCircle() : o.showDots();
		var moon:Moon;
		if(parentBody.moonType == MoonType.PLANET){
			moon = new Moon(moonTypeToBuild, o, parentBody);
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
		toolTips.add(moon.costToolTip);
		parentBody.childMoons.push(moon);
		currentEditingMoon = moon;
	}

	function updateVisibleOrbits(){
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
	
	public function startNextWave(){
		isMoving = true;
		FlxTween.tween(dayCounter, {y: dayCounter.y + 144}, 0.8, {startDelay: 0.15, ease: FlxEase.backOut});
		enemySpawner.startWave([new EnemyWave(5, 5)]);
		for(moon in moons){
			if(!moon.isMoving){
				moon.startMoon();
			}
		}
	}

	public function checkForEndOfWave(){
		if(!isMoving){
			return;
		}
		trace(enemies.countLiving(), enemySpawner.isCompleted());
		if(enemies.countLiving() <= 0 && enemySpawner.isCompleted()){
			isMoving = false;
			enemies.clear();
			dayCounter.readyButton.up();
			GameData.g.dayIndex++;
			FlxTween.tween(GameData.g, {playerCredits: GameData.g.playerCredits + GameData.g.salary}, 1.5);
			FlxG.sound.play(AssetPaths.purchase_register__ogg, 0.5).fadeOut();
			FlxTween.tween(dayCounter, {y: dayCounter.y - 144}, 0.8, {startDelay: 1.5, ease: FlxEase.backOut});
			new FlxTimer().start(1.5, (_) ->{
				for(moon in moons){
					if(moon.isMoving){
						moon.stopMoon();
					}
				}
		});
		}
	}

	public static function roundTo(value:Float, to:Float):Float {
		return Math.round(value / to) * to;
	}

	public static function findClosest(val:Float, list:Array<Int>){
		var closest:Int = -1;
		var closestIndex:Int = -1;
		for(i in 0...list.length){
			var diffClosest = Math.abs(val-closest);
			var diffNew = Math.abs(val-list[i]);
			if(closest < 0 || diffNew < diffClosest){
				closest = list[i];
				closestIndex = i;
			}
		}
		return closest;
	}

	


	
}
