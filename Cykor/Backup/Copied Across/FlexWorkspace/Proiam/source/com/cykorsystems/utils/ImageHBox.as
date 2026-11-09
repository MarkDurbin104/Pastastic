package com.cykorsystems.utils
{
	import mx.containers.HBox; 
	import mx.controls.Label; 
	import mx.core.*; 
	public class ImageHBox extends HBox {  
		protected var dp:Object;  
		protected var itemFactory:IFactory;    
		public function ImageHBox()  {   
			super();      
			setDefaults();  
		}    
		[Bindable]  
		[Inspectable]  
		public function set dataProvider(value:Object):void  {   
			dp = value;   
			createItems();  
		}  
		public function get dataProvider():Object  {   
			return dp;  
		}    
		[Bindable]  
		[Inspectable]  
		public function set itemRenderer(value:IFactory):void  {   
			itemFactory = value;   
			if(dataProvider != null)   {    
				createItems();   
			}  
		}  
		public function get itemRenderer():IFactory  {   
			return itemFactory;  
		}    
		protected function createItems(keepOld:Boolean = false):void  {   
			if(!keepOld)   {    
				removeAllChildren();   
			}   
			for each(var data:Object in dp)   {    
				var renderer:IDataRenderer = addChild(itemFactory.newInstance()) as IDataRenderer;     
				renderer.data = data;   
			}  
		}    
		protected function setDefaults():void  {   
			itemFactory = new ClassFactory(Label);  
		}   
	}
}