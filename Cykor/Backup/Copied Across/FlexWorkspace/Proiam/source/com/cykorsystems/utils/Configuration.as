package com.cykorsystems.utils {
	import flash.net.SharedObject;
	
    public final class Configuration {
        private static const _instance:Configuration = new Configuration( ConfigurationLock );
		private static const localConfiguration:SharedObject=SharedObject.getLocal("iSocietasConfiguration");

        public function Configuration(lock:Class) {
            if ( lock != ConfigurationLock )        {
                throw new Error( "Invalid Singleton access.  Use Configuration.instance" );
            }
        }
 
        public static function get instance():Configuration {
                return Configuration._instance;
        }
        public static function get localAddress():String {
			var localAddr:String=localConfiguration.data.localAddress;
			if ((localAddr==null)||(localAddr=="")) {
				localAddr="02138";
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
        public static function get useCrossesOnSecondary():Boolean {
            return localConfiguration.data.useCrossesOnSecondary;
        }
        public static function set useCrossesOnSecondary(value:Boolean):void {
			localConfiguration.data.useCrossesOnSecondary=value;
			localConfiguration.flush();
        }
        public static function get highlightSecondary():Boolean {
            return localConfiguration.data.highlightSecondary;
        }
        public static function set highlightSecondary(value:Boolean):void {
			localConfiguration.data.highlightSecondary=value;
			localConfiguration.flush();
        }
        public static function get fadeProductsOnDeselect():Boolean {
            return localConfiguration.data.fadeProductsOnDeselect;
        }
        public static function set fadeProductsOnDeselect(value:Boolean):void {
			localConfiguration.data.fadeProductsOnDeselect=value;
			localConfiguration.flush();
        }
        public static function get highlightExpress():Boolean {
            return localConfiguration.data.highlightExpress;
        }
        public static function set highlightExpress(value:Boolean):void {
			localConfiguration.data.highlightExpress=value;
			localConfiguration.flush();
        }
        
    }
}
class ConfigurationLock { }
