using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Runtime.InteropServices;
using VU.iT.Bridge;  

namespace VUiT_Bridge_VS
{
    public partial class VUiTBridge : ServiceBase
    {
        private BaseLib BridgeServer = new BaseLib();
        public VUiTBridge()
        {
            InitializeComponent();
            if (!System.Diagnostics.EventLog.SourceExists("VUiT Bridge"))  // Create the log if not exists and point to it
            {                                                                   
                System.Diagnostics.EventLog.CreateEventSource(
                   "VUiT Bridge", "VUiT Log");
            }
            BridgeEventLog.Source = "VUiT Bridge";
            BridgeEventLog.Log = "VUiT Log";
        }

        [DllImport("kernel32.dll")]
        public static extern bool Beep(int BeepFreq, int BeepDuration);

        protected override void OnStart(string[] args)
        {
            BridgeEventLog.WriteEntry("VUiT OnStart");
            BeepTimer.Enabled = true;

            BridgeEventLog.WriteEntry("TCIP test return " + Convert.ToString(BridgeServer.Create_TCP_Server(8000)));
        }

        protected override void OnStop()
        {
            BridgeEventLog.WriteEntry("VUiT OnStop.");
            BeepTimer.Enabled = false;
            BridgeServer.Stop_TCP_Server();
        }

        private void BeepTimer_Tick(object sender, EventArgs e)
        {
        //    System.Media.SystemSounds.Beep.Play();  // soundcard output.  seems to not work within service
            Beep(500, 100);  //  Test on a machine with a PC Speaker  (should work)
        }

    }
}
