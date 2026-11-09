package {
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.XMLSocket;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;

    [Event(name="dataAvailable", type="flash.events.Event")]
	public class CommandSocket extends Canvas
	{
		public var machineIP:String="127.0.0.1";
		
		//[Bindable]
		public function get isConnected():Boolean {
			if ((localServiceConnectionSocket != null) && (localServiceConnectionSocket.connected)) {
				return true;
			}
			return false;
		}
		private var checkTimer:Timer=new Timer(1000);
		private var localServiceConnectionSocket:XMLSocket;
		
		public function close():void {
			if (localServiceConnectionSocket == null) return;
			if (localServiceConnectionSocket.connected) {
				localServiceConnectionSocket.close();
			}
			localServiceConnectionSocket=null;
		}
		public function CommandSocket()
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
	  	    var commandData:XML=new XML(event.data);
	  	    trace(commandData.toXMLString());
		}
		
		public function SendCommand(command:String):void {
			if (isConnected) {
				localServiceConnectionSocket.send(command);
			}
		}
		private function ignoreSecurityError(event:SecurityErrorEvent):void {
			// nothing here, probably means the service is not installed, run in standalone mode
		}
		private function ignoreIOError(event:IOErrorEvent):void {
			// nothing here, probably means the service is not installed, run in standalone mode
		}
	}
}