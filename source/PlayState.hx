package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.waveform.FlxWaveform;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import openfl.filters.ShaderFilter;

class PlayState extends FlxState
{
	final COOL_COLOR_1:FlxColor = 0xFFFF65D9;

	var music:PreciseSound;
	var canvas:FlxSprite;
	var waveformCamera:FlxCamera;
	var waveform:FlxWaveform;
	var waveformLeft:FlxWaveform;
	var waveformRight:FlxWaveform;
	var hudCamera:FlxCamera;
	var dvdShadow:FlxSprite;
	var dvd:FlxSprite;
	var bar:FlxSprite;
	var curTime:FlxText;
	var remainingTime:FlxText;
	var conductor:Conductor;
	var coolScroll:FlxText;
	var overlay:FlxSprite;
	var pianoBoy:FlxSprite;
	var wiggleEffect:WiggleEffect;

	override public function create()
	{
		super.create();

		bgColor = 0xFF211225;

		FlxG.mouse.visible = false;
		FlxG.autoPause = false;
		FlxG.fixedTimestep = false;
		FlxG.updateFramerate = 180;
		FlxG.drawFramerate = 180;

		music = cast FlxG.sound.load("assets/canvas4d.wav");

		conductor = new Conductor(85);
		conductor.targetSound = music;
		add(conductor);

		// canvas = new FlxSprite(0, 100).makeGraphic(500, 500);
		// add(canvas);
		
		wiggleEffect = new WiggleEffect();
		wiggleEffect.effectType = FLAG;
		wiggleEffect.waveAmplitude = 0.08;
		wiggleEffect.waveFrequency = 0.2;
		wiggleEffect.waveSpeed = 0.8;
		var bgCamera = new FlxCamera();
		FlxG.cameras.add(bgCamera, false);
		bgCamera.filters = [new ShaderFilter(wiggleEffect.shader)];

		waveformCamera = new FlxCamera();
		waveformCamera.bgColor.alpha = 0;
		FlxG.cameras.add(waveformCamera, false);
		var circle = new CircleWarpShader();
		waveformCamera.filters = [new ShaderFilter(circle)];
		circle.bitmap.wrap = REPEAT;

		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;
		FlxG.cameras.add(hudCamera, true);

		// there's some weird fuckery if you apply the shader directly to the bg
		// the waveform circle will stop rendering entirely
		// I have no idea why and TBH im not gonna look into it
		var bg:FlxSprite = new FlxSprite().loadGraphic("assets/bg.png");
		bg.camera = bgCamera;
		bg.scale.set(1.3, 1.3);
		add(bg);

		dvdShadow = new FlxSprite().loadGraphic("assets/dvdShadow.png");
		dvdShadow.alpha = 0;
		dvdShadow.screenCenter();
		add(dvdShadow);

		dvd = new FlxSprite().loadGraphic("assets/dvd2.png");
		dvd.screenCenter();
		add(dvd);

		curTime = new FlxText(5, 5, 0, "8:88", 16);
		curTime.color = COOL_COLOR_1;
		curTime.camera = hudCamera;
		add(curTime);

		remainingTime = new FlxText(0, 5, 0, "8:88", 16);
		remainingTime.color = COOL_COLOR_1;
		remainingTime.alignment = RIGHT;
		remainingTime.camera = hudCamera;
		add(remainingTime);

		var halfHeightText:Int = Std.int(curTime.height);
		var barWidth:Int = Std.int(FlxG.width - curTime.width - remainingTime.width - 20);
		bar = new FlxSprite(curTime.x + 5, 5 + Std.int(halfHeightText / 4)).makeGraphic(barWidth, halfHeightText, COOL_COLOR_1);
		bar.screenCenter(X);
		bar.clipRect = FlxRect.get(0, 0, 0, 10);
		bar.camera = hudCamera;
		add(bar);

		waveform = new FlxWaveform(0, 0, FlxG.width, FlxG.height, COOL_COLOR_1, FlxColor.TRANSPARENT);
		waveform.loadDataFromFlxSound(music);
		waveform.waveformDuration = 100;
		waveform.waveformGainMultiplier = 1.7;
		waveform.waveformDrawBaseline = true;
		// waveform.waveformDrawMode = SPLIT_CHANNELS;
		waveform.camera = waveformCamera;
		add(waveform);

		var waveformPadding:Int = Std.int(curTime.y + curTime.height + 5);
		var waveformPadding2:Int = waveformPadding * 2;

		waveformLeft = new FlxWaveform(0, waveformPadding, 30, FlxG.height - waveformPadding2, COOL_COLOR_1, FlxColor.TRANSPARENT);
		waveformLeft.loadDataFromFlxWaveformBuffer(waveform.waveformBuffer);
		waveformLeft.waveformDuration = 1000;
		waveformLeft.waveformGainMultiplier = 1.5;
		waveformLeft.waveformOrientation = VERTICAL;
		waveformLeft.waveformDrawMode = SINGLE_CHANNEL(0);
		waveformLeft.waveformDrawBaseline = true;
		add(waveformLeft);

		waveformRight = new FlxWaveform(FlxG.width - 30, waveformPadding, 30, FlxG.height - waveformPadding2, COOL_COLOR_1, FlxColor.TRANSPARENT);
		waveformRight.loadDataFromFlxWaveformBuffer(waveform.waveformBuffer);
		waveformRight.waveformDuration = 1000;
		waveformRight.waveformGainMultiplier = 1.5;
		waveformRight.waveformOrientation = VERTICAL;
		waveformRight.waveformDrawMode = SINGLE_CHANNEL(1);
		waveformRight.waveformDrawBaseline = true;
		add(waveformRight);

		coolScroll = new FlxText(0, 0, 0, "A Crazy Town - canvas4d");
		coolScroll.y = FlxG.height - coolScroll.height - 8;
		coolScroll.x = -coolScroll.width;
		coolScroll.color = COOL_COLOR_1;
		add(coolScroll);

		overlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		overlay.alpha = 1;
		add(overlay);

		pianoBoy = new FlxSprite();
		pianoBoy.frames = FlxAtlasFrames.fromSparrow("assets/piano.png", "assets/piano.xml");
		pianoBoy.animation.addByIndices("idle", "funny play", [1], "", 24);
		pianoBoy.animation.addByIndices("play", "funny play", [2, 3, 4, 5, 6, 7], "", 24, false);
		pianoBoy.animation.play("idle");
		pianoBoy.y = FlxG.height + pianoBoy.height;
		pianoBoy.screenCenter(X);
		add(pianoBoy);

		conductor.onBeatHit.add((beat:Int) ->
		{
			if (beat >= 8 && beat != 15)
			{
				if (beat >= 48 && beat <= 64)
					return;

				FlxTween.cancelTweensOf(dvd);
				dvd.scale.set(1.075, 1.075);
				FlxTween.tween(dvd, {"scale.x": 1, "scale.y": 1}, conductor.beatLength / 1000, {ease: FlxEase.sineOut});
			}

			if (beat == 32)
			{
				FlxTween.tween(pianoBoy, {y: FlxG.height - pianoBoy.height + 30}, (conductor.beatLength * 16) / 1000, {
					ease: FlxEase.quadOut,
					onComplete: (t:FlxTween) ->
					{
						pianoBoy.animation.play("play");
					}
				});
			}
		});

		// don't ask
		var stepsToPlay:Array<Int> = [4, 7, 9, 11, 15, 31, 33, 36, 37, 39, 47, 59, 63];
		for (i in 0...stepsToPlay.length)
			stepsToPlay[i] += 191;

		// trace(stepsToPlay);

		// dog manager
		var triggerLight:Bool = false;
		var gettingRidOfTheDogCauseWeDontWantYouAnymore:Bool = false;
		var light:FlxSprite = new FlxSprite(0, -20).loadGraphic("assets/light.png");
		light.screenCenter(X);
		light.blend = ADD;
		light.alpha = 0;
		add(light);

		conductor.onStepHit.add((step:Int) ->
		{
			if (conductor.curBeat >= 48 && conductor.curBeat <= 64)
			{
				if (!triggerLight)
				{
					overlay.alpha = 0.8;
					light.alpha = 0.6;
					triggerLight = true;
				}

				// if (step == 204)
				// {
				// 	pianoBoy.animation.play("idle", true);
				// }

				if (stepsToPlay[0] == step)
				{
					stepsToPlay.shift();
					pianoBoy.animation.play("play", true);

					if (stepsToPlay.length == 0 && !gettingRidOfTheDogCauseWeDontWantYouAnymore)
					{
						overlay.alpha = 0;
						light.alpha = 0;
						// pianoBoy.animation.play("idle", true);
		
						FlxTween.tween(pianoBoy, {y: FlxG.height + pianoBoy.height}, conductor.beatLength / 1000,
							{startDelay: conductor.beatLength / 1000, ease: FlxEase.quadIn});
						gettingRidOfTheDogCauseWeDontWantYouAnymore = true;
					}
				}
			}
		});

		// Hide everything and show it when we do intro
		curTime.alpha = 0;
		remainingTime.alpha = 0;
		bar.alpha = 0;
		dvd.alpha = 0;
		waveform.alpha = 0;
		waveformLeft.alpha = 0;
		waveformRight.alpha = 0;
		music.onComplete = playOutro;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.watch.addQuick("beat", conductor.curBeat);
		FlxG.watch.addQuick("step", conductor.curStep);

		if (doneIntro)
		{
			if (music.playing)
			{
				waveform.waveformTime = music.position;
				waveformLeft.waveformTime = music.position;
				waveformRight.waveformTime = music.position;

				bar.clipRect.width = (music.position / music.length) * bar.width;

				curTime.text = FlxStringUtil.formatTime(music.position / 1000, false);
				remainingTime.text = FlxStringUtil.formatTime((music.length - music.position) / 1000, false);
				remainingTime.x = FlxG.width - remainingTime.width - 5;
				coolScroll.x += elapsed * 20;
				if (coolScroll.x > (FlxG.width + coolScroll.width))
					coolScroll.x = -coolScroll.width;
			}
		}
		else
		{
			if (FlxG.keys.justPressed.SPACE && !inIntro)
			{
				playIntro();
			}
		}
		dvd.angle += (conductor.beatLength / 1000) * elapsed * 20;

		wiggleEffect.update(elapsed);
	}

	var inIntro:Bool = false;
	var doneIntro:Bool = false;

	function playIntro():Void
	{
		inIntro = true;

		overlay.alpha = 1;
		dvd.alpha = 1;
		FlxTween.tween(overlay, {alpha: 0}, 1);

		curTime.text = FlxStringUtil.formatTime(music.position / 1000, false);
		remainingTime.text = FlxStringUtil.formatTime((music.length - music.position) / 1000, false);
		remainingTime.x = FlxG.width - remainingTime.width - 5;

		FlxTimer.wait(2, () ->
		{
			music.play();
			doneIntro = true;

			FlxTween.tween(dvdShadow, {alpha: 0.7}, 1);
			FlxTween.tween(curTime, {alpha: 1}, 1);
			FlxTween.tween(remainingTime, {alpha: 1}, 1);
			FlxTween.tween(bar, {alpha: 1}, 1);

			FlxTween.tween(waveform, {alpha: 1}, 1);
			FlxTween.tween(waveformLeft, {alpha: 1}, 1);
			FlxTween.tween(waveformRight, {alpha: 1}, 1);
		});
	}
	function playOutro():Void
	{
		FlxTween.tween(dvdShadow, {alpha: 0}, 1);
		FlxTween.tween(curTime, {alpha: 0}, 1);
		FlxTween.tween(remainingTime, {alpha: 0}, 1);
		FlxTween.tween(bar, {alpha: 0}, 1);

		FlxTween.tween(waveform, {alpha: 0}, 1);
		FlxTween.tween(waveformLeft, {alpha: 0}, 1);
		FlxTween.tween(waveformRight, {alpha: 0}, 1);

		// curTime.text = FlxStringUtil.formatTime(music.position / 1000, false);
		// remainingTime.text = FlxStringUtil.formatTime((music.length - music.position) / 1000, false);
		// remainingTime.x = FlxG.width - remainingTime.width - 5;

		FlxTimer.wait(2, () ->
		{
			FlxTween.tween(overlay, {alpha: 1}, 1);
		});
	}
}
