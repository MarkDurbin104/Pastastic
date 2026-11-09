package com.cykorsystems.CoverFlow
{
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.Panel;
	import mx.controls.Label;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.containers.Panel;
	import mx.controls.Image;
	import mx.controls.Spacer;
	import mx.core.Container;
	import flash.events.MouseEvent;
	import mx.controls.Button;
	import mx.events.EffectEvent;
	import mx.effects.*;
	import mx.containers.ViewStack;
	import flash.net.SharedObject;
	import flash.display.StageScaleMode;
	import com.cykorsystems.utils.Singleton;

	public class Menus extends Canvas
	{
		public var menuList:ArrayCollection;
		public var mainMenu:MenuBG;
		public var currentMenu:Array = new Array;
		private var menus:XML;
		private var buttonWidth:int = 114;
		private var buttonStep:int = 4;
		private var buttonIndent:int = buttonWidth / buttonStep;
		
		public function Menus(themenus:XML)
		{ 
			super();
			parseMenus(themenus);
	        currentMenu.push(mainMenu);
		}
		private function mouseClick(curEvt:MouseEvent):void {
			var ButtonPressed:String;
			var Items:Array;
			
			ButtonPressed=curEvt.currentTarget.id;
			Items=ButtonPressed.split("=");
			var execVal:String=Items[1];
			Items=execVal.split("."); 
			for each (var item:String in Items) {
	     		trace("item "+item);
			}
			if ((Items[0]=="logoff();") || (Items[0]=="lock();")) {
				Singleton.LoggedIn="";
//				vs.selectedIndex=0;
//				home(mainCanvas);
				return;
			}
			if (Items[0]=="menu") {
				for each (var panel:VBox in menuList) {
					if (panel.id == Items[1])  {
						var cm:Container = currentMenu[currentMenu.length-1]
//						putMenuAway(cm);
						panel.x=0;
//						mainCanvas.addChild(panel);
						currentMenu.push(panel);
//						prevBtn.visible=true;
//						homeBtn.visible=true;
						break;
					}
				}
			} else {
				cm=currentMenu[currentMenu.length-1]
//				putMenuAway(cm);
				currentMenu.push(new VBox());
//				prevBtn.visible=true;
//				homeBtn.visible=true;
			}
			if (Items[0]=="mails();") {
//				fs.selectedIndex=1;
			}
		}
		public function parseMenus(themenus:XML): void 
		{
   				menus=themenus;
				menuList= new ArrayCollection();;
   			
		        var xl:XMLList=new XMLList(menus.menu);
				
		        for (var i:int=0;i<xl.length();i++)
		        {
		        	var menuPanel:MenuBG;
		        	var menuGroup:MenuGroup;
		        	var menuButton:MenuButton;
		        	var name:Label;
		        	var icon:Image;
		        	var keyHB:HBox;
		        	var tmpHB:HBox;
		        	var tmpVB:VBox;
		        	var spacer:Spacer;
		        	var buttonIndex:int=0;
		        	
		        	menuPanel =new MenuBG();
//		        	mainCanvas.addChild(menuPanel);

        			menuPanel.creationPolicy="all";

					menuPanel.id=xl[i].@name;
		        	menuList.addItem(menuPanel);
		        	if (menuPanel.id=="main") mainMenu=menuPanel;
		        	if (xl[i].icon+xl[i].@icon != "") menuPanel.picture="resources/"+xl[i].icon+xl[i].@icon;
		        	menuPanel.title=xl[i].caption+xl[i].@caption;
		        	
		         	if (xl[i].hasOwnProperty("group")) {
			        	var gi:int=0;
			         	for each(var group:XML in xl[i].group) {
				        	menuGroup=new MenuGroup();	menuPanel.addChild(menuGroup); 
							var hasIcon:Boolean=(group.attribute("icon").length() > 0) || group.hasOwnProperty("icon");
							var hasCaption:Boolean=(group.attribute("caption").length() > 0) || group.hasOwnProperty("caption");

				        	if (hasIcon)  menuGroup.picture="resources/"+group.icon+group.@icon; 
				        	if (hasCaption)  menuGroup.title=group.caption+group.@caption;
			        		menuGroup.hasBorder(hasIcon || hasCaption);
				        	
			         		spacer=new Spacer();	menuGroup.addChild(spacer); spacer.width=gi*buttonIndent; spacer.height=100; 
			         		
				         	for each(var gmi:XML in group.menuitem) {
				         		menuButton=new MenuButton();	menuGroup.addChild(menuButton);
				         		menuButton.width=buttonWidth; 
				         		menuButton.id=gmi.@id+"="+gmi.execute+gmi.@execute;
				         		var ht:String = gmi.helptext+gmi.@helptext;
				         		if (ht == "") {
					         		menuButton.toolTip="Touch this button for "+gmi.title+gmi.@title;
				         		} else {
					         		menuButton.toolTip=ht;
				         		}
				         		menuButton.addEventListener(MouseEvent.CLICK, mouseClick);

				         		keyHB=new HBox();	
								keyHB.setStyle("horizontalAlign","right");
				         		keyHB.buttonMode=true;
				         		menuButton.addChild(keyHB);
				         		
				         		var exec:String=gmi.execute+gmi.@execute;
								
								if (exec.slice(0,5)=="menu.") {
									name=new Label();	keyHB.addChild(name); 
						        	name.text="ooo";
						        	name.setStyle("fontWeight","bold");
						        	name.setStyle("fontSize","8");
						        	name.setStyle("color","#000000");
									spacer=new Spacer();	keyHB.addChild(spacer); 
						        	spacer.width=40;
								}


								name=new Label();	keyHB.addChild(name); 
					        	name.text=gmi.shortcut+gmi.@shortcut;
				         		name.buttonMode=true;
					        	if (name.text == "") {
					        		name.text="F"+(buttonIndex+1);
					        	}
					        	name.setStyle("fontWeight","bold");
					        	name.setStyle("color","#FFFFFF");
					        	
					        	if (gmi.icon+gmi.@icon != "") {
					        		icon=new Image();	menuButton.addChild(icon);
					        		icon.source="resources/"+gmi.icon+gmi.@icon; 
					        	}
 				         		tmpHB=new HBox();	menuButton.addChild(tmpHB);
				         		tmpHB.buttonMode=true;
								tmpHB.setStyle("horizontalAlign","left");
								name=new Label();	tmpHB.addChild(name); 
					        	name.text=gmi.caption+gmi.@caption;
				         		name.buttonMode=true;
					        	name.setStyle("fontWeight","bold");
//					        	tmpHB.setStyle("backgroundColor","#2963A2");
//								tmpHB.setStyle("borderStyle","inset");
//								tmpHB.setStyle("cornerRadius","1");
//								tmpHB.setStyle("borderColor","#A6C0B5");
//								tmpHB.setStyle("borderThickness","2");
								tmpHB.setStyle("alpha","0.8"); 
//								tmpHB.setStyle("backgroundAlpha","0.8");
					        	name.setStyle("color","#ffffff");
					        	keyHB.width=menuButton.width-6;
					        	tmpHB.width=menuButton.width-6;
					        	buttonIndex++;
				         	}
			         		tmpVB=new VBox();	menuGroup.addChild(tmpVB); tmpVB.width=(buttonWidth-buttonIndent)-(gi*buttonIndent); 
			         		gi++;
			         		gi%=buttonStep;
			         	}
		         	} else {
			        	name=new Label();	addChild(name); 
			        	name.text="-   MENU ITEMS   -";
			         	for each(var mi:XML in xl[i].menuitem) {
				        	name=new Label();	menuPanel.addChild(name); 
				        	name.text="\t["+mi.shortcut+mi.@shortcut+"] ["+mi.alt+mi.@alt+"] "+mi.title+mi.@title+"\t"+mi.execute+mi.@execute+" \t("+mi.icon+mi.@icon+")";
			         	}
		         	}
        			menuPanel.createComponentsFromDescriptors(true);
		        }
			} 
		}
	}
