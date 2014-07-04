package flixel.tile;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * A class that holds the graphic, tile dimensions, margin and spacing of a tileset.
 * @author MrCdK
 */
@:allow(flixel.tile.FlxTilemap)
class FlxTileset
{
	/**
	 * The graphic asset of this tileset.
	 */
	public var graphic:FlxGraphicAsset;
	/**
	 * The width of a tile.
	 */
	public var tileWidth:Int = 0;
	/**
	 * the height of a tile.
	 */
	public var tileHeight:Int = 0;
	/**
	 * The margin (external border) of the tileset.
	 */
	public var margin(default, null):FlxPoint;
	/**
	 * The spacing (internal border) of the tileset.
	 */
	public var spacing(default, null):FlxPoint;
	
	private var marginX(get, never):Int;
	private var marginY(get, never):Int;
	private var spacingX(get, never):Int;
	private var spacingY(get, never):Int;
	
	/**
	 * @param 	graphic		The graphic asset of this tileset.
	 * @param	tileWidth	The width of a tile.
	 * @param	tileHeight	The height of a tile.
	 * @param	margin		The margin (external border) of the tileset.
	 * @param	spacing		The spacing (internal border) of the tileset.
	 */
	public function new(graphic:FlxGraphicAsset, tileWidth:Int = 0, tileHeight:Int = 0, ?margin:FlxPoint, ?spacing:FlxPoint)
	{
		this.graphic = graphic;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		if (margin == null)
		{
			this.margin = FlxPoint.get();
		}
		if (spacing == null)
		{
			this.spacing = FlxPoint.get();
		}
	}
	
	private inline function get_marginX():Int
	{
		return Std.int(margin.x);
	}
	private inline function get_marginY():Int
	{
		return Std.int(margin.y);
	}
	private inline function get_spacingX():Int
	{
		return Std.int(spacing.x);
	}
	private inline function get_spacingY():Int
	{
		return Std.int(spacing.y);
	}
}