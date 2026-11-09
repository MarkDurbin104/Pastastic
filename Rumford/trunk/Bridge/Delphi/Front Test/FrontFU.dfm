object Front: TFront
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Pop-Up'
  ClientHeight = 470
  ClientWidth = 631
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 0
    Width = 631
    Height = 470
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 264
    ExplicitTop = 224
    ExplicitWidth = 300
    ExplicitHeight = 150
    ControlData = {
      4C00000037410000933000000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object ApplicationEvents1: TApplicationEvents
    OnDeactivate = ApplicationEvents1Deactivate
    Left = 16
    Top = 8
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 160
    Top = 8
  end
end
