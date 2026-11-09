package com.cykorsystems.utils
{
	import mx.controls.TextInput;
	import mx.core.UITextField;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.events.Event;

	public class AccessibleTextInput extends TextInput
	{
		public function get innerTextField():UITextField {
			return textField;
		}
	    public function dispatchKeyBoardEvent(keyCode:int,shiftState:Boolean):void
	    {
	        var keyDownEvent:KeyboardEvent =new KeyboardEvent (KeyboardEvent.KEY_DOWN);
            keyDownEvent.charCode=keyCode;
            keyDownEvent.keyCode=keyCode;
            keyDownEvent.shiftKey=shiftState;
            textField.dispatchEvent(keyDownEvent);

	        var changeEvent:Event =new Event(Event.CHANGE);
            textField.dispatchEvent(changeEvent);

			var te:TextEvent = new TextEvent(TextEvent.TEXT_INPUT);			
			te.text = String(keyCode);			
			textField.dispatchEvent(te);
            
	        var keyUpEvent:KeyboardEvent =new KeyboardEvent (KeyboardEvent.KEY_UP);
            keyUpEvent.charCode=keyCode;
            keyUpEvent.keyCode=keyCode;
            keyUpEvent.shiftKey=shiftState;
            textField.dispatchEvent(keyUpEvent);
            
	    }

	}
}