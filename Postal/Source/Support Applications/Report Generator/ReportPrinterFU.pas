unit ReportPrinterFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,ReportIDSU, ExtCtrls,StringUtil,GPCSGUID;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    RepDef: TEdit;
    Button1: TButton;
    RepName: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    User: TEdit;
    Label4: TLabel;
    FDate: TEdit;
    Label5: TLabel;
    TDate: TEdit;
    Office: TEdit;
    WSNo: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Button2: TButton;
    Button3: TButton;
    OD: TOpenDialog;
    RadioGroup1: TRadioGroup;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    ReportNodes:TReportsNode;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
procedure TForm1.Button1Click(Sender: TObject);
var
  S:String;
begin
   if OD.Execute then
   begin
      S:='';
      if ReportNodes <> nil then 
      begin
         S:=RepName.Text;
         ReportNodes.RemoveTitles(RepName.Items);
         ReportNodes.Free;
      end;
      ReportNodes:=TReportsNode.Create('Reports',OD.FileName,1);
      ReportNodes.ParseFile(ExtractFilePath(OD.FileName),OD.FileName,1);
      ReportNodes.PutInReportTitles(RepName.Items);
      RepName.Sorted:=True;
      RepName.Text:=S;
      RepName.ItemIndex:=RepName.Items.IndexOf(S);
      RepDef.Text:=OD.FileName;
   end;
end;

function StrToPeriod(DateS:String):Integer;
var
   PDate:TDateTime;
   Y:Word;
   M:Word;
   D:Word;
begin
   D:=StrToIntDef(Copy(DateS,1,2),1);
   M:=StrToIntDef(Copy(DateS,4,2),1);
   if Length( DateS ) >= 10 then
      Y := StrToIntDef(Copy(DateS,7,4),1998)
   else
   begin
      Y:=StrToIntDef(Copy(DateS,7,2),98);
      if Y < 80 then Inc(Y,100);
      Inc(Y,1900);
   end ;
   PDate:=EncodeDate(Y,M,D);
   Result:=Trunc(PDate)-DaysUntil_010198;
end;
procedure TForm1.Button2Click(Sender: TObject);
var
   ReportNode:TReportNode;
   FD:Integer;
   TD:Integer;
begin
   ReportNode:=ReportNodes.ReportNamed(TStringObject(RepName.Items.Objects[RepName.ItemIndex]).Value);
   if ReportNode <> nil then
   begin
      FD:=StrToPeriod(FDate.Text);
      TD:=StrToPeriod(TDate.Text);
      ReportNode.ShowEmptyReports:=True;
      ReportNode.Execute(User.Text,StrToIntDef(Office.Text,0),StrToIntDef(WSNo.Text,0),FD,TD,False);
   end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   FDate.Text:=FormatDateTime('dd/mm/yyyy',Now);
   TDate.Text:=FDate.Text;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
   if ReportNodes <> nil then
   begin
//      ReportNodes.RemoveTitles(RepName.Items);
      ReportNodes.Free;
   end;
end;

end.
