package model;

import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxPoint;
import sprite.Enemy;
import flixel.math.FlxVector;

class EnemyWaveSpawner {

    var spawnDist = 1100;

    var goal:FlxPoint;
    var enemyGroup:FlxTypedGroup<Enemy>;

    var waveData:Array<EnemyWave> = [];
    var currentWaveDataIndex:Int = 0;


    public function new(enemyGroup:FlxTypedGroup<Enemy>, goalPoint:FlxPoint) {
        this.goal = goalPoint;
        this.enemyGroup = enemyGroup;
    }

    public function startWave(waveData:Array<EnemyWave>){
        this.waveData = waveData;
        currentWaveDataIndex = 0;
        doWave();
    }

    function doWave(){
        var perEnemyDelay = waveData[currentWaveDataIndex].duration / waveData[currentWaveDataIndex].numEnemies;
        for(i in 0...waveData[currentWaveDataIndex].numEnemies){
            new FlxTimer().start(perEnemyDelay*i, (_)->{
                spawnEnemy();
            });
        }
        new FlxTimer().start(waveData[currentWaveDataIndex].duration, (_)->{
            waveData[currentWaveDataIndex].isComplete = true;
            currentWaveDataIndex++;
            if(currentWaveDataIndex < waveData.length){
                doWave();
            }
        });
    }

    public function isCompleted(){
        if(waveData.length > 0 && waveData[waveData.length-1].isComplete){
            return true;
        }
        return false;
    }


    public function spawnEnemy(){
		var v = FlxVector.get(1, 1);
		v.degrees = Random.float(0, 355);
		v.length = 1120;
		var e:Enemy = new Enemy(FlxPoint.get(goal.x+v.x, goal.y+v.y), goal);
		enemyGroup.add(e);
	}
    
}