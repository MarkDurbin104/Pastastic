using System;
using System.Data;
using System.Text;
using System.IO;
//using Mono.Data.Sqlite;  // SQLite v3 and over only
using System.Xml;
using VU.iT.Bridge;

namespace SQLLiteTest {
    class Program{
        public static void Main(string[] args){
            ConsoleMenu conMenu = new ConsoleMenu();
        }
    }

    class ConsoleMenu {
        private BridgeDatabase Bridge_db = new BridgeDatabase();
        private BaseLib Bridge = new BaseLib();

        public ConsoleMenu(){
            Console.WriteLine("OS Type : " + Bridge.IdentifyOpSys() + "\r");
            this.ShowConsoleMenu();
            //    Bridge_db.ShowConsoleMenu();
        }
        public void ShowConsoleMenu(){
            int x, rowsupdated;
            char menuchoice = 'x';
            string dbFileName = "C:\\Bridge.s3db";

            while (!Char.Equals(menuchoice, 'Q')){
                menuchoice = 'x';
                Console.WriteLine("\n\n\n");
                Console.WriteLine("(1) Execute NON-Query (create, insert, update, delete) ");
                Console.WriteLine("(2) Execute Query (select statement) ");
                Console.WriteLine("(3) Execute Scaler (select count *, etc) ");
                Console.WriteLine("(4) Check Table Exists ");
                Console.WriteLine("(5) Identify Operating System ");
                Console.WriteLine("(6) Output as XML ");
                Console.WriteLine("(7)  ");
                Console.WriteLine("(8) Change current Database (" + dbFileName + ") :");
                Console.WriteLine("(9) Test  query (select * from names) on current DB");
                Console.WriteLine("(Q) Quit ");
                Console.WriteLine("\nDatabase will be created if it doesnt exist");
                Console.Write("\nEnter a Choice: ");

                x = Console.Read(); 
                Console.ReadLine();

                menuchoice = Char.ToUpper(Convert.ToChar(x));

                switch (menuchoice){
                    case '1':
                        Console.Write("Enter NON-Query {eg - create table spam ([ham] integer)}:");
                        rowsupdated = Bridge_db.ExecuteNonQuery(Console.ReadLine(), dbFileName, false);
                        Console.WriteLine("Rows Updated=" + rowsupdated + "   (-1 = Error)");
                        break;
                    case '2':
                        Console.Write("Enter Query: ");
                        Bridge_db.DataOutputToConsole(Bridge_db.ExecuteQueryToDataReader(Console.ReadLine(), dbFileName, false));
                        break;
                    case '3':
                        Console.WriteLine("TO DO");
                      //  Console.Write("Enter Scaler Query: ");
                      //  Console.WriteLine(Bridge_db.ExecuteScalar(Console.ReadLine(), "", false));
                        break;
                    case '4':
                        Console.Write("Enter Table Name: ");
                        Console.WriteLine(Bridge_db.TableExists(Console.ReadLine(), dbFileName));
                        break;
                    case '5':
                        Console.WriteLine(Bridge.IdentifyOpSys());
                        break;
                    case '6':
                        Console.Write("Enter Query: ");
                        Console.WriteLine(Bridge_db.ConvertDataToXML(Bridge_db.ExecuteQueryToDataReader(Console.ReadLine(), dbFileName, false)));
                        break;
                    case '7':
                        Console.WriteLine("Nothing Here");
                        break;
                    case '8':
                        Console.Write("Enter New Database Filename (eg C:\\testdb.s3db): ");
                        dbFileName = Console.ReadLine();
                        break;
                    case '9':
                        Bridge_db.DataOutputToConsole(Bridge_db.ExecuteQueryToDataReader("select * from names", dbFileName, false));
                        break;
                    default:
                        Console.WriteLine("Invalid Choice! ");
                        break;
                }
            }
        } 
    }
}