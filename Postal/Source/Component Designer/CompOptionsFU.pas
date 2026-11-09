unit CompOptionsFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,GPCSGUID,PackStrListU;
const
   BuildOptions = 'Component Designer\Build Options';
   
type
  TCompOptions = class(TForm)
    BuildAll: TCheckBox;
    AliasesGB: TGroupBox;
    Aliases: TMemo;
    IncludeDCUs: TGroupBox;
    InDCUDirs: TMemo;
    IncludePASs: TGroupBox;
    InPASDirs: TMemo;
    PackagesGB: TGroupBox;
    Packages: TMemo;
    OutBin: TGroupBox;
    OutEXEDir: TEdit;
    GroupBox1: TGroupBox;
    OutDCUDir: TEdit;
    GroupBox2: TGroupBox;
    CommandLine: TEdit;
    GroupBox3: TGroupBox;
    OutPASDir: TEdit;
    Button1: TButton;
    Button2: TButton;
    InDCUDirsP: TMemo;
    InPASDirsP: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OutDCUDirChange(Sender: TObject);
    procedure BuildAllClick(Sender: TObject);
  private
     Modified:Boolean;
     procedure GetBuildOptions;
     procedure SetBuildOptions;
     function GetAsString:String;
     procedure SetAsString(Value:String);
  public      
    procedure BuildDCC32CFGFiles(CompType,DesGroup:String);
    property CommaText:String read GetAsString write SetAsString;
  end;

var
  CompOptions: TCompOptions;

implementation

{$R *.DFM}

function TCompOptions.GetAsString:String;
var
  SL:TPackStringList;
  I:Integer;
begin
  SL:=TPackStringList.Create;
  SL.Add(IntToStr(InDCUDirsP.Lines.Count));
  for I:=0 to InDCUDirsP.Lines.Count-1 do 
     SL.Add(InDCUDirsP.Lines[I]);
  SL.Add(IntToStr(InPASDirsP.Lines.Count));
  for I:=0 to InPASDirsP.Lines.Count-1 do 
     SL.Add(InPASDirsP.Lines[I]);
  SL.Add(OutEXEDir.Text);
  SL.Add(OutDCUDir.Text);
  SL.Add(OutPASDir.Text);
  Result:=SL.CommaText;
  SL.Free;
end;
procedure TCompOptions.SetAsString(Value:String);
var
  SL:TPackStringList;
  I:Integer;
  Count:Integer;
begin
  SL:=TPackStringList.Create;
  SL.CommaText:=Value;
  InDCUDirsP.Lines.Clear;
  Count:=StrToInt(SL[0]); SL.Delete(0);
  for I:=0 to Count-1 do
  begin
     InDCUDirsP.Lines.Add(SL[0]); SL.Delete(0);
  end;
  InPASDirsP.Lines.Clear;
  Count:=StrToInt(SL[0]); SL.Delete(0);
  for I:=0 to Count-1 do
  begin
     InPASDirsP.Lines.Add(SL[0]); SL.Delete(0);
  end;
  OutEXEDir.Text:=SL[0];
  OutDCUDir.Text:=SL[1];
  OutPASDir.Text:=SL[2];
  SL.Free;
end;
procedure TCompOptions.BuildDCC32CFGFiles(CompType,DesGroup:String);
var
  SL:TPackStringList;
  S:String;
  I:Integer;
  CompDir:String;
begin
  SL:=TPackStringList.Create;
  if BuildAll.Checked then SL.Add('-B');
  
  S:='-A'; 
  for I:=0 to Aliases.Lines.Count-1 do 
     S:=S+Aliases.Lines[I]+';';
  SL.Add(S);
  
  S:='-LU'; 
  for I:=0 to Packages.Lines.Count-1 do 
     S:=S+Packages.Lines[I]+';';
  SL.Add(S);
  
  for I:=0 to InDCUDirs.Lines.Count-1 do 
     SL.Add('-I"'+InDCUDirs.Lines[I]+'"');
  for I:=0 to InDCUDirsP.Lines.Count-1 do 
     SL.Add('-I"'+InDCUDirsP.Lines[I]+'"');
     
  for I:=0 to InPASDirs.Lines.Count-1 do 
     SL.Add('-U"'+InPASDirs.Lines[I]+'"');
  for I:=0 to InPASDirsP.Lines.Count-1 do 
     SL.Add('-U"'+InPASDirsP.Lines[I]+'"');
     
  SL.Add('-E"'+OutEXEDir.Text+'"');
  SL.Add('-N"'+OutDCUDir.Text+'"');
  
  CreateDir(OutPASDir.Text);
  CreateDir(OutPASDir.Text+'\'+CompType);
  if DesGroup = '' then
  begin
     CompDir:=OutPASDir.Text+'\'+CompType+'\';
  end
  else
  begin
     CreateDir(OutPASDir.Text+'\'+CompType+'\'+DesGroup);
     CompDir:=OutPASDir.Text+'\'+CompType+'\'+DesGroup+'\';
  end;
  SL.SaveToFile(CompDir+'dcc32.cfg');
end;                                             
procedure TCompOptions.Button1Click(Sender: TObject);
begin
   if Modified then SetBuildOptions;
   Hide;
end;
procedure TCompOptions.SetBuildOptions;
begin
   Modified:=False;
   if BuildAll.Checked then
      SetGPCSRegString(BuildOptions,'Build All Units','Y')
   else
      SetGPCSRegString(BuildOptions,'Build All Units','N');
   SetGPCSRegString(BuildOptions,'Command Line'         ,CommandLine.Text);
   SetGPCSRegString(BuildOptions,'Root Source Directory',OutPASDir.Text);
   SetGPCSRegString(BuildOptions,'Executable Directory' ,OutEXEDir.Text);
   SetGPCSRegString(BuildOptions,'DCU Directory'        ,OutDCUDir.Text);
   SetGPCSRegNames(BuildOptions+'\Packages'    ,Packages.Lines.CommaText);
   SetGPCSRegNames(BuildOptions+'\Library Path',InDCUDirs.Lines.CommaText);
   SetGPCSRegNames(BuildOptions+'\Search Path' ,InPASDirs.Lines.CommaText);
   SetGPCSRegNames(BuildOptions+'\Aliases'     ,Aliases.Lines.CommaText);
   SetGPCSRegNames(BuildOptions+'\Project\Library Path',InDCUDirsP.Lines.CommaText);
   SetGPCSRegNames(BuildOptions+'\Project\Search Path' ,InPASDirsP.Lines.CommaText);
end;
procedure TCompOptions.GetBuildOptions;
var
  S:String;
  SL:TPackStringList;
begin                     
   Modified:=False;
   S:=StrUpper(PChar(GetGPCSRegString(BuildOptions,'Build All Units','Y')));
   if (S = 'Y') or (S = 'YES') or (S = '1') or (S = 'TRUE') then
      BuildAll.Checked:=True
   else
      BuildAll.Checked:=False;
   S:=GetGPCSRegString(BuildOptions,'Command Line','');
   if S <> '' then CommandLine.Text:=S;
   S:=GetGPCSRegString(BuildOptions,'Root Source Directory','');
   if S <> '' then OutPASDir.Text:=S;
   S:=GetGPCSRegString(BuildOptions,'Executable Directory','');
   if S <> '' then OutEXEDir.Text:=S;
   S:=GetGPCSRegString(BuildOptions,'DCU Directory','');
   if S <> '' then OutDCUDir.Text:=S;
   SL:=TPackStringList.Create;
   SL.CommaText:=GetGPCSRegNames(BuildOptions+'\Packages','');
   if SL.Count > 0 then Packages.Lines.Assign(SL);
   SL.CommaText:=GetGPCSRegNames(BuildOptions+'\Library Path','');
   if SL.Count > 0 then InDCUDirs.Lines.Assign(SL);
   SL.CommaText:=GetGPCSRegNames(BuildOptions+'\Search Path','');
   if SL.Count > 0 then InPASDirs.Lines.Assign(SL);
   SL.CommaText:=GetGPCSRegNames(BuildOptions+'\Aliases','');
   if SL.Count > 0 then Aliases.Lines.Assign(SL);
   SL.CommaText:=GetGPCSRegNames(BuildOptions+'\Project\Library Path','');
   if SL.Count > 0 then InDCUDirsP.Lines.Assign(SL);
   SL.CommaText:=GetGPCSRegNames(BuildOptions+'\Project\Search Path','');
   if SL.Count > 0 then InPASDirsP.Lines.Assign(SL);
   SL.Free;
end;
procedure TCompOptions.Button2Click(Sender: TObject);
begin
   GetBuildOptions;
   Hide;
end;

procedure TCompOptions.FormCreate(Sender: TObject);
begin                     
   GetBuildOptions;
end;   

procedure TCompOptions.OutDCUDirChange(Sender: TObject);
begin
   Modified:=True;
end;

procedure TCompOptions.BuildAllClick(Sender: TObject);
begin
   Modified:=True;
end;

end.
