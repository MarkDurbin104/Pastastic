unit DatabaseConfigF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, DBTables;

type
  TCorvusDatabaseConfigForm = class(TForm)
    BottomPanel: TPanel;
    RightPanel: TPanel;
    ApplyButton: TButton;
    CloseButton: TButton;
    Session: TSession;
    AliasStringGrid: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ApplyButtonClick(Sender: TObject);
    procedure AliasStringGridSetEditText(Sender: TObject; ACol,
      ARow: Integer; const Value: String);
  private
    { Private declarations }
		procedure FillAliasGrid;
  public
    { Public declarations }
  end;

var
  CorvusDatabaseConfigForm: TCorvusDatabaseConfigForm;

implementation

{$R *.DFM}

procedure TCorvusDatabaseConfigForm.FillAliasGrid;
var
	AliasIndex 			  : Integer;
  AliasStringList   : TStringList;
  ParamsStringList  : TStringList;
begin

	AliasStringGrid.Rows[0].CommaText := 'Alias, Path';
	AliasStringList 	:= TStringList.Create;
  ParamsStringList 	:= TStringList.Create;
	try
    Session.GetAliasNames(AliasStringList);
		AliasStringGrid.RowCount := AliasStringList.Count +1;
    AliasStringList.Sort;
    For AliasIndex := 0 to AliasStringList.Count -1 do
    begin
	    AliasStringGrid.Cells[0, AliasIndex + 1] := AliasStringList[AliasIndex];
			Session.GetAliasParams(AliasStringList[AliasIndex], ParamsStringList);
			AliasStringGrid.Cells[1, AliasIndex + 1] := ParamsStringList.Values['Path'];
    end;
  finally
	 	AliasStringList.Free;
    ParamsStringList.Free;
  end;
end;

procedure TCorvusDatabaseConfigForm.FormCreate(Sender: TObject);
var
	AliasName, AliasPath : String;
begin
 	AliasName := ParamStr(1);
  AliasPath := ParamStr(2);
  try
    If (AliasName <>  '') then Session.DeleteAlias(AliasName);
		If AliasPath <> '' then Session.AddStandardAlias(AliasName, AliasPath, '');
    Session.SaveConfigFile;
//      Session.Close;
//      Session.Open;
	finally
		FillAliasGrid;
  end;
end;

procedure TCorvusDatabaseConfigForm.CloseButtonClick(Sender: TObject);
begin
	Close;
end;

procedure TCorvusDatabaseConfigForm.FormResize(Sender: TObject);
begin
	//resize alias grid columns
  AliasStringGrid.ColWidths[1] := AliasStringGrid.Width - AliasStringGrid.ColWidths[0] - 30;
end;

procedure TCorvusDatabaseConfigForm.ApplyButtonClick(Sender: TObject);
var
	AliasIndex 			  : Integer;
  AliasStringList   : TStringList;
  ParamsStringList  : TStringList;
begin
	AliasStringList 	:= TStringList.Create;
  ParamsStringList 	:= TStringList.Create;
	try
    For AliasIndex := 1 to AliasStringGrid.RowCount  do
    begin
    	If Trim(AliasStringGrid.Cells[1, AliasIndex]) <> '' then
      begin;
        ParamsStringList.Add('PATH=' + AliasStringGrid.Cells[1, AliasIndex]);
        Session.ModifyAlias(AliasStringGrid.Cells[0, AliasIndex], ParamsStringList);
        ParamsStringList.Clear;
      end;
    end;
  	Session.SaveConfigFile;
    ApplyButton.Enabled := False;
  finally
	 	AliasStringList.Free;
    ParamsStringList.Free;
  end;

end;

procedure TCorvusDatabaseConfigForm.AliasStringGridSetEditText(
  Sender: TObject; ACol, ARow: Integer; const Value: String);
begin
	ApplyButton.Enabled := True;
end;

end.
