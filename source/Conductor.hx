package;

import lime.media.AudioBuffer;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.sound.FlxSound;
import flixel.FlxBasic;

class Conductor extends FlxBasic
{
    public var bpm(default, set):Float;

    /**
     * The length of one measure in miliseconds.
     */
    public var measureLength(default, null):Float;

    /**
     * The length of one beat in miliseconds.
     */
    public var beatLength(default, null):Float;

    /**
     * The length of one step in miliseconds.
     */
    public var stepLength(default, null):Float;

    /**
     * The time of `targetSound` directly from the audio engine, with applied offsets.
     */
    public var soundTimeRaw(get, null):Float;

    /**
     * The interpolate current time of `targetSound`, with applied offsets.
     * 
     * Due to imprecisions with the audio engine, the sound time can only update every 20±1ms. If the sound time does not update with a new frame, the current frame delta time will be added to the time.
     */
    public var soundTime(default, null):Float;

    /**
     * Top part of the time signature
     */
    public var beatsPerMeasure:Int = 4;

    /**
     * Bottom part of the time signature
     */
    public var stepsPerBeat:Int = 4;

    public var curBeat(default, null):Int;
    public var totalBeats(default, null):Int;
    public var onBeatHit:FlxTypedSignal<Int->Void>;

    public var curStep(default, null):Int;
    public var totalSteps(default, null):Int;
    public var onStepHit:FlxTypedSignal<Int->Void>;

    public var curMeasure(default, null):Int;
    public var totalMeasures(default, null):Int;
    public var onMeasureHit:FlxTypedSignal<Int->Void>;

    public var targetSound(default, set):PreciseSound;

    public var positionOffset:Float = 0.0;
    private var formatOffset:Float = 0;

    public function new(bpm:Float, ?beatsPerMeasure:Int = 4, ?stepsPerBeat:Int = 4)
    {
        super();

        this.beatsPerMeasure = beatsPerMeasure;
        this.stepsPerBeat = stepsPerBeat;
        this.bpm = bpm;

        curStep = -1;
        curBeat = -1;
        curMeasure = -1;

        onBeatHit = new FlxTypedSignal<Int->Void>();
        onStepHit = new FlxTypedSignal<Int->Void>();
        onMeasureHit = new FlxTypedSignal<Int->Void>();
    }

    var oldStep:Int = -1;
    var oldBeat:Int = -1;
    var oldMeasure:Int = -1;

    var prevSoundTimeRaw:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (targetSound != null)
        {
            var time:Float = soundTimeRaw;
            if (prevSoundTimeRaw == time)
                time += elapsed * 1000;
                
            prevSoundTimeRaw = soundTimeRaw;

            soundTime = time - positionOffset - formatOffset;
            var stepTime:Float = soundTime / stepLength;

            oldStep = curStep;
            oldBeat = curBeat;
            oldMeasure = curMeasure;

            curStep = Math.floor(stepTime);
            curBeat = Math.floor(stepTime / beatsPerMeasure);
            curMeasure = Math.floor(curBeat / beatsPerMeasure);

            if (oldStep != curStep)
                onStepHit.dispatch(curStep);
            if (oldBeat != curBeat)
                onBeatHit.dispatch(curBeat);
            if (oldMeasure != curMeasure)
                onMeasureHit.dispatch(curMeasure);
        }

        FlxG.watch.addQuick("soundTimeRaw", soundTimeRaw);
        FlxG.watch.addQuick("soundTime", soundTime);
        FlxG.watch.addQuick("soundTimeDiff", soundTime - soundTimeRaw);
        FlxG.watch.addQuick("positionOffset", positionOffset);
        FlxG.watch.addQuick("formatOffset", formatOffset);
    }

    /**
     * Returns the step at the specified time
     * @param time The time
     * @return Step
     */
    public function getStepFromTime(time:Float):Int
    {
        return Math.floor(time / stepLength);
    }

    /**
     * Returns the beat at the specified time
     * @param time The time
     * @return Beat
     */
    public function getBeatFromTime(time:Float):Int
    {
        return Math.floor(time / beatLength);
    }

    /**
     * Returns the measure at the specified time
     * @param time The time
     * @return Measure
     */
    public function getMeasureFromTime(time:Float):Int
    {
        return Math.floor(time / measureLength);
    }

    /**
     * Returns the time in miliseconds of specified `beat`
     * @param beat Beat
     * @return Time in miliseconds
     */
    public function getTimeFromBeat(beat:Int):Float
    {
        return beat * beatLength;
    }

    /**
     * Returns the time in miliseconds of specified `step`
     * @param step Step
     * @return Time in miliseconds
     */
    public function getTimeFromStep(step:Int):Float
    {
        return step * stepLength;
    }

    /**
     * Returns the time in miliseconds of specified `measure`
     * @param measure Measure
     * @return Time in miliseconds
     */
    public function getTimeFromMeasure(measure:Int):Float
    {
        return measure * measureLength;
    }

    public function parseStringTime(data:String):Float
    {
        return 0;
    }

    @:noCompletion inline function get_soundTimeRaw():Float 
    {
        return (targetSound?.position ?? 0) - positionOffset - formatOffset;
    }

    @:noCompletion private function set_bpm(value:Float):Float
    {
        beatLength = (60 / value) * 1000;
        stepLength = beatLength / stepsPerBeat;
        measureLength = beatLength * beatsPerMeasure;
        return bpm = value;
    }

    @:noCompletion private function set_targetSound(value:PreciseSound):PreciseSound
    {
        totalBeats = Math.floor(value.length / beatLength);
        totalSteps = Math.floor(value.length / stepLength);
        totalMeasures = Math.ceil(value.length / measureLength);

        #if web
        if (value != null)
        {
            @:privateAccess
            var buffer:AudioBuffer = value?._channel?.__audioSource?.buffer;

            if (buffer == null)
            {
                @:privateAccess
                buffer = value?._sound?.__buffer;
            }

            //@:privateAccess

            formatOffset = 528 / buffer.sampleRate * 1000;
        }
        #end

        return targetSound = value;
    }	
}
