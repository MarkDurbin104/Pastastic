unit MsgFileAccessU;

interface

uses
  Windows, SysUtils, Classes,FileCtrl,MsgConfigU,IPCThrd,Dialogs,ParseNodeU,GPCSGUID,
  CRC32,Compress,PackStrListU,StringWrapperU,StatusMonitorU,DirectoryU,GPCSErrorLine;
  
type
  TDeliveryType = (dtAdministration,dtTransaction,dtOfficeToOffice,
                   dtPhysicalOffToOff,dtSendToGroup,dtDistributionFile);
                   
  TMessageType = (mtTransaction,mtConfiguration,mtStatus,mtStock,mtRegistry,mtTransfer,
                  mtPension,mtMoneyOrder,mtPOBox,mtPhil,mtUser,mtMailEvent,
                  mtPensionTxn,mtMoneyOrderTxn,mtPOBoxTxn,mtPhilTxn );
                  
  TMessageFile = class;
  TMessageParams = class(TStringWrapper)
     public
      property PhysicalLayout:Variant Index 0 read GetElement write SetElement;
      property LogicalLayout :Variant Index 1 read GetElement write SetElement;
      property MessageName   :Variant Index 2 read GetElement write SetElement;
      property MessageData   :Variant Index 3 read GetElement write SetElement;
  end;
  TMessageRec = packed record 
    MessageRecVersion:Byte          ; // currently 0
    ActualSize       :Integer       ; 
    CRC 			      :Integer       ; 
    Flags 		      :Integer       ;
    Identifier       :Integer       ; 
    WorkStation      :Byte          ; 
    Office  	      :Word          ; 
    DestinationOffice:Word          ; 
    SendBy           :TDateTime     ;
    ExpiryDate       :Word          ; 
    DeliveryType     :TDeliveryType ;
    MessageVersion   :Integer       ; 
    RawLength        :Integer       ; 
    MessageType      :TMessageType  ;
    MessageParams    :TMessageParams;
  end;
  TMessageAccess = class(TObject)
  private
     FMessageRec:TMessageRec;
     procedure SetValue(Index:Integer;Value:Variant);
     function  GetValue(Index:Integer):Variant;
  public     
    constructor Create;
    destructor Destroy; override;
    procedure SetCRCFromData;
    function GoodCRC:Boolean;
    function LoadFromStream(S:TStream):Boolean;
    function SaveToStream  (S:TStream):Boolean;
    property MessageRecVersion:Variant Index  0 read GetValue write SetValue;
    property CRC 			      :Variant Index  1 read GetValue write SetValue;
    property Flags 		      :Variant Index  2 read GetValue write SetValue;
    property Identifier       :Variant Index  3 read GetValue write SetValue;
    property WorkStation      :Variant Index  4 read GetValue write SetValue;
    property Office  	      :Variant Index  5 read GetValue write SetValue;
    property DestinationOffice:Variant Index  6 read GetValue write SetValue;
    property SendBy           :Variant Index  7 read GetValue write SetValue;
    property ExpiryDate       :Variant Index  8 read GetValue write SetValue;
    property DeliveryType     :Variant Index  9 read GetValue write SetValue;
    property MessageVersion   :Variant Index 10 read GetValue write SetValue;
    property MessageLength    :Variant Index 11 read GetValue write SetValue;      
    property MessageType      :Variant Index 12 read GetValue write SetValue;
    property LengthPLayout    :Variant Index 13 read GetValue write SetValue;
    property LengthLLayout    :Variant Index 14 read GetValue write SetValue;
    property LengthName       :Variant Index 15 read GetValue write SetValue;
    property PhysicalLayout   :Variant Index 16 read GetValue write SetValue;      
    property LogicalLayout    :Variant Index 17 read GetValue write SetValue;      
    property MessageName      :Variant Index 18 read GetValue write SetValue;      
    property MessageData      :Variant Index 19 read GetValue write SetValue;      
    property RawData          :Variant Index 20 read GetValue write SetValue;      
    property RawLength        :Variant Index 21 read GetValue write SetValue;      
    property ActualSize       :Variant Index 22 read GetValue write SetValue; 
  end;
  TIndexRec = packed record 
    Identifier :Integer  ;
    Offset     :Integer  ;
    Flags 	   :Integer  ; 
    SendBy     :TDateTime;
    Destination:Word;
    Reserved   :Word;
  end;
  TIndexBlk = class(TObject)
  private
     FOffice     :Integer;
     FWorkstation:Integer;
     FMutex:TMutex;
     FWriteFileStream:TFileStream; 
     FReadFileStream :TFileStream; 
     FFileName:String;
     FNextBlk:TIndexBlk;
     FBaseAddress:Integer;
     FNextAddress:Integer;
     FIdxBlkFlags:Integer;
     FReadOnly:Boolean;
     FIdxBlks:Array[0..IndexSize] of TIndexRec;
     FData:TMemoryStream;
     FTopIndexBlk:TIndexBlk;
     FFastAccessList:TList;
     function GetMutex(CallingFuncGUID:String):Boolean;
     procedure ReleaseMutex;
     procedure GetStatBits(var Bits:TBBits;Offset:Integer;MessageFile:TMessageFile); virtual;
     function FindMessageBlk(MessageNumber:Integer;var MsgOffset:Integer;Fast:Boolean):TIndexBlk;
     function CreateMessageBlk(MessageNumber,Flags:Integer;var MsgOffset:Integer;SendBy:TDateTime;Destination:Word;ReadOnly:Boolean):TIndexBlk;
     procedure UpdateMessageFlagsFromID(Identifier,Flags:Integer);
  public
     constructor Create(Office,Workstation:Integer;FileName:String;ReadStream,WriteStream:TFileStream;TopIndexBlk:TIndexBlk;ReadOnly:Boolean);
     destructor Destroy; override;
     procedure ReleaseDataBuffer;
     procedure UpdateMessageFlags(MessageAccess:TMessageAccess);
     function GetMessageFlags(MessageIdentifier:Integer):Integer;
     function GetMessageSendBy     (MessageIdentifier:Integer):TDateTime;
     function GetMessageDestination(MessageIdentifier:Integer):Integer;
     procedure SetMessageFlags(MessageIdentifier:Integer;Value:Integer);
     function ReadMessage(MessageNumber:Integer):TMessageAccess;
     function WriteMessage(Value:TMessageAccess):Boolean;
     function AppendMessage(Value:TMessageAccess):Boolean;
     function GetStatus(var MaxIdentifier:Integer;MessageFile:TMessageFile):String;
     procedure Flush;
     function WriteFileTo(DataStream:TStream):Boolean;
  end;
  TIndexBlkRef = class(TObject)
     MessageNumber:Integer;
     IndexBlk     :TIndexBlk;
     Index        :Integer;
  end;
  TMessageFile = class(TObject)
  private
     FIndexBlk     :TIndexBlk;
     FMaxIdentifier:Integer;
     function GetFileName(Path:String;Office,Workstation:Integer):String;
     function AppendMessageBlock(Value:TMessageAccess):Boolean;
  public     
     constructor Create(Path:String;Office,Workstation:Integer;ReadOnly:Boolean);
     destructor Destroy; override;
     procedure UpdateMessageFlags(MessageAccess:TMessageAccess);
     function GetMessageBlock(MessageIdentifier:Integer;DeliveryType:TDeliveryType;DestinationOffice:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String;MarkAsProcessed:Boolean):TMessageAccess;
     function AppendMessage(DeliveryType:TDeliveryType;DestinationOffice:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String;MarkAsProcessed:Boolean):TMessageAccess;
     function AddMessage(MessageIdentifier:Integer;DeliveryType:TDeliveryType;DestinationOffice:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String;MarkAsProcessed:Boolean):TMessageAccess;
     function GetRawMessage(MessageNumber:Integer):TMessageAccess;
     function GetMessage(MessageNumber:Integer):TMessageAccess;
     function GetMessageFlags(MessageNumber:Integer):Integer;
     function GetMessageSendBy     (MessageNumber:Integer):TDateTime;
     function GetMessageDestination(MessageNumber:Integer):Integer;
     procedure SetMessageFlags(MessageNumber:Integer;Value:Integer);
     function SetMessage(Value:TMessageAccess):Boolean;
     function GetStatus:String;
     procedure Flush;
     function ReadFileFrom(DataStream:TStream):Boolean;
     function WriteFileTo(DataStream:TStream):Boolean;
  end;
  TAllMsgFiles = class(TObject)
    private
       LastOffice     :Integer;
       LastWorkstation:Integer;
       LastMessageFile:TMessageFile;
       LastFilePath   :String;
       FFilePath:String;
       FFileList:TStringList;
       OfficeList:TPackStringList;
    public
       constructor Create(Path:String;OfficeCode:Integer;ReadOnly:Boolean);
       destructor Destroy; override;
       procedure UpdateMessageFlags(MessageAccess:TMessageAccess);
       function GetRawMessage(Office,WorkStation:Integer;MessageNum:Integer):TMessageAccess;
       function GetMessage(Office,WorkStation:Integer;MessageNum:Integer):TMessageAccess;
       function GetMessageFlags(Office,WorkStation:Integer;MessageNum:Integer):Integer;
       function GetMessageSendBy     (Office,WorkStation:Integer;MessageNum:Integer):TDateTime;
       function GetMessageDestination(Office,WorkStation:Integer;MessageNum:Integer):Integer;
       procedure SetMessageFlags(Office,WorkStation:Integer;MessageNum:Integer;Value:Integer);
       function SetMessage(Value:TMessageAccess):Boolean;
       function AddMessage(Office,WorkStation,MessageIdentifier:Integer;DeliveryType:TDeliveryType;DestinationOffice:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String;MarkAsProcessed:Boolean):TMessageAccess;
       function AppendMessage(Office,WorkStation:Integer;DeliveryType:TDeliveryType;DestinationOffice:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String;MarkAsProcessed:Boolean):TMessageAccess;
       function MessageFile(Office,Workstation:Integer):TMessageFile;
       function GetStatus:String;
       function GetOfficeList(OfficeRouteInfo:TParseNode):TStrings;
       function ReadFileFrom(Office,Workstation:Integer;DataStream:TStream):Boolean;
       function WriteFileTo(Office,Workstation:Integer;DataStream:TStream):Boolean;
       procedure Flush;
  end;

function Today:Integer;
function ZeroPad(Value,Len:Integer):String;

implementation
//uses
//  TranProcessU;
  
{TIndexBlk}  
constructor TIndexBlk.Create(Office,Workstation:Integer;FileName:String;ReadStream,WriteStream:TFileStream;TopIndexBlk:TIndexBlk;ReadOnly:Boolean);
var
   I:Integer;
begin
   inherited Create;
   FOffice     :=Office     ;
   FWorkstation:=Workstation;
   FReadOnly   :=ReadOnly   ;
   if ReadStream = nil then Abort;
   if ReadStream.Position > ReadStream.Size then
   begin
      ShowMessage('Over End !');
      ReadStream.Position:=ReadStream.Size;
   end;

  
   
   FMutex:=nil;
   if TopIndexBlk = nil then // self must be top in list
   begin
      TopIndexBlk:=Self;
      if not ReadOnly then
         FMutex:=TMutex.Create(MutexName+'_'+Copy(FileName,Length(FileName)-11,8));
   end;
   FTopIndexBlk:=TopIndexBlk;
   FWriteFileStream:=WriteStream;
   FReadFileStream :=ReadStream ;
   FFileName:=FileName;
   FNextBlk:=nil;
   if FWriteFileStream <> nil then 
      FWriteFileStream.Position:=FReadFileStream.Position;
   
   FBaseAddress:=FReadFileStream.Position;
   FNextAddress:=0;
   FIdxBlkFlags:=0;
   ZeroMemory(@FIdxBlks[0],SizeOf(FIdxBlks));
   FData:=nil;
   if (FReadFileStream.Size <> 0) then
   begin
      if (FWriteFileStream <> nil) and (FWriteFileStream.Position = FWriteFileStream.Size) then
      begin               
         FWriteFileStream.Write(FIdxBlkFlags,SizeOf(FIdxBlkFlags));
         FWriteFileStream.Write(FIdxBlks,SizeOf(FIdxBlks));
      end;
      if (FReadFileStream.Read(FIdxBlkFlags,SizeOf(FIdxBlkFlags)) = SizeOf(FIdxBlkFlags)) then
      if (FReadFileStream.Read(FIdxBlks,SizeOf(FIdxBlks)) = SizeOf(FIdxBlks)) then
      begin
         if FIdxBlks[IndexSize].Offset <> 0 then // last item points to next block or 0 for last block
         begin
            FReadFileStream.Position:=FIdxBlks[IndexSize].Offset;
            if FWriteFileStream <> nil then
               FWriteFileStream.Position:=FReadFileStream.Position;
            FNextBlk:=TIndexBlk.Create(FOffice,FWorkStation,FFileName,FReadFileStream,FWriteFileStream,FTopIndexBlk,ReadOnly);
         end
         else
         begin
            for I:=0 to IndexSize do // find first empty block
            begin
               if FIdxBlks[I].Offset = 0 then 
               begin
                  FNextAddress:=I;
                  break;
               end;
            end;
         end;
      end;
   end;            
end;
procedure TIndexBlk.ReleaseMutex;
begin
   if FTopIndexBlk.FMutex = nil then Exit;
   FTopIndexBlk.FMutex.Release;
end;
function TIndexBlk.GetMutex(CallingFuncGUID:String):Boolean;
begin
   Result:=False;
   if FTopIndexBlk.FMutex = nil then Exit;
   
   Result:=True;
   if not FTopIndexBlk.FMutex.Get(1000) then
   begin
      RaiseGUIDError(CallingFuncGUID,'could not get mutex '+FMutex.FName+' - retrying');
      if not FTopIndexBlk.FMutex.Get(5000) then
      begin
         RaiseGUIDError(CallingFuncGUID,'could not get mutex '+FMutex.FName+' - FAILED');
         Result:=False;
      end;
   end;
end;                
destructor TIndexBlk.Destroy;
begin
   GetMutex('{B70E1542-B0D4-437A-B7C4-739BD86479A3}');
   if FTopIndexBlk = Self then
   begin
      if FFastAccessList <> nil then
      begin
         while FFastAccessList.Count > 0 do
         begin
            if FFastAccessList[0] <> nil then
            try
               TIndexBlkRef(FFastAccessList[0]).Free;
            except
            end;
            FFastAccessList.Delete(0);
         end;
         FFastAccessList.Free;
         FFastAccessList:=nil;
      end;
      ReleaseDataBuffer;
      if (FWriteFileStream <> nil) and (FWriteFileStream.Size = 0) then
      begin
         FReadFileStream.Free;
         FWriteFileStream.Free;
         DeleteFile(FFileName);
      end
      else
      begin
         FReadFileStream.Free;
         if (FWriteFileStream <> nil) then FWriteFileStream.Free;
      end;
      FReadFileStream:=nil;
      FWriteFileStream:=nil;
      if FMutex <> nil then
      begin
         FMutex.Release;
         FMutex.Free;
         FMutex:=nil;
      end;
   end;
   if FNextBlk <> nil then
      FNextBlk.Free;
   FNextBlk:=nil;
   inherited Destroy;
end;
procedure TIndexBlk.ReleaseDataBuffer;
begin
   if FData <> nil then
   begin
      FData.Free;
      FData:=nil;
   end;
   if FNextBlk <> nil then
      FNextBlk.ReleaseDataBuffer;
end;
procedure TIndexBlk.Flush;
begin
   if FReadOnly then Exit;
   GetMutex('{CE92E39B-65D5-413D-B428-3ECE34A926F7}');
   try
      FlushFileBuffers(FWriteFileStream.Handle);
   except
      on E:Exception do
         RaiseGUIDException('{18CC731B-32CB-43E7-AA06-D720B0CF4B7A}',E);
   end;
   ReleaseMutex;
end;

function TIndexBlk.CreateMessageBlk(MessageNumber,Flags:Integer;var MsgOffset:Integer;SendBy:TDateTime;Destination:Word;ReadOnly:Boolean):TIndexBlk;
var
   CompressedStream:TMemoryStream;
   OrigSize,CompSize:Integer;
begin
   if FNextBlk <> nil then
   begin
      Result:=FNextBlk.CreateMessageBlk(MessageNumber,Flags,MsgOffset,SendBy,Destination,ReadOnly);
      Exit;
   end;
   Result:=nil;
   try
      if FNextAddress = IndexSize then // last space! - need a new block
      begin
         if CompressingBlocks then // squash this one before writing the next
         begin
            CompressedStream:=TMemoryStream.Create;
            FWriteFileStream.Position:=FBaseAddress+SizeOf(FIdxBlkFlags)+SizeOf(FIdxBlks);
            OrigSize:=FWriteFileStream.Size-FWriteFileStream.Position;
            TCompressor.CompressStream(FWriteFileStream,CompressedStream);
            CompressedStream.Position:=0;
            CompSize:=CompressedStream.Size-CompressedStream.Position;
            if OrigSize > CompSize then // only bother if it's smaller!
            begin
               FWriteFileStream.Position:=FBaseAddress+SizeOf(FIdxBlkFlags)+SizeOf(FIdxBlks);
               CompressedStream.Position:=0;
               FWriteFileStream.CopyFrom(CompressedStream,CompressedStream.Size);
               CompressedStream.Free;
               FWriteFileStream.Size:=FWriteFileStream.Position;
               FWriteFileStream.Position:=FBaseAddress;
               FIdxBlkFlags:=FIdxBlkFlags or MessageCompressed; // mark as compressed
               FWriteFileStream.Write(FIdxBlkFlags,SizeOf(FIdxBlkFlags));
            end
            else
            begin
               CompressedStream.Free;
            end;
         end;
         
         // save the index to the new block in this block
         FIdxBlks[IndexSize].Offset:=FWriteFileStream.Size;
         FIdxBlks[IndexSize].Identifier:=0;
         FWriteFileStream.Position:=FBaseAddress+SizeOf(FIdxBlkFlags)+IndexSize*SizeOf(TIndexRec);
         FWriteFileStream.Write((@FIdxBlks[IndexSize])^,SizeOf(TIndexRec));
      
         // move to then end and create another block
         FWriteFileStream.Position:=FWriteFileStream.Size;
         FReadFileStream.Position:=FWriteFileStream.Position;
         FNextBlk:=TIndexBlk.Create(FOffice,FWorkStation,FFileName,FReadFileStream,FWriteFileStream,FTopIndexBlk,ReadOnly);
         Result:=FNextBlk.CreateMessageBlk(MessageNumber,Flags,MsgOffset,SendBy,Destination,ReadOnly);
         Exit;
      end;
      if FWriteFileStream.Size = 0 then // new file - create first block
      begin
         FWriteFileStream.Position:=0;
         FWriteFileStream.Write(FIdxBlkFlags,SizeOf(FIdxBlkFlags));
         FWriteFileStream.Write(FIdxBlks,SizeOf(FIdxBlks));
         FWriteFileStream.Position:=0;
      end;
      MsgOffset:=FNextAddress;
      Inc(FNextAddress);
      FIdxBlks[MsgOffset].Offset:=FWriteFileStream.Size;
      FIdxBlks[MsgOffset].Identifier:=MessageNumber;
      FIdxBlks[MsgOffset].Flags:=Flags;
      FIdxBlks[MsgOffset].SendBy:=SendBy;
      FIdxBlks[MsgOffset].Destination:=Destination;
      FIdxBlks[MsgOffset].Reserved:=0;
      FWriteFileStream.Position:=FBaseAddress+SizeOf(FIdxBlkFlags)+MsgOffset*SizeOf(TIndexRec);
      FWriteFileStream.Write((@FIdxBlks[MsgOffset])^,SizeOf(TIndexRec));
      Result:=Self;
   except
      on E:Exception do
         RaiseGUIDException('{18CC731B-32CB-43E7-AA06-D720B0CF4B7A}',E);
   end;
end;
function TIndexBlk.FindMessageBlk(MessageNumber:Integer;var MsgOffset:Integer;Fast:Boolean):TIndexBlk;
var
   Index:Integer;
   CurrentBlk:TIndexBlk;
   BRef:TIndexBlkRef;
const
   UseFastAccess:Boolean = False;
begin
   Result:=nil;
   if UseFastAccess then
   begin
   if FFastAccessList = nil then
   begin
      FFastAccessList:=TList.Create;
      CurrentBlk:=Self;
      while CurrentBlk <> nil do
      begin
         for Index:=0 to IndexSize-1 do
         begin
            BRef:=TIndexBlkRef.Create;
            BRef.IndexBlk:=CurrentBlk;
            BRef.Index:=Index;
            while FFastAccessList.Count <= BRef.MessageNumber do
               FFastAccessList.Add(nil);
            FFastAccessList[BRef.MessageNumber]:=BRef;
         end;
         CurrentBlk:=CurrentBlk.FNextBlk;
      end;
   end;
   if (MessageNumber >= FTopIndexBlk.FFastAccessList.Count) then
   begin
      for Index:=0 to IndexSize-1 do
      begin
         if FIdxBlks[Index].Identifier = MessageNumber then
         begin
            MsgOffset:=Index;
            Result:=Self;
            BRef:=TIndexBlkRef.Create;
            BRef.IndexBlk:=Self;
            BRef.Index:=Index;
            while FTopIndexBlk.FFastAccessList.Count <= MessageNumber do
               FTopIndexBlk.FFastAccessList.Add(nil);
            FTopIndexBlk.FFastAccessList[MessageNumber]:=BRef;
            Exit;            
         end;
      end;   
      if FNextBlk <> nil then
         Result:=FNextBlk.FindMessageBlk(MessageNumber,MsgOffset,Fast);
   end
   else
   begin
      BRef:=FTopIndexBlk.FFastAccessList[MessageNumber];
      if BRef = nil then Exit;
      MsgOffset:=BRef.Index;
      Result:=BRef.IndexBlk;
   end;
   end
   else
   begin
//      Fast:=False;
      if Fast then
      begin
         if  (MessageNumber >= FIdxBlks[0].Identifier) 
         and (MessageNumber <= FIdxBlks[IndexSize-1].Identifier) then
         begin
            for Index:=0 to IndexSize-1 do
            begin
               if FIdxBlks[Index].Identifier = MessageNumber then
               begin
                  MsgOffset:=Index;
                  Result:=Self;
                  Exit;            
               end;
            end;   
         end
         else
         begin
            if FNextBlk <> nil then
               Result:=FNextBlk.FindMessageBlk(MessageNumber,MsgOffset,Fast);
         end;
      end; 
      if Result = nil then
      begin
         for Index:=0 to IndexSize-1 do
         begin
            if FIdxBlks[Index].Identifier = MessageNumber then
            begin
               MsgOffset:=Index;
               Result:=Self;
               Exit;            
            end;
         end;   
         if FNextBlk <> nil then
            Result:=FNextBlk.FindMessageBlk(MessageNumber,MsgOffset,False);
      end;
   end;
end;          
function TIndexBlk.ReadMessage(MessageNumber:Integer):TMessageAccess;
var
   IndexBlk:TIndexBlk;
   MsgOffset:Integer;
   IMemoryStream:TMemoryStream;
   LocalFS:TFileStream;
begin
   Result:=nil;
   IndexBlk:=FindMessageBlk(MessageNumber,MsgOffset,True);
   if IndexBlk <> nil then
   begin
      Result:=TMessageAccess.Create;
      if (IndexBlk.FIdxBlkFlags and MessageCompressed) = MessageCompressed then
      begin
         try
            if IndexBlk.FData = nil then
            begin
               try
                  FTopIndexBlk.ReleaseDataBuffer;
                  IMemoryStream:=TMemoryStream.Create;
                  IndexBlk.FData:=TMemoryStream.Create;
                  
                  LocalFS:=TFileStream.Create(FFileName,fmOpenRead or fmShareDenyNone);
                  try
                     LocalFS.Position:=IndexBlk.FBaseAddress+SizeOf(FIdxBlkFlags)+SizeOf(FIdxBlks);
                     IMemoryStream.CopyFrom(LocalFS,IndexBlk.FIdxBlks[IndexSize].Offset-LocalFS.Position);
                  finally
                     LocalFS.Free;
                  end;
            
                  IMemoryStream.Position:=0;
                  TCompressor.DecompressStream(IMemoryStream,IndexBlk.FData);
                  IMemoryStream.Free;
               except
                  IndexBlk.FData.Position:=0;
                  IndexBlk.FData.Size:=0;
               end;
            end;
            if IndexBlk.FData.Size > (IndexBlk.FIdxBlks[MsgOffset].Offset-(IndexBlk.FBaseAddress+SizeOf(FIdxBlkFlags)+SizeOf(FIdxBlks))) then
            begin
               IndexBlk.FData.Position:=IndexBlk.FIdxBlks[MsgOffset].Offset-(IndexBlk.FBaseAddress+SizeOf(FIdxBlkFlags)+SizeOf(FIdxBlks));
               Result.LoadFromStream(IndexBlk.FData);
            end
            else
            begin
               Result.Free;
               Result:=nil;
            end;
         except
            on E:Exception do
               RaiseGUIDException('{311B7F9C-FE44-4DDD-B9D1-64CFD5A51D89}',E);
         end;
      end               
      else
      begin
         if FReadFileStream.Size > IndexBlk.FIdxBlks[MsgOffset].Offset then
         begin
            LocalFS:=TFileStream.Create(FFileName,fmOpenRead or fmShareDenyNone);
            try
               LocalFS.Position:=IndexBlk.FIdxBlks[MsgOffset].Offset;
               Result.LoadFromStream(LocalFS);
            except
               on E:Exception do
                  RaiseGUIDException('{DA8F9563-DB4C-4DEA-BC76-A75108F6F430}',E);
            end;
            LocalFS.Free;
         end
         else
         begin
            Result.Free;
            Result:=nil;
         end;
      end;
      if Result <> nil then
         Result.Flags:=IndexBlk.FIdxBlks[MsgOffset].Flags;
   end;
end;     
procedure TIndexBlk.SetMessageFlags(MessageIdentifier:Integer;Value:Integer);
var
   IndexBlk:TIndexBlk;
   MsgOffset:Integer;
begin
   GetMutex('{804AA290-FF38-49A5-9899-0C30B0E879B1}');
   try
      IndexBlk:=FindMessageBlk(MessageIdentifier,MsgOffset,True);
      if IndexBlk <> nil then
      begin
         if (Value and BadMessageBlock) <> 0 then
            IndexBlk.FIdxBlks[MsgOffset].Identifier:=-2;
         IndexBlk.FIdxBlks[MsgOffset].Flags:=Value;
         FWriteFileStream.Position:=IndexBlk.FBaseAddress+SizeOf(FIdxBlkFlags)+MsgOffset*SizeOf(TIndexRec);
         FWriteFileStream.Write((@IndexBlk.FIdxBlks[MsgOffset])^,SizeOf(TIndexRec));
      end;
   except
      on E:Exception do
         RaiseGUIDException('{0E48A084-EAC1-403F-B030-71D51992D48F}',E);
   end;
   ReleaseMutex;
end;
function TIndexBlk.GetMessageFlags(MessageIdentifier:Integer):Integer;
var
   IndexBlk:TIndexBlk;
   MsgOffset:Integer;
begin
   Result:=0;
   IndexBlk:=FindMessageBlk(MessageIdentifier,MsgOffset,True);
   if IndexBlk <> nil then
   begin
      Result:=IndexBlk.FIdxBlks[MsgOffset].Flags;
   end;
end;
function TIndexBlk.GetMessageSendBy(MessageIdentifier:Integer):TDateTime;
var                                        
   IndexBlk:TIndexBlk;
   MsgOffset:Integer;
begin
   Result:=0;
   IndexBlk:=FindMessageBlk(MessageIdentifier,MsgOffset,True);
   if IndexBlk <> nil then
   begin
      Result:=IndexBlk.FIdxBlks[MsgOffset].SendBy;
   end;
end;
function TIndexBlk.GetMessageDestination(MessageIdentifier:Integer):Integer;
var
   IndexBlk:TIndexBlk;
   MsgOffset:Integer;
begin
   Result:=0;
   IndexBlk:=FindMessageBlk(MessageIdentifier,MsgOffset,True);
   if IndexBlk <> nil then
   begin
      Result:=IndexBlk.FIdxBlks[MsgOffset].Destination;
   end;
end;
procedure TIndexBlk.UpdateMessageFlagsFromID(Identifier,Flags:Integer);
var
   IndexBlk:TIndexBlk;
   MsgOffset:Integer;
begin
   if FReadOnly then Exit;
   GetMutex('{C0C72DFB-5401-4F92-96FC-43C562626DE2}');
   try
      IndexBlk:=FindMessageBlk(Identifier,MsgOffset,True);
      if IndexBlk <> nil then
      begin
         if (Flags and BadMessageBlock) <> 0 then
            IndexBlk.FIdxBlks[MsgOffset].Identifier:=-2;
         IndexBlk.FIdxBlks[MsgOffset].Flags:=Flags;
         FWriteFileStream.Position:=IndexBlk.FBaseAddress+SizeOf(FIdxBlkFlags)+MsgOffset*SizeOf(TIndexRec);
         FWriteFileStream.Write((@IndexBlk.FIdxBlks[MsgOffset])^,SizeOf(TIndexRec));
      end;
   except
      on E:Exception do
         RaiseGUIDException('{810A69A4-4312-4771-8D1F-35A13B95F543}',E);
   end;
   ReleaseMutex;
end;      
procedure TIndexBlk.UpdateMessageFlags(MessageAccess:TMessageAccess);
begin
   UpdateMessageFlagsFromID(MessageAccess.Identifier,MessageAccess.Flags);
end;
function TIndexBlk.WriteMessage(Value:TMessageAccess):Boolean;
var
   IndexBlk:TIndexBlk;
   MsgOffset:Integer;
begin
   if Value.GoodCRC then
      Value.Flags:=Value.Flags or MessageHasGoodCRC
   else
      Value.Flags:=Value.Flags or BadMessageBlock;
      
   IndexBlk:=FindMessageBlk(Value.Identifier,MsgOffset,True);
   if IndexBlk <> nil then // mark old message as bad
   begin
      IndexBlk.FIdxBlks[MsgOffset].Flags:=BadMessageBlock;
      SetMessageFlags(MsgOffset,IndexBlk.FIdxBlks[MsgOffset].Flags);
   end;
   Result:=AppendMessage(Value);
end;     
function TIndexBlk.AppendMessage(Value:TMessageAccess):Boolean;
var
   IndexBlk:TIndexBlk;
   MsgOffset:Integer;
begin
   Result:=True;                  
   GetMutex('{2E4959D0-0B9F-4B31-A498-1A07E647F374}');
   try
      ReleaseDataBuffer;
      IndexBlk:=CreateMessageBlk(Value.Identifier,Value.Flags,MsgOffset,Value.SendBy,Value.DestinationOffice,False);
      FWriteFileStream.Position:=IndexBlk.FIdxBlks[MsgOffset].Offset;
      Value.SaveToStream(FWriteFileStream);
   except
      on E:Exception do
      begin
         RaiseGUIDException('{278CE7AE-DFA3-4E7F-B6AD-55F8EE5BAFCB}',E);
         Result:=False;
      end;
   end;
   ReleaseMutex;
end;     
procedure TIndexBlk.GetStatBits(var Bits:TBBits;Offset:Integer;MessageFile:TMessageFile);
var
   Index:Integer;
   MessageData:TMessageAccess;
begin
   for Index:=0 to IndexSize-1 do
   begin
      if (FIdxBlks[Index].Offset <> 0) and (FIdxBlks[Index].Reserved = 0) then
      begin                                                                                              
         if ((FIdxBlks[Index].Flags and (MessageHasGoodCRC or BadMessageBlock)) = 0) then                 
         begin                                                                                           
            MessageData:=MessageFile.GetMessage(FIdxBlks[Index].Identifier);
            if MessageData <> nil then
            begin
               if MessageData.GoodCRC then
                  MessageData.Flags:=MessageData.Flags or MessageHasGoodCRC
               else
                  MessageData.Flags:=MessageData.Flags or BadMessageBlock;
               UpdateMessageFlagsFromID(FIdxBlks[Index].Identifier,MessageData.Flags);
               MessageData.Free;
            end
            else
            begin
               FIdxBlks[Index].Flags:=FIdxBlks[Index].Flags or BadMessageBlock;
               UpdateMessageFlagsFromID(FIdxBlks[Index].Identifier,FIdxBlks[Index].Flags);
            end;
         end;
         if FIdxBlks[Index].Identifier < 200000 then
            Bits[FIdxBlks[Index].Identifier]:=(FIdxBlks[Index].Flags and MessageHasGoodCRC) <> 0;
      end;  
   end;
   if FNextBlk <> nil then
      FNextBlk.GetStatBits(Bits,Offset+IndexSize,MessageFile);
end;
function TIndexBlk.GetStatus(var MaxIdentifier:Integer;MessageFile:TMessageFile):String;
var
   Bits:TBBits;
begin
   Bits:=TBBits.Create;
   Bits.Size:=0;
   GetStatBits(Bits,0,MessageFile);
   MaxIdentifier:=Bits.Size;
   if MaxIdentifier = 0 then MaxIdentifier:=1;
   Result:=Bits.AsString;
   Bits.Free;
end;     
function TIndexBlk.WriteFileTo(DataStream:TStream):Boolean;
var
   BlockSize:Integer;
begin
   Result:=True;                  
   GetMutex('{84783F72-EC8C-4D37-A38B-5FD66596B26C}');
   try
      FReadFileStream.Position:=0;
      BlockSize:=FReadFileStream.Size;
      DataStream.Write(BlockSize,SizeOf(BlockSize));
      DataStream.CopyFrom(FReadFileStream,BlockSize);
   except
      on E:Exception do
      begin
         RaiseGUIDException('{0F92F818-C0F1-4284-9B33-EF16D199499F}',E);
         Result:=False;
      end;
   end;
   ReleaseMutex;
end;                              
{TMessageAccess}
constructor TMessageAccess.Create;
begin
   inherited Create;
   ZeroMemory(@FMessageRec,SizeOf(FMessageRec));
   FMessageRec.ActualSize:=SizeOf(FMessageRec);
   FMessageRec.MessageParams:=TMessageParams.Create;
end;
destructor TMessageAccess.Destroy;
begin
   FMessageRec.MessageParams.Free;
   FMessageRec.MessageParams:=nil;
   inherited Destroy;
end;             
function  TMessageAccess.GetValue(Index:Integer):Variant;
begin
   Result:=-1;
   case Index of
       0 : Result:=       FMessageRec.MessageRecVersion          ;
       1 : Result:=       FMessageRec.CRC 			              ;
       2 : Result:=       FMessageRec.Flags 		                 ;
       3 : Result:=       FMessageRec.Identifier                 ;
       4 : Result:=       FMessageRec.WorkStation                ;
       5 : Result:=       FMessageRec.Office  	                 ;
       6 : Result:=       FMessageRec.DestinationOffice          ;
       7 : Result:=       FMessageRec.SendBy                     ;
       8 : Result:=       FMessageRec.ExpiryDate                 ;
       9 : Result:=       FMessageRec.DeliveryType               ;
      10 : Result:=       FMessageRec.MessageVersion             ;
      11 : Result:=Length(FMessageRec.MessageParams.MessageData   );
      12 : Result:=       FMessageRec.MessageType                ;
      13 : Result:=Length(FMessageRec.MessageParams.PhysicalLayout);
      14 : Result:=Length(FMessageRec.MessageParams.LogicalLayout );
      15 : Result:=Length(FMessageRec.MessageParams.MessageName   );
      16 : Result:=       FMessageRec.MessageParams.PhysicalLayout ;
      17 : Result:=       FMessageRec.MessageParams.LogicalLayout  ;
      18 : Result:=       FMessageRec.MessageParams.MessageName    ;
      19 : Result:=       FMessageRec.MessageParams.MessageData    ;
      21 : Result:=       FMessageRec.RawLength                    ;
      22 : Result:=       FMessageRec.ActualSize                   ; 
      20 : begin
              begin
                 if (FMessageRec.Flags and MessageCompressed) <> 0 then
                 begin
                    try
                       Result:=TCompressor.CompressString(FMessageRec.MessageParams.PackText);
                    except
                       Result:='';
                    end;
                 end
                 else
                 begin
                    Result:=FMessageRec.MessageParams.PackText;
                 end;
              end;
           end;
   end;
end;
procedure TMessageAccess.SetValue(Index:Integer;Value:Variant);
begin
   case Index of
       0 : FMessageRec.MessageRecVersion         :=Value;
       1 : FMessageRec.CRC 			             :=Value;
       2 : FMessageRec.Flags 		                :=Value;
       3 : FMessageRec.Identifier                :=Value;
       4 : FMessageRec.WorkStation               :=Value;
       5 : FMessageRec.Office  	                :=Value;
       6 : FMessageRec.DestinationOffice         :=Value;
       7 : FMessageRec.SendBy                    :=Value;
       8 : FMessageRec.ExpiryDate                :=Value;
       9 : FMessageRec.DeliveryType              :=Value;
      10 : FMessageRec.MessageVersion            :=Value;
      12 : FMessageRec.MessageType               :=Value;
      16 : FMessageRec.MessageParams.PhysicalLayout:=Value;
      17 : FMessageRec.MessageParams.LogicalLayout :=Value;
      18 : FMessageRec.MessageParams.MessageName   :=Value;
      19 : FMessageRec.MessageParams.MessageData   :=Value;
      21 : FMessageRec.RawLength                   :=Value;
      22 : FMessageRec.ActualSize                  :=Value; 
      20 : begin
              if (FMessageRec.Flags and MessageCompressed) <> 0 then
              begin
                 FMessageRec.MessageParams.PackText:=TCompressor.DeCompressString(Value);
              end
              else
              begin
                 FMessageRec.MessageParams.PackText:=Value; 
              end;
           end;
   end;
   // keep length up to date
   if (Index >= 16) and  (Index <= 20) then
       FMessageRec.RawLength:=Length(FMessageRec.MessageParams.PackText); 
end;
procedure TMessageAccess.SetCRCFromData;
begin
   FMessageRec.CRC:=CRC32.CalcCCITTCRC(RawData); 
end;     
function TMessageAccess.GoodCRC:Boolean;
begin
   try
      if RawData <> '' then
         Result:=FMessageRec.CRC = CRC32.CalcCCITTCRC(RawData)
      else
         Result:=False; 
   except 
      Result:=False; 
   end;
end;     
function TMessageAccess.LoadFromStream(S:TStream):Boolean;
var
  Str:String;
  Size:Integer;
begin
   Result:=False;
   try
      Size:=SizeOf(FMessageRec)-SizeOf(String);
      if S.Read(FMessageRec,Size) = Size then
      begin
         // in later varsions, there may be additional data between the 
         // basic record data and the message strings, so skip over it 
         // on the older versions
         if ((FMessageRec.ActualSize <> SizeOf(FMessageRec)) and (FMessageRec.MessageRecVersion > 2)) or (FMessageRec.RawLength > $FFFFF) then
         begin
            RawData:='';
            Result:=False;
         end           
         else
         begin
            S.Position:=S.Position+(FMessageRec.ActualSize)-SizeOf(FMessageRec);
            SetLength(Str,FMessageRec.RawLength);
            if S.Read((@Str[1])^,FMessageRec.RawLength) = FMessageRec.RawLength then
            begin
               RawData:=Str;
               Result:=True;
            end;
         end;
      end;
   except
   end;
end;
function TMessageAccess.SaveToStream(S:TStream):Boolean;
var
  Str:String;
begin
   Result:=False;
   try 
      Str:=RawData;
      FMessageRec.RawLength:=Length(Str);
      if S.Write(FMessageRec,SizeOf(FMessageRec)-SizeOf(String)) = SizeOf(FMessageRec)-SizeOf(String) then
      begin
         if S.Write((@Str[1])^,FMessageRec.RawLength) = FMessageRec.RawLength then
           Result:=True;
      end;
   except
   end;
end;
{TMessageFile}
procedure TMessageFile.Flush;
begin
   if FIndexBlk <> nil then
      FIndexBlk.Flush;
end;
function ZeroPad(Value,Len:Integer):String;
begin
   Result:=IntToStr(Value);
   Result:=StringOfChar('0',Len-Length(Result))+Result;
end;
function TMessageFile.GetFileName(Path:String;Office,Workstation:Integer):String;
begin
   Result:=Path;
   if not DirectoryExists(Result) then
      ForceDirectories(Result);
   Result:=Result+'\'+ZeroPad(Office,5)+ZeroPad(WorkStation,3)+'.WSD';
end;
constructor TMessageFile.Create(Path:String;Office,Workstation:Integer;ReadOnly:Boolean);
var
   FileName:String;
   FReadStream:TFileStream;
   FWriteStream:TFileStream;
begin
   inherited Create;
   FileName:=GetFileName(Path,Office,Workstation);
   if ReadOnly then
   begin
      FWriteStream:=nil;
      if not FileExists(FileName) then Abort;
   end           
   else
   begin
      if not FileExists(FileName) then
         with TFileStream.Create(FileName,fmCreate or fmShareDenyNone) do Free;
      FWriteStream:=TFileStream.Create(FileName,fmOpenReadWrite or fmShareDenyNone);
   end;
   FReadStream:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
   FIndexBlk:=TIndexBlk.Create(Office,WorkStation,FileName,FReadStream,FWriteStream,nil,ReadOnly);
   FMaxIdentifier:=1;
end;          
destructor TMessageFile.Destroy;
begin
   FIndexBlk.Free;
   inherited Destroy;
end;
function TMessageFile.GetRawMessage(MessageNumber:Integer):TMessageAccess;
begin
   Result:=FIndexBlk.ReadMessage(MessageNumber);
end;
function TMessageFile.ReadFileFrom(DataStream:TStream):Boolean;
var
   FileName:String;
   WriteStream:TFileStream;
   ReadStream :TFileStream;
   BlockSize:Integer;
   Office:Integer;
   WorkStation:Integer;
begin 
   FileName   :=FIndexBlk.FFileName   ;
   Office     :=FIndexBlk.FOffice     ;
   WorkStation:=FIndexBlk.FWorkStation;
   FIndexBlk.Free;
   if not FileExists(FileName) then
      with TFileStream.Create(FileName,fmCreate or fmShareDenyNone) do Free;
      
   ReadStream:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
   WriteStream:=TFileStream.Create(FileName,fmOpenReadWrite or fmShareDenyNone);
   WriteStream.Size:=0;
   DataStream.Read(BlockSize,SizeOf(BlockSize));
   WriteStream.CopyFrom(DataStream,BlockSize);
   FlushFileBuffers(WriteStream.Handle);
   WriteStream.Position:=0;
   FIndexBlk:=TIndexBlk.Create(Office,WorkStation,FileName,ReadStream,WriteStream,nil,False);
   Result:=True;
end;
function TMessageFile.WriteFileTo(DataStream:TStream):Boolean;
begin
   Result:=FIndexBlk.WriteFileTo(DataStream);
end;
procedure TMessageFile.SetMessageFlags(MessageNumber:Integer;Value:Integer);
begin
   FIndexBlk.SetMessageFlags(MessageNumber,Value);
end;
function TMessageFile.GetMessageFlags(MessageNumber:Integer):Integer;
begin
   Result:=FIndexBlk.GetMessageFlags(MessageNumber);
end;
function TMessageFile.GetMessageSendBy(MessageNumber:Integer):TDateTime;
begin
   Result:=FIndexBlk.GetMessageSendBy(MessageNumber);
end;
function TMessageFile.GetMessageDestination(MessageNumber:Integer):Integer;
begin
   Result:=FIndexBlk.GetMessageDestination(MessageNumber);
end;
procedure TMessageFile.UpdateMessageFlags(MessageAccess:TMessageAccess);
begin
   FIndexBlk.UpdateMessageFlags(MessageAccess);
end;
function TMessageFile.GetMessage(MessageNumber:Integer):TMessageAccess;
begin
   Result:=GetRawMessage(MessageNumber);
end;         
function TMessageFile.SetMessage(Value:TMessageAccess):Boolean;
begin
   Result:=FIndexBlk.WriteMessage(Value);
end;   
function TMessageFile.AppendMessageBlock(Value:TMessageAccess):Boolean;
begin    
   Result:=FIndexBlk.AppendMessage(Value);
end;
function CleanTxns(Value:String;var HasPensionTxn,HasMOTxn:Boolean):String;
var
   TxnRecordList:TTxnLogLines;
   TxnFieldList:TTxnLogLine;
   IPDomInfoLines:TDomInfoLines;
   IPDomInfoLine:TDomInfoLine;
   OPDomInfoLine:TDomInfoLine;
   DomainIdx,RecordIdx:Integer;
begin
   HasPensionTxn:=False;
   HasMOTxn:=False;                     
   TxnFieldList:=TTxnLogLine.Create;
   TxnRecordList:=TTxnLogLines.Create;
   TxnRecordList.PackText:=Value;
   for RecordIdx:=0 to TxnRecordList.Count-1 do
   begin
      TxnFieldList.PackText:=TxnRecordList[RecordIdx];
      if ((TxnFieldList.PLU = '50040001') or (TxnFieldList.PLU = '50040002')) then
         HasPensionTxn:=True;
      if ((TxnFieldList.RecType = 'MOPaid') or (TxnFieldList.RecType = 'MOIssue')) then
         HasMOTxn:=True;                     
      if (TxnFieldList.Count > 16) 
      and (TxnFieldList.DomInfo <> '') then
      begin
         if ((TxnFieldList.RecType = 'TxnLine') or (TxnFieldList.RecType = 'MOIssue')) then
         begin
            IPDomInfoLines:=TDomInfoLines.Create;
            OPDomInfoLine:=TDomInfoLine.Create;
            IPDomInfoLine:=TDomInfoLine.Create;
      
            IPDomInfoLines.PackText:=TxnFieldList.DomInfo;
            for DomainIdx:=0 to IPDomInfoLines.Count-1 do
            begin
               IPDomInfoLine.PackText:=IPDomInfoLines[DomainIdx];
               OPDomInfoLine.Clear;
               OPDomInfoLine.Enabled:=IPDomInfoLine.Enabled;
               OPDomInfoLine.Focused:=IPDomInfoLine.Focused;
               OPDomInfoLine.DomType:=IPDomInfoLine.DomType; 
               OPDomInfoLine.Name   :=IPDomInfoLine.Name   ;
               OPDomInfoLine.Prompt :=IPDomInfoLine.Prompt ;
               OPDomInfoLine.Text   :=IPDomInfoLine.Text   ;
               IPDomInfoLines[DomainIdx]:=OPDomInfoLine.PackText;
            end;
            TxnFieldList.DomInfo:=IPDomInfoLines.PackText;
            IPDomInfoLines.Free;
            IPDomInfoLine.Free;
            OPDomInfoLine.Free;
         end
         else if (TxnFieldList.RecType = 'MOPaid') then
         begin
            TxnFieldList.DomInfo:='';
         end;                   
         TxnRecordList[RecordIdx]:=TxnFieldList.PackText;
      end;                   
   end;                   
   Result:=TxnRecordList.PackText;
   TxnFieldList.Free;
end;           
function TMessageFile.GetMessageBlock(MessageIdentifier:Integer;DeliveryType:TDeliveryType;DestinationOffice:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String;MarkAsProcessed:Boolean):TMessageAccess;
var
   MessageAccess:TMessageAccess;
   HasPensionTxn,HasMOTxn:Boolean;
begin
   MessageAccess:=TMessageAccess.Create;
   
   case MessageType of
      mtTransaction   : MessageAccess.Flags:=(Today and 1) or TransactionMsg  ;
      mtConfiguration : MessageAccess.Flags:=(Today and 1) or ConfigurationMsg;
      mtStatus        : MessageAccess.Flags:=(Today and 1) or StatusMsg       ;
      mtStock         : MessageAccess.Flags:=(Today and 1) or StockMsg        ;
      mtRegistry      : MessageAccess.Flags:=(Today and 1) or RegistryMsg     ;
      mtPension       : MessageAccess.Flags:=(Today and 1) or PensionMsg      ;
      mtMoneyOrder    : MessageAccess.Flags:=(Today and 1) or MoneyOrderMsg   ;
      mtPOBox         : MessageAccess.Flags:=(Today and 1) or POBoxMsg        ;
      mtPhil          : MessageAccess.Flags:=(Today and 1) or PhilMsg         ;
      mtUser          : MessageAccess.Flags:=(Today and 1) or UserMsg         ;
      mtMailEvent     : MessageAccess.Flags:=(Today and 1) or MailEventMsg    ;
      mtPensionTxn    : MessageAccess.Flags:=(Today and 1) or PensionMsg    or TransactionMsg ;
      mtMoneyOrderTxn : MessageAccess.Flags:=(Today and 1) or MoneyOrderMsg or TransactionMsg ;
      mtPOBoxTxn      : MessageAccess.Flags:=(Today and 1) or POBoxMsg      or TransactionMsg ;
      mtPhilTxn       : MessageAccess.Flags:=(Today and 1) or PhilMsg       or TransactionMsg ;
      else              MessageAccess.Flags:=(Today and 1)                    ;
   end;
   if MarkAsProcessed then
       MessageAccess.Flags:=MessageAccess.Flags or MessageProcessed;
       
   if MessageIdentifier > 0 then
   begin
      MessageAccess.Identifier:=MessageIdentifier;
   end
   else
   begin
      MessageAccess.Identifier:=FMaxIdentifier;   
      Inc(FMaxIdentifier);
   end;
   
   MessageAccess.Office  	       :=FIndexBlk.FOffice  	 ;
   MessageAccess.WorkStation      :=FIndexBlk.FWorkStation;
   MessageAccess.DestinationOffice:=DestinationOffice;
   MessageAccess.SendBy           :=SendBy           ;  
   MessageAccess.ExpiryDate       :=Trunc(ExpiresOn) ;
   MessageAccess.DeliveryType     :=DeliveryType     ;
   MessageAccess.MessageVersion   :=MessageVersion   ;
   MessageAccess.MessageType      :=MessageType      ;
   MessageAccess.PhysicalLayout   :=PhysicalLayout   ;
   MessageAccess.LogicalLayout    :=LogicalLayout    ;
   MessageAccess.MessageName      :=MessageName      ;
   
   if CleanTransactions and (MessageType = mtTransaction) then
      MessageData:=CleanTxns(MessageData,HasPensionTxn,HasMOTxn);
      
   if HasPensionTxn then
      MessageAccess.Flags:=MessageAccess.Flags or PensionMsg   ;
      
   if HasMOTxn then
      MessageAccess.Flags:=MessageAccess.Flags or MoneyOrderMsg;
                                          
   MessageAccess.MessageData:=MessageData;
      
   if ((CompressingData) 
   or (MessageType = mtPension)
   or (CompressLargeDataBlock and (MessageAccess.RawLength > LargeDataBlockSize)))  then
   begin
      MessageAccess.Flags:=MessageAccess.Flags or MessageCompressed;
   end;
   MessageAccess.SetCRCFromData;
   Result:=MessageAccess;
end;
function TMessageFile.AddMessage(MessageIdentifier:Integer;DeliveryType:TDeliveryType;DestinationOffice:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String;MarkAsProcessed:Boolean):TMessageAccess;
begin
   Result:=GetMessageBlock(MessageIdentifier,DeliveryType,DestinationOffice,SendBy,ExpiresOn,PhysicalLayout,LogicalLayout,MessageType,MessageVersion,MessageName,MessageData,MarkAsProcessed);
   AppendMessageBlock(Result);
end;
function TMessageFile.AppendMessage(DeliveryType:TDeliveryType;DestinationOffice:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String;MarkAsProcessed:Boolean):TMessageAccess;
begin
   Result:=AddMessage(0,DeliveryType,DestinationOffice,SendBy,ExpiresOn,PhysicalLayout,LogicalLayout,MessageType,MessageVersion,MessageName,MessageData,MarkAsProcessed);
end;
function TMessageFile.GetStatus:String;
begin
   Result:=FIndexBlk.GetStatus(FMaxIdentifier,Self);
end;  
{TAllMsgFiles}
constructor TAllMsgFiles.Create(Path:String;OfficeCode:Integer;ReadOnly:Boolean); 
var
   WS,Office,I:Integer;
   FileList:TStringList;
   FileName:String;
   Name:String;
   ValidWS:TStringList;
   ThisOffice:Integer;
   ThisWS    :Integer;
begin          
   inherited Create; 
   LastOffice     :=-1;
   LastWorkstation:=-1;
   LastMessageFile:=nil;
   LastFilePath   :='';
   FileList:=TStringList.Create;
   FFilePath:=Path;
   FillFileList(FFilePath,'*.WSD',False,FileList);
   OfficeList:=TPackStringList.Create;
   FFileList:=TStringList.Create;
   if ValidWorkstationList <> '' then
   begin
      ThisOffice:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','1000'),1000);
      ThisWS    :=StrToIntDef(GetGPCSRegString('Workstation','Ident','99'),99);
      ValidWS:=TStringList.Create;
      ValidWS.CommaText:=ValidWorkstationList;
      for I:=0 to ValidWS.Count-1 do
      begin
         if Length(ValidWS[I]) <> 6 then
         begin
            ValidWS[I]:=IntToHex(ThisOffice,4)+IntToHex(StrToIntDef(Trim(ValidWS[I]),0),2);
         end;
      end;
      if ValidWS.IndexOf(IntToHex(ThisOffice,4)+IntToHex(ThisWS,2)) = -1 then
         ValidWS.Add(IntToHex(ThisOffice,4)+IntToHex(ThisWS,2));
      for I:=250 to 255 do
         if ValidWS.IndexOf(IntToHex(ThisOffice,4)+IntToHex(I,2)) = -1 then
            ValidWS.Add(IntToHex(ThisOffice,4)+IntToHex(I,2));
      ValidWorkstationList:=ValidWS.CommaText;
      for I:=0 to FileList.Count-1 do
      begin
         if (UpperCase(ExtractFileExt(FileList[I])) = '.WSD') or (UpperCase(ExtractFileExt(FileList[I])) = 'WSD') then
         begin
            FileName:=ExtractFileName(FileList[I]);
            Office:=StrToIntDef(Copy(FileName,1,5),0);
            WS    :=StrToIntDef(Copy(FileName,6,3),0);
            Name:=IntToHex(Office,4)+IntToHex(WS,2);
            if (Office <> 0) 
            and (WS <> 0) 
            and (ValidWS.IndexOf(Name) <> -1) then
                FFileList.AddObject(Name,TMessageFile.Create(FFilePath,Office,WS,ReadOnly))
         end;
      end;
   end
   else
   begin
      for I:=0 to FileList.Count-1 do
      begin
         if (UpperCase(ExtractFileExt(FileList[I])) = '.WSD') or (UpperCase(ExtractFileExt(FileList[I])) = 'WSD') then
         begin
            FileName:=ExtractFileName(FileList[I]);
            Office:=StrToIntDef(Copy(FileName,1,5),0);
            WS    :=StrToIntDef(Copy(FileName,6,3),0);
            Name:=IntToHex(Office,4)+IntToHex(WS,2);
            if (Office <> 0) and (WS <> 0) then
                FFileList.AddObject(Name,TMessageFile.Create(FFilePath,Office,WS,ReadOnly))
         end;
      end;      
   end;
   FileList.Free;
end;
destructor TAllMsgFiles.Destroy;
begin
   while FFileList.Count > 0 do
   begin
      if FFileList.Objects[0] <> nil then
      try
         TMessageFile(FFileList.Objects[0]).Free;
      except
      end;
      FFileList.Delete(0);
   end;
   FFileList.Free;
   OfficeList.Free;
   inherited Destroy;
end;
procedure TAllMsgFiles.Flush;
var
  I:Integer;
begin
   for I:=0 to FFileList.Count-1 do
      TMessageFile(FFileList.Objects[I]).Flush;
end;
function TAllMsgFiles.MessageFile(Office,Workstation:Integer):TMessageFile;
var
   Index:Integer;
begin
   if (LastOffice = Office) and (LastWorkstation = Workstation) and (LastFilePath = FFilePath) then
   begin
     Result:=LastMessageFile;
     Exit;
   end;
   Result:=nil;
   if (Office >= 0) and (Workstation >= 0) then
   begin
      Index:=FFileList.IndexOf(IntToHex(Office,4)+IntToHex(WorkStation,2));
      if Index = -1 then
         Index:=FFileList.AddObject(IntToHex(Office,4)+IntToHex(WorkStation,2),TMessageFile.Create(FFilePath,Office,WorkStation,False));
      if Index <> -1 then
         Result:=TMessageFile(FFileList.Objects[Index]);
   end;
   LastOffice     :=Office     ;
   LastWorkstation:=Workstation;  
   LastFilePath   :=FFilePath  ;
   LastMessageFile:=Result     ;
end;
function TAllMsgFiles.ReadFileFrom(Office,Workstation:Integer;DataStream:TStream):Boolean;
begin
   try
      Result:=MessageFile(Office,Workstation).ReadFileFrom(DataStream);
   except
      Result:=False;
   end;
end;   
function TAllMsgFiles.WriteFileTo(Office,Workstation:Integer;DataStream:TStream):Boolean;
begin
   try
      Result:=MessageFile(Office,Workstation).WriteFileTo(DataStream);
   except
      Result:=False;
   end;
end;
function TAllMsgFiles.GetRawMessage(Office,WorkStation:Integer;MessageNum:Integer):TMessageAccess;
begin
   try
      Result:=MessageFile(Office,Workstation).GetRawMessage(MessageNum);
   except
      Result:=nil;
   end;
end;
function TAllMsgFiles.GetMessage(Office,WorkStation:Integer;MessageNum:Integer):TMessageAccess;
begin
   try
      Result:=MessageFile(Office,Workstation).GetMessage(MessageNum);
   except
      Result:=nil;
   end;
end;
procedure TAllMsgFiles.SetMessageFlags(Office,WorkStation:Integer;MessageNum:Integer;Value:Integer);
begin
   try
      MessageFile(Office,Workstation).SetMessageFlags(MessageNum,Value);
   except
   end;
end;
function TAllMsgFiles.GetMessageFlags(Office,WorkStation:Integer;MessageNum:Integer):Integer;
begin
   try
      Result:=MessageFile(Office,Workstation).GetMessageFlags(MessageNum);
   except
      Result:=0;
   end;
end;
function TAllMsgFiles.GetMessageSendBy(Office,WorkStation:Integer;MessageNum:Integer):TDateTime;
begin
   try
      Result:=MessageFile(Office,Workstation).GetMessageSendBy(MessageNum);
   except
      Result:=0;
   end;
end;
function TAllMsgFiles.GetMessageDestination(Office,WorkStation:Integer;MessageNum:Integer):Integer;
begin
   try
      Result:=MessageFile(Office,Workstation).GetMessageDestination(MessageNum);
   except
      Result:=0;
   end;
end;
function TAllMsgFiles.SetMessage(Value:TMessageAccess):Boolean;
begin
   try
      Result:=MessageFile(Value.Office,Value.Workstation).SetMessage(Value);
   except
      Result:=False;
   end;
end;
procedure TAllMsgFiles.UpdateMessageFlags(MessageAccess:TMessageAccess);
begin
   try
      MessageFile(MessageAccess.Office,MessageAccess.Workstation).UpdateMessageFlags(MessageAccess);
   except
   end;
end;
function TAllMsgFiles.AddMessage(Office,WorkStation,MessageIdentifier:Integer;DeliveryType:TDeliveryType;DestinationOffice:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String;MarkAsProcessed:Boolean):TMessageAccess;
begin
   try
      Result:=MessageFile(Office,Workstation).
               AddMessage(MessageIdentifier,DeliveryType,DestinationOffice,
                          SendBy,ExpiresOn,PhysicalLayout,LogicalLayout,
                          MessageType,MessageVersion,MessageName,
                          MessageData,MarkAsProcessed);
   except     
      Result:=nil;
   end;
end;
function TAllMsgFiles.AppendMessage(Office,WorkStation:Integer;DeliveryType:TDeliveryType;DestinationOffice:Integer;SendBy,ExpiresOn:TDateTime;PhysicalLayout,LogicalLayout:String;MessageType:TMessageType;MessageVersion:Integer;MessageName,MessageData:String;MarkAsProcessed:Boolean):TMessageAccess;
begin
   Result:=AddMessage(Office,WorkStation,0,
                      DeliveryType,DestinationOffice,SendBy,ExpiresOn,
                      PhysicalLayout,LogicalLayout,MessageType,
                      MessageVersion,MessageName,MessageData,
                      MarkAsProcessed);
end;
function TAllMsgFiles.GetOfficeList(OfficeRouteInfo:TParseNode):TStrings;
var
   I,J:Integer;
   Office:String;
   SL:TStringList;
   Offices:TCorvusNode;
   OfficeTitle:TCorvusNode;
   OfficeCode:TCorvusNode;
   Found:Boolean;
begin
   SL:=TStringList.Create;
   for I:=0 to FFileList.Count-1 do
   begin
      Office:=Copy(FFileList[I],1,4);
      if SL.IndexOf(Office) = -1 then
         SL.AddObject(Office,TObject(StrToIntDef('$'+Office,0)));
   end;
   OfficeList.Clear;
   OfficeList.AddObject('All Offices',TObject(0));
   Offices:=OfficeRouteInfo.NodeNamed('OfficesRoutes');
   if Offices <> nil then
   begin
      Offices:=Offices.NodeNamed('Offices');
      if Offices <> nil then
      begin
         for I:=0 to SL.Count-1 do
         begin
            Found:=False;
            for J:=0 to Offices.Count-1 do
            begin
               OfficeCode:=Offices.Node[J].NodeNamed('Code');
               if OfficeCode <> nil then
               begin
                  if StrToIntDef(OfficeCode[0],0) = Integer(SL.Objects[I]) then
                  begin
                     OfficeTitle:=Offices.Node[J].NodeNamed('Title');
                     if OfficeTitle <> nil then
                     begin
                        OfficeList.AddObject(OfficeTitle[0],SL.Objects[I]);
                        Found:=True;
                     end;
                  end;
               end;
            end;
            if not Found then
            begin
               OfficeList.AddObject('Office '+IntToStr(Integer(SL.Objects[I])),SL.Objects[I]);
            end;
         end;
      end;
   end;
   Result:=OfficeList;
   SL.Free;
end;
function TAllMsgFiles.GetStatus:String;
var
   StatusBits:TStatusBits;
   Off,I,WS:Integer;
   Bits:TBBits;
begin
   Bits:=TBBits.Create;
   StatusBits:=TStatusBits.Create;
   for I:=0 to FFileList.Count-1 do
   begin
      Off:=StrToIntDef('$'+Copy(FFileList[I],1,4),0);
      WS:=StrToIntDef('$'+Copy(FFileList[I],5,2),0);
      Bits.AsString:=TMessageFile(FFileList.Objects[I]).GetStatus;
      StatusBits.Bits[Off,WS]:=Bits;
   end;
   Bits.Free;
   Result:=StatusBits.State;
   StatusBits.Free;
end;

function Today:Integer;
begin
   Result:=(Trunc(Now)-DaysUntil_010198);
end;

end.
