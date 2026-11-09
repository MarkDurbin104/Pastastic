package com.cykorsystems.utils {
	import flash.net.SharedObject;
	
    public final class Configuration {
        private static const _instance:Configuration = new Configuration( ConfigurationLock );
		private static const localConfiguration:SharedObject=SharedObject.getLocal("iSocietasConfiguration");

        public function Configuration(lock:Class) {
            if ( lock != ConfigurationLock ) {
                throw new Error( "Invalid Singleton access.  Use Configuration.instance");
            }
        }
 
        public static function get instance():Configuration {
                return Configuration._instance;
        }
        public static function get localAddress():String {
			var localAddr:String=localConfiguration.data.localAddress;
			if ((localAddr==null)||(localAddr=="")) {
				localAddr="75075";
				localConfiguration.data.localAddress=localAddr;
				localConfiguration.flush();
			} 
            return localAddr;
        }
        public static function set localAddress(value:String):void {
			localConfiguration.data.localAddress=value;
			localConfiguration.flush();
        }
        public static function get loggedInUser():String {
            return localConfiguration.data.LoggedIn;
        }
        public static function set loggedInUser(value:String):void {
			localConfiguration.data.LoggedIn=value;
			localConfiguration.flush();
        }
        public static function get rememberMe():Boolean {
            return localConfiguration.data.rememberMe;
        }
        public static function set rememberMe(value:Boolean):void {
			localConfiguration.data.rememberMe=value;
			localConfiguration.flush();
        }
        public static function get fadeProductsOnDeselect():Boolean {
            return localConfiguration.data.fadeProductsOnDeselect;
        }
        public static function set fadeProductsOnDeselect(value:Boolean):void {
			localConfiguration.data.fadeProductsOnDeselect=value;
			localConfiguration.flush();
        }
        public static function get useAlternateInputDialog():Boolean {
            return localConfiguration.data.useAlternateInputDialog;
        }
        public static function set useAlternateInputDialog(value:Boolean):void {
			localConfiguration.data.useAlternateInputDialog=value;
			localConfiguration.flush();
        }
        public static function get useAlternateHelpDialog():Boolean {
            return localConfiguration.data.useAlternateHelpDialog;
        }
        public static function set useAlternateHelpDialog(value:Boolean):void {
			localConfiguration.data.useAlternateHelpDialog=value;
			localConfiguration.flush();
        }
        public static function get showMenu():Boolean {
            return localConfiguration.data.showMenu;
        }
        public static function set showMenu(value:Boolean):void {
			localConfiguration.data.showMenu=value;
			localConfiguration.flush();
        }
    }
}
class ConfigurationLock { }
