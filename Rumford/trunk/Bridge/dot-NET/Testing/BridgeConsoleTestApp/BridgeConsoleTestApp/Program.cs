using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using VU.iT.Bridge;

namespace BridgeConsoleTestApp
{
    class Program
    {
        static void Main(string[] args)
        {
            ConsoleMenu conMenu = new ConsoleMenu();
            conMenu.ShowConsoleMenu();
        }
    }

    class ConsoleMenu {
        int TCPport = 45000;
        
        public void ShowConsoleMenu() {
            int x;
            char menuchoice = 'x';
            string ServerStatus = "Stopped";
            BaseLib bridgelib = new BaseLib();

            while (!Char.Equals(menuchoice, 'Q')){
                menuchoice = 'x';
                Console.WriteLine("\n\n\n");
                Console.WriteLine("(1) Start Server on port " + this.TCPport + " (" + ServerStatus + ")");
                Console.WriteLine("(2) Stop Server ");
                Console.WriteLine("(3) Change Port (" + this.TCPport + ")");
                Console.WriteLine("(4) Start Broadcasting ");
                Console.WriteLine("(5) Stop Broadcasting ");
                Console.WriteLine("(6) Start Reading Broadcasts ");
                Console.WriteLine("(7) Stop Reading Broadcasts ");
                Console.WriteLine("(8)  ");
                Console.WriteLine("(9) Policy File Request ");
                Console.WriteLine("(Q) Quit ");
                Console.Write("\nEnter a Choice: ");

                x = Console.Read(); 
                Console.ReadLine();

                menuchoice = Char.ToUpper(Convert.ToChar(x));

                switch (menuchoice){
                    case '1':
                        if (bridgelib.Create_TCP_Server(this.TCPport) == 1) {
                            // server created ok 
                        } else {
                            // server already running
                        }
                        ServerStatus = "Started";
                        Console.WriteLine("TCP Server Created on Port: " + this.TCPport);
                        break;
                    case '2':
                        Console.WriteLine("TCP Stopping Server");
                        bridgelib.Stop_TCP_Server();
                        ServerStatus = "Stopped";
                        break;
                    case '3':
                        Console.Write("Enter new Port Number : ");
                        this.TCPport = Convert.ToInt32(Console.ReadLine());
                        break;
                    case '4':
                        bridgelib.StartBroadcasting();
                        break;
                    case '5':
                        bridgelib.StopBroadcasting();
                        break;
                    case '6':
                        bridgelib.StartReadingBroadcasts();
                        break;
                    case '7':
                        bridgelib.StopReadingBroadcasts();
                        break;
                    case '8':
                        break;
                    case '9':
                        bridgelib.FlashPolicyFileRequest(45001, "");
                        break;
                    default:
                        Console.WriteLine("Invalid Choice! ");
                        break;
                }
            }
        } 
    }
}

