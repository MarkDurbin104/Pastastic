unit BASE1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,Base2;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Bevel1: TBevel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  
function CreateForm(Name:PChar): TForm; export;

implementation

{$R *.DFM}

function CreateForm(Name:PChar): TForm;
begin
  result:=nil;
  if String(Name) = 'Form1' then result:=TForm1.Create(Application);
  if String(Name) = 'Form2' then result:=TForm2.Create(Application);
end;

end.
 