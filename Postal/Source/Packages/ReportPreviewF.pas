unit ReportPreviewF;

interface
//  if not(PrintPreview.PrinterInstalled) then Exit;

uses
  GPCSErrorLine,
  Preview, Printers, RegistryEx,PackStrListU, Math, SavePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Spin, Buttons, GPCSGUID, StringUtil,
  GPCSBase_TLB;

type
  TReportPreviewForm = class(TSavePosForm)
    TopPanel: TPanel;
    ZoomLabel: TLabel;
    PageLabel: TLabel;
    UnitLabel: TLabel;
    ZoomComboBox: TComboBox;
    UnitComboBox: TComboBox;
    ZoomTrackBarPanel: TPanel;
    ZoomTrackBar: TTrackBar;
    PrintBitBtn: TBitBtn;
    PageSpinEdit: TSpinEdit;
    OfPageLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ZoomComboBoxChange(Sender: TObject);
    procedure UnitComboBoxChange(Sender: TObject);
    procedure PrintButtonClick(Sender: TObject);
    procedure PriorPageButtonClick(Sender: TObject);
    procedure NextPageButtonClick(Sender: TObject);
    procedure PrintPreviewChange(Sender: TObject);
    procedure PrintPreviewNewPage(Sender: TObject);
    procedure ZoomTrackBarChange(Sender: TObject);
    procedure ZoomTrackBarPanelResize(Sender: TObject);
    procedure PrintBitBtnClick(Sender: TObject);
    procedure PriorPageBitBtnClick(Sender: TObject);
    procedure PageSpinEditChange(Sender: TObject);
  private
    { Private declarations }
    FLogo               :  TBitmap;
    FPhysicalWidthMM    :  Extended;
    FPhysicalHeightMM   :  Extended;
    FHorzPixelsPerMM    :  Extended;
    FVertPixelsPerMM    :  Extended;
    FPhysicalOffsetXMM  :  Extended;
    FPhysicalOffsetYMM  :  Extended;
    HorzSize            :  Extended;
    VertSize            :  Extended;
    InLandscape         :  Boolean;
    PAddOffsetX         :  Integer;
    PAddOffsetY         :  Integer;
    LAddOffsetX         :  Integer;
    LAddOffsetY         :  Integer;
    FUser               :  String ;
    FOfficeName         :  String ;
    FOfficeNumber       :  String ;
    FReportTitle        :  String ;
    FIsArabic           :  Boolean;
    FPrintWidth         :  integer;
  public
    { Public declarations }
    PrintPreview : TPrintPreview;
    procedure DrawGrid(Spacing : Integer);
    procedure Line(X,Y,Width,Height:Integer;Dotted:Boolean);
    procedure PrintTextAt(X,Y,Width,Height:Integer;RightJustify:Boolean;Text:String);
    procedure PrintPictureAt(X,Y,Width,Height:Integer;BitMap:TBitMap);
    function  FieldValue(Fields:TStrings;FieldName,DefaultVal:String):String;
    procedure SpaceDigits(X,Y,DigitWidth,Height,NumDigits,Number:Integer;PadChar:Char);
    procedure PrintReportStandard(MajorColumnWidths, MinorColumnWidths, ReportVals : String);
    procedure PrintIncomeSummary(FieldsVals:String);
    procedure PrintIncomeSummaryCopy(FieldsVals, CopyNumber :String);
    procedure PrintDepartmentalReceipts(FieldsVals : String );
    procedure PrintDeparReceiptsCopy(FieldsVals, CopyNumber : String );
    procedure Print2x2ColumnReport(FieldsVals:String);

    property  User : string read FUser write FUser ;
    property  OfficeName : String read FOfficeName write FOfficeName ;
    property  OfficeNumber:String read FOfficeNumber write FOfficeNumber ;
    property  ReportTitle :String read FReportTitle  write FReportTitle  ;
  end;

   procedure A4ReportPrint(User,Office,ReportTitle,ColumnHeaders,TotalLine,ColumnWidths:String;ReportLines:String);
   
var
  ReportPreviewForm: TReportPreviewForm;

implementation

{$R *.DFM}

procedure AddA4Line( ResultList : TStringList;  NumberOfColumns : Integer );
//var
//  i : Integer;
begin
  with TStringList.Create do
  begin
//    for i:= 0 to NumberOfColumns-1 do
//      Add('__________________________________________________________________________________________');
    ResultList.Add(CommaText);
    Free;
  end;
end;

procedure A4ReportPrint(User, Office, ReportTitle, ColumnHeaders, TotalLine, ColumnWidths : String; ReportLines : String);
var
  ReportHeader,
  ReportLinesSL    : TStringList;
  ReportPrint      : TReportPreviewForm;
  i, ColumnCount,
  TotalColumnWidth : Integer;
begin
  ReportHeader   := TStringList.Create;
  ReportLinesSL  := TStringList.Create;
  ReportLinesSL.CommaText := ReportLines;

  ReportPrint := TReportPreviewForm.Create(nil);
  with TStringList.Create do
  begin
    CommaText := ColumnWidths;
    ColumnCount:=Count;
    TotalColumnWidth := 0;
    for i:=0 to Count-1 do
      TotalColumnWidth := TotalColumnWidth + abs(StrToInt(Strings[i]));
    Free;
  end;

  // Header Info
  ReportPrint.OfficeNumber:=Office;
  ReportPrint.OfficeName := GetGPCSRegString('OfficeInfo', 'Office Name', '');
  if User = '' then
    ReportPrint.User:='All'
  else
    ReportPrint.User:=User;
    
  ReportHeader.Add('" "," "');
  AddA4Line(ReportHeader, ColumnCount);
  ReportHeader.Add('" "," "');
  ReportHeader.Add(ReportTitle);
  AddA4Line(ReportHeader, ColumnCount);
  ReportHeader.Add(ColumnHeaders);
  ReportHeader.Add('" "," "');

  // Totals
  if TotalLine <> '' then
  begin
    AddA4Line(ReportLinesSL, ColumnCount);
    ReportLinesSL.Add('" "," "');
    ReportLinesSL.Add(TotalLine);
    AddA4Line(ReportLinesSL, ColumnCount);
  end;

  // Print A4 Report
  ReportPrint.PrintReportStandard(IntToStr(TotalColumnWidth),ColumnWidths, ReportHeader.CommaText + ',' + ReportLinesSL.CommaText);
  ReportHeader.Free;
  ReportLinesSL.Free;
  ReportPrint.FormDestroy(nil);
end;

procedure TReportPreviewForm.DrawGrid(Spacing : Integer);
var
  X : Integer;
begin
  X := 0;
  While X < PrintPreview.PaperWidth-1 do
  begin
    PrintPreview.Canvas.MoveTo(X,0);
    PrintPreview.Canvas.LineTo(X, PrintPreview.PaperHeight-1);
//    Line(X,0, X, PrintPreview.PageHeight-1,False);
    Inc(X,Spacing);
  end;
end;

function TReportPreviewForm.FieldValue(Fields:TStrings;FieldName,DefaultVal:String):String;
var
   Index:Integer;
begin
   Result:=DefaultVal;
   if Fields = nil then Exit;
   Index:=Fields.IndexOf(FieldName);
   if (Index >= 0) and (Fields.Count > (Index+1)) then
      Result:=Fields[Index+1]
end;

procedure TReportPreviewForm.SpaceDigits(X,Y,DigitWidth,Height,NumDigits,Number:Integer;PadChar:Char);
var
   S:String;
   I:Integer;
begin
   if (PadChar = ' ') and (Number = 0) then Exit;
   if (PadChar = '!') then PadChar:=' ';
   S:=Copy(IntToStr(Number),1,NumDigits);
   while Length(S) < NumDigits do S:=PadChar+S;
   for I:=1 to NumDigits do
      PrintTextAt(X+DigitWidth*(I-1),Y,-1,Height,False,S[I]);
end;


procedure Split(Curr:String;var IntPart,FracPart:String);
var
  Value:Currency;
begin
   Value:=StrToCurrDef(Curr,0);
   IntPart:=IntToStr(Trunc(Value));
   if Value < 0 then Value:=0-Value;
   FracPart:=IntToStr(Trunc((Value-Trunc(Value))*100));
   while Length(FracPart) < 2 do FracPart:='0'+FracPart;
end;

procedure TReportPreviewForm.PrintPictureAt(X,Y,Width,Height:Integer;BitMap:TBitMap);
var
  SR,DR:TRect;
begin
   Height:=(BitMap.Height*Width) div BitMap.Width;
   X:=Trunc((X*10)-FPhysicalOffsetXMM); // convert to mm and remove paper margin
   Y:=Trunc((Y*10)-FPhysicalOffsetYMM); // convert to mm and remove paper margin
   Width :=Width*10; // convert to mm
   Height:=Height*10; // convert to mm
   if InLandscape then
   begin
      X:=X+LAddOffsetX;
      Y:=Y+LAddOffsetY;
   end
   else
   begin
      X:=X+PAddOffsetX;
      Y:=Y+PAddOffsetY;
   end;
   if FIsArabic then
      X := PrintPreview.paperwidth - X - Width ;

   with PrintPreview.Canvas do
   begin
      SR:=Bounds(0,0,BitMap.Width,BitMap.Height);
      DR:=Bounds(X,Y,Width,Height);
      CopyRect(DR,BitMap.Canvas,SR);
   end;
end;

procedure TReportPreviewForm.Line(X,Y,Width,Height:Integer;Dotted:Boolean);
begin
   X:=Trunc((X*10)-FPhysicalOffsetXMM); // convert to mm and remove paper margin
   Y:=0-Trunc((Y*10)-FPhysicalOffsetYMM); // convert to mm and remove paper margin
   Width :=Width*10; // convert to mm
   Height:=Height*10; // convert to mm
   if InLandscape then
   begin
      X:=X+LAddOffsetX;
      Y:=Y+LAddOffsetY;
   end
   else
   begin
      X:=X+PAddOffsetX;
      Y:=Y+PAddOffsetY;
   end;

   with PrintPreview.Canvas do
   begin
      Pen.Width:=25;
      if Dotted then Pen.Style:=psDash; // psDot;
      MoveTo(X,Y);
      if Width = 0 then
         LineTo(X,Y-Height)
      else
         LineTo(X+Width,Y);
      Pen.Style:=psSolid;
   end;
end;

procedure TReportPreviewForm.PrintReportStandard(MajorColumnWidths, MinorColumnWidths, ReportVals : String);
//prints a standard header report using widths of major/minor columns in pixels
//minor columns printed with report values
type
  TReportColumn = record
    Offset : Integer;
    Width  : Integer;
  end;

const
  LINESDOWNPAGE = 45;
  LEFTMARGIN    = 150;
  TOPMARGIN     = 360; 

var
  FieldIndex  : Integer;          //index of each field in a line
  LineIndex   : Integer;          //report line index
  LineList    : TPackStringList;  //nested field values

  MajorColumnWidthsSL : TStringList;
  MinorColumnWidthsSL : TStringList;

  MajorColumns  : Array[0..100] of TReportColumn;
  MinorColumns  : Array[0..100] of TReportColumn;
  ColumnIndex   : Integer;    FieldList   : TPackStringList;  //each line
  ColumnOffset  : Integer;

  Translator:ITranslate;

begin
  if not(PrintPreview.PrinterInstalled) then
    Exit;
  LineList            := TPackStringList.Create;
  FieldList           := TPackStringList.Create;
  MajorColumnWidthsSL := TStringList.Create;
  MinorColumnWidthsSL := TStringList.Create;

  try
    try
      //init printer
      Translator:=CreateTranslator;
      FIsArabic := UpperCase(Translator.CurrentLanguage)='ARABIC'; // Arabic


      PrintPreview.Orientation := poPortrait;
      InLandScape         := False;
      PrintPreview.BeginDoc;
  //    DrawGrid(1000);
  //    SetMapMode(PrintPreview.Handle,MM_HIMETRIC); //1 logical unit = 0.01 mm, x->, y^, 0,0 =TopLeft

      //setup array of columns
      ColumnOffset := LEFTMARGIN;
      MajorColumnWidthsSL.CommaText := MajorColumnWidths;            //eg, '500,500,300,200
      For ColumnIndex := 0 to MajorColumnWidthsSL.Count -1 do
      begin
        MajorColumns[ColumnIndex].Offset := ColumnOffset;
        MajorColumns[ColumnIndex].Width  := StrToInt(MajorColumnWidthsSL[ColumnIndex]);
        Inc(ColumnOffset,Abs(MajorColumns[ColumnIndex].Width));
      end;
      FPrintWidth := ColumnOffset;

      ColumnOffset := 0;  //minor cols at left of major col
      MinorColumnWidthsSL.CommaText := MinorColumnWidths;
      For ColumnIndex := 0 to MinorColumnWidthsSL.Count -1 do
      begin
        MinorColumns[ColumnIndex].Offset := ColumnOffset;
        MinorColumns[ColumnIndex].Width  := StrToInt(MinorColumnWidthsSL[ColumnIndex]);
        Inc(ColumnOffset,Abs(MinorColumns[ColumnIndex].Width));
      end;

      //extract report values into lines
      LineList.CommaText  := ReportVals;

      //printing
      with PrintPreview.Canvas do
      begin

        if FIsArabic then Font.Charset:=ARABIC_CHARSET;
        Brush.Style:=bsClear;
        Font.Name:='Arial';
        Font.Style:=[fsBold];
        Font.Size  := 300;

        //go through report lines
        for LineIndex := 0 to LineList.Count-1 do
        begin

          //check for new page
          if LineIndex mod ((MajorColumnWidthsSL.Count) * LINESDOWNPAGE) = 0 then
          begin
            if LineIndex <> 0 then
               PrintPreview.NewPage;
            //standard page header
            if FLogo <> nil then
               PrintPictureAt(125,100,195,275,FLogo);
            PrintTextAt( 710, 100, 700,50,False, ReadRegistryStringValue('HKLM\Software\PSL\GPCS\OfficeInfo\Title'));
            PrintTextAt( 450, 180, 0,45,False, Translator.Translate('OFFICE:') );
            PrintTextAt( 600, 180, 0,45,False, FOfficeName );
            PrintTextAt( 450, 260, 0,45,False, Translator.Translate('USER:') );
            PrintTextAt( 600, 260, 0,45,False, FUser );
            PrintTextAt( 1550,260, 0,45,True,  Translator.Translate('DATE:') );
            PrintTextAt( 1700,260, 0,45,False, FormatDateTime('dd/mm/yy hh:nn',Now));
            PrintTextAt( 1350,180, 0,45,True,  Translator.Translate('OFFICE NUMBER:') );
            PrintTextAt( 1700,180, 0,45,False, FOfficeNumber );
          end;

          //print each line
          FieldList.CommaText :=  LineList[LineIndex]; //grab fields from this line
          //determine major column
          ColumnIndex := LineIndex mod (MajorColumnWidthsSL.Count * LINESDOWNPAGE);   //line on page
          ColumnIndex := (ColumnIndex - 1) div LINESDOWNPAGE; //major column

          //print each field in a minor column
          For FieldIndex := 0 to MinIntValue([MinorColumnWidthsSL.Count -1, FieldList.Count-1]) do
          begin
            PrintTextAt (   MajorColumns[ColumnIndex].Offset //offset of major column
                          + MinorColumns[FieldIndex].Offset,
                          TOPMARGIN
                          + 50 * (LineIndex mod LINESDOWNPAGE),
                          MinorColumns[FieldIndex].Width,     //avoid font shrink
                          45,                                   //height
                          True,                                 //right aligned
                          FieldList[FieldIndex]
                          );
          end;

  {        if ItemList.Count > 0 then
            PrintTextAt( 50+1000*((I mod 90) div 45),410+50*(I mod 45), -1,40,False,ItemList[0]);
          if ItemList.Count > 1 then
            PrintTextAt(800+1000*((I mod 90) div 45),410+50*(I mod 45),200,40,True ,ItemList[1]);
  }
        end;  //for all report lines
        PrintPreview.Canvas.Brush.Style:=bsSolid;
      end;  //with PrintPreview.Canvas
    finally
      Translator:=nil;
      LineList.Free;
      FieldList.Free;
      MajorColumnWidthsSL.Free;
      MinorColumnWidthsSL.Free;
      PrintPreview.EndDoc;
      If RegistryEx.ReadRegistryStringValue('HKLM\Software\PSL\GPCS\Reports\PreviewOnly') = '1' then
      begin
         ShowModal;
      end
      else
      begin
         PrintPreview.Print;
      end ;
    end ;
  except
    On E : Exception do
      RaiseGUIDException('{64A4C4AB-AB24-4357-9C5C-8CCBE33F21BB}', E);
  end;

end;


procedure TReportPreviewForm.PrintTextAt(X,Y,Width,Height:Integer;RightJustify:Boolean;Text:String);
//-ve width = use abs(width) with overrun
//0 width   = just print left justified
//+ve width means use width with font shrink if required
var
  PrtWidthPhysical:integer;
begin
  Text := Replace(Text, '"', ''); //remove double quotes
   X:=Trunc((X*10)-FPhysicalOffsetXMM); // convert to mm and remove paper margin
   Y:=Trunc((Y*10)-FPhysicalOffsetYMM); // convert to mm and remove paper margin
   Width :=Width*10; // convert to mm
   Height:=Height*10; // convert to mm
   if InLandscape then
   begin
      //PrtWidthPhysical := Trunc((FPrintWidth*10)-FPhysicalOffsetYMM)+LAddOffsetX;
      X:=X+LAddOffsetX;
      Y:=Y+LAddOffsetY;
   end
   else
   begin
      //PrtWidthPhysical := Trunc((FPrintWidth*10)-FPhysicalOffsetYMM)+PAddOffsetX;
      X:=X+PAddOffsetX;
      Y:=Y+PAddOffsetY;
   end;
   PrtWidthPhysical := PrintPreview.paperwidth ;

   with PrintPreview.Canvas do
   begin
      Font.Height:=(Height);
      if Width <= 0 then // dont resize the font
      begin
         if (Text <> '') and (Text[1] = '>') then      //force right justify
         begin
            if FIsArabic then
               TextOut( PrtWidthPhysical-X-Width, Y, Copy(Text,2,9999))
            else
               TextOut((X+abs(Width))-TextWidth(Copy(Text,2,999)),Y,Copy(Text,2,999))
         end
         else if (Text <> '') and (Text[1] = '<') then //force left justify
         begin
            if FIsArabic then
               TextOut(PrtWidthPhysical-X-TextWidth(Copy(Text,2,999)), Y, Copy(Text,2,9999))
            else
               TextOut(X, Y, Copy(Text,2,9999))
         end
         else if (Text <> '') and (Text[1] = '^') then //force centre text
         begin
            if FIsArabic then
               TextOut(PrtWidthPhysical-(X+Round((abs(Width)/2))-Round((TextWidth(Copy(Text,2,999))/2))), Y, Copy(Text,2,9999))
            else
               TextOut(X+Round((abs(Width)/2))-Round((TextWidth(Copy(Text,2,9999))/2)), Y, Copy(Text,2,9999))
         end
         else if RightJustify then
         begin
            if FIsArabic then
               TextOut(PrtWidthPhysical-X-abs(Width),Y,Text)
            else
               TextOut((X+abs(Width))-TextWidth(Text),Y,Text)
         end
         else
         begin
            if FIsArabic then
               TextOut(PrtWidthPhysical-X-TextWidth(Text),Y,Text)
            else
               TextOut(X,Y,Text);
         end
      end
      else
      begin
         //shrink font to fit width
         while (TextWidth(Text) > Width) and (Height >0) do
         begin
            Dec(Height);
            Font.Height:=0-Height;
         end;

         //text justification
         if (Text <> '') and (Text[1] = '>') then
         begin
           if FIsArabic then
              TextOut(PrtWidthPhysical-X-Width, Y, Copy(Text,2,9999))
           else
              TextOut((X+Width)-TextWidth(Copy(Text,2,999)),Y,Copy(Text,2,9999))
         end
         else if (Text <> '') and (Text[1] = '<') then //force left justify
         begin
           if FIsArabic then
              TextOut(PrtWidthPhysical-X-TextWidth(Copy(Text,2,999)), Y, Copy(Text,2,9999))
           else
              TextOut(X, Y, Copy(Text,2,9999))
         end
         else if (Text <> '') and (Text[1] = '^') then //force centre text
         begin
           if FIsArabic then
             TextOut(PrtWidthPhysical-(X+Round((abs(Width)/2))-Round((TextWidth(Copy(Text,2,999))/2))), Y, Copy(Text,2,9999))
          else
             TextOut(X+Round((abs(Width)/2))-Round((TextWidth(Copy(Text,2,999))/2)), Y, Copy(Text,2,9999))
         end
         else if RightJustify then
         begin
            if FIsArabic then
               TextOut( PrtWidthPhysical-X-Width,Y,Text)
            else
               TextOut((X+Width)-TextWidth(Text),Y,Text);
         end
         else
         begin
            if FIsArabic then
               TextOut( PrtWidthPhysical-X-((Width-TextWidth(Text)) div 2) - TextWidth(Text) ,Y,Text)
            else
               TextOut(X+(Width-TextWidth(Text)) div 2,Y,Text)
         end
      end;
   end;
end;


procedure TReportPreviewForm.PrintIncomeSummary(FieldsVals:String);
begin
   if not(PrintPreview.PrinterInstalled) then
     Exit;
   PrintPreview.Orientation:=poLandscape;
   PrintPreview.BeginDoc;
   PrintIncomeSummaryCopy(FieldsVals, 'TOP(WHITE) ' );
   PrintPreview.NewPage;
   PrintIncomeSummaryCopy(FieldsVals, '2nd(YELLOW)' );
   PrintPreview.NewPage;
   PrintIncomeSummaryCopy(FieldsVals, '3rd(PINK)  ' );
   PrintPreview.EndDoc;
end ;

procedure TReportPreviewForm.PrintIncomeSummaryCopy(FieldsVals, CopyNumber:String);
var
   I:Integer;
   FieldList:TPackStringList;
   IntPart,FracPart:String;
begin
   if not(PrintPreview.PrinterInstalled) then
     Exit;
   FieldList:=TPackStringList.Create;
   FieldList.CommaText:=FieldsVals;
   InLandScape:=True;
   SetMapMode(PrintPreview.Handle,MM_HIMETRIC); //1 logical unit = 0.01 mm, x->, y^, 0,0 =TopLeft
   with PrintPreview.Canvas do
   begin
      Brush.Style:=bsClear;
      Font.Name:='Arial';
      Font.Style:=[fsBold];

      PrintTextAt( 650, 100,1460,  65,False,'GENERAL POST OFFICE - INCOME SUMMARY SHEET');
      PrintTextAt( 120, 260, 280,  20,True ,'MACHINE CLOSING TOTAL');
      PrintTextAt( 120, 320, 280,  20,True ,'MACHINE OPENING TOTAL');
      PrintTextAt( 230, 380, 172,  20,True ,'POSTAGE USED');
      PrintTextAt( 480, 220, 215,  20,False,'MACHINE READINGS');
      PrintTextAt( 890, 220, 120,  30,False,'OFFICE:');
      PrintTextAt( 890, 340, 255,  30,False,'STOCK HOLDER:');
      PrintTextAt(2170, 220,  85,  30,False,'DATE:');
      PrintTextAt(1950, 340, 310,  30,False,'LOCATION NUMBER:');
      PrintTextAt( 610, 455, 635,  40,False,'INCOME SUMMARY (inc. JAV''s)');
      PrintTextAt(2040, 455, 410,  40,False,'DEPOSIT SUMMARY');
      PrintTextAt( 700,1800, 530,  36,True ,'TOTAL INCOME INCLUDING JAV''s');
      PrintTextAt(1370, 550,  20,  30,False,'$');
      PrintTextAt(1615, 550,  20,  30,False,'¢');
      PrintTextAt(2300, 550,  20,  30,False,'$');
      PrintTextAt(2550, 550,  20,  30,False,'¢');

      PrintTextAt( 215,1935, 510,  30,True ,'CASH REGISTER TAPE TOTAL: $');
      PrintTextAt( 155,1995, 570,  30,True ,'INCOME SUMMARY SHEET TOTAL: $');
      PrintTextAt( 312,2060, 413,  30,True ,'OVERS (+) / SHORTS (-): $');

      Line(730,1970,840,0,True);
      Line(730,2030,840,0,True);
      Line(730,2090,840,0,True);

      PrintTextAt(1660,1995, 275,  30,True ,'SIGNED CASHIER:');
      PrintTextAt(1840,2060,  95,  30,True ,'DATE:');

             Line(1950,2030, 650,  0,True);
             Line(1950,2090, 650,  0,True);

             Line( 650, 160,1460,   0,False);
             Line( 710,1845, 510,   0,False);

             Line( 412, 210, 350,   0,False);
             Line( 412, 242, 350,   0,False);
             Line( 412, 298, 350,   0,False);
             Line( 412, 354, 350,   0,False);
             Line( 412, 408, 350,   0,False);

             Line( 412, 210,   0, 198,False);
             Line( 670, 242,   0, 166,False);
             Line( 762, 210,   0, 198,False);

             Line(1025, 250, 840,   0,False);
             Line(1150, 365, 720,   0,False);
             Line(2300, 250, 350,   0,False);

             Line(2290, 305, 370,   0,False);
             Line(2290, 392, 370,   0,False);
             Line(2290, 305,   0,  87,False);
             Line(2660, 305,   0,  87,False);

             Line( 610, 505, 635,  0,False);
             Line(2040, 505, 410,  0,False);

         for I:=0 to 24 do
         begin
            Line( 123, 532+I*(1323 div 25), 1613,  0,False);
            if I > 0 then
            begin
               PrintTextAt(160,537+I*(1323 div 25),-1,36,False, FieldValue(FieldList,'IncomeName'+IntToStr(I),''));
               Split(FieldValue(FieldList,'MoneyI'+IntToStr(I),'0.00'),IntPart,FracPart);
               PrintTextAt(1280,535+I*(1323 div 25),200,46,True,IntPart );
               PrintTextAt(1550,535+I*(1323 div 25), 80,46,True,FracPart);
            end;
         end;
         Line(1250,1855, 484,0,False);
         Line(1250, 532,   0,1323,False);
         Line(1736, 532,   0,1323,False);
         Line( 123, 532, 0,  24*(1323 div 25),False);
         Line( 123+1613, 532, 0,  1280,False);
         Line(1531, 532+55, 0,1323-55,False);

         for I:=0 to 20 do
         begin
            Line(1835, 532+I*(1323 div 21),  820,  0,False);
            if (I > 0) and (I < 19) then
            begin
               PrintTextAt(1850    ,542+I*(1323 div 21), -1,36,False,FieldValue(FieldList,'DepositName'+IntToStr(I),''));
               Split(FieldValue(FieldList,'MoneyD'+IntToStr(I),'0.00'),IntPart,FracPart);
               PrintTextAt(1835+380,540+I*(1323 div 21),200,46,True ,IntPart );
               PrintTextAt(1835+650,540+I*(1323 div 21), 80,46,True ,FracPart);
            end;
         end;
         Line(1835, 532+1323, 820,  0,False);
         Line(1835, 532, 0,1323,False);
         Line(1835+330, 532, 0,1323,False);
         Line(1835+625, 595, 0,1260,False);
         Line(1835+820, 532, 0,1323,False);

         Line(123,1884,1490,0,False);
         Line(123,2105,1490,0,False);
         Line(123,1884,0,2105-1884,False);
         Line(123+1490,1884,0,2105-1884,False);

         Line(1645,1884,1010,0,False);
         Line(1645,2105,1010,0,False);
         Line(1645,1884,0,2105-1884,False);
         Line(1645+1010,1884,0,2105-1884,False);

      PrintTextAt(2350, 324,-1,46,False,FieldValue(FieldList,'LocationNo'       ,''));
      PrintTextAt(1200, 200,-1,46,False,FieldValue(FieldList,'Office'           ,''));
      PrintTextAt(1200, 315,-1,46,False,FieldValue(FieldList,'StockHolder'      ,''));
      PrintTextAt(2350, 200,-1,46,False,FieldValue(FieldList,'Date'             ,''));
      PrintTextAt( 500, 250,-1,36,False,FieldValue(FieldList,'MachineCloseTotal',''));
      PrintTextAt( 500, 305,-1,36,False,FieldValue(FieldList,'MachineOpenTotal' ,''));
      PrintTextAt( 500, 360,-1,36,False,FieldValue(FieldList,'PostageUsed'      ,''));
      PrintTextAt( 800,1915,-1,46,False,FieldValue(FieldList,'CashRegTapeTotal' ,''));
      PrintTextAt( 800,1975,-1,46,False,FieldValue(FieldList,'IncSumSheetTot'   ,''));
      PrintTextAt( 800,2035,-1,46,False,FieldValue(FieldList,'OversShorts'      ,''));
      PrintTextAt(2400, 100,-1,30,False,CopyNumber );
      //PrintTextAt(2400, 100,-1,30,False,FieldValue(FieldList,'CopyNumber'       ,''));
      Brush.Style:=bsSolid;
   end;
   FieldList.Free;
end;

procedure TReportPreviewForm.PrintDepartmentalReceipts(FieldsVals : String);
begin
   if not(PrintPreview.PrinterInstalled) then
     Exit;
   PrintPreview.Orientation:=poPortrait;
   PrintPreview.BeginDoc;
   PrintDeparReceiptsCopy( FieldsVals, 'TOP(WHITE) ' );
   PrintPreview.NewPage;
   PrintDeparReceiptsCopy( FieldsVals, '2nd(YELLOW)' );
   PrintPreview.NewPage;
   PrintDeparReceiptsCopy( FieldsVals, '3rd(PINK)  ' );
   PrintPreview.EndDoc;
end;                
procedure TReportPreviewForm.PrintDeparReceiptsCopy(FieldsVals, CopyNumber : String );
var
   I,J:Integer;
   FieldList:TPackStringList;
   IntPart,FracPart:String;
begin
   if not(PrintPreview.PrinterInstalled) then
     Exit;
   FieldList:=TPackStringList.Create;
   FieldList.CommaText:=FieldsVals;
   InLandScape:=False;
   SetMapMode(PrintPreview.Handle,MM_HIMETRIC); //1 logical unit = 0.01 mm, x->, y^, 0,0 =TopLeft
   with PrintPreview.Canvas do
   begin
      if FLogo <> nil then
         PrintPictureAt(75,100,195,275,FLogo);
      Brush.Style:=bsClear;
      Font.Name:='Arial';
      Font.Style:=[fsBold];
      PrintTextAt( 710, 170, 700,50,False,'GOVERNMENT OF BERMUDA');
      PrintTextAt( 685, 255,  -1,46,False,'To:');
      PrintTextAt( 755, 245, 685,58,False,'ACCOUNTANT GENERAL');
      PrintTextAt( 635, 315, 845,63,False,'DEPARTMENTAL RECEIPTS');
      PrintTextAt(1700, 315,  -1,30,False,CopyNumber );
      PrintTextAt( 155, 410,  -1,33,False,'The sum of $');
      PrintTextAt( 870, 410,  -1,33,False,'has been received by this Department in respect of the following:');
      PrintTextAt( 125, 477,  -1,25,False,'Cost');
      PrintTextAt( 120, 504,  -1,25,False,'Centre');
      PrintTextAt( 410, 493,  -1,25,False,'Object');
      PrintTextAt(1020, 493,  -1,25,False,'Description');
      PrintTextAt(1770, 493,  -1,25,False,'$');
      PrintTextAt(1850, 493,  -1,25,False,'Amount');
      PrintTextAt(1985, 493,  -1,25,False,'¢');
      PrintTextAt(1355,1830, 235,40,False,'Total Receipts');
      PrintTextAt(  50,1855,  -1,26,False,'Revenue');
      PrintTextAt(  50,1885,  -1,26,False,'Date');
      PrintTextAt(  50,1990,  -1,26,False,'Department');
      PrintTextAt( 225,1975,  -1,36,False,'Post Office - '+ FOfficeName);
      PrintTextAt(  50,2090,  -1,26,False,'Paid in by');
      PrintTextAt( 335,2115,  -1,22,False,'(Please Print)');
      PrintTextAt( 815,2115,  -1,28,False,'Signature');
      PrintTextAt(  50,2157,  -1,26,False,'Notes:');
      PrintTextAt(  50,2195,  -1,26,False,'1.');
      PrintTextAt(  50,2275,  -1,26,False,'2.');
      PrintTextAt(  50,2392,  -1,26,False,'3.');
      PrintTextAt(  50,2440,  -1,26,False,'4.');
      PrintTextAt(  50,2490,  -1,26,False,'5.');
      PrintTextAt(  95,2195,  -1,26,False,'This form should be used for all cash/cheques deposited with the Accountant Gen-');
      PrintTextAt(  95,2230,  -1,26,False,'eral''s Cashier''s and also for notification of direct bank deposits.');
      PrintTextAt(  95,2275,  -1,26,False,'A separate form must be used for each direct bank deposit, and the copy deposit');
      PrintTextAt(  95,2310,  -1,26,False,'slip attached.  This should be sent to the Accountant General''s Cashier''s as soon as');
      PrintTextAt(  95,2350,  -1,26,False,'possible after banking.');
      PrintTextAt(  95,2392,  -1,26,False,'Only valid, nine digit codes should be used.');
      PrintTextAt(  95,2440,  -1,26,False,'Descriptions should be relevant and meaningful. Maximum 30 characters');
      PrintTextAt(  95,2490,  -1,26,False,'The yellow department copy should also be attached. This will be receipted and');
      PrintTextAt(  95,2525,  -1,26,False,'returned and should be matched to the department fast copy (pink) as evidence of');
      PrintTextAt(  95,2560,  -1,26,False,'processing');
      PrintTextAt( 310,2630,  -1,26,False,'TOP (WHITE) - ACCOUNTANT GENERAL COPY');
      PrintTextAt( 310,2665,  -1,26,False,'2nd (YELLOW) - DEPARTMENT COPY');
      PrintTextAt( 310,2700,  -1,26,False,'3rd (PINK) - DEPARTMENTAL FAST COPY');

      Line( 436, 442, 380,   0,False);

      for I:=0 to 24 do
      begin
         Line(  50, 470+(I*1334) div 24, 2000,  0,False);
         if I > 1 then
         begin
            for J:=1 to 10 do
               Line(50+(J*550) div 10,440+(I*1334) div 24,0,30,False);
            for J:=1 to 6 do
               Line(1610+(J*325) div 6,440+(I*1334) div 24,0,30,False);
            Line(1992,440+(I*1334) div 24,0,30,False);
            PrintTextAt( 337,350+(I*1334) div 24,-1,120,False,'.');
            PrintTextAt( 630,417+(I*1334) div 24,-1, 40,False,FieldValue(FieldList,'IncomeName'+IntToStr(I-1),''));
            SpaceDigits( 400,417+(I*1334) div 24,55,40,4,StrToIntDef(FieldValue(FieldList,'IncomeObject'+IntToStr(I-1),''),0),' ');
            SpaceDigits(  65,417+(I*1334) div 24,55,40,5 ,StrToIntDef(FieldValue(FieldList,'CostCentre'+IntToStr(I-1),''),0),' ');
            Split(FieldValue(FieldList,'Income'+IntToStr(I-1),'0.00'),IntPart,FracPart);
            SpaceDigits(1625,417+(I*1334) div 24,55,40,6,StrToIntDef(IntPart ,0),'!');
            SpaceDigits(1955,417+(I*1334) div 24,55,40,2,StrToIntDef(FracPart,0),'0');
         end;
      end;
      Line(  50,470,0,1334,False);
      Line( 600,470,0,1334,False);
      Line(1610,470,0,1415,False);
      Line(1935,535,0,1346,False);
      Line(2050,470,0,1415,False);
      Line(1610,1885,440,0,False);
      //PrintTextAt(1400, 50,  -1,30,False,FieldValue(FieldList,'CopyNumber'       ,''));
      Split(FieldValue(FieldList,'Total','0.00'),IntPart,FracPart);
      PrintTextAt( 440, 400,  -1,40,False,IntPart+'.'+FracPart);
      SpaceDigits(1615,1810,55,60,6,StrToIntDef(IntPart ,0),'!');
      SpaceDigits(1950,1810,55,60,2,StrToIntDef(FracPart,0),'0');

      Line(1145,1975,   0, 800,False);
      Line( 110,1910,1000,   0,False);
      Line( 200,2015, 915,   0,False);
      Line( 170,2112, 445,   0,False);
      Line( 635,2112, 475,   0,False);

      Brush.Style:=bsSolid;
   end;
   FieldList.Free;
end;

procedure TReportPreviewForm.Print2x2ColumnReport(FieldsVals:String);
var
   I:Integer;
   FieldList:TPackStringList;
   ItemList:TPackStringList;
begin
   if not(PrintPreview.PrinterInstalled) then
     Exit;
   FieldList:=TPackStringList.Create;
   ItemList:=TPackStringList.Create;
   FieldList.CommaText:=FieldsVals;
   PrintPreview.Orientation:=poPortrait;
   InLandScape:=False;
   PrintPreview.BeginDoc;
   SetMapMode(PrintPreview.Handle,MM_HIMETRIC); //1 logical unit = 0.01 mm, x->, y^, 0,0 =TopLeft
   with PrintPreview.Canvas do
   begin
      Brush.Style:=bsClear;
      Font.Name:='Arial';
      Font.Style:=[fsBold];
//      Line( 635,2112, 475,   0,False);
      for I:=0 to FieldList.Count-1 do
      begin
         //if (I mod 100) = 0 then
         if (I mod 90) = 0 then
         begin
            if I <> 0 then PrintPreview.NewPage;
            if FLogo <> nil then
               PrintPictureAt(75,100,195,275,FLogo);
            if FReportTitle = '' then
               PrintTextAt( 710, 100, 700,60,False, GetGPCSRegString('OfficeInfo','Title','BERMUDA POST OFFICE'))
            else
               PrintTextAt( 350, 100,1400,60,False,FReportTitle);
            PrintTextAt( 350, 180, -1,45,False,'OFFICE:' );
            PrintTextAt( 500, 180, -1,45,False,FOfficeName );
            PrintTextAt( 350, 260, -1,45,False,'USER:' );
            PrintTextAt( 500, 260, -1,45,False,FUser );
            PrintTextAt( 1450,260, -1,45,True ,'DATE:' );
            PrintTextAt( 1600,260, -1,45,False,FormatDateTime('dd/mm/yy',Now));
            PrintTextAt( 1250,180, -1,45,True ,'OFFICE NUMBER:');
            PrintTextAt( 1600,180, -1,45,False,FOfficeNumber);

         end;
         ItemList.CommaText:=FieldList[I];
         if ItemList.Count > 0 then
//            PrintTextAt( 50+1000*((I mod 100) div 50),410+50*(I mod 50), -1,40,False,ItemList[0]);
            PrintTextAt( 50+1000*((I mod 90) div 45),410+50*(I mod 45), -1,40,False,ItemList[0]);
         if ItemList.Count > 1 then
            PrintTextAt(600+1000*((I mod 90) div 45),410+50*(I mod 45),400,40,True ,ItemList[1]);
      end;

      Brush.Style:=bsSolid;
   end;
   PrintPreview.EndDoc;
   FieldList.Free;
   ItemList.Free;
end;


procedure TReportPreviewForm.FormCreate(Sender: TObject);
var
  LogoFileName : String;

  PrinterHandle  :THandle;
  HorzRes        :Extended;
  VertRes        :Extended;
  PhysicalWidth  :Extended;
  PhysicalHeight :Extended;
  PhysicalOffsetX:Extended;
  PhysicalOffsetY:Extended;

begin
  PrintPreview            := TPrintPreview.Create(self);
  PrintPreview.Parent     := self;
  PrintPreview.Align      := alClient;
  PrintPreview.Font.Name  := 'Arial';
  PrintPreview.Font.Size  := 300;
  PrintPreview.OnChange   := PrintPreviewChange;
  PrintPreview.OnNewPage  := PrintPreviewNewPage;
  PrintBitBtn.Enabled     := PrintPreview.PrinterInstalled;
  PrintPreview.Visible    := True;
  ActiveControl           := PrintPreview;

  ZoomComboBox.ItemIndex  := 5;
  UnitComboBox.ItemIndex  := Ord(PrintPreview.Units);
  PrintPreview.Units      := TUnits(UnitComboBox.ItemIndex);

  PAddOffsetX:=StrToIntDef(ReadRegistryStringValue('HKLM\Software\PSL\GPCS\Reports\Portrait X Adjust'),0);
  PAddOffsetY:=StrToIntDef(ReadRegistryStringValue('HKLM\Software\PSL\GPCS\Reports\Portrait Y Adjust'),0);
  LAddOffsetX:=StrToIntDef(ReadRegistryStringValue('HKLM\Software\PSL\GPCS\Reports\Landscape X Adjust'),0);
  LAddOffsetY:=StrToIntDef(ReadRegistryStringValue('HKLM\Software\PSL\GPCS\Reports\Landscape Y Adjust'),0);

  LogoFileName :=ReadRegistryStringValue('HKLM\Software\PSL\GPCS\Reports\Logo File');
  if (LogoFileName <> '') and FileExists(LogoFileName) then
  begin
    FLogo:=TBitmap.Create;
    FLogo.LoadFromFile(LogoFileName);
  end;

  if PrintPreview.PrinterInstalled then
  begin
    PrinterHandle:=   Printer.Handle;
    HorzSize          :=GetDeviceCaps(PrinterHandle,Windows.HorzSize      );
    VertSize          :=GetDeviceCaps(PrinterHandle,Windows.VertSize      );
    HorzRes           :=GetDeviceCaps(PrinterHandle,Windows.HorzRes       );
    VertRes           :=GetDeviceCaps(PrinterHandle,Windows.VertRes       );
    PhysicalWidth     :=GetDeviceCaps(PrinterHandle,Windows.PhysicalWidth );
    PhysicalHeight    :=GetDeviceCaps(PrinterHandle,Windows.PhysicalHeight);
    PhysicalOffsetX   :=GetDeviceCaps(PrinterHandle,Windows.PhysicalOffsetX);
    PhysicalOffsetY   :=GetDeviceCaps(PrinterHandle,Windows.PhysicalOffsetY);
    FHorzPixelsPerMM  :=HorzRes         / HorzSize        ;
    FVertPixelsPerMM  :=VertRes         / VertSize        ;
    FPhysicalWidthMM  :=PhysicalWidth   / FHorzPixelsPerMM;
    FPhysicalHeightMM :=PhysicalHeight  / FVertPixelsPerMM;
    FPhysicalOffsetXMM:=PhysicalOffSetX / FHorzPixelsPerMM;
    FPhysicalOffsetYMM:=PhysicalOffSetY / FVertPixelsPerMM;
  end;

end;

procedure TReportPreviewForm.FormDestroy(Sender: TObject);
begin
   if FLogo <> nil then FLogo.Free;
   FLogo:=nil;
end;

procedure TReportPreviewForm.ZoomComboBoxChange(Sender: TObject);
begin
  ZoomTrackBarPanel.Hide;
  case ZoomComboBox.ItemIndex of
    0: PrintPreview.Zoom := 50;
    1: PrintPreview.Zoom := 100;
    2: PrintPreview.Zoom := 150;
    3: PrintPreview.Zoom := 200;
    4: PrintPreview.ZoomState := zsZoomToWidth;
    5: PrintPreview.ZoomState := zsZoomToFit;
    6:ZoomTrackBarPanel.Visible := True;
  end;
  ActiveControl := PrintPreview;

end;

procedure TReportPreviewForm.UnitComboBoxChange(Sender: TObject);
begin
  PrintPreview.Units := TUnits(UnitComboBox.ItemIndex);
end;

procedure TReportPreviewForm.PrintButtonClick(Sender: TObject);
begin
  if PrintPreview.State = psReady then
    PrintPreview.Print;
  ActiveControl := PrintPreview;
end;

procedure TReportPreviewForm.PriorPageButtonClick(Sender: TObject);
begin
  PrintPreview.CurrentPage := PrintPreview.CurrentPage - 1;
  ActiveControl := PrintPreview;
end;

procedure TReportPreviewForm.NextPageButtonClick(Sender: TObject);
begin
  PrintPreview.CurrentPage := PrintPreview.CurrentPage + 1;
  ActiveControl := PrintPreview;
end;

procedure TReportPreviewForm.PrintPreviewChange(Sender: TObject);
begin
  if PrintPreview.CurrentPage <> 0 then
  begin
    with PrintPreview do
      OfPageLabel.Caption := Format('of %d', [TotalPages]);
    OfPageLabel.Update;
    PageSpinEdit.Enabled := (PrintPreview.TotalPages > 1);
    PageSpinEdit.Value := PrintPreview.CurrentPage;
    If PageSpinEdit.Enabled then
    begin
      PageSpinEdit.MinValue := 1;
      PageSpinEdit.MaxValue := PrintPreview.TotalPages;
    end;

  end

end;

procedure TReportPreviewForm.PrintPreviewNewPage(Sender: TObject);
begin
  with PrintPreview do
  begin
    { The following line ensures one pixel pen width in any mapping mode. }
    if FIsArabic then  Canvas.Font.Charset:=ARABIC_CHARSET;
    Canvas.Pen.Width := 0;
    Canvas.Brush.Style := bsCLear;
    Canvas.Font.Name:='Arial';
    Canvas.Font.Style:=[fsBold];

//    with PageRect do Canvas.Rectangle(Left, Top, Right, Bottom);
  end;
end;


procedure TReportPreviewForm.ZoomTrackBarChange(Sender: TObject);
var
  VertPercent, HorzPercent : Double;
begin
  VertPercent :=0; HorzPercent := 0;
  If PrintPreview.VertScrollBar.Range > 0 then VertPercent := PrintPreview.VertScrollBar.Position / PrintPreview.VertScrollBar.Range;
  If PrintPreview.HorzScrollBar.Range > 0 then HorzPercent := PrintPreview.HorzScrollBar.Position / PrintPreview.HorzScrollBar.Range;
  PrintPreview.Zoom := ZoomTrackBar.Position;
  If PrintPreview.VertScrollBar.Range > 0 then PrintPreview.VertScrollBar.Position := Trunc(VertPercent * PrintPreview.VertScrollBar.Range);
  If PrintPreview.HorzScrollBar.Range > 0 then PrintPreview.HorzScrollBar.Position := Trunc(HorzPercent * PrintPreview.HorzScrollBar.Range);
end;

procedure TReportPreviewForm.ZoomTrackBarPanelResize(Sender: TObject);
begin
  ZoomTrackBar.Width := ZoomTrackBar.Parent.ClientWidth;
end;

procedure TReportPreviewForm.PrintBitBtnClick(Sender: TObject);
begin
  if PrintPreview.State = psReady then
    PrintPreview.Print;
  ActiveControl := PrintPreview;
end;

procedure TReportPreviewForm.PriorPageBitBtnClick(Sender: TObject);
begin
  PrintPreview.CurrentPage := PrintPreview.CurrentPage - 1;
  ActiveControl := PrintPreview;
end;

procedure TReportPreviewForm.PageSpinEditChange(Sender: TObject);
begin
  PrintPreview.CurrentPage := PageSpinEdit.Value;
  ActiveControl := PrintPreview;
end;

end.
