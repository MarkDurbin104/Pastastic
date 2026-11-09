package com.proiam.mails
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import mx.utils.StringUtil;
	import mx.containers.Canvas;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import flash.events.MouseEvent;
	import mx.controls.DataGrid;
	import mx.collections.ArrayCollection;
	import mx.containers.VBox;
	import mx.controls.Button;
	import com.cykorsystems.utils.Utils;
	import mx.controls.Text;
	import com.cykorsystems.utils.CachedURLLoader;

	public class LookUp extends VBox
	{
		public var lookupData:ArrayCollection;
		private var summaryData:ArrayCollection;
		private var headings:Array = new Array;
		private var textData:Text=new Text;
		private var startColumn:int=0;
		private var startRow:int=0;
		private var titleColumn:int=0;
		private var titleRow:int=0;

		 
		public var tariffName:String="";
		
		public function get title():String {
			return label;
		}
		public function set title(value:String):void {
			label=value;
		}
		public function lookUpValue(value:Number,columnName:String=""):Number {
			var i:int;
			var colIndex:int=1;
			if (columnName!="") {
				for (i=0;i<headings.length;i++) {
					if (headings[i] == columnName)  {
						colIndex=i;
						break;
					}
				}
			}
			for (i=0;i<lookupData.length;i++) {
				var rangeVal:Number = lookupData[i][0];
				if (rangeVal >= value) {
					if (lookupData[i].length <= colIndex) return -1;
					return lookupData[i][colIndex];
				}
			}
			return -1;
		}
		public function LookUp(tariffName:String,Path:String,File:String,startColumn:int=0,startRow:int=0,titleColumn:int=-1,titleRow:int=-1)
		{
			super();
			width=1020;
			height=1000;
			var URL:String=Path+File;
			title=File;
			this.startColumn=startColumn;
			this.startRow=startRow;
			this.titleColumn=titleColumn;
			this.titleRow=titleRow;
			this.tariffName=tariffName;
			addChild(textData);
			textData.width=1000;
			textData.height=600;
			var smLoader:CachedURLLoader = new CachedURLLoader(); 
			smLoader.addEventListener(Event.COMPLETE,lookupLoaded);
			smLoader.load(new URLRequest(URL));
		}
		private function lookupLoaded(e:Event):void{
			var q:String=e.target.data;
			var wholeCSV:Array = StringUtil.trim(q).split("\r\n");
			var params:Array = wholeCSV.slice(startRow);
			if (titleColumn>=0) {
				var titleData:Array=wholeCSV[titleRow].split(",");
				title=Utils.trimQuotes(titleData[titleColumn])+' ('+title+')';
			}
			for (var i:int=0;i <params.length;i++) {
				params[i]=params[i].split(",");
				params[i]=params[i].slice(startColumn);
			}
			lookupData=new ArrayCollection(params.slice(1));
			var sumData:Array=new Array();
			sumData.push(["Column Name","Range"]);
			headings=params[0];
			for (i=0;i<headings.length;i++) {
				if (lookupData[0].length > i) {
					var lastLine:String=lookupData[lookupData.length-1][i];
					if (lastLine.toLowerCase()=="oversized") {
						lastLine=lookupData[lookupData.length-2][i]+' and Oversized';
					}
					sumData.push([Utils.trimQuotes(headings[i]),lookupData[0][i]+'-'+lastLine]);
				} else {
					sumData.push([Utils.trimQuotes(headings[i]),"No Data!"]);
				}
			}
			var output:String=title+"\n\n";
			for (i=0;i<sumData.length;i++) {
				for (var j:int=0;j<sumData[i].length;j++) {
					if (j < sumData[i].length-1) 
						output+=sumData[i][j]+"\t\t\t\t";
					else
						output+=sumData[i][j];
				}
				output+="\n";
			}
			output+="\n";
			for (i=0;i<headings.length;i++) {
				output+=headings[i]+"\t\t";
			}
			output+="\n";
			for (i=0;i<lookupData.length;i++) {
				for (j=0;j<lookupData[i].length;j++) {
					var s:String=lookupData[i][j];
					if (s.slice(0,1)=="$") lookupData[i][j]=s.slice(1);
					if (j < lookupData[i].length-1) 
						output+=lookupData[i][j]+"\t\t\t\t";
					else
						output+=lookupData[i][j];
				}
				output+="\n";
			}
			textData.text=output;
		}
	}
}