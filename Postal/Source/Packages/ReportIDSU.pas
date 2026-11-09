unit ReportIDSU;

interface

uses
  BaseProduct,FileCtrl,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,ComObj,ActiveX,UIDLLSupportU,
  ParseNodeU,ProjectFormFU, ExtCtrls, StdCtrls, PackStrListU, StringUtil,RegistryEx,GPCSErrorLine,
  TxnTranslateU,QueryMapU,GPCSGUID,Printers,Preview,ShareDataU,ReportPreviewF;
  
const
   ReportsLogoKeyName:String = 'Reports';
   HeadersFootersName:String = 'HeadersFooters';
   SavedReports      :String = 'C:\Saved Reports';
   
   HLine             = '!HorizontalLine!';
   DHLine            = '!DoubleHorizontalLine!';
   PBreak            = '!PageBreak!';
type
  TRepHeadCallBack = procedure(CallBackName,ReportName:String;PrintRect:TRect;Canvas:TCanvas;PageNo,NoPages:Integer);
  TColumnJustify = (cjLeft,cjCentre,cjRight,cjEnd,cjStart);
  TColumnNode = class(TCorvusNode)
  private
     function GetWidth:Integer;
     function GetZeroPad:Integer;
     function GetCallBack:String;
  public
     function Heading:String;
     function Justify:TColumnJustify;
     function TotalColumn:Boolean;
     function IsCurrency:Boolean;
     function IsText:Boolean;
     function Round:Boolean;
     function Trunc:Boolean;
     function BlankZeros:Boolean;
     function BlankRepeat:Boolean;
     function LineNumber:Boolean;
     function RowHeadings:Boolean;
     function TotalAcross:Boolean;
     function Order:Boolean;
     function Group:Boolean;
     function Sum:Boolean;
     function Avg:Boolean;
     function Min:Boolean;
     function Max:Boolean;
     function Cnt:Boolean;
     function FillWidth:Boolean;
     function IsPeriod:Boolean;
     function IsMoment:Boolean;
     function RowBreak : String ;
     property ZeroPad:Integer read GetZeroPad;
     property Width:Integer read GetWidth write FWidth;
     property CallBack:String read GetCallBack;
  end;
  TRepCallBack     = function(CallBackName,ColumnName,ReportName,Value:string):String;
//  TRepHeadCallBack = function(CallBackName,ReportName:String;PrintRect:TRect;Canvas:TCanvas):Integer;
  TReportsNode = class;
  TReportNode = class(TCorvusNode)
  private
    FRightAnchor:Boolean;
    FRepCallBack:TRepCallBack;
    FHeadCallBack:TRepHeadCallBack;
    FFootCallBack:TRepHeadCallBack;
    function ActualLineHeight(RowData : TStrings; LineNo : Integer; var NewPage : Boolean):Integer;
    function GetColumn(Index:Integer):TColumnNode;
    function GetColumnName(Index:Integer):String;
    function GetColumnHead(Index:Integer):String;
    function GetColumnWidth(Index:Integer):Integer;
    function GetPLURange(Index:Integer):String;
    function OutputText(Canvas:TCanvas;Text:String;InRect:TRect;PageWidth:Integer;Flags:Integer;Justify:TColumnJustify):Integer;
    procedure TextOutput(Canvas:TCanvas;XPos,YPos:Integer;Text:String;PageWidth:Integer);
    procedure DrawLine(Canvas:TCanvas;X1,Y1,X2,Y2,PageWidth:Integer);
    procedure CopyRectangle(Dest:TCanvas;DestRect:TRect;Source:TCanvas;SourceRect:TRect;PageWidth:Integer);
  public
     ResultCommaText:Boolean;

     function Title:String;
     function TableName:String;
     function Alias:String;
     function Query:String;
     function DataExtractor:String;
     function CSVFile:String;
     function UseRanges:String;
     function PaperType : String;
     function RangesNode:TCorvusNode;
     function HeadingCallBack:String;
     function Header:String;
     function Footer:String;
     function HeadingSize:Integer;
     function FooterCallBack:String;
     function FooterSize:Integer;
     function FirstQuery:String;
     function RequiredTxnTypes:String;
     function SecondQuery:String;
     function ColumnCount:Integer;
     function PLUCount:Integer;
     property PLURange[Index:Integer]:String read GetPLURange;
     function FitWidth   :Boolean;
     function AllLandscape:Boolean;
     function AllPortrait:Boolean;
     function ColumnLines:Boolean;
     function RowLines   :Boolean;
     function ColumnSpacing:Integer;
     function RowSpacing   :Integer;
     function Landscape:Boolean;
     property Column[Index:Integer]:TColumnNode read GetColumn;
     property ColumnName[Index:Integer]:String read GetColumnName;
     property ColumnHead[Index:Integer]:String read GetColumnHead;
     property ColumnWidth[Index:Integer]:Integer read GetColumnWidth;
     function Columns:String;
     function ForceColumns:String;
     function OrderColumns:String;
     function GroupColumns:String;
     function TotalColumns:String;
     function HasTotals:Boolean;
     function PLUs:String;
     function ColumnHeads:String;
     function ColumnWidths:String;
     function AsString:String;
     procedure CheckTotalCurr(TotalLines:TStrings);
     procedure CheckCallBacks(ReportLines:TStrings;RepCallBack:TRepCallBack);
     procedure SetWidthsFromData(Lines:TStrings);
     function CalcNumPages(RowData:TStrings):Integer;
     function  PrintFooter(PageNo,NoPages,TopOffset:Integer;FootCallBack:TRepHeadCallBack):Integer;
     function  PrintHeader(User:String;Office,WorkStation,FromPeriod,ToPeriod,PageNo,NoPages:Integer;HeadCallBack:TRepHeadCallBack):Integer;
     procedure InsertSectionTotals(RowData:TStrings);
     procedure Print(User:String;Office,WorkStation,FromPeriod,ToPeriod:Integer;RowData,Totals:TStrings;RepCallBack:TRepCallBack;HeadCallBack,FootCallBack:TRepHeadCallBack);
     function  Execute(User:String;Office,WorkStation,FromPeriod,ToPeriod:Integer;Summary:Boolean) : String;
     procedure SaveReportData(User:String;Office,WorkStation,FromPeriod,ToPeriod:Integer;Summary:Boolean;ReportLines,TotalLine:TStrings);
     procedure CleanUpReportDirectory;
     function ExecuteOn(User:String;Office,WorkStation,FromPeriod,ToPeriod:Integer;Summary:Boolean;RepCallBack:TRepCallBack;HeadCallBack,FootCallBack:TRepHeadCallBack;PP:TPrintPreview):String;
     procedure PutInJustifys(List:TStrings;Multi:Boolean);
     procedure PutInCalcFields(List:TStrings;Total:Integer);
     constructor Create(Name,FileName:String;LineNumber:Integer); override;
     property RightAnchor:Boolean read FRightAnchor write FRightAnchor;
  end;
  THFItemNode = class(TCorvusNode)
  public
     function ItemType:String;
     function CoordinateSystem:String;
     function XPosition:String;
     function YPosition:String;
     function Data:String;
     function FontName:String;
     function FontSize:Integer;
     function Bold     :Boolean;
     function Italic   :Boolean;
     function Underline:Boolean;
     function StrikeOut:Boolean;
  end;
  THeadFootNode = class(TCorvusNode)
  private
     function GetItem(Index:Integer):THFItemNode;
  public
     function FontName:String;
     function FontSize:Integer;
     function Height:Integer;
     function Title:String;
     function ItemCount:Integer;
     property Item[Index:Integer]:THFItemNode read GetItem;
  end;
  TRangeNode = class(TCorvusNode)
  private
     function GetPLURange(Index:Integer):String;
  public
     function AddTo:String;
     function SubFrom:String;
     function IDDataExtract:String;
     function Title:String;
     function PLUCount:Integer;
     property PLURange[Index:Integer]:String read GetPLURange;
     function PLUs:String;
  end;
  TReportsNode = class(TParseNode)
  private
     FLogo:TBitmap;
     function GetReport(Index:Integer):TReportNode;
  public
     constructor Create(Name,FileName:String;LineNumber:Integer); override;
     destructor Destroy; override;
     function NewCompType(CurrCompType:TCorvusNode;CurrCompTypeName,Tok,FileName:String;LineNumber:Integer):Integer; override;
     function ListReports:String;
     function ListReportNames:String;
     procedure PutInReportTitles(List:TStrings);
     procedure RemoveTitles(List:TStrings);
     function RepCount:Integer;
     property Report[Index:Integer]:TReportNode read GetReport;
     function ReportNamed(Name:String):TReportNode;
     function HeadFootCount:Integer;
     function HeadFootNamed(Name:String):THeadFootNode;
     function GetHeadFoot(Index:Integer):THeadFootNode;
     function RangeCount:Integer;
     function RangeNamed(Name:String):TRangeNode;
     function GetRange(Index:Integer):TRangeNode;
     function ReprintSavedReportOn(FileName:String;RepCallBack:TRepCallBack;HeadCallBack,FootCallBack:TRepHeadCallBack;PP:TPrintPreview):TReportNode;
     property Logo:TBitmap read FLogo write FLogo;
  end;

function ReplaceParams(Delim:Char;ParamStr:String):String;
procedure PopulateReprintList(List:TStrings);

var
   PrintPreview:TPrintPreview;
   PagePrinted:Boolean;
   
const
   UseMsgStoreData  :Boolean = False;
   UsingNewExecute  :Boolean = True;
   MultiSection     :Boolean = False;
   UseLastResults   :Boolean = False;                              
   ShowEmptyReports :Boolean = True;
   JustGetReportData:Boolean = False;
   
implementation

uses ErrorFormFU,MOSupportU,FileTxStatusU;

function PeriodToStr(Period:Integer):String;
begin
   if Period > 730 then // 730 = 01/01/2000
      Result:=DateToStr(Period+DaysUntil_010198)
   else
      Result:=' ';
end;
function DateToPeriod(Date:TDateTime):Integer; 
begin
  Result:=Trunc(Date)-DaysUntil_010198;
end;
function PeriodToDate(Period:Integer):TDateTime; 
begin
  Result:=Period+DaysUntil_010198;
end;
function TodayAsPeriod:Integer;
begin
   Result:=DateToPeriod(Now);
end;
{THFItemNode}
function THFItemNode.CoordinateSystem:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('CoordinateSystem');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0] ;
end;
function THFItemNode.ItemType:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Type');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0] ;
end;
function THFItemNode.FontName:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('FontName');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0] ;
end;
function THFItemNode.FontSize:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('FontSize');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=StrToIntDef(TCorvusNode(Objects[I])[0],0);
end;
function THFItemNode.XPosition:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Position');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0] ;
end;
function THFItemNode.YPosition:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Position');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>1) then
      Result:=TCorvusNode(Objects[I])[1] ;
end;
function THFItemNode.Data:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Data');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0] ;
end;
function THFItemNode.Bold:Boolean;
begin
   Result:=IndexOf('Bold') <> -1;
end;
function THFItemNode.Italic:Boolean;
begin
   Result:=IndexOf('Italic') <> -1;
end;
function THFItemNode.Underline:Boolean;
begin
   Result:=IndexOf('Underline') <> -1;
end;
function THFItemNode.StrikeOut:Boolean;
begin
   Result:=IndexOf('StrikeOut') <> -1;
end;
{THeadFootNode}
function THeadFootNode.GetItem(Index:Integer):THFItemNode;
var
   I:Integer;
begin
   Result:=nil;
   I:=IndexOf('Items');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      if (Index >= 0) and (Index < TCorvusNode(Objects[I]).Count) then
         Result:=THFItemNode(TCorvusNode(Objects[I]).Objects[Index]);
   end;
end;
function THeadFootNode.FontName:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('FontName');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0];
end;
function THeadFootNode.FontSize:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('FontSize');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=StrToIntDef(TCorvusNode(Objects[I])[0],0);
end;
function THeadFootNode.Height:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('Height');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=StrToIntDef(TCorvusNode(Objects[I])[0],0);
end;
function THeadFootNode.Title:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Title');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0] ;
end;
function THeadFootNode.ItemCount:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('Items');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      Result:=TCorvusNode(Objects[I]).Count;
   end;
end;
{TRangeNode}
function TRangeNode.Title:string;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Title');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0] ;
end;
function TRangeNode.AddTo:string;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('AddTo');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=Trim(TCorvusNode(Objects[I]).Text);
end;
function TRangeNode.SubFrom:string;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('SubFrom');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=Trim(TCorvusNode(Objects[I]).Text);
end;
function TRangeNode.IDDataExtract:string;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('IDDataExtract');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0];
end;


function TRangeNode.GetPLURange(Index:Integer):String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('PLURange');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      if (Index > -1) and (Index < TCorvusNode(Objects[I]).Count) then
         Result:=TCorvusNode(Objects[I])[Index];
   end;
end;
function TRangeNode.PLUCount:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('PLURange');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      Result:=TCorvusNode(Objects[I]).Count;
   end;
end;
function TRangeNode.PLUs:String;
var
   I:Integer;
begin
   Result:='';
   for I:=0 to PLUCount-1 do
     if Result = '' then
        Result:=PLURange[I]
     else
        Result:=Result+','+PLURange[I];
end;

{TColumnNode}
function TColumnNode.Heading:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Heading');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0];
end;
function TColumnNode.GetZeroPad:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('ZeroPad');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=StrToIntDef(TCorvusNode(Objects[I])[0],0);
end;
function TColumnNode.GetCallBack:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('CallBack');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0] ;
end;
function TColumnNode.GetWidth:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('Width');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=StrToIntDef(TCorvusNode(Objects[I])[0],0);
   if Result = 0 then
      Result:=FWidth;
   if Result < 0 then
      Result:=(0-Result)*10;
end;
function TColumnNode.Justify:TColumnJustify;
var
   I:Integer;
   S:String;
begin
   Result:=cjLeft;
   I:=IndexOf('Justify');
   //if (I <> -1) and (I < Count-1) then
   //begin
   //   S:=Trim(Get(I+1));
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then

    begin
      S:=TCorvusNode(Objects[I])[0];
      if S = 'Right' then
         Result:=cjRight
      else if S = 'Centre' then
         Result:=cjCentre
      else if S = 'Start' then
         Result:=cjStart
      else if S = 'End' then
         Result:=cjEnd;
   end;
end;
function TColumnNode.TotalColumn:Boolean;
begin
   Result:=IndexOf('Total') <> -1;
end;
function TColumnNode.FillWidth:Boolean;
begin
   Result:=IndexOf('FillWidth') <> -1;
end;
function TColumnNode.Avg:Boolean;
begin
   Result:=IndexOf('Avg') <> -1;
end;
function TColumnNode.Min:Boolean;
begin
   Result:=IndexOf('Min') <> -1;
end;
function TColumnNode.Max:Boolean;
begin
   Result:=IndexOf('Max') <> -1;
end;
function TColumnNode.Cnt:Boolean;
begin
   Result:=IndexOf('Count') <> -1;
end;
function TColumnNode.Sum:Boolean;
begin
   Result:=IndexOf('Sum') <> -1;
end;
function TColumnNode.Order:Boolean;
begin
   Result:=IndexOf('Order') <> -1;
end;
function TColumnNode.Group:Boolean;
begin
   Result:=IndexOf('Group') <> -1;
end;
function TColumnNode.TotalAcross:Boolean;
begin
   Result:=IndexOf('TotalAcross') <> -1;
end;
function TColumnNode.RowHeadings:Boolean;
begin
   Result:=IndexOf('RowHeadings') <> -1;
end;
function TColumnNode.LineNumber:Boolean;
begin
   Result:=IndexOf('LineNumber') <> -1;
end;

function TColumnNode.BlankRepeat:Boolean;
begin
   Result:=IndexOf('BlankRepeat') <> -1;
end;
function TColumnNode.BlankZeros:Boolean;
begin
   Result:=IndexOf('BlankZeros') <> -1;
end;
function TColumnNode.RowBreak:String;
var
  I:Integer;
begin
  Result:='';
  I:=IndexOf('RowBreak');
  if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
    Result := TCorvusNode(Objects[I])[0];
end;
function TColumnNode.Round:Boolean;
begin
   Result:=IndexOf('Round') <> -1;
end;
function TColumnNode.Trunc:Boolean;
begin
   Result:=IndexOf('Trunc') <> -1;
end;
function TColumnNode.IsText:Boolean;
begin
   Result:=IndexOf('Text') <> -1;
end;
function TColumnNode.IsCurrency:Boolean;
begin
   Result:=IndexOf('Currency') <> -1;
end;
function TColumnNode.IsMoment:Boolean;
begin
   Result:=IndexOf('Moment') <> -1;
end;
function TColumnNode.IsPeriod:Boolean;
begin
   Result:=IndexOf('Period') <> -1;
end;
{TReportNode}
constructor TReportNode.Create(Name,FileName:String;LineNumber:Integer) ;
begin
   inherited Create(Name,FileName,LineNumber) ;
   ResultCommaText := False ;
end;
function TReportNode.Landscape:Boolean;
begin
   Result:=IndexOf('Landscape') <> -1;
end;
function TReportNode.RowSpacing:Integer;
var
   I:Integer;
begin
   Result:=200;
   I:=IndexOf('RowSpacing');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=StrToIntDef(TCorvusNode(Objects[I])[0],0);
end;
function TReportNode.ColumnSpacing:Integer;
var
   I:Integer;
begin
   Result:=200;
   I:=IndexOf('ColumnSpacing');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=StrToIntDef(TCorvusNode(Objects[I])[0],0);
end;
function TReportNode.ColumnLines:Boolean;
begin
   Result:=IndexOf('ColumnLines') <> -1;
end;
function TReportNode.RowLines:Boolean;
begin
   Result:=IndexOf('RowLines') <> -1;
end;
function TReportNode.AllLandscape:Boolean;
begin
   Result:=IndexOf('AllLandscape') <> -1;
end;
function TReportNode.AllPortrait:Boolean;
begin
   Result:=IndexOf('AllPortrait') <> -1;
end;
function TReportNode.FitWidth:Boolean;
begin
   Result:=IndexOf('FitWidth') <> -1;
end;
function TReportNode.ForceColumns:String;
var
   I:Integer;
   SL:TStringList;
begin
   SL:=TStringList.Create;
   SL.CommaText:=Columns;
   Result:=SL.CommaText;
   I:=IndexOf('ForceColumns');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      SL.AddStrings(TCorvusNode(Objects[I]));
   end;
   Result:=SL.CommaText;
   SL.Free;
end;    
function TReportNode.PLUCount:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('PLURange');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      Result:=TCorvusNode(Objects[I]).Count;
   end;
end;
function TReportNode.GetPLURange(Index:Integer):String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('PLURange');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      if (Index > -1) and (Index < TCorvusNode(Objects[I]).Count) then
         Result:=TCorvusNode(Objects[I])[Index];
   end;
end;
function TReportNode.GetColumn(Index:Integer):TColumnNode;
var
   I:Integer;
begin
   Result:=nil;
   I:=IndexOf('Columns');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      if (Index >= 0) and (Index < ColumnCount) then
         Result:=TColumnNode(TCorvusNode(Objects[I]).Objects[Index]);
   end;
end;

function TReportNode.GetColumnWidth(Index:Integer):Integer;
begin
   Result:=0;
   if Column[Index] <> nil then
      Result:=Column[Index].Width;
end;
function TReportNode.GetColumnHead(Index:Integer):String;
var
   Just:String;
begin
   Result:='';
   if Column[Index] <> nil then
   begin
      Just:='<';
      if Column[Index].Justify = cjRight then
         Just:='>'
      else if Column[Index].Justify = cjCentre then
         Just:='^'
      else if (Column[Index].Justify = cjStart) and RightAnchor then
         Just:='>';
      Result:=Just+Column[Index].Heading;
   end;
end;
function TReportNode.PLUs:String;
var
   I:Integer;
begin
   Result:='';
   for I:=0 to PLUCount-1 do
     if Result = '' then
        Result:=PLURange[I]
     else
        Result:=Result+','+PLURange[I];
end;

function TReportNode.HasTotals:Boolean;
var
   I:Integer;
begin
   Result:=True;
   for I:=0 to ColumnCount-1 do
   begin
      if (Column[I] <> nil) and (Column[I].TotalColumn) then
         Exit;
   end;
   Result:=False;
end;             
function TReportNode.TotalColumns:String;
var
   I:Integer;
begin
   Result:='';
   for I:=0 to ColumnCount-1 do
   begin
     if (Column[I] <> nil) 
     and (Column[I].TotalColumn) 
     and (not Column[I].LineNumber) 
     and (not Column[I].RowHeadings) 
     and (not Column[I].TotalAcross) then
     begin
        if Result = '' then 
           Result:=ColumnName[I]
        else 
           Result:=Result+','+ColumnName[I];
     end;
  end;
end;

function TReportNode.GroupColumns:String;
var
  I:Integer;
  HasAggrigates:Boolean;
begin
  Result:='';
  With TStringList.Create do
  begin
    HasAggrigates:=False;
    for I:=0 to ColumnCount-1 do
    begin   
       if (Column[I] <> nil) 
       and (Column[I].Sum
       or Column[I].Avg
       or Column[I].Min
       or Column[I].Max
       or Column[I].Cnt) then
       begin
          HasAggrigates:=True;
          Break;
       end;
    end;
    if HasAggrigates then
    begin   
       for I:=0 to ColumnCount-1 do
       begin
         if (Column[I] <> nil) 
         and ((Column[I].Group) 
         or   (not Column[I].Sum) 
         and  (not Column[I].Avg)
         and  (not Column[I].Min) 
         and  (not Column[I].Max) 
         and  (not Column[I].Cnt)) then
           Add(ValidateFieldName(ColumnName[I], SQLReservedWords));
       end;                   
       Result := CommaText;
    end;
  end;
end;
function TReportNode.OrderColumns:String;
var
  I:Integer;
begin
  Result:='';
  With TStringList.Create do
  begin
    for I:=0 to ColumnCount-1 do
    begin
      if (Column[I] <> nil) and (Column[I].Order) then
        Add(ValidateFieldName(ColumnName[I], SQLReservedWords));
    end;
    Result := CommaText;
  end;
end;
function TReportNode.Columns:String;
var
  I         : Integer;
  S:String;
begin
  Result:='';
  With TStringList.Create do
  begin
    for I:=0 to ColumnCount-1 do
    begin
      if (Column[I] <> nil) 
      and ((not Column[I].LineNumber) and 
          (not Column[I].RowHeadings) and
          (not Column[I].TotalAcross)) then
      begin
        S:=ValidateFieldName(ColumnName[I], SQLReservedWords);
        if (Column[I].Sum) then
           Add('Sum('+S+')')
        else if (Column[I].Avg) then
           Add('Avg('+S+')')
        else if (Column[I].Min) then
           Add('Min('+S+')')
        else if (Column[I].Max) then
           Add('Max('+S+')')
        else if (Column[I].Cnt) then
           Add('Count('+S+')')
        else
           Add(S);
      end;
    end;
    Result := CommaText;
  end;
end;

function TReportNode.ColumnHeads:String;
var
   I:Integer;
begin
   if UsingNewExecute then
      Result:=''
   else
      Result:='""';
      
   for I:=0 to ColumnCount-1 do
     if Result = '' then 
        Result:='"'+ColumnHead[I]+'"'
     else 
        Result:=Result+',"'+ColumnHead[I]+'"';
end;
function TReportNode.ColumnWidths:String;
var
   I:Integer;
begin
   if UsingNewExecute then
      Result:=''
   else
      Result:='0';
   for I:=0 to ColumnCount-1 do
     if Result = '' then
        Result:=IntToStr(ColumnWidth[I]) 
     else 
        Result:=Result+','+IntToStr(ColumnWidth[I]);
end;
function TReportNode.GetColumnName(Index:Integer):String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Columns');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      if (Index >= 0) and (Index < ColumnCount) then
         Result:=TCorvusNode(Objects[I])[Index];
   end;
   if Result = 'DateTime' then Result:='TxnDateTime';
end;
function TReportNode.ColumnCount:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('Columns');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      Result:=TCorvusNode(Objects[I]).Count;
   end;
end;
function TReportNode.SecondQuery:string;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('SecondQuery');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=Trim(TCorvusNode(Objects[I]).Text);
end;
function TReportNode.TableName:string;
var
   I:Integer;
begin
   Result:='ReportResult';
   I:=IndexOf('TableName');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=Trim(TCorvusNode(Objects[I])[0]);
end;
function TReportNode.Alias:String;
var
   I:Integer;
begin
   Result:='PSL';
   I:=IndexOf('Alias');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=Trim(TCorvusNode(Objects[I])[0]);
end;
function TReportNode.FooterSize:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('FooterCallBack');
   if I = -1 then I:=IndexOf('FooterCallBack');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count > 1) then
      Result:=StrToIntDef(Trim(TCorvusNode(Objects[I])[1]),Result);
end;
function TReportNode.FooterCallBack:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('FooterCallBack');
   if I = -1 then I:=IndexOf('FooterCallBack');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count > 0) then
      Result:=Trim(TCorvusNode(Objects[I])[0]);
end;
function TReportNode.HeadingSize:Integer;
var
   I:Integer;
begin
   Result:=4000;
   I:=IndexOf('HeadingCallBack');
   if I = -1 then I:=IndexOf('HeaderCallBack');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count > 1) then
      Result:=StrToIntDef(Trim(TCorvusNode(Objects[I])[1]),Result);
end;
function TReportNode.HeadingCallBack:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('HeadingCallBack');
   if I = -1 then I:=IndexOf('HeaderCallBack');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count > 0) then
      Result:=Trim(TCorvusNode(Objects[I])[0]);
end;
function TReportNode.Header:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Header');
   if I = -1 then I:=IndexOf('Heading');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count > 0) then
      Result:=Trim(TCorvusNode(Objects[I])[0]);
end;
function TReportNode.Footer:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Footer');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count > 0) then
      Result:=Trim(TCorvusNode(Objects[I])[0]);
end;


function TReportNode.UseRanges:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('UseRanges');
   if (I <> -1) and (Objects[I] <> nil) and (TObject(Objects[I]).ClassName = 'TCorvusNode') then
      Result:=Trim(TCorvusNode(Objects[I]).Text);
end;
function TReportNode.RangesNode:TCorvusNode;
var
   I:Integer;
begin
   Result:=nil;
   I:=IndexOf('UseRanges');
   if (I <> -1) and (Objects[I] <> nil) and (TObject(Objects[I]).ClassName = 'TCorvusNode') then
      Result:=TCorvusNode(Objects[I]);
end;

function TReportNode.CSVFile:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('CSVFile');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=Trim(TCorvusNode(Objects[I])[0]);
end;
function TReportNode.PaperType:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('PaperType');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=Trim(TCorvusNode(Objects[I])[0]);
end;
function TReportNode.DataExtractor:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('DataExtractor');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=Trim(TCorvusNode(Objects[I])[0]);
end;
function TReportNode.Query:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Query');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=Trim(TCorvusNode(Objects[I]).Text);
end;
function TReportNode.RequiredTxnTypes:String;
var
   I:Integer;
begin
   Result:='TxnLine,TxnTotal';
   I:=IndexOf('RequiredTxnTypes');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=Trim(TCorvusNode(Objects[I]).Text);
end;
function TReportNode.FirstQuery:string;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('FirstQuery');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=Trim(TCorvusNode(Objects[I]).Text);
end;
function TReportNode.Title:string;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Title');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=Trim(TCorvusNode(Objects[I])[0]);

end;
function TReportNode.AsString:String;
var
   SL:TStringList;
   I:Integer;
   S:String;
begin
   SL:=TStringList.Create;
   SL.Add(Name+' {');
   if Landscape then
      SL.Add('   Landscape');
   if FitWidth then
      SL.Add('   FitWidth');
   SL.Add('   Title { '''+Title+''' }');
   SL.Add('   PLURange { ');
   for I:=0 to PLUCount-1 do
      SL.Add('     '+PLURange[I]);
   SL.Add('   }');
   SL.Add('   Columns { ');             
   for I:=0 to ColumnCount-1 do
   begin
      if Column[I] <> nil then
      begin
         S:='      '+Column[I].Name+' {';
         if Column[I].Width <> 0 then
            S:=S+' Width { '+IntToStr(Column[I].Width)+' }';
         if Column[I].Justify = cjRight then 
            S:=S+' Justify { Right }'
         else if Column[I].Justify = cjCentre then 
            S:=S+' Justify { Centre }'
         else if Column[I].Justify = cjStart then 
            S:=S+' Justify { Start }'
         else if Column[I].Justify = cjEnd then 
            S:=S+' Justify { End }';
         if Column[I].TotalColumn then S:=S+' Total';
         SL.Add(S+' }');
      end
      else
         SL.Add('     '+ColumnName[I]);
   end;           
   SL.Add('   }');
   SL.Add('}');
   Result:=SL.Text;
   SL.Free;
end;
procedure TReportNode.PutInJustifys(List:TStrings;Multi:Boolean);
var
   I,J:Integer;
   SL:TStringList;
   Just:String;
begin
   if List.Count = 0 then Exit;
   SL:=TStringList.Create;
   if Multi then
   begin
      for I:=0 to List.Count-1 do
      begin
         SL.CommaText:=List[I];
         for J:=0 to SL.Count-1 do 
         begin
            if Trim(SL[J]) <> '' then
            begin
               Just:='<';
               if Column[J] <> nil then
               begin
                  if Column[J].Justify = cjRight then
                     Just:='>'
                  else if (Column[J].Justify = cjStart) and RightAnchor then
                     Just:='>'
                  else if Column[J].Justify = cjCentre then
                     Just:='^';
               end;
               SL[J]:=Just+SL[J];
            end;
         end;
         if not UsingNewExecute then
            SL.Insert(0,' ');
         List[I]:=SL.CommaText;
      end;
   end
   else
   begin
      for I:=0 to List.Count-1 do
      begin
         if (Trim(List[I]) <> '') and (Trim(List[I]) <> '""') then
         begin
            Just:='<';    
            if Column[I] <> nil then
            begin
               if Column[I].Justify = cjRight then
                  Just:='>'
               else if (Column[I].Justify = cjStart) and RightAnchor then
                  Just:='>'
               else if Column[I].Justify = cjCentre then
                  Just:='^';
            end;                                  
            List[I]:=Just+List[I];
         end;
      end;
      if not UsingNewExecute then
         List.Insert(0,'""');
   end;
   SL.Free;
end;
procedure TReportNode.PutInCalcFields(List:TStrings;Total:Integer);
var
   I,J:Integer;
   SL:TStringList;
   Leave:Boolean;
   LineNumberReq :Boolean;
   TotalAcrossReq:Boolean;
   TotalAmount:Currency;
begin
   if List.Count = 0 then Exit;
   Leave:=True;
   LineNumberReq :=False;            
   TotalAcrossReq:=False;            
   for J:=0 to ColumnCount-1 do 
   begin
      if (Column[J] <> nil) 
      and ((Column[J].LineNumber) or (Column[J].TotalAcross)) then
      begin
         Leave:=False;            
         if Column[J].LineNumber  then LineNumberReq :=True;
         if Column[J].TotalAcross then TotalAcrossReq:=True;
         break;
      end;
   end;
   if Leave then Exit;
   
   if Total = -1 then
   begin
      SL:=TStringList.Create;
      for I:=0 to List.Count-1 do
      begin
         SL.CommaText:=List[I];
         if LineNumberReq then
         begin
            for J:=0 to ColumnCount-1 do 
            begin
               if (Column[J] <> nil) and (Column[J].LineNumber) then
               begin
                  if J < SL.Count then
                     SL.Insert(J,IntToStr(I+1))
                  else
                     SL.Add(IntToStr(I+1));
               end;   
            end;
         end;
         if TotalAcrossReq then
         begin
            TotalAmount:=0;
            for J:=0 to ColumnCount-1 do 
            begin
               if (SL.Count > J) and (Column[J] <> nil) and (Column[J].TotalColumn) then
                  TotalAmount:=TotalAmount+StrToCurrDef(SL[J],0);
            end;
            for J:=0 to ColumnCount-1 do 
            begin
               if (Column[J] <> nil) and (Column[J].TotalAcross) then
               begin
                  if J < SL.Count then
                     SL.Insert(J,CurrToStr(TotalAmount))
                  else
                     SL.Add(CurrToStr(TotalAmount));
               end;   
            end;
         end;
         List[I]:=SL.CommaText;
      end;
      SL.Free;
   end
   else
   begin
      if LineNumberReq then
      begin
         for J:=0 to ColumnCount-1 do 
         begin
            if (Column[J] <> nil) and (Column[J].LineNumber) then
            begin
               if J < List.Count then
                  List.Insert(J,IntToStr(Total))
               else
                  List.Add(IntToStr(Total));
            end;
         end;
      end;
      if TotalAcrossReq then
      begin
         TotalAmount:=0;
         for J:=0 to ColumnCount-1 do 
         begin
            if (Column[J] <> nil) and (Column[J].TotalColumn) and (not Column[J].TotalAcross) then
               TotalAmount:=TotalAmount+StrToCurrDef(List[J],0);
         end;
         for J:=0 to ColumnCount-1 do 
         begin
            if (Column[J] <> nil) and (Column[J].TotalAcross) then
            begin
               if J < List.Count then
                  List.Insert(J,CurrToStr(TotalAmount))
               else
                  List.Add(CurrToStr(TotalAmount));
            end;   
         end;
      end;
   end;
end;
procedure TReportNode.SetWidthsFromData(Lines:TStrings);
var
   I,J,W,CS:Integer;
   SL:TPackStringList;
   Widths:Array[0..10000] of Integer;
begin
   CS:=ColumnSpacing div 2;
   SL:=TPackStringList.Create;
   for I:=0 to ColumnCount-1 do
   begin
      if Column[I] <> nil then
         SL.Add(Column[I].Heading)
      else
         SL.Add(' ');
   end;
   Lines.Insert(0,SL.CommaText);
   PrintPreview.Canvas.Font.Style:=[];
   PrintPreview.Canvas.Font.Size:=10;
   SL.Clear;
   for I:=0 to Lines.Count-1 do
   begin
      SL.CommaText:=Lines[I];
      if I = 0 then
      begin
         for J:=0 to SL.Count-1 do
            Widths[J]:=0;
      end;
      for J:=0 to SL.Count-1 do
      begin
         if Trim(SL[J]) <> '' then
         begin
            W:=CS+(PrintPreview.Canvas.TextWidth(Trim(SL[J])+'.'));
            if W > Widths[J] then
               Widths[J]:=W;
         end;
      end;
   end;
   Lines.Delete(0);
   for I:=0 to ColumnCount-1 do
   begin
      if Column[I] <> nil then
      begin
         Column[I].Width:=Widths[I];
      end;
   end;
end;
procedure ReplaceStr(Tok:String;var InStr:String;WithStr:String);
var
   IPos:Integer;
begin
   if Pos(Tok,WithStr) <> 0 then Exit;

   IPos:=Pos(Tok,InStr);
   while IPos <> 0 do
   begin
      InStr:=Copy(InStr,1,IPos-1)+WithStr+Copy(InStr,IPos+Length(Tok),Length(InStr));
      IPos:=Pos(Tok,InStr);
   end;
end;
procedure TReportNode.CheckTotalCurr(TotalLines:TStrings);
var
   I:Integer;
begin
   for I:=0 to ColumnCount-1 do
   begin
      if (Column[I] <> nil) and (Column[I].TotalColumn) and (TotalLines.Count > I) then
      begin
         if (Column[I].BlankZeros) and (StrToCurrDef(TotalLines[I],0) = 0) then
         begin
            TotalLines[I]:='';
         end
         else if (Column[I].IsCurrency) then
         begin
            TotalLines[I]:=CurrToStrF(StrToCurrDef(TotalLines[I],0),ffNumber,2);
         end
         else if (Column[I].Trunc) then
         begin
            TotalLines[I]:=IntToStr(Trunc(StrToCurrDef(TotalLines[I],0)));
         end
         else if (Column[I].Round) then
         begin
            TotalLines[I]:=IntToStr(Round(StrToCurrDef(TotalLines[I],0)));
         end;
      end;
   end
end;
procedure TReportNode.CheckCallBacks(ReportLines:TStrings;RepCallBack:TRepCallBack);
var
   I,J:Integer;
   SL:TStringList;
   PrevLine:String;
begin
   SL :=TStringList.Create;
   for I:=0 to ColumnCount-1 do
   begin
      if (Column[I] <> nil) then
      begin
         if (Column[I].IsPeriod) then
         begin
            for J:=0 to ReportLines.Count-1 do
            begin
               SL.CommaText:=ReportLines[J];
               if SL.Count > I then
               begin
                  SL[I]:=PeriodToStr(StrToIntDef(SL[I],TodayAsPeriod));
                  ReportLines[J]:=SL.CommaText;
               end;
            end;
         end;
         if (Column[I].IsMoment) then
         begin
            for J:=0 to ReportLines.Count-1 do
            begin
               SL.CommaText:=ReportLines[J];
               if SL.Count > I then
               begin
                  SL[I]:=FormatDateTime('dd/mm/yy hh:nn',MomentToDateTime(StrToIntDef(SL[I],0)));
                  ReportLines[J]:=SL.CommaText;
               end;
            end;
         end;
         if (Column[I].Trunc) then
         begin
            for J:=0 to ReportLines.Count-1 do
            begin
               SL.CommaText:=ReportLines[J];
               if SL.Count > I then
               begin
                  SL[I]:=IntToStr(Trunc(StrToCurrDef(SL[I],0)));
                  ReportLines[J]:=SL.CommaText;
               end;
            end;
         end;
         if (Column[I].Round) then
         begin
            for J:=0 to ReportLines.Count-1 do
            begin
               SL.CommaText:=ReportLines[J];
               if SL.Count > I then
               begin
                  SL[I]:=IntToStr(Trunc(StrToCurrDef(SL[I],0)));
                  ReportLines[J]:=SL.CommaText;
               end;
            end;
         end;
         if (Column[I].IsText) then
         begin
            for J:=0 to ReportLines.Count-1 do
            begin
               SL.CommaText:=ReportLines[J];
               if SL.Count > I then
               begin
                  if StrToCurrDef(SL[I],-1) <> -1 then
                     if not HasGotAlphaChar( sl[i] ) then
                        SL[I]:=CurrToStrF(StrToCurrDef(SL[I],-1),ffFixed,0);
                  ReportLines[J]:=SL.CommaText;
               end;
            end;
         end;
         if (Column[I].IsCurrency) then
         begin
            for J:=0 to ReportLines.Count-1 do
            begin
               SL.CommaText:=ReportLines[J];
               if SL.Count > I then
               begin
                  SL[I]:=CurrToStrF(StrToCurrDef(SL[I],0),ffNumber,2);
                  ReportLines[J]:=SL.CommaText;
               end;
            end;
         end;
         if Column[I].ZeroPad <> 0 then
         begin
            for J:=0 to ReportLines.Count-1 do
            begin
               SL.CommaText:=ReportLines[J];
               if SL.Count > I then
               begin
                  SL[I]:=LeftPad(SL[I],Column[I].ZeroPad,'0');
                  ReportLines[J]:=SL.CommaText;
               end;
            end;
         end;
         if (Column[I].BlankRepeat) then
         begin
            PrevLine:='*-*-*';
            for J:=0 to ReportLines.Count-1 do
            begin
               SL.CommaText:=ReportLines[J];
               if SL.Count > I then
               begin
                  if PrevLine = Trim(SL[I]) then
                     SL[I]:=''
                  else
                     PrevLine:=Trim(SL[I]);
                  ReportLines[J]:=SL.CommaText;
               end;
            end;
         end;
         if (Column[I].BlankZeros) then
         begin
            for J:=0 to ReportLines.Count-1 do
            begin
               SL.CommaText:=ReportLines[J];
               if SL.Count > I then
               begin
                  if StrToCurrDef(SL[I],0) = 0 then SL[I]:='';
                  ReportLines[J]:=SL.CommaText;
               end;
            end;
         end;
         if (@RepCallBack <> nil) and (Column[I].CallBack <> '') then
         begin
            for J:=0 to ReportLines.Count-1 do
            begin
               SL.CommaText:=ReportLines[J];
               if SL.Count > I then
               begin
                  SL[I]:=RepCallBack(Column[I].CallBack,Column[I].Name,Name,SL[I]);
                  ReportLines[J]:=SL.CommaText;
               end;
            end;
         end
      end;
   end;
   SL.Free;
end;
function TReportNode.ExecuteOn(User:String;Office,WorkStation,FromPeriod,ToPeriod:Integer;Summary:Boolean;RepCallBack:TRepCallBack;HeadCallBack,FootCallBack:TRepHeadCallBack;PP:TPrintPreview):String;
begin
   Result:='';
   if PP = nil then
      PrintPreview:=TPrintPreview.Create(nil)
   else
      PrintPreview:=PP;
   FRepCallBack :=RepCallBack ;
   FHeadCallBack:=HeadCallBack;
   FFootCallBack:=FootCallBack;  
   try 
      Result:=Execute(User,Office,WorkStation,FromPeriod,ToPeriod,Summary);
   except
      on E:Exception do
         RaiseGUIDException('{C8521F70-4844-4E47-86DA-E9091A30224A}',E);
   end;
   
   if PP = nil then PrintPreview.Free;
end;
function ReplaceParams(Delim:Char;ParamStr:String):String;
var
   P:PChar;
   SP:PChar;
   ParamData:String;
   ParamName:String;
begin
   Result:=ParamStr;
   if LocalSharedData = nil then
      LocalSharedData:=TSharedData.Create('CorvusReportShare',False);
   //ensure UIDLLSupport variable is setup
   If SharedData = nil then
      SharedData := LocalSharedData;
   P:=PChar(ParamStr);
   Result:='';
   while P^ <> #0 do
   begin
      if P^ = Delim then
      begin
         Inc(P);
         if P^ <> Delim then
         begin
            SP:=P;
            while (P^ <> #0) and (P^ <> Delim) do Inc(P);
            if P <> #0 then
            begin
               SetString(ParamName,SP,P-SP);
               if UpperCase(Copy(ParamName,1,5)) = 'FORM.' then
                  ParamData:=GetFieldContents(Copy(ParamName,6,Length(ParamName)))
               else
                  ParamData:=LocalSharedData.GetVariable(ParamName);
               Result:=Result+ParamData;
            end;
         end
         else
         begin
            Result:=Result+P^;
         end;
      end
      else
         Result:=Result+P^;
      Inc(P);
   end;
end;
function TReportNode.PrintFooter(PageNo,NoPages,TopOffset:Integer;FootCallBack:TRepHeadCallBack):Integer;
var
   FR:TRect;
begin
   Result:=FooterSize;
   if (FooterCallBack <> '') and (@FootCallBack <> nil) then
   begin
//      FR:=PrintPreview.PageRect;
      FR:=PrintPreview.PrintBounds;
      FR.Top:=TopOffset;
      FootCallBack(FooterCallBack,Name,FR,PrintPreview.Canvas,PageNo,NoPages);
   end;
end;
function TReportNode.PrintHeader(User:String;Office,WorkStation,FromPeriod,ToPeriod,PageNo,NoPages:Integer;HeadCallBack:TRepHeadCallBack):Integer;
var
   I,LM,LC,RM,RC  :Integer;
   XOfs,YOfs,FS,CTR :Integer;
   SysTitle,OfficeName:String;
   SR,DR:TRect;
   Logo:TBitmap;
   PN:TReportsNode;
   HN:THeadFootNode;
   HFItemNode:THFItemNode;
   IJ:TColumnJustify;
   BMP:TBitmap;
   Font:TFont;
   DataStr:String;
begin
   Result:=HeadingSize;
   if (HeadingCallBack <> '') and (@HeadCallBack <> nil) then
   begin
      HeadCallBack(HeadingCallBack,Name,PrintPreview.PrintBounds,PrintPreview.Canvas,PageNo,NoPages);
//      HeadCallBack(HeadingCallBack,Name,PrintPreview.PrintBounds,PrintPreview.Canvas,PageNo,NoPages);
   end
   else if Header <> '' then
   begin
      if (ParentNode <> nil) then
      begin
         Font:=TFont.Create;
         Font.Assign(PrintPreview.Canvas.Font);
         try
            PN:=(ParentNode.ParentNode as TReportsNode);
            HN:=PN.HeadFootNamed(Header);
            if HN <> nil then
            begin
               if HN.Height <> 0 then Result:=HN.Height;
               for I:=0 to HN.ItemCount-1 do
               begin
                  HFItemNode:=HN.Item[I];
                  XOfs:=0;
                  IJ:=cjLeft;
                  if HFItemNode.XPosition = 'Right' then
                  begin
                     IJ:=cjRight;
                     XOfs:=PrintPreview.PrintBounds.Right;
//                     XOfs:=PrintPreview.PrintBounds.Right;
                  end
                  else if HFItemNode.XPosition = 'Centre' then
                  begin
                     IJ:=cjCentre;
                     XOfs:=PrintPreview.PrintBounds.Left+((PrintPreview.PrintBounds.Right-PrintPreview.PrintBounds.Left) div 2)
//                     XOfs:=PrintPreview.PrintBounds.Left+((PrintPreview.PrintBounds.Right-PrintPreview.PrintBounds.Left) div 2)
                  end
                  else if HFItemNode.XPosition <> 'Left' then
                  begin
//                     XOfs:=PrintPreview.PrintBounds.Left+StrToIntDef(HFItemNode.XPosition,0);
                     XOfs:=PrintPreview.PrintBounds.Left+StrToIntDef(HFItemNode.XPosition,0);
                  end;
//                  YOfs:=PrintPreview.PrintBounds.Top+StrToIntDef(HFItemNode.YPosition,0);
                  YOfs:=PrintPreview.PrintBounds.Top+StrToIntDef(HFItemNode.YPosition,0);

                  if HFItemNode.ItemType = 'Text' then
                  begin
                     if LocalSharedData <> nil then                 
                     begin                                          
                        LocalSharedData.SetVariable('WorkStation'   ,WorkStation);
                        LocalSharedData.SetVariable('FromPeriod'    ,FromPeriod );
                        LocalSharedData.SetVariable('ToPeriod'      ,ToPeriod   );
                        LocalSharedData.SetVariable('Title'         ,Title      );
                        LocalSharedData.SetVariable('SysTitle'      ,GetGPCSRegString('OfficeInfo','Title',''));
                        LocalSharedData.SetVariable('OfficeAdd1'    ,GetGPCSRegString('OfficeInfo','Address Line 1',''));
                        LocalSharedData.SetVariable('OfficeAdd2'    ,GetGPCSRegString('OfficeInfo','Address Line 2',''));
                        LocalSharedData.SetVariable('ThisOfficeName',GetGPCSRegString('OfficeInfo','Office Name',''));
                        LocalSharedData.SetVariable('PageNumber'    ,PageNo     );
                        LocalSharedData.SetVariable('NumberOfPages' ,NoPages    );
                        if Office = 0 then
                           LocalSharedData.SetVariable('OfficeName' ,'All')
                        else
                           LocalSharedData.SetVariable('OfficeName' ,TTxnTransfer.OfficeName(Office));
                        LocalSharedData.SetVariable('OfficeCode'    ,Office     );
                        LocalSharedData.SetVariable('NowDT'         ,DateTimeToStr(Now));
                        LocalSharedData.SetVariable('NowSD'         ,FormatDateTime('dd/mm/yyyy',Now));
                        if User = '' then User:='All';
                        LocalSharedData.SetVariable('User'          ,User       );
                     end;
                     DataStr:=ReplaceParams(':',HFItemNode.Data);
                     with PrintPreview.Canvas do
                     begin
                        if HN.FontSize <> 0  then Font.Size:=HN.FontSize;
                        if HN.FontName <> '' then Font.Name:=HN.FontName;
                        Font.Style:=[];
                        if HFItemNode.FontName <> '' then Font.Name:=HFItemNode.FontName;
                        if HFItemNode.FontSize <> 0  then Font.Size:=HFItemNode.FontSize;
                        if HFItemNode.Bold      then Font.Style:=Font.Style+[fsBold     ];
                        if HFItemNode.Italic    then Font.Style:=Font.Style+[fsItalic   ];
                        if HFItemNode.Underline then Font.Style:=Font.Style+[fsUnderline];
                        if HFItemNode.StrikeOut then Font.Style:=Font.Style+[fsStrikeOut];
                        if (IJ = cjLeft) and (HFItemNode.CoordinateSystem = 'TopRight') or (HFItemNode.CoordinateSystem = 'BottomRight') then
                           XOfs:=(PrintPreview.PrintBounds.Right-XOfs)-TextWidth(DataStr);
//                           XOfs:=(PrintPreview.PrintBounds.Right-XOfs)-TextWidth(DataStr);
                        if (IJ = cjLeft) and (HFItemNode.CoordinateSystem = 'BottomLeft') or (HFItemNode.CoordinateSystem = 'BottomRight') then
                           YOfs:=(PrintPreview.PrintBounds.Bottom-YOfs)-TextHeight(DataStr);
//                           YOfs:=(PrintPreview.PrintBounds.Bottom-YOfs)-TextHeight(DataStr);

                        case IJ of
                           cjLeft   : TextOutput(PrintPreview.Canvas,XOfs,YOfs,DataStr,PrintPreview.PaperWidth);
                           cjRight  : TextOutput(PrintPreview.Canvas,XOfs-TextWidth(DataStr),YOfs,DataStr,PrintPreview.PaperWidth);
                           cjCentre : TextOutput(PrintPreview.Canvas,XOfs-(TextWidth(DataStr) div 2),YOfs,DataStr,PrintPreview.PaperWidth);
                        end;
                     end;
                     PrintPreview.Canvas.Font.Assign(Font);
                  end
                  else if HFItemNode.ItemType = 'Bitmap' then
                  begin
                     if FileExists(HFItemNode.Data) then
                     begin
                        BMP:=TBitmap.Create;
                        BMP.LoadFromFile(HFItemNode.Data);
                        SR:=Bounds(0,0,BMP.Width,BMP.Height);
                        DR:=Bounds(XOfs,YOfs,BMP.Width*10,BMP.Height*10);
                        CopyRectangle(PrintPreview.Canvas,DR,BMP.Canvas,SR,PrintPreview.PaperWidth);
//                        PrintPreview.Canvas.CopyRect(DR,BMP.Canvas,SR);
                        BMP.Free;
                     end;
                  end;
               end;
            end;
         finally
            PrintPreview.Canvas.Font.Assign(Font);
            Font.Free;     
         end;
      end;
   end
   else
   begin
      PN:=nil;
      if (ParentNode <> nil) then
         PN:=(ParentNode.ParentNode as TReportsNode);
      YOfs:=PrintPreview.PrintBounds.Top;
//      YOfs:=PrintPreview.PrintBounds.Top;
      LM :=PrintPreview.PrintBounds.Left;  
//      LM :=PrintPreview.PrintBounds.Left;
      if (PN <> nil) and (PN.Logo <> nil) then
      begin
         Logo:=PN.Logo;
         SR:=Bounds(0,0,Logo.Width,Logo.Height);
         DR:=Bounds(YOfs,YOfs,Logo.Width*10,Logo.Height*10);
         CopyRectangle(PrintPreview.Canvas,DR,Logo.Canvas,SR,PrintPreview.PaperWidth);
//         PrintPreview.Canvas.CopyRect(DR,Logo.Canvas,SR);
         Inc(LM,Logo.Width*10);
      end;
      RM :=PrintPreview.PrintBounds.Right;
//      RM :=PrintPreview.PrintBounds.Right;
      CTR:=LM+((RM-LM) div 2);
      SysTitle:=GetGPCSRegString('OfficeInfo','Title','');
      OfficeName:=GetGPCSRegString('OfficeInfo','Office Name','');
      FS:=PrintPreview.Canvas.Font.Size;
      PrintPreview.Canvas.Font.Size:=(FS*3) div 2;
      TextOutput(PrintPreview.Canvas,CTR-(PrintPreview.Canvas.TextWidth(SysTitle) div 2),YOfs,SysTitle,PrintPreview.PaperWidth);
//      PrintPreview.Canvas.TextOut(CTR-(PrintPreview.Canvas.TextWidth(SysTitle) div 2),YOfs,SysTitle);
      Inc(YOfs,PrintPreview.Canvas.TextHeight('Wg'));
      TextOutput(PrintPreview.Canvas,CTR-(PrintPreview.Canvas.TextWidth(Title) div 2),YOfs,Title,PrintPreview.PaperWidth);
//      PrintPreview.Canvas.TextOut(CTR-(PrintPreview.Canvas.TextWidth(Title) div 2),YOfs,Title);
      Inc(YOfs,PrintPreview.Canvas.TextHeight('Wg'));
      PrintPreview.Canvas.Font.Size:=FS;
      CTR:=LM+((RM-LM) div 2);
      LC:=LM+((CTR-LM) div 2);
      RC:=CTR+((RM-CTR) div 2);
//      PrintPreview.Canvas.TextOut( LC-PrintPreview.Canvas.TextWidth('OFFICE:'),YOfs,'OFFICE:');
      TextOutput(PrintPreview.Canvas,LC-PrintPreview.Canvas.TextWidth('OFFICE:'),YOfs,'OFFICE:',PrintPreview.PaperWidth);
//      PrintPreview.Canvas.TextOut( LC+200 ,YOfs,OfficeName);
      TextOutput(PrintPreview.Canvas,LC+200 ,YOfs,OfficeName,PrintPreview.PaperWidth);
//      PrintPreview.Canvas.TextOut( RC-PrintPreview.Canvas.TextWidth('DATE:'),YOfs,'DATE:');
      TextOutput(PrintPreview.Canvas,RC-PrintPreview.Canvas.TextWidth('DATE:'),YOfs,'DATE:',PrintPreview.PaperWidth);
//      PrintPreview.Canvas.TextOut( RC+200,YOfs,FormatDateTime('dd/mm/yy',Now));
      TextOutput(PrintPreview.Canvas,RC+200,YOfs,FormatDateTime('dd/mm/yy',Now),PrintPreview.PaperWidth);
                                     
      Inc(YOfs,PrintPreview.Canvas.TextHeight('Wg')*2);
//      PrintPreview.Canvas.TextOut( LC-PrintPreview.Canvas.TextWidth('OFFICE NUMBER:'),YOfs,'OFFICE NUMBER:');
      TextOutput(PrintPreview.Canvas,LC-PrintPreview.Canvas.TextWidth('OFFICE NUMBER:'),YOfs,'OFFICE NUMBER:',PrintPreview.PaperWidth);
//      PrintPreview.Canvas.TextOut( LC+200 ,YOfs,IntToStr(Office));
      TextOutput(PrintPreview.Canvas,LC+200 ,YOfs,IntToStr(Office),PrintPreview.PaperWidth);
//      PrintPreview.Canvas.TextOut( RC-PrintPreview.Canvas.TextWidth('USER:'),YOfs,'USER:');
      TextOutput(PrintPreview.Canvas,RC-PrintPreview.Canvas.TextWidth('USER:'),YOfs,'USER:',PrintPreview.PaperWidth);
//      PrintPreview.Canvas.TextOut( RC+200,YOfs,User );
      TextOutput(PrintPreview.Canvas,RC+200,YOfs,User ,PrintPreview.PaperWidth);
   end;
end;
// if the cell contains pack text; make it more presentable
function CellText(Value:String):String;
var
   SL:TPackStringList;
   LSL:TPackStringList;
   I,J:Integer;
begin
   if (Length(Value) > 0) and (Integer(Value[1]) < 31) then
   begin
       SL:=TPackStringList.Create;
       LSL:=TPackStringList.Create;
       SL.PackText:=Value;
       for I:=0 to SL.Count-1 do
       begin
          if (Length(SL[I]) > 0) and (Integer(SL[I][1]) < 31) then
          begin
             LSL.PackText:=SL[I];
             SL[I]:='';
             for J:=0 to LSL.Count-1 do
             begin
                if Trim(LSL[J]) <> '' then
                begin
                   if SL[I] = '' then
                      SL[I]:=Trim(LSL[J])
                   else
                      SL[I]:=Trim(SL[I]+','+LSL[J]);
                end;
             end;    
          end;                   
       end;
       Value:=Trim(SL.Text);
       LSL.Free;
       SL.Free;
   end;
   Result:=Value;
end;
procedure TReportNode.DrawLine(Canvas:TCanvas;X1,Y1,X2,Y2,PageWidth:Integer);
begin
   if RightAnchor then
      Canvas.Polyline([Point(PageWidth-X1,Y1),Point(PageWidth-X2,Y2)])
   else
      Canvas.Polyline([Point(X1,Y1),Point(X2,Y2)]);
end;
procedure TReportNode.CopyRectangle(Dest:TCanvas;DestRect:TRect;Source:TCanvas;SourceRect:TRect;PageWidth:Integer);
begin
   if RightAnchor then
      OffsetRect(DestRect,(PageWidth-(DestRect.Left+(DestRect.Right-DestRect.Left)))-DestRect.Left,0);
   Dest.CopyRect(DestRect,Source,SourceRect);
end;
procedure TReportNode.TextOutput(Canvas:TCanvas;XPos,YPos:Integer;Text:String;PageWidth:Integer);
begin
   OutputText(Canvas,Text,Bounds(XPos,YPos,Canvas.TextWidth(Text),Canvas.TextHeight('Wg')),PageWidth,0,cjLeft);
end;
function TReportNode.OutputText(Canvas:TCanvas;Text:String;InRect:TRect;PageWidth:Integer;Flags:Integer;Justify:TColumnJustify):Integer;
begin
   if RightAnchor then
   begin
      OffsetRect(InRect,(PageWidth-(InRect.Left+(InRect.Right-InRect.Left)))-InRect.Left,0);
      if Canvas.Font.Charset <> ARABIC_CHARSET then
         Canvas.Font.Charset:=ARABIC_CHARSET;
      if (Justify = cjEnd)  then
         Flags:=(Flags and (not DT_RIGHT)) or DT_RTLREADING
      else if (Justify = cjStart) then
         Flags:=(Flags or DT_RIGHT) or DT_RTLREADING
      else
         Flags:=Flags or DT_RTLREADING;
   end;
   Result:=DrawTextEx(Canvas.Handle,PChar(Text),-1,InRect,Flags,nil);
end;
function TReportNode.ActualLineHeight(RowData : TStrings; LineNo : Integer; var NewPage : Boolean):Integer;
var
  ColSpace  : Integer;
  RowSpace  : Integer;
  InRect      : TRect;
  LastRow     : TStringList;
  PageBottom  : Integer;
  Row         : TStringList;
  H,J           : Integer;
begin
//  PageBottom:=PrintPreview.PrintBounds.Bottom;
  PageBottom:=PrintPreview.PrintBounds.Bottom;
  ColSpace := ColumnSpacing;
  RowSpace := RowSpacing;
  if RowSpace < PrintPreview.Canvas.TextHeight('Wg') then
     RowSpace:=PrintPreview.Canvas.TextHeight('Wg');;
  Row     := TStringList.Create;
  LastRow := TStringList.Create;
  try
    Row.CommaText :=RowData[LineNo];
    If LineNo > 0 then LastRow.CommaText := RowData[LineNo-1];
    Result        := PrintPreview.Canvas.TextHeight('Wg');
    NewPage := False;
    if (RowData[LineNo] = PBreak) then
      NewPage := True;
    for J:=0 to ColumnCount-1 do
    begin
      //check for page breaks on data change
      If (Column[J].RowBreak = 'Page') or (Column[J].RowBreak = 'PageTotal') then
      begin
        If (LineNo>=1) and (J < LastRow.Count) 
        and (J<Row.Count)and (LastRow[J] <> Row[J]) then //column data changed
        begin
           if (Row[J] <> HLine) and (Row[J] <> DHLine) and (Row.Count = ColumnCount) then // skip underscore lines and lines with an extra column added
              NewPage := True;//force new page
        end;
      end;
      if J >= Row.Count then Exit;
      InRect := Bounds(0,0,Column[J].Width+(ColSpace div 2),PageBottom);
      H      := OutputText(PrintPreview.Canvas,CellText(Row[J]),InRect,PrintPreview.PaperWidth,DT_WORDBREAK or DT_CALCRECT,cjLeft);
//      H      := DrawText(PrintPreview.Canvas.Handle,PChar(CellText(Row[J])),-1,InRect,DT_WORDBREAK or DT_CALCRECT);
      if H < RowSpace then H:=RowSpace;
      if H > Result then Result:=H;
    end;
  finally
    LastRow.Free;
    Row.Free;
  end;
end;

function TReportNode.CalcNumPages(RowData:TStrings):Integer;
var
  LineNo        : Integer;
  ColNo         : Integer;
  TopMargin     : Integer;
  LineHeight    : Integer;
  MaxLineHeight : Integer;
  H,ALH         : Integer;
  LastRow       : TStringList;
  Row           : TStringList;
  InRect        : TRect;
  CS,PageNo     : Integer;
  PageBottom    : Integer;
  Newpage       : Boolean;

begin
  Result:=1;
  PageNo :=1;
  CS := ColumnSpacing;
  Row:=TStringList.Create;
  LastRow := TStringList.Create;
  try
    PrintPreview.Canvas.Font.Name:='Arial';
    PrintPreview.Canvas.Font.Style:=[fsBold];
    PrintPreview.Canvas.Font.Size:=10;
    LineHeight:=PrintPreview.Canvas.TextHeight('Wg');
//    PageBottom:=PrintPreview.PrintBounds.Bottom;
    PageBottom:=PrintPreview.PrintBounds.Bottom;
    TopMargin:=PageBottom;

    for LineNo:=0 to RowData.Count-1 do
    begin
      Application.ProcessMessages;
      if Application.Terminated then Exit;
      ALH:=ActualLineHeight(RowData, LineNo, NewPage) ;
      LastRow.CommaText := RowData[LineNo];
      if ((TopMargin+ALH) > (PageBottom-FooterSize)) or NewPage then
      begin
        if (LineNo > 0) then
          Inc(PageNo);
        TopMargin:=HeadingSize;
        MaxLineHeight:=LineHeight;
        //find max height for this line
        for ColNo:=0 to ColumnCount-1 do
        begin
          InRect:=Bounds(0,0,Column[ColNo].Width+(CS div 2),PageBottom);
          H:=OutputText(PrintPreview.Canvas,Column[ColNo].Heading,InRect,PrintPreview.PaperWidth,DT_WORDBREAK or DT_CALCRECT,cjLeft);
//          H:=DrawText(PrintPreview.Canvas.Handle,PChar(Column[ColNo].Heading),-1,InRect,DT_CALCRECT or DT_WORDBREAK);
          if H > MaxLineHeight then MaxLineHeight:=H;
        end;
        Inc(TopMargin,MaxLineHeight+(LineHeight div 2)); // space * 1.5
      end;
      Inc(TopMargin,ALH);
    end;
    Result:=PageNo;
  finally
    LastRow.Free;
    Row.Free;
  end;
end;
procedure TReportNode.InsertSectionTotals(RowData:TStrings);
var
   I,J:Integer;
   RowBreakColumn:Integer;
   TotalInColumn:Array[0..200] of Boolean;
   SectionTotals:TStringList;
   CurrentSection:TStringList;
   ThisRow:TStringList;
   LastRowBreakData:String;
begin
   if RowData.Count < 1 then Exit;
   ZeroMemory(@(TotalInColumn[0]),SizeOf(TotalInColumn));
   RowBreakColumn:=-1;
   for I:=0 to ColumnCount-1 do
   begin
     if (Column[I].RowBreak = 'PageTotal') 
     or (Column[I].RowBreak = 'Total') then
     begin
        RowBreakColumn:=I;
     end;
     if Column[I].TotalColumn then
        TotalInColumn[I]:=True;
  end;
  if RowBreakColumn = -1 then Exit;
  SectionTotals :=TStringList.Create;
  CurrentSection:=TStringList.Create;
  ThisRow:=TStringList.Create;
  ThisRow.CommaText:=RowData[0];
  if ThisRow.Count > RowBreakColumn then
     LastRowBreakData:=ThisRow[RowBreakColumn]
  else
     LastRowBreakData:='';
  I:=0;
  while I < RowData.Count do
  begin
     ThisRow.CommaText:=RowData[I];
     if (ThisRow.Count > RowBreakColumn) 
     and (LastRowBreakData <> ThisRow[RowBreakColumn]) then
     begin
        CurrentSection[RowBreakColumn]:=LastRowBreakData;
        LastRowBreakData:=ThisRow[RowBreakColumn];
        CheckTotalCurr(CurrentSection);
        CurrentSection.Add(' ');
        if (Column[RowBreakColumn].RowBreak = 'Total') then
           RowData.Insert(I,' ');
        RowData.Insert(I,CurrentSection.CommaText);
        RowData.Insert(I,HLine);
        Inc(I,2);
        if (Column[RowBreakColumn].RowBreak = 'Total') then Inc(I);
        SectionTotals.Add(CurrentSection.CommaText);
        CurrentSection.Clear;
     end;
     for J:=0 to ThisRow.Count-1 do
     begin
        if J < ColumnCount then
        begin
           while CurrentSection.Count <= J do 
              CurrentSection.Add('');
           if TotalInColumn[J] then
              CurrentSection[J]:=CurrToStr(StrToCurrDef(CurrentSection[J],0)+StrToCurrDef(ThisRow[J],0));
        end;
     end;
     Inc(I);
  end;
  if (CurrentSection.Count > RowBreakColumn) then
     CurrentSection[RowBreakColumn]:=LastRowBreakData;
  CheckTotalCurr(CurrentSection);
  CurrentSection.Add(' ');
  RowData.Add(HLine);
  RowData.Add(CurrentSection.CommaText);
  SectionTotals.Add(CurrentSection.CommaText);
  if Column[RowBreakColumn].RowBreak = 'PageTotal' then
     RowData.Add(PBreak)
  else if (Column[RowBreakColumn].RowBreak = 'Total') then
     RowData.Add(' ');
  RowData.Add('Summary');
  RowData.Add(HLine);
  RowData.AddStrings(SectionTotals);
  
  ThisRow.Free;          
  SectionTotals.Free;
  CurrentSection.Free;               
end;
procedure TReportNode.Print(User:String;Office,WorkStation,FromPeriod,ToPeriod:Integer;RowData,Totals:TStrings;RepCallBack:TRepCallBack;HeadCallBack,FootCallBack:TRepHeadCallBack);
var
  LineNo        :Integer;
  ColNo         :Integer;
  XOffset       :Integer;
  TopMargin     :Integer;
  OrigTopMargin :Integer;
  LastRow       :TStringList; //previous row data
  LineHeight    :Integer;
  MaxLineHeight :Integer;
  MaxWidth,H,ALH:Integer;
  Row           :TStringList;
  DTFlags       :Word;
  InRect        :TRect;
  PageBottom    :Integer;
  CS,PageNo,NoPages:Integer;
  NewPage : Boolean;
begin
  InsertSectionTotals(RowData);
  while Totals.Count <= ColumnCount do Totals.Add(' '); // stop Rowbreak
  CS        := ColumnSpacing;
  MaxWidth  := 0;
  
  XOffset   :=PrintPreview.PrintBounds.Left;
  //determine max width
  for ColNo:=0 to ColumnCount-1 do
  begin
    if Column[ColNo].FillWidth then
    begin
      MaxWidth:=PrintPreview.PrintBounds.Right-PrintPreview.PrintBounds.Left;
      if ColNo > 0 then
        Column[ColNo].Width:=MaxWidth-(XOffset+CS)
      else
        Column[ColNo].Width:=MaxWidth-CS;
      Break;
    end
    else
      Inc(MaxWidth,Column[ColNo].Width+CS);
    Inc(XOffset,Column[ColNo].Width+CS);
  end;

  if HasTotals then
  begin
    RowData.Add(HLine);
    RowData.Add(Totals.CommaText);
  end;
  RowData.SaveToFile('C:\Report.csv');

  NoPages:=CalcNumPages(RowData);
  PageNo :=1;
  if Landscape then
    PrintPreview.Orientation:=poLandscape
  else
    PrintPreview.Orientation:=poPortrait;

  if (not MultiSection) and (PrintPreview.State <> psCreating) then
    PrintPreview.BeginDoc;

  Row:=TStringList.Create;
  LastRow := TStringList.Create;

  PrintPreview.Canvas.Brush.Style:=bsClear;
//  PageBottom:=PrintPreview.PrintBounds.Bottom;
  PageBottom:=PrintPreview.PrintBounds.Bottom;
  TopMargin:=PageBottom;
  OrigTopMargin:=TopMargin;

  PrintPreview.Canvas.Font.Name:='Arial';
  PrintPreview.Canvas.Font.Style:=[fsBold];
  PrintPreview.Canvas.Font.Size:=10;
  try
    for LineNo:=0 to RowData.Count-1 do
    begin
      Application.ProcessMessages;
      if Application.Terminated then Exit;
      ALH:=ActualLineHeight(RowData, LineNo, NewPage);
      LastRow.CommaText := RowData[LineNo]; //save previous row data
      //check for a new page
      if ((TopMargin+ALH) > (PageBottom-FooterSize)) or NewPage then //this line would go over footer
      begin
        if LineNo <> 0 then //don't start new page on first line
        begin
          if ColumnLines then // put column lines on before moving to next page
          begin
            
//            XOffset:=PrintPreview.PrintBounds.Left;
            XOffset:=PrintPreview.PrintBounds.Left;
            for ColNo:=0 to ColumnCount-1 do
            begin
              DrawLine(PrintPreview.Canvas,XOffset,OrigTopMargin,XOffset,TopMargin,PrintPreview.PaperWidth);
//              PrintPreview.Canvas.PolyLine([Point(XOffset,OrigTopMargin),Point(XOffset,TopMargin)]);
              if Column[ColNo].FillWidth then
              begin
                XOffset:=PrintPreview.PrintBounds.Right;
//                XOffset:=PrintPreview.PrintBounds.Right;
                break;
              end
              else
                Inc(XOffset,Column[ColNo].Width+CS);
            end;
            DrawLine(PrintPreview.Canvas,XOffset,OrigTopMargin,XOffset,TopMargin,PrintPreview.PaperWidth);
//            PrintPreview.Canvas.PolyLine([Point(XOffset,OrigTopMargin),Point(XOffset,TopMargin)]);
          end;
          PrintFooter(PageNo,NoPages,TopMargin,FootCallBack);
          PrintPreview.NewPage;
          PrintPreview.Canvas.Font.Name:='Arial';
          PrintPreview.Canvas.Font.Style:=[fsBold];
          PrintPreview.Canvas.Brush.Style:=bsClear;
          PrintPreview.Canvas.Font.Size:=10;
          ALH:=ActualLineHeight(RowData, LineNo, NewPage);
          Inc(PageNo);
        end;  //if not first line start a new page

        LineHeight:=PrintPreview.Canvas.TextHeight('Wg');
        TopMargin:=PrintHeader(User,Office,WorkStation,FromPeriod,ToPeriod,PageNo,NoPages,HeadCallBack);
        OrigTopMargin:=TopMargin;
        XOffset:=PrintPreview.PrintBounds.Left+(CS div 2); //output column headings
//        XOffset:=PrintPreview.PrintBounds.Left+(CS div 2); //output column headings
        MaxLineHeight:=LineHeight;
        if RowLines then
          DrawLine(PrintPreview.Canvas,PrintPreview.PrintBounds.Left,TopMargin,PrintPreview.PrintBounds.Left+MaxWidth,TopMargin,PrintPreview.PaperWidth);
//          DrawLine(PrintPreview.Canvas,PrintPreview.PrintBounds.Left,TopMargin,PrintPreview.PrintBounds.Left+MaxWidth,TopMargin,PrintPreview.PaperWidth);
//          PrintPreview.Canvas.PolyLine([Point(PrintPreview.PrintBounds.Left,TopMargin),Point(PrintPreview.PrintBounds.Left+MaxWidth,TopMargin)]);
        //draw column headers on new page
        for ColNo:=0 to ColumnCount-1 do
        begin
          case Column[ColNo].Justify of
             cjCentre : DTFlags:=DT_WORDBREAK or DT_CENTER;
             cjRight  : DTFlags:=DT_WORDBREAK or DT_RIGHT;
             else DTFlags:=DT_WORDBREAK;
          end;
          InRect:=Bounds(XOffset,TopMargin,Column[ColNo].Width+(CS div 2),PageBottom-TopMargin);
          H:=OutputText(PrintPreview.Canvas,Column[ColNo].Heading,InRect,PrintPreview.PaperWidth,DTFlags,Column[ColNo].Justify);
//          H:=DrawText(PrintPreview.Canvas.Handle,PChar(Column[ColNo].Heading),-1,InRect,DTFlags);
          if H > MaxLineHeight then MaxLineHeight:=H;
          Inc(XOffset,Column[ColNo].Width+CS);
        end;  //draw each column

        Inc(TopMargin,MaxLineHeight+(LineHeight div 2)); // space * 1.5
        if RowLines then
          DrawLine(PrintPreview.Canvas,PrintPreview.PrintBounds.Left,TopMargin,PrintPreview.PrintBounds.Left+MaxWidth,TopMargin,PrintPreview.PaperWidth);
//          PrintPreview.Canvas.PolyLine([Point(PrintPreview.PrintBounds.Left,TopMargin),Point(PrintPreview.PrintBounds.Left+MaxWidth,TopMargin)]);
      end;  //if new page required

      Row.CommaText:=RowData[LineNo];
      XOffset:=PrintPreview.PrintBounds.Left+(CS div 2);
//      XOffset:=PrintPreview.PrintBounds.Left+(CS div 2);
      for ColNo:=0 to ColumnCount-1 do
      begin
         if Row.Count > ColNo then
         begin
            if Trim(Row[ColNo]) = '""' then Row[ColNo]:='';
            case Column[ColNo].Justify of
               cjCentre : DTFlags:=DT_WORDBREAK or DT_CENTER;
               cjRight  : DTFlags:=DT_WORDBREAK or DT_RIGHT;
               else DTFlags:=DT_WORDBREAK;
            end;
            InRect:=Bounds(XOffset,TopMargin,Column[ColNo].Width+(CS div 2),PageBottom-TopMargin);
            if Row[ColNo] = HLine then
            begin
//               DrawLine(PrintPreview.Canvas,PrintPreview.PrintBounds.Left,TopMargin+(ALH div 2),PrintPreview.PrintBounds.Left+MaxWidth,TopMargin+(ALH div 2),PrintPreview.PaperWidth);
               DrawLine(PrintPreview.Canvas,PrintPreview.PrintBounds.Left,TopMargin+(ALH div 2),PrintPreview.PrintBounds.Left+MaxWidth,TopMargin+(ALH div 2),PrintPreview.PaperWidth);
//               PrintPreview.Canvas.PolyLine([Point(PrintPreview.PrintBounds.Left,TopMargin+(ALH div 2)),Point(PrintPreview.PrintBounds.Left+MaxWidth,TopMargin+(ALH div 2))]);
            end
            else if Row[ColNo] = DHLine then
            begin
               DrawLine(PrintPreview.Canvas,PrintPreview.PrintBounds.Left,TopMargin+(ALH div 3) ,PrintPreview.PrintBounds.Left+MaxWidth,TopMargin+(ALH div 3),PrintPreview.PaperWidth);
//               PrintPreview.Canvas.PolyLine([Point(PrintPreview.PrintBounds.Left,TopMargin+(ALH div 3)  ),Point(PrintPreview.PrintBounds.Left+MaxWidth,TopMargin+(ALH div 3)  )]);
               DrawLine(PrintPreview.Canvas,PrintPreview.PrintBounds.Left,TopMargin+(ALH div 3)*2,PrintPreview.PrintBounds.Left+MaxWidth,TopMargin+(ALH div 3)*2,PrintPreview.PaperWidth);
//               PrintPreview.Canvas.PolyLine([Point(PrintPreview.PrintBounds.Left,TopMargin+(ALH div 3)*2),Point(PrintPreview.PrintBounds.Left+MaxWidth,TopMargin+(ALH div 3)*2)]);
            end
            else if RowData[LineNo] <> PBreak then
            begin
               OutputText(PrintPreview.Canvas,CellText(Row[ColNo]),InRect,PrintPreview.PaperWidth,DTFlags,Column[ColNo].Justify);
//               DrawText(PrintPreview.Canvas.Handle,PChar(CellText(Row[ColNo])),-1,InRect,DTFlags);
            end;
            Inc(XOffset,Column[ColNo].Width+CS);
         end;
      end;
      Inc(TopMargin,ALH);
      if RowLines then
         DrawLine(PrintPreview.Canvas,PrintPreview.PrintBounds.Left,TopMargin,PrintPreview.PrintBounds.Left+MaxWidth,TopMargin,PrintPreview.PaperWidth);
//         PrintPreview.Canvas.PolyLine([Point(PrintPreview.PrintBounds.Left,TopMargin),Point(PrintPreview.PrintBounds.Left+MaxWidth,TopMargin)]);
    end;  //for all rows
    if ColumnLines then
    begin
      XOffset:=PrintPreview.PrintBounds.Left;
      for ColNo:=0 to ColumnCount-1 do
      begin
         DrawLine(PrintPreview.Canvas,XOffset,OrigTopMargin,XOffset,TopMargin,PrintPreview.PaperWidth);
//         PrintPreview.Canvas.PolyLine([Point(XOffset,OrigTopMargin),Point(XOffset,TopMargin)]);
         if Column[ColNo].FillWidth then
         begin
            XOffset:=PrintPreview.PrintBounds.Right;
            break;
         end
         else
            Inc(XOffset,Column[ColNo].Width+CS);
      end;
      DrawLine(PrintPreview.Canvas,XOffset,OrigTopMargin,XOffset,TopMargin,PrintPreview.PaperWidth);
//      PrintPreview.Canvas.PolyLine([Point(XOffset,OrigTopMargin),Point(XOffset,TopMargin)]);
    end;
    PrintFooter(PageNo,NoPages,TopMargin,FootCallBack);
    if (not MultiSection) then
      PrintPreview.EndDoc;
  finally
    Row.Free;
    LastRow.Free;
  end;
end;
function ProgIDToServer(ProgID:String):String;
begin
   Result:=GUIDToString(ProgIDToClassID(ProgID));
   if Result <> '' then
   begin
      try
         Result:=RegistryEx.ReadRegistryStringValue('HKCR\CLSID\'+Result+'\InProcServer32\');
      except
         on E:Exception do
            RaiseGUIDException('{82ECED96-5BAA-4F4B-BFA4-59950A6BB24D}',E);
      end;
   end;
end;
procedure PopulateReprintList(List:TStrings);
var
   SearchRec:TSearchRec;
   FileName:String;
   Ofs:Integer;
   S:String;
   Res:Integer;
begin
   List.Clear;
   Res:=FindFirst(SavedReports+'\*.Rep',$FFFF,SearchRec);
   if Res = 0 then
   begin
      while Res = 0 do 
      begin
          FileName:=SearchRec.Name;
          Ofs:=Length(FileName)-15;
          S:=Copy(FileName,Ofs+4,2)+'/'+Copy(FileName,Ofs+2,2)+'/'+Copy(FileName,Ofs   ,2)+' '+
             Copy(FileName,Ofs+6,2)+':'+Copy(FileName,Ofs+8,2)+':'+Copy(FileName,Ofs+10,2)+' '+
             Copy(FileName,1,Ofs-2);
         List.Add(S);
         Res:=FindNext(SearchRec);
      end;
      FindClose(SearchRec);
   end;   
end;
procedure TReportNode.CleanUpReportDirectory;
var
   SearchRec:TSearchRec;
   FileName:String;
   Ofs,I:Integer;
   Res:Integer;
   y,m,d:Word;
   DelList:TStringList;
begin
   Res:=FindFirst(SavedReports+'\*.Rep',$FFFF,SearchRec);
   if Res = 0 then
   begin
      DelList:=TStringList.Create;
      DecodeDate(Now,y,m,d);
      while Res = 0 do 
      begin
         FileName:=SearchRec.Name;
         Ofs:=Length(FileName)-15;
         if (StrToInt(Copy(FileName,Ofs+2,2)) <> m)
         or (StrToInt(Copy(FileName,Ofs+4,2)) <> d) then
            DelList.Add(SavedReports+'\'+FileName);
         Res:=FindNext(SearchRec);
      end;
      FindClose(SearchRec);
      for I:=0 to DelList.Count-1 do
      begin
         DeleteFile(DelList[I]);
      end;
      DelList.Free;
   end
   else
      ForceDirectories(SavedReports);
   
end;
procedure TReportNode.SaveReportData(User:String;Office,WorkStation,FromPeriod,ToPeriod:Integer;Summary:Boolean;ReportLines,TotalLine:TStrings);
var
   I:Integer;
   FileName:String;
   FileData:TPackStringList;
   SL:TPackStringList;
   SSL:TStringList;
begin
   try
      FileData:=TPackStringList.Create;
   
      SL:=TPackStringList.Create;
      SL.Text:=ReportLines.Text; FileData.Add(SL.PackText);
      SL.Text:=TotalLine.Text;   FileData.Add(SL.PackText);
      
      FileData.Add(         User             );
      FileData.Add(IntToStr(Office          ));
      FileData.Add(IntToStr(WorkStation     ));
      FileData.Add(IntToStr(FromPeriod      ));
      FileData.Add(IntToStr(ToPeriod        ));
      FileData.Add(IntToStr(Integer(Summary)));
      
      if LocalSharedData <> nil then
      begin
         SSL:=LocalSharedData.List; // creates a TStringList
         SL.Text:=SSL.Text;
         SSL.Free;
         FileData.Add(SL.PackText);
      end;
      
      SL.Free;

      I:=0;
      CleanUpReportDirectory;
      FileName:=SavedReports+'\'+Self.Name+'.'+FormatDateTime('yymmddhhnn',Now)+IntToHex(I,2)+'.Rep';
      while FileExists(FileName) do
      begin
         Inc(I);
         FileName:=SavedReports+'\'+Self.Name+'.'+FormatDateTime('yymmddhhnn',Now)+IntToHex(I,2)+'.Rep';
      end;
   
      FileData.SaveToFile(FileName);
      FileData.Free;
   except
      on E:Exception do
         RaiseGUIDException('{372FF2A4-5793-4E98-9AD8-8077B64203EA}',E);
   end;
end;

function TReportNode.Execute(User:String;Office,WorkStation,FromPeriod,ToPeriod:Integer;Summary:Boolean):String;
type
//   TDataExtractFunc = function(ReportsNode:TReportsNode;ReportNode:TReportNode;User:String;Office,WorkStation,FromPeriod,ToPeriod:Integer;Summary:Boolean):String;
   TDataExtractFunc = procedure;
const
  ParamDelimiter = ':';
var
  ZeroRecords       : Boolean;
  QueryStr          : String;
  Lines             : TTransactionLines;
  ReportLines       : TStringList;
  TotalLine         : TStringList;
  SaveSL            : TStringList;
  LibHandle         : THandle;
  DataExtractorFunc : TDataExtractFunc;
  DLLName :String;
  FuncName:String;
  SQ:String;
begin
   PagePrinted:=False;
   Result:='';
   Lines:=nil;
   
   ForceTableColumns:=ForceColumns;
   SaveSL:=TStringList.Create;
   //translate first query/all records
   if (Query = '') and (DataExtractor = '') and (CSVFile = '')then
   begin
      if FirstQuery <> '' then
      begin
         QueryStr := ReplaceParams(':',FirstQuery);
      end
      else
      begin
         QueryStr:='select * from txnlog where ((RecType = ''TxnLine'') or (RecType = ''TxnTotal'')) ';
         if (FromPeriod > 0) and (ToPeriod > 0) then
            QueryStr:=QueryStr+'and ((Period >= '+IntToStr(FromPeriod)+') and (Period <= '+IntToStr(ToPeriod)+')) ';
         if (User <> '') and (User <> 'All') then
            QueryStr:=QueryStr+'and (Teller = '''+User+''') ';
         if Office <> 0 then
            QueryStr:=QueryStr+'and (Office = '+IntToStr(Office)+') ';
         if WorkStation <> 0 then
            QueryStr:=QueryStr+'and (WSNumber = '+IntToStr(WorkStation)+') ';
      end;
      SaveSL.Text:=QueryStr;
      SaveSL.SaveToFile('C:\RRFQuery.txt');
      if UseLastResults then
         Lines:=TTransactionLines.Create
      else if UseMsgStoreData and (FirstQuery = '') then
         Lines:=TTxnTranslate.GetMsgStoreData(FromPeriod,ToPeriod,User,Office,Workstation,RequiredTxnTypes)
      else
         Lines:=TTxnTranslate.TranslateQuery('',QueryStr);
   end;


   if ShowEmptyReports or UseLastResults or ((Lines <> nil) and (Lines.Count > 0)) or (Query <> '') or (DataExtractor <> '') or (CSVFile <> '') then
   begin
      ZeroRecords := ((Lines = nil) or (Lines.Count = 0)) and (not UseLastResults);
      if not Zerorecords then
      begin
         if not UseLastResults then
         begin
            Lines.FieldsResult:=Columns;
            Application.ProcessMessages;
            Lines.ConvertToTable(Alias,TableName);
            Application.ProcessMessages;
         end;
         Lines.Free;
      end;
      ReportLines:=TStringList.Create;
      TotalLine:=TStringList.Create;
      if ((not ZeroRecords) or (Query <> '')) and (DataExtractor = '') and (CSVFile = '') then
      begin
         with TQueryMap.Create do
         begin
            try
               DataAlias           := Alias;
               SelectFields        := Columns;
               ResultFields        := Columns;
               if HasTotals then
                  TotalFields         := TotalColumns;
               if Query <> '' then
                  SQ:=Query
               else
                  SQ:=SecondQuery;

               if SQ <> '' then
               begin
                  if Pos(ParamDelimiter,SQ) <> 0 then
                     SQ:=ReplaceParams(ParamDelimiter,SQ);
                  SQL:=SQ;
               end
               else
               begin
                  SQL:='select '+Columns+' from '+TableName+' ';
                  if PLUs <> '' then
                     SQL:= SQL +'where ' + PLUToSQL(PLUs);
                  if GroupColumns <> '' then
                     SQL:=SQL +' group by ' + GroupColumns;
                  if OrderColumns <> '' then
                     SQL:=SQL +' order by ' + OrderColumns;
                     
               end ;
               SaveSL.Text:=SQL;
               SaveSL.SaveToFile('C:\RRSQuery.txt');
               ClearMaps;
               Application.ProcessMessages;
               ReportLines.CommaText := Execute;
            finally
               Free;
            end;
         end;
      end
      else if (CSVFile = '') then
      begin
         if Pos('.',DataExtractor) > 0 then
         begin
            DLLName   := ProgIDToServer('DataExtractor.'+DelimitedString(DataExtractor,'.',False));
            FuncName  := DelimitedString(DataExtractor,'.',True);
            LibHandle := LoadLibrary(PChar(DLLName));
            if LocalSharedData = nil then
               LocalSharedData:=TSharedData.Create('CorvusReportShare',False);
            try
               @DataExtractorFunc:=GetProcAddress(LibHandle,PChar(FuncName));
               if @DataExtractorFunc <> nil then
               begin
                  LocalSharedData.SetVariable('ReportName',Name);
                  DataExtractorFunc;
                  ReportLines.CommaText:=LocalSharedData.GetVariable('ReportData');
               end;

            except
               on E:Exception do
                  RaiseGUIDException('{BAC0D13C-BF7A-4AA8-8C3C-7C119840F073}',E);
            end;
            if LibHandle <> 0 then
               FreeLibrary(LibHandle);
         end;
      end
      else
      begin
         if FileExists(CSVFile) then
            ReportLines.LoadFromFile(CSVFile);
      end;
      Result:=ReportLines.CommaText;  //for resultcommatext mode
      Application.ProcessMessages;
      try
         if (HasTotals) and (ReportLines.Count > 0) then
         begin
            TotalLine.CommaText:=ReportLines[ReportLines.Count -1];
            if Trim(TotalLine[0]) = '""' then TotalLine[0]:='Total';
            ReportLines.Delete(ReportLines.Count -1);
         end;
      except
         on E:Exception do
            RaiseGUIDException('{A74CA37C-50DB-46BE-AF5F-C7E3B36C15E9}',E);
      end;
      if (ShowEmptyReports or (ReportLines.Count > 0))
      and (not ResultCommaText) then
      begin
         PagePrinted:=True;
         //force header, column headers on no data
         If ReportLines.Count = 0 then ReportLines.Add('');
         
         if not UsingNewExecute then
         begin
            PutInJustifys(TotalLine,False);
            PutInJustifys(ReportLines,True);
         end;
         Application.ProcessMessages;
         PutInCalcFields(TotalLine,ReportLines.Count);
         PutInCalcFields(ReportLines,-1);
         if UsingNewExecute then
            CheckCallBacks(ReportLines,FRepCallBack);
         CheckTotalCurr(TotalLine);
         Application.ProcessMessages;
         if FitWidth then
         begin
            ReportLines.Insert(0,TotalLine.CommaText);
            SetWidthsFromData(ReportLines);
            ReportLines.Delete(0);
         end;
         Application.ProcessMessages;
         if UsingNewExecute then
         begin
            SaveReportData(User,Office,WorkStation,FromPeriod,ToPeriod,Summary,ReportLines,TotalLine);
            ReportLines.Add(TotalLine.CommaText);
            Result:=ReportLines.CommaText;
            ReportLines.Delete(ReportLines.Count-1);
            if not JustGetReportData then
               Print(User,Office,WorkStation,FromPeriod,ToPeriod,
                     ReportLines,TotalLine,
                     FRepCallBack,FHeadCallBack,FFootCallBack);
         end
         else
         begin
            A4ReportPrint(User, // User
                          IntToStr(Office), // Office
                          '<'+ReplaceParams(ParamDelimiter,Title), // Report Title
                          ColumnHeads,  // Column Headers
                          '""'+TotalLine.CommaText,  // Total Line
                          ColumnWidths,  // Column Widths
                          ReportLines.CommaText);  // Report Lines
         end;
      end;
      ReportLines.Free;
      TotalLine.Free;
   end;
   ForceTableColumns:='';
end;
{TReportsNode}

constructor TReportsNode.Create(Name,FileName:String;LineNumber:Integer);
var
   LogoFileName:String;
begin
   inherited Create(Name,FileName,LineNumber);
   UsingNewExecute:=False;
   LogoFileName:=GetGPCSRegString(ReportsLogoKeyName,'Logo File','');
   if (LogoFileName <> '') and FileExists(LogoFileName) then
   begin
     FLogo:=TBitmap.Create;
     FLogo.LoadFromFile(LogoFileName);
   end;
end;
destructor TReportsNode.Destroy;
begin
   FLogo.Free;
   inherited Destroy;
end;
function TReportsNode.NewCompType(CurrCompType:TCorvusNode;CurrCompTypeName,Tok,FileName:String;LineNumber:Integer):Integer;
begin
   if Pos('.'+Tok+'.','.Reports.Ranges.HeadersFooters.') <> 0 then
   begin
      if (ErrorForm <> nil) then
         ErrorForm.Errors.Lines.Add(CurrCompTypeName+' contains component named '+Tok+' in File '+FileName+'('+IntToStr(LineNumber)+')');
   end;

        if CurrCompTypeName = 'Reports'        then Result:=CurrCompType.AddObject(Tok,TReportNode  .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'HeadersFooters' then Result:=CurrCompType.AddObject(Tok,THeadFootNode.Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Ranges'         then Result:=CurrCompType.AddObject(Tok,TRangeNode   .Create(Tok,FileName,LineNumber))
   else                                             Result:=CurrCompType.AddObject(Tok,TCorvusNode  .Create(Tok,FileName,LineNumber));
   
end;

function TReportsNode.ReportNamed(Name:String):TReportNode;
var
   CorvusNode:TCorvusNode;
   Index:Integer;
begin
   Result:=nil;
   if LeftOf(Name,'Report.') or LeftOf(Name,'Receipt.') then
     Name:=DelimitedString(Name,'.',True);
   CorvusNode:=NodeNamed('Reports');
   if CorvusNode <> nil then
   begin
      Index:=CorvusNode.IndexOf(Name);
      if Index >= 0 then
         Result:=TReportNode(CorvusNode.Objects[Index]);
   end;
end;
function TReportsNode.GetReport(Index:Integer):TReportNode;
var
   CorvusNode:TCorvusNode;
begin
   Result:=nil;
   CorvusNode:=NodeNamed('Reports');
   if CorvusNode <> nil then
   if (Index >= 0) and (Index < CorvusNode.Count) then
   begin
      Result:=TReportNode(CorvusNode.Objects[Index]);
   end;
end;
function TReportsNode.RepCount:Integer;
begin
   if NodeNamed('Reports') <> nil then
      Result:=NodeNamed('Reports').Count
   else
      Result:=0;
end;
function TReportsNode.HeadFootNamed(Name:String):THeadFootNode;
var
   CorvusNode:TCorvusNode;
   Index:Integer;
begin
   Result:=nil;
   if Copy(Name,1,9) = 'HeadFoot.' then
     Name:=Copy(Name,10,Length(Name));
   CorvusNode:=NodeNamed('HeadersFooters');
   if CorvusNode <> nil then
   begin
      Index:=CorvusNode.IndexOf(Name);
      if Index >= 0 then
         Result:=THeadFootNode(CorvusNode.Objects[Index]);
   end;
end;
function TReportsNode.GetHeadFoot(Index:Integer):THeadFootNode;
var
   CorvusNode:TCorvusNode;
begin
   Result:=nil;
   CorvusNode:=NodeNamed('HeadersFooters');
   if CorvusNode <> nil then
   if (Index >= 0) and (Index < CorvusNode.Count) then
   begin
      Result:=THeadFootNode(CorvusNode.Objects[Index]);
   end;
end;
function TReportsNode.HeadFootCount:Integer;
begin
   if NodeNamed('HeadersFooters') <> nil then
      Result:=NodeNamed('HeadersFooters').Count
   else
      Result:=0;
end;
function TReportsNode.RangeNamed(Name:String):TRangeNode;
var
   CorvusNode:TCorvusNode;
   Index:Integer;
begin
   Result:=nil;
   if Copy(Name,1,6) = 'Range.' then
     Name:=Copy(Name,7,Length(Name));
   CorvusNode:=NodeNamed('Ranges');
   if CorvusNode <> nil then
   begin
      Index:=CorvusNode.IndexOf(Name);
      if Index >= 0 then
         Result:=TRangeNode(CorvusNode.Objects[Index]);
   end;
end;
function TReportsNode.GetRange(Index:Integer):TRangeNode;
var
   CorvusNode:TCorvusNode;
begin
   Result:=nil;
   CorvusNode:=NodeNamed('Ranges');
   if CorvusNode <> nil then
   if (Index >= 0) and (Index < CorvusNode.Count) then
   begin
      Result:=TRangeNode(CorvusNode.Objects[Index]);
   end;
end;
function TReportsNode.RangeCount:Integer;
begin
   if NodeNamed('Ranges') <> nil then
      Result:=NodeNamed('Ranges').Count
   else
      Result:=0;
end;
procedure TReportsNode.PutInReportTitles(List:TStrings);
var
   I:Integer;
begin
   List.Clear;
   for I:=0 to RepCount-1 do
       List.AddObject(Report[I].Title,TStringObject.Create(Report[I].Name));
end;
procedure TReportsNode.RemoveTitles(List:TStrings);
begin
   while List.Count > 0 do
   begin
      if (List.Objects[0] <> nil) and (List.Objects[0] is TStringObject) then
         (List.Objects[0] as TStringObject).Free;
      List.Delete(0);
   end;
end;
function TReportsNode.ListReportNames:String;
var
   I:Integer;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   for I:=0 to RepCount-1 do SL.Add(Report[I].Name);
   Result:=SL.Text;
   SL.Free;
end;
function TReportsNode.ListReports:String;
var
   I:Integer;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   for I:=0 to RepCount-1 do SL.Add(Report[I].Title);
   Result:=SL.Text;
   SL.Free;
end;
function TReportsNode.ReprintSavedReportOn(FileName:String;RepCallBack:TRepCallBack;HeadCallBack,FootCallBack:TRepHeadCallBack;PP:TPrintPreview):TReportNode;
var
   FileData:TPackStringList;
   SL:TPackStringList;
   SSL:TStringList;
   ReportLines:TPackStringList;
   TotalLine  :TPackStringList;
   User:String;
   Office,WorkStation,FromPeriod,ToPeriod:Integer;
//   Summary:Boolean;
begin 
   Result:=nil;
   try
      Result:=ReportNamed(ExtractFileName(Copy(FileName,1,Length(FileName)-17)));
      if FileExists(FileName) and (Result <> nil) then
      begin
         if PP = nil then
            PrintPreview:=TPrintPreview.Create(nil)
         else
            PrintPreview:=PP;
         User       :='All';
         Office     :=0;
         WorkStation:=0;
         FromPeriod :=0;
         ToPeriod   :=0;
         
         ReportLines:=TPackStringList.Create;
         TotalLine  :=TPackStringList.Create;
         FileData:=TPackStringList.Create;
         FileData.LoadFromFile(FileName);
         if FileData.Count > 0 then ReportLines.PackText:=FileData[0];
         if FileData.Count > 1 then TotalLine  .PackText:=FileData[1];
         if FileData.Count > 2 then User                :=FileData[2];
         if FileData.Count > 3 then Office              :=StrToIntDef(FileData[3],0);
         if FileData.Count > 4 then WorkStation         :=StrToIntDef(FileData[4],0);
         if FileData.Count > 5 then FromPeriod          :=StrToIntDef(FileData[5],0);
         if FileData.Count > 6 then ToPeriod            :=StrToIntDef(FileData[6],0);
//         if FileData.Count > 7 then Summary             :=Boolean(StrToIntDef(FileData[7],0));
         
         if LocalSharedData <> nil then // save Shared memory
            SSL:=LocalSharedData.List
         else
            SSL:=nil;
            
         if (FileData.Count > 8) and (LocalSharedData <> nil) then
         begin // overwrite with values from print time
            SL:=TPackStringList.Create;
            SL.PackText:=FileData[8];
//            LocalSharedData.SetFromList(SL.Text); 
            SL.Free;
         end;
         Result.FRepCallBack :=RepCallBack ;
         Result.FHeadCallBack:=HeadCallBack;
         Result.FFootCallBack:=FootCallBack;
         ShowEmptyReports:=True;
         Result.Print(User,Office,WorkStation,FromPeriod,ToPeriod,ReportLines,
                      TotalLine,RepCallBack,HeadCallBack,FootCallBack);
         if SSL <> nil then // restore original Shared memory
         begin
//            LocalSharedData.SetFromList(SSL.Text);
            SSL.Free;
         end;
                
         if PP = nil then 
         begin
            PrintPreview.Free;
            PrintPreview:=nil;
         end;
         FileData.Free;
      end;
   except
      on E:Exception do
         RaiseGUIDException('{7491DD4F-3BB6-4066-B732-E76CC8C15DB2}',E);
   end;
end;
initialization
   PrintPreview:=nil;
   
finalization
   if PrintPreview <> nil then
      PrintPreview:=nil;
//      PrintPreview.Free;
end.
