using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace BeepTest
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            System.Threading.Thread.Sleep(1500);
            System.Media.SystemSounds.Beep.Play();
            System.Threading.Thread.Sleep(1500);
            System.Media.SystemSounds.Beep.Play();
        }

        [DllImport("kernel32.dll")]
        public static extern bool Beep(int BeepFreq, int BeepDuration);

        private void BeepTimer_Tick_1(object sender, EventArgs e)
        {
            // System.Media.SystemSounds.Beep.Play();
             Beep(500, 100);
        }
    }
}
