object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'VU.iT HTTP Cache'
  ClientHeight = 526
  ClientWidth = 653
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 295
    Width = 653
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 0
    ExplicitWidth = 298
  end
  object Memo1: TMemo
    Left = 0
    Top = 41
    Width = 653
    Height = 254
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitTop = 39
    ExplicitHeight = 253
  end
  object Memo2: TMemo
    Left = 0
    Top = 298
    Width = 653
    Height = 228
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 1
    ExplicitTop = 301
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 653
    Height = 41
    Align = alTop
    Caption = ' '
    TabOrder = 2
    ExplicitLeft = 224
    ExplicitTop = -1
    ExplicitWidth = 185
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Test'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 96
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
  object IdHTTPServer1: TIdHTTPServer
    Active = True
    Bindings = <>
    DefaultPort = 8000
    AutoStartSession = True
    ServerSoftware = 'Apache/1.3.34 Ben-SSL/1.55'
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 360
    Top = 8
  end
  object IdHTTPProxyServer1: TIdHTTPProxyServer
    Active = True
    Bindings = <>
    Intercept = IdServerInterceptLogEvent1
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '200'
    Greeting.Text.Strings = (
      'Accept-Ranges: bytes')
    HelpReply.Code = '100'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '400'
    Left = 240
    Top = 8
  end
  object IdServerInterceptLogEvent1: TIdServerInterceptLogEvent
    OnLogString = IdServerInterceptLogEvent1LogString
    Left = 272
    Top = 8
  end
end
