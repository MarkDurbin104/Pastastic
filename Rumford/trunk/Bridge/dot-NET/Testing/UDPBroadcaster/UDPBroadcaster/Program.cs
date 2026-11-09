using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace UDPBroadcaster {
    class Program {
        public unsafe delegate int CallbackDef(Char* Data);

        [DllImport("UDP.dll", CallingConvention = CallingConvention.Winapi)]
        public static extern int UDPStartup(CallbackDef callback, int Port);

        [DllImport("UDP.dll", CallingConvention = CallingConvention.Winapi)]
        public static unsafe extern int UDPSendData(Char[] Data);

        [DllImport("UDP.dll", CallingConvention = CallingConvention.Winapi)]
        public static extern void UDPShutdown();

        public static unsafe int OnDataReceived(Char* Data) {
            return 0;
        }

        static void Main(string[] args) {
            string ToSend = "some shit";
            char[] ToSendChars = ToSend.ToCharArray();
            int SendResult = -1;

            try {
                unsafe {
                    CallbackDef dataReceived = new CallbackDef(OnDataReceived);
                    SendResult = UDPStartup(dataReceived, 45001);
                    while (true) {
                         SendResult = UDPSendData(ToSendChars);
                         System.Threading.Thread.Sleep(1000);
                    }
                 //  UDPShutdown();
                }
            } catch (Exception e ) {
                throw (e);
            }            
        }
    }
}






