package flixel.animation;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.system.layer.frames.FlxFrame;
import flixel.system.layer.frames.FlxSpriteFrames;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.math.FlxRandom;

// We need to mark the class as generic to let the internal map use the underlying map implementation and also we need to remove the base class
@:generic @:remove
class FlxAnimationController<K> implements IFlxDestroyable
{
	/**
	 * Access the currently playing FlxAnimation (warning: can be null).
	 */
	public var currentAnimation(get, set):FlxAnimation<K>;
	
	/**
	 * Tell the sprite to change to a specific frame of the current animation.
	 */
	public var frameIndex(default, set):Int = -1;
	
	/**
	 * Tell the sprite to change to a frame with specific name.
	 * Useful for sprites with loaded TexturePacker atlas.
	 */
	public var frameName(get, set):String;
	
	/**
	 * Gets or sets the currently playing _animations (warning: can be null).
	 */
	public var key(get, set):K;
	
	/**
	 * Pause & resume _curAnim.
	 */
	public var paused(get, set):Bool;
	
	/**
	 * Returns whether an _animations is finished playing.
	 */
	public var finished(get, set):Bool;
	
	/**
	 * The total number of frames in this image.  WARNING: assumes each row in the sprite sheet is full!
	 */
	public var totalFrames(get, null):Int;
	
	/**
	 * Internal, reference to owner sprite.
	 */
	private var _sprite:FlxSprite;
	
	/**
	 * Internal, currently playing animation.
	 */
	@:allow(flixel.animation)
	private var _curAnim:FlxAnimation<K>;
	
	/**
	 * Internal, store all the _animations that were added to this sprite.
	 */
	private var _animations(default, null):Map<K, FlxAnimation<K>>;
	
	//private var _prerotated:FlxPrerotatedAnimation<K>;
	
	public function new(sprite:FlxSprite)
	{
		_sprite = sprite;
		_animations = new Map<K, FlxAnimation<K>>();
	}
	
	public function update():Void
	{
		if (_curAnim != null)
		{
			_curAnim.update();
		}
		//else if (_prerotated != null)
		//{
			//_prerotated.angle = _sprite.angle;
		//}
	}
	
	public function copyFrom(controller:FlxAnimationController<K>):FlxAnimationController<K>
	{
		destroyAnimations();
		
		for (anim in controller._animations)
		{
			add(anim.key, anim.frames, anim.frameRate, anim.looped);
		}
		
		//if (controller._prerotated != null)
		//{
			//createPrerotated();
		//}
		
		if (controller.key != null)
		{
			key = controller.key;
		}
		
		frameIndex = controller.frameIndex;
		
		return this;
	}
	
	public function createPrerotated(?controller:FlxAnimationController<K>):Void
	{
		destroyAnimations();
		controller = (controller != null) ? controller : this;
		//_prerotated = new FlxPrerotatedAnimation(controller, controller._sprite.bakedRotationAngle);
	}
	
	public function destroyAnimations():Void
	{
		clearAnimations();
		clearPrerotated();
	}
	
	public function destroy():Void
	{
		destroyAnimations();
		_animations = null;
		callback = null;
		_sprite = null;
	}
	
	private function clearPrerotated():Void
	{
		//if (_prerotated != null)
		//{
			//_prerotated.destroy();
		//}
		//_prerotated = null;
	}
	
	private inline function clearAnimations():Void
	{
		if (_animations != null)
		{
			var anim:FlxAnimation<K>;
			for (key in _animations.keys())
			{
				anim = _animations.get(key);
				if (anim != null)
				{
					anim.destroy();
				}
				_animations.remove(key);
			}
		}
		_curAnim = null;
	}
	
	/**
	 * Adds a new _animations to the sprite.
	 * @param	Name		What this animation should be called (e.g. "run").
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	FrameRate	The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped		Whether or not the _animations is looped or just plays once.
	 */
	public function add(key:K, frames:Array<Int>, frameRate:Int = 30, looped:Bool = true):Void
	{
		// check that the frames provided are in bounds of the total 
		var framesToAdd:Array<Int> = [];
		for (frame in frames)
		{
			if (FlxMath.inBounds(frame, 0, totalFrames - 1))
			{
				framesToAdd.push(frame);
			}
		}
		
		if (framesToAdd.length > 0)
		{
			var anim = new FlxAnimation<K>(this, key, framesToAdd, frameRate, looped);
			_animations.set(key, anim);
		}
	}
	
	/**
	 * Adds to an existing _animations in the sprite by appending the specified frames to the existing frames.
	 * Use this method when the indices of the frames in the atlas are already known.
	 * The animation must already exist in order to append frames to it. FrameRate and Looped are unchanged.
	 * @param	Name		What the existing _animations is called (e.g. "run").
	 * @param	Frames		An array of numbers indicating what frames to append (e.g. 1, 2, 3).
	*/
	public function append(key:K, frames:Array<Int>):Void
	{
		var anim:FlxAnimation<K> = _animations.get(key);
		
		if (anim == null)
		{
			// anim must already exist
			FlxG.log.warn("No animation called \"" + Std.string(key) + "\"");
			return;
		}
		
		for (frame in frames)
		{
			if (FlxMath.inBounds(frame, 0, totalFrames - 1))
			{
				anim.frames.push(frame);
			}
		}	
	}
	
	/**
	 * Adds a new _animations to the sprite.
	 * @param	Name			What this _animations should be called (e.g. "run").
	 * @param	FrameNames		An array of image names from atlas indicating what frames to play in what order.
	 * @param	FrameRate		The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the _animations is looped or just plays once.
	 */
	public function addByNames(key:K, frameNames:Array<String>, frameRate:Int = 30, looped:Bool = true):Void
	{
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			var indices:Array<Int> = new Array<Int>();
			byNamesHelper(indices, frameNames); // finds frames and appends them to the blank array
			
			if (indices.length > 0)
			{
				var anim = new FlxAnimation<K>(this, key, indices, frameRate, looped);
				_animations.set(key, anim);
			}
		}
	}
	
	/**
	 * Adds to an existing _animations in the sprite by appending the specified frames to the existing frames.
	 * Use this method when the exact name of each frame from the atlas is known (e.g. "walk00.png", "walk01.png").
	 * The animation must already exist in order to append frames to it. FrameRate and Looped are unchanged.
	 * @param	Name			What the existing _animations is called (e.g. "run").
	 * @param	FrameNames		An array of image names from atlas indicating what frames to append.
	*/
	public function appendByNames(key:K, frameNames:Array<String>):Void
	{
		var anim = _animations.get(key);
		
		if (anim == null)
		{
			FlxG.log.warn("No animation called \"" + Std.string(key) + "\"");
			return;
		}
		
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			byNamesHelper(anim.frames, frameNames); // finds frames and appends them to the existing array
		}
	}
	
	/**
	 * Adds a new _animations to the sprite. Should works a little bit faster than addByIndices()
	 * @param	Name			What this _animations should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	Indices			An array of strings indicating what frames to play in what order (e.g. ["01", "02", "03"]).
	 * @param	Postfix			Common ending of image names in atlas (e.g. ".png")
	 * @param	FrameRate		The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the _animations is looped or just plays once.
	 */
	public function addByStringIndices(key:K, prefix:String, indices:Array<String>, postfix:String, frameRate:Int = 30, looped:Bool = true):Void
	{
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			var frameIndices:Array<Int> = new Array<Int>();
			byStringIndicesHelper(frameIndices, prefix, indices, postfix); // finds frames and appends them to the blank array
			
			if (frameIndices.length > 0)
			{
				var anim = new FlxAnimation<K>(this, key, frameIndices, frameRate, looped);
				_animations.set(key, anim);
			}
		}
	}
	
	/**
	 * Adds to an existing _animations in the sprite by appending the specified frames to the existing frames. Should works a little bit faster than appendByIndices().
	 * Use this method when the names of each frame from the atlas share a common prefix and postfix (e.g. "walk00.png", "walk01.png").
	 * The animation must already exist in order to append frames to it. FrameRate and Looped are unchanged.
	 * @param	Name			What the existing _animations is called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	Indices			An array of strings indicating what frames to append (e.g. "01", "02", "03").
	 * @param	Postfix			Common ending of image names in atlas (e.g. ".png")
	*/
	public function appendByStringIndices(key:K, prefix:String, indices:Array<String>, postfix:String):Void
	{
		var anim = _animations.get(key);
		
		if (anim == null)
		{
			FlxG.log.warn("No animation called \"" + Std.string(key) + "\"");
			return;
		}
		
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			byStringIndicesHelper(anim.frames, prefix, indices, postfix); // finds frames and appends them to the existing array
		}
	}
	
	/**
	 * Adds a new _animations to the sprite.
	 * @param	Name			What this _animations should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	Indices			An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	Postfix			Common ending of image names in atlas (e.g. ".png")
	 * @param	FrameRate		The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the _animations is looped or just plays once.
	 */
	public function addByIndices(key:K, prefix:String, indices:Array<Int>, postfix:String, frameRate:Int = 30, looped:Bool = true):Void
	{
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			var frameIndices:Array<Int> = new Array<Int>();
			byIndicesHelper(frameIndices, prefix, indices, postfix); // finds frames and appends them to the blank array
			
			if (frameIndices.length > 0)
			{
				var anim = new FlxAnimation<K>(this, key, frameIndices, frameRate, looped);
				_animations.set(key, anim);
			}
		}
	}
	
	/**
	 * Adds to an existing _animations in the sprite by appending the specified frames to the existing frames.
	 * Use this method when the names of each frame from the atlas share a common prefix and postfix (e.g. "walk00.png", "walk01.png"). Leading zeroes are ignored for matching indices (5 will match "5" and "005").
	 * The animation must already exist in order to append frames to it. FrameRate and Looped are unchanged.
	 * @param	Name			What the existing _animations is called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	Indices			An array of numbers indicating what frames to append (e.g. 1, 2, 3).
	 * @param	Postfix			Common ending of image names in atlas (e.g. ".png")
	*/
	public function appendByIndices(key:K, prefix:String, indices:Array<Int>, postfix:String):Void
	{
		var anim = _animations.get(key);
		
		if (anim == null)
		{
			FlxG.log.warn("No animation called \"" + Std.string(key) + "\"");
			return;
		}
		
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			byIndicesHelper(anim.frames, prefix, indices, postfix); // finds frames and appends them to the existing array
		}
	}
	
	/**
	 * Find a sprite frame so that for Prefix = "file"; Indice = 5; Postfix = ".png"
	 * It will find frame with name "file5.png", but if it desn't exist it will try
	 * to find "file05.png" so allowing 99 frames per animation
	 * Returns found frame and null if nothing is found
	 */
	private function findSpriteFrame(prefix:String, index:Int, postfix:String):Int
	{
		var flxFrames:Array<FlxFrame> = _sprite.framesData.frames;
		for (i in 0...totalFrames)
		{
			var name:String = flxFrames[i].name;
			if (StringTools.startsWith(name, prefix) && StringTools.endsWith(name, postfix))
			{
				var idx:Null<Int> = Std.parseInt(name.substring(prefix.length, name.length - postfix.length));
				if (idx != null && idx == index)
				{
					return i;
				}
			}
		}
		
		return -1;
	}
	
	/**
	 * Adds a new _animations to the sprite.
	 * @param	Name			What this _animations should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	FrameRate		The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the _animations is looped or just plays once.
	*/
	public function addByPrefix(key:K, prefix:String, frameRate:Int = 30, looped:Bool = true):Void
	{
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			var animFrames:Array<FlxFrame> = new Array<FlxFrame>();
			findByPrefix(animFrames, prefix); // adds valid frames to animFrames
			
			if (animFrames.length > 0)
			{
				var frameIndices:Array<Int> = new Array<Int>();
				byPrefixHelper(frameIndices, animFrames, prefix); // finds frames and appends them to the blank array
				
				if (frameIndices.length > 0)
				{
					var anim = new FlxAnimation<K>(this, key, frameIndices, frameRate, looped);
					_animations.set(key, anim);
				}
			}
		}
	}
	
	/**
	 * Adds to an existing _animations in the sprite by appending the specified frames to the existing frames.
	 * Use this method when the names of each frame from the atlas share a common prefix (e.g. "walk00.png", "walk01.png"). Frames are sorted numerically while ignoring postfixes (e.g. ".png", ".gif").
	 * The animation must already exist in order to append frames to it. FrameRate and Looped are unchanged.
	 * @param	Name			What the existing _animations is called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	*/
	public function appendByPrefix(key:K, prefix:String):Void
	{
		var anim = _animations.get(key);
		
		if (anim == null)
		{
			FlxG.log.warn("No animation called \"" + Std.string(key) + "\"");
			return;
		}
		
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			var animFrames:Array<FlxFrame> = new Array<FlxFrame>();
			findByPrefix(animFrames, prefix); // adds valid frames to animFrames
			
			if (animFrames.length > 0)
			{
				byPrefixHelper(anim.frames, animFrames, prefix); // finds frames and appends them to the existing array
			}
		}
	}
	
	/**
	 * Plays an existing _animations (e.g. "run").
	 * If you call an _animations that is already playing it will be ignored.
	 * 
	 * @param   AnimName   The string name of the _animations you want to play.
	 * @param   Force      Whether to force the _animations to restart.
	 * @param   Frame      The frame number in _animations you want to start from (0 by default).
	 *                     If you pass negative value then it will start from random frame
	 */
	public function play(key:K, force:Bool = false, frame:Int = 0):Void
	{
		if (key == null)
		{
			if (_curAnim != null)
			{
				_curAnim.stop();
			}
			_curAnim = null;
		}
		
		if (key == null || _animations.get(key) == null)
		{
			FlxG.log.warn("No animation called \"" + Std.string(key) + "\"");
			return;
		}
		
		if (_curAnim != null && key != _curAnim.key)
		{
			_curAnim.stop();
		}
		_curAnim = _animations.get(key);
		_curAnim.play(force, frame);
	}
	
	/**
	 * Pauses current _animations
	 */
	public inline function pause():Void
	{
		if (_curAnim != null)
		{
			_curAnim.paused = true;
		}
	}
	
	/**
	 * Resumes current _animations if it's exist
	 */
	public inline function resume():Void
	{
		if (_curAnim != null)
		{
			_curAnim.paused = false;
		}
	}
	
	/**
  	 * Gets the FlxAnim object with the specified name.
	 */
	public inline function getByName(key:K):FlxAnimation<K>
	{
		return _animations.get(key); 
	}
	
	/**
	 * Tell the sprite to change to a random frame of _animations
	 * Useful for instantiating particles or other weird things.
	 */
	public function randomFrame():Void
	{
		if (_curAnim != null)
		{
			_curAnim.stop();
			_curAnim = null;
		}
		frameIndex = FlxRandom.int(0, totalFrames - 1);
	}
	
	/**
	 * Dynamic function that will be be called each time the current frame changes.
	 * @param	key			The current key
	 * @param	frameNumber	The current frame
	 * @param	frameIndex	The current frame index
	 */
	public dynamic function callback(key:K, frameNumber:Int, frameIndex:Int):Void
	{
		
	}
	
	private inline function fireCallback():Void
	{
		if (callback != null)
		{
			var key:K = (_curAnim != null) ? (_curAnim.key) : null;
			var number:Int = (_curAnim != null) ? (_curAnim.currentFrame) : frameIndex;
			callback(key, number, frameIndex);
		}
	}
	
	/**
	 * Private helper method for add- and appendByNames. Gets frames and appends them to AddTo.
	 */
	private function byNamesHelper(addTo:Array<Int>, frameNames:Array<String>):Void
	{
		for (name in frameNames)
		{
			if (_sprite.framesData.framesHash.exists(name))
			{
				var frameToAdd:FlxFrame = _sprite.framesData.framesHash.get(name);
				addTo.push(getFrameIndex(frameToAdd));
			}
		}
	}
	
	/**
	 * Private helper method for add- and appendByStringIndices. Gets frames and appends them to AddTo.
	 */
	private function byStringIndicesHelper(addTo:Array<Int>, prefix:String, indices:Array<String>, postfix:String):Void
	{
		for (idx in indices)
		{
			var name:String = prefix + idx + postfix;
			if (_sprite.framesData.framesHash.exists(name))
			{
				var frameToAdd:FlxFrame = _sprite.framesData.framesHash.get(name);
				addTo.push(getFrameIndex(frameToAdd));
			}
		}
	}
	
	/**
	 * Private helper method for add- and appendByIndices. Finds frames and appends them to AddTo.
	 */
	private function byIndicesHelper(addTo:Array<Int>, prefix:String, indices:Array<Int>, postfix:String):Void
	{
		for (idx in indices)
		{
			var indexToAdd:Int = findSpriteFrame(prefix, idx, postfix);
			if (indexToAdd != -1) 
			{
				addTo.push(indexToAdd);
			}
		}
	}
	
	/**
	 * Private helper method for add- and appendByPrefix. Sorts frames and appends them to AddTo.
	 */
	private function byPrefixHelper(addTo:Array<Int>, animFrames:Array<FlxFrame>, prefix:String):Void
	{
		var name:String = animFrames[0].name;
		var postIndex:Int = name.indexOf(".", prefix.length);
		var postfix:String = name.substring(postIndex == -1 ? name.length : postIndex, name.length);
		animFrames.sort(frameSortFunction.bind(_, _, prefix.length, postfix.length));
		
		for (frame in animFrames)
		{
			addTo.push(getFrameIndex(frame));
		}
	}
	
	/**
	 * Private helper method for add- and appendByPrefix. Finds frames with the given prefix and appends them to AnimFrames.
	 */
	private function findByPrefix(animFrames:Array<FlxFrame>, prefix:String):Void
	{
		for (frame in _sprite.framesData.frames)
		{
			if (StringTools.startsWith(frame.name, prefix))
			{
				animFrames.push(frame);
			}
		}
	}
	
	private function set_frameIndex(frame:Int):Int
	{
		if (_sprite.framesData != null)
		{
			frame = frame % totalFrames;
			
			if (frame != frameIndex)
			{
				_sprite.frame = _sprite.framesData.frames[frame];
				frameIndex = frame;
				fireCallback();
			}
		}
		
		return frameIndex;
	}
	
	private inline function get_frameName():String
	{
		return _sprite.frame.name;
	}
	
	private function set_frameName(value:String):String
	{
		if (_sprite.framesData != null && _sprite.framesData.framesHash.exists(value))
		{
			if (_curAnim != null)
			{
				_curAnim.stop();
				_curAnim = null;
			}
			
			var frame = _sprite.framesData.framesHash.get(value);
			if (frame != null)
			{
				frameIndex = getFrameIndex(frame);
			}
		}
		
		return value;
	}
	
	/**
	 * Gets the name of the currently playing _animations (warning: can be null)
	 */
	private function get_key():K
	{
		var key:K = null;
		if (_curAnim != null)
		{
			key = _curAnim.key;
		}
		return key;
	}
	
	/**
	 * Plays a specified _animations (same as calling play)
	 * @param	AnimName	The name of the _animations you want to play.
	 */
	private function set_key(key:K):K
	{
		play(key);
		return key;
	}
	
	/**
	 * Gets the currently playing _animations (warning: can return null).
	 */
	private inline function get_currentAnimation():FlxAnimation<K>
	{
		return _curAnim;
	}
	
	/**
	 * Plays a specified _animations (same as calling play)
	 * @param	AnimName	The name of the _animations you want to play.
	 */
	private inline function set_currentAnimation(anim:FlxAnimation<K>):FlxAnimation<K>
	{
		if (anim != _curAnim)
		{
			if (_curAnim != null) 
			{
				_curAnim.stop();
			}
			
			if (anim != null)
			{
				anim.play();
			}
		}
		return _curAnim = anim;
	}
	
	private inline function get_paused():Bool
	{
		var paused:Bool = false;
		if (_curAnim != null)
		{
			paused = _curAnim.paused;
		}
		return paused;
	}
	
	private inline function set_paused(value:Bool):Bool
	{
		if (_curAnim != null)
		{
			_curAnim.paused = value;
		}
		return value;
	}
	
	private function get_finished():Bool
	{
		var finished:Bool = true;
		if (_curAnim != null)
		{
			finished = _curAnim.finished;
		}
		return finished;
	}
	
	private inline function set_finished(value:Bool):Bool
	{
		if (value == true && _curAnim != null)
		{
			_curAnim.finished = true;
			frameIndex = _curAnim.totalFrames - 1;
		}
		return value;
	}
	
	private inline function get_totalFrames():Int
	{
		return _sprite.frames;
	}
	
	/**
	 * Helper function used for finding index of FlxFrame in _framesData's frames array
	 * @param	Frame	FlxFrame to find
	 * @return	position of specified FlxFrame object.
	 */
	public inline function getFrameIndex(frame:FlxFrame):Int
	{
		return _sprite.framesData.frames.indexOf(frame);
	}
	
	/**
	 * Helper frame sorting function used by addAnimationByPrefixFromTexture() method
	 */
	function frameSortFunction(frame1:FlxFrame, frame2:FlxFrame, prefixLength:Int = 0, postfixLength:Int = 0):Int
	{
		var name1:String = frame1.name;
		var name2:String = frame2.name;
		
		var num1:Int = Std.parseInt(name1.substring(prefixLength, name1.length - postfixLength));
		var num2:Int = Std.parseInt(name2.substring(prefixLength, name2.length - postfixLength));
		
		if (num1 > num2)
		{
			return 1;
		}
		else if (num2 > num1)
		{
			return -1;
		}
		
		return 0;
	}
}
