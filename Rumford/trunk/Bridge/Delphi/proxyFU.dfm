object Form1: TForm1
  Left = 0
  Top = 0
  AlphaBlendValue = 128
  Caption = 'Form1'
  ClientHeight = 464
  ClientWidth = 852
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    852
    464)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 16
    Width = 836
    Height = 440
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    WordWrap = False
  end
  object Button1: TButton
    Left = 8
    Top = 0
    Width = 57
    Height = 17
    Caption = 'Clear'
    TabOrder = 1
    OnClick = Button1Click
  end
  object IdHTTPProxyServer1: TIdHTTPProxyServer
    Active = True
    Bindings = <>
    Intercept = IdServerInterceptLogEvent1
    IOHandler = IdServerIOHandlerStack1
    CommandHandlers = <>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '200'
    HelpReply.Code = '100'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <>
    ReplyUnknownCommand.Code = '400'
    Left = 736
    Top = 8
  end
  object IdServerIOHandlerStack1: TIdServerIOHandlerStack
    Left = 768
    Top = 8
  end
  object IdServerInterceptLogEvent1: TIdServerInterceptLogEvent
    OnLogString = IdServerInterceptLogEvent1LogString
    Left = 800
    Top = 8
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 704
    Top = 8
  end
end
