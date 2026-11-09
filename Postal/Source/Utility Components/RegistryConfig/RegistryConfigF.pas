unit RegistryConfigF;

interface

uses
	Registry, RegistryEx, StringUtil,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TRegistryConfigForm = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Registry  : TRegistry;
  public
    { Public declarations }
  end;

var
  RegistryConfigForm: TRegistryConfigForm;

implementation

{$R *.DFM}

{ Find command-line switch }

procedure TRegistryConfigForm.FormCreate(Sender: TObject);
var
	KeyToDelete, KeyToRename : String;
begin
	Registry := TRegistry.Create;
  KeyToDelete := ParamStr(1);
  KeyToRename := ParamStr(2);
	If ParamStr(1) <> '' then
  	RegistryEx.DeleteKeyTree(ParamStr(1));

end;

end.
