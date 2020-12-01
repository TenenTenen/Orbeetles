package sprite;

import model.Costs;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;

class PanelButton extends UIButton{
    
    public var moonType(default, null):MoonType;

    public var costLabel:FlxText;

    public function new(moonType:MoonType, upPath:String, downPath:String) {
        super(upPath, downPath);
        this.moonType = moonType;

        costLabel = new FlxText(0, 0, 218, "$"+Std.string(Costs.data.BASE_COST.get(moonType)), 20);
        costLabel.setFormat(AssetPaths.goodbylullaby__ttf, 19, FlxColor.BROWN.getDarkened(0.4), "center");
        costLabel.x = this.x + this.width/2  - costLabel.fieldWidth/2;
        costLabel.y = this.y + 64;
        costLabel.angle = 1;
       
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        costLabel.update(elapsed);

        if(costLabel.cameras != this.cameras){
            costLabel.cameras = this.cameras;
        }

        costLabel.x = this.x + this.width/2  - costLabel.fieldWidth/2;
        costLabel.y = this.y + 64;

    }

    override function draw() {
        super.draw();
        costLabel.draw();
    }
}