package com.proiam.mails
{
	public class MailServiceGroup extends MailService
	{
		public function MailServiceGroup(service:XML,iconURL:String="resources/graphics/mails_icons/") {
			setup(service,iconURL);
			setStyle("backgroundColor","#8487D4");
			setStyle("backgroundAlpha","0.25");
		}
		//override public function toString():String {
		//	return("MailServiceGroup"+listAttribs());
		//}
	}
}
