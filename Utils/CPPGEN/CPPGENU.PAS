unit Cppgenu;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, TabNotBk, ExtCtrls, Buttons;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    ModuleCB: TComboBox;
    ClassCB: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    TabbedNotebook1: TTabbedNotebook;
    AttribCB: TComboBox;
    MethodCB: TComboBox;
    ParamCB: TComboBox;
    SaveButton: TBitBtn;
    LoadButton: TBitBtn;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    MethodAdd: TButton;
    ClassAdd: TButton;
    Label3: TLabel;
    BaseMemo: TMemo;
    CheckBox1: TCheckBox;
    Memo2: TMemo;
    Label4: TLabel;
    ClassLB: TListBox;
    Image1: TImage;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Button1: TButton;
    procedure CBChange(Sender: TObject);
    procedure LoadButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure AddClick(Sender: TObject);
    procedure ClassLBClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    procedure FillCB(CB:TComboBox);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure LoadProject(name:String); far; external 'E:\SRC\CPPGEN\CPPGUTIL.DLL';
procedure SaveProject(name:String); far; external 'E:\SRC\CPPGEN\CPPGUTIL.DLL';
procedure GetClasses (name:String); far; external 'E:\SRC\CPPGEN\CPPGUTIL.DLL';
procedure GetMethods (name:String); far; external 'E:\SRC\CPPGEN\CPPGUTIL.DLL';
procedure GetAttribs (name:String); far; external 'E:\SRC\CPPGEN\CPPGUTIL.DLL';
procedure GetParams  (name:String); far; external 'E:\SRC\CPPGEN\CPPGUTIL.DLL';
procedure Pass       (memo:TStrings); far; external 'E:\SRC\CPPGEN\CPPGUTIL.DLL';

procedure TForm1.FillCB(CB:TComboBox);
begin
   CB.Items.LoadFromFile('MODULES.OPT');
   if CB.Items.Count > 0 then 
   begin
      CB.ItemIndex:=0;
      CB.OnChange(CB);
   end;
end;
procedure TForm1.CBChange(Sender: TObject);
begin
   if Sender.ClassType <> TCombobox then Exit;
   with Sender as TCombobox do
   begin
      if Sender = ModuleCB then
      begin
           GetClasses(Items[ItemIndex]); 
           ClassLB.Items.LoadFromFile('MODULES.OPT');
           FillCB(ClassCB);
      end
      else if Sender = ClassCB then
      begin
           GetMethods(Items[ItemIndex]); 
           FillCB(MethodCB);
           GetAttribs(Items[ItemIndex]); 
           FillCB(AttribCB);
      end
      else if Sender = MethodCB then
      begin
           GetParams(Items[ItemIndex]); 
           FillCB(ParamCB);
      end;
   end;          
end;
procedure TForm1.LoadButtonClick(Sender: TObject);
begin
   OpenDialog1.FileName:='*.PRJ';
   if OpenDialog1.Execute then
   begin
      LoadProject(OpenDialog1.FileName); 
      FillCB(ModuleCB);
      SaveDiaLog1.FileName:=OpenDialog1.FileName;
   end;
end;

procedure TForm1.SaveButtonClick(Sender: TObject);
begin
   if SaveDialog1.Execute then
      SaveProject(SaveDiaLog1.FileName);
end;

procedure TForm1.AddClick(Sender: TObject);
begin
    if Sender = MethodAdd then
       with MethodCB do items.Add(Text)
    else
       with ClassCB do items.Add(Text);
end;

procedure TForm1.ClassLBClick(Sender: TObject);
begin
    BaseMemo.Lines.Add(ClassLB.Items[ClassLB.ItemIndex]);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    Pass(BaseMemo.Lines);
end;

end.
 

                                                                 
