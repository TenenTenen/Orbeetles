package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxState;

class SplashState extends FlxState{

    var splash:FlxSprite;

    var canGo = false;

    override function create() {
        super.create();
        FlxG.camera.antialiasing = true;

        splash = new FlxSprite().loadGraphic(AssetPaths.splash__png);
        add(splash);
        splash.screenCenter();

        FlxG.camera.fade(FlxColor.BLACK, 1.0, true, ()-> canGo = true);

    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if(FlxG.mouse.justPressed && canGo){
            GameData.g.reset();
            FlxG.camera.fade(FlxColor.BLACK, 1.0, false, ()-> FlxG.switchState(new PlayState()));
            
        }

    }
}