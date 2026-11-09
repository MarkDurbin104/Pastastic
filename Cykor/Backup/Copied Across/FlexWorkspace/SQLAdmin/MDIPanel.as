package
{
	import mx.core.UIComponent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import mx.controls.Button;
	import mx.events.ResizeEvent;
	import flash.display.Graphics;
	import mx.managers.CursorManager;
	import mx.containers.Panel;

	public class MDIPanel extends Panel
	{
		// Constants for MDI panel event names
		public static var MINIMIZE:String = "minimize";
		public static var MAXIMIZE:String = "maximize";
		public static var CLOSE:String = "close";
		public static var RESTORE:String = "restore";
		
		public var originalX:Number;
		public var originalY:Number;
		public var originalWidth:Number;
		public var originalHeight:Number;
		public var originalCornerRadius:Object;

		// Current state of the panel. Using two variables so that when
		// we minimize a panel, we can restore it in the right state (maximized or not).
		public var minimized:Boolean = false;
		public var maximized:Boolean = false;

		// MDI Panel images
		[Embed(source="assets/icon_close.png")]
		private static var iconClose:Class;
			
		[Embed(source="assets/icon_minimize.png")]
		private static var iconMinimize:Class;
			
		[Embed(source="assets/icon_maximize.png")]
		private static var iconMaximize:Class;
			
		[Embed(source="assets/icon_restore.png")]
		private static var iconRestore:Class;

		[Embed(source="assets/icon_resize.gif")]
		private static var iconResize:Class;

		private var xOffset:Number;
       	private var yOffset:Number;

		protected var minimizeButton:Button;
		protected var maximizeButton:Button;
		protected var closeButton:Button;
		protected var grip:UIComponent;

		public function MDIPanel()
		{
			super();
			isPopUp = true;
		}				
					
		override protected function createChildren():void
		{
			super.createChildren();
			
			minimizeButton = new Button();
			minimizeButton.y = 6;
			minimizeButton.setStyle("upSkin", null);
			minimizeButton.setStyle("cornerRadius", 2);
			minimizeButton.width = 18;
			minimizeButton.height = 18;
			minimizeButton.setStyle("icon", iconMinimize);
			minimizeButton.addEventListener(MouseEvent.CLICK, minimizeHandler);

			maximizeButton = new Button();
			maximizeButton.y = 6;
			maximizeButton.setStyle("upSkin", null);
			maximizeButton.setStyle("cornerRadius", 2);
			maximizeButton.width = 18;
			maximizeButton.height = 18;
			maximizeButton.setStyle("icon", iconMaximize);
			maximizeButton.addEventListener(MouseEvent.CLICK, maximizeHandler);
			
			closeButton = new Button();
			closeButton.y = 6;
			closeButton.setStyle("upSkin", null);
			closeButton.setStyle("cornerRadius", 2);
			closeButton.width = 18;
			closeButton.height = 18;
			closeButton.setStyle("icon", iconClose);
			closeButton.addEventListener(MouseEvent.CLICK, closeHandler);
			
			titleBar.addChild(closeButton);			
			titleBar.addChild(maximizeButton);			
			titleBar.addChild(minimizeButton);			

			grip = new UIComponent();
			grip.width = 10;
			grip.height = 10;	    	

			var g:Graphics = grip.graphics;
            g.clear();
            g.beginFill(0xFFFFFF, 0);
            g.drawRect(0, 0, 10, 10);
            g.endFill();
            
			g.lineStyle(1, 0x333333);
			g.moveTo(2, 9);
			g.lineTo(9, 2);
			g.moveTo(5, 9);
			g.lineTo(9, 5);
			
			grip.addEventListener(MouseEvent.MOUSE_OVER, 
				function (event:MouseEvent):void
				{
					CursorManager.setCursor(iconResize);
				});
			grip.addEventListener(MouseEvent.MOUSE_OUT, 
				function (event:MouseEvent):void
				{
					CursorManager.removeCursor(CursorManager.currentCursorID);
				});
			grip.addEventListener(MouseEvent.MOUSE_DOWN, startResizing);

			rawChildren.addChild(grip);

			addEventListener(MouseEvent.MOUSE_DOWN, bringToTop);
			parent.addEventListener(ResizeEvent.RESIZE, parentResizeHandler);
			verticalScrollPolicy = "off";
			horizontalScrollPolicy = "off";
			
			originalCornerRadius = getStyle("cornerRadius");
		}
			
		protected function bringToTop(event:MouseEvent):void
		{
			parent.setChildIndex(this, parent.numChildren - 1); 
		}

	    override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void
	    {
			super.layoutChrome(unscaledWidth, unscaledHeight);
			closeButton.x = unscaledWidth - 24;
			maximizeButton.x = closeButton.x - 18;
			minimizeButton.x = maximizeButton.x - 18;
			if (maximized)
			{
				grip.visible = false;
			}
			else
			{
				grip.move(unscaledWidth - 10, unscaledHeight - 10);
				grip.visible = true;
			}
	    }
					
		protected function parentResizeHandler(event:Event):void
		{
			if (parent==null) return;
			if (maximized)
			{
				width = parent.width;
				height = parent.height;				
			}
			if (!minimized && ! maximized)
			{
				if (x > parent.width - 50) x = parent.width - 100;
				if (y > parent.height - 50) y = parent.height - 100;
			}
		}
		
		protected function minimizeHandler(event:Event):void
		{
			minimized = true;
			dispatchEvent(new Event(MINIMIZE));
		}

		protected function maximizeHandler(event:Event):void
		{
			if (maximized)
			{
				maximizeButton.setStyle("icon", iconMaximize);	
				maximized = false;
				dispatchEvent(new Event(RESTORE));
			}
			else
			{
				originalX = x;
				originalY = y;
				originalWidth = width;
				originalHeight = height;
				maximizeButton.setStyle("icon", iconRestore);	
				maximized = true;
				dispatchEvent(new Event(MAXIMIZE));
			}
		}

		protected function closeHandler(event:Event):void
		{
			parent.removeEventListener(ResizeEvent.RESIZE, parentResizeHandler);
			dispatchEvent(new Event(CLOSE));
		}

		// Resize panel event handlers
		protected  function startResizing(event:MouseEvent):void
		{
			CursorManager.setCursor(iconResize);
			originalWidth = width;
			originalHeight = height;
			xOffset = parent.mouseX;
        	yOffset = parent.mouseY;

	        systemManager.addEventListener(MouseEvent.MOUSE_MOVE, resizing, true);
	        systemManager.addEventListener(MouseEvent.MOUSE_UP, stopResizing, true);
	        systemManager.stage.addEventListener(Event.MOUSE_LEAVE, stopResizing);
		}
		
		protected function resizing(event:MouseEvent):void
    	{
	    	event.stopImmediatePropagation();
    		if ((originalWidth + (parent.mouseX - xOffset)) > 250)
			{
				width = originalWidth + (parent.mouseX - xOffset);	
			}
			
			if ((originalHeight + (parent.mouseY - yOffset)) > titleBar.height)
			{
				height = originalHeight + (parent.mouseY - yOffset);
			}
    	}

		protected function stopResizing(event:Event):void 
		{
			CursorManager.removeCursor(CursorManager.currentCursorID);
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, resizing, true);
	        systemManager.removeEventListener(MouseEvent.MOUSE_UP, stopResizing, true);
	        systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, stopResizing);
		}
		
	}

}