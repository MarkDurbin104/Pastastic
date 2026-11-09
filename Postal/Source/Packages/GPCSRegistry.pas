unit GPCSRegistry;

interface
uses
   SysUtils,ComObj,Forms,Windows,Graphics,Classes,GPCSBase_TLB,Registry,CompressU,Bin2String,ActiveX,Compress,PackStrListU;
   
type
  // LoadComponent Status
  TLoadState = ( lsNotLoaded, // LoadComponent hasn't been called
                 lsLoadedOK,  // LoadComponent ran successfully
                 lsError      // LoadComponent failed
                );
  // One Corvus Entry from the Registry
  TGPCSRegistryEntry = class(TObject)
  protected
    FBitMap        :OleVariant; // The Component's bitmap
    FCaption       :String; // The Component's Caption
    FGUID          :String; // The Component's Globally Unique Identifier
    FDescription   :String; // The Component's Description
    FComponentType :String; // The Component's Type
    FServerBinary1 :String; // The Component's Binary File Name InProcess
    FServerBinary2 :String; // The Component's Binary File Name Local
    FServerBinary3 :String; // The Component's Binary File Name Remote
    FProgID        :String; // The Component's Program Identifier
    FName          :String; // The Component's Name
    FVersion       :String; // The Component's Version Number
    FGroup         :String; // The Component's Design Group
    FLoadState:TLoadState;  // The Status of the last LoadComponent() operation
    function GetImage:TBitMap;
  public
    constructor Create(Key:TRegistry;CLSID,Desc:String);
    procedure LoadFromStream(Stream:TStream);
    procedure SaveToStream(Stream:TStream);
    property GUID          :String     read FGUID         ;
    property Caption       :String     read FCaption      ;
    property BitMap        :OleVariant  read FBitMap       ;
    property Image         :TBitMap    read GetImage      ;
    property Description   :String     read FDescription  ;
    property ComponentType :String     read FComponentType;
    property ServerBinary1 :String     read FServerBinary1;
    property ServerBinary2 :String     read FServerBinary2;
    property ServerBinary3 :String     read FServerBinary3;
    property ProgID        :String     read FProgID       ;
    property Name          :String     read FName         ;
    property Version       :String     read FVersion      ;
    property Group         :String     read FGroup write FGroup;
    property LoadState     :TLoadState read FLoadState write FLoadState;
  end;     
  // The list of all Corvus Entries arranged as a Tree
  TGPCSRegistryList = class(TObject)
  private
     FCompLoad:ICompLoad;
     TheList:TPackStringList;
     function GetCount:Integer;
     function GetItem(Index:Integer):TGPCSRegistryEntry;
     function GetObject(Index:Integer):IComponent;
  protected
     function LoadComponent(GUID:String):IComponent;
  public           
     constructor Create; virtual;
     destructor Destroy; override;
     function CommaText:String;
     procedure LoadFromRegistry;
     procedure LoadFromStream(Stream:TStream;var ProjectData:String);
     procedure SaveToStream(Stream:TStream;ProjectData:String);
     procedure LoadFromFile(FileName:String;var ProjectData:String);
     procedure SaveToFile(FileName:String;ProjectData:String);
     procedure AddEntry(Key:TRegistry;CLSID,Desc:String); // add a new TGPCSRegistryEntry from the Registry
     property Count:Integer read GetCount;
     property Item[Index:Integer]:TGPCSRegistryEntry read GetItem; default;
     property Instance[Index:Integer]:IComponent read GetObject     ;
  end;
  TGPCSRegistry = class(TObject)
  private
     FRegistryList:TGPCSRegistryList;
     function GetCount:Integer;
     function GetItem(Index:Integer):TGPCSRegistryEntry;
     function GetObject(Index:Integer):IComponent;
     function EscString(Value:String):String;
  public
     function IndexOf(ProgID:String):Integer;
     procedure LoadFromStream(Stream:TStream;var ProjectData:String);
     procedure SaveToStream(Stream:TStream;ProjectData:String);
     procedure LoadFromRegistry;
     procedure LoadFromFile(FileName:String;var ProjectData:String);
     procedure SaveToFile(FileName:String;ProjectData:String);
     procedure FillRegistry;
     procedure EraseKey(KeyName:String);
     procedure EraseRegistry;
     function Add(Value:TGPCSRegistryEntry):Integer;
     procedure Delete(ProgID:String);
     function CommaText:String;
     function CreateGroupList(CompType:String):TPackStringList;
     function CreateCompList(CompType,Group:String):TPackStringList;
     property Count:Integer read GetCount;
     property Item[Index:Integer]:TGPCSRegistryEntry read GetItem; default;
     property Instance[Index:Integer]:IComponent read GetObject;
  end;

const
   ProjectType:String = 'GPCS CD V2.0 Packed';
   
implementation

function StrToBMP(Str:OleVariant):TBitMap;
var
   SStream:TStringStream;
   Compress:TCompress;
   Compressor:TCompressor;
begin
   if VarType(Str) = vtString then
   begin
      try
         Result:=TBitMap.Create;
         Compress:=TCompress.Create;
         SStream:=TStringStream.Create(Compress.CompressString(StringToBinary(Str)));
         Compress.Free;
         Result.LoadFromStream(SStream);
         SStream.Free;
      except
         Result:=TBitMap.Create;
      end;
   end
   else
   begin
      Compressor:=TCompressor.Create;
      Result:=Compressor.CreateBitmapFromArray(Str);
      Compressor.Free;
   end;
end;
function BMPToStr(BitMap:TBitMap):String;
var
   SStream:TStringStream;
   Compressor:TCompress;
   S:String;
begin
   SStream:=TStringStream.Create('');
   Bitmap.SaveToStream(SStream);
   SStream.Position:=0;
   Compressor:=TCompress.Create;
   S:=SStream.DataString;
   SStream.Free;
   S:=Compressor.CompressString(S);
   Compressor.Free;
   Result:=BinaryToString(S);
end;
function ReadSString(Stream:TStream):String;
var
   Len:Integer;
begin
   if ProjectType = 'GPCS CD V2.0 Packed' then
   begin
      try
         Stream.ReadBuffer(Pointer(@Len)^,SizeOf(Len));
         SetLength(Result,Len);
         Stream.ReadBuffer(Pointer(@Result[1])^,Len);
      except
         Result:='';
         // raise read error
      end;
   end;
end;
function WriteSString(Stream:TStream;Value:String):String;
var
   Len:Integer;
begin
   if ProjectType = 'GPCS CD V2.0 Packed' then
   begin
      Len:=Length(Value);
      Stream.WriteBuffer(Pointer(@Len)^,SizeOf(Len));
      Stream.WriteBuffer(Pointer(@Value[1])^,Len);
   end;
end;
function TGPCSRegistryEntry.GetImage:TBitMap;
begin
   Result:=StrToBMP(FBitMap);
end;
procedure TGPCSRegistryEntry.LoadFromStream(Stream:TStream);
var
   ExeType:String;
   I:Integer;
   ExecComponent:IExecComponent;
begin
   FGUID          :=ReadSString(Stream);
   FDescription   :=ReadSString(Stream);
   FVersion       :=ReadSString(Stream);
   FProgID        :=ReadSString(Stream);
   FLoadState     :=lsNotLoaded;
   ExeType        :=ReadSString(Stream);
   if ExeType = 'I' then
      FServerBinary1:=ReadSString(Stream)
   else if ExeType = 'L' then
      FServerBinary2:=ReadSString(Stream)
   else if ExeType = 'R' then
      FServerBinary3:=ReadSString(Stream);
   FBitMap:=ReadSString(Stream);
   FCaption:=ReadSString(Stream);
   FGroup:=ReadSString(Stream);

   for I:=1 to Length(ProgID) do
   begin
      if ProgID[I] = '.' then
      begin
         FComponentType:=Copy(ProgID,1,I-1);
         FName:=Copy(ProgID,I+1,999);
         break;
      end;
   end;
   if (FComponentType = 'Product') or (FComponentType = 'Group') then
   begin
      if (FBitMap = '') or (FCaption = '') then
      begin
         try
            ExecComponent:=CreateComObject(StringToGUID(FGUID)) as IExecComponent;
            if ExecComponent <> nil then
            begin
               FBitMap :=ExecComponent.BitMap;
               FCaption:=ExecComponent.Caption;
               ExecComponent:=nil;
            end;
         except
            FBitMap :='';
            FCaption:='Error Loading '+FProgId;
            ExecComponent:=nil;
         end;
      end;
   end
   else if (FComponentType = 'LookUp') 
        or (FComponentType = 'PickList') 
        or (FComponentType = 'Service')
        or (FComponentType = 'WGroup')
        or (FComponentType = 'UGroup') then
   begin
      // ?
   end
   else
      FGroup:=FComponentType;
end;
procedure TGPCSRegistryEntry.SaveToStream(Stream:TStream);
var
   ExeType:String;
begin
   WriteSString(Stream,FGUID          );
   WriteSString(Stream,FDescription   );
   WriteSString(Stream,FVersion       );
   WriteSString(Stream,FProgID        );
   if FServerBinary1 <> '' then
   begin
      ExeType:='I';
      WriteSString(Stream,ExeType);
      WriteSString(Stream,FServerBinary1);
   end
   else if FServerBinary2 <> '' then
   begin
      ExeType:='L';
      WriteSString(Stream,ExeType);
      WriteSString(Stream,FServerBinary2);
   end
   else if FServerBinary3 <> '' then
   begin
      ExeType:='R';
      WriteSString(Stream,ExeType);
      WriteSString(Stream,FServerBinary3);
   end
   else
   begin
      WriteSString(Stream,'');
      WriteSString(Stream,'');
   end;
   WriteSString(Stream,FBitMap);
   WriteSString(Stream,FCaption);
   WriteSString(Stream,FGroup);
end;
constructor TGPCSRegistryEntry.Create(Key:TRegistry;CLSID,Desc:String);
var
   I:Integer;
   ExecComponent:IExecComponent;
   V1Component:Variant;
   ABitMap:TBitMap;
   Dispatch:IDispatch;
   Component:IComponent;
begin    
   if Key = nil then Exit;
   FGUID          :=CLSID;
   FDescription   :=Desc;
   FVersion       :='1';
   FLoadState     :=lsNotLoaded;
   FCaption:='';
   FGroup:='';
   with Key do
   begin
      if OpenKey('CLSID\'+CLSID+'\GPCS',False) then
      begin
         FComponentType:=ReadString('');
         CloseKey;
      end;
      if OpenKey('CLSID\'+CLSID+'\GPCS\Version',False) then
      begin
         FVersion:=ReadString('');
         CloseKey;
      end;
      if OpenKey('CLSID\'+CLSID+'\GPCS\Group',False) then
      begin
         FGroup:=ReadString('');
         CloseKey;
      end;
      if OpenKey('CLSID\'+CLSID+'\GPCS\Caption',False) then
      begin
         FCaption:=ReadString('');
         CloseKey;
      end;
      if OpenKey('CLSID\'+CLSID+'\ProgID',False) then
      begin
         FProgID:=ReadString('');
         CloseKey;
      end;
      if OpenKey('CLSID\'+CLSID+'\RemoteServer32',False) then
      begin
         FServerBinary3:=ReadString('');
         CloseKey;
      end;
      if OpenKey('CLSID\'+CLSID+'\LocalServer32',False) then
      begin
         FServerBinary2:=ReadString('');
         CloseKey;
      end;
      if OpenKey('CLSID\'+CLSID+'\InProcServer32',False) then
      begin
         FServerBinary1:=ReadString('');
         CloseKey;
      end;
   end;
   for I:=1 to Length(ProgID) do
   begin
      if ProgID[I] = '.' then
      begin
         if ComponentType = '' then
           FComponentType:=Copy(ProgID,1,I-1);
         FName:=Copy(ProgID,I+1,999);
         break;
      end;
   end;
   if (FComponentType = 'Product') or (FComponentType = 'Group') then
   begin       
      if VarIsEmpty(FBitMap) or (FCaption = '') then
      begin
         try
            ExecComponent:=CreateComObject(StringToGUID(FGUID)) as IExecComponent;
            if ExecComponent <> nil then
            begin
               FBitMap :=ExecComponent.BitMap;
               FCaption:=ExecComponent.Caption;
               ExecComponent:=nil;
            end;
         except
            try
               FGroup:='Version 1 Components';
               CoCreateInstance(StringToGUID(FGUID),nil,CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER,IDispatch,Dispatch);
               V1Component:=Dispatch;
               if (FComponentType = 'Product') or (FComponentType = 'Group') then
               begin
                  ABitMap:=TBitMap.Create;
                  ABitMap.LoadFromResourceID(V1Component.Instance,1);
                  FBitMap:=BMPToStr(ABitMap);
                  ABitMap.Free;
               end;
               if (FComponentType = 'Product') then
                  FCaption:=V1Component.Description
               else
                  FCaption:=V1Component.Name;
               V1Component:=Unassigned;
               Dispatch:=nil;
            except
               FBitMap :='';
               FGroup:='Error Loading';
               FCaption:=FProgId;
               ExecComponent:=nil;
               Dispatch:=nil;
            end;
         end;
      end;
   end
   else if (FComponentType = 'LookUp') 
        or (FComponentType = 'PickList') 
        or (FComponentType = 'Service')
        or (FComponentType = 'WGroup')
        or (FComponentType = 'UGroup') then
   begin
      try
         Component:=CreateComObject(StringToGUID(FGUID)) as IComponent;
         Component:=nil;
      except
         try
            FGroup:='Version 1 Components';
            CoCreateInstance(StringToGUID(FGUID),nil,CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER,IDispatch,Dispatch);
            V1Component:=Dispatch;
            FCaption:=V1Component.Name;
            V1Component:=Unassigned;
            Dispatch:=nil;
         except       
            FGroup:='Error Loading';
            FCaption:=FProgID;
            Dispatch:=nil;
         end;
      end;
   end
   else
      FGroup:=FComponentType;
   if FGroup = '' then FGroup:='All';
end;
procedure TGPCSRegistryList.LoadFromRegistry;
var
   Registry:TRegistry;
   I:Integer;
   Value:String;
   CLSIDs:TPackStringList;
begin          
   Registry:=TRegistry.Create;
   with Registry do
   begin
      RootKey:=HKEY_CLASSES_ROOT;
      if (OpenKey('CLSID',False)) and (HasSubKeys) then
      begin
         CLSIDs:=TPackStringList.Create;
         GetKeyNames(CLSIDs);
         CloseKey;
         for I:=0 to CLSIDs.Count-1 do
         begin
            if OpenKey('CLSID\'+CLSIDs.Strings[I],False) then
            begin
               Value:=ReadString('');
               CloseKey;
               if (Value <> '') and ((Copy(Value,1,5) = 'GPCS ') or (Copy(Value,1,7) = 'Corvus ') or (Copy(Value,1,7) = 'CORVUS ')) then 
                   AddEntry(Registry,CLSIDs[I],Value)
            end;                                                
            Application.ProcessMessages;
            if Application.Terminated then Exit;
         end;                                                
         CLSIDs.Free;
      end;
   end;
   Registry.Free;
   TheList.Sort;
end;
constructor TGPCSRegistryList.Create;
begin          
   inherited Create;
   TheList:=TPackStringList.Create;
end;
destructor TGPCSRegistryList.Destroy;
var
   I:Integer;
begin
   for I:=0 to Count-1 do
      if Item[I] <> nil then Item[I].Free;
   TheList.Free;
   FCompLoad:=nil;
   inherited Destroy;
end; 
procedure TGPCSRegistryList.LoadFromStream(Stream:TStream;var ProjectData:String);
var
   ItemCount:Integer;
   I:Integer;
   RegEntry:TGPCSRegistryEntry;
begin
   if Stream <> nil then
   begin
      Stream.Position:=0;
      ProjectType:=ReadSString(Stream);
      Stream.ReadBuffer(Pointer(@ItemCount)^,SizeOf(ItemCount));
      for I:=0 to ItemCount-1 do
      begin
         RegEntry:=TGPCSRegistryEntry.Create(nil,'','');
         RegEntry.LoadFromStream(Stream);
         TheList.AddObject(RegEntry.ProgID,RegEntry);
      end;            
      try
         ProjectData:=ReadSString(Stream);
      except
         ; // no project data available
      end;
   end;                      
end;
procedure TGPCSRegistryList.SaveToStream(Stream:TStream;ProjectData:String);
var
   ItemCount:Integer;
   I:Integer;
   RegEntry:TGPCSRegistryEntry;
begin
   TheList.Sort;
   if Stream <> nil then
   begin
      Stream.Position:=0;
      WriteSString(Stream,ProjectType);
      ItemCount:=Count;
      Stream.WriteBuffer(Pointer(@ItemCount)^,SizeOf(ItemCount));
      for I:=0 to Count-1 do
      begin
         RegEntry:=Item[I];
         RegEntry.SaveToStream(Stream);
      end;            
      WriteSString(Stream,ProjectData);
   end;                      
end;
procedure TGPCSRegistryList.LoadFromFile(FileName:String;var ProjectData:String);
var
   FileStream:TFileStream;
begin
   FileStream:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
   LoadFromStream(FileStream,ProjectData);
   FileStream.Free;
end;
procedure TGPCSRegistryList.SaveToFile(FileName,ProjectData:String);
var
   FileStream:TFileStream;
begin
   FileStream:=TFileStream.Create(FileName,fmCreate or fmOpenWrite or fmShareDenyNone);
   SaveToStream(FileStream,ProjectData);
   FileStream.Free;
end;
function TGPCSRegistryList.GetCount:Integer;
begin
   if TheList <> nil then
      Result:=TheList.Count
   else
      Result:=0;
end;
function TGPCSRegistryList.LoadComponent(GUID:String):IComponent;
begin
   Result:=nil;
   Application.ProcessMessages;
   if Application.Terminated then Exit;
   try
      if FCompLoad = nil then
         FCompLoad:=CreateOleObject('Support.CompLoad') as ICompLoad;
      try
         Result:=FCompLoad.LoadComponent(GUID) as IComponent;
      except
      end;
   except
      Result:=CreateComObject(StringToGUID(GUID)) as IComponent;
   end;
end;
function TGPCSRegistryList.GetObject(Index:Integer):IComponent;
begin
   Result:=nil;
   
   if Index >= Count then Exit;

   Result:=LoadComponent(Item[Index].FGUID);
   if Result = nil then
      Item[Index].FLoadState:=lsError
   else
      Item[Index].FLoadState:=lsLoadedOK;
end;
function TGPCSRegistryList.GetItem(Index:Integer):TGPCSRegistryEntry;
begin
   if Index < Count then
      Result:=TGPCSRegistryEntry(TheList.Objects[Index])
   else
      Result:=nil;
end;
function TGPCSRegistryList.CommaText:String;
begin
   if TheList <> nil then
      Result:=TheList.CommaText
   else
      Result:='';
end;
procedure TGPCSRegistryList.AddEntry(Key:TRegistry;CLSID,Desc:String);
var
   RegEntry:TGPCSRegistryEntry;
   Index:Integer;
begin
   RegEntry:=TGPCSRegistryEntry.Create(Key,CLSID,Desc);
   Index:=TheList.IndexOf(RegEntry.FProgID);
   if Index <> -1 then
   begin
      if StrToIntDef(Item[Index].Version,0) > StrToIntDef(RegEntry.Version,0) then
      begin
         RegEntry.Free;
      end
      else
      begin
         Item[Index].Free;
         TheList.Objects[Index]:=RegEntry;
      end;
   end
   else
      TheList.AddObject(RegEntry.ProgID,RegEntry);
      
end;   
{TGPCSRegistry}
procedure TGPCSRegistry.EraseKey(KeyName:String);
var
   I:Integer;
   SL:TPackStringList;
begin
   Application.ProcessMessages;
   SL:=TPackStringList.Create;
   with TRegistry.Create do
   begin
      RootKey:=HKEY_CLASSES_ROOT;
      if OpenKey(KeyName,False) then
      begin
         if HasSubKeys then
         begin
            GetKeyNames(SL);
            CloseKey;
            for I:=0 to SL.Count-1 do
               EraseKey(KeyName+'\'+SL[I]);
         end
         else
         begin
            CloseKey;
         end;        
      end;
      DeleteKey(KeyName);
      Free;
   end;
   SL.Free;
end;
procedure TGPCSRegistry.EraseRegistry;
var
   I:Integer;
   SL:TPackStringList;
   Value:String;
begin
   SL:=TPackStringList.Create;
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
                  Value:=ReadString('');
                  if ((Copy(Value,1,5) = 'GPCS ') or (Copy(Value,1,7) = 'Corvus ') or (Copy(Value,1,7) = 'CORVUS ')) then 
                  begin
                     CloseKey;
                     EraseKey('CLSID'+'\'+SL[I]);
                  end
                  else
                  begin
                     CloseKey;
                  end;
               end;           
            end;
         end;
      end;
      Free;
   end;
   SL.Free;
end;
procedure TGPCSRegistry.LoadFromRegistry;
begin
   if FRegistryList <> nil then FRegistryList.Free;
   FRegistryList:=TGPCSRegistryList.Create;
   FRegistryList.LoadFromRegistry;
end;
procedure TGPCSRegistry.LoadFromStream(Stream:TStream;var ProjectData:String);
begin
   if FRegistryList <> nil then FRegistryList.Free;
   FRegistryList:=TGPCSRegistryList.Create;
   FRegistryList.LoadFromStream(Stream,ProjectData);
end; 
procedure TGPCSRegistry.SaveToStream(Stream:TStream;ProjectData:String);
begin
   if FRegistryList <> nil then
      FRegistryList.SaveToStream(Stream,ProjectData);
end; 
procedure TGPCSRegistry.LoadFromFile(FileName:String;var ProjectData:String);
begin
   if FRegistryList <> nil then FRegistryList.Free;
   FRegistryList:=TGPCSRegistryList.Create;
   FRegistryList.LoadFromFile(FileName,ProjectData);
end; 
procedure TGPCSRegistry.SaveToFile(FileName:String;ProjectData:String);
begin
   if FRegistryList <> nil then 
      FRegistryList.SaveToFile(FileName,ProjectData);
end;
function TGPCSRegistry.EscString(Value:String):String;
var
   I:Integer;
begin
   Result:='';
   for I:=1 to Length(Value) do
   begin
      if Value[I] = '\' then
         Result:=Result+'\\'
      else
         Result:=Result+Value[I];
   end;
end;
procedure TGPCSRegistry.FillRegistry;
var
  I:Integer;
  RegEntry:TGPCSRegistryEntry;
  SL:TPackStringList;
  KeyString:String;
  FileName:String;
  procedure AddLines(Key,Value:String);
  begin
     SL.Add(''); 
     SL.Add('['+Key+']'); 
     SL.Add('@="'+EscString(Value)+'"');
  end;
  
begin                                  
   SL:=TPackStringList.Create;
   SL.Add('REGEDIT4');
   for I:=0 to FRegistryList.Count-1 do
   begin
      RegEntry:=FRegistryList[I];
      KeyString:='HKEY_CLASSES_ROOT\CLSID\'+RegEntry.FGUID;
      
      AddLines(KeyString,RegEntry.Description);
      AddLines(KeyString+'\ProgID',RegEntry.ProgID);
      if RegEntry.FServerBinary3 <> '' then
         AddLines(KeyString+'\RemoteServer32',RegEntry.FServerBinary3)
      else if RegEntry.FServerBinary2 <> '' then
         AddLines(KeyString+'\LocalServer32',RegEntry.FServerBinary2)
      else if RegEntry.FServerBinary1 <> '' then
         AddLines(KeyString+'\InProcServer32',RegEntry.FServerBinary1);
      AddLines(KeyString+'\GPCS',RegEntry.ComponentType);
      AddLines(KeyString+'\GPCS\Version',RegEntry.Version);
      if RegEntry.Caption <> '' then
         AddLines(KeyString+'\GPCS\Caption',RegEntry.Caption);
      AddLines(KeyString+'\GPCS\Group',RegEntry.Group);
      Application.ProcessMessages;
   end;                        
   for I:=0 to FRegistryList.Count-1 do
   begin
      RegEntry:=FRegistryList[I];
      KeyString:='HKEY_LOCAL_MACHINE\SOFTWARE\Classes\'+RegEntry.ProgID;
      AddLines(KeyString,RegEntry.Description);
      AddLines(KeyString+'\Clsid',RegEntry.FGUID);
      Application.ProcessMessages;
   end;
   for I:=0 to 9999 do
   begin
      FileName:='TRg'+IntToStr(I)+'.reg';
      if not FileExists(FileName) then
      begin
         SL.SaveToFile(FileName);
         Application.ProcessMessages;
         WinExec(PChar('RegEdit /s '+FileName),SW_SHOW);
         Application.ProcessMessages;
         DeleteFile(PChar(FileName));
         Application.ProcessMessages;
         break;
      end;
   end;
end;
function TGPCSRegistry.GetCount:Integer;
begin
   if FRegistryList <> nil then
      Result:=FRegistryList.Count
   else
      Result:=0;
end;
function TGPCSRegistry.GetItem(Index:Integer):TGPCSRegistryEntry;
begin
   if FRegistryList <> nil then
      Result:=FRegistryList[Index]
   else
      Result:=nil;
end;
function TGPCSRegistry.GetObject(Index:Integer):IComponent;
begin
   if FRegistryList <> nil then
      Result:=FRegistryList.Instance[Index]
   else
      Result:=nil;
end;
function TGPCSRegistry.CommaText:String;
begin
   if FRegistryList <> nil then
      Result:=FRegistryList.CommaText
   else
      Result:='';
end;
function TGPCSRegistry.CreateGroupList(CompType:String):TPackStringList;
var
   I:Integer;
begin
   Result:=TPackStringList.Create;
   if CompType = 'Others' then
   begin
      for I:=0 to Count-1 do
      begin
         if (Item[I].ComponentType <> 'Product') 
         and (Item[I].ComponentType <> 'Group') 
         and (Item[I].ComponentType <> 'LookUp') 
         and (Item[I].ComponentType <> 'PickList') 
         and (Item[I].ComponentType <> 'Service') 
         and (Item[I].ComponentType <> 'WGroup') 
         and (Item[I].ComponentType <> 'UGroup')
         and (Item[I].ComponentType <> 'GPCSBase')
         and (Result.IndexOf(Item[I].Group) = -1) then
            Result.Add(Item[I].Group);
      end;
   end    
   else
   begin
      for I:=0 to Count-1 do
      begin
         if (Item[I].ComponentType = CompType) 
         and (Result.IndexOf(Item[I].Group) = -1) then
            Result.Add(Item[I].Group);
      end;
   end;
   Result.Sort;
end;
function TGPCSRegistry.CreateCompList(CompType,Group:String):TPackStringList;
var
   I:Integer;
begin
   Result:=TPackStringList.Create;
   if CompType = 'Others' then CompType:=Group;
   for I:=0 to Count-1 do
   begin
      if (Item[I].ComponentType = CompType) and (Item[I].Group = Group) then
         Result.AddObject(Item[I].ProgID,Item[I]);
   end;
   Result.Sort;
end;
function TGPCSRegistry.IndexOf(ProgID:String):Integer;
begin
   Result:=-1;
   if (FRegistryList = nil) or (FRegistryList.TheList = nil) then Exit;
   Result:=FRegistryList.TheList.IndexOf(ProgID);
end;
function TGPCSRegistry.Add(Value:TGPCSRegistryEntry):Integer;
var
   RegEntry:TGPCSRegistryEntry;
begin
   Result:=IndexOf(Value.FProgID);
   if Result <> -1 then Exit; // already in list !
   RegEntry:=TGPCSRegistryEntry.Create(nil,'','');
   RegEntry.FBitMap       :=Value.FBitMap       ;
   RegEntry.FCaption      :=Value.FCaption      ;
   RegEntry.FGUID         :=Value.FGUID         ;
   RegEntry.FDescription  :=Value.FDescription  ;
   RegEntry.FComponentType:=Value.FComponentType;
   RegEntry.FServerBinary1:=Value.FServerBinary1;
   RegEntry.FServerBinary2:=Value.FServerBinary2;
   RegEntry.FServerBinary3:=Value.FServerBinary3;
   RegEntry.FProgID       :=Value.FProgID       ;
   RegEntry.FName         :=Value.FName         ;
   RegEntry.FVersion      :=Value.FVersion      ;
   RegEntry.FGroup        :=Value.FGroup        ;
   if FRegistryList = nil then
      FRegistryList:=TGPCSRegistryList.Create;
   Result:=FRegistryList.TheList.AddObject(Value.FProgID,RegEntry);
end;
procedure TGPCSRegistry.Delete(ProgID:String);
var
   I:Integer;
begin
   if (FRegistryList = nil) or (FRegistryList.TheList = nil) then Exit;
   I:=FRegistryList.TheList.IndexOf(ProgID);
   if I >= 0 then
      FRegistryList.TheList.Delete(I);
end;
 
end.
 