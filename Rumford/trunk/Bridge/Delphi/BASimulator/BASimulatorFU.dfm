object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 598
  ClientWidth = 765
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 161
    Width = 765
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 202
    ExplicitWidth = 396
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 765
    Height = 41
    Align = alTop
    Caption = ' '
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 11
      Width = 52
      Height = 13
      Caption = 'IP Address'
    end
    object Label2: TLabel
      Left = 192
      Top = 11
      Width = 20
      Height = 13
      Caption = 'Port'
    end
    object Edit1: TEdit
      Left = 66
      Top = 8
      Width = 121
      Height = 21
      TabOrder = 0
      Text = '127.0.0.1'
    end
    object Button1: TButton
      Left = 279
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 360
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Disconnect'
      Enabled = False
      TabOrder = 2
      OnClick = Button2Click
    end
    object Edit2: TEdit
      Left = 218
      Top = 8
      Width = 55
      Height = 21
      TabOrder = 3
      Text = '2000'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 765
    Height = 120
    Align = alTop
    Caption = ' '
    TabOrder = 1
    object Memo1: TMemo
      Left = 11
      Top = 34
      Width = 746
      Height = 80
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Lines.Strings = (
        '<vuitControl>'
        '    <command>ARM</command>'
        '</vuitControl>')
      TabOrder = 0
    end
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 763
      Height = 32
      Align = alTop
      BevelOuter = bvNone
      Caption = ' '
      TabOrder = 1
      object Button3: TButton
        Left = 4
        Top = 2
        Width = 75
        Height = 25
        Caption = 'Send'
        Enabled = False
        TabOrder = 0
        OnClick = Button3Click
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 164
    Width = 765
    Height = 434
    Align = alClient
    Caption = ' '
    TabOrder = 2
    object PageControl1: TPageControl
      Left = 8
      Top = 6
      Width = 749
      Height = 428
      ActivePage = TabSheet2
      Align = alCustom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Enabled = False
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Received Data'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object DataMemo: TMemo
          Left = 0
          Top = 0
          Width = 741
          Height = 400
          Align = alClient
          Lines.Strings = (
            '')
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Decoded Image'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object TImage
          Left = 160
          Top = 368
          Width = 105
          Height = 105
        end
        object DataImage: TImage
          Left = 0
          Top = 0
          Width = 741
          Height = 400
          Align = alClient
          Stretch = True
          ExplicitWidth = 165
          ExplicitHeight = 137
        end
      end
    end
  end
  object IdTCPClient1: TIdTCPClient
    OnDisconnected = IdTCPClient1Disconnected
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    OnConnected = IdTCPClient1Connected
    Port = 2000
    ReadTimeout = -1
    Left = 440
    Top = 8
  end
  object Timer1: TTimer
    Interval = 2000
    OnTimer = Timer1Timer
    Left = 472
    Top = 8
  end
end
