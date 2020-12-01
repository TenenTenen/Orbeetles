package model;

import sprite.Moon;

class Costs{

    // Each Moon or Satellite's base cost
    public var BASE_COST:Map<MoonType, Int>;

    // the tax per orbit-dist for moons. 
    // Each Key is an index into the possible orbit distances
    public var MOON_ORBIT_DIST_TAX:Array<Int>;

    // the tax per orbit-dist for sattelites. 
    // Each Key is an index into the possible orbit distances
    public var SATTELITE_ORBIT_DIST_TAX:Array<Int>;

    //cost per additional object of this type.
    public var DUPLICATE_TAX:Map<MoonType, Int>;
    
    //if moons share an orbit, the cost per moon goes up, this is the cost per distance by parent type
    public var MOON_CO_ORBIT_TAX:Array<Int>;
    public var SATELLITE_CO_ORBIT_TAX:Array<Int>;

    public static var data(get, null):Costs;
    static function get_data(){
        if(data == null) data = new Costs();
        return data;
    }

    private function new() {

        BASE_COST = new Map<MoonType, Int>();
        DUPLICATE_TAX = new Map<MoonType, Int>();

        MOON_ORBIT_DIST_TAX = [0, 25, 50, 100, 250, 500];
        MOON_ORBIT_DIST_TAX.reverse();
        SATTELITE_ORBIT_DIST_TAX = [0, 50, 100];
        SATTELITE_ORBIT_DIST_TAX.reverse();
        
        SATELLITE_CO_ORBIT_TAX = [1000, 500, 250, 0];
        SATELLITE_CO_ORBIT_TAX.reverse();
        MOON_CO_ORBIT_TAX = [3000, 1500, 750, 0];
        MOON_CO_ORBIT_TAX.reverse();

        Type.allEnums(MoonType).map(moonType -> {
            switch(moonType){
                case IRON: 
                    BASE_COST.set(moonType, 1000);
                    DUPLICATE_TAX.set(moonType, 50);
                case FIRE: 
                    BASE_COST.set(moonType, 1100);
                    DUPLICATE_TAX.set(moonType, 55);
                case ICE: 
                    BASE_COST.set(moonType, 900);
                    DUPLICATE_TAX.set(moonType, 45);
                case MISSILE:
                    BASE_COST.set(moonType, 200);
                    DUPLICATE_TAX.set(moonType, 10);
                case LASER:
                    BASE_COST.set(moonType, 300);
                    DUPLICATE_TAX.set(moonType, 15);
                case PLANET:
                    BASE_COST.set(moonType, 0);
                    DUPLICATE_TAX.set(moonType, 0);
            }
            return true;
        });

    }

    public function getCost(newMoon:Moon, allMoons:Array<Moon>, parentMoon:Moon):CostBreakdown{
        var useSateliteCost = [MoonType.MISSILE, MoonType.LASER].indexOf(newMoon.moonType) != -1;

        var c = new CostBreakdown();
        c.baseCost = BASE_COST.get(newMoon.moonType);

        c.duplicateIndex = allMoons.filter(moon -> moon != newMoon && moon.moonType == newMoon.moonType).length;
        c.duplicateTax = DUPLICATE_TAX.get(newMoon.moonType)*c.duplicateIndex;

        c.sameOrbitIndex = parentMoon.childMoons.filter(moon -> moon != newMoon && moon.parentMoon == newMoon.parentMoon && newMoon.orbitPath.orbitRadius == moon.orbitPath.orbitRadius).length;
        if(c.sameOrbitIndex >= (useSateliteCost ? SATELLITE_CO_ORBIT_TAX.length : MOON_CO_ORBIT_TAX.length)){
            var maxIndex = (useSateliteCost ? SATELLITE_CO_ORBIT_TAX.length-1 : MOON_CO_ORBIT_TAX.length-1);
            c.sameOrbitTax = useSateliteCost ? SATELLITE_CO_ORBIT_TAX[maxIndex] : MOON_CO_ORBIT_TAX[maxIndex];
        }else{
            c.sameOrbitTax = useSateliteCost ? SATELLITE_CO_ORBIT_TAX[c.sameOrbitIndex] : MOON_CO_ORBIT_TAX[c.sameOrbitIndex];
        }

        c.distIndex = parentMoon.getOrbitDistances().indexOf(Std.int(newMoon.orbitPath.orbitRadius));
        c.distTax = useSateliteCost ? SATTELITE_ORBIT_DIST_TAX[c.distIndex] : MOON_ORBIT_DIST_TAX[c.distIndex];
        
        return c;
    }

}