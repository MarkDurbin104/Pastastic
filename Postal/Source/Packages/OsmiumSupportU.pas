unit OsmiumSupportU;
interface

uses
   Windows,Classes,SysUtils,DBTables,DB,GPCSGUID,StringWrapperU,
   PackStrListU,DBUtil;

const
   Offices:Array[0..113,0..1] of String = (
     ('Head Quarters'   ,'2600'),('Gaborone Central','0101'),('River Walk'      ,'2601'),     
     ('Bontleng'        ,'0102'),('Gaborone Village','0105'),('Ramotswa Village','1101'),
     ('Ramotswa Station','1105'),('Gaborone UB'     ,'2602'),('Broadhurst'      ,'0103'),
     ('Kopong'          ,'1206'),('SSK Airport'     ,'2603'),('Tlokweng'        ,'0701'),
     ('Gaborone Station','0104'),('Gabane'          ,'1205'),('Mogoditshane'    ,'1203'),
     ('Mmankgodi'       ,'1204'),('Thamaga'         ,'1202'),('Ghanzi'          ,'2201'),
     ('Charles hill'    ,'2206'),('Kalfontein'      ,'2202'),('Nojane'          ,'2203'),
     ('Jwaneng'         ,'0601'),('Hukuntsi'        ,'2301'),('Kang'            ,'2303'),
     ('Khakhea'         ,'0907'),('Lehututu'        ,'2307'), ('Mabutsane'      ,'0911'),
     ('Middlepits'      ,'2315'),('Tsabong'         ,'2302'),('Werda'           ,'2304'),
     ('Lobatse'         ,'0301'),('Digawana'        ,'0906'),('Good Hope'       ,'1004'),
     ('Mabule'          ,'0908'),('Otse'            ,'1103'),('Pitsane'         ,'1001'),
     ('Sedibeng'        ,'0953'),('Woodhall'        ,'0302'),('Mochudi'         ,'1301'),
     ('Bokaa'           ,'1302'),('Ntshinoge'       ,'1399'),('Oodi'            ,'1303'),
     ('Sikwane'         ,'1308'),('Molepolole'      ,'1201'),('Letlhakeng'      ,'2501'),
     ('Lentsweletau'    ,'1207'),('Mathubantwa'     ,'1299'),('Motokwe'         ,'2502'),
     ('Sojwe'           ,'1215'),('Thebephatswa'    ,'2604'),('Mmasekou'        ,'0998'),
     ('Kanye'           ,'0901'),('Mafhikana'       ,'1501'),('Moshupa'         ,'0902'),
     ('Mmathethe'       ,'0904'),('Serowe'          ,'1401'),('Moiyabana'       ,'1404'),
     ('Rasebolai'       ,'1499'),('Palapye'         ,'0801'),('Tumasera'        ,'1538'),
     ('Lecheng'         ,'1410'),('Pota'            ,'0802'),('Maokatumo'       ,'1458'),
     ('Sherwood Ranch'  ,'2605'),('Lerala'          ,'1402'),('Moeng'           ,'2606'),
     ('Maunatlala'      ,'1403'),('Ramokgonami'     ,'1506'),('Selebi Phikwe'   ,'0401'),
     ('Sefhophe'        ,'1603'),('Mmadinare'       ,'1601'),('Serule'          ,'1605'),
     ('Tsetsebye'       ,'1927'),('Bobonong'        ,'1602'),('Botshabelo'      ,'0402'),
     ('Semolale'        ,'1607'),('Mahalapye'       ,'0999'),('Mookane'         ,'1507'),
     ('Sefhare'         ,'1503'),('Madiba'          ,'1599'),('Pilikwe'         ,'1510'),
     ('Shoshong'        ,'1502'),('Kalamare'        ,'1505'),('Machaneng'       ,'1509'),
     ('Francistown'     ,'0201'),('Tatitown'        ,'0202'),('Matsiloje'       ,'1921'),
     ('Mathangwane'     ,'1811'),('Nata'            ,'1808'),('Gweta'           ,'1805'),
     ('Sowa'            ,'1891'),('Tutume'          ,'1802'),('Sebina'          ,'1820'),
     ('Nkange'          ,'1804'),('Maitengwe'       ,'1803'),('Masunga'         ,'1907'),
     ('Makaleng'        ,'1914'),('Ramokwebana'     ,'1909'),('Tsesebe'         ,'1604'),
     ('Tonota'          ,'1801'),('Shashe'          ,'1807'),('Monarch'         ,'0203'),
     ('Orapa'           ,'0501'),('Letlhakane'      ,'1701'),('Mopipi'          ,'1703'),
     ('Rakops'          ,'1702'),('Kasane'          ,'2101'),('Kavimba'         ,'2109'),
     ('Maun'            ,'2001'),('Boseja'          ,'2099'),('Sehitwa'         ,'2002'),
     ('Gumare'          ,'2401'),('Etsha'           ,'2402'),('Shakawe'         ,'2403')
   );

type
  TPensionType = ( ptOAPNormal,ptOAPArrears,ptWWVNormal,ptWWVArrears,ptDCANormal,ptDCAArrears);
  TPensionPayment = class(TStringWrapper)
      property PayPoint       :Variant Index  0 read GetElement write SetElement;
      property VoucherNumber  :Variant Index  1 read GetElement write SetElement;
      property ValidFromPeriod:Variant Index  2 read GetElement write SetElement;
      property PensionTypeID  :Variant Index  3 read GetElement write SetElement;
      property PensionTypeName:Variant Index  4 read GetElement write SetElement;
      property IssueNumber    :Variant Index  5 read GetElement write SetElement;
      property ValidToPeriod  :Variant Index  6 read GetElement write SetElement;
      property PensionAmount  :Variant Index  7 read GetElement write SetElement;
      property ArrearsAmount  :Variant Index  8 read GetElement write SetElement;
      property ArrearsPeriod  :Variant Index  9 read GetElement write SetElement;
      property PayeeIdentifier:Variant Index 10 read GetElement write SetElement;
      property PayeeName      :Variant Index 11 read GetElement write SetElement;
      property ProxyIdentifier:Variant Index 12 read GetElement write SetElement;
      property ProxyName      :Variant Index 13 read GetElement write SetElement;
  end;
  TMinPensionPayment = class(TStringWrapper)
  protected
      function GetPackData:String;
      procedure SetPackData(Value:String);
  public
      property PayeeIdentifier:Variant Index 0 read GetElement write SetElement;
      property VoucherNumber  :Variant Index 1 read GetElement write SetElement;
      property Amount         :Variant Index 2 read GetElement write SetElement;
      property PensionType    :Variant Index 3 read GetElement write SetElement;
      property PayeeName      :Variant Index 4 read GetElement write SetElement;
      property ProxyIdentifier:Variant Index 5 read GetElement write SetElement;
      property ProxyName      :Variant Index 6 read GetElement write SetElement;
      property PackData:String read GetPackData write SetPackData;
  end;
function CheckPensionFile(FileName:String;var PayDate:TDateTime;var PensionCount:Integer;var TotalPensionValue:Currency;Contents:TStrings):Boolean;
function ConvertPensionLine(Line:String;PayDate:TDateTime):TPensionPayment;
function PPtoMinPP(PensionPayment:TPensionPayment):TMinPensionPayment;
function PayPointToName(PayPoint:Integer):String;
function NameToPayPoint(PayPointName:String):Integer;
function CreatePensionTables(Database:TDatabase;DBName,Alias,TableBaseName:String):Boolean;
function AddPensionRecord(PensionLine:TPensionPayment):Boolean;
procedure PayPension(VoucherNumber,IssueNumber,PayNumber,PayPoint,PayPeriod,PayeeIdentifier:Integer);
function MakePensionPayment(VoucherNumber,POffice,PayPeriod,PayeeIdentifier:Integer;Amount:Currency;PayeeName:String):Boolean;

implementation
uses
   MOSupportU;

function PPtoMinPP(PensionPayment:TPensionPayment):TMinPensionPayment;
begin
   Result:=TMinPensionPayment.Create;
   Result.PayeeIdentifier:=PensionPayment.PayeeIdentifier;
   Result.VoucherNumber  :=PensionPayment.VoucherNumber  ;
   Result.PayeeName      :=PensionPayment.PayeeName      ;
   Result.ProxyIdentifier:=PensionPayment.ProxyIdentifier;
   Result.ProxyName      :=PensionPayment.ProxyName      ;
   if PensionPayment.PensionTypeName = 'OAP' then
   begin
      if PensionPayment.PensionAmount <> 0 then
      begin
         Result.Amount:=PensionPayment.PensionAmount;
         Result.PensionType:=ptOAPNormal;
      end
      else
      begin
         Result.Amount:=PensionPayment.ArrearsAmount;
         Result.PensionType:=ptOAPArrears;           
      end;
   end   
   else if PensionPayment.PensionTypeName = 'WWV' then
   begin
      if PensionPayment.PensionAmount <> 0 then
      begin
         Result.Amount:=PensionPayment.PensionAmount;
         Result.PensionType:=ptWWVNormal;            
      end
      else
      begin
         Result.Amount:=PensionPayment.ArrearsAmount;
         Result.PensionType:=ptWWVArrears;     
      end;
   end   
   else if PensionPayment.PensionTypeName = 'DCA' then
   begin
      if PensionPayment.PensionAmount <> 0 then
      begin
         Result.Amount:=PensionPayment.PensionAmount;
         Result.PensionType:=ptDCANormal;            
      end
      else
      begin
         Result.Amount:=PensionPayment.ArrearsAmount;
         Result.PensionType:=ptDCAArrears;
      end;
   end;  
end;
function CheckPensionFile(FileName:String;var PayDate:TDateTime;var PensionCount:Integer;var TotalPensionValue:Currency;Contents:TStrings):Boolean;
var
   I:Integer;
   d,m,y:Word;
begin
   Result:=False;
   try
   if not FileExists(FileName) then Exit;
   Contents.LoadFromFile(FileName);
   PensionCount:=0;
   TotalPensionValue:=0;
   for I:=0 to Contents.Count-2 do
   begin
      Inc(PensionCount);
      TotalPensionValue:=TotalPensionValue+(StrToCurr(Copy(Contents[I],185,14)))+(StrToCurr(Copy(Contents[I],199,14)));
   end;
   d:=StrToInt(Copy(Contents[Contents.Count-1],1,2));
   m:=StrToInt(Copy(Contents[Contents.Count-1],3,2));
   y:=StrToInt(Copy(Contents[Contents.Count-1],5,4));
   PayDate:=EncodeDate(y,m,d);
   if (PensionCount = StrToInt(Copy(Contents[Contents.Count-1],19,14)))
   and (TotalPensionValue = StrToCurr(Copy(Contents[Contents.Count-1],33,14))) then
      Result:=True;
   except
      Result:=False;
   end;
   TotalPensionValue:=TotalPensionValue/100;
end;

function NameToPayPoint(PayPointName:String):Integer;
var
   I:Integer;
begin
   for I:=0 to 113 do
   begin
      if Offices[I,0] = PayPointName then
      begin
         Result:=StrToInt(Offices[I,1]);
         Exit;
      end;
   end;
   Result:=0;
end;                       
function PayPointToName(PayPoint:Integer):String;
var
   I:Integer;
begin
   for I:=0 to 113 do
   begin
      if StrToInt(Offices[I,1]) = PayPoint then
      begin
         Result:=Offices[I,0];
         Exit;
      end;
   end;
   Result:='Office '+IntToStr(PayPoint);
end;
function ConvertPensionLine(Line:String;PayDate:TDateTime):TPensionPayment;
var
   d,m,y:Word;
   S:String;
   Table:TTable;
const
   PTypes:TStringList=nil;
begin
   if PTypes = nil then
   begin
      PTypes:=TStringList.Create;
      Table:=TTable.Create(nil);
      Table.DatabaseName:='PSL';
      Table.TableName:='OsmiumType';
      if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
         Table.TableName:='dbo.'+Table.TableName;
      with Table do
      begin
         Table.Active:=True;
         First;
         while not EOF do
         begin
            S:=FieldByName('PensionTypeName').AsString;
            S:=S+IntToHex(FieldByName('ValidFromPeriod').Value,8);
            S:=S+IntToHex(FieldByName('ValidToPeriod'  ).Value,8);
            S:=S+IntToHex(FieldByName('IssueNumber'    ).Value,8);
            S:=S+IntToHex(Trunc(FieldByName('PensionAmount').Value*100),8);
            S:=S+IntToHex(Trunc(FieldByName('ArrearsAmount').Value*100),8);
            S:=S+IntToHex(FieldByName('ArrearsPeriod'  ).Value,8);
            PTypes.AddObject(S,TObject(Integer(FieldByName('PensionTypeID').Value)));
            Next;
         end;
         Table.Active:=False;
      end;
      Table.Free;
   end;
   Result:=nil;
   if Length(Line) <> 212 then Exit;
   Result:=TPensionPayment.Create;
   try
      Result.PayPoint     :=StrToInt (Trim(Copy(Line,4 ,5))); // "PO-NNNN "
      Result.VoucherNumber:=StrToInt (Trim(Copy(Line,9 ,8)));
      Result.IssueNumber  :=DateToPeriod(PayDate);// (StrToInt (Trim(Copy(Line,27,4)))*100)+StrToInt (Trim(Copy(Line,25,2)));

      d:=StrToInt (Trim(Copy(Line,31,2)));
      m:=StrToInt (Trim(Copy(Line,33,2)));
      y:=StrToInt (Trim(Copy(Line,35,4)));
      Result.ValidFromPeriod:=DateToPeriod(EncodeDate(y,m,d));

      d:=StrToInt (Trim(Copy(Line,39,2)));
      m:=StrToInt (Trim(Copy(Line,41,2)));
      y:=StrToInt (Trim(Copy(Line,43,4)));
      Result.ValidToPeriod:=DateToPeriod(EncodeDate(y,m,d))-1;
      Result.PayeeIdentifier:=StrToIntDef(Trim(Copy(Line, 47, 9)),0);
      Result.PayeeName      :=            Trim(Copy(Line, 56,60)) ;
      Result.ProxyIdentifier:=StrToIntDef(Trim(Copy(Line,116, 9)),0);
      Result.ProxyName      :=            Trim(Copy(Line,125,60)) ;
      Result.PensionAmount:=StrToCurr(Trim(Copy(Line,185,14)))/100;
      Result.PensionTypeName:=Trim(Copy(Line,17,8)) ;
      Result.ArrearsAmount:=StrToCurr(Trim(Copy(Line,199,14)))/100;
      if Result.ArrearsAmount <> 0 then
         Result.ArrearsPeriod:=Result.ValidFromPeriod
      else
         Result.ArrearsPeriod:=0;

      S:=Result.PensionTypeName;
      S:=S+IntToHex(Result.ValidFromPeriod,8);
      S:=S+IntToHex(Result.ValidToPeriod  ,8);
      S:=S+IntToHex(Result.IssueNumber    ,8);
      S:=S+IntToHex(Trunc(Result.PensionAmount*100),8);
      S:=S+IntToHex(Trunc(Result.ArrearsAmount*100),8);
      S:=S+IntToHex(Result.ArrearsPeriod,8);
      Result.PensionTypeID:=PTypes.IndexOf(S);
      if Result.PensionTypeID <> -1 then
         Result.PensionTypeID:=Integer(PTypes.Objects[Result.PensionTypeID])
      else
         Result.PensionTypeID:=PTypes.AddObject(S,TObject(PTypes.Count));
   except
      Result.Free;
      Result:=nil;
   end;
end;
function GetQueryElement(Query:String):String;
var
   SL:TPackStringList;
begin
   Result:='';
   SL:=TPackStringList.Create;
   try
      SL.PackText:=QueryToPackText(Query);
      if SL.Count > 0 then
      begin
         Result:=SL[0];
         SL.PackText:=SL[0];
         if SL.Count > 0 then
            Result:=SL[0];
      end;
   finally
      SL.Free;
   end;
end;
function MakePensionPayment(VoucherNumber,POffice,PayPeriod,PayeeIdentifier:Integer;Amount:Currency;PayeeName:String):Boolean;
var
   PaymentNumber,PensionTypeID,IssueNumber:Integer;
begin
   IssueNumber:=-1;
   PaymentNumber:=0;
   PensionTypeID:=StrToIntDef(GetQueryElement('Select PensionTypeID from Osmium where VoucherNumber = '+IntToStr(VoucherNumber)+' and PayeeIdentifier = '+IntToStr(PayeeIdentifier)),-1);
   if PensionTypeID >= 0 then
   begin
      IssueNumber:=StrToIntDef(GetQueryElement('Select IssueNumber from OsmiumType where PensionTypeID = '+IntToStr(PensionTypeID)),-1);
      if IssueNumber >= 0 then
         PaymentNumber:=StrToIntDef(GetQueryElement('Select max(PaymentNumber) from OsmiumPayment where VoucherNumber = '+IntToStr(VoucherNumber)+' and IssueNumber = '+IntToStr(IssueNumber)),0);
   end;
   if IssueNumber < 0 then
      PaymentNumber:=StrToIntDef(GetQueryElement('Select max(PaymentNumber) from OsmiumPayment where VoucherNumber = '+IntToStr(VoucherNumber)),0);
   PayPension(VoucherNumber,IssueNumber,PaymentNumber,POffice,PayPeriod,PayeeIdentifier);
   Result:=True;
end;
procedure PayPension(VoucherNumber,IssueNumber,PayNumber,PayPoint,PayPeriod,PayeeIdentifier:Integer);
var
   OsmiumPayment:TTable;
begin
   OsmiumPayment:=TTable.Create(nil);
   OsmiumPayment.DatabaseName:='PSL';
   OsmiumPayment.TableName:='OsmiumPayment';
   if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
      OsmiumPayment.TableName:='dbo.'+OsmiumPayment.TableName;
   OsmiumPayment.Active:=True;
   with OsmiumPayment do
   begin
      if not FindKey([VoucherNumber,IssueNumber,PayNumber]) then
      begin
         Append;
         FieldByName('VoucherNumber').Value:=VoucherNumber;
         FieldByName('IssueNumber'  ).Value:=IssueNumber  ;
         FieldByName('PaymentNumber').Value:=PayNumber    ;
         FieldByName('PaymentPeriod').Value:=PayPeriod    ;
         FieldByName('PaymentOffice').Value:=PayPoint     ;
         Post;
      end;
   end;
   OsmiumPayment.Active:=False;
   OsmiumPayment.Free;
end;
function AddPensionRecord(PensionLine:TPensionPayment):Boolean;
const
   Osmium:TTable     = nil;
   OsmiumType:TTable = nil;
   OsmiumPayee:TTable= nil;
begin
   if Osmium = nil then
   begin
      Osmium:=TTable.Create(nil);
      Osmium.DatabaseName:='PSL';
      Osmium.TableName:='Osmium';
      if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
         Osmium.TableName:='dbo.'+Osmium.TableName;
      Osmium.Active:=True;

      OsmiumType:=TTable.Create(nil);
      OsmiumType.DatabaseName:='PSL';
      OsmiumType.TableName:='OsmiumType';
      if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
         OsmiumType.TableName:='dbo.'+OsmiumType.TableName;
      OsmiumType.Active:=True;

      OsmiumPayee:=TTable.Create(nil);
      OsmiumPayee.DatabaseName:='PSL';
      OsmiumPayee.TableName:='OsmiumPayee';
      if GetGPCSRegString('Workstation','DBType','Paradox') = 'SQLServer' then
         OsmiumPayee.TableName:='dbo.'+OsmiumPayee.TableName;
      OsmiumPayee.Active:=True;
   end;
   if PensionLine = nil then
   begin
      Osmium.Active:=False;
      Osmium.Free;
      OsmiumType.Active:=False;
      OsmiumType.Free;
      OsmiumPayee.Active:=False;
      OsmiumPayee.Free;
      Osmium:=nil;
      OsmiumType:=nil;
      OsmiumPayee:=nil;
      Result:=True;
      Exit;
   end;

   Result:=False;
   try
      with Osmium do
      begin
         if not FindKey([PensionLine.VoucherNumber,PensionLine.PensionTypeID]) then
         begin
            Append;
            FieldByName('VoucherNumber'  ).Value:=PensionLine.VoucherNumber  ;
            FieldByName('PensionTypeID'  ).Value:=PensionLine.PensionTypeID  ;
            FieldByName('PaymentOffice'  ).Value:=PensionLine.PayPoint       ;
            FieldByName('PayeeIdentifier').Value:=PensionLine.PayeeIdentifier;
            Post;
            Result:=True;
         end;
      end;
      if Result then
      begin
         with OsmiumType do
         begin
            if not FindKey([PensionLine.PensionTypeID]) then
            begin
               Append;
               FieldByName('PensionTypeID'  ).Value:=PensionLine.PensionTypeID  ;
               FieldByName('PensionTypeName').Value:=PensionLine.PensionTypeName;
               FieldByName('PensionAmount'  ).Value:=PensionLine.PensionAmount  ;
               FieldByName('ArrearsAmount'  ).Value:=PensionLine.ArrearsAmount  ;
               FieldByName('ArrearsPeriod'  ).Value:=PensionLine.ArrearsPeriod  ;
               FieldByName('ValidFromPeriod').Value:=PensionLine.ValidFromPeriod;
               FieldByName('ValidToPeriod'  ).Value:=PensionLine.ValidToPeriod  ;
               FieldByName('IssueNumber'    ).Value:=PensionLine.IssueNumber    ;
               Post;
            end;
         end;
         with OsmiumPayee do
         begin
            if not FindKey([PensionLine.PayeeIdentifier]) then
            begin
               Append;
               FieldByName('PayeeIdentifier').Value:=PensionLine.PayeeIdentifier;
               FieldByName('PayeeName'      ).Value:=PensionLine.PayeeName      ;
               FieldByName('ProxyIdentifier').Value:=PensionLine.ProxyIdentifier;
               Post;
               if  (PensionLine.ProxyIdentifier <> 0)
               and (not FindKey([PensionLine.ProxyIdentifier])) then
               begin
                  Append;
                  FieldByName('PayeeIdentifier').Value:=PensionLine.ProxyIdentifier;
                  FieldByName('PayeeName'      ).Value:=PensionLine.ProxyName      ;
                  FieldByName('ProxyIdentifier').Value:=0;
                  Post;
               end;
            end;
         end;
      end;
   finally
   end;
end;
function CreatePensionTables(Database:TDatabase;DBName,Alias,TableBaseName:String):Boolean;
var
   DatabaseType:String;
   Query:TQuery;
   Table:TTable;
begin
   Database.AliasName   :=Alias;
   Database.DatabaseName:=DBName;
   Database.LoginPrompt :=False;
   Database.SessionName :='Default';
   Result:=False;
   // create table of type given by HKLM\Software\PSL\GPCS\Workstation\DBType
   
   DatabaseType:=GetGPCSRegString('Workstation','DBType','Paradox');
   if DatabaseType = 'Paradox' then
   begin
      // create via DBE, this function should use SQL for all table types
      // and use common routines to select field naming syntax for 
      // specific DB types ... one day!
      
      Table:=TTable.Create(nil);
      with Table do
      begin
         try
            Active:=False;
            DatabaseName:=DBName;
            TableType:=ttParadox;
            TableName:=TableBaseName;
            with FieldDefs do
            begin
               Clear; // clear the current field definitions
               Add('VoucherNumber'  ,ftInteger, 0,True );
               Add('PensionTypeID'  ,ftInteger, 0,True );
               Add('PaymentOffice'  ,ftInteger, 0,False);
               Add('PayeeIdentifier',ftInteger, 0,False);
            end;
            with IndexDefs do // create the index
            begin
               Clear;
               Add('','VoucherNumber;PensionTypeID',[ixPrimary,ixUnique]);
            end;
            CreateTable;

            TableName:=TableBaseName+'Type';
            with FieldDefs do
            begin
               Clear; // clear the current field definitions
               Add('PensionTypeID'  ,ftInteger , 0,True );
               Add('PensionTypeName',ftString  ,10,False);
               Add('PensionAmount'  ,ftCurrency, 0,False);
               Add('ArrearsAmount'  ,ftCurrency, 0,False);
               Add('ArrearsPeriod'  ,ftInteger , 0,False);
               Add('ValidFromPeriod',ftInteger , 0,False);
               Add('ValidToPeriod'  ,ftInteger , 0,False);
               Add('IssueNumber'    ,ftInteger , 0,False);
            end;
            with IndexDefs do // create the index
            begin
               Clear;
               Add('','PensionTypeID',[ixPrimary,ixUnique]);
            end;
            CreateTable;

            TableName:=TableBaseName+'Payee';
            with FieldDefs do
            begin
               Clear; // clear the current field definitions
               Add('PayeeIdentifier',ftInteger, 0,True );
               Add('PayeeName'      ,ftString ,60,False);
               Add('ProxyIdentifier',ftInteger, 0,False);
            end;
            with IndexDefs do // create the index
            begin
               Clear;
               Add('','PayeeIdentifier',[ixPrimary,ixUnique]);
            end;
            CreateTable;

            TableName:=TableBaseName+'Payment';
            with FieldDefs do
            begin
               Clear; // clear the current field definitions
               Add('VoucherNumber',ftInteger, 0,True );
               Add('IssueNumber'  ,ftInteger, 0,True );
               Add('PaymentNumber',ftInteger, 0,True );
               Add('PaymentPeriod',ftInteger, 0,False);
               Add('PaymentOffice',ftInteger, 0,False);
            end;
            with IndexDefs do // create the index
            begin
               Clear;
               Add('','VoucherNumber;IssueNumber;PaymentNumber',[ixPrimary,ixUnique]);
            end;
            CreateTable;
            Result:=True;
         finally
         end;
         Table.Free;
      end;
   end
   else if DatabaseType = 'Oracle' then
   begin
      // define fromSQLServer queries later !
   end
   else if DatabaseType = 'SQLServer' then
   begin
      Query:=TQuery.Create(nil);
      try
         Query.DatabaseName:=DBName;
         try
             Query.SQL.Text:='DROP TABLE "'+UpperCase(TableBaseName)+'"';
             Query.ExecSQL;
         except
         end;
         Query.SQL.Text:='CREATE TABLE '+UpperCase(TableBaseName)+'(        '+
                         '   VOUCHERNUMBER   INT      NOT NULL,' +
                         '   PENSIONTYPEID   INT      NOT NULL,' +
                         '   PAYMENTOFFICE   INT      NOT NULL,' +
                         '   PAYEEIDENTIFIER INT      NOT NULL,' +
                         '  CONSTRAINT '+UpperCase(TableBaseName)+'_PINDEX PRIMARY KEY(VOUCHERNUMBER,PENSIONTYPEID));';
         Query.ExecSQL;
         
         try
             Query.SQL.Text:='DROP TABLE "'+UpperCase(TableBaseName+'TYPE')+'"';
             Query.ExecSQL;
         except
         end;
         Query.SQL.Text:='CREATE TABLE '+UpperCase(TableBaseName+'TYPE')+'(        '+
                         '   PENSIONTYPEID    INT      NOT NULL,' +
                         '   PENSIONTYPENAME  CHAR(10) NOT NULL,' +
                         '   PENSIONAMOUNT    MONEY    NOT NULL,' +
                         '   ARREARSAMOUNT    MONEY    NOT NULL,' +
                         '   ARREARSPERIOD    INT      NOT NULL,' +
                         '   VALIDFROMPERIOD  INT      NOT NULL,' +
                         '   VALIDTOPERIOD    INT      NOT NULL,' +
                         '   ISSUENUMBER      INT      NOT NULL,' +
                         '  CONSTRAINT '+UpperCase(TableBaseName+'TYPE')+'_PINDEX PRIMARY KEY(PENSIONTYPEID));';
         Query.ExecSQL;
         
         try           
             Query.SQL.Text:='DROP TABLE "'+UpperCase(TableBaseName+'PAYEE')+'"';
             Query.ExecSQL;
         except
         end;
         Query.SQL.Text:='CREATE TABLE '+UpperCase(TableBaseName+'PAYEE')+'(        '+
                         '   PAYEEIDENTIFIER  INT      NOT NULL,' +
                         '   PAYEENAME        CHAR(60) NOT NULL,' +
                         '   PROXYIDENTIFIER  INT      NOT NULL,' +
                         '  CONSTRAINT '+UpperCase(TableBaseName+'PAYEE')+'_PINDEX PRIMARY KEY(PAYEEIDENTIFIER));';
         Query.ExecSQL;
                       
         try           
             Query.SQL.Text:='DROP TABLE "'+UpperCase(TableBaseName+'PAYMENT')+'"';
             Query.ExecSQL;
         except
         end;
         Query.SQL.Text:='CREATE TABLE '+UpperCase(TableBaseName+'PAYMENT')+'(        '+
                         '   VOUCHERNUMBER   INT      NOT NULL,' +
                         '   ISSUENUMBER     INT      NOT NULL,' +
                         '   PAYMENTNUMBER   INT      NOT NULL,' +
                         '   PAYMENTPERIOD   INT      NOT NULL,' +
                         '   PAYMENTOFFICE   INT      NOT NULL,' +
                         '  CONSTRAINT '+UpperCase(TableBaseName+'PAYMENT')+'_PINDEX PRIMARY KEY(VOUCHERNUMBER,ISSUENUMBER,PAYMENTNUMBER));';
         Query.ExecSQL;
                         
         Query.Free;
      finally
      end;
      Result:=True;
   end;        
end;
{TMinPensionPayment}
function RemExtraSpace(S:String):String;
var
  P:PChar;
begin
   Result:='';
   P:=PChar(S);
   while P^ <> #0 do
   begin
      case P^ of
         ' ' : begin 
                  while P^ = ' ' do Inc(P); 
                  Result:=Result+' '+P^; 
               end;
         ',' : begin 
                  Inc(P);
                  while P^ = ' ' do Inc(P); 
                  Result:=Result+','+P^; 
               end;
         else 
                  Result:=Result+P^;
      end;
      Inc(P);
   end;
end;
function TMinPensionPayment.GetPackData:String;
var
   I:Integer;
   S:String;
   HasProxy:Boolean;
   HexStr:String;
begin
   PayeeName:=RemExtraSpace(PayeeName);
   ProxyName:=RemExtraSpace(ProxyName);
   if (ProxyIdentifier = '') or (ProxyIdentifier = 0) then
      HasProxy:=False
   else
      HasProxy:=True;
   HexStr:=IntToHex(VoucherNumber,8);
   HexStr:=HexStr+IntToHex(PayeeIdentifier,8);
   if PensionType = '' then PensionType:=0;
   if Amount = '' then Amount:=0;
   I:=Trunc(Amount*10000)+PensionType*10+Integer(HasProxy);
   HexStr:=HexStr+IntToHex(I,8);
   if HasProxy then
   begin
      HexStr:=HexStr+IntToHex(ProxyIdentifier,8);
   end;    
   if HasProxy then
      S:=PayeeName+'^'+ProxyName
   else
      S:=PayeeName;
   HexStr:=HexStr+S;
   Result:=HexStr;
end;
procedure TMinPensionPayment.SetPackData(Value:String);
var
   I:Integer;
   S:String;
   HasProxy:Boolean;
begin         
   VoucherNumber  :=StrToInt('$'+Copy(Value, 1,8));
   PayeeIdentifier:=StrToInt('$'+Copy(Value, 9,8));
   I              :=StrToInt('$'+Copy(Value,17,8));
   Amount:=(I div 100) / 100;
   PensionType:=(I div 10) mod 10;
   HasProxy:=Boolean(I mod 10);
   if HasProxy then
   begin
      ProxyIdentifier:=StrToInt('$'+Copy(Value,25,8));
      S:=Copy(Value,33,Length(Value));
      I:=Pos('^',S);
      PayeeName:=Copy(S,1,I-1);
      ProxyName:=Copy(S,I+1,Length(S));
   end
   else
   begin
      PayeeName:=Copy(Value,25,Length(Value));
   end;
end;

end.                                              
                                                  
                                                  
                                                  
                                                  
