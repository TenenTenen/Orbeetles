package sprite;

import sprite.Tooltip.ToolTip;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class ButtonPanel extends FlxTypedSpriteGroup<FlxSprite> {

    var panelBg:FlxSprite;

    var buttons:Array<PanelButton> = [];

    var uiCam:FlxCamera;

    var buttonStart:FlxPoint = FlxPoint.get(28, 22);
    var buttonSpacer:FlxPoint = FlxPoint.get(8, 8);

    public var helpText:ToolTip;
    var buyDescriptionText:ToolTip;

    var currentHoverButton:PanelButton = null;

    public function new(uiCam:FlxCamera) {
        super();
        this.uiCam = uiCam;
        this.cameras = [uiCam];
       
        panelBg = new FlxSprite();
        panelBg.loadGraphic(AssetPaths.buttonpanel__png);
        panelBg.x = FlxG.width - panelBg.width - 8;
        panelBg.y = FlxG.height - panelBg.height - 16;
        panelBg.camera = uiCam;

        add(panelBg);

        setHelpText("Add a moon by clicking on one of the\nbuttons in this panel! Click a moon\nto add weapons.");
        //setDescriptionText();

        loadButtons();

        
    }

    public function setHelpText(message:String){
        if(this.members.indexOf(helpText) != -1){
            this.remove(helpText);
        }

        helpText = new ToolTip(message, uiCam);
		helpText.setPositionByArrow(panelBg.x - 18, panelBg.y+panelBg.height - 48);
        add(helpText);
    }

    public function setDescriptionText(message:String){
        if(this.members.indexOf(buyDescriptionText) != -1){
            this.remove(buyDescriptionText);
        }

        buyDescriptionText = new ToolTip(message, uiCam, RIGHT);
		buyDescriptionText.setPositionByArrow(panelBg.x - 18, panelBg.y+panelBg.height - 375);
        add(buyDescriptionText);
    }

    public function loadButtons(satteliteMode:Bool = false, emptyMode:Bool = false){
        for(b in buttons){
            this.remove(b);
        }
        buttons = [];

        var currentRow = 0;
        var currentCol = 0;
        if(emptyMode){
            //dont add any buttons
        }else if(satteliteMode){
            var b = new PanelButton(MoonType.MISSILE, AssetPaths.button_turret_missle_up__png, AssetPaths.button_turret_missle_down__png);
            b.setPosition(panelBg.x + buttonStart.x, panelBg.y + buttonStart.y);
            buttons.push(b);
            add(b);

            currentCol++;

            b = new PanelButton(MoonType.LASER, AssetPaths.button_turret_beam_up__png, AssetPaths.button_turret_beam_down__png);
            b.setPosition(panelBg.x + buttonStart.x + currentCol*(b.width + buttonSpacer.x), panelBg.y + buttonStart.y + currentRow*(b.height + buttonSpacer.y));
            buttons.push(b);
            add(b);
        }else{
            var b = new PanelButton(MoonType.IRON, AssetPaths.button_moon_iron_up__png, AssetPaths.button_moon_iron_down__png);
            b.setPosition(panelBg.x + buttonStart.x, panelBg.y + buttonStart.y);
            buttons.push(b);
            add(b);

            currentCol++;

            b = new PanelButton(MoonType.FIRE, AssetPaths.button_moon_fire_up__png, AssetPaths.button_moon_fire_down__png);
            b.setPosition(panelBg.x + buttonStart.x + currentCol*(b.width + buttonSpacer.x), panelBg.y + buttonStart.y + currentRow*(b.height + buttonSpacer.y));
            buttons.push(b);
            add(b);

            currentRow++;
            currentCol = 0;

            b = new PanelButton(MoonType.ICE, AssetPaths.button_moon_ice_up__png, AssetPaths.button_moon_ice_down__png);
            b.setPosition(panelBg.x + buttonStart.x + currentCol*(b.width + buttonSpacer.x), panelBg.y + buttonStart.y + currentRow*(b.height + buttonSpacer.y));
            buttons.push(b);
            add(b);
        }
    }

    public function handleButtonsClick(onButtonDown:MoonType->Void = null, onButtonUp:MoonType->Void = null){
        for(b in buttons){
            if(b.getHitbox().containsPoint(FlxG.mouse.getPositionInCameraView(uiCam))){
                if(b.state == DOWN){
                    b.up();
                    FlxG.sound.play(AssetPaths.press_key__ogg, 0.8);
                }else{
                    allButtonsUp();
                    b.down();
                    onButtonDown(b.moonType);
                    FlxG.sound.play(AssetPaths.unpress_key__ogg, 0.8);
                }
            }
        }  
    }
    public function handleButtonsHover(){
        for(b in buttons){
            if(b.getHitbox().containsPoint(FlxG.mouse.getPositionInCameraView(uiCam))){
                if(currentHoverButton != b){
                    currentHoverButton = b;
                    setDescriptionText(getBuyDescriptionByType(b.moonType));
                }
                return;
            }
        }
        currentHoverButton = null;
        if(buyDescriptionText != null && this.members.indexOf(buyDescriptionText) != -1){
            remove(buyDescriptionText);
        }
        
    }

    public function allButtonsUp(){
        for(b in buttons){
            b.up();
        }
    }

    public function allButtonsDown(){
        for(b in buttons){
            b.down();
        }
    }

    private static function getBuyDescriptionByType(moonType:MoonType):String{
        switch(moonType){
            case PLANET:
                return "";
            case IRON:
                return "That's an Iron Moon.\nNothing special, but still\na solid choice.";
            case ICE:
                return "That's an Frost Moon. Brr!\nSo frigid that it moves a bit\nslower than other moons.";
            case FIRE:
                return "Woah! An Ember Moon!\nLeftover thermal energy\ncauses it to move faster\nthan any other moon!";
            case MISSILE:
                return "A Missile Turret.\nIt will aim and fire at the\nnearest enemy within range.";
            case LASER:
                return "Is that a Beam Repeater?\nThose shoot a powerful beam\ntowards the moon they orbit.";
            default:
                return "";
        }
    }
    
}