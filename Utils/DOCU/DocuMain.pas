unit Documain;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, StdCtrls, Grids, Outline;

type
  TForm1 = class(TForm)
    Outline1: TOutline;
    Label1: TLabel;
    PopupMenu1: TPopupMenu;
    Add1: TMenuItem;
    Delete1: TMenuItem;
    refresh1: TMenuItem;
    N1: TMenuItem;
    OpenDialog1: TOpenDialog;
    procedure Add1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Add1Click(Sender: TObject);
var
   Pos:LongInt;
   i:Integer;
begin
  OpenDialog1.Options := [ofAllowMultiSelect];
  OpenDialog1.Filter := 'C files (*.C)|*.C';
  if OpenDialog1.Execute then
  begin
    while Outline1[Outline1.SelectedItem].Level <> 1 do { move up to the project }
       Outline1.SelectedItem:=Outline1.SelectedItem-1;
    Outline1.Items[Outline1.SelectedItem].Expand;
    for i:=0 to OpenDialog1.Files.Count-1 do 
    begin
       Pos:=Outline1.Add(Outline1.SelectedItem,OpenDialog1.Files[i]);
       Outline1[Pos].ChangeLevelBy(1);
       Outline1[Outline1.Add(Pos,'function1')].ChangeLevelBy(1);
       Outline1[Outline1.Add(Pos,'function2')].ChangeLevelBy(1);
       Outline1[Outline1.Add(Pos,'function3')].ChangeLevelBy(1);
       Outline1[Outline1.Add(Pos,'function4')].ChangeLevelBy(1);
       Outline1[Outline1.Add(Pos,'function5')].ChangeLevelBy(1);
       Outline1[Outline1.Add(Pos,'function6')].ChangeLevelBy(1);
       Outline1[Outline1.Add(Pos,'function7')].ChangeLevelBy(1);
       Outline1[Outline1.Add(Pos,'function8')].ChangeLevelBy(1);
    end;
  end;
end;

end.
 