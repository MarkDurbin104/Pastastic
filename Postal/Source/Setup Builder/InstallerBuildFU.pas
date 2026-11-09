unit InstallerBuildFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls,FileCtrl,WinExecU,GPCSGUID,PackStrListU;

type
  TBuildLine = class(TObject)
    FFile:String;
    FLine:Integer;
    FError:String;
  public
     constructor Create(Path,ErrorLine:String);
  end;
  TInstallBuild = class(TForm)
    PageControl1: TPageControl;
    CompilerProgress: TTabSheet;
    Panel1: TPanel;
    Button2: TButton;
    BuildOptions: TTabSheet;
    IncludeDCUs: TGroupBox;
    InDCUDirs: TMemo;
    IncludePASs: TGroupBox;
    InPASDirs: TMemo;
    OutBin: TGroupBox;
    OutEXEDir: TEdit;
    GroupBox1: TGroupBox;
    OutDCUDir: TEdit;
    GroupBox2: TGroupBox;
    Corvus: TEdit;
    BuildStat: TListBox;
    Button1: TButton;
    GroupBox3: TGroupBox;
    Installer: TEdit;
    GroupBox4: TGroupBox;
    MinDelphi: TEdit;
    Aliases: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure BuildStatDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    CancelBuild:Boolean;
    procedure BuildDCC32CFGFiles(ProjName:String);
    procedure BuildComponents;
  public           
    { Public declarations }
  end;

var
  InstallBuild: TInstallBuild;

implementation

{$R *.DFM}
{TBuildLine}
constructor TBuildLine.Create(Path,ErrorLine:String);
var
   I,J:Integer;
   EFile:String;
begin
   inherited Create;
   FError:=ErrorLine;
   J:=1;
   for I:=1 to Length(ErrorLine) do
   begin
      if ErrorLine[I] = '(' then
      begin
         EFile:=Copy(ErrorLine,J,I-1);
         if (Length(EFile) > 2) and (EFile[2] = ':') then
            FFile:=EFile
         else
            FFile:=Path+'\'+EFile;
         J:=I+1;
      end
      else if ErrorLine[I] = ')' then
      begin
         FLine:=StrToIntDef(Copy(ErrorLine,J,I-J),0);
         FError:=Copy(ErrorLine,I+9,Length(ErrorLine));
         break;
      end
   end;        
end;
{TBaseBuild}
procedure TInstallBuild.BuildDCC32CFGFiles(ProjName:String);
var              
  SL:TPackStringList;
  S:String;
  I:Integer;
  CompDir:String;
begin
  CompDir:=ExtractFilePath(ProjName);
  ProjName:=ExtractFileName(ProjName);

  SL:=TPackStringList.Create;
  S:='-A';
  for I:=0 to Aliases.Lines.Count-1 do
     S:=S+Aliases.Lines[I]+';';
  SL.Add(S);

  for I:=0 to InDCUDirs.Lines.Count-1 do
     SL.Add('-I"'+InDCUDirs.Lines[I]+'"');

  for I:=0 to InPASDirs.Lines.Count-1 do
     SL.Add('-U"'+InPASDirs.Lines[I]+'"');

  SL.Add('-E"'+OutEXEDir.Text+'"');
  SL.Add('-N"'+OutDCUDir.Text+'"');

  ForceDirectories(OutEXEDir.Text);
  ForceDirectories(OutDCUDir.Text);
  SL.SaveToFile(CompDir+'dcc32.cfg');
  SL.SaveToFile(CompDir+ProjName+'.cfg');
  SL.Clear;
  SL.Add('[Compiler]');
  S:='UnitAliases=';
  for I:=0 to Aliases.Lines.Count-1 do
     S:=S+Aliases.Lines[I]+';';
  SL.Add(S);
  SL.Add('');
  SL.Add('[Directories]');
  SL.Add('OutputDir='+OutEXEDir.Text);
  SL.Add('UnitOutputDir='+OutDCUDir.Text);

  SL.SaveToFile(CompDir+ProjName+'.dof');
end;
procedure TInstallBuild.BuildComponents;
var
   SL : TStringList;
   CurrDir : String;
   Output : String;
   InstallerPath : String;
   ShortPath : String;
   PathLength : Integer;
begin
   BuildStat.Clear;
   if FileExists(Corvus.Text + '\Binary\CompMan.EXE') then
   begin
      BuildStat.Items.Add('Constructing Archive File of "'+Corvus.Text+'"');
      SetLength(ShortPath, 256);
      PathLength:=GetShortPathName(PChar(MinDelphi.Text), PChar(ShortPath), 256);
      SetLength(ShortPath, PathLength);
      GetDir(0,CurrDir);
      ChDir('C:\');
      WinExecAndWait(ShortPath + '\Rar.exe a -s -r -md1024 C:\Install.RAR ' + Corvus.Text + '\*.*', Output, FALSE);
      if FileExists('C:\Install.RAR') then
        BuildStat.Items.Add('Archive Created Sucessfully')
      else
        BuildStat.Items.Add('Error Creating Archive');
      //BuildStat.Items.Add(Output);
      ChDir(CurrDir);

      BuildStat.Items.Add('');
      InstallerPath:=ExtractFilePath(Installer.Text);
      BuildStat.Items.Add('Generating Binary Resource File');
      GetDir(0,CurrDir);
      ChDir(ExtractFilePath(Installer.Text));
      WinExecAndWait(ShortPath + '\Brcc32.exe rar.rc', Output, FALSE);
      BuildStat.Items.Add(Output);
      if FileExists(InstallerPath + 'Rar.RES') then
        BuildStat.Items.Add('Resource File Created Sucessfully')
      else
        BuildStat.Items.Add('Error Creating Resource File');
      ChDir(CurrDir);
      if not(DeleteFile('C:\Install.RAR')) then
        BuildStat.Items.Add('Unable to Delete Temporary Archive File');


      Application.ProcessMessages;
      if Application.Terminated then
      begin
        DeleteFile('C:\Install.RAR');
        DeleteFile(InstallerPath + 'Rar.RES');
        Exit;
      end;

      GetDir(0,CurrDir);

      BuildDCC32CFGFiles(Installer.Text);
      BuildStat.Items.Add('Building :- '+Installer.Text);

      ChDir(InstallerPath);
      WinExecAndWait(ShortPath+'\DCC32'+' "'+Installer.Text+'"',Output,False);
      SL:=TStringList.Create;
      SL.Text:=Output;
      BuildStat.Items.AddStrings(SL);
      SL.Free;
      ChDir(CurrDir);

      if CancelBuild=TRUE then
         BuildStat.Items.Add('Build Cancelled.')
      else
        if BuildStat.Items.Count = 0 then
           BuildStat.Items.Add('Nothing to Build.')
        else
           BuildStat.Items.Add('Build Complete.');
   end;
end;

procedure TInstallBuild.Button1Click(Sender: TObject);
begin
   PageControl1.ActivePage:=CompilerProgress;
   CancelBuild:=False;
   BuildComponents;
end;

procedure TInstallBuild.BuildStatDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  FC:TColor;
begin
   with BuildStat.Canvas do
   begin
      FillRect(Rect);
      FC:=Font.Color;
      if BuildStat.Items.Objects[Index] <> nil then
      begin
         if Pos('Hint:',BuildStat.Items[Index]) > 0 then
            Font.Color:=clBlue
         else
            Font.Color:=clRed;
      end;
      TextOut(Rect.Left+2,Rect.Top,BuildStat.Items[Index]);
      Font.Color:=FC;
   end; 
end;

procedure TInstallBuild.Button2Click(Sender: TObject);
begin
   CancelBuild:=True;
end;

procedure TInstallBuild.FormShow(Sender: TObject);
var
   I:Integer;
   Value:String;
begin
   for I:=0 to ComponentCount-1 do
   begin
      if Components[I] is TMemo then
      begin
         Value:=GetGPCSRegNames('Build Base\'+Components[I].Name,'');
         if Value <> '' then
            (Components[I] as TMemo).Lines.CommaText:=Value;
      end
      else if Components[I] is TEdit then
      begin
         Value:=GetGPCSRegString('Build Base',Components[I].Name,'');
         if Value <> '' then
            (Components[I] as TEdit).Text:=Value;
      end
      else if Components[I] is TCheckBox then
      begin
         Value:=GetGPCSRegString('Build Base',Components[I].Name,'Y');
         if Value = 'N' then
            (Components[I] as TCheckBox).Checked:=False
         else
            (Components[I] as TCheckBox).Checked:=True;
      end;  
   end;  
end;

procedure TInstallBuild.FormClose(Sender: TObject; var Action: TCloseAction);
var
   I:Integer;
begin
   for I:=0 to ComponentCount-1 do
   begin
      if Components[I] is TMemo then
         SetGPCSRegNames('Build Base\'+Components[I].Name,(Components[I] as TMemo).Lines.CommaText)
      else if Components[I] is TEdit then
         SetGPCSRegString('Build Base',Components[I].Name,(Components[I] as TEdit).Text)
      else if Components[I] is TCheckBox then
      begin
         if (Components[I] as TCheckBox).Checked then
            SetGPCSRegString('Build Base',Components[I].Name,'Y')
         else
            SetGPCSRegString('Build Base',Components[I].Name,'N');
      end;
   end;                                 
end;

end.
