using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;


namespace IPAdressLister
{
    class Program
    {
       static void Main(string[] args)
        {
           // Gets IP addresses of the local machine
           // Get host name
           String strHostName = Dns.GetHostName();
           Console.WriteLine("Host Name: " + strHostName);

           // Find host by name
           IPHostEntry iphostentry = Dns.GetHostByName(strHostName);

           // Enumerate IP addresses
           int nIP = 0;
           foreach (IPAddress ipaddress in iphostentry.AddressList)
           {
               Console.WriteLine("IP #" + ++nIP + ": " +
                                 ipaddress.ToString());
           }
           System.Console.ReadKey();
        }
    }
}
