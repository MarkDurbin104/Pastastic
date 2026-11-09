unit BuilderFU;

interface

uses
  SavePosFormU,SyncObjs,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,FileCtrl,TokenParser,ParseNode,WinExecU, ComCtrls,Registry,
  ExtCtrls,PackStrListU;

const
   ThreadCount:Integer = 0;
   ThreadLimit = 1;
type
  TBuildLine = class(TObject)
    FFile:String;
    FLine:Integer;
    FError:String;
  public
     constructor Create(Path,ErrorLine:String);
  end;
  TBuildThread = class(TThread)
  public
     RunningAsThread:Boolean;
     Component:String;
     CPrefix  :String;
     Version  :String;
     CompType :String;
     SubGroup :String;
     UnReReg  :Boolean;
     ProgID   :String;
     OutEXEDir:String;
     OutPASDir:String;
     CommandLine:String;
     BuildLine:TBuildLine;
     ErrorString:String;
     IncludeDebug:Boolean;
     procedure Execute; override;
     procedure BDCC32;
     procedure AddLine;
  end;
//  TBuilder = class(TSavePosForm)
  TBuilder = class(TSavePosForm)
    PageControl1: TPageControl;
    BuildOptions: TTabSheet;
    CompilerProgress: TTabSheet;
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
    ListBox1: TListBox;
    Panel1: TPanel;
    PBar: TProgressBar;
    Panel2: TPanel;
    procedure BuildAllClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1DblClick(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
  private
    BA:Boolean;
    ST:Boolean;
    procedure ThreadComplete(Sender:TObject);
  public
    procedure RemOldFrom(var CompList:String;Nodes:TRootNode);
    procedure GenNewSource(CompList:String;Nodes:TRootNode);
    procedure BuildComponent(CompList:String;Nodes:TRootNode;UnReReg,IncludeDebug:Boolean);
  end;

    procedure BuildDCC32CFGFiles(CompType,DesGroup,ProjName:String;IncludeDebug:Boolean);
    procedure RegFile(FileName:String;UseRegserver:Boolean);
    procedure UnRegFile(FileName:String;UseRegserver:Boolean);
    procedure RegisterFile(ProgID,Name:String;Reg:Boolean; BuildThread : TBuildThread);

var
  Builder: TBuilder;
  CancelBuild:Boolean;

implementation

uses SourceFormFU,ProdGenU, IDSParseFU;

{$R *.DFM}
{TBuildThread}
procedure TBuildThread.AddLine;
begin
   Builder.ListBox1.Items.AddObject(ErrorString,BuildLine);
   if Copy(ErrorString,1,5) = 'Built' then
      Builder.PBar.StepBy(1);
   Builder.ListBox1.TopIndex:=Builder.ListBox1.Items.Count-1;
   Builder.ListBox1.ItemIndex:=Builder.ListBox1.Items.Count-1;
end;
procedure TBuildThread.BDCC32;
begin
    BuildDCC32CFGFiles(CompType,SubGroup,Component,IncludeDebug);
end;
procedure TBuildThread.Execute;
var
   CompilerOutput:String;
   CurrDir:String;
   ESL:TStringList;
   I:Integer;
   TC:TCriticalSection;
   EXEName:String;
begin
    TC:=nil;
    if RunningAsThread then TC:=TCriticalSection.Create;
    GetDir(0,CurrDir);
    Component:=CPrefix+'_'+Component+'_'+Version;

    if RunningAsThread then
       Synchronize(BDCC32)
    else
       BDCC32;

    if UnReReg then
    begin
       if RunningAsThread then TC.Enter;
       RegisterFile(ProgID,OutEXEDir+'\'+Component,False, self);
       if RunningAsThread then TC.Leave;
    end;

    if RunningAsThread then TC.Enter;
    ChDir(OutPASDir+'\'+CompType+SubGroup);
    WinExecAndWaitEnvTC(CommandLine+' "'+Component+'"',CompilerOutput,False,'PATH=%PATH%;'+OutEXEDir+#0#0#0#0,TC);
    
    if UnReReg then
    begin
       if RunningAsThread then TC.Enter;
       RegisterFile(ProgID,OutEXEDir+'\'+Component,True, self);
       if RunningAsThread then TC.Leave;
    end;

    BuildLine:=nil;
    ErrorString:='Built:-'+OutPASDir+'\'+CompType+SubGroup+'\'+Component+'.dpr';
    if RunningAsThread then
       Synchronize(AddLine)
    else
       AddLine;
    ESL:=TStringList.Create;
    ESL.Text:=CompilerOutput;
    for I:=0 to ESL.Count-1 do
    begin
       if StrScan(PChar(Copy(ESL[I],3,Length(ESL[I]))),':') <> nil then
       begin
          BuildLine:=TBuildLine.Create(OutPASDir+'\'+CompType+SubGroup,ESL[I]);
          ErrorString:=ESL[I];
          if RunningAsThread then
             Synchronize(AddLine)
          else
             AddLine;
       end
       else if ESL.Count = 1 then
       begin
          BuildLine:=nil;
          ErrorString:=ESL[I];
          if RunningAsThread then
             Synchronize(AddLine)
          else
             AddLine;
       end;
    end;
    CompilerOutput:='';
    if IncludeDebug then 
    begin
       if FileExists(OutEXEDir+'\'+Component+'.dll') then
       begin
          EXEName:=OutEXEDir+'\'+Component+'.dll';
          BuildLine:=nil;
          ErrorString:='TDSPacking :- '+EXEName;
          if RunningAsThread then
             Synchronize(AddLine)
          else
             AddLine;
          WinExecAndWait(ExtractFilePath(CommandLine)+'TDSPack -o -e '+' "'+EXEName,CompilerOutput,False);
       end
       else
       begin
          EXEName:=OutEXEDir+'\'+Component+'.exe';
          BuildLine:=nil;
          ErrorString:='TDSPacking :- '+EXEName;
          if RunningAsThread then
             Synchronize(AddLine)
          else
             AddLine;
          WinExecAndWait(ExtractFilePath(CommandLine)+'TDSPack -o -e '+' "'+EXEName,CompilerOutput,False);
       end;
       ESL.Text:=CompilerOutput;
       if (ESL.Count = 1) then
       begin
          BuildLine:=nil;
          ErrorString:=ESL[0];
          if RunningAsThread then
             Synchronize(AddLine)
          else
             AddLine;
       end
       else if (ESL.Count > 1) and (Copy(ESL[1],1,7) <> 'Reading') then
       begin
          for I:=0 to ESL.Count-1 do
          begin
             BuildLine:=nil;
             ErrorString:=ESL[I];
             if RunningAsThread then
                Synchronize(AddLine)
             else
                AddLine;
          end;
       end;
    end;
    
    ChDir(CurrDir);
    ESL.Free;
end;
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
{TBuilder}
procedure TBuilder.BuildAllClick(Sender: TObject);
begin
   if ST then 
      BuildAll.Checked:=BA;
end;

procedure TBuilder.FormShow(Sender: TObject);
begin
   BA:=BuildAll.Checked;
   ST:=True;
end;
procedure BuildDCC32CFGFiles(CompType,DesGroup,ProjName:String;IncludeDebug:Boolean);
var
  SL:TStringList;
  S:String;
  I:Integer;
  CompDir:String;
begin
  SL:=TStringList.Create;
//  if Builder.BuildAll.Checked then SL.Add('-B');

  S:='-A';
  for I:=0 to Builder.Aliases.Lines.Count-1 do
     S:=S+Builder.Aliases.Lines[I]+';';
  SL.Add(S);

  S:='-LU';
  for I:=0 to Builder.Packages.Lines.Count-1 do
     S:=S+Builder.Packages.Lines[I]+';';
  SL.Add(S);

  for I:=0 to Builder.InDCUDirs.Lines.Count-1 do
     SL.Add('-I"'+Builder.InDCUDirs.Lines[I]+'"');

  for I:=0 to Builder.InPASDirs.Lines.Count-1 do
     SL.Add('-U"'+Builder.InPASDirs.Lines[I]+'"');

  SL.Add('-E"'+Builder.OutEXEDir.Text+'"');
  SL.Add('-N"'+Builder.OutDCUDir.Text+'"');
  SL.Add('-LE"'+Builder.OutEXEDir.Text+'"');
  SL.Add('-LN"'+Builder.OutEXEDir.Text+'"');

  if IncludeDebug then 
  begin
     SL.Add('-V');
     SL.Add('-W+');
     SL.Add('-D+');
  end;
  
  if DesGroup = '' then
     CompDir:=Builder.OutPASDir.Text+'\'+CompType+'\'
  else
     CompDir:=Builder.OutPASDir.Text+'\'+CompType+'\'+DesGroup+'\';

  if not FileExists(CompDir)                then ForceDirectories(CompDir);
  if not FileExists(Builder.OutEXEDir.Text) then ForceDirectories(Builder.OutEXEDir.Text);
  if not FileExists(Builder.OutDCUDir.Text) then ForceDirectories(Builder.OutDCUDir.Text);
  SL.SaveToFile(CompDir+'dcc32.cfg');
//  SL.SaveToFile(CompDir+ProjName+'.cfg');
  SL.Clear;
  SL.Add('[Compiler]');
  if IncludeDebug then 
  begin
     SL.Add('W=1');
     SL.Add('DebugInfo=1');
  end;
  S:='UnitAliases=';
  for I:=0 to Builder.Aliases.Lines.Count-1 do
     S:=S+Builder.Aliases.Lines[I]+';';
  SL.Add(S);
  SL.Add('');
  SL.Add('[Directories]');
  SL.Add('OutputDir='+Builder.OutEXEDir.Text);
  SL.Add('UnitOutputDir='+Builder.OutDCUDir.Text);
  SL.Add('SearchPath='+ExtractFilePath(MainForm.OD.FileName));
  S:='Packages=';
  for I:=0 to Builder.Packages.Lines.Count-1 do
     S:=S+Builder.Packages.Lines[I]+';';
  SL.Add(S);
  SL.Add('UsePackages=1');
  SL.SaveToFile(CompDir+ProjName+'.dof');
end;
procedure RegFile(FileName:String;UseRegserver:Boolean);
type
  TRegUnRegFunc = procedure;
var
   HModule:THandle;
   RegFunc:TRegUnRegFunc;
   op:String;
begin
  try
     if (FileName = '') then Exit;
     if UpperCase(Copy(FileName,Length(FileName)-2,3)) = 'EXE' then
     begin
        try
           WinExec(PChar(FileName+' /RegServer'),SW_SHOW);
        except
           ShowMessage(FileName+' /RegServer - Failed');
        end;
     end
     else
     begin
        if UseRegserver then
        begin
           WinExecAndWaitEnv('Regsvr32 /s '+FileName,op,False,'PATH=%PATH%;'+Builder.OutEXEDir.Text+#0#0#0#0);
        end
        else
        begin
           HModule:=LoadLibrary(PChar(FileName));
           if HModule <> 0 then
           begin
              try
                 if GetProcAddress(HModule,'DllRegisterServer') <> nil then
                 begin
                    @RegFunc:=GetProcAddress(HModule,'DllRegisterServer');
                    if @RegFunc <> nil then
                       RegFunc;
                 end
                 else
                 begin
                    ShowMessage(FileName+' DllRegisterServer - Failed');
                 end;
              except
                 ShowMessage(FileName+' DllRegisterServer - Failed');
              end;
              FreeLibrary(HModule);
           end
           else
           begin
              ShowMessage('LoadLibrary('+FileName+') - Failed');
           end;
        end;
     end;
    except
      On E : Exception do
        ShowMessage(E.Message);
    end;

end;
procedure UnRegFile(FileName:String;UseRegserver:Boolean);
type
  TRegUnRegFunc = procedure;
var
   HModule:THandle;
   UnRegFunc:TRegUnRegFunc;
   op:String;
begin
  try
     if (FileName = '') then Exit;
     if UpperCase(Copy(FileName,Length(FileName)-2,3)) = 'EXE' then
     begin
        try
           WinExec(PChar(FileName+' /UnRegServer'),SW_HIDE);
        except
           ShowMessage(FileName+' /UnRegServer - Failed');
        end;
     end
     else
     begin
        if UseRegserver then
        begin
           WinExecAndWaitEnv('Regsvr32 /s /u '+FileName,op,False,'PATH=%PATH%;'+Builder.OutEXEDir.Text+#0#0#0#0);
        end
        else
        begin
           HModule:=LoadLibrary(PChar(FileName));
           if HModule <> 0 then
           begin
              try
                 if GetProcAddress(HModule,'DllUnregisterServer') <> nil then
                 begin
                    @UnRegFunc:=GetProcAddress(HModule,'DllUnregisterServer');
                    if @UnRegFunc <> nil then
                       UnRegFunc;
                 end;
              except
                 ShowMessage(FileName+' DllUnregisterServer - Failed');
              end;
              FreeLibrary(HModule);
           end;
        end;
     end;
    except
      On E : Exception do
        ShowMessage(E.Message);
    end;

end;
procedure RegisterFile(ProgID,Name:String;Reg : Boolean; BuildThread : TBuildThread);
var
   CLSID:String;
   SL:TStringList;
   I:Integer;
begin
  try
     if FileExists(Name+'.DLL') then
        Name:=Name+'.DLL'
     else if FileExists(Name+'.EXE') then
        Name:=Name+'.EXE'
     else
        Exit;

     if Reg then
     begin
        RegFile(Name,MainForm.UnRegReRegOnBuildRegServer1.Checked);
     end
     else
     begin
        with TRegistry.Create do
        begin
           RootKey:=HKEY_CLASSES_ROOT;
           if OpenKey(ProgID+'\Clsid',False) then
           begin
              CLSID:=ReadString('');
              CloseKey;
              DeleteKey(ProgID+'\Clsid');
              DeleteKey(ProgID);
              if OpenKey('CLSID\'+CLSID,False) then
              begin
                 SL:=TStringList.Create;
                 GetKeyNames(SL);
                 CloseKey;
                 for I:=0 to SL.Count-1 do
                    DeleteKey('CLSID\'+CLSID+'\'+SL[I]);
                 DeleteKey('CLSID\'+CLSID);
                 SL.Free;
              end;
           end;
           Free;
        end;
        UnRegFile(Name,MainForm.UnRegReRegOnBuildRegServer1.Checked);
     end;
  except
    On E : Exception do
    begin
      BuildThread.BuildLine:=nil;
      BuildThread.ErrorString:= E.Message;
      if BuildThread.RunningAsThread then
         BuildThread.Synchronize(BuildThread.AddLine)
      else
         BuildThread.AddLine;
    end;
  end;


end;
procedure TBuilder.ThreadComplete(Sender:TObject);
begin
   Dec(ThreadCount);
end;
procedure TBuilder.BuildComponent(CompList:String;Nodes:TRootNode;UnReReg,IncludeDebug:Boolean);
var
   CCount,I:Integer;
//   ESL:TStringList;
   RList:TStringList;
   CList:TStringList;
//   CurrDir:String;
//   CompilerOutput:String;
   Component:String;
   CompType:String;
   SubGroup:String;
   CPrefix:String;
   Version:String;
   ProductsNode:TNode;
   ProdNode:TProdNode;
   GroupsNode:TNode;
   GroupNode:TGroupNode;
   UGroupsNode:TNode;
   UGroupNode:TUGroupNode;
   WGroupsNode:TNode;
   WGroupNode:TWGroupNode;
   LookUpsNode:TNode;
   LookUpNode:TLookUpNode;
//   BuildLine:TBuildLine;
   ProgID:String;
   BuildThread:TBuildThread;
   BuiltGroups:Boolean;
begin
   BuiltGroups:=False;
   RList:=TStringList.Create;
   RList.Text:=CompList;
   CList:=TStringList.Create;
   if not Visible then Show else BringToFront;
   PageControl1.ActivePage:=Self.CompilerProgress;

   for I:=0 to ListBox1.Items.Count-1 do
     if (ListBox1.Items.Objects[I] <> nil) and (Copy(ListBox1.Items[I],1,5) <> 'Build') then
        TBuildLine(ListBox1.Items.Objects[I]).Free;
   Builder.PBar.Min:=0;
   Builder.PBar.Max:=RList.Count;
   Builder.PBar.Position:=0;
   for CCount:=0 to RList.Count-1 do
   begin
      Application.ProcessMessages;
      if (Application.Terminated) or (CancelBuild) then Exit;
      CList.CommaText:=RList[CCount];
      CompType:=CList[0];
      Component:=CList[1];
      ProgID:=CompType+'.'+Component;
      SubGroup:='';
      Version:='2';
      if UpperCase(CompType) = 'PRODUCT' then
      begin
         ProductsNode:=Nodes.SelectNode(ttProducts);
         if ProductsNode <> Nodes then
         begin
            ProdNode:=TProdNode(ProductsNode.SelectNode(Component));
            if ProdNode <> ProductsNode then
            begin
               SubGroup:=ProdNode.SubGroup;
               Version :=IntToStr(StrToIntDef(ProdNode.Version,2));
            end;
         end;
      end
      else if UpperCase(CompType) = 'GROUP' then
      begin
         GroupsNode:=Nodes.SelectNode(ttGroups);
         if GroupsNode <> Nodes then
         begin
            GroupNode:=TGroupNode(GroupsNode.SelectNode(Component));
            if GroupNode <> GroupsNode then
            begin
               SubGroup:=GroupNode.SubGroup;
               Version :=IntToStr(StrToIntDef(GroupNode.Version,2));
            end;
         end;
      end
      else if UpperCase(CompType) = 'USER' then
      begin
         UGroupsNode:=Nodes.SelectNode(ttUsers);
         if UGroupsNode <> Nodes then
         begin
            UGroupNode:=TUGroupNode(UGroupsNode.SelectNode(Component));
            if UGroupNode <> UGroupsNode then
            begin
               SubGroup:=UGroupNode.SubGroup;
               Version :=IntToStr(StrToIntDef(UGroupNode.Version,2));
            end;
         end;
      end
      else if UpperCase(CompType) = 'WORKSTATION' then
      begin
         WGroupsNode:=Nodes.SelectNode(ttWorkStations);
         if WGroupsNode <> Nodes then
         begin
            WGroupNode:=TWGroupNode(WGroupsNode.SelectNode(Component));
            if WGroupNode <> WGroupsNode then
            begin
               SubGroup:=WGroupNode.SubGroup;
               Version :=IntToStr(StrToIntDef(WGroupNode.Version,2));
            end;
         end;
      end
      else if UpperCase(CompType) = 'PICKLIST' then
      begin
         WGroupsNode:=Nodes.SelectNode(ttWorkStations);
         if WGroupsNode <> Nodes then
         begin
            WGroupNode:=TWGroupNode(WGroupsNode.SelectNode(Component));
            if WGroupNode <> WGroupsNode then
            begin
               SubGroup:=WGroupNode.SubGroup;
               Version :=IntToStr(StrToIntDef(WGroupNode.Version,2));
            end;
         end;
      end
      else if UpperCase(CompType) = 'LOOKUP' then
      begin
         LookUpsNode:=Nodes.SelectNode(ttLookUps);
         if LookUpsNode <> Nodes then
         begin
            LookUpNode:=TLookUpNode(LookUpsNode.SelectNode(Component));
            if LookUpNode <> LookUpsNode then
            begin
               SubGroup:=LookUpNode.SubGroup;
               Version :=IntToStr(StrToIntDef(LookUpNode.Version,2));
            end;
         end;
      end;

      if SubGroup <> '' then SubGroup:='\'+SubGroup;
      Version:='2';

      if UpperCase(CompType) = 'PICKLIST' then CPrefix:='K' else CPrefix:=CompType[1];
      
      if UpperCase(CompType) = 'GROUP' then
      begin
         if Not BuiltGroups then
         begin
            BuiltGroups:=True;
            BuildThread:=TBuildThread.Create(True);
            BuildThread.OnTerminate:=ThreadComplete;
            BuildThread.Component  :='Multi';
            BuildThread.CPrefix    :=CPrefix    ;
            BuildThread.Version    :=Version    ;
            BuildThread.CompType   :=CompType   ;
            BuildThread.SubGroup   :='';
            BuildThread.UnReReg    :=UnReReg    ;
            BuildThread.IncludeDebug:=IncludeDebug;
            BuildThread.ProgID     :='Group.Multi';
            BuildThread.OutEXEDir  :=OutEXEDir.Text  ;
            BuildThread.OutPASDir  :=OutPASDir.Text  ;
            BuildThread.CommandLine:=CommandLine.Text;
            if ThreadLimit = 1 then
            begin
               BuildThread.RunningAsThread:=False;
               BuildThread.Execute;
               BuildThread.Free;
            end
            else
            begin
               BuildThread.RunningAsThread:=True;
               BuildThread.FreeOnTerminate:=True;
               BuildThread.Resume;
               Inc(ThreadCount);
               if (ThreadCount >= ThreadLimit) then
               begin
                  while (ThreadCount >= ThreadLimit) and (not Application.Terminated) and (not CancelBuild) do
                     Application.ProcessMessages;
               end;
            end;
         end;
      end
      else
      begin
         BuildThread:=TBuildThread.Create(True);
         BuildThread.OnTerminate:=ThreadComplete;
         BuildThread.Component  :=Component  ;
         BuildThread.CPrefix    :=CPrefix    ;
         BuildThread.Version    :=Version    ;
         BuildThread.CompType   :=CompType   ;
         BuildThread.SubGroup   :=SubGroup   ;
         BuildThread.UnReReg    :=UnReReg    ;
         BuildThread.IncludeDebug:=IncludeDebug;
         BuildThread.ProgID     :=ProgID     ;
         BuildThread.OutEXEDir  :=OutEXEDir.Text  ;
         BuildThread.OutPASDir  :=OutPASDir.Text  ;
         BuildThread.CommandLine:=CommandLine.Text;
         if ThreadLimit = 1 then
         begin
            BuildThread.RunningAsThread:=False;
            BuildThread.Execute;
            BuildThread.Free;
         end
         else
         begin
            BuildThread.RunningAsThread:=True;
            BuildThread.FreeOnTerminate:=True;
            BuildThread.Resume;
            Inc(ThreadCount);
            if (ThreadCount >= ThreadLimit) then
            begin
               while (ThreadCount >= ThreadLimit) and (not Application.Terminated) and (not CancelBuild) do
                  Application.ProcessMessages;
            end;
         end;
      end;
   end;
   while (ThreadCount > 0) and (not Application.Terminated) and (not CancelBuild) do
      Application.ProcessMessages;

   if ListBox1.Items.Count = 0 then
      ListBox1.Items.Add('Nothing to Build.')
   else
      ListBox1.Items.Add('Build Complete.');
   ListBox1.TopIndex:=ListBox1.Items.Count-1;
   ListBox1.ItemIndex:=ListBox1.Items.Count-1;
   
   Beep;
end;
procedure TBuilder.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   FC:TColor;
begin
   with ListBox1.Canvas do
   begin
      FillRect(Rect);
      FC:=Font.Color;
      If Pos('Exception:', ListBox1.Items[Index])>0 then
        Font.Color:=clRed;

      if ListBox1.Items.Objects[Index] <> nil then
      begin
         if Pos('Hint:',ListBox1.Items[Index]) < 1 then
            Font.Color:=clRed
         else
            Font.Color:=clBlue;
      end;
      TextOut(Rect.Left+2,Rect.Top,ListBox1.Items[Index]);
      Font.Color:=FC;
   end;
end;

procedure TBuilder.ListBox1DblClick(Sender: TObject);
var
   BuildLine:TBuildLine;
begin
   if Copy(ListBox1.Items[ListBox1.ItemIndex],1,5) <> 'Build' then
   begin
      BuildLine:=TBuildLine(ListBox1.Items.Objects[ListBox1.ItemIndex]);
      if BuildLine <> nil then
      begin
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
function GetFileData(FileName:String):String;
var
   FileHandle:THandle;
begin
   Result:='';
   try
      FileHandle:=FileOpen(FileName,fmOpenRead or fmShareDenyNone);
      if FileHandle > 0 then
      begin
         Result:=IntToStr(FileGetDate(FileHandle));
         FileClose(FileHandle);
      end;
   except
   end;
end;
procedure TBuilder.RemOldFrom(var CompList:String;Nodes:TRootNode);
var
   CCount,I:Integer;
   RList:TStringList;
   CList:TStringList;
   Component:String;
   CompType:String;
   SubGroup:String;
   Version:String;
   BldDir:String;
   ProductsNode:TProductsNode;
   ProdNode:TProdNode;
   GroupsNode:TGroupsNode;
   GroupNode:TGroupNode;
   UGroupsNode:TUsersNode;
   UGroupNode:TUGroupNode;
   WGroupsNode:TWorkstationsNode;
   WGroupNode:TWGroupNode;
   PickListsNode:TPickListsNode;
   PickListNode:TPickListNode;
   LookUpsNode:TLookUpsNode;
   LookUpNode:TLookUpNode;
//   LogFormatNode:TLogFormatNode;
//   LogFormatsNode:TLogFormatsNode;
   OptionsNode:TOptionsNode;
   FieldData:String;
//   NL,OL:TStringList;
begin
   OptionsNode:=Nodes.BuildOptions;
   if OptionsNode = nil then Exit;
//   LogFormatsNode:=Nodes.LogFormats;
   RList:=TStringList.Create;
   RList.Text:=CompList;
   CList:=TStringList.Create;
   if not Visible then Show else BringToFront;
   PageControl1.ActivePage:=Self.CompilerProgress;
                       
   for I:=0 to ListBox1.Items.Count-1 do
     if (ListBox1.Items.Objects[I] <> nil) and (Copy(ListBox1.Items[I],1,5) <> 'Build') then
        TBuildLine(ListBox1.Items.Objects[I]).Free;
   ListBox1.Clear;
   ListBox1.Items.Add('Checking Previous Versions...');
   CCount:=0;
   while CCount < RList.Count do
   begin
      CList.CommaText:=RList[CCount];
      CompType:=CList[0];
      Component:=CList[1];
      Application.ProcessMessages;
      if (Application.Terminated) or (CancelBuild) then Exit;
      SubGroup:='';
      Version:='1';
      if UpperCase(CompType) = 'PRODUCT' then
      begin
         CList.Delete(0);
         CList.Delete(0);
         FieldData:=CList.CommaText;
         ProductsNode:=Nodes.Products;
         if ProductsNode <> nil then
         begin
            ProdNode:=ProductsNode.GetItemByName(Component);
            if ProdNode <> nil then
            begin
               if ProdNode.Description = '' then
               begin
                  if ProdNode.Title = '' then
                     ProdNode.Title:=ProdNode.Caption;
                  ProdNode.Description:=ProdNode.Title
               end
               else
               begin
                  if ProdNode.Title = '' then
                     ProdNode.Title:=ProdNode.Description
                  else
                     ProdNode.Title:=ProdNode.Caption;
               end;

//               LogFormatNode:=nil;
//               if LogFormatsNode <> nil then
//                  LogFormatNode:=LogFormatsNode.GetItemByName(ProdNode.LogAs);
               Version :=IntToStr(StrToIntDef(ProdNode.Version,1)+1);
{               NL:=TStringList.Create;
               NL.Add(GetFileData(OptionsNode.Product.Directory+'\'+OptionsNode.Product.ProjFile));
               NL.Add(GetFileData(OptionsNode.Product.Directory+'\'+OptionsNode.Product.AutoFile));
               for I:=0 to OptionsNode.Product.FormFiles.Count-1 do
                  NL.Add(GetFileData(OptionsNode.Product.Directory+'\'+OptionsNode.Product.FormFiles[I]));
               for I:=0 to OptionsNode.Product.Dependencies.Count-1 do
                  NL.Add(GetFileData(OptionsNode.Product.Dependencies[I]));
               NL.Add('T'+ProdNode.NodeName+'Product');
               NL.Add('P_'+ProdNode.NodeName+'_'+Version);
               NL.Add('P_'+ProdNode.NodeName+'AU_'+Version);
               NL.Add('P_'+ProdNode.NodeName+'AU_'+Version+'.pas');
               NL.Add('P_'+ProdNode.NodeName+'FU_'+Version+'.pas');
               NL.Add('Product.'+ProdNode.NodeName);
//               NL.Add(ProdNode.RegDesc);
               NL.Add(ProdNode.BarCode      );
               NL.Add(ProdNode.Description  );
               NL.Add(ProdNode.EndDate      );
               NL.Add(ProdNode.HighDays     );
               NL.Add(ProdNode.MaxQuantity  );
               NL.Add(ProdNode.MCRCode      );
               NL.Add(ProdNode.MinQuantity  );
               NL.Add(ProdNode.OCRCode      );
               NL.Add(ProdNode.OtherCode    );
               NL.Add(ProdNode.PLU          );
               NL.Add(ProdNode.Regulations  );
               NL.Add(ProdNode.StartDate    );
               NL.Add(ProdNode.UnitPrice    );
               NL.Add(ProdNode.UnitQuantity );
               NL.Add(ProdNode.UseDays      );
               NL.Add(ProdNode.Title        );
               NL.Add(ProdNode.Prompt       );
               NL.Add(ProdNode.Hint         );
               NL.Add(ProdNode.NodeName     );
               NL.Add(ProdNode.ProjectFiles );
               NL.Add(ProdNode.Bitmap       );
               NL.Add(ProdNode.PrintList    );
               NL.Add(ProdNode.Endorse      );
               NL.Add(ProdNode.Customer     );
               NL.Add(FieldData             );
               NL.Add(ProdNode.SubGroup     );
               NL.Add(IntToStr(ProdNode.Count));
               for I:=0 to ProdNode.Count-1 do
                  NL.Add(ProdNode.Item[I]);

               for I:=0 to ProdNode.Snippets.Count-1 do
               begin
                  NL.Add(ProdNode.Snippets[I]);
                  NL.Add(ProdNode.Snippet[I].InsertBetweenStart);
                  NL.Add(ProdNode.Snippet[I].InsertBetweenEnd);
                  NL.Add(ProdNode.Snippet[I].CodeBlock);
               end;

               if LogFormatNode <> nil then
                  NL.Add(LogFormatNode.Format); }

               SubGroup:=ProdNode.SubGroup;
               if SubGroup <> '' then SubGroup:='\'+SubGroup;
               BldDir:=OutPASDir.Text+'\'+CompType+SubGroup;
               if not FileExists(BldDir) then
                  ForceDirectories(BldDir);
{               if (FileExists(BldDir+'\P_'+ProdNode.NodeName+'_'+Version+'.dpr')) and
                  (FileExists(BldDir+'\P_'+ProdNode.NodeName+'AU_'+Version+'.pas')) and
                  (FileExists(BldDir+'\'+'P_'+ProdNode.NodeName+'.ido')) then
               begin
                  OL:=TStringList.Create;
                  OL.LoadFromFile(BldDir+'\'+'P_'+ProdNode.NodeName+'.ido');
                  if OL.CommaText <> NL.CommaText then
                  begin
                     NL.SaveToFile(BldDir+'\'+'P_'+ProdNode.NodeName+'.ido');
                  end
                  else
                  begin
                     RList.Delete(CCount);
                     Dec(CCount);
                  end;
                  OL.Free;
               end
               else
               begin
                  NL.SaveToFile(BldDir+'\'+'P_'+ProdNode.NodeName+'.ido');
               end;
               NL.Free; }
            end;
         end;
      end
      else if UpperCase(CompType) = 'GROUP' then
      begin
         GroupsNode:=Nodes.Groups;
         if GroupsNode <> nil then
         begin
            GroupNode:=GroupsNode.GetItemByName(Component);
            if GroupNode <> nil then
            begin
{               NL:=TStringList.Create;
               NL.Add(GetFileData(OptionsNode.Group.Directory+'\'+OptionsNode.Group.ProjFile));
               NL.Add(GetFileData(OptionsNode.Group.Directory+'\'+OptionsNode.Group.AutoFile));
               for I:=0 to OptionsNode.Group.Dependencies.Count-1 do
                  NL.Add(GetFileData(OptionsNode.Group.Dependencies[I])); }
               SubGroup:=GroupNode.SubGroup;
               Version :=IntToStr(StrToIntDef(GroupNode.Version,1)+1);
               GroupNode.RegDesc:='CORVUS MultiGroup Component';
{               NL.Add('T'+GroupNode.NodeName+'Group');
               NL.Add('G_'+GroupNode.NodeName+'_'+Version+'.dpr');
               NL.Add('G_'+GroupNode.NodeName+'AU_'+Version+'.pas');
               NL.Add('Group.'+GroupNode.NodeName);
//               NL.Add(GroupNode.RegDesc);
               NL.Add(Version);
               NL.Add(GroupNode.Title       );
//               NL.Add(GroupNode.Key         );
               NL.Add(GroupNode.Title       );
               NL.Add(GroupNode.Prompt      );
               NL.Add(GroupNode.Hint        );
               NL.Add(GroupNode.ProjectFiles);
               NL.Add(GroupNode.BitMap      );

               NL.Add(IntToStr(GroupNode.Count));
               for I:=0 to GroupNode.Count-1 do
                  NL.Add(GroupNode.Item[I]); }

               if SubGroup <> '' then SubGroup:='\'+SubGroup;
               BldDir:=OutPASDir.Text+'\'+CompType+SubGroup;
               if not FileExists(BldDir) then
                  ForceDirectories(BldDir);

{               if (FileExists(BldDir+'\G_'+GroupNode.NodeName+'_'+Version+'.dpr')) and
                  (FileExists(BldDir+'\G_'+GroupNode.NodeName+'AU_'+Version+'.pas')) and
                  (FileExists(BldDir+'\'+'G_'+GroupNode.NodeName+'.ido')) then
               begin
                  OL:=TStringList.Create;
                  OL.LoadFromFile(BldDir+'\'+'G_'+GroupNode.NodeName+'.ido');
                  if OL.CommaText <> NL.CommaText then
                  begin
                     NL.SaveToFile(BldDir+'\'+'G_'+GroupNode.NodeName+'.ido');
                  end
                  else
                  begin
                     RList.Delete(CCount);
                     Dec(CCount);
                  end;
                  OL.Free;
               end
               else
               begin
                  NL.SaveToFile(BldDir+'\'+'G_'+GroupNode.NodeName+'.ido');
               end;
               NL.Free; }
            end;
         end;
      end
      else if UpperCase(CompType) = 'USER' then
      begin
         UGroupsNode:=Nodes.Users;
         if UGroupsNode <> nil then
         begin
            UGroupNode:=UGroupsNode.GetItemByName(Component);
            if UGroupNode <> nil then
            begin
{               NL:=TStringList.Create;
               NL.Add(GetFileData(OptionsNode.UGroup.Directory+'\'+OptionsNode.UGroup.ProjFile));
               NL.Add(GetFileData(OptionsNode.UGroup.Directory+'\'+OptionsNode.UGroup.AutoFile));
               for I:=0 to OptionsNode.UGroup.Dependencies.Count-1 do
                  NL.Add(GetFileData(OptionsNode.UGroup.Dependencies[I])); }
               SubGroup:=UGroupNode.SubGroup;
               Version :=IntToStr(StrToIntDef(UGroupNode.Version,1)+1);
{               NL.Add('T'+UGroupNode.NodeName+'UGroup');
               NL.Add('U_'+UGroupNode.NodeName+Version+'.dpr');
               NL.Add('U_'+UGroupNode.NodeName+'AU_'+Version+'.pas');
               NL.Add('UGroup.'+UGroupNode.NodeName);
//               NL.Add(UGroupNode.RegDesc);
               NL.Add(Version);

               NL.Add(IntToStr(UGroupNode.Count));
               for I:=0 to UGroupNode.Count-1 do
                  NL.Add(UGroupNode.Item[I]); }

               if SubGroup <> '' then SubGroup:='\'+SubGroup;
               BldDir:=OutPASDir.Text+'\'+CompType+SubGroup;
               if not FileExists(BldDir) then
                  ForceDirectories(BldDir);

{               if (FileExists(BldDir+'\U_'+UGroupNode.NodeName+'_'+Version+'.dpr')) and
                  (FileExists(BldDir+'\U_'+UGroupNode.NodeName+'AU_'+Version+'.pas')) and
                  (FileExists(BldDir+'\'+'U_'+UGroupNode.NodeName+'.ido')) then
               begin
                  OL:=TStringList.Create;
                  OL.LoadFromFile(BldDir+'\'+'U_'+UGroupNode.NodeName+'.ido');
                  if OL.CommaText <> NL.CommaText then
                  begin
                     NL.SaveToFile(BldDir+'\'+'U_'+UGroupNode.NodeName+'.ido');
                  end
                  else
                  begin
                     RList.Delete(CCount);
                     Dec(CCount);
                  end;
                  OL.Free;
               end
               else
               begin
                  NL.SaveToFile(BldDir+'\'+'U_'+UGroupNode.NodeName+'.ido');
               end;
               NL.Free; }
            end;
         end;
      end
      else if UpperCase(CompType) = 'WORKSTATION' then
      begin
         WGroupsNode:=Nodes.WorkStations;
         if WGroupsNode <> nil then
         begin
            WGroupNode:=WGroupsNode.GetItemByName(Component);
            if WGroupNode <> nil then
            begin
{               NL:=TStringList.Create;
               NL.Add(GetFileData(OptionsNode.WGroup.Directory+'\'+OptionsNode.WGroup.ProjFile));
               NL.Add(GetFileData(OptionsNode.WGroup.Directory+'\'+OptionsNode.WGroup.AutoFile));
               for I:=0 to OptionsNode.WGroup.Dependencies.Count-1 do
                  NL.Add(GetFileData(OptionsNode.WGroup.Dependencies[I])); }
               SubGroup:=WGroupNode.SubGroup;
               Version :=IntToStr(StrToIntDef(WGroupNode.Version,1)+1);
{               NL.Add('T'+WGroupNode.NodeName+'WGroup');
               NL.Add('W_'+WGroupNode.NodeName+Version+'.dpr');
               NL.Add('W_'+WGroupNode.NodeName+'AU_'+Version+'.pas');
               NL.Add('WGroup.'+WGroupNode.NodeName);
//               NL.Add(WGroupNode.RegDesc);
               NL.Add(Version);

               NL.Add(IntToStr(WGroupNode.Count));
               for I:=0 to WGroupNode.Count-1 do
                  NL.Add(WGroupNode.Item[I]); }

               if SubGroup <> '' then SubGroup:='\'+SubGroup;
               BldDir:=OutPASDir.Text+'\'+CompType+SubGroup;
               if not FileExists(BldDir) then
                  ForceDirectories(BldDir);

{               if (FileExists(BldDir+'\W_'+WGroupNode.NodeName+'_'+Version+'.dpr')) and
                  (FileExists(BldDir+'\W_'+WGroupNode.NodeName+'AU_'+Version+'.pas')) and
                  (FileExists(BldDir+'\'+'W_'+WGroupNode.NodeName+'.ido')) then
               begin
                  OL:=TStringList.Create;
                  OL.LoadFromFile(BldDir+'\'+'W_'+WGroupNode.NodeName+'.ido');
                  if OL.CommaText <> NL.CommaText then
                  begin
                     NL.SaveToFile(BldDir+'\'+'W_'+WGroupNode.NodeName+'.ido');
                  end
                  else
                  begin
                     RList.Delete(CCount);
                     Dec(CCount);
                  end;
                  OL.Free;
               end
               else
               begin
                  NL.SaveToFile(BldDir+'\'+'W_'+WGroupNode.NodeName+'.ido');
               end;
               NL.Free; }
            end;
         end;
      end
      else if UpperCase(CompType) = 'PICKLIST' then
      begin
         PickListsNode:=Nodes.PickLists;
         if PickListsNode <> nil then
         begin
            PickListNode:=PickListsNode.GetItemByName(Component);
            if PickListNode <> nil then
            begin
{               NL:=TStringList.Create;
               NL.Add(GetFileData(OptionsNode.PickList.Directory+'\'+OptionsNode.PickList.ProjFile));
               NL.Add(GetFileData(OptionsNode.PickList.Directory+'\'+OptionsNode.PickList.AutoFile));
               for I:=0 to OptionsNode.PickList.Dependencies.Count-1 do
                  NL.Add(GetFileData(OptionsNode.PickList.Dependencies[I])); }
               Version :=IntToStr(StrToIntDef(PickListNode.Version,1)+1);

{               NL.Add('T'+PickListNode.NodeName+'PickList');
               NL.Add('K_'+PickListNode.NodeName+'_'+Version+'.dpr');
               NL.Add('K_'+PickListNode.NodeName+'AU_'+Version+'.pas');
               NL.Add('PickList.'+PickListNode.NodeName);
//               NL.Add(PickListNode.RegDesc);
               NL.Add(Version);

               NL.Add(PickListNode.NodeName);
               NL.Add('Zone');

               for I:=0 to PickListNode.Items.Count-1 do
                  NL.Add(PickListNode.Items[I]);
               for I:=0 to PickListNode.Zones.Count-1 do
                  NL.Add(PickListNode.Zones[I]); }

               if SubGroup <> '' then SubGroup:='\'+SubGroup;
               BldDir:=OutPASDir.Text+'\'+CompType+SubGroup;
               if not FileExists(BldDir) then
                  ForceDirectories(BldDir);

{               if (FileExists(BldDir+'\K_'+PickListNode.NodeName+'_'+Version+'.dpr')) and
                  (FileExists(BldDir+'\K_'+PickListNode.NodeName+'AU_'+Version+'.pas')) and
                  (FileExists(BldDir+'\'+'K_'+PickListNode.NodeName+'.ido')) then
               begin
                  OL:=TStringList.Create;
                  OL.LoadFromFile(BldDir+'\'+'K_'+PickListNode.NodeName+'.ido');
                  if OL.CommaText <> NL.CommaText then
                  begin
                     NL.SaveToFile(BldDir+'\'+'K_'+PickListNode.NodeName+'.ido');
                  end
                  else
                  begin
                     RList.Delete(CCount);
                     Dec(CCount);
                  end;
                  OL.Free;
               end
               else
               begin
                  NL.SaveToFile(BldDir+'\'+'K_'+PickListNode.NodeName+'.ido');
               end;
               NL.Free; }
            end;
         end;
      end
      else if UpperCase(CompType) = 'LOOKUP' then
      begin
         LookUpsNode:=Nodes.LookUps;
         if LookUpsNode <> nil then
         begin
            LookUpNode:=LookUpsNode.GetItemByName(Component);
            if LookUpNode <> nil then
            begin
{               NL:=TStringList.Create;
               NL.Add(GetFileData(OptionsNode.LookUp.Directory+'\'+OptionsNode.LookUp.ProjFile));
               NL.Add(GetFileData(OptionsNode.LookUp.Directory+'\'+OptionsNode.LookUp.AutoFile));
               for I:=0 to OptionsNode.LookUp.Dependencies.Count-1 do
                  NL.Add(GetFileData(OptionsNode.LookUp.Dependencies[I]));
 }
               Version :=IntToStr(StrToIntDef(LookUpNode.Version,1)+1);
               SubGroup:=LookUpNode.SubGroup;
{               NL.Add('T'+LookUpNode.NodeName+'LookUp');
               NL.Add('L_'+LookUpNode.NodeName+'_'+Version+'.dpr');
               NL.Add('L_'+LookUpNode.NodeName+'AU_'+Version+'.pas');
               NL.Add('LookUp.'+LookUpNode.NodeName);
//               NL.Add(LookUpNode.RegDesc);
               NL.Add(Version);

               for I:=0 to LookUpNode.ZoneNames.Count-1 do
                  NL.Add(LookUpNode.ZoneNames[I]);

               for I:=0 to LookUpNode.Ranges.Count-1 do
                  NL.Add(LookUpNode.Ranges[I]);

               for I:=0 to LookUpNode.Zones.Count-1 do
                  NL.Add(LookUpNode.Zones[I]);
}
               if SubGroup <> '' then SubGroup:='\'+SubGroup;
               BldDir:=OutPASDir.Text+'\'+CompType+SubGroup;
               if not FileExists(BldDir) then
                  ForceDirectories(BldDir);

{               if (FileExists(BldDir+'\L_'+LookUpNode.NodeName+'_'+Version+'.dpr')) and
                  (FileExists(BldDir+'\L_'+LookUpNode.NodeName+'AU_'+Version+'.pas')) and
                  (FileExists(BldDir+'\'+'L_'+LookUpNode.NodeName+'.ido')) then
               begin
                  OL:=TStringList.Create;
                  OL.LoadFromFile(BldDir+'\'+'L_'+LookUpNode.NodeName+'.ido');
                  if OL.CommaText <> NL.CommaText then
                  begin
                     NL.SaveToFile(BldDir+'\'+'L_'+LookUpNode.NodeName+'.ido');
                  end
                  else
                  begin
                     RList.Delete(CCount);
                     Dec(CCount);
                  end;
                  OL.Free;
               end
               else
               begin
                  NL.SaveToFile(BldDir+'\'+'L_'+LookUpNode.NodeName+'.ido');
               end;
               NL.Free; }
            end;
         end;
      end;
      Inc(CCount);
   end;
   CompList:=RList.Text;
end;
procedure TBuilder.GenNewSource(CompList:String;Nodes:TRootNode);
var
   CCount,I,J:Integer;
   RList:TStringList;
   CList:TStringList;
   Component:String;
   CompType:String;
   SubGroup:String;
   Version:String;
   BldDir:String;
   ProductsNode:TProductsNode;
   ProdNode:TProdNode;
   ProductGen:TProductGen;
   GroupsNode:TGroupsNode;
   GroupNode:TGroupNode;
   GroupGen:TGroupGen;
   UGroupsNode:TUsersNode;
   UGroupNode:TUGroupNode;
   UGroupGen:TUGroupGen;
   WGroupsNode:TWorkstationsNode;
   WGroupNode:TWGroupNode;
   WGroupGen:TWGroupGen;
   PickListsNode:TPickListsNode;
   PickListNode:TPickListNode;
   PickListGen:TPickListGen;
   LookUpsNode:TLookUpsNode;
   LookUpNode:TLookUpNode;
   LogFormatNode:TLogFormatNode;
   LogFormatsNode:TLogFormatsNode;
   LookUpGen:TLookUpGen;
   OptionsNode:TOptionsNode;
   OrigFile,FieldData:String;
   PP,PA,PF,PC:String;
   GP,GA:String;
   LP,LA:String;
   KP,KA:String;
   UP,UA:String;
   WP,WA:String;
   OPThread:TOPThread;
   GroupsBuilt:Boolean;
   SL:TPackStringList;
   WriteConst : boolean ;
begin
   WriteConst:= False ;
   GroupsBuilt:=False;
   OptionsNode:=Nodes.BuildOptions;
   if OptionsNode <> nil then
   begin
      CList:=TStringList.Create;
      CList.LoadFromFile(OptionsNode.Product.Directory+'\'+OptionsNode.Product.ProjFile);
      PP:=CList.Text;
      CList.LoadFromFile(OptionsNode.Product.Directory+'\'+OptionsNode.Product.AutoFile);
      PA:=CList.Text;

      if OptionsNode.Product.ContsFile <> '' then
         CList.LoadFromFile(OptionsNode.Product.Directory+'\'+OptionsNode.Product.ContsFile)
      else
         CList.Text:='';
         
      PC:=CList.Text;

      OrigFile:=OptionsNode.Product.Directory+'\'+OptionsNode.Product.FormFiles[0];
      PF:='';
      if FileExists(OrigFile) then
      begin
         CList.LoadFromFile(OrigFile);
         PF:=CList.Text;
      end;
      CList.LoadFromFile(OptionsNode.Group.Directory+'\'+OptionsNode.Group.ProjFile);
      GP:=CList.Text;
      CList.LoadFromFile(OptionsNode.Group.Directory+'\'+OptionsNode.Group.AutoFile);
      GA:=CList.Text;
      CList.LoadFromFile(OptionsNode.LookUp.Directory+'\'+OptionsNode.LookUp.ProjFile);
      LP:=CList.Text;
      CList.LoadFromFile(OptionsNode.LookUp.Directory+'\'+OptionsNode.LookUp.AutoFile);
      LA:=CList.Text;
      CList.LoadFromFile(OptionsNode.PickList.Directory+'\'+OptionsNode.PickList.ProjFile);
      KP:=CList.Text;
      CList.LoadFromFile(OptionsNode.PickList.Directory+'\'+OptionsNode.PickList.AutoFile);
      KA:=CList.Text;
      CList.LoadFromFile(OptionsNode.UGroup.Directory+'\'+OptionsNode.UGroup.ProjFile);
      UP:=CList.Text;
      CList.LoadFromFile(OptionsNode.UGroup.Directory+'\'+OptionsNode.UGroup.AutoFile);
      UA:=CList.Text;
      CList.LoadFromFile(OptionsNode.WGroup.Directory+'\'+OptionsNode.WGroup.ProjFile);
      WP:=CList.Text;
      CList.LoadFromFile(OptionsNode.WGroup.Directory+'\'+OptionsNode.WGroup.AutoFile);
      WA:=CList.Text;
      CList.Free;
   end;
   RList:=TStringList.Create;
   RList.Text:=CompList;
   CList:=TStringList.Create;
   if not Visible then Show else BringToFront;
   PageControl1.ActivePage:=Self.CompilerProgress;

   for I:=0 to ListBox1.Items.Count-1 do
     if (ListBox1.Items.Objects[I] <> nil) and (Copy(ListBox1.Items[I],1,5) <> 'Build') then
        TBuildLine(ListBox1.Items.Objects[I]).Free;
   ListBox1.Clear;

   LogFormatsNode:=Nodes.LogFormats;
   LogFormatNode:=nil;
   Builder.PBar.Min:=0;
   Builder.PBar.Max:=RList.Count;
   Builder.PBar.Position:=0;
   for CCount:=0 to RList.Count-1 do
   begin
      CList.CommaText:=RList[CCount];
      CompType:=CList[0];
      Component:=CList[1];
      Builder.PBar.StepBy(1);
      if UpperCase(CompType) <> 'GROUP' then
      begin
         ListBox1.Items.Add('Generating '+CompType+' '+Component);
         ListBox1.ItemIndex:=ListBox1.Items.Count-1;
      end;
      Application.ProcessMessages;
      if (Application.Terminated) or (CancelBuild) then Exit;
      SubGroup:='';
      Version:='1';
      if UpperCase(CompType) = 'PRODUCT' then
      begin
         CList.Delete(0);
         CList.Delete(0);
         FieldData:=CList.CommaText;
         ProductsNode:=Nodes.Products;
         if ProductsNode <> nil then
         begin
            ProdNode:=ProductsNode.GetItemByName(Component);
            if ProdNode <> nil then
            begin
               ProductGen:=TProductGen.Create('');
               SubGroup:=ProdNode.SubGroup;
               Version :=IntToStr(StrToIntDef(ProdNode.Version,1)+1);
               ProductGen.PClass      :='T'+ProdNode.NodeName+'Product';
               ProductGen.PName       :='P_'+ProdNode.NodeName+'_'+Version;
               ProductGen.UName       :='P_'+ProdNode.NodeName+'AU_'+Version;
               ProductGen.UFile       :=ProductGen.UName+'.pas';
               ProductGen.FName       :='P_'+ProdNode.NodeName+'FU_'+Version;
               ProductGen.FFile       :=ProductGen.FName+'.pas';
               ProductGen.CName       :=OptionsNode.OutConstName ;
               ProductGen.CFile       :=OutPASDir.Text+'\'+OptionsNode.OutConstName+'.pas'  ;
               ProductGen.PGUID       :='';
               ProductGen.PProgID     :='Product.'+ProdNode.NodeName;
               if ProdNode.RegDesc = '' then ProdNode.RegDesc:='CORVUS '+ProdNode.Title+' Product';
               if Copy(ProdNode.RegDesc,1,7) <> 'CORVUS ' then
                  ProductGen.PRegDesc    :='CORVUS '+ProdNode.RegDesc
               else
                  ProductGen.PRegDesc    :=ProdNode.RegDesc;
               ProductGen.Version     :=Version;

               ProductGen.BarCode     :=ProdNode.BarCode      ;
               ProductGen.Description :=ProdNode.Description  ;
               ProductGen.EndDate     :=ProdNode.EndDate      ;
               ProductGen.HighDays    :=ProdNode.HighDays     ;
               ProductGen.MaxQuantity :=ProdNode.MaxQuantity  ;
               ProductGen.MCRCode     :=ProdNode.MCRCode      ;
               ProductGen.MinQuantity :=ProdNode.MinQuantity  ;
               ProductGen.OCRCode     :=ProdNode.OCRCode      ;
               ProductGen.OtherCode   :=ProdNode.OtherCode    ;
               ProductGen.PLU         :=ProdNode.PLU          ;
               ProductGen.Regulations :=ProdNode.Regulations  ;
               ProductGen.StartDate   :=ProdNode.StartDate    ;
               ProductGen.UnitPrice   :=ProdNode.UnitPrice    ;
               ProductGen.UnitQuantity:=ProdNode.UnitQuantity ;
               ProductGen.UseDays     :=ProdNode.UseDays      ;
               ProductGen.Caption     :=ProdNode.Caption      ;
               ProductGen.Title       :=ProdNode.Title        ;
               ProductGen.Prompt      :=ProdNode.Prompt       ;
               ProductGen.Hint        :=ProdNode.Hint         ;
               ProductGen.Name        :=ProdNode.NodeName;
               ProductGen.ProjectFiles:=ProdNode.ProjectFiles;
               ProductGen.PrintList   :=ProdNode.PrintList;
               ProductGen.Endorse     :=ProdNode.Endorse  ;
               ProductGen.Customer    :=ProdNode.Customer ;
               ProductGen.Taxes        :=ProdNode.Taxes        ;
               ProductGen.MOPs         :=ProdNode.MOPs         ;
               ProductGen.AvailAfterEOD:=ProdNode.AvailAfterEOD;
               if Nodes.Constants <> nil then
                  ProductGen.Constants   :=Nodes.Constants.AsString;

               ProductGen.BitMap:=ProdNode.Image;
               ProductGen.Controls:=FieldData;
               if LogFormatsNode <> nil then
                  LogFormatNode:=LogFormatsNode.GetItemByName(ProdNode.LogAs);
               if LogFormatNode <> nil then
                  ProductGen.LogFormat:=LogFormatNode.Format;

               if SubGroup <> '' then SubGroup:='\'+SubGroup;

               for I:=0 to ProdNode.Count-1 do
                  ProductGen.Items.Add(ProdNode.Item[I]);

                for I:=0 to ProdNode.Snippets.Count-1 do
                begin
                 try
                   ProductGen.Snippets.Add(ProdNode.Snippet[I].InsertBetweenStart);
                   ProductGen.Snippets.Add(ProdNode.Snippet[I].InsertBetweenEnd);
                   ProductGen.Snippets.Add(ProdNode.Snippet[I].CodeBlock);

                 except
                   On E : Exception do
                    ListBox1.Items.Add('Exception: Snippet ' + ProdNode.Snippets[I] + ' : ' + E.Message);
                 end;
                end;
               BldDir:=OutPASDir.Text+'\'+CompType+SubGroup;

               ForceDirectories(BldDir);

               OptionsNode:=Nodes.BuildOptions;
               if OptionsNode <> nil then
               begin
                  ProductGen.LoadFromString(PP);
                  ProductGen.SaveToFile(BldDir+'\'+ProductGen.PName+'.dpr');
                  ProductGen.LoadFromString(PA);
                  ProductGen.SaveToFile(BldDir+'\'+ProductGen.UFile);
                  if (not WriteConst) and (PC <> '') then
                  begin
                     ProductGen.LoadFromString(PC);
                     ProductGen.SaveToFile(ProductGen.CFile);
                     WriteConst := True ;   
                  end ;

                  if PF <> '' then
                  begin
                     ProductGen.LoadFromString(PF);
                     ProductGen.SaveToFile(BldDir+'\'+ProductGen.FFile);
                     GenerateFormFile(BldDir+'\'+ProductGen.FName+'.dfm',FieldData);
                  end;
               end;
               ProductGen.Free;
            end;
         end;
      end
      else if UpperCase(CompType) = 'GROUP' then
      begin
         if Not GroupsBuilt then
         begin
            ListBox1.Items.Add('Generating Group Multi');
            ListBox1.ItemIndex:=ListBox1.Items.Count-1;
            GroupsNode:=Nodes.Groups;
            if GroupsNode <> nil then
            begin
               GroupGen:=TGroupGen.Create('');
               Version:='2';
               GroupsBuilt:=True;
               SubGroup:='';
               GroupGen.PClass      :='TMultiGroup';
               GroupGen.PName       :='G_Multi_'+Version;
               GroupGen.UName       :='G_MultiAU_'+Version;
               GroupGen.UFile       :=GroupGen.UName+'.pas';
               GroupGen.PGUID       :='';
               GroupGen.PProgID     :='Group.Multi';
               GroupGen.Version     :=Version;
               GroupGen.PRegDesc:='CORVUS MultiGroup Component';
               SL:=TPackStringList.Create; 
               for I:=0 to GroupsNode.Count-1 do
               begin
                  GroupNode:=GroupsNode[I];
                  if (GroupNode <> nil) then
                  begin
                     if GroupNode.Caption = '' then
                        GroupNode.Caption:=GroupNode.Title;
                     if GroupNode.Title = '' then
                        GroupNode.Title:=GroupNode.Caption;
                     if GroupNode.Caption = '' then
                     begin
                        GroupNode.Caption:=GroupNode.NodeName;
                        GroupNode.Title  :=GroupNode.NodeName;
                     end;
                     GroupGen.Captions.Add(GroupNode.Caption );
                     GroupGen.Titles  .Add(GroupNode.Title   );
                     GroupGen.Names   .Add(GroupNode.NodeName);
                     GroupGen.BitMaps .Add(GroupNode.Image   );
                     SL.Clear;
                     for J:=0 to GroupNode.Count-1 do
                        SL.Add(GroupNode.Item[J]);
                     GroupGen.Items.Add(SL.PackText);
                  end;
               end;
               BldDir:=OutPASDir.Text+'\'+CompType;
               ForceDirectories(BldDir);
               OptionsNode:=Nodes.BuildOptions;
               if OptionsNode <> nil then
               begin
                  GroupGen.LoadFromString(GP);
                  GroupGen.SaveToFile  (BldDir+'\'+GroupGen.PName+'.dpr');
                  GroupGen.LoadFromString(GA);
                  GroupGen.SaveToFile  (BldDir+'\'+GroupGen.UFile);
               end;
               GroupGen.Free;
            end;
         end;
      end
      else if UpperCase(CompType) = 'USER' then
      begin
         UGroupsNode:=Nodes.Users;
         if UGroupsNode <> nil then
         begin
            UGroupNode:=UGroupsNode.GetItemByName(Component);
            if UGroupNode <> nil then
            begin
               UGroupGen:=TUGroupGen.Create('');
               SubGroup:=UGroupNode.SubGroup;
               Version :=IntToStr(StrToIntDef(UGroupNode.Version,1)+1);
               UGroupGen.PClass      :='T'+UGroupNode.NodeName+'UGroup';
               UGroupGen.PName       :='U_'+UGroupNode.NodeName+'_'+Version;
               UGroupGen.UName       :='U_'+UGroupNode.NodeName+'AU_'+Version;
               UGroupGen.UFile       :=UGroupGen.UName+'.pas';
               UGroupGen.PGUID       :='';
               UGroupGen.PProgID     :='UGroup.'+UGroupNode.NodeName;
               if UGroupNode.RegDesc = '' then UGroupNode.RegDesc:='CORVUS '+UGroupNode.NodeName+' User Group';
               if Copy(UGroupNode.RegDesc,1,7) <> 'CORVUS ' then
                  UGroupGen.PRegDesc    :='CORVUS '+UGroupNode.RegDesc
               else
                  UGroupGen.PRegDesc    :=UGroupNode.RegDesc;
               UGroupGen.Version     :=Version;
   
               if SubGroup <> '' then SubGroup:='\'+SubGroup;

               UGroupGen.Count:=IntToStr(UGroupNode.Count);
               for I:=0 to UGroupNode.Count-1 do        
                  UGroupGen.Items.Add(UGroupNode.Item[I]);

               BldDir:=OutPASDir.Text+'\'+CompType+SubGroup;
            
               ForceDirectories(BldDir);

               OptionsNode:=Nodes.BuildOptions;
               if OptionsNode <> nil then
               begin
                  UGroupGen.LoadFromString(UP);
                  UGroupGen.SaveToFile  (BldDir+'\'+UGroupGen.PName+'.dpr');
                  UGroupGen.LoadFromString(UA);
                  UGroupGen.SaveToFile  (BldDir+'\'+UGroupGen.UFile);
               end;
               UGroupGen.Free;
            end;
         end;
      end
      else if UpperCase(CompType) = 'WORKSTATION' then
      begin
         WGroupsNode:=Nodes.WorkStations;
         if WGroupsNode <> nil then
         begin
            WGroupNode:=WGroupsNode.GetItemByName(Component);
            if WGroupNode <> nil then
            begin
               WGroupGen:=TWGroupGen.Create('');
               SubGroup:=WGroupNode.SubGroup;
               Version :=IntToStr(StrToIntDef(WGroupNode.Version,1)+1);
               WGroupGen.PClass      :='T'+WGroupNode.NodeName+'WGroup';
               WGroupGen.PName       :='W_'+WGroupNode.NodeName+'_'+Version;
               WGroupGen.UName       :='W_'+WGroupNode.NodeName+'AU_'+Version;
               WGroupGen.UFile       :=WGroupGen.UName+'.pas';
               WGroupGen.PGUID       :='';
               WGroupGen.PProgID     :='WGroup.'+WGroupNode.NodeName;
               if WGroupNode.RegDesc = '' then WGroupNode.RegDesc:='CORVUS '+WGroupNode.NodeName+' User Group';
               if Copy(WGroupNode.RegDesc,1,7) <> 'CORVUS ' then
                  WGroupGen.PRegDesc    :='CORVUS '+WGroupNode.RegDesc
               else
                  WGroupGen.PRegDesc    :=WGroupNode.RegDesc;
               WGroupGen.Version     :=Version;

               if SubGroup <> '' then SubGroup:='\'+SubGroup;

               WGroupGen.Count:=IntToStr(WGroupNode.Count);

               for I:=0 to WGroupNode.Count-1 do
                  WGroupGen.Items.Add(WGroupNode.Item[I]);

               BldDir:=OutPASDir.Text+'\'+CompType+SubGroup;

               ForceDirectories(BldDir);

               OptionsNode:=Nodes.BuildOptions;
               if OptionsNode <> nil then
               begin
                  WGroupGen.LoadFromString(WP);
                  WGroupGen.SaveToFile  (BldDir+'\'+WGroupGen.PName+'.dpr');
                  WGroupGen.LoadFromString(WA);
                  WGroupGen.SaveToFile  (BldDir+'\'+WGroupGen.UFile);
               end;
               WGroupGen.Free;
            end;
         end;
      end
      else if UpperCase(CompType) = 'PICKLIST' then
      begin
         PickListsNode:=Nodes.PickLists;
         if PickListsNode <> nil then
         begin
            PickListNode:=PickListsNode.GetItemByName(Component);
            if PickListNode <> nil then
            begin
               PickListGen:=TPickListGen.Create('');
               SubGroup:=PickListNode.SubGroup;
               Version :=IntToStr(StrToIntDef(PickListNode.Version,1)+1);
               PickListGen.PClass      :='T'+PickListNode.NodeName+'PickList';
               PickListGen.PName       :='K_'+PickListNode.NodeName+'_'+Version;
               PickListGen.UName       :='K_'+PickListNode.NodeName+'AU_'+Version;
               PickListGen.UFile       :=PickListGen.UName+'.pas';
               PickListGen.PGUID       :='';
               PickListGen.PProgID     :='PickList.'+PickListNode.NodeName;
               if PickListNode.RegDesc = '' then PickListNode.RegDesc:='CORVUS '+PickListNode.NodeName+' Pick List';
               if Copy(PickListNode.RegDesc,1,7) <> 'CORVUS ' then
                  PickListGen.PRegDesc    :='CORVUS '+PickListNode.RegDesc
               else
                  PickListGen.PRegDesc    :=PickListNode.RegDesc;
               PickListGen.Version     :=Version;


               PickListGen.ColumnNames.Clear;
               PickListGen.ColumnNames.Add(PickListNode.NodeName);
               PickListGen.ColumnNames.Add('Zone');

               PickListGen.ColumnData.Clear;
               for I:=0 to PickListNode.Items.Count-1 do
                  PickListGen.ColumnData.Add(PickListNode.Items[I]);
               for I:=0 to PickListNode.Zones.Count-1 do
                  PickListGen.ColumnData.Add(PickListNode.Zones[I]);

               if SubGroup <> '' then SubGroup:='\'+SubGroup;
               BldDir:=OutPASDir.Text+'\'+CompType+SubGroup;

               ForceDirectories(BldDir);

               OptionsNode:=Nodes.BuildOptions;
               if OptionsNode <> nil then
               begin
                  PickListGen.LoadFromString(KP);
                  PickListGen.SaveToFile  (BldDir+'\'+PickListGen.PName+'.dpr');
                  PickListGen.LoadFromString(KA);
                  PickListGen.SaveToFile  (BldDir+'\'+PickListGen.UFile);
               end;
               PickListGen.Free;
            end;
         end;
      end
      else if UpperCase(CompType) = 'LOOKUP' then
      begin
         LookUpsNode:=Nodes.LookUps;
         if LookUpsNode <> nil then
         begin
            LookUpNode:=LookUpsNode.GetItemByName(Component);
            if LookUpNode <> nil then
            begin
               LookUpGen:=TLookUpGen.Create('');
               SubGroup:=LookUpNode.SubGroup;
               Version :=IntToStr(StrToIntDef(LookUpNode.Version,1)+1);
               LookUpGen.CurrDecimals:= StrToIntDef(OptionsNode.CurrDecimals,2) ;               
               LookUpGen.PClass      :='T'+LookUpNode.NodeName+'LookUp';
               LookUpGen.PName       :='L_'+LookUpNode.NodeName+'_'+Version;
               LookUpGen.UName       :='L_'+LookUpNode.NodeName+'AU_'+Version;
               LookUpGen.UFile       :=LookUpGen.UName+'.pas';
               LookUpGen.PGUID       :='';
               LookUpGen.PProgID     :='LookUp.'+LookUpNode.NodeName;
               if LookUpNode.RegDesc = '' then LookUpNode.RegDesc:='CORVUS '+LookUpNode.NodeName+' Look Up';
               if Copy(LookUpNode.RegDesc,1,7) <> 'CORVUS ' then
                  LookUpGen.PRegDesc    :='CORVUS '+LookUpNode.RegDesc
               else
                  LookUpGen.PRegDesc    :=LookUpNode.RegDesc;
               LookUpGen.Version     :=Version;
   
               LookUpGen.ColumnNames.Clear;
               for I:=0 to LookUpNode.ZoneNames.Count-1 do
                  LookUpGen.ColumnNames.Add(LookUpNode.ZoneNames[I]);
                  
               LookUpGen.ColumnRanges.Clear;
               for I:=0 to LookUpNode.Ranges.Count-1 do
                  LookUpGen.ColumnRanges.Add(LookUpNode.Ranges[I]);
                  
               LookUpGen.ColumnData.Clear;
               for I:=0 to LookUpNode.Zones.Count-1 do
                  LookUpGen.ColumnData.Add(LookUpNode.Zones[I]);

               if SubGroup <> '' then SubGroup:='\'+SubGroup;
               BldDir:=OutPASDir.Text+'\'+CompType+SubGroup;
            
               ForceDirectories(BldDir);
            
               OptionsNode:=Nodes.BuildOptions;
               if OptionsNode <> nil then
               begin
                  LookUpGen.LoadFromString(LP);
                  LookUpGen.SaveToFile  (BldDir+'\'+LookUpGen.PName+'.dpr');
                  LookUpGen.LoadFromString(LA);
                  LookUpGen.SaveToFile  (BldDir+'\'+LookUpGen.UFile);
               end;
               LookUpGen.Free;
            end;
         end;
      end;
   end;
end;
procedure TBuilder.Panel2Click(Sender: TObject);
begin
   CancelBuild:=True;
end;

end.
