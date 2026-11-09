unit confform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask;

type
  TControlCentre = record
      Name:String;
      Ident:Integer;
      Phone:String;
      Port:Integer;
      TName:String;
      TIdent:String;
      TType:String;
  end;             
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    CCList: TListBox;
    Button1: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    GroupBox3: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    TermList: TListBox;
    TNameEdit: TEdit;
    Button6: TButton;
    Button2: TButton;
    Button4: TButton;
    Label1: TLabel;
    Button3: TButton;
    Button5: TButton;
    TTypeEdit: TComboBox;
    CCommEdit: TComboBox;
    TIdEdit: TComboBox;
    CNameEdit: TEdit;
    CIdEdit: TEdit;
    CPhoneEdit: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure CCListClick(Sender: TObject);
    procedure TermListClick(Sender: TObject);
    procedure CNameEditExit(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure TNameEditExit(Sender: TObject);
    procedure CNameEditKeyPress(Sender: TObject; var Key: Char);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    CC : array[0..99] of TControlCentre;
    NumbCC:Integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var
   ConfLines:TStringList;
   I,J:Integer;
begin
   KeyPreview := True;
   ConfLines:=TStringList.Create;              
   ConfLines.LoadFromFile('G:\KEYMAINT\KEYMAINT.CFG');
   NumbCC:=0;
   for I:=0 to ConfLines.Count-1 do
   begin
   
      CC[NumbCC].Ident:=StrToInt(Copy(ConfLines.Strings[I],1,2));
      J:=14; while ConfLines.Strings[I][3+J] = ' ' do Dec(J);
      CC[NumbCC].Name:=Copy(ConfLines.Strings[I],3,J+1);
      CC[NumbCC].TIdent:=Copy(ConfLines.Strings[I],18,2);
      J:=14; while ConfLines.Strings[I][20+J] = ' ' do Dec(J);
      CC[NumbCC].TName:=Copy(ConfLines.Strings[I],20,J+1);
      CC[NumbCC].TType:=Copy(ConfLines.Strings[I],35,3);
      CC[NumbCC].Port:=StrToInt(Copy(ConfLines.Strings[I],38,2));
      J:=0; while ConfLines.Strings[I][40+J] <> ' ' do Inc(J);
      CC[NumbCC].Phone:=Copy(ConfLines.Strings[I],40,J);
      
      if CCList.Items.IndexOf(CC[NumbCC].Name) < 0 then
         CCList.Items.Add(CC[NumbCC].Name);
         
      Inc(NumbCC);
   end;
   if CCList.Items.Count > 0 then CCList.ItemIndex:=0;
   CCListClick(Self);
   ConfLines.Free;
end;

procedure TForm1.CCListClick(Sender: TObject);
var
   I,Ofs:Integer;
begin
     if CCList.ItemIndex >= 0 then
     begin
        for I:=0 to NumbCC-1 do
        begin
           if CC[I].Name = CCList.Items[CCList.ItemIndex] then
           begin
               CNameEdit.Text:=CC[I].Name;
               CIdEdit.Text:=IntToStr(CC[I].Ident);
               CPhoneEdit.Text:=CC[I].Phone; 
               CCommEdit.Text:=IntToStr(CC[I].Port);
               CCommEdit.ItemIndex:=CCommEdit.Items.IndexOf(IntToStr(CC[I].Port));
               TermList.Clear;
               Ofs:=0;
               while (CC[I+Ofs].Name = CCList.Items[CCList.ItemIndex]) and (I+Ofs < NumbCC) do
               begin
                   TermList.Items.Add(CC[I+Ofs].TName);
                   Inc(Ofs);
               end;
               if TermList.Items.Count > 0 then TermList.ItemIndex:=0;
               TermListClick(Self);
               Exit;
           end;
        end;
     end;
end;

procedure TForm1.TermListClick(Sender: TObject);
var
   I,Ofs:Integer;
begin
     if (CCList.ItemIndex >= 0) and (TermList.ItemIndex >= 0) then
     begin
        for I:=0 to NumbCC-1 do
        begin
           if (CC[I].Name = CCList.Items[CCList.ItemIndex])
           and (CC[I].TName = TermList.Items[TermList.ItemIndex]) then
           begin
               TNameEdit.Text:=CC[I].TName;
               TIdEdit.Text:=CC[I].TIdent;
               TIdEdit.ItemIndex:=TIdEdit.Items.IndexOf(CC[I].TIdent);
               TTypeEdit.Text:=CC[I].TType; 
               TTypeEdit.ItemIndex:=TTypeEdit.Items.IndexOf(CC[I].TType);
               Exit;
           end;
        end;
     end;
end;

procedure TForm1.CNameEditExit(Sender: TObject);
var
   I:Integer;
begin
   if CCList.ItemIndex >= 0 then
   begin
      for I:=0 to NumbCC-1 do
      begin
         if CC[I].Name = CCList.Items[CCList.ItemIndex] then
         begin
            CC[I].Name:=CNameEdit.Text;
            CC[I].Phone:=CPhoneEdit.Text;
            if CIdEdit.Text    <> '' then CC[I].Ident:=StrToInt(CIdEdit.Text);
            if CCommEdit.Text  <> '' then CC[I].Port:=StrToInt(CCommEdit.Text);
         end;
      end;
   end;
   CCList.Items[CCList.ItemIndex]:=CNameEdit.Text;
   CCList.ItemIndex:=CCList.Items.IndexOf(CNameEdit.Text);
zend;

procedure TForm1.EditKeyPress(Sender: TObject; var Key: Char);
begin
    if ((Key < #48) or (Key > #57)) and (Key <> #8) then Key:=#0;
end;

procedure TForm1.TNameEditExit(Sender: TObject);
var
   I,Ofs:Integer;
begin
     if (CCList.ItemIndex >= 0) and (TermList.ItemIndex >= 0) then
     begin
        for I:=0 to NumbCC-1 do
        begin
           if (CC[I].Name = CCList.Items[CCList.ItemIndex])
           and (CC[I].TName = TermList.Items[TermList.ItemIndex]) then
           begin
               CC[I].TName :=TNameEdit.Text;
               CC[I].TType :=TTypeEdit.Text;
               CC[I].TIdent:=TIdEdit.Text  ;
           end;
        end;
     end;
     TermList.Items[TermList.ItemIndex]:=TNameEdit.Text;
     TermList.ItemIndex:=TermList.Items.IndexOf(TNameEdit.Text);
end;

procedure TForm1.CNameEditKeyPress(Sender: TObject; var Key: Char);
begin
   CNameEditExit(Self);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
   Close;
end;

end.
 