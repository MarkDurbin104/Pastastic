object CommsController: TCommsController
  Left = 0
  Top = 0
  Caption = 'CommsController'
  ClientHeight = 537
  ClientWidth = 738
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    738
    537)
  PixelsPerInch = 96
  TextHeight = 13
  object Log: TMemo
    Left = 8
    Top = 39
    Width = 722
    Height = 490
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitWidth = 607
    ExplicitHeight = 513
  end
  object Button1: TButton
    Left = 543
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Run Locally'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button4: TButton
    Left = 440
    Top = 8
    Width = 97
    Height = 25
    Caption = 'Cache Site Locally'
    TabOrder = 3
    OnClick = Button4Click
  end
  object CheckBox1: TCheckBox
    Left = 96
    Top = 12
    Width = 80
    Height = 17
    Caption = 'Logging On'
    TabOrder = 4
    Visible = False
    OnClick = CheckBox1Click
  end
  object IdHTTPServer: TIdHTTPServer
    Bindings = <>
    DefaultPort = 8000
    OnCommandGet = IdHTTPServerCommandGet
    Left = 872
    Top = 8
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 840
    Top = 8
  end
  object IdUDPServer1: TIdUDPServer
    Active = True
    BroadcastEnabled = True
    Bindings = <>
    DefaultPort = 45001
    OnUDPRead = IdUDPServer1UDPRead
    Left = 800
    Top = 8
  end
  object IdTCPServer1: TIdTCPServer
    Active = True
    Bindings = <>
    DefaultPort = 45000
    OnExecute = IdTCPServer1Execute
    Left = 768
    Top = 8
  end
  object IdTCPClient1: TIdTCPClient
    OnStatus = IdTCPClient1Status
    OnDisconnected = IdTCPClient1Disconnected
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    OnConnected = IdTCPClient1Connected
    Port = 0
    ReadTimeout = -1
    Left = 728
    Top = 8
  end
  object DeviceTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = DeviceTimerTimer
    Left = 696
    Top = 8
  end
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Compressor = IdCompressorZLibEx1
    Left = 624
    Top = 8
  end
  object IdCompressorZLibEx1: TIdCompressorZLibEx
    Left = 656
    Top = 8
  end
end
