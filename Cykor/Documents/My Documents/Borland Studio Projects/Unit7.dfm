object Form7: TForm7
  Left = 0
  Top = 0
  Width = 698
  Height = 837
  Caption = 'Form7'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ShellListView1: TShellListView
    Left = 217
    Top = 0
    Width = 473
    Height = 803
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
    Width = 217
    Height = 803
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 1
    DesignSize = (
      217
      803)
    object ShellComboBox1: TShellComboBox
      Left = 0
      Top = 0
      Width = 201
      Height = 22
      Root = 'rfDesktop'
      ShellTreeView = ShellTreeView1
      ShellListView = ShellListView1
      UseShellImages = True
      Anchors = [akLeft, akTop, akRight]
      Constraints.MinWidth = 150
      DropDownCount = 8
      TabOrder = 0
    end
    object ShellTreeView1: TShellTreeView
      Left = 1
      Top = 24
      Width = 215
      Height = 778
      ObjectTypes = [otFolders]
      Root = 'rfDesktop'
      ShellComboBox = ShellComboBox1
      ShellListView = ShellListView1
      UseShellImages = True
      Align = alBottom
      AutoRefresh = False
      Indent = 19
      ParentColor = False
      RightClickSelect = True
      ShowRoot = False
      TabOrder = 1
    end
  end
end
