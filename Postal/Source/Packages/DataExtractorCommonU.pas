unit DataExtractorCommonU;

interface

uses
  BaseProduct,
  Classes,
  ComObj,
  DatabaseServer_TLB,
  Dialogs,
  GPCSBase_TLB,
  GPCSGUID,
  PackStrListU,
  ParseNodeU,
  QueryMapU,
  ReportIDSU,
  ShareDataU,
  Stock2U,
  StringUtil,
  SumSales,
  SysUtils,
  Windows,
  UserManager_TLB;

var
  GPCSUsers :TStringList ;
  Stock     : IStock ;


function DateToPeriod(FromDate:TDateTime):Integer;
function DateToWeekNo(FromDate:TDateTime):Integer;
function EndOfMonth(FromPeriod:Integer):Integer; // (var DaysInWeek:Integer)
function FormatAverages(ReportGrid:TReportGrid):String;
function Format15Columns(ReportGrid:TReportGrid):String;
function GetAllGPCSUsers : String;
//returns each GPCS user on domain
function GetAllValuesFor(Day:Integer;User:String;SalesItems:TSalesItems;var TotQty:Integer):String;
function GetIDValues(DayFrom,DayTo:Integer;var TotQty:Integer;PLUList:TStrings;IDDataStract,User:String  ):currency; external '.\DataExtractor';
function GetPLUValues(DayFrom,DayTo:Integer;RangeNode:TRangeNode;SalesItems:TSalesItems;var TotQty:Integer;PLUList:TStrings):String;
function PeriodToDate(FromPeriod:Integer):TDateTime;
function PeriodToWeekNo(FromPeriod:Integer):Integer;
function PLUIn(PLU:Integer;Range:String):Boolean;
function StartOfMonth(FromPeriod:Integer):Integer;
function StartWeek(FromPeriod:Integer):Integer;
function StkAtPeriodRepSection(Stock:IStock; FUser:String; PLUList:String; ReportEmptyLines:Boolean; ReqdPeriod : Integer; Db : IDatabaseServerAuto ) : Currency;
//returns stock level at end of a given period
function TotalGPCSUserStock : String ;
//totals each GPCS users stock holding
function WeekByUserGrid:TReportGrid;
function WeekStarting(FromPeriod:Integer):Integer;

implementation


function DateToPeriod(FromDate:TDateTime):Integer;
begin
   Result:=Trunc(FromDate)-DaysUntil_010198;
end;

function DateToWeekNo(FromDate:TDateTime):Integer;
const
   Days_Until_01042002 = 37347;
begin
   // week 1 starts on 01/04/2002 so
   // take off the days until then
   // div 7 gives weeks since then
   // mod 52 restarts at 0 each year
   // add 1 because this calc is zero based
   Result:=(((Trunc(FromDate)-Days_Until_01042002) div 7) mod 52)+1;
end;

function DayNumber(Date:TDateTime):Integer;
const
  Days_Until_01042002 = 37347;
begin
  // 01/04/2002 is a Monday (Day 1)
  Result:=((Trunc(Date)-Days_Until_01042002) mod 7)+1;
end;

function EndOfMonth(FromPeriod:Integer):Integer; // (var DaysInWeek:Integer)
var
   d,m,y:Word;
const
   NumbDays:Array[1..12] of Integer = (31,28,31,30,31,30,31,31,30,31,30,31);
begin
   DecodeDate(PeriodToDate(FromPeriod),y,m,d);
   if ((y mod 4) = 0) and (m = 2) then // Feb. in leap year
      Result:=Trunc(EncodeDate(y,m,NumbDays[m]+1))
   else
      Result:=Trunc(EncodeDate(y,m,NumbDays[m]));
end;

function EndWeek(FromPeriod:Integer):Integer; // (var DaysInWeek:Integer)
begin
  Result:=DateToWeekNo(EndOfMonth(FromPeriod));
end;

function FormatAverages(ReportGrid:TReportGrid):String;
var
   ColumnList:TPackStringList;
   RowList:TPackStringList;
   I,J:Integer;
begin
   ColumnList:=TPackStringList.Create;
   RowList   :=TPackStringList.Create;
   for I:=0 to ReportGrid.RowCount-1 do
   begin
      RowList.Add(ReportGrid[I,0]);
      if ((Trim(ReportGrid[I,0]) = '') or (Trim(ReportGrid[I,0]) = '___')) then
      begin
         for J:=1 to 7 do RowList.Add(' ')
      end
      else
      begin
         for J:=1 to 7 do
         begin
            if StrToIntDef(ReportGrid[I,J*2],0) = 0 then
               RowList.Add('0')
            else
               RowList.Add(CurrToStr(StrToCurrDef(ReportGrid[I,J*2-1],0) / StrToCurrDef(ReportGrid[I,J*2],1)));
         end;
      end;
      ColumnList.Add(RowList.CommaText);
      RowList.Clear;
   end;
   Result:=ColumnList.CommaText;
   ColumnList.Free;
   RowList.Free;
end;

function Format15Columns(ReportGrid:TReportGrid):String;
var
   ColumnList:TPackStringList;
   RowList:TPackStringList;
   I,J:Integer;
begin
   ColumnList:=TPackStringList.Create;
   RowList   :=TPackStringList.Create;
   for I:=0 to ReportGrid.RowCount-1 do
   begin
      RowList.Add(ReportGrid[I,0]);
      if ((Trim(ReportGrid[I,0]) = '') or (Trim(ReportGrid[I,0]) = '___')) then
      begin
         for J:=1 to 14 do RowList.Add(' ')
      end
      else
      begin
         for J:=1 to 14 do RowList.Add(ReportGrid[I,J]);
      end;
      ColumnList.Add(RowList.CommaText);
      RowList.Clear;
   end;
   Result:=ColumnList.CommaText;
   ColumnList.Free;
   RowList.Free;
end;

function GetAllGPCSUsers : String;
var
  NetManager      : INetUser ;
  SL              : TPackStringList ;
  SLUsers         : TPackStringList;
  UseLocalMachine : Boolean ;
  ServerName      : String;
  i,j             : Integer;
begin
  NetManager       :=  CreateOleObject('UserManager.NetUser') as INetUser;
  UseLocalMachine  :=  GetGPCSRegString('','Primary Domain Controller','') = 'None' ;

  SL:=TPackStringList.Create;
  SLUsers:= TPackStringList.Create;
  try
    if not UseLocalMachine then
    begin
      try
        ServerName:=NetManager.GetPDC;
      except
      end;
    end;
    if ServerName = '' then
    begin
      UseLocalMachine:=True;
      ServerName:=GetLocalMachineName;
      SLUsers.CommaText:=NetManager.GetUsers(ServerName);
    end
    else
      SLUsers.CommaText:=NetManager.GetUsers(ServerName);

  except
  end;

  i := 0 ;
  while (i <= SlUsers.Count-1) do
  begin
    try
      if UseLocalMachine then
        SL.CommaText:=NetManager.GetMemberLocalGroups(ServerName,SLUsers[i])
      else
        SL.CommaText:=NetManager.GetMemberGlobalGroups(ServerName,SLUsers[i]);
    except
    end ;

    j := 0 ;
    while ( ( J<=SL.Count-1) and  ( Pos('GPCS',SL[j])=0 ) ) do  Inc(j);

    if J = SL.Count then // if doesn't belong to GPCS removed from the list
      SlUsers.Delete(i)
    else
      Inc(i);
  end ;


  result := SLUsers.CommaText;
  SL.Free ;
  SLUsers.Free;
  NetManager:=nil;
end ;

function GetAllValuesFor(Day:Integer;User:String;SalesItems:TSalesItems;var TotQty:Integer):String;
var
   SI:Integer;
   TotVal:Currency;
begin
   TotQty:=0;
   TotVal:=0;
   for SI:=0 to SalesItems.Count-1 do
   begin
     if (SalesItems[SI].Period = Day) then
     begin
         if  (SalesItems[SI].Teller = User)
         and (SalesItems[SI].PLU <> 90000016) then // cash !!!
         begin
            TotVal:=TotVal+SalesItems[SI].Value;
            TotQty:=TotQty+SalesItems[SI].Quantity;
         end;
      end;
   end;
   Result:=CurrToStr(TotVal);
end;

function GetPLUValues(DayFrom,DayTo:Integer;RangeNode:TRangeNode;SalesItems:TSalesItems;var TotQty:Integer;PLUList:TStrings):String;
var
   PLUIndex,SI:Integer;
   PLURange:String;
   TotVal:Currency;
begin
   TotQty:=0;
   TotVal:=0;
   for PLUIndex:=0 to RangeNode.PLUCount-1 do
   begin
      PLURange:=RangeNode.PLURange[PLUIndex];
      for SI:=0 to SalesItems.Count-1 do
      begin
        if (SalesItems[SI].Period >= DayFrom) and (SalesItems[SI].Period <= DayTo) then
        begin
           if (PLURange = '*') and (not SalesItems[SI].Used) then
           begin
              SalesItems[SI].Used:=True;
              if PLUList <> nil then
              begin
                 if PLUList.IndexOf(IntToStr(SalesItems[SI].PLU)) = -1 then
                    PLUList.Add(IntToStr(SalesItems[SI].PLU));
              end;
              if SalesItems[SI].PLU <> 90000016 then // cash !!!
              begin
                 TotVal:=TotVal+SalesItems[SI].Value;
                 TotQty:=TotQty+SalesItems[SI].Quantity;
              end;
           end
           else if PLUIn(SalesItems[SI].PLU,PLURange) then
           begin
              if PLUList <> nil then
              begin
                 if PLUList.IndexOf(IntToStr(SalesItems[SI].PLU)) = -1 then
                    PLUList.Add(IntToStr(SalesItems[SI].PLU));
              end;
              SalesItems[SI].Used:=True;
              TotVal:=TotVal+SalesItems[SI].Value;
              TotQty:=TotQty+SalesItems[SI].Quantity;
           end;
        end;
      end;
   end;
   Result:=CurrToStr(TotVal);
end;

function PeriodToDate(FromPeriod:Integer):TDateTime;
begin
  Result:=DaysUntil_010198+FromPeriod;
end;

function PeriodToWeekNo(FromPeriod:Integer):Integer;
begin
  Result:=DateToWeekNo(PeriodToDate(FromPeriod));
end;

function PLUIn(PLU:Integer;Range:String):Boolean;
//tests PLU is in the Range (eg 123,234-345,678,987-10002 == 4 subranges)
var
  FromPLU, ToPLU : Integer;
begin
  Result:=False;
  With TStringObject.Create(Range) do //create sub ranges
  begin
    try
      While Strings.Count > 0 do  //go through all subranges
      begin
        //extract subrange limits
        if Pos('-',Strings[0]) > 1 then  //PLU range
        begin
          FromPLU := StrToIntDef(DelimitedString(Strings[0],'-',False),0); //before hyphen
          ToPLU   := StrToIntDef(DelimitedString(Strings[0],'-',True),0);  //after hyphen
        end
        else  //single PLU
        begin
          FromPLU := StrToIntDef(Strings[0],0);
          ToPLU   := FromPLU;
        end;

        //test limits
        if  (PLU >= FromPLU) and (PLU <= ToPLU) then
        begin
          Result := True;
          Strings.Clear;  //matches a plu subrange - dont need to check others
        end
        else
          Strings.Delete(0);  //sub-range tested
      end;
    finally
      Free;
    end;
  end;
end;

function StartOfMonth(FromPeriod:Integer):Integer;
var
   d,m,y:Word;
begin
   DecodeDate(PeriodToDate(FromPeriod),y,m,d);
   Result:=Trunc(EncodeDate(y,m,1));
end;

function StartWeek(FromPeriod:Integer):Integer;
begin
   Result:=DateToWeekNo(StartOfMonth(FromPeriod));
end;

function StkAtPeriodRepSection(Stock:IStock; FUser:String; PLUList:String; ReportEmptyLines:Boolean; ReqdPeriod : Integer; Db : IDatabaseServerAuto ) : Currency;
//returns stock level at end of a given period
type
  TPLURange = (prFrom, prTo);
var
  //TheCurrentPeriod    : Integer;
  PLUSL               : TPackStringList;
  TxnsSL              : TPackStringList;
  StockCollection     : TStockCollection;
  StockCollectionItem : TStockCollectionItem;
  StockItemIndex,
  PLUIndex            : Integer;
  FromPLU,ToPLU       : Integer;
  //UserName            : String;
  PLURange            : Array[0..20,prFrom..prTo] of Integer;  //up to 20 ranges of low -> high PLU ranges
  PosSign,NegSign     :String ;
  UserSearch : String ;
begin
  //TheCurrentPeriod := GetCurrentPeriod ;
  Result := 0;
  //if (DoFullUserSearch) or (FUser <> 'Supervisor') then UserName:=FUser
  //else UserName:='All';
  if Stock = nil then Exit;

  StockCollection := TStockCollection.Create;
  PLUSL :=TPackStringList.Create;
  TxnsSL:=TPackStringList.Create;
  try

    //grab current stock levels
//    TheCurrentPeriod := GetCurrentPeriod;
     StockCollection.CommaText  := Stock.ListAllStock(FUser,'All');
    //StockCollection.CommaText                      := Stock.ListAvailableStock(FUser,'All');

    //extract PLU ranges
    If PLUList <> '' then //PLUs specified
    begin
      PLUSL.CommaText:=PLUList; //grab PLU expressions, eg, "123-456,789,234"
      ZeroMemory(@PLURange,SizeOf(PLURange)); //clear all array values
      for PLUIndex := 0 to PLUSL.Count-1 do
      begin
        FromPLU := StrToIntDef(DelimitedString(PLUSL[PLUIndex],'-',False),0);
        ToPLU   := StrToIntDef(DelimitedString(PLUSL[PLUIndex],'-',True),0);
        PLURange[PLUIndex,prFrom] := FromPLU;
        If ToPLU = 0 then ToPLU := FromPLU;  //single value PLUs
        PLURange[PLUIndex,prTo] := ToPLU;
      end;
    end;

    //go through all stock items
    for StockItemIndex:=0 to StockCollection.Count-1 do
    begin
      StockCollectionItem := StockCollection.Items[StockItemIndex];
      if PLUList = '' then     //no PLUs specified - return all items individually
      begin
          //Res.Add('"' + StockCollectionItem.Description + '","' + IntToStr(StockCollectionItem.Quantity) + '"');  //description, quantity
          Result := Result + StockCollectionItem.Price * StockCollectionItem.Quantity;  //value
      end
      else  //PLUs specified
      begin
        for PLUIndex := 0 to PLUSL.Count-1 do //test this stock item against each PLU range
        begin
          if (StockCollectionItem.PLU >= PLURange[PLUIndex,prFrom]) and (StockCollectionItem.PLU <= PLURange[PLUIndex,prTo]) then //matches a PLU
          begin
            Result := Result + StockCollectionItem.Price * StockCollectionItem.Quantity;  //add current level for this stock item
//            //calculate previous stock level of this stock item

            If (ReqdPeriod > TodaysPeriod ) then //and (DB <> nil) then
               result := 0
            else
               If (ReqdPeriod < TodaysPeriod ) then //and (DB <> nil) then
               begin

                  //subtract all stock txns of this stock item from current level (TheCurrentPeriod) back to the start of the period following the required period
                  With TQueryMap.Create do
                  begin
                    try
                      SelectFields        := 'applyvalue';
                      ResultFields        := 'applyvalue';
                      TotalFields         := 'applyvalue';
                      //StockUsed (=Sold) records are always required for back-calculating from current stock levels


                      UserSearch:='';
                      PosSign := '';
                      NegSign :='-';
                      if (FUser <> 'Supervisor') and (FUser <> 'Vendor') then
                        UserSearch := ' and Teller = '''+FUser+'''' ;


                      if (FUser <> 'Supervisor' ) then //= 'Vendor') then
                      begin
                        PosSign := '-';
                        NegSign :='';
                      end ;

                      if Fuser <> 'Vendor' then
                      begin
                        SQL :=
                              ' select Sum(-TxnValue) as Applyvalue from TxnLog '
                              //+ ' where (PLU = ' + IntToStr(StockCollectionItem.PLU) + ') '
                              + ' where (Description = ''' + StockCollectionItem.Description + ''') '
                              + UserSearch
                              + ' and (RecType = "StockUsed") '
                              + ' and Period >= ' + IntToStr(ReqdPeriod+1) ;

                       // if FUser = 'Supervisor' then
                           SQL := SQL + ' union ' ;

                      end ;

                      //If (FUser = 'Supervisor') or (FUser = 'Vendor') then
                      //begin
                          //remittances in to the supervisor and transfers to the vendors.

                         SQL := SQL
                          + ' select Sum('+PosSign+'TxnValue) as Applyvalue from TxnLog '
                          //+ ' where (PLU = ' + IntToStr(StockCollectionItem.PLU) + ') '
                          + ' where (Description = ''' + StockCollectionItem.Description + ''') '
                          //+ UserSearch
                          + ' and (RecType = "TxStkTo" ) '
                          + ' and Period >=  ' + IntToStr(ReqdPeriod+1)
                          + ' and (Teller = "' + FUser + '")'
                          //remiitances out from supervisor and transfers back from vendors.
                          + ' union'
                          + ' select Sum('+NegSign+'TxnValue) as Applyvalue from TxnLog '
                          //+ ' where (PLU = ' + IntToStr(StockCollectionItem.PLU) + ') '
                          + ' where (Description = ''' + StockCollectionItem.Description + ''') '
                          //+ UserSearch
                          + ' and (RecType = "TxStkFrom" ) '
                          + ' and Period >= ' + IntToStr(ReqdPeriod+1)
                          + ' and (Teller = "' + FUser + '")' ;
                      //end;

                      ClearMaps;
                      TxnsSL.CommaText := Execute;

                    finally
                      Free; //querymap
                    end;
                  end;
                  Result := Result - StrToCurrDef(TxnsSL[TxnsSL.Count -1],0); //last line is total of stock txns
                end;  //stock required for a previous period
              end;  //if this stock item matches a plu
        end;  //if PLUs specified
      end;  //if PLU list given
    end;  //for all stock item

    //PLUs specified - add summary line only
    //if PLUList <> '' then Res.Add('"'+Desc+'","'+CurrToStrF(Result,ffNumber,2)+'"');
  finally
    StockCollection.Free;
    PLUSL.Free;
    TxnsSL.Free;
  end;
end;

function TotalGPCSUserStock : String ;
//totals each GPCS users stock holding
var
  I, J            : Integer ;
  Tot             : Currency ;
  StockListSL     : TPackStringList;
  StockListReturn : TPackStringList ;
  StockLine       : TPackStringList;
begin
  StockListReturn := TPackStringList.Create ;
  StockListSL := TPackStringList.Create;
  StockLine := TPackStringList.Create;

  if (GPCSUsers <> nil) and (GPCSUsers.Count > 0) and Assigned( Stock ) then
  begin
    for I := 0 to GPCSUsers.Count-1 do
    begin
      StockListSL.CommaText := Stock.ListAvailableStock(GPCSUsers[i],'*All');
      Tot:= 0;
      for J := 0 to StockListSL.Count-1 do
      begin
         StockLine.Commatext := StockListSL[j];
         Tot := Tot + (StrToCurrDef(StockLine[1],0)*StrToCurrDef(StockLine[2],0)) ;
      end ;
      if Tot <> 0 then
      begin
         StockLine.Clear;
         StockLine.Add( GPCSUsers[i] );
         StockLine.Add( CurrToStr(Tot) );
         StockListReturn.Add(  StockLine.CommaText ) ;
      end;

    end ;
  end ;

  Result := StockLIstReturn.CommaText ;
  StockListSL.Free ;
  StockListReturn.Free;
  StockLine.Free;
end;

function WeekByUserGrid:TReportGrid;
var
   UserList:TPackStringList;
   SalesItems:TSalesItems;
   UserCount,Day:Integer;
   EntryQty:Integer;
   EntryValue:Currency;
   TotalQty:Integer;
   TotalValue:Currency;
   RepFileName,Name:String;
   ReportsNode:TReportsNode;
   ReportNode:TReportNode;
   FromPeriod,ToPeriod:Integer;
begin
   SalesItems:=TSalesItems.Create;
   Result:=TReportGrid.Create;

   Name:=LocalSharedData.GetVariable('ReportName');
   RepFileName:=GetGPCSRegString('Reports','Definition File','Reports.ids');
   if (Copy(RepFileName,1,1) <> '\') and (Copy(RepFileName,2,1) <> ':') then
      RepFileName:=ApplicationRootPath+RepFileName;
   if FileExists(RepFileName) then
   begin
      ReportsNode:=TReportsNode.Create('Reports',RepFileName,1);
      try
         ReportsNode.ParseFile(ExtractFilePath(RepFileName),RepFileName,1);
         ReportNode:=ReportsNode.ReportNamed(Name);
         if ReportNode <> nil then
         begin
            FromPeriod:=WeekStarting(LocalSharedData.GetVariable('FromPeriod'));//WeekStarting(GetTodayAsPeriod);
            ToPeriod:=FromPeriod+5; // temp set to end of week
            UserList:=TPackStringList.Create;
            SalesItems.Populate('(RecType = ''TxnLine'')','',0,0,UserList); // User,FromPeriod,ToPeriod,UserList);
            for UserCount:=0 to UserList.Count-1 do
            begin
               Result[UserCount,0]:=UserList[UserCount];
               TotalValue:=0;
               TotalQty  :=0;
               for Day:=0 to ToPeriod-FromPeriod do
               begin
                  EntryValue:=StrToCurrDef(GetAllValuesFor(Day+FromPeriod,UserList[UserCount],SalesItems,EntryQty),0);
                  Result[UserCount,Day*2+1]:=CurrToStr(EntryValue);
                  Result[UserCount,Day*2+2]:=IntToStr(EntryQty);
                  Result[UserList.Count,Day*2+1]:=CurrToStr(StrToCurrDef(Result[UserList.Count,Day*2+1],0)+EntryValue);
                  Result[UserList.Count,Day*2+2]:= IntToStr(StrToIntDef (Result[UserList.Count,Day*2+2],0)+EntryQty  );
                  TotalValue:=TotalValue+EntryValue;
                  TotalQty  :=TotalQty  +EntryQty  ;
               end;
               Result[UserCount,13]:=CurrToStr(TotalValue);
               Result[UserCount,14]:=IntToStr(TotalQty);
               Result[UserList.Count,13]:=CurrToStr(StrToCurrDef(Result[UserList.Count,13],0)+TotalValue);
               Result[UserList.Count,14]:= IntToStr(StrToIntDef (Result[UserList.Count,14],0)+TotalQty  );
            end;
            Result[UserList.Count,0]:='Totals';
            UserList.Free;
         end;
      except
         ;
      end;
//      ReportsNode.Free;
//      ReportsNode:=nil;
   end;
   SalesItems.Free;
end;

function WeekStarting(FromPeriod:Integer):Integer;
begin
   Result := FromPeriod - DayOfWeek( StrToDateTime(PeriodToDateStr(FromPeriod)) ) +2 ;
   //Result:=((FromPeriod div 7)*7)+4;
end;



end.
