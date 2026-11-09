Mark

2 functions:

CreateAllTables creates tables on SQL Server Alias from a local alias. Can call each of the ExecuteSQl lines on its own.

FillAllTables fills SQl Server tables with matching tablenames and field names. 

The only problem is the resulting tables come back as dbo.Txnlog etc when the BDE opens an ODBC Alias to SQL Server.

I couldn't get the AddToTable to work because the TFreeOnDestroyList.Destroy was bombing out. So I had to construct the script from the Delphi code. The Txnlog, MOStatus look ok. Pictures has data but I haven't tested it.