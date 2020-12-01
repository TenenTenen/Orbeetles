package sprite;

import flixel.math.FlxVector;
import flixel.FlxG;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;


class MissileMoon extends Moon{

    public var shootCallBack:FlxSprite->Void;

    var shootOrigin:FlxPoint;
   
    public var shootCoolDown:Float = 1.6; 
    public var shootCoolDownTimer:Float = 0; 

    public var shootRange:Float = 180;
    public var bulletSpeed:Float = 90;

    var turret:FlxSprite;

    public function new(orbitPath:OrbitPath, parentMoon:Moon){
        super(MoonType.MISSILE, orbitPath, parentMoon);
        loadGraphic(AssetPaths.turret_missle_base__png);
        //color = FlxColor.RED.getLightened(0.75);


        turret = new FlxSprite();
        turret.loadGraphic(AssetPaths.turret_missle_top__png);

        shootCoolDownTimer = shootCoolDown;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        turret.update(elapsed);
        turret.setPosition(this.x, this.y);
        
        if(isMoving){
            shootCoolDownTimer -= elapsed;
            if(shootCoolDownTimer <= 0){
                shootCoolDownTimer = 0;
            }
        }
    }

    override  function draw() {
        super.draw();
        turret.draw();
    }

    public function tryShoot(enemies:FlxTypedGroup<Enemy>) {

        var closestEnemy:Enemy = null;
        var dist:Float = 0;

        var currentMidpoint:FlxPoint = FlxPoint.get();
        shootOrigin = this.getMidpoint(shootOrigin);
        enemies.forEachAlive(e->{
            currentMidpoint = e.getMidpoint(currentMidpoint);
            var distToEnmey = shootOrigin.distanceTo(currentMidpoint);
            if(closestEnemy == null || distToEnmey <= dist){
                closestEnemy = e;
                dist = distToEnmey;
            }
        });

        //just face closest enemy
        if(closestEnemy != null && dist <= shootRange*2.5){
            currentMidpoint = closestEnemy.getMidpoint(currentMidpoint);
            var dir = FlxVector.get();
            dir.set(currentMidpoint.x-shootOrigin.x, currentMidpoint.y-shootOrigin.y);
            turret.angle = dir.degrees;
            dir.put();
        }   

        if(shootCoolDownTimer > 0){
            return;
        }

        //ONLY SHOOT IF IN RANGE
        if(closestEnemy != null && dist <= shootRange){
            currentMidpoint = closestEnemy.getMidpoint(currentMidpoint);
            shootAtPoint(currentMidpoint.x, currentMidpoint.y);
            shootCoolDownTimer = shootCoolDown;//reset timer
        } 
        
    }

    public function shootAtPoint(targetX:Float, targetY:Float){
        var bullet = new FlxSprite();
        bullet.loadGraphic(AssetPaths.missle_flip_32__png, true, 32, 8, false);
        bullet.animation.add("rotate", [0, 1, 2, 3], 20, true);
        bullet.animation.play("rotate");
        shootOrigin = this.getMidpoint(shootOrigin);
        bullet.setPosition(shootOrigin.x, shootOrigin.y);
        var bulletVel = FlxVector.get();
        bulletVel.set(targetX-shootOrigin.x, targetY-shootOrigin.y);
        bulletVel.length = bulletSpeed;
        bullet.velocity.set(bulletVel.x, bulletVel.y);
        bullet.angle = bulletVel.degrees;
        bulletVel.put();
        if(shootCallBack != null){
            shootCallBack(bullet);

            //UNCOMMENT TO SHOW THE TARGET MARKER
            //
            //var target = new FlxSprite().makeGraphic(5, 5, FlxColor.GREEN);
            //target.setPosition(targetX, targetY);
            //shootCallBack(target);
        }

        

    }   
}