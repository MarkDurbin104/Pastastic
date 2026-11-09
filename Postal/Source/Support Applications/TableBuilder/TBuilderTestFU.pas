unit TBuilderTestFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,ComObj,RegistryEx,GPCSErrorLine,StringWrapperU,PackStrListU,
  FileTxStatusU,StatusMonitorU,MsgFileAccessU,MsgConfigU, ComCtrls;

type
  TDLLFunc = procedure(MessageData:String);
  TForm1 = class(TForm)
    Button1: TButton;
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
function ProgIDToServer(ProgID:String):String;
begin
   Result:=GUIDToString(ProgIDToClassID(ProgID));
   if Result <> '' then
   begin
      try
         Result:=RegistryEx.ReadRegistryStringValue('HKCR\CLSID\'+Result+'\InProcServer32\');
      except
         on E:Exception do
            RaiseGUIDException('{59877E98-7DBA-42BA-9A21-FA6169DA25D2}',E);
      end;
   end;
end;
procedure CallDLLFunc(FuncName,MessageData:String);
var
   DLLName   :String;
   LibHandle :THandle;
   DLLFunc:TDLLFunc;
begin
   DLLName   := ProgIDToServer('Utility.TBuilder');
   LibHandle := LoadLibrary(PChar(DLLName));
   try
      @DLLFunc:=GetProcAddress(LibHandle,PChar(FuncName));
      if @DLLFunc <> nil then
         DLLFunc(MessageData);
   except
      on E:Exception do
         RaiseGUIDException('{65824C8F-9627-4962-9177-C0D26192C4FC}',E);
   end;
   if LibHandle <> 0 then
      FreeLibrary(LibHandle);
end;
procedure TForm1.Button1Click(Sender: TObject);
var                                                                                                                    
  MsgIndex:Integer;
  I,Off,WS:Integer;
  Status:TStatusBits;
  MessageData:TMessageAccess;
  AllLines:TPackStringList;
  TxnLines:TTxnLogLines;
  TxnLine:TTxnLogLine;//Flags
  Flags:Integer;       
  S:String;
  FSMon:TFileStatusMon;
  WSIdx:Integer;
  Count:Integer;
begin
   Button1.Enabled:=False;
   try
      FSMon:=TFileStatusMon.Create(nil);
      Status:=TStatusBits.Create;
      Status.State:=FSMon.FileBlockMgr.GetStatus;
      TxnLines:=TTxnLogLines.Create;
      TxnLine:=TTxnLogLine.Create;
      AllLines:=TPackStringList.Create;
      ProgressBar1.Min:=0;
      ProgressBar1.Max:=Status.Count;
      Count:=0;
      for WSIdx:=0 to Status.Count-1 do
      begin
         ProgressBar1.Position:=WSIdx+1;
         ProgressBar1.RePaint;
         Label1.Caption:='Message Count:'+IntToStr(Count);
         Label1.RePaint;
         Application.ProcessMessages;
         if Application.Terminated then Break;
         WS:=Status.WSNumber(WSIdx);
         Off:=Status.OfficeCode(WSIdx);
         for MsgIndex:=0 to Status.Size(Off,WS)-1 do
         begin
            if MsgIndex mod 500 = 0 then
            begin
               Label1.Caption:='Message Count:'+IntToStr(Count+MsgIndex);
               Label1.RePaint;
               Application.ProcessMessages;
               if Application.Terminated then Break;
            end;
            try
               Flags:=FSMon.FileBlockMgr.GetMessageFlags(Off,WS,MsgIndex);
               // is it a transaction message
               if (Flags and TransactionMsg) = TransactionMsg then
               begin
                  MessageData:=FSMon.FileBlockMgr.GetMessage(Off,WS,MsgIndex);
                  if MessageData <> nil then
                  begin
                     S:=MessageData.MessageData;
                     if (S <> '') and (S[1] = #1) then
                        TxnLines.PackText:=#2+S
                     else                       
                        TxnLines.PackText:=S;
                     if not MessageData.GoodCRC then 
                        ShowMessage('Bad CRC in Message (Office '+IntToStr(Off)+' WS '+IntToStr(WS)+' Idx '+IntToStr(MsgIndex)+')');
                     if MessageData.GoodCRC and (TxnLines.Count <> 0) then
                     begin
                        try
                           I:=0;
                           while I < TxnLines.Count do
                           begin
                              TxnLine.PackText:=TxnLines[I];
                              if (TxnLine.RecordID <> '') 
                              or (TxnLine.WSNumber <> '')
                              and (TxnLine.DateTime <> '') then 
                              begin
                                 if TxnLine.Price = '' then TxnLine.Price:=0;
                                 if TxnLine.TxnValue = '' then TxnLine.TxnValue:=0;
                                 if TxnLine.Quantity = '' then TxnLine.Quantity:=0;
                                 TxnLines[I]:=TxnLine.PackText;
                                 Inc(I);
                              end
                              else
                                 TxnLines.Delete(I);
                           end;
                           if TxnLines.Count <> 0 then
                              AllLines.AddStrings(TxnLines);
                        except
                        end;
                     end;
                     MessageData.Free;
                  end;
               end;     
            except
            end;
         end;
         Inc(Count,Status.Size(Off,WS));
         CallDLLFunc('CheckData',AllLines.PackText);
         AllLines.Clear;
      end;
      Label1.Caption:='Message Count:'+IntToStr(Count);
      AllLines.Free;
      TxnLines.Free;
      TxnLine.Free;
      Status.Free;
   except
   end;
   CallDLLFunc('CheckData','Complete');  
   Button1.Enabled:=True;
end;

end.
