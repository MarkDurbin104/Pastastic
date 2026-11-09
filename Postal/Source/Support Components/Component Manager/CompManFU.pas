{  <Synopsis>      Corvus Component Manager
   <Unit>          Form
   <Copyright(c)>  Postal Solutions Limited 1996..1998
   <Author>        MJD
   <Description>   Load and manage Corvus Components via the
                   component loader
   <Modifications> 06/01/98 - MJD
                              Original Release
                   13/02/99 - MJD
                              Change Commenting format
}
unit CompManFU;

interface

uses
  GPCSErrorLine, RegistryEx,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, LargeDialogs,  // can use std Dialogs unit in D5 - bug fixed
  CommDlg,ExtCtrls, SubTree, StdCtrls, Menus,SavePosFormU,Registry,GPCSGUID,ComObj,GPCSBase_TLB,
  DBTables, ComCtrls, Db;

type
  TRegUnRegFunc = procedure;
  TMainForm = class(TSavePosForm)            
    Panel1: TPanel;
    ShowCL: TButton;
    Splitter1: TSplitter;
    OpenMenu: TPopupMenu;
    Open1: TMenuItem;
    Label1: TLabel;
    Label2: TLabel;
    Backup1: TMenuItem;
    RemoveFromList1: TMenuItem;
    RegisterFile1: TMenuItem;
    UnRegisterFile1: TMenuItem;
    N1: TMenuItem;
    MainMenu1: TMainMenu;
    Operations1: TMenuItem;
    AddToList1: TMenuItem;
    Backup2: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    RegisterFile2: TMenuItem;
    UnRegisterFile2: TMenuItem;
    CreateRGLfilefromcurrentSettings1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    ApplyRGLtoRegistry1: TMenuItem;
    EditRGLFile1: TMenuItem;
    N6: TMenuItem;
    Exit1: TMenuItem;
    N7: TMenuItem;
    RemoveRegistryEntries1: TMenuItem;
    PSLDataBase: TDatabase;
    PageControl: TPageControl;
    TreeTabSheet: TTabSheet;
    ScrollBox1: TScrollBox;
    ComponentList: TTreeBox;
    RGLFiles: TListBox;
    LogTabSheet: TTabSheet;
    LogMemo: TMemo;
    procedure ShowCLClick(Sender: TObject);
    procedure ComponentListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure RGLFilesDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure RGLFilesDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Open1Click(Sender: TObject);
    procedure ComponentListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ScrollBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Backup1Click(Sender: TObject);
    procedure RemoveFromList1Click(Sender: TObject);
    procedure RGLFilesDblClick(Sender: TObject);
    procedure RegisterFile1Click(Sender: TObject);
    procedure UnRegisterFile1Click(Sender: TObject);
    procedure CreateRGLfilefromcurrentSettings1Click(Sender: TObject);
    procedure ApplyRGLtoRegistry1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
     procedure SaveRegSettings;
     procedure LoadRegSettings;
     procedure RefreshComponentList;
  public
    { Public declarations }
		procedure AppException(Sender: TObject; E: Exception);
    procedure ParseCommandLine;
  end;


procedure LogEvent(Event : String);

var
  MainForm: TMainForm;
  ReferenceCount : Integer;  

function ValidCommandLine:Boolean;

implementation

{$R *.DFM}

uses ComServ2,CompManAU, BackDirFU, RGLFormFU;

procedure LogEvent(Event : String);
begin
  MainForm.LogMemo.Lines.Add(DAteTimeToStr(Now) + ' - ' + Event);
  While MainForm.LogMemo.Lines.Count > 100 do
    MainForm.LogMemo.Lines.Delete(0);
end;

procedure TMainForm.AppException(Sender: TObject; E: Exception);
begin
  RaiseGUIDException('{3126D3A4-71EE-497A-B39B-224EC303875A}',E);
end;

{===============================================================================
  Class        TMainForm
  Method       ShowCLClick
  Description  Show or hide the component loader form(s)
  Params       The Sender
  Result       None
________________________________________________________________________________}
procedure TMainForm.ShowCLClick(Sender: TObject);
begin
// using the tag to hold state info i.e 1 = showing 0 = not showing
   if ShowCL.Tag = 0 then                // not showing ?
   begin
      ComponentList.ShowCompLoad(True);  // then show 
      ShowCL.Tag:=1;                     // update state info
      ShowCL.Caption:='Hide CL';         // change caption
   end                           
   else                                  // otherwise
   begin
      ComponentList.ShowCompLoad(False); // hide
      ShowCL.Tag:=0;                     // update state info
      ShowCL.Caption:='Show CL';         // change caption
   end;                         
end;

{===============================================================================
  Class        TMainForm
  Method       ComponentListMouseDown
  Description  load a component into memory when clicked
  Params       The Sender
  Result       None
________________________________________________________________________________}
procedure TMainForm.ComponentListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   ComponentList.BeginDrag(False);
  if ComponentList.Component <> nil then // if we are on a component
     ComponentList.Component.Instance;   // load it into memory
  ShowCL.Enabled:=True;
end;
procedure TMainForm.FormCreate(Sender: TObject);
begin
  PSLDataBase.Params.Add('USER NAME=' + GetGPCSRegString('','UserName','psl'));
  PSLDataBase.Params.Add('PASSWORD='  + GetGPCSRegString('','Password','suvroc'));
  Application.OnException := MainForm.AppException;
  LoadRegSettings;
end;

function ValidCommandLine:Boolean;
begin
   Result:=(ParamCount = 1) and (ParamStr(1) <> '') and (FileExists(ParamStr(1)) or (Pos('CLEANREG',UpperCase(ParamStr(1)))<>0))
end;

procedure TMainForm.ParseCommandLine;
var
  Param : String;
  ParamIndex : Integer;
  RGLFileName : String;
begin
  If RegistryEx.ReadRegistryStringValue('HKEY_LOCAL_MACHINE\SOFTWARE\PSL\GPCS\Component Manager\StartUp\Show') = '1' then
    Show;

  RGLFileName := '';  //assume no RGL file passed
  If (ParamCount > 0) then
  begin
    For ParamIndex := 1 to ParamCount do
    begin
      if (ParamStr(ParamIndex)[1] in ['-', '/']) then //not an RGLFile
      begin
        Param := Trim(UpperCase(Copy(ParamStr(ParamIndex),2,999)));
        if Param = 'Test' then
          ShowMessage('Component Manager Test');
        if Param = 'CLEANREG' then
        begin
          RegistryEx.DeleteKeyTree('HKEY_LOCAL_MACHINE\SOFTWARE\PSL\GPCS');
          //  ShowMessage('Reg Clean Test');
          Application.Terminate;
        end;
      end
      else
        RGLFileName := ParamStr(1)
    end;
  end;

   If (RGLFileName <> '') and (FileExists(RGLFileName)) then
   begin
     //add to list if necessary
     if RGLFiles.Items.IndexOf(RGLFileName) = -1 then
     begin
        RGLFiles.Items.Add(RGLFileName);
        SaveRegSettings;
     end;
     // wait for ComponentList to complete reading registry
     while (not ComponentList.Ready) and (not Application.Terminated) do
        Application.ProcessMessages;
        
     //unreg and reg RGL file
     RGLFiles.ItemIndex := RGLFiles.Items.IndexOf(RGLFileName);
     ScrollBox1DragDrop(ComponentList,RGLFiles,0,0);  //use dragdrop event handler

     //close immediately if run with valid RGL param
     Application.Terminate;
   end;
end;

procedure TMainForm.RGLFilesDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
   if Source = ComponentList then Accept:=True;
end;

procedure TMainForm.SaveRegSettings;
var
   I:Integer;
begin
   with TRegistry.Create do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('Software\PSL\GPCS\Component Manager',True) then
      begin
         for I:=0 to RGLFiles.Items.Count-1 do
         begin
            WriteString(RGLFiles.Items[I],'');
         end;
         CloseKey;
      end;    
      Free;
   end;
end;
procedure TMainForm.LoadRegSettings;
var
   I:Integer;
   SL:TStringList;
   SL1:TStringList;
begin
   with TRegistry.Create do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('Software\PSL\GPCS\Component Manager',True) then
      begin
         SL:=TStringList.Create;
         GetValueNames(SL);
         SL1:=TStringList.Create;
         for I:=0 to SL.Count-1 do
         begin
            if FileExists(SL[I]) then
            try
               SL1.LoadFromFile(SL[I]);
               RGLFiles.Items.Add(SL[I]);
            except
               ;
            end;
         end;
         SL1.Free;
         SL.Free;
         CloseKey;
      end;    
      Free;
   end;
end;
procedure TMainForm.RGLFilesDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
   J,I:Integer;
   SL:TStringList;
   OPString:String;
   OpenDialog:TOpenDialog;
begin
   OpenDialog:=TOpenDialog.Create(nil);
   OpenDialog.Options:=[ofHideReadOnly,ofAllowMultiSelect];
   OpenDialog.Filter:='RGL Files|*.rgl';
   OpenDialog.DefaultExt:='*.rgl';
   if (Source = ComponentList) and OpenDialog.Execute then 
   begin
      SL:=TStringList.Create;
      for I:=0 to ComponentList.RegList.Count-1 do
      begin
         if ComponentList.RegList.Objects[I] <> nil then
         begin
            for J:=0 to ComponentList.RegList.Objects[I].Count-1 do
            begin
               if ComponentList.RegList.Objects[I].Objects[J] <> nil then
               begin
                  if ComponentList.RegList.Objects[I].Objects[J].Count > 2 then
                  begin
                     OPString:=ComponentList.RegList.Objects[I].Objects[J].Items[2];
                     if SL.IndexOf(OPString) = -1 then
                        SL.Add(OPString);
                  end;
               end;
            end;
         end;
      end;
      SL.SaveToFile(OpenDialog.FileName);
      SL.Free;
      RGLFiles.Items.Add(OpenDialog.FileName);
      SaveRegSettings;
   end;
   OpenDialog.Free;
end;

procedure TMainForm.Open1Click(Sender: TObject);
var
   OpenDialog:TOpenDialog;
begin
   OpenDialog:=TOpenDialog.Create(nil);
   OpenDialog.Options:=[ofHideReadOnly,ofAllowMultiSelect];
   if (OpenDialog.Execute) and (RGLFiles.Items.IndexOf(OpenDialog.FileName) = -1) then
   begin
      RGLFiles.Items.Add(OpenDialog.FileName);
      SaveRegSettings;
   end;
   OpenDialog.Free;
end;                         

procedure TMainForm.ComponentListDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
   if Source = RGLFiles then Accept:=True;
end;
procedure RegisterFile(FileName:String);
var
   HModule:THandle;
   UnRegFunc:TRegUnRegFunc;
begin
	try
     FileName := Trim( FileName ) ;
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
        HModule:=0;
        try
	        HModule:=LoadLibrary(PChar(FileName));
        except
        	On E : Exception do
          	ShowMessage(E.Message);
        end;
        if HModule <> 0 then
        begin
           try
              if GetProcAddress(HModule,'DllRegisterServer') <> nil then
              begin
                 UnRegFunc:=GetProcAddress(HModule,'DllRegisterServer');
                 UnRegFunc;
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
  except
  	On E : Exception do
    	ShowMessage(E.Message);
  end;
end;
procedure UnRegisterFile(FileName:String);
var
   HModule:THandle;
   UnRegFunc:TRegUnRegFunc;
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
      HModule:=LoadLibrary(PChar(FileName));
      if HModule <> 0 then
      begin
         try
            if GetProcAddress(HModule,'DllUnregisterServer') <> nil then
            begin
               UnRegFunc:=GetProcAddress(HModule,'DllUnregisterServer');
               UnRegFunc;
            end;
         except
            ShowMessage(FileName+' DllUnregisterServer - Failed');
         end;
         FreeLibrary(HModule);
      end;
   end;
	except
  	On E : Exception do
    	ShowMessage(E.Message);
  end;
end;
procedure TMainForm.RefreshComponentList;
begin
   ComponentList.RegList.Free;
   ComponentList.RegList:=TGPCSRegistryList.Create(ComponentList);
   Sleep(1000);
   ComponentList.RePaint;
end;
procedure TMainForm.ScrollBox1DragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
   J,I:Integer;
   OPString:String;
   RegList:TStringList;
begin
   if (Source = RGLFiles) and (RGLFiles.ItemIndex >= 0) then
   begin
      CompLoad:=nil;
      Label1.Caption:='Collecting Info...                                 '; Panel1.RePaint;
      RegList:=TStringList.Create;
      for I:=0 to ComponentList.RegList.Count-1 do
      begin
         if ComponentList.RegList.Objects[I] <> nil then
         begin
            for J:=0 to ComponentList.RegList.Objects[I].Count-1 do
            begin
               if ComponentList.RegList.Objects[I].Objects[J] <> nil then
               begin
                  if ComponentList.RegList.Objects[I].Objects[J].Count > 2 then
                  begin
                     OPString:=ComponentList.RegList.Objects[I].Objects[J].Items[2];
                     if RegList.IndexOf(OPString) = -1 then
                        RegList.Add(OPString);
                  end;        
               end;
            end;
         end;
      end;
      Label1.Caption:='Un-Registering...                                 '; Panel1.RePaint;
      for I:=0 to RegList.Count-1 do 
      begin
         Label2.Caption:=RegList[I]+'                                 '; Panel1.RePaint;
         UnRegisterFile(RegList[I]);
      end;
      RegList.Clear;
      Button1Click(nil);  // clean up
      Label1.Caption:='Collecting Info...                                 '; Panel1.RePaint;
      try
         RegList.LoadFromFile(RGLFiles.Items[RGLFiles.ItemIndex]);
      except
         ;
      end;
      Label1.Caption:='Registering...                                 '; Panel1.RePaint;
      for I:=0 to RegList.Count-1 do 
      begin
         Label2.Caption:=RegList[I]+'                                 '; Panel1.RePaint;
         RegisterFile(RegList[I]);
      end;
      Label1.Caption:='Refreshing                                                                  ';
      Label2.Caption:='                                                                  '; Panel1.RePaint;
      RegList.Free;
      RefreshComponentList;
      Label1.Caption:='                                      '; Panel1.RePaint;
   end;                          
end;

procedure CopyFileWithMD(Source,Dest:String);
var
   DirToMake:String;
   I:Integer;
begin
   for I:=1 to Length(Dest) do
   begin
      if Dest[I] = '\' then
      begin
         DirToMake:=Copy(Dest,1,I-1);
         CreateDirectory(PChar(DirToMake),nil);
      end;
   end;
   CopyFile(PChar(Source),PChar(Dest),False);
end;
procedure TMainForm.Backup1Click(Sender: TObject);
var
   SL:TStringList;
   BSL:TStringList;
   I:Integer;
   J:Integer;
   BackDir:String;
begin
   if (RGLFiles.ItemIndex <> -1) and (BackupForm.ShowModal = mrOK) then
   begin
      SL:=TStringList.Create;
      BSL:=TStringList.Create;
      BackDir:=BackupForm.BDir.Text;
      if BackDir[Length(BackDir)] = '\' then BackDir:=Copy(BackDir,1,Length(BackDir)-1);
      try
         SL.LoadFromFile(RGLFiles.Items[RGLFiles.ItemIndex]);
         for I:=0 to SL.Count-1 do
         begin
            if SL[I] <> '' then
            begin
               for J:=Length(SL[I]) downto 1 do
               begin
                  if SL[I][J] = '\' then
                  begin
                     BSL.Add(BackDir+Copy(SL[I],J,Length(SL[I])));
                     break;
                  end;
               end;
            end;
         end;    
      except
         ;
      end;
      for I:=0 to SL.Count-1 do
         if SL[I] <> '' then
            CopyFileWithMD(SL[I],BSL[I]);
      for J:=Length(RGLFiles.Items[RGLFiles.ItemIndex]) downto 1 do
      begin
         if RGLFiles.Items[RGLFiles.ItemIndex][J] = '\' then
         begin
            BackDir:=BackDir+Copy(RGLFiles.Items[RGLFiles.ItemIndex],J,Length(RGLFiles.Items[RGLFiles.ItemIndex]));
            BSL.SaveToFile(BackDir);
            break;
         end;
      end;
      BSL.Free;
      SL.Free;
      if RGLFiles.Items.IndexOf(BackDir) = -1 then 
      begin
         RGLFiles.Items.Add(BackDir);
         SaveRegSettings;
      end;
   end;              
end;

procedure TMainForm.RemoveFromList1Click(Sender: TObject);
begin
   if RGLFiles.ItemIndex <> -1 then
   begin
      RGLFiles.Items.Delete(RGLFiles.ItemIndex);
      SaveRegSettings;
   end;
end;

procedure TMainForm.RGLFilesDblClick(Sender: TObject);
begin
   if RGLFiles.ItemIndex <> -1 then
   begin
      RGLForm.Memo1.Lines.LoadFromFile(RGLFiles.Items[RGLFiles.ItemIndex]);
      if RGLForm.ShowModal = mrOK then
         RGLForm.Memo1.Lines.SaveToFile(RGLFiles.Items[RGLFiles.ItemIndex]);
   end;
end;

procedure TMainForm.RegisterFile1Click(Sender: TObject);
var
   I:Integer;
   OpenDialog:TOpenDialog;
begin
   OpenDialog:=TOpenDialog.Create(nil);
   OpenDialog.Options:=[ofHideReadOnly,ofAllowMultiSelect];
   OpenDialog.Filter:='All Files|*.*';
   OpenDialog.DefaultExt:='*.*';
   if OpenDialog.Execute then
   begin
      Label1.Caption:='Registering...                                 '; Panel1.RePaint;
      for I:=0 to OpenDialog.Files.Count-1 do
      begin
         Label2.Caption:=OpenDialog.Files[I]+'                                 '; Panel1.RePaint;
         RegisterFile(OpenDialog.Files[I]);
      end;
      Label2.Caption:='';
      Label1.Caption:='Refreshing'; Panel1.RePaint;
      RefreshComponentList;
   end; 
   Label1.Caption:='';
   OpenDialog.Free;
end;                   

procedure TMainForm.UnRegisterFile1Click(Sender: TObject);
var
   I:Integer;
   OpenDialog:TOpenDialog;
begin
   OpenDialog:=TOpenDialog.Create(nil);
   OpenDialog.Options:=[ofHideReadOnly,ofAllowMultiSelect];
   OpenDialog.Filter:='All Files|*.*';
   OpenDialog.DefaultExt:='*.*';
   if OpenDialog.Execute then
   begin
      Label1.Caption:='Un-Registering...                                 '; Panel1.RePaint;
      for I:=0 to OpenDialog.Files.Count-1 do
      begin
         Label2.Caption:=OpenDialog.Files[I]+'                                 '; Panel1.RePaint;
         UnRegisterFile(OpenDialog.Files[I]);
      end;
      Label2.Caption:='';
      Label1.Caption:='Refreshing'; Panel1.RePaint;
      RefreshComponentList;
   end; 
   Label1.Caption:='';
   OpenDialog.Free;
end;                     

procedure TMainForm.CreateRGLfilefromcurrentSettings1Click(
  Sender: TObject);
begin
  RGLFilesDragDrop(RGLFiles,ComponentList,0,0);
end;

procedure TMainForm.ApplyRGLtoRegistry1Click(Sender: TObject);
begin
   ScrollBox1DragDrop(ComponentList,RGLFiles,0,0);
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
   Close;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
   I:Integer;
   RegList:TStringList;
   ProgIdList:TStringList;
   SL:TStringList;
   J:Integer;
   OPString:String;
begin
   Label1.Caption:='Cleaning Up...                                     ';
   Label2.Caption:=''; Panel1.RePaint;
   RegList:=TStringList.Create;
   ProgIdList:=TStringList.Create;
   SL:=TStringList.Create;
   for I:=0 to ComponentList.RegList.Count-1 do
   begin
      if ComponentList.RegList.Objects[I] <> nil then
      begin
         for J:=0 to ComponentList.RegList.Objects[I].Count-1 do
         begin
            if ComponentList.RegList.Objects[I].Objects[J] <> nil then
            begin
               if ComponentList.RegList.Objects[I].Objects[J].Count > 2 then
               begin
                  OPString:=ComponentList.RegList.Objects[I].Objects[J].Items[0];
                  if RegList.IndexOf(OPString) = -1 then
                     RegList.Add(OPString);
               end;
            end;
         end;
      end;
   end;
   for I:=0 to RegList.Count-1 do
   begin
      EraseKey(HKEY_CLASSES_ROOT,'CLSID\'+RegList[I]);
      if ((I mod 20) = 0) then
      begin
         if Length(Label2.Caption) >= 100 then
            Label2.Caption:=''
         else
            Label2.Caption:=Label2.Caption+'.';
         Panel1.RePaint;
      end;
   end;
   Application.ProcessMessages;
   with TRegistry.Create do
   begin
      RootKey:=HKEY_CLASSES_ROOT;
      if OpenKey('CLSID',False) then
      begin
         if HasSubKeys then
         begin
            GetKeyNames(SL);
            CloseKey;
            for I:=0 to SL.Count-1 do
            begin
               if OpenKey('CLSID'+'\'+SL[I],False) then
               begin
                  if (Copy(ReadString(''),1,5) = 'GPCS ') or (Copy(ReadString(''),1,7) = 'CORVUS ') then
                  begin
                     CloseKey;
                     EraseKey(HKEY_CLASSES_ROOT,'CLSID'+'\'+SL[I]);
                  end
                  else
                  begin
                     CloseKey;
                     if OpenKey('CLSID'+'\'+SL[I]+'\ProgID',False) then
                     begin
                        if (Copy(ReadString(''),1,4) = 'GPCS') or (Copy(ReadString(''),1,6) = 'CORVUS') or (ProgIDList.IndexOf(ReadString('')) >= 0) then
                        begin
                           CloseKey;
                           EraseKey(HKEY_CLASSES_ROOT,'CLSID'+'\'+SL[I]);
                        end
                        else
                          CloseKey;
                     end;
                  end;
               end;
               if ((I mod 20) = 0) then
               begin
                  if Length(Label2.Caption) >= 100 then
                     Label2.Caption:=''
                  else
                     Label2.Caption:=Label2.Caption+'.';
                  Panel1.RePaint;
               end;
            end;
         end;
      end;
      Free;
   end;
   Label1.Caption:='Refreshing';
   Label2.Caption:=''; Panel1.RePaint;
   SL.Free;
   RegList.Free;
   ProgIdList.Free;
   RefreshComponentList;
   Label1.Caption:=''; Panel1.RePaint;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
   CompLoad:=nil;
end;

end.
