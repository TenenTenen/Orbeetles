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

class OrbitPath extends FlxGroup{

    var waypointSprites:FlxGroup;
    var waypointCircle:FlxSprite;
    public var waypoints:Array<FlxPoint>;
    public var actualPath:Array<FlxPoint>;

    public var orbitRadius:Float;

    var center:FlxPoint;

    public var parentMoon:Moon;

    override public function new(radius, centerX, centerY, parentMoon){
        super();
        center = FlxPoint.get(centerX, centerY);
        this.parentMoon = parentMoon;
        orbitRadius = radius;
        waypoints = getCirclePoints(center, orbitRadius, true);
		waypointSprites = new FlxGroup();
        waypoints.map(wayPoint->{
			var s = new FlxSprite(wayPoint.x-3, wayPoint.y-3).makeGraphic(6, 6, FlxColor.LIME);
			s.alpha = 0.3;
			waypointSprites.add(s);
			return s;
        });
        waypointCircle = new FlxSprite().makeGraphic(Std.int(orbitRadius*2.2), Std.int(orbitRadius*2.2), FlxColor.TRANSPARENT);
        waypointCircle.alpha = 0.3;
        FlxSpriteUtil.drawCircle(waypointCircle, -1, -1, orbitRadius, FlxColor.TRANSPARENT, {color: FlxColor.LIME, thickness: 2});
        if(parentMoon.moonType != MoonType.PLANET){
            waypointCircle.setPosition(parentMoon.x + parentMoon.width/2-waypointCircle.width/2, parentMoon.y+parentMoon.height/2-waypointCircle.height/2);
        }else{
            waypointCircle.setPosition(center.x-waypointCircle.width/2, center.y-waypointCircle.height/2);
        }
        
        waypointCircle.visible = false;
        add(waypointCircle);
        add(waypointSprites);
    }

    public function setRadius(radius){
        orbitRadius = radius;
        while(waypoints.length > 0){
            waypoints.pop().put();
        }

        for(w in waypointSprites){
            w.destroy();
        }
        waypointSprites.clear();

        waypointCircle.makeGraphic(Std.int(orbitRadius*2.2), Std.int(orbitRadius*2.2), FlxColor.TRANSPARENT);
        waypointCircle.alpha = 0.3;
        FlxSpriteUtil.drawCircle(waypointCircle, -1, -1, orbitRadius, FlxColor.TRANSPARENT, {color: FlxColor.LIME, thickness: 2});
        if(parentMoon.moonType != MoonType.PLANET){
            waypointCircle.setPosition(parentMoon.x + parentMoon.width/2-waypointCircle.width/2, parentMoon.y+parentMoon.height/2-waypointCircle.height/2);
        }else{
            waypointCircle.setPosition(center.x-waypointCircle.width/2, center.y-waypointCircle.height/2);
        }

        waypoints = getCirclePoints(center, orbitRadius, true);
        waypoints.map(wayPoint->{
            var s = new FlxSprite(wayPoint.x-3, wayPoint.y-3).makeGraphic(6, 6, FlxColor.LIME);
            if(parentMoon.moonType != MoonType.PLANET){
                s.setPosition(parentMoon.x + parentMoon.width/2 + wayPoint.x-2, parentMoon.y+parentMoon.height/2+wayPoint.y-2);
            }
            s.alpha = 0.3;
            waypointSprites.add(s);
            return s;
        });

        
        
    }

    public function showDots() {
        waypointSprites.visible = true;
        waypointCircle.visible = false;
    }

    public function showCircle() {
        waypointSprites.visible = false;
        waypointCircle.visible = true;
    }

    public function computeActualPath(){
        actualPath = getCirclePoints(center, orbitRadius);
    }

    public static function getCirclePoints(center:FlxPoint, distFromCenter:Float, wayPointMode:Bool = false):Array<FlxPoint>{
		var points = [];

		var circumfrence:Float = 2*Math.PI*distFromCenter;
        var numPoints =  Math.round(circumfrence / (wayPointMode ? 30 : 6));
        //var numPoints = 100;
		for(i in 0...numPoints){
			var v:FlxVector = new FlxVector(1, 1);
			v.length = distFromCenter;
			v.degrees = FlxAngle.asDegrees((2*Math.PI/numPoints)*i);
			points.push(FlxPoint.get(center.x + v.x, center.y + v.y));
		}

        return points;   
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
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        if(parentMoon.moonType != MoonType.PLANET){
            for(i in 0...waypointSprites.length){
                var w = cast(waypointSprites.members[i], FlxSprite);
                w.setPosition(parentMoon.x + parentMoon.width/2 + waypoints[i].x, parentMoon.y+parentMoon.height/2+waypoints[i].y);
            }
            waypointCircle.setPosition(parentMoon.x + parentMoon.width/2-waypointCircle.width/2, parentMoon.y+parentMoon.height/2-waypointCircle.height/2);
        }
    }
}