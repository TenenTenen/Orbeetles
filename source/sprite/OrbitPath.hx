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

typedef ClosestPointData = {
    var point : FlxPoint;
    var index : Int;
    var dist : Float;
}

class OrbitPath extends FlxGroup{

    var wayPointSprites:FlxGroup;
    var waypoints:Array<FlxPoint>;
    var actualPath:Array<FlxPoint>;


    var speed:Float = 45;
    var orbitRadius:Float;

    var center:FlxPoint;

    public var moon:FlxSprite;
    public var moonIsActive:Bool = false;

    override public function new(radius, centerX, centerY){
        super();
        center = FlxPoint.get(centerX, centerY);
        orbitRadius = radius;
        waypoints = getCirclePoints(center, orbitRadius, true);
		wayPointSprites = new FlxGroup();
        waypoints.map(wayPoint->{
			var s = new FlxSprite(wayPoint.x-2, wayPoint.y-2).makeGraphic(4, 4, FlxColor.WHITE);
			s.alpha = 0.65;
			wayPointSprites.add(s);
			return s;
        });
        
        add(wayPointSprites);


        moon = new FlxSprite();
        moon.makeGraphic(38, 38, FlxColor.TRANSPARENT);
        FlxSpriteUtil.drawCircle(moon, -1, -1, -1, FlxColor.GRAY.getLightened());
        add(moon);

        //moon.angularVelocity = 14;

    }

    public function setRadius(radius){
        orbitRadius = radius;
        while(waypoints.length > 0){
            waypoints.pop().put();
        }

        for(w in wayPointSprites){
            w.destroy();
        }
        wayPointSprites.clear();

        waypoints = getCirclePoints(center, orbitRadius, true);
        waypoints.map(wayPoint->{
            var s = new FlxSprite(wayPoint.x-2, wayPoint.y-2).makeGraphic(4, 4, FlxColor.WHITE);
            s.alpha = 0.65;
            wayPointSprites.add(s);
            return s;
        });

        var closestWayPoint = getClosestPointAndIndex(FlxG.mouse.getPosition(), waypoints).point;
        moon.setPosition(closestWayPoint.x-moon.width/2, closestWayPoint.y - moon.height/2);
        
    }

    public function startMoon(){
        setPathWithStartingPoint(moon, actualPath);
        moon.setPosition(moon.path.nodes[0].x-moon.width/2, moon.path.nodes[0].y - moon.height/2);
        moon.path.start(null, speed, FlxPath.LOOP_FORWARD);
        

        for(w in wayPointSprites){
            cast(w, FlxSprite).alpha = 0.3;
        }

        moonIsActive = true;
    }

    public function setPathWithStartingPoint(sprite:FlxSprite, nodes:Array<FlxPoint>){
        var startPointData = getClosestPointAndIndex(sprite.getMidpoint(), nodes);
        var nodesCopy = nodes.copy();
        var newPath = nodesCopy.splice(startPointData.index, nodesCopy.length).concat(nodesCopy);

        sprite.path = new FlxPath(newPath);

    }

    public function getClosestPointAndIndex(src:FlxPoint, pointList:Array<FlxPoint>):ClosestPointData{
        var closestPoint:FlxPoint = null;
        var minDist:Float = 0;
        var index:Int = 0;

        for(p in 0...pointList.length){
            var d = src.distanceTo(pointList[p]);
            if(closestPoint == null || d < minDist){
                closestPoint = pointList[p];
                index = p;
                minDist = d;
            }
        }

        return {point: closestPoint, index: index, dist: minDist};
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
}