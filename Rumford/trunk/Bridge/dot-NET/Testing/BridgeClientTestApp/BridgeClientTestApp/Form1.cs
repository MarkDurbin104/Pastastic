using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Net.Sockets;
using System.Net;

namespace BridgeClientTestApp
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void btnSend_Click(object sender, EventArgs e)
        {
            byte[] message = new byte[32768];  // arry of chars
            int bytesRead;
            bool sockerror = false;

            //  TCP Client Create/Connect/Send
            TcpClient client = new TcpClient();

            IPEndPoint serverEndPoint = new IPEndPoint(IPAddress.Parse(txtIPAddress.Text), Convert.ToInt32(txtPort.Text));

            try {
                client.Connect(serverEndPoint);
            }
            catch (SocketException socketerror) {
                lbResult.Items.Add(socketerror.ToString());
                sockerror = true;
            }
            if (!sockerror) {
                NetworkStream clientStream = client.GetStream();

                ASCIIEncoding encoder = new ASCIIEncoding();
                byte[] buffer = encoder.GetBytes(txtSendString.Text);

                clientStream.Write(buffer, 0, buffer.Length);
                clientStream.Flush();

                // wait for echo
                while (true) {
                    bytesRead = 0;

                    try {
                        bytesRead = clientStream.Read(message, 0, 4096); //blocks until a client sends a message
                    }
                    catch {
                        break; //a socket error has occured
                    }

                    if (bytesRead == 0) {
                        break; //the client has disconnected from the server
                    }
                    lbResult.Items.Add(encoder.GetString(message, 0, bytesRead));
                    break;
                }
            }
            client.Close();
        }
    }
}
