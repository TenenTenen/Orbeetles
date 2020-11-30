package sprite;

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


    var speed:Float = 20;

    public var start:FlxPoint;
    public var goal:FlxPoint;

    var midpoint:FlxPoint;

    public function new(start, goal){
        super();
        this.start = start;
        this.goal = goal;
        this.setPosition(start.x, start.y);
        this.makeGraphic(12, 12, FlxColor.PURPLE.getLightened());
        var vel = FlxVector.get(goal.x - start.x, goal.y - start.y);
        vel.length = speed;
        this.velocity.set(vel.x, vel.y);
        vel.put();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var midpoint = getMidpoint(midpoint);
        if(midpoint.distanceTo(goal) <= width){
            velocity.set(0, 0);
            kill();
        }
    }

}