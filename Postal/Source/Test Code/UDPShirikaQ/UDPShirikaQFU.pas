unit UDPShirikaQFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,ShirikaU,UDPSocketU, ExtCtrls,GPCSGUID;
  
const
   MaxBlocksInOneDGram = 32;
   
type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    OfficeCode: TEdit;
    WSNumber: TEdit;
    Timer1: TTimer;
    Panel2: TPanel;
    Memo2: TMemo;
    Splitter1: TSplitter;
    StatusList: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StatusListMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure StatusListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
     UDP:TUDP;
     IgnoreAllMessages:Boolean;
     CurrentState :TWSMaxMsgList;
     RequiredState:TWSMaxMsgList;
//     BitsHere     :TWSBitsList;
//     BitsAll      :TWSBitsList;
     BitsRequested:TWSBitsList;
     BitsProposed :TWSBitsList;
     BitsAccepted :TWSBitsList;
//     BitsSent     :TWSBitsList;
     TxList       :TList;
     procedure UpdateStatus(S:String);
     procedure RxDGram(Sender:TUDP;From,Data:String);
     procedure DGramError(Sender:TUDP;EMessage:String);
     
     procedure CheckQueue;
     procedure CheckReqired;
     
     procedure SendStatement;
     procedure SendRFP;
     procedure SendProposal;
     procedure SendAccept;
     
     procedure ProcessStatement(S:String);
     procedure ProcessRFP(S:String);
     procedure ProcessProp(S:String);
     procedure ProcessAccept(S:String);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
   FileBlockMgr:TFileBlockMgr;
   WS,Off,Day,Txn:Integer;
   S:TStream;
begin               
   FileBlockMgr:=TFileBlockMgr.Create;
   for Day:=1 to 1 do
   begin
      Memo2.Lines.Add(FormatDateTime('tt',Now));
      for Off:=3201 to 3201 do
      begin
         for WS:=1 to 4 do
         begin
//            S:=FileBlockMgr.GetWSFileStream(Off,WS,False);
            S:=nil;
            for Txn:=1 to 1200 do
               FileBlockMgr.AppendMessage(Off,WS,DestThisPGnAP,Today+30,'This is Message '+IntToStr(Txn),S);
//            S.Free;
            Application.ProcessMessages;
            if Application.Terminated then Exit;
         end;
      end;
   end;
   Memo2.Lines.Add(FormatDateTime('tt',Now));
   FileBlockMgr.Free;  
   SendStatement;
end;        

procedure TForm1.Button2Click(Sender: TObject);
var
   FileBlockMgr:TFileBlockMgr;
   Off:Integer;
   CS:TWSMaxMsgList;
   CB,CD:TWSBitsList;
begin
   FileBlockMgr:=TFileBlockMgr.Create;
   Memo2.Lines.Add('Start '+FormatDateTime('tt',Now));
   for Off:=1 to 10 do
   begin
      CS:=FileBlockMgr.GetCurrentState(Off);
      CB:=FileBlockMgr.GetBitmaps(Off);
      CD:=FileBlockMgr.FindDifference(Off,CS,CB);
      if CS.PackText <> '' then
        Memo2.Lines.Add('OF '+IntToStr(Off)+' '+CS.PackText+' '+CB.PackText+' ['+CD.PackText+']');
      CB.Free;
      CD.Free;
      CS.Free;
   end;
   Memo2.Lines.Add('End '+FormatDateTime('tt',Now));
   FileBlockMgr.Free;
end;
function GetString(S:TStream;Len:Integer):String;
begin
   SetLength(Result,Len);
   S.Read(PChar(Result)^,Len);
end;
procedure PutString(S:TStream;Str:String);
begin
   S.Write(PChar(Str)^,Length(Str));
end;
procedure TForm1.Timer1Timer(Sender: TObject);
const
   CallCount:Integer = 0;
begin                     
   if UDP <> nil then 
   begin
     if (CallCount mod 3) = 0 then
        SendStatement;
     Inc(CallCount);
     CheckQueue;
   end;
end;
procedure TForm1.CheckQueue;
var
   SS:TStringStream;
   S:String;
   Block:TFileBlock;
   FileBlockMgr:TFileBlockMgr;
begin
   if TxList.Count >= MaxQueueThreshold then
      IgnoreAllMessages:=True;
   if IgnoreAllMessages and (TxList.Count < RestoreQueueThreshold) then
      IgnoreAllMessages:=False;
   while TxList.Count > 0 do
   begin
      if (TxList[0] <> nil) and (TFileBlock(TxList[0]) is TFileBlock) then
      begin
         SS:=TStringStream.Create('SHIRIKAQB');
         SS.Position:=SS.Size;
         Block:=TFileBlock(TxList[0]);
         Block.SaveToStream(SS);
         PutString(SS,'E');
         S:=SS.DataString;
         SS.Free;
         if UDP.SendDGram(S) then
         begin
            Memo2.Lines.Add('Actual Send '+IntToStr(Block.WorkStation)+' '+IntToStr(Block.BlockNum));
            FileBlockMgr:=TFileBlockMgr.Create;     
            FileBlockMgr.ClearBit(BitsRequested,Block.WorkStation,Block.BlockNum);
            FileBlockMgr.ClearBit(BitsProposed ,Block.WorkStation,Block.BlockNum);
            FileBlockMgr.ClearBit(BitsAccepted ,Block.WorkStation,Block.BlockNum);
            FileBlockMgr.Free;
            Block.Free;
            TxList.Delete(0);
         end
         else
         begin
            Application.ProcessMessages;
            if Application.Terminated then Close;
            Exit;
         end;
      end                   
      else
         TxList.Delete(0);
   end;
end;
procedure TForm1.UpdateStatus(S:String);
begin
   StatusList.Items.Add(S);
   StatusList.ItemIndex:=StatusList.Items.Count-1;
   StatusList.TopIndex :=StatusList.Items.Count-1;
end;
procedure TForm1.SendStatement;
var
   SS:TStringStream;
   FileBlockMgr:TFileBlockMgr;
   RS:TWSMaxMsgList;
begin
   SS:=TStringStream.Create('SHIRIKAQN');
   SS.Position:=SS.Size;
      
   FileBlockMgr:=TFileBlockMgr.Create;
   CurrentState:=FileBlockMgr.GetCurrentState(StrToIntDef(OfficeCode.Text,0));
   
   RS:=FileBlockMgr.AddState(StrToIntDef(OfficeCode.Text,0),CurrentState,RequiredState);
   RequiredState.Free;
   RequiredState:=RS;
   
   FileBlockMgr.Free;
      
   UpdateStatus('SS'+CurrentState.PackText);
   CurrentState.Insert(0,GetLocalMachineName);
   CurrentState.Insert(1,OfficeCode.Text);
   PutString(SS,'C'+CurrentState.PackText);
   CurrentState.Delete(0); CurrentState.Delete(0);
      
   UDP.SendDGram(SS.DataString);     
   SS.Free;
end;

procedure TForm1.SendRFP; // has anybody got xxx ?
var
   SS:TStringStream;
begin
   UpdateStatus('SR'+BitsRequested.PackText);
   SS:=TStringStream.Create('SHIRIKAQN');
   SS.Position:=SS.Size;
   PutString(SS,'R'+BitsRequested.PackText);
   UDP.SendDGram(SS.DataString);     
   SS.Free;
end;
procedure TForm1.SendProposal; // I've got xxx if you want it 
var                  
   SS:TStringStream;
begin
   UpdateStatus('SP'+BitsProposed.PackText);
   SS:=TStringStream.Create('SHIRIKAQN');
   SS.Position:=SS.Size;
   PutString(SS,'P'+BitsProposed.PackText);
   UDP.SendDGram(SS.DataString);     
   SS.Free;
end;
procedure TForm1.SendAccept; // Yes, send me xxx 
var
   SS:TStringStream;
begin
   UpdateStatus('SA'+BitsAccepted.PackText);
   SS:=TStringStream.Create('SHIRIKAQN');
   SS.Position:=SS.Size;
   PutString(SS,'A'+BitsAccepted.PackText);
   UDP.SendDGram(SS.DataString);     
   SS.Free;
end;
procedure TForm1.CheckReqired;
var
   FileBlockMgr:TFileBlockMgr;
   Office:Integer;
begin                        
   if RequiredState.PackText <> CurrentState.PackText then
   begin
      Office:=StrToIntDef(OfficeCode.Text,0);
      FileBlockMgr:=TFileBlockMgr.Create;
      // which bits do I need to get to required state
      BitsRequested:=FileBlockMgr.FindDifference(Office,RequiredState,FileBlockMgr.GetBitmaps(Office));
      if BitsRequested.PackText <> '' then
      begin
         Memo2.Lines.Add('SendRFP '+BitsRequested.PackText);
         SendRFP;
      end;
   end;
end;

procedure TForm1.ProcessStatement(S:String);
var
   ReceivedState,RS:TWSMaxMsgList;
   FileBlockMgr:TFileBlockMgr;
begin                         
   UpdateStatus('PS'+S);
   ReceivedState:=TWSMaxMsgList.Create;
   ReceivedState.PackText:=S;
   if (ReceivedState.Count > 2) and (ReceivedState.Strings[1] = OfficeCode.Text) then
   begin
      Memo2.Lines.Add(ReceivedState.Strings[0]); // machine name
      ReceivedState.Delete(0); ReceivedState.Delete(0);
      FileBlockMgr:=TFileBlockMgr.Create;
      RS:=FileBlockMgr.AddState(StrToIntDef(OfficeCode.Text,0),RequiredState,ReceivedState);
      RequiredState.Free;
      RequiredState:=RS;
      if RequiredState.PackText <> CurrentState.PackText then
      begin
         Memo2.Lines.Add('R '+RequiredState.PackText);
         Memo2.Lines.Add('C '+CurrentState.PackText);
      end;
      FileBlockMgr.Free;
   end;
   ReceivedState.Free;
   CheckReqired;
end;
procedure TForm1.ProcessRFP(S:String);
var
   Bitmap:TWSBitsList;
   FileBlockMgr:TFileBlockMgr;
   Office:Integer;
//   I,WS:Integer;
   BitsRequired:TWSBitsList;
   BP:TWSBitsList;
//   WSBits:TBBits;
//   MaxSend:Integer;
   CB:TWSBitsList;
begin                   
   UpdateStatus('PR'+S);
   Office:=StrToIntDef(OfficeCode.Text,0);
   Bitmap:=TWSBitsList.Create;
   Bitmap.PackText:=S;
   FileBlockMgr:=TFileBlockMgr.Create;
   CB:=FileBlockMgr.GetBitmaps(Office);
   // return the bits that are both in the request and the current database
   BitsRequired:=FileBlockMgr.FindCommon(Office,CB,Bitmap); // get what of req we can supply from our data
   CB.Free;
   Bitmap.Free;
   BP:=FileBlockMgr.MergeInBits(BitsProposed,BitsRequired); // merge with other outstanding requests
   FileBlockMgr.Free;
   BitsRequired.Free;
   BitsProposed.Free;
//   MaxSend:=100; // max total
{   for WS:=0 to BP.Count-1 do
   begin
      WSBits:=TBBits.Create;
      WSBits.AsString:=BP[WS].RLEBitmap;
      MaxSend:=10; // max per ws
      for I:=WSBits.Size downto 0 do
      begin
         if WSBits[I] then
         begin
            if MaxSend > 0 then
               Dec(MaxSend)
            else
               WSBits[I]:=False;
         end;
      end;
      BP.Strings[WS]:=#2+BP[WS].WSNumber+#2+WSBits.AsString;
   end; }
   BitsProposed:=BP; // assign cut down list 
   if BitsProposed.PackText <> '' then
   begin
      Memo2.Lines.Add('SendProposal '+BitsProposed.PackText);
      SendProposal;
   end;
end;
procedure TForm1.ProcessProp(S:String);
var
   Bitmap:TWSBitsList;
   FileBlockMgr:TFileBlockMgr;
   Office:Integer;
   BitsRequired:TWSBitsList;
   CB:TWSBitsList;
   BA:TWSBitsList;
begin                   
   UpdateStatus('PP'+S);
   Office:=StrToIntDef(OfficeCode.Text,0);
   Bitmap:=TWSBitsList.Create;
   Bitmap.PackText:=S;
   FileBlockMgr:=TFileBlockMgr.Create;
   CB:=FileBlockMgr.GetBitmaps(Office);
   BitsRequired:=FileBlockMgr.FindMissing(Office,CB,Bitmap); // what do we need of whats proposed
   CB.Free;
   Bitmap.Free;
   BA:=FileBlockMgr.ExcludeBits(BitsAccepted,BitsRequired); // remove bits already being supplied
   FileBlockMgr.Free;
   BitsRequired.Free;
   BitsAccepted.Free;
   BitsAccepted:=BA;
   if BitsAccepted.PackText <> '' then
   begin
      Memo2.Lines.Add('SendAccept '+BitsAccepted.PackText);
      SendAccept;
   end;
end;
procedure TForm1.ProcessAccept(S:String);
var
   Bitmap:TWSBitsList;
   Block,WS,I:Integer;
   WorkStn,Office:Integer;
   Bits:TBBits;
   Found:Boolean;
   FileBlockMgr:TFileBlockMgr;
   FileBlock:TFileBlock;
begin       
   UpdateStatus('PA'+S);
   Bitmap:=TWSBitsList.Create;      
   Bitmap.PackText:=S;
   FileBlockMgr:=TFileBlockMgr.Create;
   Office:=StrToIntDef(OfficeCode.Text,0);
   for WS:=0 to Bitmap.count-1 do
   begin
      WorkStn:=Bitmap[WS].WSNumber;
      Bits:=TBBits.Create;
      Bits.AsString:=Bitmap[WS].RLEBitmap;
   //   if Bits.Size > 0 then
//         Memo2.Lines.Add('Sending '+Bitmap[WS].WSNumber+' '+Bitmap[WS].RLEBitmap);
      for Block:=0 to Bits.Size do
      begin
         if Bits[Block] then
         begin
            FileBlock:=FileBlockMgr.GetBlock(Office,WorkStn,Block);
            if FileBlock <> nil then
            begin
               Found:=False;
               for I:=0 to TxList.Count-1 do
               begin
                  if TFileBlock(TxList[I]).BlockNum = FileBlock.BlockNum then
                  begin
                     Found:=True;
                     Break;
                  end;
               end;
               if not Found then
               begin
                  Memo2.Lines.Add('Sending '+Bitmap[WS].WSNumber+' '+IntToStr(Block));
                  TxList.Add(FileBlock);
               end;
            end;
         end;                  
      end;
      Bits.Free;
   end;
   Bitmap.Free;
end;
procedure TForm1.RxDGram(Sender:TUDP;From,Data:String);
var
   SS:TStringStream;
   Block:TFileBlock;
   FileBlockMgr:TFileBlockMgr;
   CB:TWSBitsList;
begin                
   if Copy(Data,1,8)= 'SHIRIKAQ' then // check valid dgram 
   begin
      if From <> UDP.HexIPAddress then // not from me!
      begin
         SS:=TStringStream.Create(Data);
         SS.Position:=Length('SHIRIKAQ');
         Data:=GetString(SS,1);
         if Data = 'B' then // Contains Data Block
         begin
            Block:=TFileBlock.Create;
            Block.LoadFromStream(SS);
            FileBlockMgr:=TFileBlockMgr.Create;
            Memo2.Lines.Add('Received Block '+IntToStr(Block.WorkStation)+' '+IntToStr(Block.BlockNum));
            if not FileBlockMgr.SetBlock(Block) then ; // Error
            CB:=FileBlockMgr.GetBitmaps(Block.Office);
            UpdateStatus('CS'+CB.PackText);
            CB.Free;
            FileBlockMgr.ClearBit(BitsRequested,Block.WorkStation,Block.BlockNum);
            FileBlockMgr.ClearBit(BitsProposed ,Block.WorkStation,Block.BlockNum);
            FileBlockMgr.ClearBit(BitsAccepted ,Block.WorkStation,Block.BlockNum);
            Block.Free;
         end;
         if not IgnoreAllMessages then
         begin
            Data:=GetString(SS,1);
            case Data[1] of
              'C' : ProcessStatement(GetString(SS,SS.Size-SS.Position)); // This is what I've got!
              'R' : ProcessRFP      (GetString(SS,SS.Size-SS.Position)); // Can you send me xxx?
              'P' : ProcessProp     (GetString(SS,SS.Size-SS.Position)); // I can send you xxx
              'A' : ProcessAccept   (GetString(SS,SS.Size-SS.Position)); // Send me xxx
              'E' : ; // end of data
            end;
         end;
         SS.Free;
      end;
   end;
end;
procedure TForm1.DGramError(Sender:TUDP;EMessage:String);
begin
   Memo2.Lines.Add(EMessage);
end;                        
procedure TForm1.Button3Click(Sender: TObject);
begin
   UDP:=TUDP.Create;
   UDP.OnRxDGram:=RxDGram   ;
   UDP.OnError  :=DGramError;
   UDP.RxOwn    :=True;
   UDP.PortNumber:=45020;
   UDP.Active:=True;
   Timer1.Enabled:=True;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
   Timer1.Enabled:=False;
   UDP.Active:=False;
   UDP.Free;
   UDP:=nil;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
   Timer1.Enabled:=False;
   if UDP <> nil then
   begin
      UDP.Active:=False;
      UDP.Free;
      UDP:=nil;
   end;
//   BitsHere.Free;
//   BitsAll.Free;
   BitsRequested.Free;
   BitsProposed.Free;
   BitsAccepted.Free;
//   BitsSent.Free;
   TxList.Free;
   
   CurrentState.Free;
   RequiredState.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
   FileBlockMgr:TFileBlockMgr;
begin
   IgnoreAllMessages:=False;
   CurrentState:=TWSMaxMsgList.Create;
   RequiredState:=TWSMaxMsgList.Create;
   FileBlockMgr:=TFileBlockMgr.Create;
//   BitsHere:=FileBlockMgr.GetBitmaps(StrToIntDef(OfficeCode.Text,0));
   FileBlockMgr.Free;
//   BitsAll:=TWSBitsList.Create;
//   BitsAll.PackText:=BitsHere.PackText;
   
   BitsRequested:=TWSBitsList.Create;
   BitsProposed :=TWSBitsList.Create;
   BitsAccepted :=TWSBitsList.Create;
//   BitsSent     :=TWSBitsList.Create;
   TxList:=TList.Create;
end;

procedure TForm1.StatusListMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
var
   S:String;
   Bitmap:TWSBitsList;
   BState:TWSMaxMsgList;
   LineHeight:Integer;
begin         
   LineHeight:=StatusList.Canvas.TextHeight('Wg');
   Height:=LineHeight;
   S:=Copy(StatusList.Items[Index],1,2);
   if (S = 'PR') or (S = 'PP') or (S = 'PA') or (S = 'SR') or (S = 'SP') or (S = 'SA') or (S = 'CS') then
   begin
      Bitmap:=TWSBitsList.Create;
      Bitmap.PackText:=Copy(StatusList.Items[Index],3,Length(StatusList.Items[Index]));
      Height:=Bitmap.Count*LineHeight;
      Bitmap.Free;
   end
   else if (S = 'SS') or (S = '') or (S = 'PS') then
   begin
      BState:=TWSMaxMsgList.Create;
      BState.PackText:=Copy(StatusList.Items[Index],3,Length(StatusList.Items[Index]));
      if (S = 'PS') and  (BState.Count > 1) then
      begin
         BState.Delete(0);
         BState.Delete(0);
      end;
      Height:=BState.Count*LineHeight;
      BState.Free;
   end;
end;  

procedure TForm1.StatusListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   S:String;
   Bits:TBBits;
   Bitmap:TWSBitsList;
   BState:TWSMaxMsgList;
   I:Integer;
   R:Integer;
   BS:TBrushStyle;
   LineHeight:Integer;
begin         
   BS:=StatusList.Canvas.Brush.Style;
   LineHeight:=StatusList.Canvas.TextHeight('Wg');
   StatusList.Canvas.FillRect(Rect);
   S:=Copy(StatusList.Items[Index],1,2);
   if (S = 'PR') or (S = 'PP') or (S = 'PA') or (S = 'SR') or (S = 'SP') or (S = 'SA') or (S = 'CS') then
   begin
      Bitmap:=TWSBitsList.Create;
      Bitmap.PackText:=Copy(StatusList.Items[Index],3,Length(StatusList.Items[Index]));
      with StatusList.Canvas do
      begin
         if S[1] = 'P' then Pen.Color:=clGreen else Pen.Color:=clMaroon;
         StatusList.Canvas.Brush.Style:=bsClear;
         for I:=0 to Bitmap.Count-1 do
         begin
            TextOut(Rect.Left,Rect.Top+I*LineHeight,S);
            TextOut(Rect.Left+TextWidth('888'),Rect.Top+I*LineHeight,Bitmap[I].WSNumber);
            Bits:=TBBits.Create;
            Bits.AsString:=Bitmap[I].RLEBitmap;
            for R:=0 to Bits.size do
            begin
               if Bits[R] then
                  Rectangle(Rect.Left+TextWidth('8888888')+R,(Rect.Top+I*LineHeight)+LineHeight div 4,Rect.Left+TextWidth('8888888')+R+1,(Rect.Top+I*LineHeight)+(LineHeight div 4)*3);
            end;
            Bits.Free;   
         end;    
         StatusList.Canvas.Brush.Style:=BS;
      end;   
//      for I:=0 to Bitmap.Count-1 do
//         StatusList.Canvas.TextOut(Rect.Left,Rect.Top+I*LineHeight,Bitmap[I].WSNumber+' -> '+Bitmap[I].RLEBitmap);
      Bitmap.Free;
   end
   else if (S = 'SS') or (S = '') or (S = 'PS') then
   begin
      BState:=TWSMaxMsgList.Create;
      BState.PackText:=Copy(StatusList.Items[Index],3,Length(StatusList.Items[Index]));
      if (S = 'PS') and  (BState.Count > 1) then
      begin
         BState.Delete(0);
         BState.Delete(0);
      end;
      with StatusList.Canvas do
      begin
         StatusList.Canvas.Brush.Style:=bsClear;
         if S[1] = 'P' then Pen.Color:=clGreen else Pen.Color:=clMaroon;
         for I:=0 to BState.Count-1 do        
         begin
            TextOut(Rect.Left,Rect.Top+I*LineHeight,S);
            TextOut(Rect.Left+TextWidth('888'),Rect.Top+I*LineHeight,BState[I].WSNumber);
            R:=0;
            while R < BState[I].MaxMessageNo do
            begin
               Inc(R,100);
               if R > BState[I].MaxMessageNo then R:=BState[I].MaxMessageNo;
               Rectangle(Rect.Left+TextWidth('8888888'),(Rect.Top+I*LineHeight)+LineHeight div 4,Rect.Left+TextWidth('8888888')+R,(Rect.Top+I*LineHeight)+(LineHeight div 4)*3);
            end;
            TextOut(Rect.Left+TextWidth('88888888')+R,Rect.Top+I*LineHeight,BState[I].MaxMessageNo);
         end;   
         StatusList.Canvas.Brush.Style:=BS;
      end;   
      BState.Free;
   end
   else
      StatusList.Canvas.TextOut(Rect.Left,Rect.Top,StatusList.Items[Index]);
end;   

end.
