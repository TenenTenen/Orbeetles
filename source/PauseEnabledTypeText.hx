package;
import flixel.addons.text.FlxTypeText;
import flixel.FlxG;

/**
 * ...
 * @author Drew
 */
class PauseEnabledTypeText extends FlxTypeText
{

	public var delayModifierMap:Map<String, Float>;
	
	var charSpecificDelay:Float;
	
	private static var helperString:String = "";

	
	public function new(x:Float, y:Float, width:Int, text:String, size:Int = 8, embeddedFont:Bool=true, delayMap:Map<String, Float>=null) 
	{
		super(x, y, width, text, size, embeddedFont);
		if (delayMap == null){
			delayMap = new Map<String, Float>();
		}
		charSpecificDelay = delay;
		this.delayModifierMap = delayMap;
	}
	
	
	public override function update(elapsed:Float)
	{
		// If the skip key was pressed, complete the animation.
		#if FLX_KEYBOARD
		if (skipKeys != null && skipKeys.length > 0 && FlxG.keys.anyJustPressed(skipKeys))
		{
			skip();
		}
		#end
		
		if (_waiting && !paused)
		{
			_waitTimer -= elapsed;
			
			if (_waitTimer <= 0)
			{
				_waiting = false;
				_erasing = true;
			}
		}
		
		// So long as we should be animating, increment the timer by time elapsed.
		if (!_waiting && !paused)
		{
			if (_length < _finalText.length && _typing)
			{
				_timer += elapsed;
			}
			
			if (_length > 0 && _erasing)
			{
				_timer += elapsed;
			}
		}
		
		// If the timer value is higher than the rate at which we should be changing letters, increase or decrease desired string length.
		
		if (_typing || _erasing)
		{
						
			if (_typing && _timer >= charSpecificDelay)
			{
				_length += Std.int(_timer / charSpecificDelay);
				if (_length > _finalText.length)
					_length = _finalText.length;
			}
			
			if (_erasing && _timer >= eraseDelay)
			{
				_length -= Std.int(_timer / eraseDelay);
				if (_length < 0)
					_length = 0;
			}
			
			
			if ((_typing && _timer >= charSpecificDelay) || (_erasing && _timer >= eraseDelay))
			{
				var prevCharDelay = charSpecificDelay;
				charSpecificDelay = delay * getPercentChangeBasedOnDelay();
				if (_typingVariation)
				{
					
					if (_typing)
					{
						_timer = FlxG.random.float( -charSpecificDelay * _typeVarPercent / 2, charSpecificDelay * _typeVarPercent / 2);
					}
					else
					{
						_timer = FlxG.random.float( -eraseDelay * _typeVarPercent / 2, eraseDelay * _typeVarPercent / 2);
					}
				}
				else
				{
					_timer %= prevCharDelay;
				}
				
				if (sounds != null && !useDefaultSound)
				{
					if (!finishSounds)
					{
						for (sound in sounds)
						{
							sound.stop();
						}
					}
					
					FlxG.random.getObject(sounds).play(!finishSounds);
				}
				else if (useDefaultSound)
				{
					_sound.play(!finishSounds);
				}
			}
		}
		
		// Update the helper string with what could potentially be the new text.
		helperString = prefix + _finalText.substr(0, _length);
		
		// Append the cursor if needed.
		if (showCursor)
		{
			_cursorTimer += elapsed;
			
			// Prevent word wrapping because of cursor
			var isBreakLine = (prefix + _finalText).charAt(helperString.length) == "\n";
			
			if (_cursorTimer > cursorBlinkSpeed / 2 && !isBreakLine)
			{
				helperString += cursorCharacter.charAt(0);
			}
			
			if (_cursorTimer > cursorBlinkSpeed)
			{
				_cursorTimer = 0;
			}
		}
		
		// If the text changed, update it.
		if (helperString != text)
		{
			text = helperString;
			
			// If we're done typing, call the onComplete() function
			if (_length >= _finalText.length && _typing && !_waiting && !_erasing)
			{
				onComplete();
			}
			
			// If we're done erasing, call the onErased() function
			if (_length == 0 && _erasing && !_typing && !_waiting)
			{
				onErased();
			}
		}
		
		//super.update(elapsed);
	}
	
	private function getPercentChangeBasedOnDelay(){
		var char:String = _finalText.charAt(_length - 1);
		var percent:Float = delayModifierMap.get(char);
		
		if (percent == 0){
			percent = 1;
		}
		
		//html5 maps return null for keys without value, whereas desktop returns 0
		#if web
		if (percent == null){
			percent = 1;
		}
		#end
		
		//trace(char + " " + percent);
		return percent;
	}
	
}