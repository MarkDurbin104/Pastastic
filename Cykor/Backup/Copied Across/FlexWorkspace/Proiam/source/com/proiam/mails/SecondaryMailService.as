package com.proiam.mails
{
	public class SecondaryMailService extends MailService
	{
		public function SecondaryMailService(service:XML) {
			super(service);
			setStyle("backgroundColor","#FFFF80");
			setStyle("backgroundAlpha","0.25");
		}
		override public function toString():String {
			return("SecondaryMailService"+listAttribs());
		}
	}
}