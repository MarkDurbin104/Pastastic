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
		public var itemXML:XML=new XML(); // xml recieved from vuit device
		[Bindable]
		public var imageSource:String="";  // filename of the image named in itemXML
		
		public var machineIP:String="127.0.0.1";
		
		private var checkTimer:Timer=new Timer(1000);
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
		
		// on tick connect to local bridge if it exists  (keep checking incase connection lost)
		public function onCheckTimerTick(event:TimerEvent):void {
			if (localServiceConnectionSocket == null) return;
			if (!localServiceConnectionSocket.connected) {
				localServiceConnectionSocket.connect('127.0.0.1',45000);
			}
		}
		private function socketClosed(event:Event):void {
		}
		private function socketReceivedData(event:DataEvent):void {
			trace(event.data);
	  	    var MachineListXML:XML=new XML(event.data);  // xml recieved with details of all bridges on LAN

			for each (var machine:XML in MachineListXML.Machine) {
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
			try {
				itemXML=new XML(event.target.data);
			} catch (error:Error) {
				itemXML=new XML();
			}
			var unique:int=new Date().getTime();
			dispatchEvent(new Event("dataAvailable"));
		}
		
		public function ReadyForData():void {
			var dataFile:URLLoader=new URLLoader();
			var unique:int=new Date().getTime();
			dataFile.addEventListener(IOErrorEvent.IO_ERROR,ignoreIOError);
			dataFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR,ignoreSecurityError);
			dataFile.load(new URLRequest('http://'+machineIP+':8000/VU.iT.Ready.xml?unique='+unique));
		}
		private function ignoreSecurityError(event:SecurityErrorEvent):void {
			// nothing here, probably means the service is not installed, run in standalone mode
		}
		private function ignoreIOError(event:IOErrorEvent):void {
			// nothing here, probably means the service is not installed, run in standalone mode
		}
	}
}