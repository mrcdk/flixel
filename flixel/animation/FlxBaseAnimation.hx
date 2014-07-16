package flixel.animation;

import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

@:generic @:remove
class FlxBaseAnimation<K> implements IFlxDestroyable
{
	/**
	 * Animation controller this animation belongs to
	 */
	public var parent:FlxAnimationController<K>;
	
	/**
	 * String name of the animation (e.g. "walk")
	 */
	public var key:K;
	
	/**
	 * Keeps track of the current index into the tile sheet based on animation or rotation.
	 * Allow access to private var from FlxAnimationController.
	 */
	public var currentIndex(default, set):Int = 0;
	
	public function new(parent:FlxAnimationController<K>, key:K)
	{
		this.parent = parent;
		this.key = key;
	}
	
	public function destroy():Void
	{
		parent = null;
		key = null;
	}
	
	public function update():Void {}
	
	public function clone(Parent:FlxAnimationController<K>):FlxBaseAnimation<K>
	{
		return null;
	}
	
	
	private function set_currentIndex(value:Int):Int
	{
		currentIndex = value;
		
		if (parent != null && parent._curAnim == this)
		{
			parent.frameIndex = value;
		}
		
		return value;
	}
}