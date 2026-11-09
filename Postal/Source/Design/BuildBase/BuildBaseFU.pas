unit BuildBaseFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls,FileCtrl,WinExecU,GPCSGUID,PackStrListU,
  StringUtil;

type
  TBuildLine = class(TObject)
    FFile:String;
    FLine:Integer;
    FError:String;
  public
     constructor Create(Path,ErrorLine:String);
  end;
  TBaseBuild = class(TForm)
    PageControl1: TPageControl;
    CompilerProgress: TTabSheet;
    Panel1: TPanel;
    Button2: TButton;
    BuildOptions: TTabSheet;
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
    Projects: TMemo;
    BuildStat: TListBox;
    Button1: TButton;
    GroupBox4: TGroupBox;
    CondDef: TEdit;
    DebugInfo: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure BuildStatDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure BuildStatDblClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    CancelBuild:Boolean;
    procedure BuildDCC32CFGFiles(ProjName:String);
    procedure BuildComponents;
  public           
    { Public declarations }
  end;

var
  BaseBuild: TBaseBuild;

implementation

uses SourceFormFU;

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
procedure TBaseBuild.BuildDCC32CFGFiles(ProjName:String);
var
  SL:TPackStringList;
  S:String;
  I:Integer;
  CompDir:String;
begin
  CompDir:=ExtractFilePath(ProjName);
  ProjName:=ExtractFileName(ProjName);
  
  SL:=TPackStringList.Create;             
  if BuildAll.Checked then SL.Add('-B');

  S:='-A';
  for I:=0 to Aliases.Lines.Count-1 do 
     S:=S+Aliases.Lines[I]+';';
  SL.Add(S);

  If Packages.Lines.Count > 0 then
  begin
    S:='-LU';
    for I:=0 to Packages.Lines.Count-1 do
       S:=S+Packages.Lines[I]+';';
    SL.Add(S);
  end;

  for I:=0 to InDCUDirs.Lines.Count-1 do 
     SL.Add('-I"'+InDCUDirs.Lines[I]+'"');
     
  for I:=0 to InPASDirs.Lines.Count-1 do 
     SL.Add('-U"'+InPASDirs.Lines[I]+'"');
     
  SL.Add('-E"'+OutEXEDir.Text+'"');
  SL.Add('-LE"'+OutEXEDir.Text+'"');  //package output  
  SL.Add('-N"'+OutDCUDir.Text+'"');
  
  SL.Add('-D"'+CondDef.Text+'"');
  SL.Add('-W');  
  
  if DebugInfo.Checked then
  begin
     SL.Add('-V');
     SL.Add('-$W+');
     SL.Add('-$D+');
     SL.Add('-$L+');
  end;

  ForceDirectories(OutEXEDir.Text);
  ForceDirectories(OutDCUDir.Text);
  SL.SaveToFile(CompDir+'dcc32.cfg');
  SL.SaveToFile(CompDir+ProjName+'.cfg');
  SL.Clear;
  SL.Add('[Compiler]');
  if DebugInfo.Checked then
  begin
     SL.Add('W=1');
     SL.Add('D=1');
  end;
  S:='UnitAliases=';
  for I:=0 to Aliases.Lines.Count-1 do
     S:=S+Aliases.Lines[I]+';';
  SL.Add(S);
  SL.Add('');
  SL.Add('[Linker]');
  if DebugInfo.Checked then
  begin
    SL.Add('DebugInfo=1');
  end;
  SL.Add('[Directories]');
  SL.Add('OutputDir='+OutEXEDir.Text);
  SL.Add('UnitOutputDir='+OutDCUDir.Text);
  If Packages.Lines.Count > 0 then
  begin
    S:='Packages=';
    for I:=0 to Packages.Lines.Count-1 do
       S:=S+Packages.Lines[I]+';';
    SL.Add(S);
    SL.Add('UsePackages=1');
  end
  else
  begin
    SL.Add('UsePackages=0');
  end;
  SL.Add('Conditionals='+CondDef.Text);
  try
     SL.SaveToFile(CompDir+ProjName+'.dof');
  except
     BuildStat.Items.AddObject('Cannot Create '+CompDir+ProjName+'.dof',TObject(1));
  end;
end;                                             
procedure TBaseBuild.BuildComponents;
var
   CCount,I:Integer;
   ESL:TPackStringList;
   CurrDir:String;
   CompilerOutput:String;
   BuildLine:TBuildLine;
   ProjectString:String;
   ProjPath:String;
   ProjectName      :String;
   ProjectExtension : String;
begin
   PageControl1.ActivePage:=Self.CompilerProgress;

   if ParamCount = 0 then
   begin
      for I:=0 to BuildStat.Items.Count-1 do
         if (BuildStat.Items.Objects[I] <> nil) and (Integer(BuildStat.Items.Objects[I]) <> 1) then
            TBuildLine(BuildStat.Items.Objects[I]).Free;
      BuildStat.Clear;
   end;

   for CCount:=0 to Projects.Lines.Count-1 do
   begin
      Application.ProcessMessages;
      if Application.Terminated then Exit;
      if CancelBuild then Break;

      GetDir(0,CurrDir);
      ProjPath:=ExtractFilePath(Projects.Lines[CCount]);

      BuildDCC32CFGFiles(Projects.Lines[CCount]);
      BuildStat.Items.Add('Building :- '+Projects.Lines[CCount]);

      ChDir(ProjPath);
//      WinExecAndWaitEnv(CommandLine.Text+' "'+Projects.Lines[CCount]+'"',CompilerOutput,False,'PATH=%PATH%;'+OutEXEDir.Text+#0#0#0#0);
      WinExecAndWait(CommandLine.Text+' "'+Projects.Lines[CCount]+'"',CompilerOutput,False);

      ESL:=TPackStringList.Create;
      ESL.Text:=CompilerOutput;
      for I:=0 to ESL.Count-1 do
      begin
         if StrScan(PChar(Copy(ESL[I],3,Length(ESL[I]))),':') <> nil then
         begin
            BuildLine:=TBuildLine.Create(ProjPath,ESL[I]);
            BuildStat.Items.AddObject(ESL[I],BuildLine);
         end 
         else if ESL.Count = 1 then
         begin
            BuildStat.Items.Add(ESL[I]);
         end;
      end;
      CompilerOutput:='';
      if DebugInfo.Checked then 
      begin
        ProjectString := Projects.Lines[CCount] ;
        if not ContainsSubString(ProjectString,'.') then ProjectString := ProjectString + '.';
        ProjectName      := ExtractFileName(DelimitedString(ProjectString,'.',False));
        if      FileExists(OutEXEDir.Text+'\'+ProjectName+'.dll') then ProjectExtension := '.dll'
        else if FileExists(OutEXEDir.Text+'\'+ProjectName+'.exe') then ProjectExtension := '.exe'
        else if FileExists(OutEXEDir.Text+'\'+ProjectName+'.dpl') then ProjectExtension := '.dpl';

         BuildStat.Items.Add('TDSPacking :- '+Projectname +ProjectExtension);
         WinExecAndWait(ExtractFilePath(CommandLine.Text)+'TDSPack -o -e '+' "'+OutEXEDir.Text+'\'+ProjectName+ProjectExtension+'"',CompilerOutput,False);

         ESL.Text:=CompilerOutput;
         if (ESL.Count = 1) then
            BuildStat.Items.AddObject(CompilerOutput,TObject(1))
         else if (ESL.Count > 1) and (Copy(ESL[1],1,7) <> 'Reading') then
         begin
            for I:=0 to ESL.Count-1 do
               BuildStat.Items.AddObject(ESL[I],TObject(1));
         end;
      end;
      ChDir(CurrDir);
      ESL.Free;
   end;
   if CancelBuild then
      BuildStat.Items.AddObject('Build Cancelled.',TObject(1))
   else if BuildStat.Items.Count = 0 then
      BuildStat.Items.AddObject('Nothing to Build.',TObject(1))
   else
      BuildStat.Items.Add('Build Complete.');
end;   

procedure TBaseBuild.Button1Click(Sender: TObject);
begin
   PageControl1.ActivePage:=CompilerProgress;
   CancelBuild:=False;
   BuildComponents;
end;

procedure TBaseBuild.BuildStatDrawItem(Control: TWinControl;
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

procedure TBaseBuild.BuildStatDblClick(Sender: TObject);
var
   BuildLine:TBuildLine;
begin
   if Copy(BuildStat.Items[BuildStat.ItemIndex],1,5) <> 'Build' then
   begin
      if (BuildStat.Items.Objects[BuildStat.ItemIndex] <> nil) and (Integer(BuildStat.Items.Objects[BuildStat.ItemIndex]) <> 1) then
      begin
         BuildLine:=TBuildLine(BuildStat.Items.Objects[BuildStat.ItemIndex]);
         if BuildLine.FFile <> '' then
         begin
            SourceForm.SourceMemo.Lines.LoadFromFile(BuildLine.FFile);
            SourceForm.LineNo:=BuildLine.FLine;
            SourceForm.Caption:=BuildLine.FError;
            SourceForm.ShowModal;
            if (SourceForm.ModalResult = mrOK) and (SourceForm.SourceMemo.Modified) then
               SourceForm.SourceMemo.Lines.SaveToFile(BuildLine.FFile);
         end
         else
            ShowMessage('Error: '+BuildLine.FError);
      end;
   end;              
end;

procedure TBaseBuild.Button2Click(Sender: TObject);
begin
   CancelBuild:=True;
end;
function StringFromSL(Name:String;List:TStrings):String;
var
   ResSL:TStringList;
   I:Integer;
   Index:Integer;
begin
   Result:='';
   Index:=List.IndexOf('['+Name+']');
   if Index <> -1 then 
   begin
      ResSL:=TStringList.Create;
      I:=Index+1;
      while (I < List.Count) and (Copy(List[I],1,1) <> '[') do
      begin
         ResSL.Add(List[I]);
         Inc(I);
      end;
      Result:=Trim(ResSL.Text);
      ResSL.Free;;
   end;
end;
function BoolFromSL(Name:String;List:TStrings):Boolean;
begin
   if Trim(StringFromSL(Name,List)) = 'Y' then
      Result:=True
   else
      Result:=False;
end;
procedure TBaseBuild.FormShow(Sender: TObject);
var
   I:Integer;
   Value:String;
begin
   if ParamCount = 0 then
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
end;

procedure TBaseBuild.FormClose(Sender: TObject; var Action: TCloseAction);
var
   I:Integer;
   SL:TStringList;
begin
   SL:=TStringList.Create;
   if ParamCount = 0 then
   begin
      for I:=0 to ComponentCount-1 do
      begin
         if Components[I] is TMemo then
         begin
            SL.Add('['+Components[I].Name+']');
            SL.Add((Components[I] as TMemo).Lines.Text);
            SetGPCSRegNames('Build Base\'+Components[I].Name,(Components[I] as TMemo).Lines.CommaText);
         end
         else if Components[I] is TEdit then
         begin
            SL.Add('['+Components[I].Name+']');
            SL.Add((Components[I] as TEdit).Text);
            SetGPCSRegString('Build Base',Components[I].Name,(Components[I] as TEdit).Text);
         end
         else if Components[I] is TCheckBox then
         begin
            SL.Add('['+Components[I].Name+']');
            if (Components[I] as TCheckBox).Checked then
            begin
               SL.Add('Y');
               SetGPCSRegString('Build Base',Components[I].Name,'Y');
            end
            else
            begin
               SL.Add('N');
               SetGPCSRegString('Build Base',Components[I].Name,'N');
            end;
         end;    
      end;    
      SL.SaveToFile('C:\BuildBase.lst');
   end;                                 
   SL.Free;
end;

procedure TBaseBuild.FormActivate(Sender: TObject);
var
   I,FI:Integer;
   FileName:String;
   SL:TStringList;
begin
   if (ParamCount > 0) then
   begin
      for FI:=1 to ParamCount do
      begin
         FileName :='';
         if (Length(ParamStr(FI)) > 1) and (ParamStr(FI)[2] = ':') then
            FileName:=ParamStr(FI)
         else
            FileName:=ExtractFilePath(ParamStr(0))+ParamStr(FI);
            
         if (FileName <> '') and FileExists(FileName) then
         begin
            BuildStat.Items.Add('Build List From : '+FileName);
            SL:=TStringList.Create;
            SL.LoadFromFile(FileName);
            for I:=0 to ComponentCount-1 do
            begin
               if Components[I] is TMemo then
                  (Components[I] as TMemo).Lines.Text:=StringFromSL(Components[I].Name,SL)
               else if Components[I] is TEdit then
                  (Components[I] as TEdit).Text:=StringFromSL(Components[I].Name,SL)
               else if Components[I] is TCheckBox then
                  (Components[I] as TCheckBox).Checked:=BoolFromSL(Components[I].Name,SL);
            end;
            SL.Free;
            Button1Click(Button1);
         end
      end;
   end;
end;

end.
