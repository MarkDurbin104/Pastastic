unit DataEntryTableF;

interface

uses
	SavePosFormU,
	DBTables, DataEntryDM,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls;

type
  TDataEntryTableForm = class(TSavePosForm)
    TablesGroupBox: TGroupBox;
    DatabaseTreeView: TTreeView;
    TableImageList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure DatabaseTreeViewExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataEntryTableForm: TDataEntryTableForm;

implementation

{$R *.DFM}

procedure TDataEntryTableForm.FormCreate(Sender: TObject);
var
  AliasList : TStringList;
  AliasNode	: TTreeNode;
begin
	AliasList := TStringList.Create;
  try
    Session.GetAliasNames(AliasList);
    AliasList.Sort;
    While AliasList.Count > 0 do
    begin
	    AliasNode := DatabaseTreeView.Items.Add(nil, AliasList[0]);
      DatabaseTreeView.Items.AddChild(AliasNode, 'Dummy');	//allows expansion
      AliasList.Delete(0);
    end;
  finally
  	AliasList.Free;
  end;
end;


procedure TDataEntryTableForm.DatabaseTreeViewExpanding(
  Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
var
	NodeIndex		: Integer;
  TableNames 	: TStringList;
  TreeNode		: TTreeNode;
begin
  Node.Selected := True;
  Node.DeleteChildren;
	Case Node.Level of
    0 :	//database
    begin
			If DataEntryDataModule.SQLServerDatabase.AliasName <> DatabaseTreeView.Selected.Text then
      begin
        DataEntryDataModule.SQLServerDatabase.Connected 		:= False;
        DataEntryDataModule.SQLServerDatabase.DatabaseName 	:= DatabaseTreeView.Selected.Text;
        DataEntryDataModule.SQLServerDatabase.AliasName 		:= DataEntryDataModule.SQLServerDatabase.DatabaseName;
        DataEntryDataModule.SQLServerDatabase.Connected 		:= True;
        DataEntryDataModule.Table.DatabaseName 							:= DataEntryDataModule.SQLServerDatabase.DatabaseName;
      end;
      TableNames := TStringList.Create;
      try
        Session.GetTableNames(DataEntryDataModule.SQLServerDatabase.DatabaseName, '', False, False, TableNames);
        TableNames.Sort;
        while TableNames.Count > 0 do
        begin
          TreeNode := DatabaseTreeView.Items.AddChild(DatabaseTreeView.Selected,	TableNames[0]);
          TreeNode.ImageIndex 		:= 1;	//table image
          TreeNode.SelectedIndex 	:= 1;	//table image

          DatabaseTreeView.Items.AddChild(TreeNode, 'Dummy');	//allows expansion
          TableNames.Delete(0);
        end;
      finally
        TableNames.Free;
      end;
    end;

    1 :	//table
    begin
      DataEntryDataModule.Table.Close;
      DataEntryDataModule.Table.TableName := DatabaseTreeView.Selected.Text;
      DataEntryDataModule.Table.Open;
      for NodeIndex :=  0 to  DataEntryDataModule.Table.FieldCount -1 do
      begin
        TreeNode := DatabaseTreeView.Items.AddChild(Node,DataEntryDataModule.Table.FieldDefs[NodeIndex].Name);
        TreeNode.ImageIndex 		:= 2;
        TreeNode.SelectedIndex 	:= 2;	//table image
      end;
    end;
  end;
end;




end.
