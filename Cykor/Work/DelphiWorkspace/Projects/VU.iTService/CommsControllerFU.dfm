object CommsController: TCommsController
  Left = 0
  Top = 0
  Caption = 'CommsController'
  ClientHeight = 525
  ClientWidth = 709
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
    709
    525)
  PixelsPerInch = 96
  TextHeight = 13
  object Log: TMemo
    Left = 8
    Top = 39
    Width = 568
    Height = 478
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    ExplicitWidth = 545
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Test'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 89
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 2
    OnClick = Button2Click
  end
  object DevicesLB: TListBox
    Left = 552
    Top = 39
    Width = 149
    Height = 478
    ItemHeight = 13
    TabOrder = 3
  end
  object Button3: TButton
    Left = 170
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Send'
    TabOrder = 4
    OnClick = Button3Click
  end
  object IdHTTPServer: TIdHTTPServer
    Bindings = <>
    DefaultPort = 8000
    OnCommandGet = IdHTTPServerCommandGet
    Left = 648
    Top = 8
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 616
    Top = 8
  end
  object IdUDPServer1: TIdUDPServer
    Active = True
    BroadcastEnabled = True
    Bindings = <>
    DefaultPort = 45001
    OnUDPRead = IdUDPServer1UDPRead
    Left = 584
    Top = 8
  end
  object IdTCPServer1: TIdTCPServer
    Active = True
    Bindings = <>
    DefaultPort = 45000
    OnExecute = IdTCPServer1Execute
    Left = 552
    Top = 8
  end
end
