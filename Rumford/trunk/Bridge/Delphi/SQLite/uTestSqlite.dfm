object Form1: TForm1
  Left = 199
  Top = 280
  Caption = 'Test SQLite 3'
  ClientHeight = 272
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 272
    Top = 12
    Width = 241
    Height = 165
    Proportional = True
    Stretch = True
  end
  object btnTest: TButton
    Left = 24
    Top = 224
    Width = 161
    Height = 37
    Caption = 'Test SQLite 3'
    TabOrder = 0
    OnClick = btnTestClick
  end
  object btnLoadImage: TButton
    Left = 192
    Top = 224
    Width = 157
    Height = 37
    Caption = 'Load image'
    TabOrder = 1
    OnClick = btnLoadImageClick
  end
  object btnDisplayImage: TButton
    Left = 360
    Top = 224
    Width = 157
    Height = 37
    Caption = 'Display image'
    TabOrder = 2
    OnClick = btnDisplayImageClick
  end
  object Memo1: TMemo
    Left = 16
    Top = 16
    Width = 241
    Height = 185
    Lines.Strings = (
      'Memo1')
    TabOrder = 3
  end
end
