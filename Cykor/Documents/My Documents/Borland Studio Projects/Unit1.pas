unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,ParseNodeU, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
   Comps:TRootNode;
   FileName:String;
begin
  FileName:=Edit1.Text;
  Comps:=TRootNode.Create('Comps',FileName,0);
  Cursor:=crHourGlass;
  try
     Comps.ParseFile(ExtractFilePath(FileName),FileName,1);
  except
  end;
  Comps.Functions.AddObject('Cancel Customer',TFunctionNode.Create('Cancel Customer','M',1));
  Comps.Functions.AddObject('End Customer',TFunctionNode.Create('End Customer','M',1));
  Comps.Functions.AddObject('Receipt',TFunctionNode.Create('Receipt','M',1));
  Comps.Functions.AddObject('Exit',TFunctionNode.Create('Exit','M',1));
  Comps.Functions.AddObject('Shutdown Workstation',TFunctionNode.Create('Shutdown Workstation','M',1));
  Comps.Functions.AddObject('Complete',TFunctionNode.Create('Complete','P',1));
  Comps.Functions.AddObject('Report',TFunctionNode.Create('Report','P',1));

  Comps.SetBasedOn(Comps);

  Comps.Functions   .Sort;
  Comps.BuildOptions.Sort;
  Comps.Constants   .Sort;
  Comps.Domains     .Sort;
  Comps.Groups      .Sort;
  Comps.LogFormats  .Sort;
  Comps.LookUps     .Sort;
  Comps.PickLists   .Sort;
  Comps.Products    .Sort;
  Comps.Snippets    .Sort;
  Comps.Users       .Sort;
  Comps.WorkStations.Sort;

  for I:=0 to Comps.Groups.Count-1 do
     if Comps.Groups.Objects[I] <> nil then
        TImageNode(Comps.Groups.Objects[I]).GetItemNodeCount;
  for I:=0 to Comps.Products.Count-1 do
  begin
     if Comps.Products.Objects[I] <> nil then
     begin
        TImageNode(Comps.Products.Objects[I]).GetItemNodeCount;
     end;
  end;
  for I:=0 to Comps.Users.Count-1 do
     if Comps.Users.Objects[I] <> nil then
        TUserNode(Comps.Users.Objects[I]).GetItemNodeCount;
  for I:=0 to Comps.Workstations.Count-1 do
     if Comps.Workstations.Objects[I] <> nil then
        TWorkstationNode(Comps.Workstations.Objects[I]).GetItemNodeCount;
  Cursor:=crDefault;
  ShowMessage(Comps.text);
  Comps.Free;
end;

end.
