package flixel.system.frontEnds;

import flixel.util.FlxPoint;

#if js
import js.Browser;

class HTML5FrontEnd
{
	/**
	 * Which browser the game is running in.
	 */
	public var browser(get, null):String;
	public var browserPosition(get, null):FlxPoint;
	public var browserWidth(get, null):Int;
	public var browserHeight(get, null):Int;
	
	/**
	 * Constants for the different browsers returned by <code>browser</code>
	 */
	inline static public var INTERNET_EXPLORER:String 	= "Internet Explorer";
	inline static public var CHROME:String 				= "Chrome";
	inline static public var FIREFOX:String			 	= "Firefox";
	inline static public var SAFARI:String 				= "Safari";
	inline static public var OPERA:String 				= "Opera";
	
	public function new() {}
	
	private function get_browser():String
	{
		if (Browser.navigator.userAgent.indexOf(" OPR/") > -1) {
			return OPERA;
		}
		else if (Browser.navigator.userAgent.toLowerCase().indexOf("chrome") > -1) {
			return CHROME;
		}
		else if (Browser.navigator.appName == "Netscape") {
			return FIREFOX;
		}
		else if (untyped false || !!document.documentMode) {
			return INTERNET_EXPLORER;
		}
		else if (untyped Object.prototype.toString.call(window.HTMLElement).indexOf("Constructor") > 0) {
			return SAFARI;
		}
		return "Unknown";
	}
	
	private function get_browserPosition():FlxPoint
	{
		if (browserPosition == null) {
			browserPosition = new FlxPoint(0, 0);
		}
		browserPosition.set(Browser.window.screenX, Browser.window.screenY);
		return browserPosition;
	}
	
	inline private function get_browserWidth():Int
	{
		return Browser.window.innerWidth;
	}
	
	inline private function get_browserHeight():Int
	{
		return Browser.window.innerHeight;
	}
}
#end
