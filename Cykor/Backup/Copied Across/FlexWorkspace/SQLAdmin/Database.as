package
{
	import flash.external.ExternalInterface;
	
	public class Database
	{
		public function open(dbName:String):Object
		{
			return ExternalInterface.call("openDatabase", dbName);
		}

		public function getTables():Object
		{
			return ExternalInterface.call("executeSQL", "SELECT * FROM sqlite_master ORDER BY name");
		}

		public function executeQuery(sql:String, params:Array = null):Object
		{
			return ExternalInterface.call("executeSQL", sql, params);
		}	
	}

}