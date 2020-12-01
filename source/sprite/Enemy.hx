package sprite;

import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.math.FlxVelocity;
import flixel.math.FlxVector;
import flixel.FlxG;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Enemy extends FlxSprite{


    var speed:Float = 40;

    public var start:FlxPoint;
    public var goal:FlxPoint;

    var midpoint:FlxPoint;

    var suckTimer:FlxTimer;

    public function new(start, goal){
        super();
        this.start = start;
        this.goal = goal;
        this.loadGraphic(AssetPaths.alien_flip__png, true, 64, 64);
        this.setPosition(start.x - this.width/2, start.y - this.height/2);
        this.animation.add("flutter", [0, 1, 2, 4, 5, 6, 7, 8, 9, 10, 11], 15);
        animation.play("flutter");
        var vel = FlxVector.get(goal.x - start.x, goal.y - start.y);
        vel.length = speed;
        this.velocity.set(vel.x, vel.y);
        this.angle = vel.degrees;
        vel.put();

        this.scale.set(0.95, 0.95);
        this.width *= 0.44;
        this.height *= 0.44;
        this.centerOffsets();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var midpoint = getMidpoint(midpoint);
        if(midpoint.distanceTo(goal) <= 140){
            velocity.set(0, 0);
            if(suckTimer == null){
                suckTimer = new FlxTimer().start(0.2, (_) -> GameData.g.playerCredits -= 3, 0);
            }
        }
    }

    
    override function kill() {
        if(suckTimer != null){
            suckTimer.cancel();
        }
        super.kill();
        
    }

}