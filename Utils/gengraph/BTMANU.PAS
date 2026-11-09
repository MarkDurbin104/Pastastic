unit Btmanu;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls;

type
  TWaitForm = class(TForm)
    Timer1: TTimer;
    Panel1: TPanel;
    Panel2: TPanel;
    AboutForm: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Image1: TImage;
    ProductName: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    FileName:String;
    { Public declarations }
  end;

var
  WaitForm: TWaitForm;

implementation
                   
{$R *.DFM}
procedure LoadTable(FileName :String); far; 
          external 'GETDATA';
 
procedure TWaitForm.FormShow(Sender: TObject);
begin
    Timer1.Interval:=100;
end;

procedure TWaitForm.Timer1Timer(Sender: TObject);
begin
    Timer1.Interval:=0;
    try
       LoadTable(FileName);
    finally
       ModalResult := mrOK;
    end;                      
end;                      

end.
 