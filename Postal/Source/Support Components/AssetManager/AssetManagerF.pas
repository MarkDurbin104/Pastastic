unit AssetManagerF;

interface

uses
  AssetManager_TLB,
  AssetNodeU,
  SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, Grids, DBGrids, DBTables, ComCtrls, StdCtrls, ExtCtrls,
  GPCSErrorLine, ToolWin, StructureNodeU;

type
  TAssetManagerForm = class(TSavePosForm)
    AssetTreeImageList: TImageList;
    MainPageControl: TPageControl;
    AssetGroupTabSheet: TTabSheet;
    AssetGroupDBGrid: TDBGrid;
    AssetGroupTotalTabSheet: TTabSheet;
    AssetGroupTotalDBGrid: TDBGrid;
    AssetGroupSplitter: TSplitter;
    BottomPanel: TPanel;
    HierarchyGroupBox: TGroupBox;
    HierarchySplitter: TSplitter;
    AssetGroupTreeView: TTreeView;
    HierarchyListBox: TListBox;
    ButtonPanel: TPanel;
    RefreshButton: TButton;
    SessionLogTabSheet: TTabSheet;
    SessionLogMemo: TMemo;
    AssetDescriptionTextBatchMove: TBatchMove;
    BatchButton: TButton;
    BatchDestTable: TTable;
    ViewUpdateTimer: TTimer;
    LastGroup: TEdit;
    LastChildView: TRadioButton;
    ViewOptionsPanel: TPanel;
    ParentRadioButton: TRadioButton;
    ChildrenRadioButton: TRadioButton;
    TreeEnabledCheckBox: TCheckBox;
    HierarchyEnabledCheckBox: TCheckBox;
    ExitButton: TButton;
    TopToolBar: TToolBar;
    AssetToolButton: TToolButton;
    AssetUnitToolButton: TToolButton;
    AssetTriggerToolButton: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure RefreshButtonClick(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AssetGroupTableBeforeDelete(DataSet: TDataSet);
    procedure AssetGroupTotalTableBeforeDelete(DataSet: TDataSet);
    procedure BatchButtonClick(Sender: TObject);
    procedure ViewUpdateTimerTimer(Sender: TObject);
    procedure TreeEnabledCheckBoxClick(Sender: TObject);
    procedure HierarchyEnabledCheckBoxClick(Sender: TObject);
    procedure AssetToolButtonClick(Sender: TObject);
    procedure AssetUnitToolButtonClick(Sender: TObject);

  private
    { Private declarations }
    procedure UpdateHierarchyViews;
    function DrawAssetGroupChildren(CurrentNode : TTreeNode; AssetGroup : String) : AmStatus;
    function DrawAssetGroupParents(CurrentNode : TTreeNode; AssetGroup : String) : AmStatus;
//    function GetMulitiplier(AssetGroup, AssetChild : String) : Double;
    //returns multiplier for given parent-child relation
//    function GetMultSign(Multiplier : Double) : String;
    //returns +/- for a mulitiplier
    function GetNextImageIndex(CurrentImageIndex : Integer; NextMultiplier : Double) : Integer;
    //returns correct imageindex for next node

//    function StripMult(AssetGroup : String) : String;

//    procedure ListAssetGroupParentHierarchy(AssetGroup : String);
//    procedure ListAssetGroupChildrenHierarchy(AssetGroup : String);

  public
    { Public declarations }
    function GetAssetGroupDescription(AssetGroup : String) : String;
    procedure GetAssetGroupChildren(AssetGroup : String;
                                      var ChildrenStringList : TStringList);
    //builds stringlist of Asset group children

    procedure GetAssetGroupParents(AssetGroup : String;
                                                    var ParentsStringList : TStringList);
    //builds commatext stringlist of immediate parents and their mulitpliers of group
    function GetAssetGroupParentHierarchy(AssetGroup : String;
                                             var ParentHierarchyStringList : TStringList) :AmStatus;
    //builds stringlist of all parents in hierarchy
    function GetAssetGroupChildrenHierarchy(AssetGroup : String;
                                             var ChildrenHierarchyStringList : TStringList) : AmStatus;
    //builds stringlist of all children in hierarchy

  end;

var
  AssetManagerForm: TAssetManagerForm;

implementation

uses AssetPaletteF, AssetManagerDM, AssetUnitPaletteF, AssetBalanceF;

{$R *.DFM}

procedure TAssetManagerForm.FormCreate(Sender: TObject);
var
  CompIndex : Integer;
begin
  //activate all datasets
  For CompIndex := 0 to self.ComponentCount-1 do
  begin
    If self.Components[CompIndex] Is TBDEDataSet then
    begin
      If (Components[CompIndex] As TBDEDataSet).Name <> 'BatchDestTable' then
        (self.Components[CompIndex] As TBDEDataSet).Active := True;
    end;
  end;
end;

procedure TAssetManagerForm.RefreshButtonClick(Sender: TObject);
var
  CompIndex : Integer;
begin
  //refreshes all datasets
  For CompIndex := 0 to self.ComponentCount-1 do
  begin
    If self.Components[CompIndex] Is TBDEDataSet then
    begin
      If (self.Components[CompIndex] As TBDEDataSet).Active then
        (self.Components[CompIndex] As TBDEDataSet).Refresh;
    end;
  end;
end;

procedure TAssetManagerForm.ExitButtonClick(Sender: TObject);
begin
  Close;
end;

function TAssetManagerForm.DrawAssetGroupChildren(CurrentNode : TTreeNode; AssetGroup : String) : AMStatus;
var
  AssetGroupChildren : TStringList;
  ChildStringList : TStringList;
  ChildrenIndex : Integer;
  ChildNode : TTreeNode;
begin
  //add top level node
  If CurrentNode = nil then
  begin
    CurrentNode := AssetGroupTreeView.Items.AddChildFirst(CurrentNode,
      AssetGroup +' - ' + GetAssetGroupDescription(AssetGroup));
    CurrentNode.ImageIndex := 2;  //start +ve
  end;

  AssetGroupChildren := TStringList.Create;
  ChildStringList := TStringList.Create;
  try
    Result := GetAssetGroupChildrenHierarchy(AssetGroup,AssetGroupChildren);
    If amSuccess  = Result then  //no duplicates
    begin
      AssetGroupChildren.Clear;
      GetAssetGroupChildren(AssetGroup,AssetGroupChildren);
      For ChildrenIndex := 0 to AssetGroupChildren.Count -1 do
      begin
        ChildStringList.CommaText := AssetGroupChildren[ChildrenIndex];
        ChildNode := AssetGroupTreeView.Items.AddChild(CurrentNode,
          ChildStringList[0]
          +' -  '
          + GetAssetGroupDescription(ChildStringList[0]));
        //display multiplier
        ChildNode.ImageIndex :=
          GetNextImageIndex(CurrentNode.ImageIndex,
                          StrToIntDef(ChildStringList[1],0));
        DrawAssetGroupChildren(ChildNode,ChildStringList[0]);
        ChildNode.Collapse(False);
      end;
      CurrentNode.Expand(False);  //expand the immediate children
    end;  //if GetHierarchy (no duplicates)
  finally
    ChildStringList.Free;
    AssetGroupChildren.Free;
  end;
end;

function TAssetManagerForm.DrawAssetGroupParents(CurrentNode : TTreeNode; AssetGroup : String) : amStatus;
var
  AssetGroupParents : TStringList;
  ParentStringList : TStringList;
  ParentIndex : Integer;
  ParentNode : TTreeNode;
begin

  //add top level node
  If CurrentNode = nil then
  begin
    CurrentNode := AssetGroupTreeView.Items.AddChildFirst(CurrentNode,
      AssetGroup +' - '+ GetAssetGroupDescription(AssetGroup));
    CurrentNode.ImageIndex := 2;  //start +ve
  end;

  AssetGroupParents := TStringList.Create;
  ParentStringList := TStringList.Create;
  try
    Result := GetAssetGroupParentHierarchy(AssetGroup, AssetGroupParents);
    If amSuccess = Result then //no duplicates
    begin
      AssetGroupParents.Clear;
      GetAssetGroupParents(AssetGroup,AssetGroupParents);
      For ParentIndex := 0 to AssetGroupParents.Count -1 do
      begin
        ParentStringList.CommaText := AssetGroupParents[ParentIndex];
        ParentNode := AssetGroupTreeView.Items.AddChild(CurrentNode,
          ParentStringList[0]
          +' - '
          + GetAssetGroupDescription(ParentStringList[0]));

        //display multiplier
        ParentNode.ImageIndex :=
          GetNextImageIndex(CurrentNode.ImageIndex,
                            StrToIntDef(ParentStringList[1],0));

        DrawAssetGroupParents(ParentNode,ParentStringList[0]);
        ParentNode.Collapse(True);
      end;
      CurrentNode.Expand(False);
    end;  //if GetHierarchy (no duplicates)
  finally
    AssetGroupParents.Free;
  end;
end;

procedure TAssetManagerForm.GetAssetGroupParents(AssetGroup : String;
                                                    var ParentsStringList : TStringList);
var
  AccGroupTable     : TTable;
  ParentStringList  : TStringList; //name of parent
begin
  AccGroupTable := TTable.Create(nil);
  ParentStringList := TStringList.Create;
  try
     try
       AssetGroup := AssetGroup;
       AccGroupTable.DatabaseName := 'PSLAsset';
       AccGroupTable.TableName := 'AssetGroup';
       AccGroupTable.Active := True;
       AccGroupTable.Filter := 'AGIdentifier = ''' + AssetGroup + '''';
       AccGroupTable.Filtered := True;
       AccGroupTable.First;
       While Not AccGroupTable.EOF do
       begin
         ParentStringList.Clear;
         ParentStringList.Add(AccGroupTable.FieldByName('AGParent').AsString);
         ParentStringList.Add(AccGroupTable.FieldByName('AGMultiplier').AsString);
         ParentsStringList.Add(ParentStringList.CommaText);
         AccGroupTable.Next;
       end;
     finally
       ParentStringList.Free;
       AccGroupTable.Close;
       AccGroupTable.Free;
     end;
  except
     on E : Exception do RaiseGUIDException('{26449047-BF83-4949-A4DA-1000A994F3FE}',E);
  end;
end;

function TAssetManagerForm.GetAssetGroupParentHierarchy(AssetGroup : String;
                                                              var ParentHierarchyStringList : TStringList) : amStatus;
//builds stringlist of all parents in hierarchy
var
  ImmediateParents : TStringList;
  ParentStringList : TStringList;
  ParentHierarchy : TStringList;
  ParentIndex : Integer;
begin
  try
    Result := amSuccess;
    If AssetGroup <> '' then
    begin
      ImmediateParents := TStringList.Create;
      ParentHierarchy := TStringList.Create;
      ParentStringList := TStringList.Create;
      try
        //get and check immediate parents
        GetAssetGroupParents(AssetGroup,ImmediateParents);
        For ParentIndex := 0 to ImmediateParents.Count-1 do
        begin
          ParentStringList.CommaText := ImmediateParents[ParentIndex];
          If ParentStringList[0] = AssetGroup then
            Result := amCircular
          else
            ParentHierarchyStringList.AddStrings(ImmediateParents);
        end;
        //get hierarchy above each immediate parent
        ParentIndex := 0;
        While (ParentIndex <= ImmediateParents.Count - 1)
              and (Result = amSuccess) do
        begin
          ParentHierarchy.Clear;
          ParentStringList.CommaText := ImmediateParents[ParentIndex];
          Result := GetAssetGroupParentHierarchy(ParentStringList[0], ParentHierarchy);
          If amSuccess = Result then
            ParentHierarchyStringList.AddStrings(ParentHierarchy);
          Inc(ParentIndex);
        end;  //for each immediate parent add all parents
      finally
        ParentStringList.Free;
        ImmediateParents.Free;
        ParentHierarchy.Free;
      end;
    end;  //if Assetgroup <>''
  except
    On E : EStringListError do
      Result := amDuplicate;
    else
      raise;
  end;  //try
end;

procedure TAssetManagerForm.GetAssetGroupChildren(AssetGroup : String;
                                                      var ChildrenStringList : TStringList);
//builds stringlist of Asset group children
var
  AccGroupTable  : TTable;
  ChildStringList : TStringList;
begin
  If AssetGroup <> '' then
  begin
    AccGroupTable := TTable.Create(nil);
    ChildStringList := TStringList.Create;
    try
       try
         //find child groups
         AccGroupTable.DatabaseName := 'PSLAsset';
         AccGroupTable.TableName := 'AssetGroup';
         AccGroupTable.Active := True;
         AccGroupTable.Filter := 'AGParent = ''' + AssetGroup + '''';
         AccGroupTable.Filtered := True;
         AccGroupTable.First;
         While Not AccGroupTable.EOF do
         begin
           ChildStringList.Clear;
           ChildStringList.Add(AccGroupTable.FieldByName('AGIdentifier').AsString);
           ChildStringList.Add(AccGroupTable.FieldByName('AGMultiplier').AsString);
           ChildrenStringList.Add(ChildStringList.CommaText);
           AccGroupTable.Next;
         end;
       finally
         ChildStringList.Free;
         AccGroupTable.Close;
         AccGroupTable.Free;
       end;
    except
       on E : Exception do RaiseGUIDException('{3BA9585D-F2F9-4297-A8EA-26533DC5C124}',E);
    end;
  end;  //if AssetGroup<> ''
end;

function TAssetManagerForm.GetAssetGroupChildrenHierarchy(AssetGroup : String;
                                                              var ChildrenHierarchyStringList : TStringList) : amStatus;
//builds stringlist of all Childrens in hierarchy
var
  ImmediateChildren : TStringList;
  ChildrenHierarchy : TStringList;
  ChildrenIndex : Integer;
  ChildStringList : TStringList;
begin
  try
    Result := amSuccess;
    ImmediateChildren := TStringList.Create;
    ChildrenHierarchy := TStringList.Create;
    ChildStringList := TStringList.Create;
    try
      //get and check immediate Children
      GetAssetGroupChildren(AssetGroup,ImmediateChildren);
      For ChildrenIndex := 0 to ImmediateChildren.Count -1 do
      begin
        ChildStringList.CommaText:= ImmediateChildren[ChildrenIndex];
        If ChildStringList[0] = AssetGroup then
          Result := amCircular
        else
          ChildrenHierarchyStringList.AddStrings(ImmediateChildren);
      end;

      //get hierarchy below each immediate Children
      ChildrenIndex := 0;
      While (ChildrenIndex <= (ImmediateChildren.Count - 1))
            and (Result = amSuccess) do
      begin
        ChildrenHierarchy.Clear;
        ChildStringList.CommaText:= ImmediateChildren[ChildrenIndex];
        Result := GetAssetGroupChildrenHierarchy(ChildStringList[0], ChildrenHierarchy);
        If amSuccess = Result then
          ChildrenHierarchyStringList.AddStrings(ChildrenHierarchy);
        Inc(ChildrenIndex);
      end;  //for each immediate Children add all Childrens
    finally
      ImmediateChildren.Free;
      ChildrenHierarchy.Free;
    end;
  except
    On E : EStringListError do
      Result := amDuplicate;
    else
      Raise;
  end;
end;

procedure TAssetManagerForm.UpdateHierarchyViews;
//var
//  AssetGroup : String;

begin
{  If (self.Visible)
  and (
      (AssetGroupTreeView.Enabled) or (HierarchyListBox.Enabled)) then
  begin
    If MainPageControl.ActivePage = AssetGroupTabSheet then
    begin
      AssetGroup := AssetManagerDataModule.AssetGroupTableAGIdentifier.AsString;
    end
    else If MainPageControl.ActivePage = AssetGroupTotalTabSheet then
    begin
      AssetGroup := AssetManagerDataModule.AssetBalanceTableABIdentifier.AsString;
    end;

    If (AssetGroup <> LastGroup.Text) or (LastChildView.Checked <> ChildrenRadioButton.Checked ) then
    begin
      LastGroup.Text := AssetGroup;
      LastChildView.Checked := ChildrenRadioButton.Checked;

      If ChildrenRadioButton.Checked then
      begin
        If AssetGroupTreeView.Enabled then
        begin
          AssetGroupTreeView.Items.Clear;
          DrawAssetGroupChildren(nil,AssetGroup); //nil for current node
        end;
        If HierarchyListBox.Enabled then
          ListAssetGroupChildrenHierarchy(AssetGroup);
      end
      else If ParentRadioButton.Checked then
      begin
        If AssetGroupTreeView.Enabled then
        begin
          AssetGroupTreeView.Items.Clear;
          DrawAssetGroupParents(nil,AssetGroup); //nil for current node
        end;
        If HierarchyListBox.Enabled then
          ListAssetGroupParentHierarchy(AssetGroup);

      end;
    end;
  end;
}
end;

function TAssetManagerForm.GetAssetGroupDescription(AssetGroup : String) : String;
var
  AccGroupTable : TTable;
  VarResult : Variant;
begin
  try
    If AssetGroup <> '' then
    begin
      AccGroupTable := TTable.Create(nil);
      try
        AccGroupTable.DatabaseName := 'PSLAsset';
        AccGroupTable.TableName := 'AssetDescription';
        AccGroupTable.Active := True;
        VarResult := AccGroupTable.Lookup('ADAsset',AssetGroup,'ADDescription');
        If VarIsEmpty(VarResult) then
          result := ''
        else
          Result := VarToStr(VarResult);
      finally
        AccGroupTable.Close;
        AccGroupTable.Free;
      end;
    end;
  except
    on E : Exception do RaiseGUIDException('{D4B8A70E-586A-49E1-A237-B34727D9156E}',E);
    Result := '';
  end;
end;

{procedure TAssetManagerForm.ListAssetGroupParentHierarchy(AssetGroup : String);
var
  ParentHierarchy : TStringList;
  ListResult : amStatus;
begin
  ParentHierarchy := TStringList.Create;
  try
    ListResult := GetAssetGroupParentHierarchy(AssetGroup, ParentHierarchy);
    HierarchyListBox.Clear;
    HierarchyListBox.Items.Assign(ParentHierarchy);
    If amSuccess <> ListResult then
    begin
      HierarchyListBox.Items.Add('*Duplicate');
    end;
  finally
    ParentHierarchy.Free;
  end;
end;
}

{procedure TAssetManagerForm.ListAssetGroupChildrenHierarchy(AssetGroup : String);
var
  ChildrenHierarchy : TStringList;
  ListResult : amStatus;
begin
  ChildrenHierarchy := TStringList.Create;
  try
    ListResult := GetAssetGroupChildrenHierarchy(AssetGroup, ChildrenHierarchy);
    HierarchyListBox.Clear;
    HierarchyListBox.Items.Assign(ChildrenHierarchy);
    If amSuccess <> ListResult then
    begin
      HierarchyListBox.Items.Add('*Duplicate');
    end;
  finally
    ChildrenHierarchy.Free;
  end;
end;
}

procedure TAssetManagerForm.FormDestroy(Sender: TObject);
var
  CompIndex : Integer;
begin
  //Deactivate all datasets
  For CompIndex := 0 to self.ComponentCount-1 do
  begin
    If self.Components[CompIndex] Is TBDEDataSet then
    begin
      (self.Components[CompIndex] As TBDEDataSet).Active := False;
    end;
  end;

end;

procedure TAssetManagerForm.AssetGroupTableBeforeDelete(
  DataSet: TDataSet);
begin
  ;
end;

procedure TAssetManagerForm.AssetGroupTotalTableBeforeDelete(
  DataSet: TDataSet);
begin
  ;
end;

procedure TAssetManagerForm.BatchButtonClick(Sender: TObject);
var
  FieldIndex : Integer;
  SourceTable : TTable;
begin
  SourceTable := AssetDescriptionTextBatchMove.Source As TTable;

  With TMemo.Create(nil), SourceTable do
  begin
    For FieldIndex := 0 To FieldCount -1 do
    begin
      Text := Text + '"' + SourceTable.Fields[FieldIndex].Name + '",';
    end;
    Lines.SaveToFile('c:\GPCSBatchMove.txt');
    Free;
  end;
  AssetDescriptionTextBatchMove.Destination :=   BatchDestTable;
//  AssetDescriptionTextBatchMove.Execute;
end;

{function TAssetManagerForm.GetMulitiplier(AssetGroup, AssetChild : String) : Double;
//returns multiplier for given parent-child relation
var
  AccGroupTable : TTable;
  VarResult : Variant;
begin
  Result := 0;
  try
    If AssetGroup <> '' then
    begin
      AccGroupTable := TTable.Create(nil);
      try
        With AccGroupTable do
        begin
          DatabaseName:= 'PSLAsset';
          TableName := 'AssetGroup.db';
          Active := True;
          VarResult :=     AssetManagerDataModule.AssetGroupTable.Lookup('AGIdentifier;AGParent',
                                              VarArrayOf([AssetChild,AssetGroup]),
                                             'AGMultiplier');
          If VarIsEmpty(VarResult) then
            Result := 0
          else
            Result := VarResult;

        end;  //with table
      finally
        AccGroupTable.Free;
      end;
    end;
  except
    On E : Exception do
      Result := 0;
  end;
end;
}

{function TAssetManagerForm.StripMult(AssetGroup : String) : String;
//strips leading +/-
begin
  If AssetGroup <> '' then
    If AssetGroup[1] in ['+','-'] then
      Result := Copy(AssetGroup,2,Length(AssetGroup))
    else
      Result := AssetGroup;
end;
}


{function TAssetManagerForm.GetMultSign(Multiplier : Double) : String;
//returns +/- for a mulitiplier
begin
  If Multiplier >= 0 then
    Result := '+'
  else
    Result := '-';
end;
}

function TAssetManagerForm.GetNextImageIndex(CurrentImageIndex : Integer; NextMultiplier : Double) : Integer;
//returns correct imageindex for next node
var
  NextImageSense : Integer;
begin
  CurrentImageIndex := CurrentImageIndex - 1; // 0 -> -1 ,  1 -> 0, 2 -> 1
  If NextMultiplier > 0 then NextImageSense := 1
  else If NextMultiplier = 0 then NextImageSense := 0
  else NextImageSense := -1;

  Result := 1 + CurrentImageIndex * NextImageSense;
end;

procedure TAssetManagerForm.ViewUpdateTimerTimer(Sender: TObject);
begin
  ViewUpdateTimer.Enabled := False;
  UpdateHierarchyViews;
  ViewUpdateTimer.Enabled := True;;

end;

procedure TAssetManagerForm.TreeEnabledCheckBoxClick(Sender: TObject);
begin
  If TreeEnabledCheckBox.Checked  then
  begin
    AssetGroupTreeView.Enabled := True;
  end
  else
  begin
    AssetGroupTreeView.Items.Clear;
    AssetGroupTreeView.Enabled := False;
  end;
  ViewUpdateTimer.Enabled :=
    (HierarchyEnabledCheckBox.Checked)
    or (TreeEnabledCheckBox.Checked);
  
end;

procedure TAssetManagerForm.HierarchyEnabledCheckBoxClick(
  Sender: TObject);
begin
  If HierarchyEnabledCheckBox.Checked  then
  begin
    HierarchyListBox.Enabled := True;
  end
  else
  begin
    HierarchyListBox.Clear;
    HierarchyListBox.Enabled := False;
  end;

  ViewUpdateTimer.Enabled :=
    (HierarchyEnabledCheckBox.Checked)
    or (TreeEnabledCheckBox.Checked);
end;

procedure TAssetManagerForm.AssetToolButtonClick(Sender: TObject);
begin
  AssetPaletteForm.Visible := AssetToolButton.Down;
  AssetBalanceForm.Visible := AssetToolButton.Down;

end;

procedure TAssetManagerForm.AssetUnitToolButtonClick(Sender: TObject);
begin
  AssetUnitPaletteForm.Visible := AssetUnitToolButton.Down;
end;


end.
