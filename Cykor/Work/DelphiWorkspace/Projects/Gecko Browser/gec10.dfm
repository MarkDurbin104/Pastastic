object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 558
  ClientWidth = 979
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblProg: TLabel
    Left = 296
    Top = 400
    Width = 32
    Height = 13
    Caption = 'lblProg'
  end
  object lblProgMax: TLabel
    Left = 352
    Top = 400
    Width = 52
    Height = 13
    Caption = 'lblProgMax'
  end
  object GeckoBrowser1: TGeckoBrowser
    Left = 0
    Top = 0
    Width = 979
    Height = 445
    Align = alClient
    TabOrder = 0
    TabStop = False
    OnStatusTextChange = GeckoBrowser1StatusTextChange
    OnProgressChange = GeckoBrowser1ProgressChange
    OnLocationChange = GeckoBrowser1LocationChange
    ExplicitTop = 16
    ExplicitWidth = 665
    ExplicitHeight = 257
  end
  object ListBox1: TListBox
    Left = 0
    Top = 445
    Width = 979
    Height = 113
    Align = alBottom
    ItemHeight = 13
    TabOrder = 1
    ExplicitTop = 280
    ExplicitWidth = 665
  end
end
