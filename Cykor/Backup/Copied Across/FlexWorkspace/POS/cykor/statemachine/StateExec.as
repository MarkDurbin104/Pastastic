package cykor.statemachine
{
	import mx.collections.ArrayCollection;
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.utils.StringUtil;
	
	public class StateExec extends StateNode
	{
		private var transitionList:Array;
		private var actionList:Array;
		private var eventQueue:Array;
		private var subStates:ArrayCollection;
		public var parentState:StateExec;
		private var _isActive:Boolean=false;
		public function set active(value:Boolean):void {
			_isActive=value;
		}
		
		public function get active():Boolean {
			return _isActive;
		}
		public function StateExec(config:XML,container:Container)
		{
			if (config != null) {
				if (config.attribute("id").length() > 0) {
					stateName=config.@id;
				} else {
					stateName="";
				}
				super(stateName);

				var state:State;
				var xl:XMLList;
				var i:int;
				
				xl=new XMLList(config.initial);
				for (i=0;i<xl.length();i++) {
					state=new InitialState(xl[i],container);
					addSubState(state);
				}
				xl=new XMLList(config.state);
				for (i=0;i<xl.length();i++) {
					if (xl.@final == "true") {
						state=new FinalState(xl[i],container);
					} else {
						state=new State(xl[i],container);
					}
					addSubState(state);
				}	
				container.addChild(this);
				x=config.@x;
				y=config.@y;
				width=config.@width;
				height=config.@height;
				buttonMode=true;
			}
		}
		public function addSubState(subState:StateExec):int {
			if (subStates == null) subStates=new ArrayCollection;
			subState.parentState=this;
			if (subState.width == 0) {
				if (subStates.length == 0) {
					subState.x=20;
					subState.y=20;
				} else {
					var lastState:State=subStates[subStates.length-1];
					subState.x=lastState.x+lastState.width+20;
					subState.y=lastState.y;
				}
//				if (subState is InitialState) {
//					subState.width=60;
//					subState.height=60;
//				} else {
					subState.width=100;
					subState.height=100;
//				}
			}
			subStates.addItem(subState);
			return subStates.length-1;
		}
		public function deleteSubState(index:int):void {
			if ((subStates == null) || (index>=subStates.length) || (index<0)) return;
			subStates.removeItemAt(index);
		}
		public override function toString():String {
			var result:String=name+" ";
			if ((subStates != null) && (subStates.length > 0)) {
				result+="{";
				for (var i:int=0;i<subStates.length;i++) {
					result+=subStates[i].toString();
				}
				result+="}";
			}
			return result;
		}
	}
}