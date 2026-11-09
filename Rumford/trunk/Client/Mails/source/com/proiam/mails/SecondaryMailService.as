package com.proiam.mails
{
	public class SecondaryMailService extends MailService
	{
		public function SecondaryMailService(service:XML,iconURL:String="resources/graphics/mails_icons/") {
			setup(service,iconURL);
			setStyle("backgroundColor","#90C4B4");
			setStyle("backgroundAlpha","0.25");
		}
		//override public function toString():String {
		//	return("SecondaryMailService"+listAttribs());
		//}
	}
}