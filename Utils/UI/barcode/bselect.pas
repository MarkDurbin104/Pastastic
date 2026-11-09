unit bselect;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, Buttons, DB, DBTables, ZebraEMS;

type
  TLStr = class(TObject)
    S:String;
  end;
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    ComboBox1: TComboBox;
    Edit2: TEdit;
    Bevel1: TBevel;
    Label4: TLabel;
    Label5: TLabel;
    Edit3: TEdit;
    Edit4: TEdit;
    Image1: TImage;
    PopupMenu1: TPopupMenu;
    Labelreport1: TMenuItem;
    Button1: TBitBtn;
    Button2: TBitBtn;
    Label6: TLabel;
    Edit5: TEdit;
    Button3: TBitBtn;
    Button4: TBitBtn;
    Button5: TBitBtn;
    Table1: TTable;
    Memo1: TMemo;
    ZebraEMS1: TZebraEMS;
    procedure Labelreport1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private       
    function BStr(En:Integer):String;
    function mod11(Code:Integer):Char;
    procedure setupZ;
  public 
  end;

var
  Form1: TForm1;

implementation

uses breport;

{$R *.DFM}
procedure TForm1.setupZ;
begin
//  if ZebraEMS1 = nil then
//  begin
//     ZebraEMS1.Create;
//     ZebraEMS1.ServiceIndicator:= 'EE';
//     ZebraEMS1.Country:= 'AW';
//     ZebraEMS1.StartNumber:= 1000;
//     ZebraEMS1.RunLength:= 2;
//     ZebraEMS1.DataBits:= db7Bits;
//     ZebraEMS1.Parity:= ptEvenParity;
//     ZebraEMS1.BaudRate:=br9600;
//     ZebraEMS1.PortNumber:=COM1;
//  end;
end;
procedure TForm1.Labelreport1Click(Sender: TObject);
begin
   Form2.ShowModal;
end;
function TForm1.mod11(Code:Integer):Char;
var
   res,cnt:Integer;
begin
    res:=0;
    cnt:=2;
    while code > 0 do
    begin
        res:=res+cnt*(code mod 10);
        Inc(cnt);
        code:=code div 10;
    end;
    Result:=Char((11-(res mod 11))+48);
end;
function TForm1.BStr(En:Integer):String;
var
   I:Integer;
   Val:Integer;
   m:Char;
begin
  I:=10000000;
  if En = 0 then
     Val:=StrToIntDef(Edit5.Text,0)
  else
  begin
     if StrToIntDef(Edit2.Text,0) <= 0 then
        Val:=StrToIntDef(Edit5.Text,0)
     else
        Val:=StrToIntDef(Edit5.Text,0)+StrToIntDef(Edit2.Text,0)-1;
  end;
  m:=mod11(Val);
  Result:=Edit1.Text+' ';
  if Val <> 0 then
  begin
     while I > Val do
     begin
        Result:=Result+'0';
        I:=I div 10;
     end;
     Result:=Result+IntToStr(Val)+m+' ';
  end
  else
  begin
     Result:=Result+'00000000'+m+' ';
  end;
  Result:=Result+Copy(TLStr(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).S,1,2);
end;
procedure TForm1.FormCreate(Sender: TObject);
var
   LStr:TLStr;
   S:TStringList;
   LOK:Boolean;
   I:Integer;
begin
   ComboBox1.Clear;
   S:=TStringList.Create;
   try
      S.LoadFromFile('Countrys.Txt');
      for I:=0 to S.Count-1 do
      begin
         LStr:=TLStr.Create;
         LStr.S:=UpperCase(S.Strings[I]);
         ComboBox1.Items.AddObject(UpperCase(Copy(S.Strings[I],4,999)),LStr);
      end;
      S.Clear;
      S.LoadFromFile('BarPStr.Txt');
      LOK:=True;
   except
      LOK:=False;
   end;
   if LOK then
   begin
      if S.Count > 0 then Caption:=S.Strings[0];
      if S.Count > 1 then Label1.Caption:=S.Strings[1];
      if S.Count > 2 then Label2.Caption:=S.Strings[2];
      if S.Count > 3 then Label3.Caption:=S.Strings[3];
      if S.Count > 4 then Label4.Caption:=S.Strings[4];
      if S.Count > 5 then Label5.Caption:=S.Strings[5];
      if S.Count > 6 then Button1.Caption:=S.Strings[6];
      if S.Count > 7 then Button2.Caption:=S.Strings[7];
   end;
   S.Free;
end;

procedure TForm1.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
   if ((Key < #48) or (Key > #57)) and (Key <> #8) then Key:=#0;
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin
   Edit3.Text:=BStr(0);
   Edit4.Text:=BStr(1);
   if (StrToIntDef(Edit5.Text,0) <> 0) and(StrToIntDef(Edit2.Text,0) <> 0) and (ComboBox1.Text <> '') then
   begin
      Button1.Enabled:=True;
      Button2.Enabled:=True;
   end
   else
   begin
      Button1.Enabled:=False;
      Button2.Enabled:=False;
   end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
   LStr:TLStr;
   MaxVal:Integer;
   V:Integer;
   S:String;
begin
    if ComboBox1.ItemIndex >= 0 then
    begin
       Table1.Active:=True;
       with Table1 do
       begin
         FindNearest([ComboBox1.Items[ComboBox1.ItemIndex]]);
         MaxVal:=0;
         while (not Eof) 
           and (UpperCase(FieldByName('Country').AsString) = ComboBox1.Items[ComboBox1.ItemIndex]) do
         begin
            if FieldByName('EndLabel').AsInteger > MaxVal then
               MaxVal:=FieldByName('EndLabel').AsInteger;
            Next;
         end;  
       end;         
       Table1.Active:=False;
       if MaxVal = 0 then
       begin
         Edit5.Text:='0';
         Edit5.ReadOnly:=False;
         Edit5.Color:=clWindow;
         Edit5.tabStop:=True;
       end
       else
       begin
         Edit5.Text:=IntToStr(MaxVal+1);
         Edit5.ReadOnly:=True;
         Edit5.Color:=clBtnFace;
         Edit5.tabStop:=False;
       end;
       Edit3.Text:=BStr(0);
       Edit4.Text:=BStr(1);
       Edit2.Text:='0';
       Edit2.Color:=clWindow;
       Edit2.ReadOnly:=False;
       Edit2.TabStop:=True;
    end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
   ZebraEMS1.Country:=Copy(TLStr(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).S,1,2);
   ZebraEMS1.ServiceIndicator:=Edit1.Text;
   ZebraEMS1.RunLength:=StrToIntDef(Edit2.Text,0);
   ZebraEMS1.StartNumber:=StrToIntDef(Edit5.Text,0);
   Memo1.Clear;
   if ZebraEMS1.FPortOpen   then Memo1.Lines.Add('FPortOpen   True') else Memo1.Lines.Add('FPortOpen   False');
   if ZebraEMS1.FPortSetup  then Memo1.Lines.Add('FPortSetup  True') else Memo1.Lines.Add('FPortSetup  False');
   if ZebraEMS1.FPaperOut   then Memo1.Lines.Add('FPaperOut   True') else Memo1.Lines.Add('FPaperOut   False');
   if ZebraEMS1.FPaused     then Memo1.Lines.Add('FPaused     True') else Memo1.Lines.Add('FPaused     False');
   if ZebraEMS1.FBufferFull then Memo1.Lines.Add('FBufferFull True') else Memo1.Lines.Add('FBufferFull False');
   if ZebraEMS1.FCorruptRAM then Memo1.Lines.Add('FCorruptRAM True') else Memo1.Lines.Add('FCorruptRAM False');
   if ZebraEMS1.FUnderTemp  then Memo1.Lines.Add('FUnderTemp  True') else Memo1.Lines.Add('FUnderTemp  False');
   if ZebraEMS1.FOverTemp   then Memo1.Lines.Add('FOverTemp   True') else Memo1.Lines.Add('FOverTemp   False');
   if ZebraEMS1.FHeadUp     then Memo1.Lines.Add('FHeadUp     True') else Memo1.Lines.Add('FHeadUp     False');
   if ZebraEMS1.FRibonOut   then Memo1.Lines.Add('FRibonOut   True') else Memo1.Lines.Add('FRibonOut   False');
   if ZebraEMS1.FNoResponse then Memo1.Lines.Add('FNoResponse True') else Memo1.Lines.Add('FNoResponse False');
   if ZebraEMS1.FCommsError then Memo1.Lines.Add('FCommsError True') else Memo1.Lines.Add('FCommsError False');
   Memo1.Lines.Add('FStillPrinting '+IntToStr(ZebraEMS1.FStillPrinting));
   Memo1.Lines.Add('StatLine1      '+ZebraEMS1.StatLine1     );
   Memo1.Lines.Add('StatLine2      '+ZebraEMS1.StatLine2     );
   Memo1.Lines.Add('StatLine3      '+ZebraEMS1.StatLine3     );
   ZebraEMS1.Print;
   Memo1.Lines.Add(' ');
   if ZebraEMS1.FPortOpen   then Memo1.Lines.Add('FPortOpen   True') else Memo1.Lines.Add('FPortOpen   False');
   if ZebraEMS1.FPortSetup  then Memo1.Lines.Add('FPortSetup  True') else Memo1.Lines.Add('FPortSetup  False');
   if ZebraEMS1.FPaperOut   then Memo1.Lines.Add('FPaperOut   True') else Memo1.Lines.Add('FPaperOut   False');
   if ZebraEMS1.FPaused     then Memo1.Lines.Add('FPaused     True') else Memo1.Lines.Add('FPaused     False');
   if ZebraEMS1.FBufferFull then Memo1.Lines.Add('FBufferFull True') else Memo1.Lines.Add('FBufferFull False');
   if ZebraEMS1.FCorruptRAM then Memo1.Lines.Add('FCorruptRAM True') else Memo1.Lines.Add('FCorruptRAM False');
   if ZebraEMS1.FUnderTemp  then Memo1.Lines.Add('FUnderTemp  True') else Memo1.Lines.Add('FUnderTemp  False');
   if ZebraEMS1.FOverTemp   then Memo1.Lines.Add('FOverTemp   True') else Memo1.Lines.Add('FOverTemp   False');
   if ZebraEMS1.FHeadUp     then Memo1.Lines.Add('FHeadUp     True') else Memo1.Lines.Add('FHeadUp     False');
   if ZebraEMS1.FRibonOut   then Memo1.Lines.Add('FRibonOut   True') else Memo1.Lines.Add('FRibonOut   False');
   if ZebraEMS1.FNoResponse then Memo1.Lines.Add('FNoResponse True') else Memo1.Lines.Add('FNoResponse False');
   if ZebraEMS1.FCommsError then Memo1.Lines.Add('FCommsError True') else Memo1.Lines.Add('FCommsError False');
   Memo1.Lines.Add('FStillPrinting '+IntToStr(ZebraEMS1.FStillPrinting));
   Memo1.Lines.Add('StatLine1      '+ZebraEMS1.StatLine1     );
   Memo1.Lines.Add('StatLine2      '+ZebraEMS1.StatLine2     );
   Memo1.Lines.Add('StatLine3      '+ZebraEMS1.StatLine3     );
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
//   ByVol.QuickReport1.Preview;
end;

end.
 