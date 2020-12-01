package model;

class EnemyWave {
    
    public var numEnemies:Int;
    public var duration:Float;

    public var isComplete:Bool = false;

    public function new(numEnemies:Int, duration:Float) {
        this.numEnemies = numEnemies;
        this.duration = duration;
    }


}