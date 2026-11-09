package com.cykorsystems.utils
{
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.SharedObject;
	import flash.events.Event;
	import mx.core.UIComponent;
	import mx.controls.SWFLoader;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Bitmap;
	import com.cykorsystems.utils.UIUtils;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class CachedURLLoader extends UIComponent
	{
		public var data:Object;
		private var urlLoader:URLLoader;
		private var thisRequest:URLRequest;
		static public const LocalPath:String='';
//		static public const LocalPath:String='http://localhost:8000/';
		
		private const fileSplitGranularity:int = 5;
		public function saveCacheItem(name:String,item:Object):void {
		return;
	        var indexFile:SharedObject=SharedObject.getLocal("iSocietasIndex");
	        var items:Array=indexFile.data.items;
	        var index:int;
	        if (items == null) items=new Array;
	        index=items.indexOf(name);
	        if (index < 0) {
	        	index=items.length;
	        	items.push(name);
	        }
	        var dataFile:SharedObject=SharedObject.getLocal("iSocietasData"+String(int(index/fileSplitGranularity)));
	        var dataItems:Array=dataFile.data.items;
	        if (dataItems == null) dataItems=new Array;
	        dataItems[int(index%fileSplitGranularity)]=item;
	        dataFile.data.items=dataItems;
			dataFile.flush();
			dataFile=null;
        	indexFile.data.items=items;
			indexFile.flush();
			indexFile=null;
		}
		public function loadCacheItem(name:String):Object {
	        var indexFile:SharedObject=SharedObject.getLocal("iSocietasIndex");
	        var items:Array=indexFile.data.items;
	        var index:int;
	        var item:Object;
	        if (items == null) {
				indexFile=null;
	        	return null;
	        }
	        index=items.indexOf(name);
	        if (index < 0) {
				indexFile=null;
		        return null;
	        }

	        var dataFile:SharedObject=SharedObject.getLocal("iSocietasData"+String(int(index/fileSplitGranularity)));
	        var dataItems:Array=dataFile.data.items;
	        if (dataItems == null) {
				dataFile=null;
				indexFile=null;
		        return null;
	        }
	        item=dataItems[int(index%fileSplitGranularity)];
			dataFile=null;
			indexFile=null;
			return item;
		}
		public function isItemCached(name:String):Boolean{
	        var indexFile:SharedObject=SharedObject.getLocal("iSocietasIndex");
	        var items:Array=indexFile.data.items;
	        if ((items == null) || (items.indexOf(name) < 0)) return false;
	        return true;
		}
		public function CachedURLLoader(request:URLRequest=null)
		{
			urlLoader=new URLLoader();
			if (request !=null) {
				this.load(request);
			}
		}
		public function load(request:URLRequest):void {
			thisRequest=request;
			thisRequest.url=LocalPath+thisRequest.url;
			if (!isItemCached(thisRequest.url)) {
				urlLoader.addEventListener(Event.COMPLETE,CacheBeforeReturning);
				urlLoader.load(request);
			} else {
				var event:Event=new Event(Event.COMPLETE);
				data=loadCacheItem(thisRequest.url);
				dispatchEvent(event);
			}
		}
		private function CacheBeforeReturning(event:Event):void {
			data=event.target.data;
			if (!isItemCached(thisRequest.url)) {
				saveCacheItem(thisRequest.url,data);
			}
			var replacementEvent:Event=new Event(Event.COMPLETE);
			dispatchEvent(replacementEvent);
		}
   		public function loadImage(request:URLRequest):void {
			thisRequest=request;
			thisRequest.url=LocalPath+thisRequest.url;
			if (!isItemCached(thisRequest.url)) {
				var loader:Loader = new Loader();
			    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, CacheBeforeReturningImage);
				loader.load(request);
			} else {
				try {
					var event:Event=new Event(Event.COMPLETE);
					var byteArray:ByteArray=ByteArray(loadCacheItem(thisRequest.url));
					var bmpData:BitmapData=UIUtils.byteArrayToBitmapData(byteArray);
					var bmp:Bitmap=new Bitmap(bmpData);
					data=bmp;
					dispatchEvent(event);
				} catch (e:Error) {
				    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, CacheBeforeReturningImage);
					loader.load(request);
				}
			}
   		}
		private function CacheBeforeReturningImage(event:Event):void {
		    var t:LoaderInfo = event.currentTarget as LoaderInfo;
		    data = t.content;
			if (!isItemCached(thisRequest.url)) {
//				var byteArray:ByteArray=UIUtils.bitmapDataToByteArray((data as Bitmap).bitmapData);
//				saveCacheItem(thisRequest.url,byteArray);
			}
			var replacementEvent:Event=new Event(Event.COMPLETE);
			dispatchEvent(replacementEvent);
		}
	}
}