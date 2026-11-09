{ Module          Database Server
  Unit            Form
  Copyright(c)    Postal Solutions Limited 1996..1999
  Author          ASH
  Description     Display and log errors form the rest of the Corvus system.
  Modifications   09/1998     - ASH
                                Original Release
                  25/01/1999  - ASH
                                Header comments and code formatting

}
unit DatabaseServerF;

interface

uses
  ComServ2,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GPCSErrorLine, GPCSGUID,
  Db, DBTables, StdCtrls;

type
  TDatabaseServerForm = class(TForm)
    LogMemo: TMemo;
    PSLDatabase: TDatabase;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DatabaseServerForm: TDatabaseServerForm;

implementation

{$R *.DFM}

{===============================================================================
  Class        TDatabaseServerForm
  Method       FormCreate
  Description  Activates all datasets on form
  Params       Sender : TObject - object creating form
  Result       None
________________________________________________________________________________}
procedure TDatabaseServerForm.FormCreate(Sender: TObject);
var
  CompIndex : Integer;
begin

  try
    If ComServer.StartMode <> smStandAlone then
    begin
    end;

    //activate any datasets on form
    For CompIndex := 0 to ComponentCount -1 do
    begin
      If (Components[CompIndex] is TDBDataSet) then
      begin
        (Components[CompIndex] as TDBDataSet).Active := True
      end;  //if is TDBDataSet
    end;  //for
  except
    On E : Exception do
    begin
      RaiseGUIDException('{97C28EE3-DED0-4083-8C08-FA49F88A72C8}',E);
    end;
  end;
  PSLDatabase.Params.Add('USER NAME=' + GetGPCSRegString('','UserName','psl'));
  PSLDatabase.Params.Add('PASSWORD='  + GetGPCSRegString('','Password','suvroc'));
end;

{===============================================================================
  Class         TDatabaseServerForm
  Method        FormCreate
  Description   DeActivates all datasets on form
  Params        Sender : TObject          - object closing form
                var Action : TCloseAction - customised close action
  Result        None
________________________________________________________________________________}
procedure TDatabaseServerForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  CompIndex : Integer;
begin
  try
    //close all datasets on form
    For CompIndex := 0 to ComponentCount -1 do
    begin
      If (Components[CompIndex] is TDBDataSet) then
      begin
        (Components[CompIndex] as TDBDataSet).Active := False;
      end;  //if is TDBDataSet
    end;  //for
  except
    On E : Exception do
    begin
      RaiseException($151,E);
    end;
  end;
end;

end.
