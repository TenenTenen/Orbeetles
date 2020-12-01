package sprite;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import sprite.Tooltip.ToolTip;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxCamera;

class DayCounter extends FlxTypedSpriteGroup<FlxSprite> {

    var panelBg:FlxSprite;

    var buttons:Array<PanelButton> = [];

    var uiCam:FlxCamera;

    var buttonStart:FlxPoint = FlxPoint.get(28, 22);

    var helpText:ToolTip;

    var currentHoverButton:UIButton = null;

    var credits:FlxText;
    var dayOnes:FlxText;
    var dayTens:FlxText;
    var dayHundreds:FlxText;

    public var readyButton(default, null):UIButton;

    public function new(uiCam:FlxCamera) {
        super();
        this.uiCam = uiCam;
        this.cameras = [uiCam];
       
        panelBg = new FlxSprite();
        panelBg.loadGraphic(AssetPaths.daytab__png);
        panelBg.x = 10;
        panelBg.y = FlxG.height - panelBg.height - 16;
        panelBg.camera = uiCam;

        add(panelBg);

        credits = new FlxText(0, 0, 218, "cccccc", 20);
        credits.setFormat(AssetPaths.monoMMM_5__ttf, 24, FlxColor.LIME, "center");
        credits.x = panelBg.x + panelBg.width/2  - credits.fieldWidth/2;
        credits.y = panelBg.y + 50;
        credits.cameras = [uiCam];
        add(credits);

        dayOnes = new FlxText(0, 0, 0, "0", 20);
        dayOnes.setFormat(AssetPaths.monoMMM_5__ttf, 24, FlxColor.BLACK, "center");
        dayOnes.x = panelBg.x + panelBg.width/2 - 59;
        dayOnes.y = panelBg.y + 202;
        dayOnes.cameras = [uiCam];
        add(dayOnes);

        dayTens = new FlxText(0, 0, 0, "0", 20);
        dayTens.setFormat(AssetPaths.monoMMM_5__ttf, 24, FlxColor.BLACK, "center");
        dayTens.x = panelBg.x + panelBg.width/2 - 59 - 27;
        dayTens.y = panelBg.y + 202;
        dayTens.cameras = [uiCam];
        add(dayTens);

        dayHundreds = new FlxText(0, 0, 0, "0", 20);
        dayHundreds.setFormat(AssetPaths.monoMMM_5__ttf, 24, FlxColor.BLACK, "center");
        dayHundreds.x = panelBg.x + panelBg.width/2 - 59 - 27 -27;
        dayHundreds.y = panelBg.y + 202;
        dayHundreds.cameras = [uiCam];
        add(dayHundreds);

        readyButton = new UIButton(AssetPaths.button_ready_up__png, AssetPaths.button_ready_down__png);
        add(readyButton);
        readyButton.x = panelBg.x + 197;
        readyButton.y = panelBg.y + 152;

        //setHelpText("Add a moon by clicking on one of\nthe buttons in this panel!");
        
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        setCreditsText(Math.floor(GameData.g.playerCredits));

        var days = Std.string(GameData.g.dayIndex);
        while(days.length < 3){
            days = "0"+days;
        }
        dayHundreds.text = days.charAt(0);
        dayTens.text = days.charAt(1);
        dayOnes.text = days.charAt(2);
    }

    public function handleButtonsClick(onButtonDown:Void->Void = null, onButtonUp:Void->Void = null){
        var b = readyButton;
        if(b.getHitbox().containsPoint(FlxG.mouse.getPositionInCameraView(uiCam))){
            if(b.state == DOWN){
                b.up();
                FlxG.sound.play(AssetPaths.press_key__ogg, 0.8);
            }else{
                b.down();
                onButtonDown();
                FlxG.sound.play(AssetPaths.unpress_key__ogg, 0.8);
            }
        }
    }

    public function handleButtonsHover(){
        var b = readyButton;
        if(b.getHitbox().containsPoint(FlxG.mouse.getPositionInCameraView(uiCam))){
            if(currentHoverButton != b){
                currentHoverButton = b;
            }
            return;
        }
    }

    public function setCreditsText(newVal:Int) {
        var numChars = 9;
        var creds = "$" + Std.string(newVal);
        while (creds.length < numChars){
            creds = "."+creds;
        }

        credits.text = "Crd:"+creds;

    }
}