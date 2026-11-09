package cykor.statemachine
{
	import cykor.statemachine.StateExec;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import mx.core.Container;
	
	public class StateMachine extends StateExec
	{
		public var background:Container;
		public function StateMachine(URL:String,container:Container) {
			super(null,null);
			name=URL;
			background=container;
			var smLoader:URLLoader = new URLLoader(); 
			smLoader.addEventListener(Event.COMPLETE,smLoaded);
			smLoader.load(new URLRequest(URL));
		}
		private function smLoaded(e:Event):void{
			var smConfig:XML=new XML(e.target.data);
//			smConfig.removeNamespace("scxml");
			var xl:XMLList=new XMLList(smConfig.state);
			for (var i:int=0;i<xl.length();i++) {
				var state:State;
				if (xl[i].@id == smConfig.@initalstate) {
					state = new InitialState(xl[i],background);
				} else if (xl.@final == "true") {
					state=new FinalState(xl[i],background);
				} else {
					state = new State(xl[i],background);
				}
				addSubState(state);
			}	
			trace(toString());		
	 	}
	}
}