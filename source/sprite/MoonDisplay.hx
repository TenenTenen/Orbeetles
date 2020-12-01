package sprite;

import flixel.util.FlxColor;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxTimer;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class MoonDisplay extends FlxTypedSpriteGroup<FlxSprite> {

    var panelBg:FlxSprite;

    var selectedBodySprite:FlxSprite;
    var selectedBodySpriteEffect:FlxSprite;

    var moonTypeText:FlxTypeText;

    var uiCam:FlxCamera;

    //var contentStart:FlxPoint = FlxPoint.get(0, 0);

    var selectedMoon:Moon;

    var glitch:FlxGlitchEffect;

    public function new(uiCam:FlxCamera) {
        super();
        this.uiCam = uiCam;
        this.cameras = [uiCam];
       
        panelBg = new FlxSprite();
        panelBg.loadGraphic(AssetPaths.mainscreen__png);
        panelBg.x = FlxG.width - panelBg.width + 15;
        panelBg.y = 160;
        panelBg.camera = uiCam;

        glitch = new FlxGlitchEffect(4, 2, 0.05, FlxGlitchDirection.HORIZONTAL);

        selectedBodySprite = new FlxSprite();
        selectedBodySprite.loadGraphic(AssetPaths.highlight_planet__png);
        selectedBodySpriteEffect = new FlxEffectSprite(selectedBodySprite, [glitch]);
        selectedBodySpriteEffect.x = panelBg.x + panelBg.width*0.59 - selectedBodySprite.width/2;
        selectedBodySpriteEffect.y = panelBg.y+120;

        moonTypeText = new FlxTypeText(0, 0, 188, "", 20, true);
        moonTypeText.setFormat(AssetPaths.novem_____ttf, 24, FlxColor.LIME, "center");
        moonTypeText.x = selectedBodySpriteEffect.x + selectedBodySprite.width/2 - moonTypeText.textField.width/2;
        moonTypeText.y = selectedBodySpriteEffect.y - 33;
        
        add(panelBg);
        add(selectedBodySpriteEffect);
        add(moonTypeText);

        resetGlitch();
    }

    public function updateMoon(moon:Moon){
        selectedMoon = moon;
        selectedBodySprite.loadGraphic(getDisplaySpritePath(moon.moonType));
        
        moonTypeText.resetText(getDisplayName(moon.moonType));
        moonTypeText.start();
    }

    private function doGlitch(t:FlxTimer = null){
        glitch.active = true;
        new FlxTimer().start(Random.float(0.2, 0.7), resetGlitch);
    }

    private function resetGlitch(t:FlxTimer = null){
        glitch.active = false;
        new FlxTimer().start(Random.float(1, 5), doGlitch);
    }


    override function update(elapsed:Float) {
        super.update(elapsed);
    }


    private static function getDisplayName(moonType:MoonType):String{
        switch(moonType){
            case PLANET:
                return "Home Planet";
            case IRON:
                return "Iron Moon";
            case ICE:
                return "Frost Moon";
            case FIRE:
                return "Ember Moon";
            case MISSILE:
                return "Missile Turret";
            case LASER:
                return "Beam Repeater";
            default:
                return "Untranslatable";
        }
    }

    private static function getDisplaySpritePath(moonType:MoonType):String{
        switch(moonType){
            case PLANET:
                return AssetPaths.highlight_planet__png;
            case IRON:
                return AssetPaths.highlight_moon_iron__png;
            case ICE:
                return AssetPaths.highlight_moon_ice__png;
            case FIRE:
                return AssetPaths.highlight_moon_fire__png;
            case MISSILE:
                return AssetPaths.highlight_turret_missle__png;
            case LASER:
                return AssetPaths.highlight_turret_beam__png;
            default:
                return "";
        }
    }

    
}