package sprite;

import sprite.Tooltip.ToolTip;
import sprite.Tooltip.ArrowDirection;
import model.CostBreakdown;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxRect;
import flixel.FlxSprite;

import flixel.addons.display.FlxSliceSprite;

class CostToolTip extends ToolTip{
    override public function new(cost:CostBreakdown, cam:FlxCamera, arrowDirection:ArrowDirection = ArrowDirection.BELOW) {
        super("", cam, arrowDirection);
    }

    public function padToChars(prefix:String, value:String, paddingChar:String) {
        var numChars = 18 - prefix.length;
        var creds = Std.string(value);
        while (creds.length < numChars){
            creds = paddingChar+creds;
        }
        return prefix+creds;
    }

    public function setCost(cost:CostBreakdown){
        var t = padToChars("Base Cost", "$"+cost.baseCost, ".");
        t += "\n" + padToChars("Distance Tax", "$"+cost.distTax, ".");
        t += "\n" + padToChars("Duplicate Tax", "$"+cost.duplicateTax, ".");
        t += "\n" + padToChars("Co-orbit Tax", "$"+cost.sameOrbitTax, ".");
        t += "\n" + "------------------";
        t += "\n" + padToChars("   Total", "$"+cost.totalCost(), ".");
        text.text = t;
        this.setSize(text.textField.textWidth + textPadding.x*2, text.textField.textHeight + textPadding.y*2);
    }
}