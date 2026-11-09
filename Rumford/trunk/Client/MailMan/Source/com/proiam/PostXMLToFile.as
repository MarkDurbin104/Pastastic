package com.proiam
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	[Event(name="PostToFileOK", type="flash.events.Event")]
	[Event(name="PostToFileError", type="flash.events.Event")]

	public class PostXMLToFile
	{
//		private var phpPath:String = "php/post_to_file.php";
		//private var phpPath:String = "http://www.proiam.com/demonstration/php/post_to_file.php";
		private var phpPath:String = "http://www.proiam.com/demonstration/php/file_upload.php";

		[Bindable]
		public var sendStatus:String="";
		
		private static function toHex(n:uint):String {
            var s:String = n.toString(16);
            return '00000000'.slice(0,8-s.length)+s;
        }
        
		public function PostXMLToFile(fileName:String,value:XML)	{
			
			var boundary: String = '----------'+toHex(new Date().getDate())+toHex(new Date().getTime());
			var request: URLRequest = new URLRequest(phpPath);
			request.method = URLRequestMethod.POST;
			request.contentType = "multipart/form-data; boundary=" + boundary;
			request.data = '--'+boundary + '\r\n'
									+'Content-Disposition: form-data; name="Filename"\r\n\r\n'+fileName+'\r\n'+'--'+boundary+'\r\n'
									+'Content-Disposition: form-data; name="Filedata"; filename="'+fileName+'"\r\n'
									+'Content-Type: application/octet-stream\r\n\r\n'
									+'<?xml version="1.0" encoding="utf-8" ?>\n'
									+value
				 					+'\r\n--'+boundary + '\r\n'
									+'Content-Disposition: form-data; name="Upload"\r\n\r\n'
									+'Submit Query\r\n'
									+'--'+boundary + '--';

			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, uploadCompleted);
			try {
				loader.load(request);
				sendStatus="OK";
			} catch (error: Error) {
				sendStatus="Unable to save requested document - "+error.message;
			}
			trace(sendStatus);
		}
		private function uploadCompleted (e: Event):void {
			sendStatus=e.target.data;
			trace(sendStatus);
		}
	}
}

