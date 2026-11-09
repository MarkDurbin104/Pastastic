unit CDMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ToolWin, ComCtrls,GPCSRegistry, Buttons, ExtCtrls,CompListFU,PackStrListU;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Window1: TMenuItem;
    CloseAll1: TMenuItem;
    Options1: TMenuItem;
    CompilerOptions1: TMenuItem;
    DefaultDirectories1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SpeedButton6: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Timer1: TTimer;
    procedure Exit1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure CloseAll1Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure CompilerOptions1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    ProjectList:TPackStringList;
    procedure AddWindow(Name:String);
  public
    CurrentProject:TComponentPalette;
  end;

var
  MainForm: TMainForm;

implementation

uses SnapInFU, SplashFU, CompOptionsFU;

{$R *.DFM}

procedure TMainForm.Exit1Click(Sender: TObject);
begin
   Close;
end;
procedure TMainForm.AddWindow(Name:String);
var
  NewItem: TMenuItem;
begin
  if Window1.Count = 1 then
  begin
     NewItem:=TMenuItem.Create(Self);
     NewItem.Caption:='-';
     Window1.Add(NewItem);
  end;
  NewItem:=TMenuItem.Create(Self);
  NewItem.Caption:=Name;
  Window1.Add(NewItem);
end;
procedure TMainForm.Open1Click(Sender: TObject);
begin
   if ProjectList = nil then
      ProjectList:=TPackStringList.Create;
   if OpenDialog1.Execute then
   begin
      CurrentProject:=TComponentPalette.Create(Self);
      ProjectList.AddObject(OpenDialog1.FileName,CurrentProject);
      CurrentProject.FileName:=OpenDialog1.FileName;
      CompOptions.CommaText:=CurrentProject.BuildOptions;
      AddWindow(OpenDialog1.FileName);
      CurrentProject.Visible:=True;
   end;
end;

procedure TMainForm.New1Click(Sender: TObject);
begin
   if ProjectList = nil then
      ProjectList:=TPackStringList.Create;
   CurrentProject:=TComponentPalette.Create(Self);
   ProjectList.AddObject('Project 1',CurrentProject);
   AddWindow('Project 1');
   CurrentProject.Visible:=True;
   CurrentProject.BuildOptions:=CompOptions.CommaText;
end;          

procedure TMainForm.CloseAll1Click(Sender: TObject);
var
   ProjectForm:TComponentPalette;
begin              
   if (ProjectList <> nil) and (ProjectList.Count > 0) then
   begin
      Window1.Delete(1);        
      while ProjectList.Count > 0 do
      begin
         Window1.Delete(1);
         ProjectForm:=TComponentPalette(ProjectList.Objects[0]);
         ProjectForm.Free;
         ProjectList.Delete(0);
      end;
   end;                      
end;

procedure TMainForm.SpeedButton6Click(Sender: TObject);
begin
   if Splash.Visible then
   begin
      Splash.Hide;
      SpeedButton6.Down:=False;
   end
   else
   begin
      Splash.Show;
      SpeedButton6.Down:=True;
   end;
end;   

procedure TMainForm.CompilerOptions1Click(Sender: TObject);
begin
   CompOptions.ShowModal;
   if CompOptions.ModalResult = mrOK then
   begin
      if CurrentProject <> nil then
         CurrentProject.BuildOptions:=CompOptions.CommaText;
   end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
   I:Integer;
begin
   if ProjectList = nil then
      ProjectList:=TPackStringList.Create;
   for I:=1 to ParamCount do
   begin
      if UpperCase(ExtractFileExt(ParamStr(I))) = '.GPF' then
      begin
         CurrentProject:=TComponentPalette.Create(Self);
         ProjectList.AddObject(ParamStr(I),CurrentProject);
         CurrentProject.FileName:=ParamStr(I);
         AddWindow(ParamStr(I));
         CurrentProject.Visible:=True;
      end;
   end;
   Left:=0;
   Top:=0
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
   SpeedButton6Click(SpeedButton6);
   Timer1.Enabled:=False;
end;

end.
