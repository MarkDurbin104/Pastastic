package com.cykorsystems.utils
{
	import mx.controls.Image;

	public class ImageRenderer extends Image
	{
		public override function set data(value:Object):void
		{
			source = value;
		}
	}
}