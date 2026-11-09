package com.proiam.mails
{
	public class MailServiceGroup extends MailService
	{
		public function MailServiceGroup(service:XML) {
			super(service);
			setStyle("backgroundColor","#FF80FF");
			setStyle("backgroundAlpha","0.25");
		}
		override public function toString():String {
			return("MailServiceGroup"+listAttribs());
		}
	}
}
