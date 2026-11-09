unit FoneForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormShow(Sender: TObject);
var
   Names:TStringList;
begin
     Names:=TStringList.Create;
     try
        Names.LoadFromFile('Names.LST');
        if Names.Count > 15 then
        begin
           Edit1.Text :=Names.Strings[ 0];
           Edit2.Text :=Names.Strings[ 1];
           Edit3.Text :=Names.Strings[ 2];
           Edit4.Text :=Names.Strings[ 3];
           Edit5.Text :=Names.Strings[ 4];
           Edit6.Text :=Names.Strings[ 5];
           Edit7.Text :=Names.Strings[ 6];
           Edit8.Text :=Names.Strings[ 7];
           Edit9.Text :=Names.Strings[ 8];
           Edit10.Text:=Names.Strings[ 9];
           Edit11.Text:=Names.Strings[10];
           Edit12.Text:=Names.Strings[11];
           Edit13.Text:=Names.Strings[12];
           Edit14.Text:=Names.Strings[13];
           Edit15.Text:=Names.Strings[14];
           Edit16.Text:=Names.Strings[15];
        end;                            
     finally
        Names.Destroy;
     end;                            
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
   Names:TStringList;
begin
     Names:=TStringList.Create;
     try
        Names.Add(Edit1.Text );
        Names.Add(Edit2.Text );
        Names.Add(Edit3.Text );
        Names.Add(Edit4.Text );
        Names.Add(Edit5.Text );
        Names.Add(Edit6.Text );
        Names.Add(Edit7.Text );
        Names.Add(Edit8.Text );
        Names.Add(Edit9.Text );
        Names.Add(Edit10.Text);
        Names.Add(Edit11.Text);
        Names.Add(Edit12.Text);
        Names.Add(Edit13.Text);
        Names.Add(Edit14.Text);
        Names.Add(Edit15.Text);
        Names.Add(Edit16.Text);
        Names.SaveToFile('Names.LST');
     finally
        Names.Destroy;
     end;                            

end;
end.
 
