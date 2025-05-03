package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.display.waveform.FlxWaveform;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{
	var canvas:FlxSprite;
	var waveform:FlxWaveform;

	override public function create()
	{
		super.create();

		FlxG.sound.playMusic("assets/canvas4d mixshit 4.ogg");

		canvas = new FlxSprite(0, 100).makeGraphic(500, 500);
		add(canvas);

		waveform = new FlxWaveform(0, 200, 500, 200, FlxColor.BLACK, FlxColor.TRANSPARENT);
		waveform.loadDataFromFlxSound(FlxG.sound.music);
		waveform.waveformDuration = 5000;
		waveform.waveformGainMultiplier = 1.25;
		add(waveform);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.playing)
			waveform.waveformTime = FlxG.sound.music.time;
	}
}
