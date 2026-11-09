unit LkpassFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,TokenParser,
  StdCtrls,ActiveX,ExtCtrls,PackStrListU;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  TLookUpGen = class(TTokenList)
  public
     PClass      :String;
     PName       :String;
     UName       :String;
     UFile       :String;
     PGUID       :String;
     PProgID     :String;
     PRegDesc    :String;
     Version     :String;
     ResRowCount :String ;
     ColumnCount :String ;
     ItemsCol1   :TPackStringList ;


     procedure SaveToFile(FileName:String); override;
     constructor CreateLt( Value : String ) ;
     destructor  Destroy ; override ;
  end;
var
  Form1: TForm1;

implementation

{$R *.DFM}

{TLookUpGen}
constructor TLookUpGen.CreateLt( Value : String ) ;
begin
  ItemsCol1 := TPackStringList.Create ;
  inherited Create( Value );
end ;

destructor TLookUpGen.Destroy ;
begin
  ItemsCol1.Free ;
  inherited ;
end ;

procedure TLookUpGen.SaveToFile(FileName:String);
var
  guid:TGUID;
  GUIDstr:Array [0..50] of WideChar;
  RangeItems         :TPackStringList ;
  DimensionItems     :TPackStringList ;
  LookUpCaseItems    :TPackStringList ;
  ColumnNameItems    :TPackStringList ;
  RangeResItems      :TPackStringList ;
  DimensionResItems  :TPackStringList ;
  ColumnNameResItems :TPackStringList ;
  ItemCount : integer ;
  ItemNext : integer ;
  ItemStr : string ;
begin
   if PGUID = '' then
   begin
      if CoCreateGuid(guid) = S_OK then
         StringFromGUID2(guid,GUIDstr,50);
      PGUID:=WideCharToString(GUIDstr);
   end;
   ReplaceTokenAfter('{PClass}'      ,PClass);
   ReplaceTokenAfter('{PName}'       ,PName);
   ReplaceTokenAfter('{UName}'       ,UName);
   ReplaceTokenAfter('{UFile}'       ,#39+UFile       +#39);
   ReplaceTokenAfter('{PGUID}'       ,#39+PGUID       +#39);
   ReplaceTokenAfter('{PProgID}'     ,#39+PProgID     +#39);
   ReplaceTokenAfter('{PRegDesc}'    ,#39+PRegDesc    +#39);

   ReplaceTokenAfter('{Version}'     ,#39+Version     +#39);
   ReplaceTokenAfter('{RowCount}'    ,#39+ResRowCount +#39);
   ReplaceTokenAfter('{ColumnCount}' ,#39+ColumnCount +#39) ;

   RangeItems         :=TPackStringList.Create ;
   DimensionItems     :=TPackStringList.Create ;
   LookUpCaseItems    :=TPackStringList.Create ;
   ColumnNameItems    :=TPackStringList.Create ;
   RangeResItems      :=TPackStringList.Create ;
   DimensionResItems  :=TPackStringList.Create ;
   ColumnNameResItems :=TPackStringList.Create ;

   RangeItems.Add('');
   for ItemCount := 0 to ItemsCol1.Count -1 do
    RangeItems.Add('  ResRange'+Format('%2.2d', [ItemCount])+'           = '#39''+IntToStr((1+ItemCount)*100)+''#39';') ;

   //RangeItems.Add('  ResRange00           = '#39'100'#39';') ;
   //RangeItems.Add('  ResRange01           = '#39'200'#39';') ;
   //RangeItems.Add('  ResRange02           = '#39'300'#39';') ;


   DimensionItems.Add('');
   for ItemCount := 0 to ItemsCol1.Count -1 do
    DimensionItems.Add('  '+ItemsCol1[ ItemCount ]+'           = '#39''+IntToStr(ItemCount+1)+''#39';') ;

   DimensionItems[1] :='  '+ItemsCol1[ 0 ]+'           = '#39'1'#39'; // Column '#39'Test Column 0'#39'' ;
   //DimensionItems.Add('  ResItem01           = '#39'2'#39';');
   //DimensionItems.Add('  ResItem02           = '#39'3'#39';');


   ColumnNameItems.Add('');
   ColumnNameItems.Add('  ResColumnName00     = '#39'Test Column 0'#39';');
   ColumnNameItems.Add('  ResColumnName01     = '#39'Test Column 1'#39';');

   ColumnNameResItems.Add('');
   ColumnNameResItems.Add('         riColumnName   : Result:=ResColumnName00;');


   DimensionResItems.Add('');
   for ItemCount := 0 to ItemsCol1.Count -1 do
   begin
     ItemStr := '         riDimensionBase+'+IntToStr(ItemCount)+'                  ' ;
     ItemStr := Copy( ItemStr ,1, 28 ) ;

     DimensionResItems.Add( ItemStr +': Result:='+ItemsCol1[ItemCount]+';');
   end ;

   DimensionResItems[1] := '         riDimensionBase    : Result:='+ItemsCol1[ 0 ]+'; // Column '#39'Test Column 0'#39' ';
   //DimensionResItems.Add('         riDimensionBase+1  : Result:=ResItem01;');
   //DimensionResItems.Add('         riDimensionBase+2  : Result:=ResItem02;');


   RangeResItems.Add('');
   for ItemCount := 0 to ItemsCol1.Count -1 do
    RangeResItems.Add('         riRange+'+IntToStr(ItemCount)+'   : Result:=ResRange'+Format('%2.2d', [ItemCount])+'; ') ;
   //RangeResItems.Add('         riRange   : Result:=ResRange00; ') ;
   //RangeResItems.Add('         riRange+1 : Result:=ResRange01; ') ;
   //RangeResItems.Add('         riRange+2 : Result:=ResRange02; ') ;

   LookUpCaseItems.Add('');
   LookUpCaseItems.Add('   case Column of                                 ');
   LookUpCaseItems.Add('      0 : begin                                   ');
   LookUpCaseItems.Add('             case Index of                        ');
   ItemNext := 0;
   for ItemCount := 0 to ItemsCol1.Count -1 do
   begin
    LookUpCaseItems.Add('                  '+IntToStr( ItemNext )+'..'+IntToStr((ItemCount+1)*100)+'  : Result:= '#39''+IntToStr(ItemCount+1)+''#39'; ');
    ItemNext := ((ItemCount+1)*100 )+ 1 ;
   end ;
   //LookUpCaseItems.Add('                  0..100  : Result:= '#39'1'#39'; ');
   //LookUpCaseItems.Add('                101..200  : Result:= '#39'2'#39'; ');
   //LookUpCaseItems.Add('                201..300  : Result:= '#39'3'#39'; ');

   LookUpCaseItems.Add('             end;                                 ');
   LookUpCaseItems.Add('          end;                                    ');
   LookUpCaseItems.Add('   end;                                           ');

   ReplaceCommaTextBetweenTokens('{RangeStart}'       ,'{RangeEnd}'         , RangeItems.CommaText        );
   ReplaceCommaTextBetweenTokens('{DimensionStart}'   ,'{DimensionEnd}'     , DimensionItems.CommaText    );
   ReplaceCommaTextBetweenTokens('{LookUpCaseStart}'  ,'{LookUpCaseEnd}'    , LookUpCaseItems.CommaText   );
   ReplaceCommaTextBetweenTokens('{ColumnNameStart}'  ,'{ColumnNameEnd}'    , ColumnNameItems.CommaText   );
   ReplaceCommaTextBetweenTokens('{RangeResStart}'    ,'{RangeResEnd}'      , RangeResItems.CommaText     );
   ReplaceCommaTextBetweenTokens('{DimensionResStart}','{DimensionResEnd}'  , DimensionResItems.CommaText );
   ReplaceCommaTextBetweenTokens('{ColumnNameResStart}','{ColumnNameResEnd}', ColumnNameResItems.CommaText);

   inherited SaveToFile(FileName);

   RangeItems.Free ;
   DimensionItems.Free ;
   LookUpCaseItems.Free ;
   ColumnNameItems.Free ;
   RangeResItems.Free ;
   DimensionResItems.Free ;
   ColumnNameResItems.Free ;

end;
procedure TForm1.Button1Click(Sender: TObject);
var
   LookUpGen:TLookUpGen;
begin

   LookUpGen:=TLookUpGen.CreateLt('');

   LookUpGen.PClass    :='TTestLookUp';
   LookUpGen.PName     :='TestLookUp';
   LookUpGen.UName     :='TestLookUpAU';
   LookUpGen.UFile     :='TestlookUpAU.pas';
   LookUpGen.PGUID     :='';
   LookUpGen.PProgID   :='LookUp.TryLookUp';
   LookUpGen.PRegDesc  :='GPCS TryLookUp LookUp';

   LookUpGen.Version     :='1';
   LookUpGen.ResRowCount := '10' ;
   LookUpGen.ColumnCount:= '2';


   LookUpGen.ItemsCol1.Add('ResItem00');
   LookUpGen.ItemsCol1.Add('ResItem01');
   LookUpGen.ItemsCol1.Add('ResItem02');
   LookUpGen.ItemsCol1.Add('ResItem03');
   LookUpGen.ItemsCol1.Add('ResItem04');
   LookUpGen.ItemsCol1.Add('ResItem05');
   LookUpGen.ItemsCol1.Add('ResItem06');
   LookUpGen.ItemsCol1.Add('ResItem07');
   LookUpGen.ItemsCol1.Add('ResItem08');
   LookUpGen.ItemsCol1.Add('ResItem09');

   // generated dpr
   LookUpGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\LookUp\GenFromLookup.dpr');
   LookUpGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestLookUp.dpr');

   // generated pas
   LookUpGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\LookUp\GenFromLookUpAU.pas');
   LookUpGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestLookUpAU.Pas');

   Close;
end;

end.
