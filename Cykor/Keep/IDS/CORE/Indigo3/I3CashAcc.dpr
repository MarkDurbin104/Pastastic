library I3CashAcc;

uses
  Windows,Graphics,SysUtils,Classes,Controls,StdCtrls,
  ShareDataU,UIDLLSupportU,OsmiumSupportU,PackStrListU,
  MOSupportU,GPCSBase_TLB,GPCSGUID;

type
  TTimerRoutine    = procedure ;
  TValidateRoutine = function (Control:TWinControl):Boolean;
  TExecuteRoutine  = function :Integer;
  TDrawRoutine     = procedure (Control:TWinControl;Index:Integer;Rect:TRect;State:TOwnerDrawState);
  TRepCallBack     = function (ColumnName,ReportName,Value:String):String;
  TRepFootCallBack = procedure(ReportName:String;PrintRect:TRect;Canvas:TCanvas;PageNo,NoPages:Integer);
  
var
   MainCallBack:TCallBack;  
   
// -------------------------------------------------------------------------
// ---------------------- DLL Start Stop -----------------------------------
// -------------------------------------------------------------------------
procedure UIDLLStartup(var SystemName:String;CallBackFunction:TCallBack);
begin
   SharedData:=TSharedData.Create('CorvusReportShare',False);
   MainCallBack:=@CallBackFunction;
end;
procedure UIDLLShutdown;
begin
   SharedData.Free;
end;
// -------------------------------------------------------------------------
// ------------------- Validation Functions --------------------------------
// -------------------------------------------------------------------------
function CAOffice(Control:TWinControl):Boolean;
begin
   SetFieldContents('CAOfficeCode',IntToStr(NameToPayPoint(GetFieldContents('CAOffice'))));
   Result:=True;
end;
function CAOfficeCode(Control:TWinControl):Boolean;
begin
   SetFieldContents('CAOffice',PayPointToName(StrToIntDef(GetFieldContents('CAOfficeCode'),0)));
   Result:=True;
end;
function ValidateCashAcc(Control:TWinControl):Boolean;
var
   SL,LSL:TPackStringList;
   I:Integer;
begin
   Result:=True;
   SL:=TPackStringList.Create;
   LSL:=TPackStringList.Create;
   SL.PackText:=GetFieldContents('CashAcc');
   if SL.Count > 1 then
   begin
      LSL.PackText:=SL[1];
      for I:=0 to LSL.Count-1 do
      begin
         LSL[I]:=CurrToStrF(StrToCurrDef(LSL[I],0),ffNumber,2);
      end;
      SL[1]:=LSL.PackText;
   end;  
   SetFieldContents('CashAcc',SL.PackText);
   SL.Free;
   LSL.Free;
end;
function CashAccountChange(Control:TWinControl):Boolean;
var
   S:String;
begin
   Result:=False;
   S:=SharedData.GetVariable('SGCurrentValue');
   if S = '' then 
      Result:=True
   else if (StrToCurrDef(S,-1) <> -1) then
   begin
      Result:=True;
   end;
   SharedData.SetVariable('SGCurrentValue',S);
end;
// -------------------------------------------------------------------------
// ---------------------- Completion Functions -----------------------------
// -------------------------------------------------------------------------
function StrToPeriod(DateS:String):Integer;
var
   PDate:TDateTime;
   Y:Word;
   M:Word;
   D:Word;
begin
   D:=StrToIntDef(Copy(DateS,1,2),14);
   M:=StrToIntDef(Copy(DateS,4,2),2);
   if Length( DateS ) >= 10 then
      Y := StrToIntDef(Copy(DateS,7,4),0)
   else
   begin
      Y:=StrToIntDef(Copy(DateS,7,2),0);
      if Y < 80 then Inc(Y,100);
      Inc(Y,1900);
   end ;
   PDate:=EncodeDate(Y,M,D);
   Result:=Trunc(PDate)-DaysUntil_010198;
end;

function CashAccComplete:Integer;
var
  SL:TPackStringList;
  LSL:TPackStringList;
  LeftCols:TPackStringList;
  RightCols:TPackStringList;
  I:Integer;
  CAPeriod:Integer;
  Value:Currency;
  Stock:IStock;
  TxnLog:ITransactionLog;
  Index,TempOfficeCode:Integer;
  TempUserName:String;
begin
   Stock:=CreateStock;
   TxnLog:=CreateTransactionLog;
   if (Stock <> nil) and (TxnLog <> nil) then
   begin
      CAPeriod:=StrToPeriod(GetFieldContents('CADate'));
      
      TempOfficeCode:=TxnLog.Office; // store office code
      TxnLog.Office:=StrToIntDef(GetFieldContents('CAOfficeCode'),0);
      
      TempUserName:=TxnLog.User; // store user name
      if GetFieldContents('CAUser') <> '' then
         TxnLog.User:=GetFieldContents('CAUser')
      else
         TxnLog.User:='Supervisor';
         
      try
         LeftCols:=TPackStringList.Create;
         RightCols:=TPackStringList.Create;
         SL:=TPackStringList.Create;
         LSL:=TPackStringList.Create;
         SL.PackText:=GetFieldContents('CashAcc');
         if SL.Count > 1 then
         begin
            LeftCols.PackText:=SL[0];
            RightCols.PackText:=SL[1];
         end;
         SL.CommaText:=Stock.ListAllStock('Supervisor','CashAcc');
         
         for I:=0 to SL.Count-1 do
         begin
            LSL.CommaText:=SL[I];
            if LSL.Count > 4 then
            begin
               Index:=LeftCols.IndexOf(LSL[0]); // find Description
               if (Index <> -1) and (StrToCurrDef(RightCols[Index],-1) > 0) then 
               begin
                  Value:=StrToCurrDef(RightCols[Index],-1);
                  TxnLog.WriteTransaction(
                     '*CashAcc',0,0,              // Type,Index,Quantity
                     StrToIntDef(LSL[3],9000000), // PLU
                     Value,Value,                 // Value,Price
                     LeftCols[Index],             // Description
                     IntToStr(CAPeriod),          // Additional
                     LSL[4],'');                  // ProgID,DomInfo
               end;
            end;
         end;
         LSL.Free;
         SL.Free;
         LeftCols.Free;
         RightCols.Free;
      except
      end;
      TxnLog.Office:=TempOfficeCode;
      TxnLog.User  :=TempUserName  ;
   end;
   Stock:=nil;
   TxnLog:=nil;
   
   Result:=1;
end;
// -------------------------------------------------------------------------
// ------------------------- OnCreate Functions ----------------------------
// -------------------------------------------------------------------------
procedure SetupCashAcc;
var
  SL:TPackStringList;
  LSL:TPackStringList;
  I:Integer;
  Stock:IStock;
begin
   SetFieldContents('CADate',DateToStr(Now-1));
   Stock:=CreateStock;
   if Stock <> nil then
   begin
      SL:=TPackStringList.Create;
      SL.CommaText:=Stock.ListAllStock('Supervisor','CashAcc');
      LSL:=TPackStringList.Create;
      for I:=0 to SL.Count-1 do
      begin
         LSL.CommaText:=SL[I];
         if LSL.Count > 0 then
           SL[I]:=LSL[0];
      end;
      LSL.PackText:=SL.PackText;
      SL.Clear;
   
      SL.Add(LSL.PackText);
      for I:=0 to LSL.Count-1 do
         LSL[I]:='0';
      SL.Add(LSL.PackText);
      LSL.Free;        
   
      SetFieldContents('CashAcc',SL.PackText); // default to first in list
      SL.Free;
      Stock:=nil;
   end;
end;
// -------------------------------------------------------------------------
// ---------------------- ReportCallBack Functions -------------------------
// -------------------------------------------------------------------------
function OfficeCodeAsName(ColumnName,ReportName,Value:String):String;
begin
   Result:=PayPointToName(StrToIntDef(Value,0));
end;
function PeriodAsDate(ColumnName,ReportName,Value:String):String;
begin
   if StrToIntDef(Value,0) = 0 then
      Result:=' '
   else
      Result:=FormatDateTime('dd/mm/yyyy',PeriodToDate(StrToIntDef(Value,0)));
end;
// -------------------------------------------------------------------------
// ----------------- Report Header/Footer CallBack Functions ---------------
// -------------------------------------------------------------------------
procedure PageNumOfNum(ReportName:String;PrintRect:TRect;Canvas:TCanvas;PageNo,NoPages:Integer);
var
   S:String;
begin
   S:='Page '+IntToStr(PageNo)+' of '+IntToStr(NoPages);
   Canvas.TextOut(PrintRect.Right-Canvas.TextWidth(S),PrintRect.Bottom-Canvas.TextHeight('Wg'),S);
end;
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
exports
   // DLL routines
   UIDLLStartup,UIDLLShutdown,
   // Validation routines
   CAOffice,CAOfficeCode,CashAccountChange,ValidateCashAcc,
   // Completion routines
   CashAccComplete,
   // OnCreate routines
   SetupCashAcc,
   // Report callback routines
   OfficeCodeAsName,PeriodAsDate,
   // Footer calback routines
   PageNumOfNum;
begin
end.
