using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Timers;
using System.Net;
using System.Net.Sockets;
using System.Xml;
using System.IO;

namespace VU.iT.Bridge
{
    public class BridgeException : Exception {
        public BridgeException(string message)
            : base(message) {
        }
        private static int CreateExceptionFile (string ExceptionFilename) {
          XmlWriter writer;
          XmlWriterSettings settings = new XmlWriterSettings();
          settings.Indent = true;
          settings.IndentChars = ("    ");
          try {
              if (!File.Exists(ExceptionFilename)) {
                  // write and create a default file
                  writer = XmlWriter.Create(ExceptionFilename, settings);
                  writer.WriteStartElement("bridge-error-log");
                  writer.WriteEndElement();  // bridge-error-log     
                  writer.Flush();
                  writer.Close();
              }
              return 0;
          } catch (Exception e) {
              BridgeException.LogExceptionToFile("File Create Error (ErrorLog)" + e.ToString());
              return -1;
          }   
    }
    public static int LogExceptionToFile(string message) {
        return LogExceptionToFile(message, "C:\\Bridglog.xml");
    }

    public static int LogExceptionToFile(string message, string LogFilePath) {
        try {
                if (!File.Exists(LogFilePath)) 
                    CreateExceptionFile(LogFilePath);

                XmlDocument doc = new XmlDocument();
                doc.Load(LogFilePath);
                XmlNode newNode = doc.CreateElement("Exception");

                XmlAttribute dtAttribute = doc.CreateAttribute("DateTime");
                dtAttribute.Value = DateTime.Now.ToString();
                newNode.Attributes.Append(dtAttribute);
                XmlAttribute msgAttribute = doc.CreateAttribute("Message");
                msgAttribute.Value = message;
                newNode.Attributes.Append(msgAttribute);

                doc.DocumentElement.AppendChild(newNode);
                doc.Save(LogFilePath); 
                return 0;
            } catch (Exception e) {
                Console.WriteLine("Failed to Log Bridge Exception");
                return -1;
                throw (e);
            }
        }
    }

    public class BaseLib
    {
      private const string BridgeLogFile = "C:\\Bridglog.xml";
      private const int MessageSize = 32768; // maybe read a reg string and default to this
      private const int UdpPort = 45001;
      private TcpListener tcpListener = null;
      private Thread listenThread;

    //  private System.Threading.Timer BroadcastThreadTimerOutgoing;
      private System.Threading.Timer BroadcastThreadTimerIncoming;
      private int UdpCount = 0;
      private UdpClient UdpConnection; // = new UdpClient(UdpPort);
      private IPEndPoint UdpRemoteIpEndPoint = new IPEndPoint(IPAddress.Any, UdpPort);
      public BridgeDatabase SQLite = new BridgeDatabase();


      public BaseLib () {
      }

    //nothing wrong with broadcast.  even when receive is failing because available==0 send continues.

    //no problem when connecting directly to an IP without broadcast.  Send and receive is ok in both directions

    //if both machines D/C then send/rec works perfectly between the 2 machines perfectly.  any other broadcast data is ignored (maybe a couple of packets get through).
    //all are being sent but not necessarily recieved.

    //direct conn from sonyvaio to acerlaptop(broadcasting) with nicklaptop also broadcasting
    //sonyvaio received a few packets from nicklaptop but reliably continued to receive from acerlaptop.
    //same thing happened between shift to nicklaptop (all simultaneously)

    // once connected on broadcast then UdpClient.Available = 0 always on broadcasting machines.
      public void StartBroadcasting() {
          UdpConnection = new UdpClient(UdpPort);
          UdpConnection.EnableBroadcast = true;
          UdpConnection.Connect(IPAddress.Broadcast, UdpPort); // 255.255.255.255
     // UdpConnection.Connect("192.168.1.102", UdpPort); //

          // Send Broadcast
          Byte[] sendBytes = Encoding.ASCII.GetBytes("VU.iT Bridge Alive (" + UdpCount++ + ")");
          Console.WriteLine("Sending : " + Encoding.ASCII.GetString(sendBytes));
          UdpConnection.Send(sendBytes, sendBytes.Length);

          // check for incoming and Recieve if Data  
          if (UdpConnection.Available > 0) {
              Byte[] receiveBytes = UdpConnection.Receive(ref UdpRemoteIpEndPoint); // Blocks until message.
              string returnData = Encoding.ASCII.GetString(receiveBytes);
              Console.WriteLine(returnData.ToString() + " from " + UdpRemoteIpEndPoint.Address.ToString() + " on port " + UdpRemoteIpEndPoint.Port.ToString());
          }
                   
//          TimerCallback timerDelegate = new TimerCallback(TransmitBroadcast);
//          AutoResetEvent autoEvent = new AutoResetEvent(false);
          
//          BroadcastThreadTimerOutgoing = new System.Threading.Timer(timerDelegate, autoEvent, 1000, 1000);

      }
      private void TransmitBroadcast(object source) {
              // Send Broadcast
        //      Byte[] sendBytes = Encoding.ASCII.GetBytes("VU.iT Bridge Alive (" + UdpCount++ + ")");
        //      Console.WriteLine("Sending : " + Encoding.ASCII.GetString(sendBytes));
        //      UdpConnection.Send(sendBytes, sendBytes.Length);

              // check for incoming and Recieve if Data  
              if (UdpConnection.Available > 0) {
                  Byte[] receiveBytes = UdpConnection.Receive(ref UdpRemoteIpEndPoint); // Blocks until message.
                  string returnData = Encoding.ASCII.GetString(receiveBytes);
                  Console.WriteLine(returnData.ToString() + " from " + UdpRemoteIpEndPoint.Address.ToString() + " on port " + UdpRemoteIpEndPoint.Port.ToString());
              }
      }
      public void StopBroadcasting() {
         // UdpSending = false;
         // UdpOutgoing.Close();
//          BroadcastThreadTimerOutgoing.Dispose();
          UdpConnection.Close();
      }

       // Only one usage of each socket address (protocol/network address/port) is normally permitted
      public void StartReadingBroadcasts() {
              TimerCallback timerDelegate = new TimerCallback(CheckIncomingBroadcasts);
              AutoResetEvent autoEvent = new AutoResetEvent(false);

              BroadcastThreadTimerIncoming = new System.Threading.Timer(timerDelegate, autoEvent, 250, 1000);
      }
      private void CheckIncomingBroadcasts(object source) {
        //  try {
            //  UdpListening = true;
            //  while (UdpListening) {
                 // if (UdpIncoming.Available > 0) {
                  if (UdpConnection.Available > 0) {
                 //     Byte[] receiveBytes = UdpIncoming.Receive(ref UdpRemoteIpEndPoint); // Blocks until message.
                      Byte[] receiveBytes = UdpConnection.Receive(ref UdpRemoteIpEndPoint); // Blocks until message.
                      string returnData = Encoding.ASCII.GetString(receiveBytes);
                      Console.WriteLine(returnData.ToString() + " from " + UdpRemoteIpEndPoint.Address.ToString() + " on port " + UdpRemoteIpEndPoint.Port.ToString());
                  }
            //  }
         // } catch (SocketException) {
              // will bomb when UdpIncoming is closed during a blocking call  WSACancelBlockingCall
         // }
      }
      public void StopReadingBroadcasts() {
        //  UdpListening = false;
        //  UdpIncoming.Close();
          BroadcastThreadTimerIncoming.Dispose();
      }

      public int Create_TCP_Server(int port) {
          try {
              if (this.tcpListener == null) {
                  // create listener on port (port) and listen for client activity on all network interfaces (0.0.0.0)
                  this.tcpListener = new TcpListener(IPAddress.Any, port);
              }
              this.listenThread = new Thread(new ThreadStart(ListenForClients));
              this.listenThread.Start();
              return 1;
          } catch (SocketException e) {
              BridgeException.LogExceptionToFile("Failed to Create TCP Server :" + e.ToString());
              return -1;
              throw (e);
          }
      }

      public void Stop_TCP_Server() { 
          try {
               if (this.tcpListener != null) {
                   this.listenThread.Abort();                       
                   this.tcpListener.Stop(); // does not kill any active connections.
               }
          } catch (SocketException e) {
              BridgeException.LogExceptionToFile("Error Stopping TCP Server :" + e.ToString());
              throw (e);
          }
      }

      private void ListenForClients() {
          try {
              this.tcpListener.Start();
              while (true) {
                  //AcceptTcpClient blocks until a client has connected to the server 
                  //and returns a TCPClient to send and receive data
                //  if (tcpListener.Pending()) {
                      TcpClient client = this.tcpListener.AcceptTcpClient();

                      // client accepted so we should listen for another one
                      // or bridge should retry until conn is open

                      //create a thread to handle communication with this individual client
                      Thread clientThread = new Thread(new ParameterizedThreadStart(HandleClientComm));
                      clientThread.Start(client); // pass the TCPClient in as param for "HandleClientComm"
               //   }
              }
          } catch (SocketException e) {
              BridgeException.LogExceptionToFile("TCP Listener Error (ListenForClients)");
              throw (e);
          }
      }

      private void HandleClientComm(object client) {  
          // client is now lost to the thread.  maybe keep track of them in an array.  do i need to?
          TcpClient tcpClient = (TcpClient)client;
          NetworkStream clientStream = tcpClient.GetStream();
          string DataRecieved;

          byte[] message = new byte[MessageSize];
          int bytesRead;

          while (true) {
              bytesRead = 0;

              try {
                  bytesRead = clientStream.Read(message, 0, MessageSize); //blocks until a client sends a message use pending or something
              } catch (SocketException e) {
                  BridgeException.LogExceptionToFile("Socket Exception has Occured:" + e.ToString());
                  break; 
              }
              if (bytesRead == 0) {
                  break; //the client has disconnected from the server
              }

              //message has been received - Process It
              ASCIIEncoding encoder = new ASCIIEncoding();
              DataRecieved = encoder.GetString(message, 0, bytesRead);
              ProcessTcpDataReceived(tcpClient, DataRecieved);
          }
          tcpClient.Close();
      }

      private void ProcessTcpDataReceived(TcpClient tcpClient, string DataReceived) {
          string SendData = String.Empty;

          try {
              XmlTextReader xmlreader = new XmlTextReader(new StringReader(DataReceived));
              xmlreader.XmlResolver = null;
              xmlreader.WhitespaceHandling = WhitespaceHandling.None;
              //   XmlTextReaderSettings settings = new XmlReaderSettings();

              while (xmlreader.Read()) {
              //    xmlreader.MoveToContent();
                  
                  switch (xmlreader.NodeType) {
                      case XmlNodeType.XmlDeclaration:  //ignore eg. <?xml version='1.0'?>
                          break;
                      case XmlNodeType.Element:
                          if (xmlreader.Name.ToUpper() == "POLICY-FILE-REQUEST") {
                              SendToClient(tcpClient, FlashPolicyFileRequest(-1, DataReceived));
                          } else if (xmlreader.Name.ToUpper() == "QUERY") {
                              SendData = ProcessQueryReceived(xmlreader);
                              SendToClient(tcpClient, SendData);
                          } else if (xmlreader.Name.ToUpper() == "OPERATING-SYSTEM") {
                              SendToClient(tcpClient, "<OS Type=\"" + IdentifyOpSys() + "\"/>");
                          } else if (xmlreader.Name.ToUpper() == "SCHEMA-REQUEST") {
                              SendToClient(tcpClient, "<NotImplemented/>");  //TODO
                          } else if (xmlreader.Name.ToUpper() == "ERROR-LOG-REQUEST") {
                              SendToClient(tcpClient, XmlFileAsString(BridgeLogFile));
                          }
                          break;
                      case XmlNodeType.Text:
                          Console.Write(xmlreader.Value);
                          break;
                      case XmlNodeType.CDATA:
                          Console.Write("<![CDATA[{0}]]>", xmlreader.Value);
                          break;
                      case XmlNodeType.ProcessingInstruction:
                          Console.Write("<?{0} {1}?>", xmlreader.Name, xmlreader.Value);
                          break;
                      case XmlNodeType.Comment:
                          Console.Write("<!--{0}-->", xmlreader.Value);
                          break;
                      case XmlNodeType.Document:
                          break;
                      case XmlNodeType.DocumentType:
                          Console.Write("<!DOCTYPE {0} [{1}]", xmlreader.Name, xmlreader.Value);
                          break;
                      case XmlNodeType.EntityReference:
                          Console.Write(xmlreader.Name);
                          break;
                      case XmlNodeType.EndElement:
                          Console.Write("</{0}>", xmlreader.Name);
                          break;
                  }       
              }
              xmlreader.Close();
          } catch (XmlException e) {
              BridgeException.LogExceptionToFile("XML Parsing Error :" + e.ToString());
              SendToClient(tcpClient, "<XmlException/>");
          } catch (BridgeException e) {
              BridgeException.LogExceptionToFile("Error Processing TCP Data Received :" + e.ToString());
              SendToClient(tcpClient, "<TcpException/>");
          }
      }
      // returns the query result as a string
      private string ProcessQueryReceived(XmlTextReader xmlreader) {
          string QueryType = "DataQuery", 
                 sql       = String.Empty, 
                 dbPath    = "C:\\Bridge.s3db";
          bool Transaction = false;

          if (xmlreader.HasAttributes) {
              xmlreader.MoveToFirstAttribute();
              do {
                  if (xmlreader.Name.ToUpper() == "QUERYTYPE")
                      QueryType = xmlreader.Value;
                  else if (xmlreader.Name.ToUpper() == "SQL")
                      sql = xmlreader.Value;
                  else if (xmlreader.Name.ToUpper() == "DATABASE")
                      dbPath = xmlreader.Value;
                  else if ((xmlreader.Name.ToUpper() == "TRANSACTION") && (xmlreader.Value.ToUpper() == "TRUE"))
                      Transaction = true;
              } while (xmlreader.MoveToNextAttribute());
          }

          if (sql != String.Empty) {
              if (QueryType.ToUpper() == "DATAQUERY")
                  return SQLite.ConvertDataToXML(SQLite.ExecuteQueryToDataReader(sql, dbPath, Transaction));
              else if (QueryType.ToUpper() == "NONQUERY") {
                  SQLite.ExecuteNonQuery(sql, dbPath, Transaction);
                  return String.Empty;
              } else if (QueryType.ToUpper() == "SCALER") {
                  // SQLite.ExecuteScalar(sql, dbPath, Transaction);
                  BridgeException.LogExceptionToFile("ExecuteScaler() Not Implemented");
                  return "<NotImplemented/>";
              }
          } else {
              throw new XmlException("<Query> 'sql' Attribute incorrect or missing");
          }
          return String.Empty;
          
      }
      private void SendToClient(TcpClient ClientToSend, string ToSend){
          NetworkStream clientStream = ClientToSend.GetStream();
          ASCIIEncoding encoder = new ASCIIEncoding();
       //   byte[] buffer = encoder.GetBytes("Echo from Server "  + Dns.GetHostName() + " : "+ ToSend);

          byte[] buffer = encoder.GetBytes(ToSend);
          clientStream.Write(buffer, 0, buffer.Length);
          clientStream.Flush();          
      }

      public string FlashPolicyFileRequest(int IncomingPort, string RequestString){
          string PolicyRequestFileName = "C:\\polfile.xml";
          XmlWriter writer;
          XmlWriterSettings settings = new XmlWriterSettings();
          settings.Indent = true;
          settings.IndentChars = ("    ");
          try {
              if (!File.Exists(PolicyRequestFileName)) {
                  // write and create a default file
                  writer = XmlWriter.Create(PolicyRequestFileName, settings);
                  writer.WriteStartElement("cross-domain-policy");
                  // allow-access-from
                  writer.WriteStartElement("allow-access-from");
                  writer.WriteAttributeString("domain", "127.0.0.1");
                  writer.WriteAttributeString("to-ports", "80,8000,45001,45000");
                  writer.WriteEndElement();
                  // allow-access-from              
                  writer.WriteStartElement("allow-access-from");
                  writer.WriteAttributeString("domain", "*.proiam.com");
                  writer.WriteAttributeString("to-ports", "80,8000,45001,45000");
                  writer.WriteEndElement();

                  writer.WriteEndElement();  // cross-domain-policy     
                  writer.Flush();
                  writer.Close();
              }
              return XmlFileAsString(PolicyRequestFileName);
          } catch (BridgeException e) {
              BridgeException.LogExceptionToFile("Flash PolicyFile Error :" + e.ToString());
              return "";
          }   
      }

      public string XmlFileAsString(string FileName) {
          XmlDocument doc = new XmlDocument();
          StringWriter swXML = new StringWriter();
          XmlTextWriter xmlTW = new XmlTextWriter(swXML);
          try {
              doc.Load(FileName);
              doc.WriteTo(xmlTW);
              return swXML.ToString();
          } catch (XmlException e_xml) {
              BridgeException.LogExceptionToFile("XML Error :" + e_xml.ToString());
              return String.Empty;
          } catch (Exception e_gen) {
              BridgeException.LogExceptionToFile("Error Loading File :" + e_gen.ToString());
              return String.Empty;
          }
      }

      public string IdentifyOpSys() {
          OperatingSystem os = Environment.OSVersion;
          PlatformID pid = os.Platform;
          string OS_id = "";
          switch (pid) {
              case PlatformID.Unix:
                  OS_id = "Unix";
                  break;
              case PlatformID.Win32NT:
              case PlatformID.Win32S:
              case PlatformID.Win32Windows:
                  OS_id = "Windows";
                  break;
              case PlatformID.WinCE:
                  OS_id = "WinCE";
                  break;
              default:
                  OS_id = "Unknown-PlatformID";
                  break;
          }
          return OS_id;
      }
    }
}
