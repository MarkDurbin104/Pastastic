using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using VU.iT.Bridge;

namespace BridgeTestApp
{
    public partial class Form1 : Form
    {
        public BaseLib bridgelib = new BaseLib();

        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (bridgelib.Create_TCP_Server(Convert.ToInt32(txtPort.Text)) == 1)
            {
                lbData.Items.Add("TCP Server Created on Port: " + txtPort.Text);
            }
            else
            {
                lbData.Items.Add("TCP Server is already running on Port: " + txtPort.Text + " at the specified address");
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            lbData.Items.Add("TCP Server Stopping");
            bridgelib.Stop_TCP_Server();
           //lbData.Items.Add("TODO");
        }

        private void button3_Click(object sender, EventArgs e)
        {
           MessageBox.Show(bridgelib.FlashPolicyFileRequest(8000, "<policy-file-request>"));
        }
    }
}
