package com.proiam.slides
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.containers.Canvas;
	
[Event(name="Email Sent OK", type="flash.events.Event")]
[Event(name="Email Error", type="flash.events.Event")]

public class Emailer extends Canvas
	{
			private var phpPath:String = "php/mail_sender.php";
			private var mTo:String;
			private var mFrom:String;
			private var mSubject:String;
			private var mMessage:String;
			private var mSenderName:String;
			private var mCompany:String;
			
			[Bindable]
			public var sendStatus:String="";

			public function send():void {
				var dataRequest:URLRequest = new URLRequest(phpPath);
				dataRequest.method = URLRequestMethod.POST;				
				
				var params:URLVariables = new URLVariables();
				params.vTo = mTo;
				params.vSubj =mSubject;
				params.vMessage = mMessage;
				params.vMail = mFrom;
				params.vName = mSenderName;
				params.vCompany = mCompany;
				
				dataRequest.data = params;
				
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
				urlLoader.addEventListener(Event.COMPLETE, urlLoaderComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR,urlLoaderIOError)
				try {
					urlLoader.load(dataRequest);
				} catch (event:Error) {
					sendStatus="ERROR - Message could not be sent";
					trace(sendStatus);
					dispatchEvent(new Event("Email Error"));
				}
			}
			private function urlLoaderIOError(event:Event):void {
					sendStatus="ERROR. Message could not be sent - "+event.type;
					trace(sendStatus);
					dispatchEvent(new Event("Email Error"));
			}
			private function urlLoaderComplete(event:Event):void {
				if (event.target.data.sent != '"OK"') {
					sendStatus="ERROR. Message could not be sent - "+event.target.data.sent;
					trace(sendStatus);
					dispatchEvent(new Event("Email Error"));
				} else {
					dispatchEvent(new Event("Email Sent OK"));
					trace("Email Sent OK");
				}
			}		
			public function Emailer(eTo:String,eFrom:String,eSubject:String,eMessage:String,sendNow:Boolean=true,eSenderName:String="",eCompany:String="") {
				mTo=eTo;
				mFrom=eFrom;
				mSubject=eSubject;
				mMessage=eMessage;
				mSenderName=eSenderName;
				mCompany=eCompany;
				if (sendNow) send();
			}
	}
}