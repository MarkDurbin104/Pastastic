unit ShirikaU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,FileCtrl,CRC32,Compress,PackStrListU,StringWrapperU;
  
const
   DaysUntil_010198 = 35796;
   MessageDir = 'E:\Messages';
   MaxBlockSize = 1000;
   MsgProcessed = 2;
   MaxQueueThreshold     = 200;
   RestoreQueueThreshold = MaxQueueThreshold/2;
   
   
   
   // Destination 1-65500 = Destination Office Code (via Root and each Intermediary node)
   DestThisWorkstationOnly = 65501; // This Workstation only
   DestThisPeerGroupOnly   = 65502; // This Peer group only
   DestThisOfficeOnly      = 65503; // This Office only (repeated to all peer groups in office)
   DestThisPGnAP           = 65504; // This Peer group and all parents
   DestThisPGnAPR          = 65505; // This Peer group, all parents + Regions
   DestThisPGnAPRZ         = 65506; // This Peer group, all parents + Regions + Zones
   DestThisPGnAPRZB        = 65507; // This Peer group, all parents + Regions + Zones + Branches
   DestThisPGnAllOther     = 65508; // This Peer group and All other Offices
   DestThisOFnAP           = 65509; // This Office and all parents
   DestThisOFnAPR          = 65510; // This Office, all parents + Regions
   DestThisOFnAPRZ         = 65511; // This Office, all parents + Regions + Zones
   DestThisOFnAPRZB        = 65512; // This Office, all parents + Regions + Zones + Branches
   DestThisOFnAllOther     = 65513; // This Office and All other Offices
  
type
  // 2 cust sessions per minute for 10 hours = 2*60*10 = 1200 txns per day per WS
  // 1 year with 6 day week and 12 days holiday = ((52*6)-12) = 300 days
  // with one cust session per block, 2147483648/(300*1200)= blocks = 6000 years
  // 1024*2147483648 = 2 Tera bytes
  // 1 Days data  =     1200*1024=  1228800 = 1.1 Mega bytes per WS
  // 1 Weeks data =   6*1200*1024= 29491200 =   7 Mega bytes per WS
  // 1 years data = 300*1200*1024=368640000 = 350 Mega bytes per WS
  // if Average office = 4 WS
  // 1 Days data  = 4*    1200*1024=   4915200 =   5 Mega bytes per Office/Day
  // 1 Weeks data = 4*  6*1200*1024=  29491200 =  24 Mega bytes per Office/Week
  // 1 years data = 4*300*1200*1024=1474560000 = 1.4 Giga bytes per Office/Year
  
  
  TFBRec = packed record 
     BlockNum   :Integer;                          //     4      - 0-4294967295 
     MessageNum  :Integer;                          // +   4=   8 - 0-4294967295
     SubMsgIdx  :Word   ;                          // +   2=  10 - 0-65535
     ExpDate    :Word   ;                          // +   2=  12 - 01/01/1998 - 20/07/2177
     Destination:Word   ;                          // +   2=  14 - 0-65535 
     DataLen    :Word   ;                          // +   2=  16 - 0-1000
     Data       :Array[0..MaxBlockSize-1] of Byte; // +1000=1016 - [1000]
     WorkStation:Byte   ;                          // +   1=1017 - 0-255
     Office     :Word   ;                          // +   2=1019 - 0-65000
     CRC        :Integer;                          // +   4=1023 - 00000000-FFFFFFFF 
     Flags      :Byte   ;                          // +   1=1024 
  end;
                                                   // bit 0 = Send Date mod 2 (only accept messages sent today)
                                                   // bit 1 = processed
                                                   // bit 2 = 
                                                   // bit 3 = 
                                                   // bit 4 = 
                                                   // bit 5 = 
                                                   // bit 6 = 
                                                   // bit 7 = 
  TWSMaxMsg = class(TStringWrapper)
  public
     property WSNumber     :Variant Index 0 read GetElement write SetElement;
     property MaxMessageNo :Variant Index 1 read GetElement write SetElement;
  end;
  TWSMaxMsgList = class(T2DStringWrapper)
    protected
       function GetElement(Index:Integer):TWSMaxMsg;
    public                                                       
       property Element[Index:Integer]:TWSMaxMsg read GetElement; default;
  end;                                     
  
  TWSBits = class(TStringWrapper)
  public
     property WSNumber  :Variant Index 0 read GetElement write SetElement;
     property RLEBitmap :Variant Index 1 read GetElement write SetElement;
  end;
  TWSBitsList = class(T2DStringWrapper)
    protected
       function GetElement(Index:Integer):TWSBits;
    public                                                       
       property Element[Index:Integer]:TWSBits read GetElement; default;
  end;                                     
  TFileBlock = class(TObject)
  private
     FFBRec:TFBRec;
     function  GetBlockNum   :Integer ;
     function  GetSubMsgIdx  :Integer ;
     function  GetMessageNum  :Word    ;
     function  GetExpDate    :Word    ;
     function  GetDestination:Word    ;
     function  GetData       :String  ;
     function  GetWorkStation:Byte    ;
     function  GetOffice     :Word    ;
     function  GetCRC        :Integer ;
     function  GetFlags      :Byte    ;
     procedure SetBlockNum   (Value:Integer );
     procedure SetSubMsgIdx  (Value:Integer );
     procedure SetMessageNum  (Value:Word    );
     procedure SetExpDate    (Value:Word    );
     procedure SetDestination(Value:Word    );
     procedure SetData       (Value:String  );
     procedure SetWorkStation(Value:Byte    );
     procedure SetOffice     (Value:Word    );
     procedure SetCRC        (Value:Integer );
     procedure SetFlags      (Value:Byte    );
  public
     constructor Create;
     procedure SetCRCFromData;
     function GoodCRC:Boolean;
     function LoadFromStream(S:TStream):Boolean;
     function SaveToStream(S:TStream):Boolean;
     property BlockNum   :Integer  read GetBlockNum    write SetBlockNum   ;
     property SubMsgIdx  :Integer  read GetSubMsgIdx   write SetSubMsgIdx  ;
     property MessageNum  :Word     read GetMessageNum   write SetMessageNum  ;
     property ExpDate    :Word     read GetExpDate     write SetExpDate    ;
     property Destination:Word     read GetDestination write SetDestination;
     property Data       :String   read GetData        write SetData       ;
     property WorkStation:Byte     read GetWorkStation write SetWorkStation;
     property Office     :Word     read GetOffice      write SetOffice     ;
     property CRC        :Integer  read GetCRC         write SetCRC        ;
     property Flags      :Byte     read GetFlags       write SetFlags      ;
  end;                    
  TFileBlockMgr = class(TObject)
  private
  public
     function GetWSFileStream(Office,WorkStation:Integer;ReadOnly:Boolean):TFileStream;
     function GetBlock(Office,WorkStation:Integer;BlockNum:Integer):TFileBlock;
     function GetBlockCount(Office,WorkStation:Integer):Integer;
     function SetBlock(Value:TFileBlock):Boolean;
     function AppendBlock(Value:TFileBlock;S:TStream):Boolean;
     function AppendMessage(Office,WorkStation,Destination,ExpDate:Integer;Value:String;S:TStream):Boolean;
     function GetLastMsgNo(Office,WorkStation:Integer;S:TStream):Integer;
     function GetBitmaps(Office:Integer):TWSBitsList;
     function GetCurrentState(Office:Integer):TWSMaxMsgList;
     
     function AddState(Office:Integer;CurrentState,NewState:TWSMaxMsgList):TWSMaxMsgList;
     function FindMissing(Office:Integer;CurrentBitmap,Bitmap:TWSBitsList):TWSBitsList;
     function FindCommon(Office:Integer;CurrentBitmap,Bitmap:TWSBitsList):TWSBitsList;
     function FindDifference(Office:Integer;AState:TWSMaxMsgList;Bitmap:TWSBitsList):TWSBitsList;
     function MergeInBits(OrigBits,NewBits:TWSBitsList):TWSBitsList;
     function ExcludeBits(OrigBits,NewBits:TWSBitsList):TWSBitsList;
     procedure ClearBit(var Bits:TWSBitsList;WorkStation,BlockNumb:Integer);
     
  end;             
  TBBits = class(TBits)
  private
      function GetBit(Index:Integer):Boolean;
      procedure SetBit(Index:Integer;Value:Boolean);
      function GetRLEBits:String;
      procedure SetRLEBits(Value:String);
  public
      function Missing(UpTo:Integer):String;
      function Included(RLE:String):String;
      function Excluded(RLE:String):String;
      property Bits[Index:Integer]:Boolean read GetBit write SetBit; default;
      property AsString:String read GetRLEBits write SetRLEBits;
  end;

function Today:Integer;

implementation         

function Today:Integer;
begin
   Result:=Trunc(Now)-DaysUntil_010198;
end;

{TWSMaxMsgList}
function TWSMaxMsgList.GetElement(Index:Integer):TWSMaxMsg; 
begin 
   Result:=TWSMaxMsg(inherited GetElement(Index)); 
end;
{TWSBitsList}
function TWSBitsList.GetElement(Index:Integer):TWSBits; 
begin 
   Result:=TWSBits(inherited GetElement(Index)); 
end;

{TFileBlock}
constructor TFileBlock.Create;
begin
   inherited Create;
   ZeroMemory(@FFBRec,SizeOf(FFBRec));
end;
function TFileBlock.GoodCRC:Boolean;
begin
   Result:=FFBRec.CRC=CRC32.CalcMemCCITTCRC(@FFBRec,SizeOf(FFBRec)-(SizeOf(Integer )+SizeOf(Byte))); 
end;                                              
procedure TFileBlock.SetCRCFromData;
begin
   // calc CRC, ignoring CRC and Flags
   FFBRec.CRC:=CRC32.CalcMemCCITTCRC(@FFBRec,SizeOf(FFBRec)-(SizeOf(Integer )+SizeOf(Byte))); 
end;                                              
function TFileBlock.GetBlockNum:Integer;
begin
   Result:=FFBRec.BlockNum;
end;
function TFileBlock.GetSubMsgIdx:Integer;
begin
   Result:=FFBRec.SubMsgIdx;
end;
function TFileBlock.GetMessageNum:Word;
begin
   Result:=FFBRec.MessageNum;
end;
function TFileBlock.GetExpDate:Word;
begin
   Result:=FFBRec.ExpDate;
end;
function TFileBlock.GetData:String;
begin
   SetLength(Result,FFBRec.DataLen);
   CopyMemory(PChar(Result),@(FFBRec.Data),FFBRec.DataLen);
end;
function TFileBlock.GetCRC:Integer;
begin
   Result:=FFBRec.CRC;
end;
function TFileBlock.GetFlags:Byte;
begin
   Result:=FFBRec.Flags;
end;
function TFileBlock.GetDestination:Word;
begin
   Result:=FFBRec.Destination;
end;
function TFileBlock.GetWorkStation:Byte;
begin
   Result:=FFBRec.WorkStation;
end;
function TFileBlock.GetOffice:Word;
begin
   Result:=FFBRec.Office;
end;
procedure TFileBlock.SetBlockNum(Value:Integer);
begin
   FFBRec.BlockNum:=Value;
end;
procedure TFileBlock.SetSubMsgIdx(Value:Integer);
begin
   FFBRec.SubMsgIdx:=Value;
end;
procedure TFileBlock.SetMessageNum(Value:Word);
begin
   FFBRec.MessageNum:=Value;
end;
procedure TFileBlock.SetExpDate(Value:Word);
begin
   FFBRec.ExpDate:=Value;
end;
procedure TFileBlock.SetData(Value:String);
begin
   FFBRec.DataLen:=Length(Value);
   if FFBRec.DataLen > 1000 then
      FFBRec.DataLen:=1000;
   CopyMemory(@(FFBRec.Data),PChar(Value),FFBRec.DataLen);
end;
procedure TFileBlock.SetCRC(Value:Integer);
begin
   FFBRec.CRC:=Value;
end;
procedure TFileBlock.SetFlags(Value:Byte);
begin
   FFBRec.Flags:=Value;
end;
procedure TFileBlock.SetDestination(Value:Word);
begin
   FFBRec.Destination:=Value;
end;
procedure TFileBlock.SetWorkStation(Value:Byte);
begin
   FFBRec.WorkStation:=Value;
end;
procedure TFileBlock.SetOffice(Value:Word);
begin
   FFBRec.Office:=Value;
end;
function TFileBlock.LoadFromStream(S:TStream):Boolean;
begin
   Result:=False;
   try
      if S.Read(FFBRec,SizeOf(FFBRec)) = SizeOf(FFBRec) then
         Result:=True;
   except
   end;
end;
function TFileBlock.SaveToStream(S:TStream):Boolean;
begin
   Result:=False;
   try
      if S.Write(FFBRec,SizeOf(FFBRec)) = SizeOf(FFBRec) then
         Result:=True;
   except
   end;
end;                              
{TFileBlockMgr}
function TFileBlockMgr.GetWSFileStream(Office,WorkStation:Integer;ReadOnly:Boolean):TFileStream;
var
   FileName:String;                           
begin
   FileName:=MessageDir;
   if not DirectoryExists(FileName) then
      ForceDirectories(FileName);
   FileName:=FileName+'\M'+IntToHex(Office,4)+'_'+IntToHex(WorkStation,2)+'.WSD';
   if ReadOnly then
   begin
      if FileExists(FileName) then
         Result:=TFileStream.Create(Filename,fmOpenRead or fmShareDenyNone)
      else
         Result:=nil;
   end
   else
   begin
      if not FileExists(FileName) then
         Result:=TFileStream.Create(Filename,fmCreate or fmShareDenyWrite)
      else
         Result:=TFileStream.Create(Filename,fmOpenReadWrite or fmShareDenyWrite);
   end;
end;
function TFileBlockMgr.GetBlock(Office,WorkStation:Integer;BlockNum:Integer ):TFileBlock;
var
   S:TStream;
begin
   Result:=nil;
   try
      S:=GetWSFileStream(Office,WorkStation,True);
      if S <> nil then
      begin
         if S.Size > (BlockNum*SizeOf(TFBRec)) then
         begin
            S.Position:=BlockNum*SizeOf(TFBRec);
            Result:=TFileBlock.Create;
            if (Result.LoadFromStream(S)) and (Result.GoodCRC) then
               Exit
            else
               Result.Blocknum:=-1;
         end;
         S.Free;
      end;
   except
   end;
end;
function TFileBlockMgr.GetBlockCount(Office,WorkStation:Integer):Integer;
var
   S:TStream;
begin 
   Result:=0;
   try
      S:=GetWSFileStream(Office,WorkStation,True);
      if S <> nil then
      begin
         Result:=S.Size div SizeOf(TFBRec);
         S.Free;
      end;
   except;
   end;
end;
function TFileBlockMgr.SetBlock(Value:TFileBlock):Boolean;
var
   S:TStream;
   EmptyBlock:TFileBlock;
begin
   Result:=False;
   try
      S:=GetWSFileStream(Value.Office,Value.WorkStation,False);
      if S <> nil then
      begin
         S.Position:=S.Size;
         if S.Position < Value.BlockNum*SizeOf(TFBRec) then // need to add empty blocks
         begin
            EmptyBlock:=TFileBlock.Create;
            EmptyBlock.BlockNum:=-1;
            while S.Position < Value.BlockNum*SizeOf(TFBRec) do
               EmptyBlock.SaveToStream(S);
            EmptyBlock.Free;
         end;
         S.Position:=Value.BlockNum*SizeOf(TFBRec);
         Value.SetCRCFromData;
         Result:=Value.SaveToStream(S);
         S.Free;
      end;
   except
   end;
end;
function TFileBlockMgr.AppendBlock(Value:TFileBlock;S:TStream):Boolean;
var
  CreateStream:Boolean;
begin                 
   CreateStream:=False;
   Result:=False;
   try
      if S = nil then
      begin
         CreateStream:=True;
         S:=GetWSFileStream(Value.Office,Value.WorkStation,False);
      end;
      if S <> nil then
      begin
         Value.BlockNum:=S.Size div SizeOf(TFBRec);
         S.Position:=Value.BlockNum*SizeOf(TFBRec);
         Value.SetCRCFromData;
         Result:=Value.SaveToStream(S);
         if CreateStream then S.Free;
      end;
   except
   end;
end;
function TFileBlockMgr.GetLastMsgNo(Office,WorkStation:Integer;S:TStream):Integer;
var
   Block:TFileBlock;
   StreamPassed:Boolean;
begin        
   Result:=-1;
   StreamPassed:=False;
   if S = nil then       
      S:=GetWSFileStream(Office,WorkStation,True)
   else
      StreamPassed:=True;
   if S = nil then Exit;
   
   Block:=TFileBlock.Create;
   if S.Size > SizeOf(TFBRec) then
   begin
      S.Position:=S.Size-SizeOf(TFBRec);
      Block.LoadFromStream(S);
      Result:=Block.GetMessageNum;
   end;
   Block.Free;
   
   if not StreamPassed then S.Free;
end;     
function TFileBlockMgr.AppendMessage(Office,WorkStation,Destination,ExpDate:Integer;Value:String;S:TStream):Boolean;
var
   Block:TFileBlock;
   CV:String;
   BOfs:Integer;
   Index:Integer;
   MaxMsgNo:Integer;
   StreamPassed:Boolean;
begin  
   StreamPassed:=False;
   Result:=False;
   try
      CV:=TCompressor.CompressString(Value);
      if Length(CV) < Length(Value) then
         Value:='C'+CV
      else
         Value:='U'+Value;
      BOfs:=0;
      Index:=0;
      if S = nil then       
         S:=GetWSFileStream(Office,WorkStation,False)
      else
         StreamPassed:=True;
      MaxMsgNo:=GetLastMsgNo(Office,WorkStation,S);
      Inc(MaxMsgNo);
      if S = nil then Exit;
      while BOfs < Length(Value) do
      begin
         Block:=TFileBlock.Create;
         Block.BlockNum   :=0;
         Block.MessageNum  :=MaxMsgNo;
         Block.SubMsgIdx  :=Index;
         Block.ExpDate    :=ExpDate;
         Block.Destination:=Destination;
         Block.Data       :=Copy(Value,BOfs,MaxBlockSize);
         Block.WorkStation:=WorkStation;
         Block.Office     :=Office;
         Block.Flags      :=Today mod 2;
         Inc(BOfs,MaxBlockSize);
         Inc(Index);
         if not AppendBlock(Block,S) then Exit;
         Block.Free;
      end;
      if not StreamPassed then S.Free;
   except
      Exit;
   end;
   Result:=True;
end;
function TFileBlockMgr.GetBitmaps(Office:Integer):TWSBitsList;
var
   WS:Integer;
   S:TStream;
   BlockPos:Integer;
   Block:TFileBlock;
   Bits:TBBits;
begin
   Result:=TWSBitsList.Create;
   Block:=TFileBlock.Create;
   for WS:=1 to 255 do
   begin
      S:=GetWSFileStream(Office,WS,True);
      if S <> nil then
      begin
         Bits:=TBBits.Create;
         BlockPos:=0;
         while S.Position < S.Size do
         begin
            Block.LoadFromStream(S);
            if Block.BlockNum = BlockPos then
               Bits[BlockPos]:=True;
            Inc(BlockPos);
         end;
         Result.Add(#2+IntToStr(WS)+#2+Bits.AsString);
         Bits.Free;
         S.Free;
      end;
   end;
   Block.Free;
end;
function TFileBlockMgr.AddState(Office:Integer;CurrentState,NewState:TWSMaxMsgList):TWSMaxMsgList;
var
   I,J:Integer;
   Found:Boolean;
begin
   Result:=TWSMaxMsgList.Create;
   Result.PackText:=CurrentState.PackText;
   for I:=0 to CurrentState.Count-1 do
   begin                
      for J:=0 to NewState.Count-1 do
      begin
         if  (CurrentState[I].WSNumber = NewState[J].WSNumber) 
         and (Integer(NewState[J].MaxMessageNo) > CurrentState[I].MaxMessageNo) then
         begin
            Result.Put(I,#1+NewState[J].WSNumber+#1+NewState[J].MaxMessageNo);
            break;
         end;
      end;
   end;
   for J:=0 to NewState.Count-1 do
   begin                
      Found:=False;
      for I:=0 to CurrentState.Count-1 do
      begin
         if (CurrentState[I].WSNumber = NewState[J].WSNumber) then
         begin
            Found:=True;
            break;
         end;
      end;
      if not Found then
         Result.Add(#1+NewState[J].WSNumber+#1+NewState[J].MaxMessageNo);
   end;
end;
function TFileBlockMgr.MergeInBits(OrigBits,NewBits:TWSBitsList):TWSBitsList;
var
   OriBitmap:TBBits;
   NewBitmap:TBBits;
   Found:Boolean;
   I,J,K:Integer;
begin
   Result:=TWSBitsList.Create;
   for I:=0 to OrigBits.Count-1 do
   begin
      OriBitmap:=TBBits.Create;
      OriBitmap.AsString:=OrigBits[I].RLEBitmap;
      for J:=0 to NewBits.Count-1 do
      begin
         if OrigBits[I].WSNumber = NewBits[J].WSNumber then
         begin
            NewBitmap:=TBBits.Create;
            NewBitmap.AsString:=NewBits[J].RLEBitmap;
            for K:=0 to NewBitmap.Size-1 do
            begin
               if NewBitmap[K] then
                  OriBitmap[K]:=True;
            end;
            OrigBits.Strings[I]:=#2+OrigBits[I].WSNumber+#2+OriBitmap.AsString;
            NewBitmap.Free;
            break;
         end;    
      end;
      OriBitmap.Free;
   end;   
   for J:=0 to NewBits.Count-1 do
   begin
      Found:=False;
      for I:=0 to OrigBits.Count-1 do
      begin
         if OrigBits[I].WSNumber = NewBits[J].WSNumber then
         begin
            Found:=True;
            break;
         end;
      end;
      if not Found then
         OrigBits.Add(NewBits.Strings[J]);
   end;
   Result.PackText:=OrigBits.PackText;
end;
procedure TFileBlockMgr.ClearBit(var Bits:TWSBitsList;WorkStation,BlockNumb:Integer);
var
   I:Integer;
   BB:TBBits;
begin
   for I:=0 to Bits.Count-1 do
   begin
      if Bits[I].WSNumber = WorkStation then
      begin
         BB:=TBBits.Create;
         BB.AsString:=Bits[I].RLEBitmap;
         BB[BlockNumb]:=False;
         Bits.Strings[I]:=#2+Bits[I].WSNumber+#2+BB.AsString;
         BB.Free;
         break;
      end;
   end;
end;
function TFileBlockMgr.ExcludeBits(OrigBits,NewBits:TWSBitsList):TWSBitsList;
var
   OriBitmap:TBBits;
   NewBitmap:TBBits;
   I,J,K:Integer;
begin
   Result:=TWSBitsList.Create;
   for J:=0 to NewBits.Count-1 do // require from other machines
   begin
      NewBitmap:=TBBits.Create;
      NewBitmap.AsString:=NewBits[J].RLEBitmap;
      for I:=0 to OrigBits.Count-1 do // already being supplied by other machines
      begin
         if OrigBits[I].WSNumber = NewBits[J].WSNumber then
         begin
            OriBitmap:=TBBits.Create;
            OriBitmap.AsString:=OrigBits[I].RLEBitmap;
            for K:=0 to OriBitmap.Size-1 do
            begin
               if OriBitmap[K] then
                  NewBitmap[K]:=False
            end;
            NewBits.Strings[I]:=#2+NewBits[J].WSNumber+#2+NewBitmap.AsString;
            OriBitmap.Free;
            break;
         end;    
      end;
      NewBitmap.Free;
   end;   
   Result.PackText:=NewBits.PackText;
end;
function TFileBlockMgr.FindMissing(Office:Integer;CurrentBitmap,Bitmap:TWSBitsList):TWSBitsList;
var
   I,J:Integer;
   Bits:TBBits;
   S:String;
begin
   // find what is in bitmap that is not in CurrentBitmap
   Result:=TWSBitsList.Create;
   if CurrentBitmap.Count > 0 then
   begin
      for I:=0 to CurrentBitmap.Count-1 do
      begin                
         for J:=0 to Bitmap.Count-1 do
         begin
            if (CurrentBitmap[I].WSNumber = Bitmap[J].WSNumber) then
            begin
               Bits:=TBBits.Create;
               Bits.AsString:=CurrentBitmap[J].RLEBitmap;
               S:=Bits.Excluded(Bitmap[I].RLEBitmap); // if its in both then clear it
               Bits.Free;
               Result.Add(#2+CurrentBitmap[I].WSNumber+#2+S);
            end;
         end;
      end;
   end
   else
      Result.PackText:=Bitmap.PackText;
end;
function TFileBlockMgr.FindCommon(Office:Integer;CurrentBitmap,Bitmap:TWSBitsList):TWSBitsList;
var
   I,J:Integer;
   Bits:TBBits;
   S:String;
begin
   Result:=TWSBitsList.Create;
   for I:=0 to CurrentBitmap.Count-1 do
   begin                
      if Bitmap.Count > 0 then
      begin
         for J:=0 to Bitmap.Count-1 do
         begin
            if (CurrentBitmap[I].WSNumber = Bitmap[J].WSNumber) then
            begin
               Bits:=TBBits.Create;
               Bits.AsString:=Bitmap[J].RLEBitmap;
               S:=Bits.Included(CurrentBitmap[I].RLEBitmap);
               Bits.Free;
               if S <> '' then
                  Result.Add(#2+CurrentBitmap[I].WSNumber+#2+S);
            end;
         end;
      end;
   end;
end;
function TFileBlockMgr.FindDifference(Office:Integer;AState:TWSMaxMsgList;Bitmap:TWSBitsList):TWSBitsList;
var
   I,J:Integer;
   Bits:TBBits;
   S:String;
begin
   Result:=TWSBitsList.Create;
//   if AState.Count = 0 then
//     Result.PackText:=Bitmap.PackText;
   for I:=0 to AState.Count-1 do
   begin                
      if Bitmap.Count > 0 then
      begin
         for J:=0 to Bitmap.Count-1 do
         begin
            if  (AState[I].WSNumber = Bitmap[J].WSNumber) then
            begin
               Bits:=TBBits.Create;
               Bits.AsString:=Bitmap[J].RLEBitmap;
               S:=Bits.Missing(AState[I].MaxMessageNo);
               Bits.Free;
               if S <> '' then
                  Result.Add(#2+AState[I].WSNumber+#2+S);
            end;
         end;
      end
      else
      begin
         Bits:=TBBits.Create;
         S:=Bits.Missing(AState[I].MaxMessageNo);
         Bits.Free;
         if S <> '' then
            Result.Add(#2+AState[I].WSNumber+#2+S);
      end;
   end;
end;
function TFileBlockMgr.GetCurrentState(Office:Integer):TWSMaxMsgList;
var
   WS:Integer;
   S:TStream;
   BlockPos:Integer;
   Block:TFileBlock;
begin
   Result:=TWSMaxMsgList.Create;
   Block:=TFileBlock.Create;
   for WS:=1 to 255 do
   begin
      S:=GetWSFileStream(Office,WS,True);
      if S <> nil then
      begin
         BlockPos:=0;
         if S.Size > SizeOf(TFBRec) then
         begin
            S.Position:=S.Size-SizeOf(TFBRec);
            Block.LoadFromStream(S);
            BlockPos:=Block.BlockNum;
         end;
         Result.Add(#1+IntToStr(WS)+#1+IntToStr(BlockPos));
         S.Free;
      end;
   end;
   Block.Free;
end;

{TBBits}
function TBBits.GetBit(Index:Integer):Boolean;
begin
  if (Index >= 0) and (Index < Size) then
    Result:=inherited Bits[Index]
  else
    Result:=False;
end;

procedure TBBits.SetBit(Index:Integer;Value:Boolean);
begin
  if (Index >= 0) then
    inherited Bits[Index]:=Value;
end;

function TBBits.GetRLEBits:String;
var
   I:Integer;
   RL:Integer;
   State:Boolean;
   RSL:TPackStringList;
begin
   Result:='';
   if Size = 0 then Exit;
   RSL:=TPackStringList.Create;
   State:=Bits[0];
   if State then RSL.Add('0');
   RL:=0;
   for I:=0 to Size-1 do
   begin
      if Bits[I] = State then
      begin
         Inc(RL)
      end
      else
      begin
         RSL.Add(IntToStr(RL));
         RL:=1;
         State:=not State;
      end;
   end;
   RSL.Add(IntToStr(RL));
   Result:=RSL.PackText;
   RSL.Free;
end;
procedure TBBits.SetRLEBits(Value:String);
var
  SL:TPackStringList;
  I:Integer;
  State:Boolean;
  RL:Integer;
  CurrentOfs:Integer;
begin
  if Value = '' then Exit;
  SL:=TPackStringList.Create;
  SL.PackText:=Value;
  Size:=0; // this doesn't clear the associated memory
  if SL.Count > 0 then
  begin
     State:=True;
     CurrentOfs:=StrToIntDef(SL[0],0);
     for I:=1 to SL.Count-1 do
     begin
        RL:=StrToIntDef(SL[I],0);
        if State then
        begin
           while RL > 0 do
           begin
              Bits[CurrentOfs]:=True;
              Inc(CurrentOfs);
              Dec(RL);
           end;
        end
        else
        begin
           while RL > 0 do
           begin
              Bits[CurrentOfs]:=False;
              Inc(CurrentOfs);
              Dec(RL);
           end;
//           Inc(CurrentOfs,RL);
        end;
        State:=not State;
     end;
  end;
  SL.Free;
end;
function TBBits.Included(RLE:String):String;
var
   MB:TBBits;
   I:Integer;
begin
   // if its not in both then clear it
   MB:=TBBits.Create;
   MB.AsString:=RLE;
   for I:=0 to MB.Size-1 do
      if not (Bits[I] and MB[I]) then MB[I]:=False;
   Result:=MB.AsString;
   MB.Free;
end;
function TBBits.Excluded(RLE:String):String;
var
   MB:TBBits;
   I:Integer;
begin
   // if its in both then clear it
   MB:=TBBits.Create;
   MB.AsString:=RLE;
   for I:=0 to MB.Size-1 do
      if (Bits[I] and MB[I]) then MB[I]:=False;
   Result:=MB.AsString;
   MB.Free;
end;

function TBBits.Missing(UpTo:Integer):String;
var
   MB:TBBits;
   I:Integer;
begin
   // negative bitmap
   MB:=TBBits.Create;
   for I:=0 to UpTo do
      if not Bits[I] then MB[I]:=True;
   Result:=MB.AsString;
   MB.Free;
end;
end.
 