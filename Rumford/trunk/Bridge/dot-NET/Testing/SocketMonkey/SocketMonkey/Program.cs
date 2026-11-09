using System;

using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Net;
using System.Net.Sockets;

namespace SocketMonkey {
    class Program {
        static void Main(string[] args) {
            int udpPort = 45001;
            int count = 0;
            string choice = "";
            string SendText = "";

            IPEndPoint ReceiveEndPoint = new IPEndPoint(IPAddress.Any, udpPort);
            UdpClient udpClient   = new UdpClient(udpPort);

            try {
                udpClient.EnableBroadcast = true;
                if (args.Length == 0) {
                    // broadcast
                    Console.WriteLine("Broadcasting on Port : " + udpPort);
                  //  udpClient.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.Broadcast, 1);
                    udpClient.Connect(IPAddress.Broadcast, udpPort); // 255.255.255.255
                    SendText = "Broadcasting";
                } else {
                    // ip address
                    Console.WriteLine("Sending to " + args[0] + " on Port : " + udpPort);
                    udpClient.Connect(args[0], udpPort);
                    SendText = "Direct Connection to : " + args[0];
                }
                while (choice != "quit") {
                    Byte[] sendBytes = Encoding.ASCII.GetBytes(SendText + " (" + count++ + ")");
                    udpClient.Send(sendBytes, sendBytes.Length);

                    if (udpClient.Available > 0) {
                        IPEndPoint RemoteIpEndPoint = new IPEndPoint(IPAddress.Any, 0);
                        Byte[] receiveBytes = udpClient.Receive(ref RemoteIpEndPoint);
                        //    Byte[] receiveBytes = udpIncoming.Receive(ref RemoteIpEndPoint);
                        string returnData = Encoding.ASCII.GetString(receiveBytes);

                        Console.WriteLine("Incoming Message you received " + returnData.ToString());
                        Console.WriteLine("From " + RemoteIpEndPoint.Address.ToString() + " on port" + RemoteIpEndPoint.Port.ToString());
                    }
                    // choice = Console.ReadLine();
                    Thread.Sleep(1000);
                }
                udpClient.Close();
            } catch (Exception e) {
                Console.WriteLine(e.ToString());
                Console.ReadLine();
            }
        }
    }
}
