package com.proiam.slides
{
	import com.proiam.mails.MailService;
	
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	
	import mx.containers.Canvas;
	import mx.effects.Fade;
	import mx.effects.Zoom;

	public class OneDayBase extends Canvas
	{
		[Bindable]
		public var service:MailService=null;
		
        private var alphaFade:Fade=new Fade();
    	private var _caption:String;
    	private var _price:String;
    	private var _hint:String;
    	private var _iconSource:Object;

        [Bindable]
        [Inspectable(defaultValue=1)]
        public var itemWidth:int=1;
        
        [Bindable]
        [Inspectable(defaultValue="")]
        public function get caption():String
        {
        	return _caption;
        }
        public function set caption(value:String):void
        {
        	_caption=value;
        }
        [Bindable]
        [Inspectable(defaultValue="")]
        public function get price():String
        {
        	return _price;
        }
        public function set price(value:String):void
        {
        	_price=value;
        }
        [Bindable]
        [Inspectable(defaultValue="")]
        public function get hint():String
        {
        	return _hint;
        }
        public function set hint(value:String):void
        {
        	_hint=value;
        }
        [Bindable]
        [Inspectable(defaultValue=null)]
        public function get iconSource():Object
        {
        	return _iconSource;
        }
        public function set iconSource(value:Object):void
        {
        	_iconSource=value;
        }
    	public function fadeToAlpha(newAlpha:Number,duration:int=2000):void {
    		if (alphaFade.isPlaying) alphaFade.end();
            alphaFade.alphaFrom=alpha;
            alphaFade.alphaTo=newAlpha;
            alphaFade.duration=duration;
            alphaFade.target=this;
            alphaFade.play();
    	}
        public function createEffect(eventObj:Event):void {
            var zoomOver:Zoom = new Zoom();
            zoomOver.duration = 20; 
            zoomOver.zoomHeightTo = 1.05; 
            zoomOver.zoomWidthTo = 1.05;
            var zoomOut:Zoom = new Zoom();
            zoomOut.duration =200; 
            zoomOut.zoomHeightTo = 1; 
            zoomOut.zoomWidthTo = 1; 
            setStyle("rollOverEffect", zoomOver); 
            setStyle("rollOutEffect", zoomOut); 
		} 

        public function OneDayBase() {
        	super();
            var filter:BitmapFilter = getBitmapFilter();
            var myFilters:Array = new Array();
            myFilters.push(filter);
            filters = myFilters;
        }

        private function getBitmapFilter():BitmapFilter {
            var color:Number = 0x000000;
            var angle:Number = 45;
            var alpha:Number = 0.1;
            var blurX:Number = 0;
            var blurY:Number = 0;
            var distance:Number = 4;
            var strength:Number = 1;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;
            return new DropShadowFilter(distance,angle,color,alpha,blurX,blurY,strength,quality,inner,knockout);
        }
	}
}