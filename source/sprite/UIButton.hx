package sprite;

import flixel.FlxSprite;

enum ButtonState{
    UP;
    DOWN;
}

class UIButton extends FlxSprite{
    

    var upStatePath:String;
    var downStatePath:String;

    var travelDist = 3;

    public var state(default, null):ButtonState = UP;

    public function new(upPath:String, downPath:String) {
        super();
        this.upStatePath = upPath;
        this.downStatePath = downPath;
        this.loadGraphic(upStatePath);
    }

    public function down(){
        if(state == DOWN) return;
        this.state = DOWN;
        this.loadGraphic(downStatePath);
        this.y += travelDist;
    }

    public function up(){
        if(state == UP) return;
        this.state = UP;
        this.loadGraphic(upStatePath);
        this.y -= travelDist;
    }
}