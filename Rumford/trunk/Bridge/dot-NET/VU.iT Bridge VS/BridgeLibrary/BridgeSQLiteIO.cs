using System;
using System.Data;
using System.Text;
using System.IO;
// using Mono.Data.SqliteClient;
using Mono.Data.Sqlite;  // SQLite v3 and over only
using System.Xml;

namespace VU.iT.Bridge {
    public class BridgeDatabase {
        /// <summary>
        /// Notes
        /// SQLite's objects cannot be shared across threads and is likely to cause database corruption.
        /// You cannot have any active DataReaders open on a connection during a transaction commit.  
        /// All datareaders must be disposed of before you can rollback.

        /// TODO
        /// need to handle access if database is locked (during a transaction commit, etc)
        /// handle open/close  more orderly on a create/dispose
        /// method for GetSchemaToXML(string DBfilename)
        /// TEST
        /// Transaction operation
        /// </summary>

        private string dbFilePath = "C:\\Bridge.s3db";
        private SqliteConnection dbConnection = null;
        private SqliteTransaction dbTransaction = null;

        private string SetDBFilePath(string DBfilename)
        {
            if (DBfilename != "") {
                this.dbFilePath = DBfilename;
            }
            return this.dbFilePath;
        }

        private void OpenDB(string DBfilename, bool UseTransaction)
        {
            string connectionString = "URI=file:" + SetDBFilePath(DBfilename);

            try {
                if (!File.Exists(this.dbFilePath)) {
                    SqliteConnection.CreateFile(this.dbFilePath);
                }
                this.dbConnection = new SqliteConnection(connectionString);
                this.dbConnection.Open();
                if (UseTransaction) {
                    dbTransaction = (SqliteTransaction)this.dbConnection.BeginTransaction();
                }
            } catch (SqliteException e_sql) {
                BridgeException.LogExceptionToFile("SqliteException in OpenDB " + this.dbFilePath + " : " + e_sql.ToString());
            } catch (Exception e_gen) {
                // x64 problem throws here
                BridgeException.LogExceptionToFile("General Exception in OpenDB " + this.dbFilePath + " : " + e_gen.ToString());
            }
        }

        public void CloseDB()
        {
            try {
                if (dbTransaction != null) {
                    dbTransaction.Commit();
                    dbTransaction.Dispose();
                    dbTransaction = null;
                }
                this.dbConnection.Close();
                this.dbConnection.Dispose();
                this.dbConnection = null;

            } catch (SqliteException e) {
                BridgeException.LogExceptionToFile("Error closing DataBase file: " + this.dbFilePath);
                throw (e);
            }
        }
        public bool TableExists(string TableName, string DBfilename)
        {
            DataRow[] drowsSchema = null;
            bool ConnectionAlreadyOpen;
            try
            {
                ConnectionAlreadyOpen = (this.dbConnection != null);
                if (!ConnectionAlreadyOpen){
                    OpenDB(DBfilename, false);
                }
                drowsSchema = this.dbConnection.GetSchema("Tables").Select("Table_Name = '" + TableName + "'");  //returns a DataRow[]
                if (!ConnectionAlreadyOpen){
                    CloseDB();
                }
                return (drowsSchema.Length > 0);
            } catch (SqliteException e) {
                BridgeException.LogExceptionToFile("Error in TableExists method: " + this.dbFilePath + " " + e.ToString());
                return false;
                throw (e);
            }
        }
        /// <summary>
        /// Executes a Query that doesn't return data.  Assumes table exists and query is valid.  
        /// Use for Create/Insert/Modify/etc
        /// </summary>
        public int ExecuteNonQuery(string sql) {
            return ExecuteNonQuery(sql, "", false);
        }
        public int ExecuteNonQuery(string sql, string DBfilename) {
            return ExecuteNonQuery(sql, DBfilename, false);
        }
        public int ExecuteNonQuery(string sql, bool UseTransaction) {
            return ExecuteNonQuery(sql, "", UseTransaction);
        }
        public int ExecuteNonQuery(string sql, string DBfilename, bool UseTransaction) {
            int rowsUpdated = -1;
            try
            {
                OpenDB(DBfilename, UseTransaction);
                SqliteCommand dbcmd = new SqliteCommand(sql, this.dbConnection);
                rowsUpdated = dbcmd.ExecuteNonQuery();
                dbcmd.Dispose();
                dbcmd = null;
                CloseDB();
                return rowsUpdated;
            } catch (SqliteException e){
                BridgeException.LogExceptionToFile("Possible Query Syntax Error \" " + sql + "\"" + e.ToString());
                CloseDB();
                return -1;
                throw (e);
            }
        }
        /// <summary>
        /// Executes the query and returns the first column of the first row of the first resultset from the query
        /// maybe useful for retrieving images, etc
        /// </summary>
        public string ExecuteScalar(string sql, string DBfilename, bool UseTransaction)
        {
            OpenDB(DBfilename, UseTransaction);
            SqliteCommand dbcmd = new SqliteCommand(sql, this.dbConnection);
            object value = dbcmd.ExecuteScalar();
            CloseDB();
            if (value != null){
                return value.ToString();
            }
            return "";
        }
        // create table first 
        /// <summary>
        /// Executes a Query for data.  Assumes table exists and query is valid.  Call DB Connection is left open.
        /// </summary>
        /// <returns>IDataReader interface to the data</returns>
        public IDataReader ExecuteQueryToDataReader(string sql) {
            return ExecuteQueryToDataReader(sql, "", false);
        }
        public IDataReader ExecuteQueryToDataReader(string sql, string DBfilename) {
            return ExecuteQueryToDataReader(sql, DBfilename, false);
        }
        public IDataReader ExecuteQueryToDataReader(string sql, bool UseTransaction) {
            return ExecuteQueryToDataReader(sql, "", UseTransaction);
        }
        public IDataReader ExecuteQueryToDataReader(string sql, string DBfilename, bool UseTransaction) // execute Query and return a DataSet
        {
            IDataReader reader;
            try {
                OpenDB(DBfilename, UseTransaction);
                SqliteCommand dbcmd = new SqliteCommand(sql, this.dbConnection);

                reader = dbcmd.ExecuteReader();  // CommandText must be valid before creating the reader
                dbcmd.Dispose();
                dbcmd = null;
                return reader;
            } catch (SqliteException e) {
                BridgeException.LogExceptionToFile("Possible Query Syntax Error \" " + sql + "\"" + e.ToString());
                CloseDB();
                return null;
                throw (e);
            }
        }

        public DataSet ExecuteQueryToDataSet(string sql) {
            return ExecuteQueryToDataSet(sql, "", false);
        }
        public DataSet ExecuteQueryToDataSet(string sql, string DBfilename) {
            return ExecuteQueryToDataSet(sql, DBfilename, false);
        }
        public DataSet ExecuteQueryToDataSet(string sql, bool UseTransaction) {
            return ExecuteQueryToDataSet(sql, "", UseTransaction);
        }
        public DataSet ExecuteQueryToDataSet(string sql, string DBfilename, bool UseTransaction) // execute Query and return a DataSet
        {
            try{
                OpenDB(DBfilename, UseTransaction);
                SqliteCommand dbcmd = new SqliteCommand(sql, this.dbConnection);
                SqliteDataAdapter Adap = new SqliteDataAdapter(dbcmd);
                DataSet ResultsDataSet = new DataSet();

                Adap.Fill(ResultsDataSet);
                dbcmd.Dispose();
                dbcmd = null;
                CloseDB();
                return ResultsDataSet;
            } catch (SqliteException e) {
                BridgeException.LogExceptionToFile("Possible Query Syntax Error \" " + sql + "\"" + e.ToString());
                CloseDB();
                return null;
                throw (e);
            }
        }
        /// <summary>
        /// Uses an IDataReader or DataSet to create an XML dataset as a string.  Closes DB connection on exit.
        /// </summary>
        public string ConvertDataToXML(DataSet QueryDataSet) // OVERLOADED (DataSet has performance overhead but more functionality)
        {
            // TODO find out how to format what comes back from GetXml()
            //      may be best to build an XMLWriter from the dataset like below
            try
            {
                string xml;
                xml = QueryDataSet.GetXml();
                return xml;
            } catch (SqliteException e) {
                BridgeException.LogExceptionToFile("ConvertDataToXML(DataSet)" + e.ToString());
                CloseDB();
                return "";
                throw (e);
            }
        }
        public string ConvertDataToXML(IDataReader QueryReader) // OVERLOADED
        {
            // TODO improve by reading FieldName and FieldType once and sticking them in a stringbuilder.
            //      not sure how much of a performance hit this will have but it works for the moment
            try
            {
                XmlDocument xmldoc = new XmlDocument();
                XmlWriter writer;
                StringBuilder sbXML = new StringBuilder();
                XmlWriterSettings settings = new XmlWriterSettings();
                int FieldCount = 0;
                int RecordCount = 0;

                settings.Indent = true;
                settings.IndentChars = ("    ");
                writer = XmlWriter.Create(sbXML, settings);            // save to StringBuilder
                //  writer = XmlWriter.Create("C:\\dataset.xml", settings);  // save to test file

                writer.WriteStartElement("dataset");
                writer.WriteAttributeString("Table", "");
                FieldCount = QueryReader.FieldCount;
                writer.WriteAttributeString("FieldCount", Convert.ToString(FieldCount));
                while (QueryReader.Read())
                {
                    writer.WriteStartElement("record");
                    for (int i = 0; i < FieldCount; i++)
                    {
                        writer.WriteStartElement(QueryReader.GetName(i));
                        writer.WriteAttributeString("Type", QueryReader.GetDataTypeName(i));
                        writer.WriteString(QueryReader.GetValue(i).ToString());
                        writer.WriteEndElement();
                    }
                    writer.WriteEndElement(); // record
                    RecordCount++;
                }
                writer.WriteEndElement();  // dataset   
                writer.Flush();
                QueryReader.Close();
                QueryReader = null;
                CloseDB();
                return sbXML.ToString();
            } catch (SqliteException e) {
                BridgeException.LogExceptionToFile("ConvertDataToXML(IDataReader):" + e.ToString());
                CloseDB();
                return "";
                throw (e);
            }
        }

        public void DataOutputToConsole(IDataReader QueryReader)  // test function
        {
            string record;

            try {
                while (QueryReader.Read()) {
                    record = "Record: ";
                    for (int i = 0; i < QueryReader.FieldCount; i++) {
                        record = record + QueryReader.GetString(i) + " ";
                    }
                    Console.WriteLine(record);
                }
                QueryReader.Close();
                QueryReader = null;
                CloseDB();

            } catch (SqliteException e) {
                Console.WriteLine("Exception:" + e.ToString());
                BridgeException.LogExceptionToFile(e.ToString());
            }
        }
    }
}