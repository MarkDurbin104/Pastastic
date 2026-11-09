package com.proiam.comms
{
	import mx.containers.Canvas;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.net.XMLSocket;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.DataEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

    [Event(name="dataAvailable", type="flash.events.Event")]
	public class ServiceInterface extends Canvas
	{
		[Bindable]
		public var rxRawXML:XML=new XML();
		[Bindable]
		public var itemXML:XML=new XML();
		[Bindable]
		public var imageSource:String="";
		
		private var checkTimer:Timer=new Timer(2000);
		private var localServiceConnectionSocket:XMLSocket;
		
		public function close():void {
			if (localServiceConnectionSocket == null) return;
			if (localServiceConnectionSocket.connected) {
				localServiceConnectionSocket.close();
			}
			localServiceConnectionSocket=null;
		}
		public function ServiceInterface()
		{
			super();

			localServiceConnectionSocket=new XMLSocket();
			localServiceConnectionSocket.addEventListener(Event.CLOSE,socketClosed);
			localServiceConnectionSocket.addEventListener(DataEvent.DATA,socketReceivedData);
			localServiceConnectionSocket.addEventListener(IOErrorEvent.IO_ERROR,ignoreIOError);
			localServiceConnectionSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,ignoreSecurityError);
			
			checkTimer.addEventListener(TimerEvent.TIMER,onCheckTimerTick);
			checkTimer.start();
		}
		public function onCheckTimerTick(event:TimerEvent):void {
			if (localServiceConnectionSocket == null) return;
			if (!localServiceConnectionSocket.connected) {
				localServiceConnectionSocket.connect('localhost',45000);
			}
		}
		private function socketClosed(event:Event):void {
			rxRawXML=new XML();
		}
		private var machineIP:String="127.0.0.1";
		private function socketReceivedData(event:DataEvent):void {
			rxRawXML=new XML(event.data);
			for each (var machine:XML in rxRawXML.Machine) {
				var ipAddress:String=machine.@ipAddress;
				var dataAvailable:String=machine.@dataAvailable;
				if (dataAvailable=="true") {
					var dataFile:URLLoader=new URLLoader();
					dataFile.addEventListener(Event.COMPLETE,postDataToText);
					var unique:int=new Date().getTime();
					machineIP=ipAddress;
					dataFile.load(new URLRequest('http://'+machineIP+':8000/VU.iT.Data.xml?unique='+unique));
					break;
				}
			}
		}
		private function postDataToText(event:Event):void {
			itemXML=new XML(event.target.data);
			var unique:int=new Date().getTime();
			imageSource='http://'+machineIP+':8000'+itemXML.Machine.Item.Image+'?unique='+unique;
			dispatchEvent(new Event("dataAvailable"));
		}
		
		public function ReadyForData():void {
			var dataFile:URLLoader=new URLLoader();
			var unique:int=new Date().getTime();
			dataFile.addEventListener(IOErrorEvent.IO_ERROR,ignoreIOError);
			dataFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR,ignoreSecurityError);
//			dataFile.addEventListener(Event.COMPLETE,dummyEVHandler);
			dataFile.load(new URLRequest('http://'+machineIP+':8000/VU.iT.Ready.xml?unique='+unique));
		}
		private function ignoreSecurityError(event:SecurityErrorEvent):void {
			// nothing here, probably means the service is not installed, run in standalone mode
		}
		private function ignoreIOError(event:IOErrorEvent):void {
			// nothing here, probably means the service is not installed, run in standalone mode
		}
//		private function dummyEVHandlerprivate function 
//			;	
//		}
	}
}