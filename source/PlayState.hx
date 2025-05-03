package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.waveform.FlxWaveform;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import openfl.filters.ShaderFilter;

class PlayState extends FlxState
{
	var music:PreciseSound;
	var canvas:FlxSprite;
	var waveformCamera:FlxCamera;
	var waveform:FlxWaveform;

	var hudCamera:FlxCamera;

	var dvd:FlxSprite;

	var bar:FlxSprite;
	var curTime:FlxText;
	var remainingTime:FlxText;

	var conductor:Conductor;

	override public function create()
	{
		super.create();

		bgColor = 0xFF000000;

		FlxG.updateFramerate = 60;
		FlxG.drawFramerate = 60;

		music = cast FlxG.sound.load("assets/canvas4d mixshit 4.ogg");
		music.play();

		conductor = new Conductor(85);
		conductor.targetSound = music;
		add(conductor);

		// canvas = new FlxSprite(0, 100).makeGraphic(500, 500);
		// add(canvas);

		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;
		FlxG.cameras.add(hudCamera, false);

		dvd = new FlxSprite().loadGraphic("assets/dvd2.png");
		dvd.screenCenter();
		add(dvd);

		curTime = new FlxText(5, 5, 0, "8:88", 16);
		curTime.camera = hudCamera;
		add(curTime);

		remainingTime = new FlxText(0, 5, 0, "8:88", 16);
		remainingTime.alignment = RIGHT;
		remainingTime.camera = hudCamera;
		add(remainingTime);

		var halfHeightText:Int = Std.int(curTime.height);
		var barWidth:Int = Std.int(FlxG.width - curTime.width - remainingTime.width - 20);
		bar = new FlxSprite(curTime.x + 5, 5 + Std.int(halfHeightText / 4)).makeGraphic(barWidth, halfHeightText);
		bar.screenCenter(X);
		bar.clipRect = FlxRect.get(0, 0, 0, 10);
		bar.camera = hudCamera;
		add(bar);

		waveform = new FlxWaveform(0, 0, FlxG.width, FlxG.height, FlxColor.WHITE, FlxColor.TRANSPARENT);
		waveform.loadDataFromFlxSound(music);
		waveform.waveformDuration = 100;
		waveform.waveformGainMultiplier = 2;
		// waveform.waveformDrawBaseline = true;
		// waveform.waveformDrawMode = SPLIT_CHANNELS;
		add(waveform);

		waveformCamera = new FlxCamera();
		waveformCamera.bgColor.alpha = 0;
		FlxG.cameras.add(waveformCamera, false);
		waveform.camera = waveformCamera;

		var circle = new CircleWarpShader();
		waveformCamera.filters = [new ShaderFilter(circle)];
		circle.bitmap.wrap = REPEAT;

		// conductor.onStepHit.add(colorBlockStep);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (music.playing)
		{
			waveform.waveformTime = music.position;
			bar.clipRect.width = (music.position / music.length) * FlxG.width;

			curTime.text = FlxStringUtil.formatTime(music.position / 1000, false);
			remainingTime.text = FlxStringUtil.formatTime((music.length - music.position) / 1000, false);
			remainingTime.x = FlxG.width - remainingTime.width - 5;
		}

		dvd.angle += conductor.beatLength / 1000;
	}
}
