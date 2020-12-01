package;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxState;

class GameOverState extends FlxState{

    var gameOverText:FlxText;
    var clickText:FlxText;

    override function create() {
        super.create();
        FlxG.camera.antialiasing = true;

        gameOverText = new FlxText(0, 0, 0, "You ran out of credits", 20);
        gameOverText.setFormat(AssetPaths.monoMMM_5__ttf, 26, FlxColor.LIME, "center");
        add(gameOverText);
        gameOverText.screenCenter();
      
        clickText = new FlxText(0, 0, 0, "click to try again", 20);
        clickText.setFormat(AssetPaths.monoMMM_5__ttf, 18, FlxColor.LIME, "center");
        add(clickText);
        clickText.screenCenter();
        clickText.y += 25;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if(FlxG.mouse.justPressed){
            GameData.g.reset();
            FlxG.switchState(new PlayState());
        }

    }
}