﻿package flixel.tweens.motion;

import flixel.util.FlxPool;
import flixel.util.FlxPoint;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween.CompleteCallback;

/**
 * Determines motion along a quadratic curve.
 */
class QuadMotion extends Motion
{
	/**
	 * A pool that contains QuadMotions for recycling.
	 */
	@:isVar 
	@:allow(flixel.tweens.FlxTween)
	private static var _pool(get, null):FlxPool<QuadMotion>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	private static function get__pool():FlxPool<QuadMotion>
	{
		if (_pool == null)
		{
			_pool = new FlxPool<QuadMotion>(QuadMotion);
		}
		return _pool;
	}
	
	/**
	 * The distance of the entire curve.
	 */
	public var distance(get, never):Float;
	
	// Curve information.
	private var _distance:Float;
	private var _fromX:Float;
	private var _fromY:Float;
	private var _toX:Float;
	private var _toY:Float;
	private var _controlX:Float;
	private var _controlY:Float;
	
	/**
	 * This function is called when tween is created, or recycled.
	 *
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 * @param	Eease		Optional easer function.
	 */
	override public function init(Complete:CompleteCallback, TweenType:Int, UsePooling:Bool)
	{
		_distance = -1;
		_fromX = _fromY = _toX = _toY = 0;
		_controlX = _controlY = 0;
		return super.init(Complete, TweenType, UsePooling);
	}
	
	/**
	 * Starts moving along the curve.
	 * 
	 * @param	FromX			X start.
	 * @param	FromY			Y start.
	 * @param	ControlX		X control, used to determine the curve.
	 * @param	ControlY		Y control, used to determine the curve.
	 * @param	ToX				X finish.
	 * @param	ToY				Y finish.
	 * @param	DurationOrSpeed	Duration or speed of the movement.
	 * @param	UseDuration		Duration of the movement.
	 * @param	Ease			Optional easer function.
	 */
	public function setMotion(FromX:Float, FromY:Float, ControlX:Float, ControlY:Float, ToX:Float, ToY:Float, DurationOrSpeed:Float, UseDuration:Bool = true, ?Ease:EaseFunction):QuadMotion
	{
		_distance = -1;
		x = _fromX = FromX;
		y = _fromY = FromY;
		_controlX = ControlX;
		_controlY = ControlY;
		_toX = ToX;
		_toY = ToY;
		
		if (UseDuration)
		{
			duration = DurationOrSpeed;
		}
		else
		{
			duration = distance / DurationOrSpeed;
		}
		
		this.ease = Ease;
		start();
		
		return this;
	}
	
	override public function update():Void
	{
		super.update();
		x = _fromX * (1 - scale) * (1 - scale) + _controlX * 2 * (1 - scale) * scale + _toX * scale * scale;
		y = _fromY * (1 - scale) * (1 - scale) + _controlY * 2 * (1 - scale) * scale + _toY * scale * scale;
		if (finished)
		{
			postUpdate();
		}
	}
	
	override inline public function put():Void
	{
		_pool.put(this);
	}
	
	private function get_distance():Float
	{
		if (_distance >= 0) return _distance;
		var a = FlxPoint.get();
		var b = FlxPoint.get();
		a.x = x - 2 * _controlX + _toX;
		a.y = y - 2 * _controlY + _toY;
		b.x = 2 * _controlX - 2 * x;
		b.y = 2 * _controlY - 2 * y;
		var A:Float = 4 * (a.x * a.x + a.y * a.y),
			B:Float = 4 * (a.x * b.x + a.y * b.y),
			C:Float = b.x * b.x + b.y * b.y,
			ABC:Float = 2 * Math.sqrt(A + B + C),
			A2:Float = Math.sqrt(A),
			A32:Float = 2 * A * A2,
			C2:Float = 2 * Math.sqrt(C),
			BA:Float = B / A2;
			
		a.put();
		b.put();
		
		return (A32 * ABC + A2 * B * (ABC - C2) + (4 * C * A - B * B) * Math.log((2 * A2 + BA + ABC) / (BA + C2))) / (4 * A32);
	}
}
