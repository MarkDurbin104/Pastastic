package com.proiam.comms
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.XMLSocket;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;

    [Event(name="dataAvailable"	, type="flash.events.Event")]
    [Event(name="IOError"				, type="flash.events.Event")]
    [Event(name="securityError"		, type="flash.events.Event")]
    [Event(name="socketClosed"		, type="flash.events.Event")]
    
	public class PhoneHome extends Canvas
	{
		[Bindable]
		public var rxRawXML:XML=new XML();
		public var errorText:String="";
		
		public var remoteMachine:String;		
		public var remotePort:int;
		public var callInterval:int;

		private var checkTimer:Timer=new Timer(callInterval);
		private var localServiceConnectionSocket:XMLSocket;
		
		public function PhoneHome(interval:int=2000,machine:String="127.0.0.1",port:int=8000) //www.isocietas.com
		{
			super();

			remoteMachine=machine;		
			remotePort=port;
			callInterval=interval;
			
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
				localServiceConnectionSocket.connect(remoteMachine,remotePort);
			}
		}
		public function close():void {
			checkTimer.stop();
			if (localServiceConnectionSocket == null) return;
			if (localServiceConnectionSocket.connected) {
				localServiceConnectionSocket.close();
			}
			localServiceConnectionSocket=null;
			checkTimer.removeEventListener(TimerEvent.TIMER,onCheckTimerTick);
		}
		public function sendMessage(message:XML):Boolean {
			if ((localServiceConnectionSocket != null) && (localServiceConnectionSocket.connected)) {
				localServiceConnectionSocket.send(message);
				return true;
			}
			return false;
		}
		private function socketClosed(event:Event):void {
			dispatchEvent(new Event("socketClosed"));
		}
		private function socketReceivedData(event:DataEvent):void {
			rxRawXML=new XML(event.data);
			dispatchEvent(new Event("dataAvailable"));
		}
		private function ignoreSecurityError(event:SecurityErrorEvent):void {
			errorText=event.text;
			dispatchEvent(new Event("securityError"));
		}
		private function ignoreIOError(event:IOErrorEvent):void {
			errorText=event.text;
			dispatchEvent(new Event("IOError"));
		}
	}
}