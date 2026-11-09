package com.cykorsystems.CoverFlow
{
	import mx.containers.Canvas;
	import mx.controls.TextArea;
	import flash.events.Event;
	import mx.controls.TextInput;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	import com.proiam.slides.KeyboardKey;
	import com.proiam.slides.LargeKeyboardKey;
	import com.proiam.slides.SpaceKeyboardKey;
	import com.proiam.slides.DoubleKeyboardKey;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import mx.core.UIComponent;
	import flash.events.TextEvent;
	import com.cykorsystems.utils.AccessibleTextInput;
	import mx.automation.IAutomationObject;

	public class KeyBoardCanvas extends Canvas
	{
	 	private const keyWidth:int=82;
	 	private const keyHeight:int=65;
	 	private const rowStepX:int=21;
	 	private const keyXSpacing:int=3;
	 	private const keyYSpacing:int=5;
	 	public var EditControl:TextInput=null;
		private var keys:Array=[
				[['1','!',1],['2','"',1],['3','#',1],['4','$',1],['5','%',1],['6','^',1],['7','&',1],['8','*',1],['9','(',1],['0',')',1],['BACK\nSPACE','BACK\nSPACE',3]],
				[['q','Q',1],['w','W',1],['e','E',1],['r','R',1],['t','T',1],['y','Y',1],['u','U',1],['i','I',1],['o','O',1],['p','P',1],['@',':',1]],
				[['a','A',1],['s','S',1],['d','D',1],['f','F',1],['g','G',1],['h','H',1],['j','J',1],['k','K',1],['l','L',1],['ENTER','ENTER',2]],
				[['z','Z',1],['x','X',1],['c','C',1],['v','V',1],['b','B',1],['n','N',1],['m','M',1],['.',',',1],['<---','HOME',5],['--->','END',5]],
				[['SHIFT','LOCK',4],['SPACE','SPACE',6]]
		];
		private var shiftState:Boolean=false;
		private var shiftKey:KeyboardKey;
		
		public function KeyBoardCanvas()
		{
			super();
			for (var i:int=0;i<4;i++) {
				assignKeys(i,x+i*rowStepX,y+i*(keyYSpacing+keyHeight),10);
			}
			shiftKey=new LargeKeyboardKey(); 
			shiftKey.yPos=15;
			shiftKey.x=x;
			shiftKey.y=y+4*(keyYSpacing+keyHeight);
			shiftKey.shiftState=shiftState;
			shiftKey.key=keys[4][0][0];
			shiftKey.shiftKey=keys[4][0][1];
			addChild(shiftKey);
			shiftKey.addEventListener(MouseEvent.CLICK,changeShiftState);
			var key:KeyboardKey=new SpaceKeyboardKey();
			key.x=x+235;
			key.y=y+4*(keyYSpacing+keyHeight);
			key.shiftState=shiftState;
			key.key=keys[4][1][0];
			key.shiftKey=keys[4][1][1];
			addChild(key);
			key.addEventListener(MouseEvent.CLICK,keyPress);
		}

		private function assignKeys(rowNum:Number,xPos:Number,yPos:Number,keyCount:Number):void {
			for (var keyidx:int=0;keyidx<keys[rowNum].length;keyidx++) {
				var key:KeyboardKey;
				switch (keys[rowNum][keyidx][2] ) {
					case 1		: key=new KeyboardKey(); break;
					case 2		: key=new DoubleKeyboardKey(); break;
					case 3		: key=new LargeKeyboardKey(); break;
					case 4		: key=new LargeKeyboardKey(); key.yPos=15; break;
					case 5		: key=new KeyboardKey(); key.fontSize=20; key.yPos=15; break;
					default	: return;
				}
				key.x=xPos+keyidx*(keyXSpacing+keyWidth);
				key.y=yPos;
				key.shiftState=shiftState;
				key.key=keys[rowNum][keyidx][0];
				key.shiftKey=keys[rowNum][keyidx][1];
				addChild(key);
				key.addEventListener(MouseEvent.CLICK,keyPress);
			}
		}
		private function changeShiftState(event:MouseEvent):void {
			if (shiftKey.cap.text=="LOCK") {
				shiftKey.cap.text="UNLOCK"
				return;
			} else if (shiftKey.cap.text=="UNLOCK") {
				shiftKey.cap.text="LOCK"
			}
			shiftState=!shiftState;
			for (var i:int=0;i<numChildren;i++) {
				var child:DisplayObject=getChildAt(i);
				if (child is KeyboardKey) KeyboardKey(child).shiftState=shiftState;
			}
		}
	    public function dispatchKeyBoardEvent(keyCode:int,shiftState:Boolean):void
	    {
	        var keyDownEvent:KeyboardEvent =new KeyboardEvent (KeyboardEvent.KEY_DOWN);
            keyDownEvent.charCode=keyCode;
            keyDownEvent.keyCode=keyCode;
            keyDownEvent.shiftKey=shiftState;
            EditControl.dispatchEvent(keyDownEvent);

	        var keyUpEvent:KeyboardEvent =new KeyboardEvent (KeyboardEvent.KEY_UP);
            keyUpEvent.charCode=keyCode;
            keyUpEvent.keyCode=keyCode;
            keyUpEvent.shiftKey=shiftState;
            EditControl.dispatchEvent(keyUpEvent);
	    }
		private function keyPress(event:Event):void {
			EditControl=TextInput(focusManager.getFocus());
			if (EditControl == null) return;
			EditControl.setFocus();
			
			var key:KeyboardKey=KeyboardKey(event.currentTarget);
			var keyPressed:String=key.shiftState?key.shiftKey:key.key;
			var enterPressed:Boolean=false;
			var backSpacePressed:Boolean=false;
			var processKey:Boolean=true;

			if (shiftKey.cap.text=="LOCK") {
				shiftKey.cap.text="UNLOCK"
				changeShiftState(null);
			}
			var newIndex:int=EditControl.selectionBeginIndex;
			var endIndex:int=EditControl.selectionEndIndex;
			
			switch (keyPressed) {
				case 'SPACE' : keyPressed=" "; break;
				case 'BACK\nSPACE' : backSpacePressed=true; processKey=false; break;
				case 'ENTER' : dispatchKeyBoardEvent(Keyboard.ENTER,false); return;
				case '<---' : if (newIndex>0) EditControl.setSelection(newIndex-1,newIndex-1); return;
				case '--->' : if (newIndex<EditControl.text.length) EditControl.setSelection(newIndex+1,newIndex+1); return;
				case 'HOME' : EditControl.setSelection(0,0); return;
				case 'END' : EditControl.setSelection(EditControl.text.length,EditControl.text.length); return;
			}
			// text selected ? - delete it
			if (newIndex != endIndex) {
				EditControl.text=EditControl.text.slice(0,newIndex)+EditControl.text.slice(endIndex);
				EditControl.setSelection(newIndex,newIndex);
				endIndex=newIndex;
				backSpacePressed=false;
			}
			if (processKey) {
				EditControl.text=EditControl.text.slice(0,newIndex)+keyPressed+EditControl.text.slice(endIndex);
				newIndex++;
				EditControl.setSelection(newIndex,newIndex);
			}
			if ((backSpacePressed)&&(newIndex>0)) {
				newIndex--;
				EditControl.text=EditControl.text.slice(0,newIndex)+EditControl.text.slice(newIndex+1);
				EditControl.setSelection(newIndex,newIndex);
			}
		}
		private function emulateKeyPress(event:Event):void {
			
			var key:KeyboardKey=KeyboardKey(event.currentTarget);
			var keyPressed:String=key.key;
			var keyCode:uint;

			switch (keyPressed) {
				case 'SPACE' 				: keyCode=Keyboard.SPACE; 			break;
				case 'BACK\nSPACE' 	: keyCode=Keyboard.BACKSPACE; 	break;
				case 'ENTER' 				: keyCode=Keyboard.ENTER;				break;
				case '<---' 						: keyCode=Keyboard.LEFT; 				break;
				case '--->' 						: keyCode=Keyboard.RIGHT; 			break;
				case 'HOME' 					: keyCode=Keyboard.HOME; 				break;
				case 'END' 						: keyCode=Keyboard.END; 					break;
				default							: keyCode=keyPressed.charCodeAt(0);
			}
			dispatchKeyBoardEvent(keyCode,key.shiftState);

			if (shiftKey.cap.text=="LOCK") {
				shiftKey.cap.text="UNLOCK"
				changeShiftState(null);
			}
		}
	}
}
