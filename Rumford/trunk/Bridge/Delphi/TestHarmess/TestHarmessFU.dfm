object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 631
  ClientWidth = 864
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    864
    631)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 40
    Width = 848
    Height = 583
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object CheckBox1: TCheckBox
    Left = 112
    Top = 8
    Width = 97
    Height = 17
    Caption = 'Empty'
    TabOrder = 2
  end
  object CheckBox2: TCheckBox
    Left = 200
    Top = 8
    Width = 97
    Height = 17
    Caption = 'Image File'
    TabOrder = 3
  end
  object CheckBox3: TCheckBox
    Left = 288
    Top = 8
    Width = 97
    Height = 17
    Caption = 'Multi Transfer'
    TabOrder = 4
  end
  object Delay1: TEdit
    Left = 424
    Top = 8
    Width = 41
    Height = 21
    TabOrder = 5
    Text = '2000'
  end
  object Delay2: TEdit
    Left = 471
    Top = 8
    Width = 41
    Height = 21
    TabOrder = 6
    Text = '2000'
  end
  object Button2: TButton
    Left = 576
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 7
    OnClick = Button2Click
  end
  object IdTCPServer1: TIdTCPServer
    Active = True
    Bindings = <>
    DefaultPort = 2000
    OnExecute = IdTCPServer1Execute
    Left = 384
    Top = 8
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 750
    OnTimer = Timer1Timer
    Left = 528
    Top = 8
  end
end
