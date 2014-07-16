package flixel.animation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRandom;

@:generic @:remove
class FlxAnimation<K> extends FlxBaseAnimation<K>
{
	/**
	 * Animation frameRate - the speed in frames per second that the animation should play at.
	 */
	public var frameRate(default, set):Int;
	
	/**
	 * Keeps track of the current frame of animation.
	 * This is NOT an index into the tile sheet, but the frame number in the animation object.
	 */
	public var currentFrame(default, set):Int = 0;
	
	/**
	 * Accessor for frames.length
	 */
	public var totalFrames(get, null):Int;
	
	/**
	 * Seconds between frames (basically the framerate)
	 */
	public var delay(default, null):Float = 0;
	
	/**
	 * Whether the current animation has finished.
	 */
	public var finished:Bool = true;
	
	/**
	 * Whether the current animation gets updated or not.
	 */
	public var paused:Bool = true;
	
	/**
	 * Whether or not the animation is looped
	 */
	public var looped:Bool = true;
	
	
	/**
	 * A list of frames stored as int objects
	 */
	@:allow(flixel.animation)
	public var frames(default, null):Array<Int>;
	
	/**
	 * Internal, used to time each frame of animation.
	 */
	private var _frameTimer:Float = 0;
	
	/**
	 * @param	Name		What this animation should be called (e.g. "run")
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3)
	 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40)
	 * @param	Looped		Whether or not the animation is looped or just plays once
	 */
	public function new(parent:FlxAnimationController<K>, key:K, frames:Array<Int>, frameRate:Int = 0, looped:Bool = true)
	{
		super(parent, key);
		
		this.frameRate = frameRate;
		this.frames = frames;
		this.looped = looped;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		frames = null;
		key = null;
		super.destroy();
	}
	
	public function play(force:Bool = false, frame:Int = 0):Void
	{
		if (!force && (looped || !finished))
		{
			paused = false;
			finished = false;
			//set_currentFrame(currentFrame);
			return;
		}
		
		paused = false;
		_frameTimer = 0;
		
		if ((delay <= 0) || (frame == (totalFrames - 1)))
		{
			finished = true;
		}
		else
		{
			finished = false;
		}
		
		currentFrame = frame;
	}
	
	public function restart():Void
	{
		play(true);
	}
	
	public function stop():Void
	{
		finished = true;
		paused = true;
	}
	
	override public function update():Void
	{
		if (delay > 0 && (looped || !finished) && !paused)
		{
			_frameTimer += FlxG.elapsed;
			while (_frameTimer > delay)
			{
				_frameTimer = _frameTimer - delay;
				if (looped && (currentFrame == totalFrames - 1))
				{
					currentFrame = 0;
				}
				else
				{
					currentFrame++;
				}
			}
		}
	}
	
	override public function clone(parent:FlxAnimationController<K>):FlxAnimation<K>
	{
		return new FlxAnimation<K>(parent, key, frames, frameRate, looped);
	}
	
	private function set_frameRate(value:Int):Int
	{
		delay = 0;
		if (value > 0)
		{
			delay = 1.0 / value;
		}
		return frameRate = value;
	}
	
	private function set_currentFrame(frame:Int):Int
	{
		if (frame >= 0)
		{
			if (!looped && frame >= totalFrames)
			{
				finished = true;
				currentFrame = totalFrames - 1;
			}
			else
			{
				currentFrame = frame;
			}
		}
		else
		{
			currentFrame = FlxRandom.int(0, totalFrames - 1);
		}
		
		currentIndex = frames[currentFrame];
		
		return currentFrame;
	}
	
	private inline function get_totalFrames():Int
	{
		return frames.length;
	}
}