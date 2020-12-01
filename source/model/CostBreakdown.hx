package model;

class CostBreakdown {
    
    public var moonType:MoonType;
    public var baseCost:Float;
    
    public var duplicateTax:Float;
    public var duplicateIndex:Int;

    public var distTax:Float;
    public var distIndex:Int;

    public var sameOrbitTax:Float;
    public var sameOrbitIndex:Int;

    public function new(){

    }

    public function totalCost(){
        return baseCost + duplicateTax + distTax + sameOrbitTax;
    }

    public function toString(){
        trace('base cost: [$baseCost]\ndistance tax: [$distIndex : $distTax]\nduplicate tax: [$duplicateIndex : $duplicateTax]\nco-orbit tax: [$sameOrbitIndex : $sameOrbitTax]');
    }


}