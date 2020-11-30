package sprite;

import flixel.util.FlxTimer;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxVector;
import flixel.FlxG;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class LaserMoon extends Moon{

    public var shootCallBack:FlxSprite->Void;

    var shootOrigin:FlxPoint;
   
    public var shootCoolDown:Float = 1.6; 
    public var shootCoolDownTimer:Float = 0; 

    public var shootRange:Float = 80;
    public var bulletSpeed:Float = 80;

    public var laserEmitter:FlxEmitter;

    var parentMoonMidpoint:FlxPoint;

    public function new(orbitPath:OrbitPath, parentMoon:Moon){
        super(MoonType.LASER, orbitPath, parentMoon);

        loadGraphic(AssetPaths.turret_missle_base__png);
        color = FlxColor.YELLOW.getLightened(0.75);

        laserEmitter = new FlxEmitter(0, 0);
        laserEmitter.makeParticles(4, 14, FlxColor.YELLOW, 400);
        laserEmitter.launchMode = FlxEmitterMode.CIRCLE;
        laserEmitter.speed.set(850);
        laserEmitter.angle.set(0, 360);
        laserEmitter.scale.set(0.8, 0.8, 1.2, 1.2);
        laserEmitter.alpha.set(0.6, 1.0);
        laserEmitter.solid = true;

        shootCoolDownTimer = shootCoolDown;

    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        laserEmitter.update(elapsed);

        shootOrigin = this.getMidpoint(shootOrigin);

        if(parentMoon != null){
            laserEmitter.x = shootOrigin.x;
            laserEmitter.y = shootOrigin.y;
        }

        if(isMoving){
            shootCoolDownTimer -= elapsed;
            if(shootCoolDownTimer <= 0){
                shootCoolDownTimer = 0;
            }
        }

        
    }

    override  function draw() {
        super.draw();
        laserEmitter.draw();
    }



    public function tryShoot(enemies:FlxTypedGroup<Enemy>) {
        if(shootCoolDownTimer > 0){
            return;
        }

        if(!laserEmitter.emitting){
            laserEmitter.start(false, 0.002);
        }

        new FlxTimer().start(1.0, (_)-> {
            laserEmitter.kill();
            shootCoolDownTimer = shootCoolDown;//reset timer
        });

        parentMoonMidpoint = parentMoon.getMidpoint(parentMoonMidpoint);
        shootOrigin = this.getMidpoint(shootOrigin);
        var v = FlxVector.get(parentMoonMidpoint.x, parentMoonMidpoint.y).subtract(shootOrigin.x, shootOrigin.y);
        laserEmitter.launchAngle.set(v.degrees-2, v.degrees+2);
        laserEmitter.lifespan.set((1/laserEmitter.speed.start.min)*(parentMoonMidpoint.distanceTo(shootOrigin)-parentMoon.width/3));
        v.put();

    }
}