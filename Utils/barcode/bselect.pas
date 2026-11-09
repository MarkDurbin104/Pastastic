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
    Label6: TLabel;
    Edit5: TEdit;
    Button3: TBitBtn;
    Button4: TBitBtn;
    Button5: TBitBtn;
    Table1: TTable;
    ZebraEMS1: TZebraEMS;
    Table1Country: TStringField;
    Table1Date: TDateField;
    Table1StartLabel: TStringField;
    Table1EndLabel: TStringField;
    Table1LabelCount: TIntegerField;
    Table1BadLabels: TSmallintField;
    SetPrintSpeed1: TMenuItem;
    procedure Labelreport1Click(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure SetPrintSpeed1Click(Sender: TObject);
  private     
    Done:Boolean;
    BadLabels:Integer;
    CountryT:String;
    LabelCountT:String;
    DateT:String;
    BadLabelsT:String;
    StartT:String;
    EndT:String;
    function BStr(En:Integer):String;
    procedure setupZ;
  public 
  end;

var
  Form1: TForm1;

implementation

uses breport, PError, RCountry, RDate, RVol, psfu;

{$R *.DFM}
procedure TForm1.setupZ;
begin
end;
procedure TForm1.Labelreport1Click(Sender: TObject);
begin
   Form2.ShowModal;
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
  m:=ZebraEMS1.mod11(Val);
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
procedure TForm1.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
   if ((Key < #48) or (Key > #57)) and (Key <> #8) then Key:=#0;
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin
   Edit3.Text:=BStr(0);
   Edit4.Text:=BStr(1);
   if (StrToIntDef(Edit2.Text,0) <> 0) and (ComboBox1.Text <> '') then
   begin
      Button1.Enabled:=True;
   end
   else
   begin
      Button1.Enabled:=False;
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
//       if MaxVal = 0 then
//       begin
//         Edit5.Text:='0';
         Edit5.ReadOnly:=False;
         Edit5.Color:=clWindow;
         Edit5.tabStop:=True;
//       end
//       else
//       begin
         Edit5.Text:=IntToStr(MaxVal);
//         Edit5.ReadOnly:=True;
//         Edit5.Color:=clBtnFace;
//         Edit5.tabStop:=False;
//       end;
       Edit3.Text:=BStr(0);
       Edit4.Text:=BStr(1);
       Edit2.Text:='0';
       Edit2.Color:=clWindow;
       Edit2.ReadOnly:=False;
       Edit2.TabStop:=True;
    end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   nl:Integer;
begin
   ZebraEMS1.Country:=Copy(TLStr(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).S,1,2);
   ZebraEMS1.ServiceIndicator:=Edit1.Text;
   ZebraEMS1.RunLength:=StrToIntDef(Edit2.Text,0);
   ZebraEMS1.StartNumber:=StrToIntDef(Edit5.Text,0);
   Done:=False;
   BadLabels:=0;
   while not Done do
   begin
      if not ZebraEMS1.Print then
      begin
         ErrorForm.Z:=ZebraEMS1;
         if ErrorForm.ShowModal = mrOK then
         begin
             nl:=(ZebraEMS1.LastPrinted+1)-ZebraEMS1.StartNumber;
             ZebraEMS1.StartNumber:=ZebraEMS1.LastPrinted+1;
             ZebraEMS1.RunLength:=(ZebraEMS1.RunLength-nl)+10;
             BadLabels:=BadLabels+10;
         end
         else
         begin
            nl:=(ZebraEMS1.LastPrinted+1)-ZebraEMS1.StartNumber;
            ZebraEMS1.RunLength:=nl;
            Done:=True;
         end;            
      end
      else
      begin
         Done:=True;
      end;          
   end;
   with ZebraEMS1 do
   begin
      if LastPrinted <> StartNumber-1 then
      begin
         Table1.Open;
         Table1.Insert;
         Table1Country.Value   :=ComboBox1.Items[ComboBox1.ItemIndex];
         Table1Date.Value      :=Now;
         nl:=StrToIntDef(Edit5.Text,0)+StrToIntDef(Edit2.Text,0)+BadLabels;
         Table1StartLabel.Value:=Edit5.Text;
         Table1LabelCount.Value:=StrToIntDef(Edit2.Text,0);
         Table1BadLabels.Value :=BadLabels;
         Table1EndLabel.Value  :=IntToStr(nl);
         Table1.Post;
         Table1.Close;
      end;           
   end;
   ComboBox1Change(ComboBox1);
end;

procedure TForm1.FormShow(Sender: TObject);
var
   LStr:TLStr;
   S:TStringList;
   LOK:Boolean;
   I:Integer;
begin
   ZebraEMS1.PrintSpeed:=Form3.GetSpeed;
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
      if S.Count >  0 then Caption:=S.Strings[0];
      if S.Count >  1 then Label1.Caption:=S.Strings[1];
      if S.Count >  2 then Label2.Caption:=S.Strings[2];
      if S.Count >  3 then Label3.Caption:=S.Strings[3];
      if S.Count >  4 then Label4.Caption:=S.Strings[4];
      if S.Count >  5 then Label5.Caption:=S.Strings[5];
      if S.Count >  6 then Button1.Caption:=S.Strings[6];
      if S.Count >  6 then ErrorForm.Button1.Caption:=S.Strings[6];
      if S.Count >  7 then ErrorForm.Caption:=S.Strings[ 7];
      if S.Count >  8 then ErrorForm.CheckBox1.Caption:=S.Strings[ 8];
      if S.Count >  9 then ErrorForm.CheckBox2.Caption:=S.Strings[ 9];
      if S.Count > 10 then ErrorForm.CheckBox3.Caption:=S.Strings[10];
      if S.Count > 11 then ErrorForm.CheckBox4.Caption:=S.Strings[11];
      if S.Count > 12 then ErrorForm.CheckBox5.Caption:=S.Strings[12];
      if S.Count > 13 then ErrorForm.CheckBox6.Caption:=S.Strings[13];
      if S.Count > 14 then ErrorForm.CheckBox7.Caption:=S.Strings[14];
      if S.Count > 15 then ErrorForm.CheckBox8.Caption:=S.Strings[15];
      if S.Count > 16 then ErrorForm.CheckBox9.Caption:=S.Strings[16];
      if S.Count > 17 then ErrorForm.Button2.Caption:=S.Strings[17];
      if S.Count > 18 then CountryT    :=S.Strings[18];
      if S.Count > 19 then LabelCountT :=S.Strings[19];
      if S.Count > 20 then DateT       :=S.Strings[20];
      if S.Count > 21 then BadLabelsT  :=S.Strings[21];
      if S.Count > 22 then StartT      :=S.Strings[22];
      if S.Count > 23 then EndT        :=S.Strings[23];
      if S.Count > 24 then Button3.Caption:=S.Strings[24];
      if S.Count > 25 then Button4.Caption:=S.Strings[25];
      if S.Count > 26 then Button5.Caption:=S.Strings[26];
      if S.Count > 27 then Label6.Caption:=S.Strings[27];
   end                       
   else
   begin
      S.Add(Caption);
      S.Add(Label1.Caption);
      S.Add(Label2.Caption);
      S.Add(Label3.Caption);
      S.Add(Label4.Caption);
      S.Add(Label5.Caption);
      S.Add(Button1.Caption);
      S.Add(ErrorForm.Caption);
      S.Add(ErrorForm.CheckBox1.Caption);
      S.Add(ErrorForm.CheckBox2.Caption);
      S.Add(ErrorForm.CheckBox3.Caption);
      S.Add(ErrorForm.CheckBox4.Caption);
      S.Add(ErrorForm.CheckBox5.Caption);
      S.Add(ErrorForm.CheckBox6.Caption);
      S.Add(ErrorForm.CheckBox7.Caption);
      S.Add(ErrorForm.CheckBox8.Caption);
      S.Add(ErrorForm.CheckBox9.Caption);
      S.Add(ErrorForm.Button2.Caption);
      S.Add('Country'   );
      S.Add('Label Count');
      S.Add('Date'      );
      S.Add('Bad Labels' );
      S.Add('Start'     );
      S.Add('End'       );
      S.Add(Button3.Caption);
      S.Add(Button4.Caption);
      S.Add(Button5.Caption);
      S.Add(Label6.Caption);                          
      S.SaveToFile('BarPStr.Txt');
   end;
   S.Free;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  ByVol.Caption:=Button3.Caption;
  ByVol.Table1Country.DisplayLabel:=CountryT;
  ByVol.Table1LabelCount.DisplayLabel:=LabelCountT;
  
  ByVol.ShowModal;                
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  ByCountry.Caption:=Button4.Caption;
  ByCountry.Table1Country.DisplayLabel:=CountryT;
  ByCountry.Table1LabelCount.DisplayLabel:=LabelCountT;
  ByCountry.Table1BadLabels.DisplayLabel:=BadLabelsT;
  ByCountry.ShowModal;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  ByDate.Caption:=Button5.Caption;
  ByDate.Table1Date.DisplayLabel:=DateT;
  ByDate.Table1Country.DisplayLabel:=CountryT;
  ByDate.Table1LabelCount.DisplayLabel:=LabelCountT;
  ByDate.Table1BadLabels.DisplayLabel:=BadLabelsT;
  ByDate.ShowModal;    
end;

procedure TForm1.Image1DblClick(Sender: TObject);
begin
//    Table1.Open;
//    Table1.First;
//    while not Table1.EOF do
//    begin
//       Table1.Delete;
//       Table1.First;
//    end;
end;

procedure TForm1.SetPrintSpeed1Click(Sender: TObject);
begin
   Form3.ShowModal;    
   ZebraEMS1.PrintSpeed:=Form3.GetSpeed;
end;

end.
 