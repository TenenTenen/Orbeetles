package sprite;

import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxPath;
import flixel.math.FlxAngle;
import flixel.math.FlxVector;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;

class ChildOrbitPath extends OrbitPath{


    var parentMoon:FlxSprite;
    var entagledPathSprite:FlxSprite;

    override public function new(radius, parentMoon:FlxSprite){
        super(radius, 0, 0);
        this.moon.makeGraphic(18, 18, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawCircle(moon, -1, -1, -1, FlxColor.ORANGE.getLightened());

        this.speed = 55;
        this.parentMoon = parentMoon;

        entagledPathSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
        add(entagledPathSprite);
    }

    override function setRadius(radius:Float) {
        orbitRadius = radius;
        while(waypoints.length > 0){
            waypoints.pop().put();
        }

        for(w in wayPointSprites){
            w.destroy();
        }
        wayPointSprites.clear();

        waypoints = OrbitPath.getCirclePoints(center, orbitRadius, true);
        waypoints.map(wayPoint->{
            var s = new FlxSprite(parentMoon.x + parentMoon.width/2 + wayPoint.x-2, parentMoon.y+parentMoon.height/2 + wayPoint.y-2).makeGraphic(4, 4, FlxColor.WHITE);
            s.alpha = 0.65;
            wayPointSprites.add(s);
            return s;
        });

        var parentMoonCenter = parentMoon.getMidpoint();
        var offsetMouseCenter = FlxPoint.get(FlxG.mouse.x - parentMoonCenter.x, FlxG.mouse.y - parentMoonCenter.y);
        var closestWayPoint = getClosestPointAndIndex(offsetMouseCenter, waypoints).point;
        entagledPathSprite.setPosition(closestWayPoint.x-entagledPathSprite.width/2, closestWayPoint.y - entagledPathSprite.height/2);
        moon.setPosition(parentMoon.x + parentMoon.width/2 + entagledPathSprite.x -moon.width/2, parentMoon.y+parentMoon.height/2+entagledPathSprite.y-moon.height/2);
        parentMoonCenter.put();
        offsetMouseCenter.put();

    }

    override function startMoon(){
        setPathWithStartingPoint(entagledPathSprite, actualPath);
        entagledPathSprite.setPosition(entagledPathSprite.path.nodes[0].x-entagledPathSprite.width/2, entagledPathSprite.path.nodes[0].y - entagledPathSprite.height/2);
        entagledPathSprite.path.start(null, speed, FlxPath.LOOP_FORWARD);


        for(w in wayPointSprites){
            cast(w, FlxSprite).alpha = 0.3;
        }

        moonIsActive = true;
    }
    

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(moonIsActive){
            for(i in 0...wayPointSprites.length){
                var w = cast(wayPointSprites.members[i], FlxSprite);
                w.setPosition(parentMoon.x + parentMoon.width/2 + waypoints[i].x, parentMoon.y+parentMoon.height/2+waypoints[i].y);
            }
            moon.setPosition(parentMoon.x + parentMoon.width/2 + entagledPathSprite.x -moon.width/2, parentMoon.y+parentMoon.height/2+entagledPathSprite.y-moon.height/2);
        }
        
    }
}