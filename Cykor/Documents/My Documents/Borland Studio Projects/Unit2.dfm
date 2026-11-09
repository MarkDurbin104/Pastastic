object Form2: TForm2
  Left = 0
  Top = 0
  Width = 561
  Height = 857
  Caption = 'Form2'
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
    Left = 185
    Top = 0
    Height = 823
  end
  object ShellListView1: TShellListView
    Left = 188
    Top = 0
    Width = 365
    Height = 823
    ObjectTypes = [otFolders, otNonFolders]
    Root = 'rfDesktop'
    ShellTreeView = ShellTreeView1
    ShellComboBox = ShellComboBox1
    Sorted = True
    Align = alClient
    ReadOnly = False
    HideSelection = False
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 823
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 1
    object ShellTreeView1: TShellTreeView
      Left = 0
      Top = 22
      Width = 185
      Height = 801
      ObjectTypes = [otFolders]
      Root = 'rfDesktop'
      ShellComboBox = ShellComboBox1
      ShellListView = ShellListView1
      UseShellImages = True
      Align = alClient
      AutoRefresh = False
      Indent = 19
      ParentColor = False
      RightClickSelect = True
      ShowRoot = False
      TabOrder = 0
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 185
      Height = 22
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Panel2'
      TabOrder = 1
      DesignSize = (
        185
        22)
      object ShellComboBox1: TShellComboBox
        Left = 0
        Top = 0
        Width = 187
        Height = 22
        Root = 'rfDesktop'
        ShellTreeView = ShellTreeView1
        ShellListView = ShellListView1
        UseShellImages = True
        Anchors = [akLeft, akTop, akRight, akBottom]
        DropDownCount = 8
        TabOrder = 0
      end
    end
  end
end
