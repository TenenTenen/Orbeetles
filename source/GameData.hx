package;

import sprite.Moon;

class GameData{

    public var playerCredits:Int = 5500;
    public var salary:Int = 2000;
    public var dayIndex:Int = 0;

    public static var g(get, null):GameData;
    static function get_g(){
        if(g == null) g = new GameData();
        return g;
    }

    private function new() {
    }

    public function reset(){
        dayIndex = 0;
        playerCredits = 5500;
    }

}