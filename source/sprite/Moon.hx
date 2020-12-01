package sprite;

import model.CostBreakdown;
import sprite.Tooltip.ToolTip;
import flixel.math.FlxVector;
import flixel.FlxG;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;


typedef ClosestPointData = {
    var point : FlxPoint;
    var index : Int;
    var dist : Float;
}

class Moon extends FlxSprite{

    //These are used if this moon is a child moon
    //it will move relative to the parent object in the same patrh the entagelement sprite moves relative to 0,0
    var entagledPathSprite:FlxSprite;
    public var parentMoon:Moon;

    public var speed:Float = 68;

    public var orbitPath:OrbitPath;
    var startingWaypoint:FlxPoint;

    public var isMoving = false;

    public var isEditing = true;
    public var baseScale:FlxPoint;

    public var moonType(default, null):MoonType;

    public var orbitDistFromSurface = 50;
    public var orbitStep = 50;
    public var numOrbits = 3;

    public var childMoons:Array<Moon> = [];

    public var costToolTip:CostToolTip;

    public var midpoint:FlxPoint;

    public function new(moonType:MoonType, orbitPath:OrbitPath, parentMoon:Moon = null){
        super();
        this.moonType = moonType;
        this.parentMoon = parentMoon;
        this.orbitPath = orbitPath;
        loadGraphic(AssetPaths.moon_iron__png, false, 0, 0, true);
        this.angle = Random.float(-180, 180);
        this.angularVelocity = -3.3;

        this.scale.set(0.95, 0.95);
        costToolTip = new CostToolTip(new CostBreakdown(), this.camera);

        if(moonType == PLANET){
            loadGraphic(AssetPaths.planet__png, false, 0, 0, true);
            this.angularVelocity = -2.3;
            costToolTip.visible = false;
            return;
        }

        if(moonType == FIRE){
            loadGraphic(AssetPaths.moon_fire__png, false, 0, 0, true);
            this.scale.set(0.75,0.75);
            this.speed *= 1.25;
        }else if(moonType == ICE){
            loadGraphic(AssetPaths.moon_ice__png, false, 0, 0, true);
            this.scale.set(1.15, 1.15);
            this.speed *= 0.75;
        }

        this.scale.x *= Random.float(0.92, 1.08);
        this.scale.y *= Random.float(0.92, 1.08);

        baseScale = FlxPoint.get(this.scale.x, this.scale.y);
        this.scale.x *= 1.15;
        this.scale.y *= 1.15;

        if(parentMoon.moonType != MoonType.PLANET){
            this.parentMoon = parentMoon;
            entagledPathSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
        }
        setPositionToClosestWaypoint();
        this.alpha = 0.75;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if(getMidpoint(midpoint).y < FlxG.camera.y + FlxG.camera.height/2){
            costToolTip.arrowDirection = ABOVE;
            var costLoc = getMidpoint(midpoint).add(0, 65);
            costToolTip.setPositionByArrow(costLoc.x, costLoc.y);
        }else{
            costToolTip.arrowDirection = BELOW;
            var costLoc = getMidpoint(midpoint).subtract(0, 65);
            costToolTip.setPositionByArrow(costLoc.x, costLoc.y);
        }
        

        if(moonType == PLANET){
            costToolTip.visible = false;
        }

        if(entagledPathSprite != null) {
            entagledPathSprite.update(elapsed);
        }

        if(isMoving){
            if(parentMoon.moonType != MoonType.PLANET){
                this.setPosition(parentMoon.x + parentMoon.width/2 + entagledPathSprite.x -this.width/2, parentMoon.y+parentMoon.height/2+entagledPathSprite.y-this.height/2);
            }
        }
    }

    public function updateCost(c:CostBreakdown){
        costToolTip.setCost(c);
    }

    override function draw() {
        super.draw();
    }

    public function donEditing(){
        this.isEditing = false;
        this.orbitPath.showCircle();
        this.scale.set(baseScale.x, baseScale.y);
        this.alpha = 1.0;
        costToolTip.visible = false;
    }

    public function setPositionToClosestWaypoint(){
        var closestWaypoint:FlxPoint;
        if(parentMoon.moonType == MoonType.PLANET){
            closestWaypoint = getClosestPointAndIndex(FlxG.mouse.getPosition(), orbitPath.waypoints).point;
            if(closestWaypoint == null){
                return;
            }
            this.setPosition(closestWaypoint.x-this.width/2, closestWaypoint.y - this.height/2);
        }else{
            var parentMoonCenter = parentMoon.getMidpoint();
            var offsetMouseCenter = FlxPoint.get(FlxG.mouse.x - parentMoonCenter.x, FlxG.mouse.y - parentMoonCenter.y);
            closestWaypoint = getClosestPointAndIndex(offsetMouseCenter, orbitPath.waypoints).point;
            if(closestWaypoint == null){
                parentMoonCenter.put();
                offsetMouseCenter.put();
                return;
            }
            entagledPathSprite.setPosition(closestWaypoint.x-entagledPathSprite.width/2, closestWaypoint.y - entagledPathSprite.height/2);
            this.setPosition(parentMoon.x + parentMoon.width/2 + entagledPathSprite.x -this.width/2, parentMoon.y+parentMoon.height/2+entagledPathSprite.y-this.height/2);
            parentMoonCenter.put();
            offsetMouseCenter.put();
        }

        startingWaypoint = closestWaypoint;
    }

    public function startMoon(){     
        orbitPath.computeActualPath();  
        if(parentMoon.moonType == MoonType.PLANET){
            setPathWithStartingPoint(this, orbitPath.actualPath);
            resetPositionToPathStart();
            trace(Type.getClassName(Type.getClass(this)), speed);
            this.path.start(null, speed, FlxPath.LOOP_FORWARD);
        }else{
            setPathWithStartingPoint(entagledPathSprite, orbitPath.actualPath);
            resetPositionToPathStart();
            trace(Type.getClassName(Type.getClass(this)), speed);
            entagledPathSprite.path.start(null, speed, FlxPath.LOOP_FORWARD);
        }       

        isMoving = true;
    }

    public function stopMoon(){     
        resetPositionToPathStart();
        isMoving = false;
    }

    public function resetPositionToPathStart(){
        if(parentMoon.moonType == MoonType.PLANET){
            this.path.cancel();
            setPosition(this.path.nodes[0].x-this.width/2, this.path.nodes[0].y - this.height/2);
        }else{
            entagledPathSprite.path.cancel();
            entagledPathSprite.setPosition(entagledPathSprite.path.nodes[0].x-entagledPathSprite.width/2, entagledPathSprite.path.nodes[0].y - entagledPathSprite.height/2);
            this.setPosition(parentMoon.x + parentMoon.width/2 + entagledPathSprite.x -this.width/2, parentMoon.y+parentMoon.height/2+entagledPathSprite.y-this.height/2);
        }
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

    public function getMinOrbitDist(){
        return this.width/2 + orbitDistFromSurface;
    }

    public function getMaxOrbitDist(){
        return getMinOrbitDist()+orbitStep*(numOrbits-1);
    }

    public function getOrbitDistances():Array<Int>{
        var dists:Array<Int> = [];
        for(i in 0...numOrbits){
            dists.push(Std.int(getMinOrbitDist() + orbitStep*i));
        }

        return dists;
    }
}