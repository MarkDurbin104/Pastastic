object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Shield Control Form'
  ClientHeight = 390
  ClientWidth = 667
  Color = 15201772
  TransparentColor = True
  TransparentColorValue = 15201772
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 89
    Width = 667
    Height = 301
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    TabOrder = 0
    ExplicitTop = 74
    ExplicitWidth = 531
    ExplicitHeight = 387
    ControlData = {
      4C000000F04400001C1F00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 667
    Height = 89
    Align = alTop
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 1
    object ILabel: TLabel
      Left = 380
      Top = 35
      Width = 112
      Height = 13
      Caption = 'Idle Time = 10 Seconds'
    end
    object TLabel: TLabel
      Left = 97
      Top = 35
      Width = 103
      Height = 13
      Caption = 'Transparency = 50%'
    end
    object TrackBar2: TTrackBar
      Left = 372
      Top = 8
      Width = 150
      Height = 30
      Max = 60
      Min = 1
      Frequency = 10
      Position = 10
      TabOrder = 0
      OnChange = TrackBar2Change
    end
    object ColorListBox1: TColorListBox
      Left = 245
      Top = 8
      Width = 121
      Height = 57
      Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbPrettyNames]
      ItemHeight = 16
      TabOrder = 1
      OnClick = ColorListBox1Click
    end
    object TrackBar1: TTrackBar
      Left = 89
      Top = 8
      Width = 150
      Height = 30
      Max = 255
      Frequency = 16
      Position = 128
      TabOrder = 2
      OnChange = TrackBar1Change
    end
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Exit'
      TabOrder = 3
      OnClick = Button1Click
    end
    object HButton: TButton
      Left = 552
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Hide'
      TabOrder = 4
      OnClick = HButtonClick
    end
  end
  object IdHTTPServer: TIdHTTPServer
    Bindings = <>
    DefaultPort = 8000
    OnCommandGet = IdHTTPServerCommandGet
    Left = 632
    Top = 8
  end
  object IdTCPServer: TIdTCPServer
    Bindings = <>
    DefaultPort = 45000
    OnExecute = IdTCPServerExecute
    Left = 632
    Top = 32
  end
  object ExitTimer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = ExitTimerTimer
    Left = 552
    Top = 40
  end
  object IdTimeUDP1: TIdTimeUDP
    ReceiveTimeout = 20000
    BaseDate = 2.000000000000000000
    Left = 632
    Top = 56
  end
end
