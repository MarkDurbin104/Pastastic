unit ProdGenU;

interface

uses
  StringUtil,
  Classes,Graphics,TokenParser,GPCSGUID,SysUtils,PackStrListU;

type
  TProductGen = class(TTokenList)
     PClass      :String; // Product Class Name
     PName       :String; // Project Name
     UName       :String; // Unit Name
     UFile       :String; // Unit File Name
     FName       :String; // Form Unit Name
     FFile       :String; // Form Unit File Name
     CName       :String; // Constant Unit Name
     CFile       :String; // Constant Unit File Name
     PGUID       :String; // Product GUID or '' for Auto Generate
     PProgID     :String; // Product ProgID
     PRegDesc    :String; // Product Registry Description
     Version     :String; // Version Number
     BarCode     :String; // Bar Code      
     Description :String; // Description 
     EndDate     :String; // End Date     
     HighDays    :String; // High Days
     MaxQuantity :String; // Max Quantity
     MCRCode     :String; // MCR Code     
     MinQuantity :String; // Min Quantity 
     OCRCode     :String; // OCR Code
     OtherCode   :String; // Other Code
     PLU         :String; // PLU
     Regulations :String; // Regulations
     StartDate   :String; // Start Date
     UnitPrice   :String; // Unit Price
     UnitQuantity:String; // Unit Quantity
     UseDays     :String; // Use Days
     Caption     :String; // Caption
     Title       :String; // Title
     Prompt      :String; // Prompt
     Hint        :String; // Hint
     Name        :String; // Name
     ProjectFiles:String; // ProjectFiles
     Controls    :String;
     BitMap      :TBitMap; // BitMap
     LogFormat   :String;
     PrintList   :String;
     FillList    :String;
     Endorse     :String;
     Customer    :String;
     Constants   :String;
     Taxes        :String;
     MOPs         :String;
     AvailAfterEOD:Boolean;
     Items:TStringList;
     Snippets:TStringList;
     constructor Create(InputString:String); override;
     destructor Destroy; override;
     procedure SaveToFile(FileName:String); override;
  end;

  TGroupGen = class(TTokenList)
  public
     PClass      :String;
     PName       :String;
     UName       :String;
     UFile       :String;
     PGUID       :String;
     PProgID     :String;
     PRegDesc    :String;
     Version     :String;
     Prompt      :String;
     Hint        :String;
     Key         :String;
     Captions    :TStringList;
     Titles      :TStringList;
     BitMaps     :TList; // TBitMap
     Items       :TStringList;
     Names       :TStringList;
     procedure SaveToFile(FileName:String); override;
     function GlyphLines(BitMap:TBitMap;I:Integer):String;
     constructor Create(InputString:String); override;
     destructor  Destroy; override ;
  end;
  TUGroupGen = class(TTokenList)
  public
     PClass      :String;
     PName       :String;
     UName       :String;
     UFile       :String;
     PGUID       :String;
     PProgID     :String;
     PRegDesc    :String;
     Version     :String;
     Count       :String;
     Items       :TStringList;
     procedure    SaveToFile(FileName:String); override;
     constructor  Create(InputString:String); override;
     destructor   Destroy ; override ;
  end;
  TWGroupGen = class(TUGroupGen)
  end;
  TPickListGen = class(TTokenList)
  public
     PClass      :String;
     PName       :String;
     UName       :String;
     UFile       :String;
     PGUID       :String;
     PProgID     :String;
     PRegDesc    :String;
     Version     :String;
     ColumnNames :TStringList;
     ColumnData  :TStringList;
     procedure    SaveToFile(FileName:String); override;
     constructor  Create(InputString:String); override;
     destructor   Destroy ; override ;
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
     CurrDecimals:integer;
     ColumnNames :TStringList;
     ColumnData  :TStringList;
     ColumnRanges:TStringList;
     procedure    SaveToFile(FileName:String); override;
     constructor  Create(InputString:String); override;
     destructor   Destroy ; override ;
  end;

procedure GenerateFormFile(FileName,FieldData:String);

implementation

{TUGroupGen}
constructor TUGroupGen.Create(InputString:String);
begin
  inherited Create(InputString);
  Items:=TStringList.Create ;
end;

destructor TUGroupGen.Destroy;
begin
  Items.Free;
  inherited Destroy;
end ;

procedure TUGroupGen.SaveToFile(FileName:String);
var
  ItemsInf, ItemResItems: TStringList;
  ItemNum : integer ;
begin
   if PGUID = '' then PGUID:=GenerateGUID;
   ReplaceTokenAfter('{PClass}'      ,PClass);
   ReplaceTokenAfter('{PName}'       ,PName);
   ReplaceTokenAfter('{UName}'       ,UName);
   ReplaceTokenAfter('{UFile}'       ,#39+UFile       +#39);
   ReplaceTokenAfter('{PGUID}'       ,#39+PGUID       +#39);
   ReplaceTokenAfter('{PProgID}'     ,#39+PProgID     +#39);
   ReplaceTokenAfter('{PRegDesc}'    ,#39+PRegDesc    +#39);
   ReplaceTokenAfter('{Version}'     ,#39+Version     +#39);
   ReplaceTokenAfter('{Count}'       ,#39+Count       +#39);

   ItemsInf     := TStringList.Create ;
   ItemsInf.Add( '' );
   for ItemNum := 0 to Items.Count -1 do
     ItemsInf.Add( '  ResItem'+IntToHex(ItemNum,2)+'           = '+#39+Items[ ItemNum ]+#39+';');
   ReplaceCommaTextBetweenTokens('{ItemStart}','{ItemEnd}', ItemsInf.CommaText );
   ItemsInf.Free ;
   
   ItemResItems := TStringList.Create ;
   ItemResItems.Add('');
   for ItemNum := 0 to Items.Count -1 do
     ItemResItems.Add('         riItemBase+'+IntToStr(ItemNum)+'     : Result:=ResItem'+IntToHex(ItemNum,2)+';');
   ReplaceCommaTextBetweenTokens('{ItemResStart}','{ItemResEnd}',ItemResItems.CommaText );
   ItemResItems.Free ;
              
   inherited SaveToFile(FileName);
end;

{TGroupGen}
constructor TGroupGen.Create(InputString:String);
begin
  inherited Create(InputString);
  Items   :=TStringList.Create;
  Captions:=TStringList.Create;
  Titles  :=TStringList.Create;
  Names   :=TStringList.Create;
  BitMaps :=TList.Create; // TBitMap
end;

destructor TGroupGen.Destroy;
begin
  Items   .Free;
  Captions.Free;
  Titles  .Free;
  BitMaps .Free;
  Names   .Free;
  inherited Destroy;
end;

function ItemLine(Items:String;I:Integer):String;
var
  J:Integer;
  SL:TPackStringList;
  S:String;
begin
   SL:=TPackStringList.Create;
   if I < 10 then
      S:='   Items'+IntToStr(I)+' :String = '
   else
      S:='   Items'+IntToStr(I)+':String = ';
   if Items = '' then
   begin
      S:=S+'''''';
   end
   else
   begin
      SL.PackText:=Items;
      if SL.Count > 5 then
      begin
         for J:=0 to 4 do
            S:=S+'#1'''+SL[J]+'''';
         S:=S+'+'#13#10+'                    ';
         for J:=5 to SL.Count-1 do
            S:=S+'#1'''+SL[J]+'''';
      end
      else
      begin
         for J:=0 to SL.Count-1 do
            S:=S+'#1'''+SL[J]+'''';
      end;
   end; 
   SL.Free;
   Result:=S+';';
end;
function TGroupGen.GlyphLines(BitMap:TBitMap;I:Integer):String;
begin
   Result:='';
   if (BitMap <> nil) then
   begin
      Result:=ConvertBitmap('Glyph'+IntToStr(I),BitMap);
   end;
end;
procedure TGroupGen.SaveToFile(FileName:String);
var
  I:Integer;
  GlyphDefs:TPackStringList;
  ItemDefs :TPackStringList;
  InitDefs :TPackStringList;
begin
   if PGUID = '' then PGUID:=GenerateGUID;
   ReplaceTokenAfter('{PClass}'  ,PClass);
   ReplaceTokenAfter('{PName}'   ,PName);
   ReplaceTokenAfter('{UName}'   ,UName);
   ReplaceTokenAfter('{UFile}'   ,#39+UFile   +#39);
   ReplaceTokenAfter('{PGUID}'   ,#39+PGUID   +#39);
   ReplaceTokenAfter('{PProgID}' ,#39+PProgID +#39);
   ReplaceTokenAfter('{PRegDesc}',#39+PRegDesc+#39);
   if UpperCase(ExtractFileExt(FileName)) <> '.DPR' then
   begin
      GlyphDefs:=TPackStringList.Create;
      ItemDefs :=TPackStringList.Create;
      InitDefs :=TPackStringList.Create;
      ItemDefs.Add('');
      InitDefs.Add('');
      for I:=0 to Items.Count-1 do
      begin
         ItemDefs .Add(ItemLine(Items[I],I));
         GlyphDefs.Add(GlyphLines(BitMaps[I],I));
         InitDefs.Add('     FGroupInfo.AddObject(''Group.'+Names[I]+''',TGroupDetails.Create('''+Captions[I]+''','''+Titles[I]+''',Items'+IntToStr(I)+',Glyph'+IntToStr(I)+'));');
      end;       
      ReplaceTextBetweenTokens('{ItemDataStart}','{ItemDataEnd}',ItemDefs.Text);
      ReplaceTextBetweenTokens('{GlyphDataStart}','{GlyphDataEnd}',GlyphDefs.Text);
      ReplaceTextBetweenTokens('{SetupGroupsStart}','{SetupGroupsEnd}',InitDefs.Text);
      GlyphDefs.Free;
      ItemDefs .Free;
      InitDefs .Free;      
   end;
   inherited SaveToFile(FileName);
end;
{TPickListGen}
constructor TPickListGen.Create(InputString:String);
begin
  inherited Create(InputString);
  ColumnNames:=TStringList.Create;
  ColumnData :=TStringList.Create;
end;

destructor TPickListGen.Destroy;
begin
  ColumnNames.Free;
  ColumnData .Free;
  inherited Destroy;
end ;

procedure TPickListGen.SaveToFile(FileName:String);
var
   I:Integer;
   SL:TStringList;
   NumbRows:Integer;
begin
   NumbRows:=ColumnData.Count div ColumnNames.Count;
   if PGUID = '' then PGUID:=GenerateGUID;
   ReplaceTokenAfter('{PClass}'     ,PClass);
   ReplaceTokenAfter('{PName}'      ,PName);
   ReplaceTokenAfter('{UName}'      ,UName);
   ReplaceTokenAfter('{UFile}'      ,#39+UFile      +#39);
   ReplaceTokenAfter('{PGUID}'      ,#39+PGUID      +#39);
   ReplaceTokenAfter('{PProgID}'    ,#39+PProgID    +#39);
   ReplaceTokenAfter('{PRegDesc}'   ,#39+PRegDesc   +#39);

   ReplaceTokenAfter('{Version}'    ,#39+Version    +#39);
   ReplaceTokenAfter('{Count}'      ,#39+IntToStr(NumbRows)+#39);
   ReplaceTokenAfter('{ColumnCount}',#39+IntToStr(ColumnNames.Count)+#39);
   
   SL:=TStringList.Create;
   SL.Add('  ');
   for I:=0 to ColumnNames.Count-1 do
      SL.Add('  ResColumnName'+IntToHex(I,4)+' = '+#39+ColumnNames[I]+#39+';');
   ReplaceTextBetweenTokens('{ColumnNameStart}','{ColumnNameEnd}',SL.Text+'  ');
   SL.Clear;
   
   SL.Add('  ');
   for I:=0 to ColumnNames.Count-1 do
      SL.Add('         riColumnName+'+IntToStr(I)+'   : Result:=ResColumnName'+IntToHex(I,4)+';');
   ReplaceTextBetweenTokens('{ColumnNameResStart}','{ColumnNameResEnd}',SL.Text+'         ');
   SL.Clear;

   SL.Add('  ');
   for I:=0 to ColumnData.Count-1 do
   begin
      if (I mod NumbRows) = 0 then
      begin
         if (I <> 0) then SL.Add(' ');
         SL.Add('  ResDimension'+IntToHex(I,8)+' = '+#39+ColumnData[I]+#39+'; // Column '+ColumnNames[I div NumbRows]);
      end
      else
      begin
         SL.Add('  ResDimension'+IntToHex(I,8)+' = '+#39+ColumnData[I]+#39+';');
      end;
   end;
   ReplaceTextBetweenTokens('{DimensionStart}','{DimensionEnd}',SL.Text+'  ');
   SL.Clear;
   
   SL.Add('  ');
   for I:=0 to ColumnData.Count-1 do
   begin
      if (I mod NumbRows) = 0 then
      begin
         if (I <> 0) then SL.Add(' ');
         SL.Add('         riDimensionBase+'+IntToStr(I)+'   : Result:=ResDimension'+IntToHex(I,8)+'; // Column '+ColumnNames[I div NumbRows]);
      end
      else
      begin
         SL.Add('         riDimensionBase+'+IntToStr(I)+'   : Result:=ResDimension'+IntToHex(I,8)+';');
      end;
   end;
   ReplaceTextBetweenTokens('{DimensionResStart}','{DimensionResEnd}',SL.Text+'         ');
   SL.Free;
   inherited SaveToFile(FileName);
end;

{TLookUpGen}
constructor TLookUpGen.Create(InputString:String);
begin
  inherited Create(InputString);
  ColumnNames :=TStringList.Create;
  ColumnData  :=TStringList.Create;
  ColumnRanges:=TStringList.Create;
  CurrDecimals:= 2;  
end;

destructor TLookUpGen.Destroy;
begin
  ColumnNames .Free;
  ColumnData  .Free;
  ColumnRanges.Free;
  inherited Destroy;
end ;
function ContainsFormula(S:String):Boolean;
var
   I:Integer;
begin
   Result:=True;
   for I:=1 to Length(S) do
      if not (S[I] in ['0'..'9','.']) then Exit;
   Result:=False;
end;
procedure TLookUpGen.SaveToFile(FileName:String);
var
   I,J,K:Integer;
   LastRange:Integer;
   SL:TStringList;
   NumbRows:Integer;
begin
   NumbRows:=ColumnData.Count div ColumnNames.Count;
   if PGUID = '' then PGUID:=GenerateGUID;
   ReplaceTokenAfter('{PClass}'     ,PClass);
   ReplaceTokenAfter('{PName}'      ,PName);
   ReplaceTokenAfter('{UName}'      ,UName);
   ReplaceTokenAfter('{UFile}'      ,#39+UFile      +#39);
   ReplaceTokenAfter('{PGUID}'      ,#39+PGUID      +#39);
   ReplaceTokenAfter('{PProgID}'    ,#39+PProgID    +#39);
   ReplaceTokenAfter('{PRegDesc}'   ,#39+PRegDesc   +#39);

   ReplaceTokenAfter('{Version}'    ,#39+Version    +#39);
   ReplaceTokenAfter('{RowCount}'   ,#39+IntToStr(NumbRows)+#39);
   ReplaceTokenAfter('{ColumnCount}',#39+IntToStr(ColumnNames.Count)+#39);
   
   SL:=TStringList.Create;
   SL.Add('  ');
   for I:=0 to ColumnNames.Count-1 do
      SL.Add('  ResColumnName'+IntToHex(I,4)+' = '+#39+ColumnNames[I]+#39+';');
   ReplaceTextBetweenTokens('{ColumnNameStart}','{ColumnNameEnd}',SL.Text+'  ');
   SL.Clear;
   
   SL.Add('  ');
   for I:=0 to ColumnNames.Count-1 do
      SL.Add('         riColumnName+'+IntToStr(I)+'   : Result:=ResColumnName'+IntToHex(I,4)+';');
   ReplaceTextBetweenTokens('{ColumnNameResStart}','{ColumnNameResEnd}',SL.Text+'         ');
   SL.Clear;

   SL.Add('  ');
   for I:=0 to ColumnData.Count-1 do
   begin
      if (I mod NumbRows) = 0 then
      begin
         if (I <> 0) then SL.Add(' ');
         SL.Add('  ResDimension'+IntToHex(I,8)+' = '+#39+ColumnData[I]+#39+'; // Column '+ColumnNames[I div NumbRows]);
      end
      else
      begin
         SL.Add('  ResDimension'+IntToHex(I,8)+' = '+#39+ColumnData[I]+#39+';');
      end;
   end;
   ReplaceTextBetweenTokens('{DimensionStart}','{DimensionEnd}',SL.Text+'  ');
   SL.Clear;
   
   SL.Add('  ');
   for I:=0 to ColumnData.Count-1 do
   begin
      if (I mod NumbRows) = 0 then
      begin
         if (I <> 0) then SL.Add(' ');
         SL.Add('         riDimensionBase+'+IntToStr(I)+'   : Result:=ResDimension'+IntToHex(I,8)+'; // Column '+ColumnNames[I div NumbRows]);
      end
      else
      begin
         SL.Add('         riDimensionBase+'+IntToStr(I)+'   : Result:=ResDimension'+IntToHex(I,8)+';');
      end;
   end;
   ReplaceTextBetweenTokens('{DimensionResStart}','{DimensionResEnd}',SL.Text+'         ');
   SL.Clear;
   SL.Add('  ');
   for I:=0 to ColumnRanges.Count-1 do
      SL.Add('  ResRange'+IntToHex(I,4)+' = '+#39+ColumnRanges[I]+#39+';');
   ReplaceTextBetweenTokens('{RangeStart}','{RangeEnd}',SL.Text+'  ');
   SL.Clear;
   
   SL.Add('  ');
   for I:=0 to ColumnRanges.Count-1 do
      SL.Add('         riRange+'+IntToStr(I)+'   : Result:=ResRange'+IntToHex(I,4)+';');
   ReplaceTextBetweenTokens('{RangeResStart}','{RangeResEnd}',SL.Text+'         ');
   SL.Clear;
   
   SL.Add('   ');
   SL.Add('   case Column of');
   K:=0;
   for I:=0 to ColumnNames.Count-1 do
   begin
      SL.Add('      '+IntToStr(I)+' : begin');
      SL.Add('             case LookVal of');
      LastRange:=0;
      for J:=0 to ColumnRanges.Count-1 do
      begin
         if ContainsFormula(ColumnData[K]) then
            SL.Add('                  '+IntToStr(LastRange)+'..'+ColumnRanges[J]+'  : Result:=CurrToStrF('+ColumnData[K]+',ffNumber,'+IntToStr(CurrDecimals)+');')

         else
            SL.Add('                  '+IntToStr(LastRange)+'..'+ColumnRanges[J]+'  : Result:= '+#39+CurrToStrF(StrToCurrDef(ColumnData[K],0),ffNumber,CurrDecimals)+#39+';');

         LastRange:=StrToIntDef(ColumnRanges[J],LastRange)+1;
         Inc(K);
      end;
      SL.Add('             end;');
      SL.Add('          end;');
   end;                        
   SL.Add('   end;');
   ReplaceTextBetweenTokens('{LookUpCaseStart}','{LookUpCaseEnd}',SL.Text+'   ');
   SL.Free;

   inherited SaveToFile(FileName);
end;

{TProductGen}
constructor TProductGen.Create(InputString:String);
begin
  inherited Create(InputString);
  Items:=TStringList.Create;
  Snippets:=TStringList.Create;
end;
destructor TProductGen.Destroy;
begin
  Items.Free;
  Snippets.Free;
  inherited Destroy;
end;
function RemSpace(Value:String):String;
var
   I:Integer;
begin
   Result:='';
   for I:=1 to Length(Value) do 
      if Value[I] in ['A'..'Z','a'..'z','0'..'9','_'] then 
         Result:=Result+Value[I];
end;
function AddParams(FieldData:String):String;
var
  FD,ValData:TStringList;
  ParamList:TStringList;
begin
   FD       :=TStringList.Create;
   ValData  :=TStringList.Create;
   ParamList:=TStringList.Create;

   FD.CommaText:=FieldData;
   ParamList.CommaText:=FD[10];
   if (ParamList.Count > 1) and LeftOf(UpperCase(ParamList[1]),'LOOKUP.') then
   begin
      ValData.Add('   '+RemSpace(FD[0])+'.Text:=LookUp('#39+'Value'+#39+','+ParamList[0]+'.Text,'+#39+Copy(ParamList[1],8,999)+#39+','+ParamList[0]+',Result);');
   end
   else if (ParamList.Count > 2) and LeftOf(UpperCase(ParamList[2]),'LOOKUP.') then
   begin
      ValData.Add('   '+ParamList[1]+'.ItemIndex:='+ParamList[1]+'.Items.IndexOf('+ParamList[1]+'.Text);');
      ValData.Add('   if '+ParamList[1]+'.ItemIndex >= 0 then');
      ValData.Add('      '+RemSpace(FD[0])+'.Text:=LookUp(TStringObject('+ParamList[1]+'.Items.Objects['+ParamList[1]+'.ItemIndex]).Value,'+ParamList[0]+'.Text,'+#39+Copy(ParamList[2],8,999)+#39+','+ParamList[0]+',Result);');
   end;
   Result:=Valdata.Text;
   ParamList.Free;
   ValData  .Free;
   FD       .Free;
end;
{===============================================================================
  <Synopsis>     Save the New Product
  <Description>  Apply Changes and Save the New Product
  <FileName>     the file name to save
________________________________________________________________________________}
procedure TProductGen.SaveToFile(FileName:String);
type
   TRGBList = packed array[0..0] of packed record B,G,R:Byte; end;
   PRGBList = ^TRGBList;
var
   FieldDataList,FD,FormData,ValidateData:TStringList;
   I:Integer;
   Index:Integer;
   S:String;
   T:String;    
   ListName:String;
   ListCombo:String;
   HasWeight:Boolean;
   HasList:Boolean;
   StdFee:Boolean;
   SwapLines:TStringList;
   DomainList:TStringList;
   DomainName:String;
   HadCarat:Boolean;
   HasSwap:Boolean;
   CustomerLine:String;
   EndorseLine:String;
   SummaryType:String;
begin
   DomainList:=TStringList.Create;
   HasList:=False;
   HasWeight:=False;
   StdFee:=False;
   if PGUID = '' then PGUID:=GenerateGUID; 
   if PClass <> '' then ReplaceTokenAfter('{PClass}'      ,PClass);
   if PName <> '' then ReplaceTokenAfter('{PName}'       ,PName);
   if UName <> '' then ReplaceTokenAfter('{UName}'       ,UName);
   if UFile <> '' then ReplaceTokenAfter('{UFile}'       ,#39+UFile       +#39);
   if CName <> '' then ReplaceTokenAfter('{CName}'       ,CName);
   if CFile <> '' then ReplaceTokenAfter('{CFile}'       ,#39+CFile       +#39);
   if PGUID <> '' then ReplaceTokenAfter('{PGUID}'       ,#39+PGUID       +#39);
   if PProgID  <> '' then ReplaceTokenAfter('{PProgID}'     ,#39+PProgID     +#39);
   if PRegDesc <> '' then ReplaceTokenAfter('{PRegDesc}'    ,#39+PRegDesc    +#39);
   if Description = '' then Description:=Title;
   if Caption     = '' then Caption    :=Title;
   if Prompt      = '' then Prompt     :=' ';
   if Hint        = '' then Hint       :=' ';
   if Version      <> '' then ReplaceTokenAfter('{Version}'     ,#39+Version     +#39);
   if BarCode      <> '' then ReplaceTokenAfter('{BarCode}'     ,#39+BarCode     +#39);
   if Description  <> '' then ReplaceTokenAfter('{Description}' ,#39+Description +#39);
   if EndDate      <> '' then ReplaceTokenAfter('{EndDate}'     ,#39+EndDate     +#39);
   if HighDays     <> '' then ReplaceTokenAfter('{HighDays}'    ,#39+HighDays    +#39);
   if MaxQuantity  <> '' then ReplaceTokenAfter('{MaxQuantity}' ,#39+MaxQuantity +#39);
   if MCRCode      <> '' then ReplaceTokenAfter('{MCRCode}'     ,#39+MCRCode     +#39);
   if MinQuantity  <> '' then ReplaceTokenAfter('{MinQuantity}' ,#39+MinQuantity +#39);
   if OCRCode      <> '' then ReplaceTokenAfter('{OCRCode}'     ,#39+OCRCode     +#39);
   if OtherCode    <> '' then ReplaceTokenAfter('{OtherCode}'   ,#39+OtherCode   +#39);
   if PLU          <> '' then ReplaceTokenAfter('{PLU}'         ,#39+PLU         +#39);
   if Regulations  <> '' then ReplaceTokenAfter('{Regulations}' ,#39+Regulations +#39);
   if StartDate    <> '' then ReplaceTokenAfter('{StartDate}'   ,#39+StartDate   +#39);
   if UnitPrice    <> '' then ReplaceTokenAfter('{UnitPrice}'   ,#39+UnitPrice   +#39);
   if UnitQuantity <> '' then ReplaceTokenAfter('{UnitQuantity}',#39+UnitQuantity+#39);
   if UseDays      <> '' then ReplaceTokenAfter('{UseDays}'     ,#39+UseDays     +#39);
   if Caption      <> '' then ReplaceTokenAfter('{Caption}'     ,#39+Caption     +#39);
   if Title        <> '' then ReplaceTokenAfter('{Title}'       ,#39+Title       +#39);
   if Prompt       <> '' then ReplaceTokenAfter('{Prompt}'      ,#39+Prompt      +#39);
   if Hint         <> '' then ReplaceTokenAfter('{Hint}'        ,#39+Hint        +#39);
   if Taxes        <> '' then ReplaceTokenAfter('{Taxes}'       ,#39+Taxes       +#39);
   if MOPs         <> '' then ReplaceTokenAfter('{MOPs}'        ,#39+MOPs        +#39);
   if AvailAfterEOD      then ReplaceTokenAfter('{AvailAftEOD}' ,#39+'1'+#39);

   if Name         <> '' then ReplaceTokenAfter('{Name}'        ,#39+Name        +#39);
   if ProjectFiles <> '' then ReplaceTokenAfter('{ProjectFiles}',#39+ProjectFiles+#39);
   
   if FName <> '' then ReplaceTokenAfter('{FName}'       ,FName);
   if FFile <> '' then ReplaceTokenAfter('{FFile}'       ,#39+FFile       +#39);

   if (BitMap <> nil) and (List.IndexOf('{BMPStart}') >= 0) then
   begin
      ReplaceTextBetweenTokens('{BMPStart}','{BMPEnd}',ConvertBitmap('Glyph',BitMap));
   end;
   ReplaceTextBetweenTokens('{BMPResStart}','{BMPResEnd}',#13#10'         riBitMap       : Result:='''';'#13#10'       ');
   HasSwap:=False;
   if (Items <> nil) and (Items.Count > 0) then
   begin
      ReplaceTokenAfter('{Count}',#39+IntToStr(Items.Count)+#39);
      S:=#13#10;
      SwapLines:=TStringList.Create;
      for I:=0 to Items.Count-1 do
      begin
         if Copy(Items[I],1,6) = 'SwapTo' then
         begin
            SwapLines.Add('   if (Name = '+#39+'Product'+Copy(Items[I],7,999)+#39+') then');
            SwapLines.Add('   begin');
            SwapLines.Add('      if ValidateOK and (FindTotalField(ProdForm) <> nil) then');
            SwapLines.Add('         FUIEventSink.SwapTo(Name,#8+TotalWithoutAdvDel(ProdForm)+#8+Get_ProgramID+#8+GetFormData(ProdForm)+#8+CombineList.ButtonFlags)');
            SwapLines.Add('      else');
            SwapLines.Add('         FUIEventSink.DisplayItemInfo(Self,Index,'+#39#39+','+#39#39+',0,BUTTON_ENABLED_UP,False,False);');
            SwapLines.Add('      Exit;');
            SwapLines.Add('   end;');

            S:=S+'  ResItem0'+IntToStr(I)+'           = '+#39+'Product'+Copy(Items[I],7,999)+#39+';'#13#10;
         end
         else
         begin
            S:=S+'  ResItem0'+IntToStr(I)+'           = '+#39+Items[I]+#39+';'#13#10;
         end
      end;
      ReplaceTextBetweenTokens('{ItemStart}','{ItemEnd}',S);
      if SwapLines.Count > 0 then
      begin
         ReplaceTextBetweenTokens('{SwapToStart}','{SwapToEnd}',SwapLines.Text+'   ');
         HasSwap:=True;
      end;
      SwapLines.Free;
      S:=#13#10+'         riItemBase     : if ValidateOK then Result:=ResItem00 else Result:='#39#39';'+#13#10;
      for I:=1 to Items.Count-1 do
         S:=S+'         riItemBase+'+IntToStr(I)+'   : if CombineList <> nil then Result:=CombineList.ItemName(Index-riItemBase,ResItem0'+IntToStr(I)+') else Result:=ResItem0'+IntToStr(I)+';'#13#10;
//         riItemBase+1   : if CombineList <> nil then Result:=CombineList.ItemName(Index-riItemBase,ResItem01) else Result:=ResItem01;
      ReplaceTextBetweenTokens('{ItemResStart}','{ItemResEnd}',S);
   end;

   if FName <> '' then ReplaceTokenAfter('{FName}'       ,FName);
   if (Controls <> '') then
   begin
      FieldDataList:=TStringList.Create;
      FormData:=TStringList.Create;
      ValidateData:=TStringList.Create;
      FD           :=TStringList.Create;
      FieldDataList.CommaText:=Controls;
      FormData.Add('');
      ValidateData.Add('');
      ValidateData.Add('   Result:=CheckMaskEdits(Self);');
      for I:=0 to FieldDataList.Count-1 do
      begin
         FD.CommaText:=FieldDataList[I];
         if FD.Count > 10 then
         begin
            DomainName:=RemSpace(FD[0]);
            DomainList.Add(DomainName);
            FormData.Add('   '+DomainName+'Label:TLabel;');
            if (Copy(FD[5],1,8) = 'PickList') then
               FormData.Add('   '+DomainName+':TDomainCombo;')
            else  if (Copy(FD[5],1,4) = 'List') then
            begin
               FormData.Add('   '+DomainName+':TDomainCombo;');
               ListName:=Copy(FD[5],6,Length(FD[5])-6);
               ListCombo:=DomainName;
               HasList:=True;
            end
            else
               FormData.Add('   '+DomainName+':TDomainEdit;');
            if DomainName = 'Weight' then
               HasWeight:=True
            else if DomainName = 'Standard Fee' then
               StdFee:=True;
         end;
         if FD.Count > 10 then
            ValidateData.Add(AddParams(FieldDataList[I]));
      end;
      S:=FormData.Text+'   ';
      ReplaceTextBetweenTokens('{ControlDecStart}','{ControlDecEnd}',S);
      S:=ValidateData.Text;
      if Trim(S) = '' then
         ReplaceTextBetweenTokens('{ValidateStart}','{ValidateEnd}',#13#10+'   Result:=CheckMaskEdits(Self);'+#13#10+'   ')
      else
         ReplaceTextBetweenTokens('{ValidateStart}','{ValidateEnd}',S);
      FieldDataList.Free;
      FormData.Free;
      ValidateData.Free;
      FD.Free;
   end
   else
   begin
      ReplaceTextBetweenTokens('{ValidateStart}','{ValidateEnd}',#13#10+'   Result:=True;'+#13#10+'   ');
   end;
   if Constants <> '' then
   begin
      ReplaceTextBetweenTokens('{PLUConstStart}','{PLUConstEnd}',Constants);
   end;
   if Customer <> '' then
   begin
      FormData:=TStringList.Create ;
      FormData.CommaText:=Customer;
      CustomerLine:='';
      HadCarat:=False;
      for I:=0 to FormData.Count-1 do
      begin
         if FormData[I] = '^' then
         begin
            if Length(CustomerLine) > 0 then
               CustomerLine[Length(CustomerLine)]:=',';
            HadCarat:=True;
         end
         else if DomainList.IndexOf(FormData[I]) = -1 then
         begin
            if FormData[I] = 'ListTotal' then
            begin
               if I < FormData.Count-1 then
                  CustomerLine:=CustomerLine+'ListTotal(ProdForm.'+ListCombo+')+'
               else
                  CustomerLine:=CustomerLine+'ListTotal(ProdForm.'+ListCombo+')';
            end
            else
            begin
               if I < FormData.Count-1 then
                  CustomerLine:=CustomerLine+#39+FormData[I]+#39+'+'
               else
                  CustomerLine:=CustomerLine+#39+FormData[I]+#39;
            end;
         end
         else
         begin
            if I < FormData.Count-1 then
               CustomerLine:=CustomerLine+'ProdForm.'+FormData[I]+'.Text+'
            else
               CustomerLine:=CustomerLine+'ProdForm.'+FormData[I]+'.Text';
         end;
      end;
      if not HadCarat then CustomerLine:=CustomerLine+','+#39#39;
      FD:=TStringList.Create;
      FD.Add('');
      FD.Add('   UpdateCustomerDisplay('+CustomerLine+');');
      ReplaceTextBetweenTokens('{UpdateCustStart}','{UpdateCustEnd}',FD.Text+'   ');
      FD.Free;
   end;
   if HasWeight then
   begin
      FD:=TStringList.Create ;

      FD.Add('');
      FD.Add('    function Get_NeedsWeight:WordBool; override; ');
      FD.Add('    procedure TriggerScale(Value:String); override; ');
      if HasSwap then
         FD.Add('    procedure TriggerStatusDevice0(Value:String); override; ');
      ReplaceTextBetweenTokens('{WeightProdDecStart}','{WeightProdDecEnd}',FD.Text+'    ');
      ReplaceTextBetweenTokens('{NeedsWeightStart}','{NeedsWeightEnd}','NeedsWeight:=True;'+'    ');
      FD.Clear;
      FD.Add('');
      FD.Add('function {PClass}'+PClass+'.Get_NeedsWeight: WordBool;');
      FD.Add('begin');
      FD.Add('   Result:=NeedsWeight;');
      FD.Add('end;');
      FD.Add('procedure {PClass}'+PClass+'.TriggerScale(Value:String);');
      FD.Add('var');
      FD.Add('   i:Integer;');
      FD.Add('   SubProd:IProduct;');
      FD.Add('begin');
      FD.Add('{TriggerScaleStart}');
      FD.Add('   if StrToIntDef(Value,-2) >= 0 then');
      FD.Add('   begin');
      FD.Add('      ProdForm.Weight.Ignore:=True;');
      FD.Add('      if ProdForm.Weight.Text <> Value then');
      FD.Add('      begin');
      FD.Add('         ProdForm.Weight.Text:=Value;');
      FD.Add('         for i:=0 to Self.Get_Count-1 do');
      FD.Add('            if Pos(''Product'',Self.Get_Item(i)) <> 0 then');
      FD.Add('            begin');
      FD.Add('               SubProd:=CombineList.InstanceOf(Self.Get_Item(i));  // IProduct');
      FD.Add('               SubProd.TriggerValue(tsScale,Value);');
      FD.Add('            end;');
      FD.Add('         SubProd:=nil;');
      FD.Add('');
      FD.Add('         FlagComplete(ProdForm.Validate);');
      FD.Add('         FUIEventSink.DataChanged(Self,GetFormData(ProdForm),not ValidateOK);');
      if Customer <> '' then
         FD.Add('         UpdateCustomerDisplay('+CustomerLine+');');
      FD.Add('      end;');
      FD.Add('   end');
      FD.Add('   else');
      FD.Add('   begin');
      FD.Add('      if ProdForm.Weight.Ignore then');
      FD.Add('      begin');
      FD.Add('         ProdForm.Weight.Ignore:=False;');
      FD.Add('         FlagComplete(ProdForm.Validate);');
      FD.Add('         FUIEventSink.DataChanged(Self,GetFormData(ProdForm),not ValidateOK);');
      if Customer <> '' then
         FD.Add('         UpdateCustomerDisplay('+CustomerLine+');');
      FD.Add('      end;');
      FD.Add('   end;');
      FD.Add('{TriggerScaleEnd}');
      FD.Add('end;');
      if HasSwap then
      begin
         FD.Add('');
         FD.Add('procedure {PClass}'+PClass+'.TriggerStatusDevice0(Value:String);');
         FD.Add('var');
         FD.Add('{TriggerStatusDevice0VarStart}');
         FD.Add('   SL:TPackStringList;');
         FD.Add('   I:Integer;');
         FD.Add('{TriggerStatusDevice0VarEnd}');
         FD.Add('begin');
         FD.Add('{TriggerStatusDevice0Start}');
         FD.Add('   SL:=TPackStringList.Create;');
         FD.Add('   SL.PackText:=Value;');
         FD.Add('   CombineList.ButtonFlags:=SL[2];');
         FD.Add('   SetFormData(SL[1],ProdForm);');
         FD.Add('   if SL.Count > 3 then SwapData:=SL[3];');
         FD.Add('   for I:=1 to Length(SL[2]) do');
         FD.Add('      if SL[2][I] = '#39'1'#39' then');
         FD.Add('         FUIEventSink.DisplayItemInfo(Self,I,'#39#39','#39#39',0,BUTTON_ENABLED_DOWN,False,False);');
         FD.Add('   FlagComplete(ProdForm.Validate);');
         FD.Add('   if SL[0] = '#39'Exit'#39' then');
         FD.Add('   begin');
         FD.Add('      UIEventSink.Restore');
         FD.Add('   end');
         FD.Add('   else');
         FD.Add('   begin');
         FD.Add('      FUIEventSink.DataChanged(Self,GetFormData(ProdForm),False);');
         FD.Add('   end;');
         FD.Add('   SL.Free;');
         FD.Add('{TriggerStatusDevice0End}');
         FD.Add('end;');

      end;
      ReplaceTextBetweenTokens('{WeightProdDefStart}','{WeightProdDefEnd}',FD.Text+'    ');
      FD.Free;
   end
   else
   begin
      FD:=TStringList.Create ;
      FD.Add('');
      if HasSwap then
      begin

         FD.Add('');
         FD.Add('    procedure TriggerStatusDevice0(Value:String); override; ');
         ReplaceTextBetweenTokens('{OverrideDecStart}','{OverrideDecEnd}',FD.Text+'    ');
         FD.Clear;

         FD.Add('');
         FD.Add('procedure {PClass}'+PClass+'.TriggerStatusDevice0(Value:String);');
         FD.Add('var');
         FD.Add('{TriggerStatusDevice0VarStart}');
         FD.Add('   SL:TPackStringList;');
         FD.Add('   I:Integer;');
         FD.Add('{TriggerStatusDevice0VarEnd}');
         FD.Add('begin');
         FD.Add('{TriggerStatusDevice0Start}');
         FD.Add('   SL:=TPackStringList.Create;');
         FD.Add('   SL.PackText:=Value;');
         FD.Add('   CombineList.ButtonFlags:=SL[2];');
         FD.Add('   SetFormData(SL[1],ProdForm);');
         FD.Add('   if SL.Count > 3 then SwapData:=SL[3];');
         FD.Add('   for I:=1 to Length(SL[2]) do');
         FD.Add('      if SL[2][I] = '#39'1'#39' then');
         FD.Add('         FUIEventSink.DisplayItemInfo(Self,I,'#39#39','#39#39',0,BUTTON_ENABLED_DOWN,False,False);');
         FD.Add('   FlagComplete(ProdForm.Validate);');
         FD.Add('   if SL[0] = '#39'Exit'#39' then');
         FD.Add('   begin');
         FD.Add('      UIEventSink.Restore');
         FD.Add('   end');
         FD.Add('   else');
         FD.Add('   begin');
         FD.Add('      FUIEventSink.DataChanged(Self,GetFormData(ProdForm),False);');
         FD.Add('   end;');
         FD.Add('   SL.Free;');
         FD.Add('{TriggerStatusDevice0End}');
         FD.Add('end;');
         ReplaceTextBetweenTokens('{OverrideDefStart}','{OverrideDefEnd}',FD.Text+'    ');
      end
      else
      begin
         ReplaceTextBetweenTokens('{OverrideDecStart}','{OverrideDecEnd}',FD.Text+'    ');
         ReplaceTextBetweenTokens('{OverrideDefStart}','{OverrideDefEnd}',FD.Text);
      end ;
      FD.Free;
   end;
   if HasList then
   begin
      FD:=TStringList.Create ;

      FD.Add('');
      FD.Add('    procedure TriggerStatusDevice0(Value:String); override; ');
      ReplaceTextBetweenTokens('{OverrideDecStart}','{OverrideDecEnd}',FD.Text+'    ');
      FD.Clear;

      FD.Add('');
      FD.Add('procedure {PClass}'+PClass+'.TriggerStatusDevice0(Value:String);');
      FD.Add('begin');
      FD.Add('   CalcStockDenoms(ProdForm.'+ListCombo+'.Items,StrToCurrDef(Value,0));');
      FD.Add('   FUIEventSink.DataChanged(Self,ProdForm.'+ListCombo+'.LineEditData,False);');
      FD.Add('end;');
      ReplaceTextBetweenTokens('{OverrideDefStart}','{OverrideDefEnd}',FD.Text);

      FD.Clear;

      FD.Add('');
      FD.Add('   if UIEventSink <> nil then');
      FD.Add('   begin');
      FD.Add('      if not GetAvailableStock(ProdForm.'+ListCombo+',UIEventSink.User,'+#39+ListName+#39+') then');
      FD.Add('      begin');
      FD.Add('         ProdForm.'+ListCombo+'.Clear;');
      FD.Add('         ProdForm.'+ListCombo+'.Text:='+#39+'No Stock Available'+#39+';');
      FD.Add('      end;');
      FD.Add('   end;');
      ReplaceTextBetweenTokens('{IsListStart}','{IsListEnd}',FD.Text+'    ');

      FD.Clear;
      FD.Add('');
      FD.Add('   Result:=ProdForm.'+ListCombo+'.LineEditData;');
      ReplaceTextBetweenTokens('{ListGetDataStart}','{ListGetDataEnd}',FD.Text+'   ');

      FD.Clear;
      FD.Add('');
      FD.Add('   ProdForm.'+ListCombo+'.SetLineEditData(Value);');
      FD.Add('   ProdForm.CurrentLine:=FUIEventSink.CurrentLine;');
      FD.Add('   if not FlagComplete(ProdForm.Validate) then FlagError:=True;');
      FD.Add('   Result:=ProdForm.'+ListCombo+'.LineEditData;');
      ReplaceTextBetweenTokens('{ListSetDataStart}','{ListSetDataEnd}',FD.Text+'   ');

      FD.Clear;
      FD.Add('');
      FD.Add('   LogStock(TxnLog,ProdForm.'+ListCombo+');');
      ReplaceTextBetweenTokens('{LogTransactionStart}','{LogTransactionEnd}',FD.Text+'   ');
      FD.CommaText:=ListName;
      if FD.Count > 1 then
      begin
         FD.Clear;
         FD.Add('');
         FD.Add('   Result:=True;');
      end
      else
      begin
         FD.Clear;
         FD.Add('');
         FD.Add('   Result:=SufficientStockLeft('+ListCombo+'.Items,CurrentLine);');
         FD.Add('   '+ListCombo+'.Hint:='#39'Enter Desired Quantities against each item^Total Value so far '#39'+TotalStockValue('+ListCombo+'.Items);');
      end;
      ReplaceTextBetweenTokens('{ValidateStart}','{ValidateEnd}',FD.Text+'   ');
      FD.Free;

      LogFormat:='';
   end;
   if (LogFormat = '') and (not HasList) then
   begin
      if (Items <> nil) and (Items.Count > 0) then
      begin
         if StdFee then
            LogFormat:='Name,StandardFee'
         else
            ReplaceTextBetweenTokens('{LogTransactionStart}','{LogTransactionEnd}','');
      end
      else if DomainList.Count = 0 then
      begin
         FD:=TStringList.Create;
         FD.Add('');
         FD.Add('if (not Nested) and (UIEventSink <> nil) then UIEventSink.Restore;');
         FD.Add('');
         ReplaceTextBetweenTokens('{IsListStart}','{IsListEnd}',FD.Text);
         FD.Free;
      end;
   end;
   if Endorse <> '' then
   begin
      FormData:=TStringList.Create ;
      FormData.CommaText:=Endorse;
      EndorseLine:='';
      for I:=0 to FormData.Count-1 do
      begin
         if FormData[I] = '^' then
         begin
            if Length(EndorseLine) > 0 then
               EndorseLine[Length(EndorseLine)]:='+';
            EndorseLine:=EndorseLine+#39+'","'+#39;
         end
         else if DomainList.IndexOf(FormData[I]) = -1 then
         begin
            if I < FormData.Count-1 then
               EndorseLine:=EndorseLine+#39+FormData[I]+#39+'+'
            else
               EndorseLine:=EndorseLine+#39+FormData[I]+#39;
         end
         else
         begin
            if I < FormData.Count-1 then
               EndorseLine:=EndorseLine+'ProdForm.'+FormData[I]+'.Text+'
            else
               EndorseLine:=EndorseLine+'ProdForm.'+FormData[I]+'.Text';
         end;
      end;
      FD:=TStringList.Create;
      FD.Add('');
      FD.Add('   if SwapData = '#39#39' then');
      FD.Add('   begin');
      FD.Add('      if not EndorseLabel(StrToCurrDef(ProdForm.TotalFee.Text,0),TxnLog,EndorseData(StrToCurrDef(ProdForm.TotalFee.Text,0),'+EndorseLine+',DateTimeToStr(now),GetFormData(ProdForm)),False) then ');
      FD.Add('      begin');
      FD.Add('         TerminateExecute(TxnLog);');
      FD.Add('         Exit;');
      FD.Add('      end;');
      FD.Add('   end');
      FD.Add('   else');
      FD.Add('   begin');
      FD.Add('      TxnLog.SubLogVisible:=True; // Fudge to Log all values as Zero Price');
      FD.Add('   end;');
      ReplaceTextBetweenTokens('{EndorseStart}','{EndorseEnd}',FD.Text+'   ');
      FD.Clear;
      //FD.Add('   TxnLog.WriteTransaction( ''PrLabel'',0,-1,0,0-StrToCurrDef(ProdForm.TotalFee.Text,0),0-StrToCurrDef(ProdForm.TotalFee.Text,0),'''','''','''','''');');
      FD.Add('//log a -ve PrLabel to contra printed label log when customer pays');
      FD.Add('TxnLog.WriteTransaction( ''PrLabel'',0,-1,Get_PLU, -StrToCurrDef(ProdForm.TotalFee.Text,0),'   );
      FD.Add('                         -StrToCurrDef(ProdForm.TotalFee.Text,0), Get_Description,PrLabelGUID,Get_ProgramID,'''');' );
      ReplaceTextBetweenTokens('{PostLogTransactionStart}','{PostLogTransactionEnd}',FD.Text+'   ');
      FD.Free;
   end;
   if LogFormat <> '' then
   begin
      FD      :=TStringList.Create ;
      FormData:=TStringList.Create ;
      ValidateData:=TStringList.Create ;
      FormData.CommaText:=LogFormat;
      if FormData.Count > 1 then
      begin
         ValidateData.CommaText:=FormData[0];
         FD.Add('');
         Index:=0;
         while ValidateData.Count > 0 do
         begin
            S:='';
            T:='';
            I:=0;
            while I < ValidateData.Count do
            begin
               if ValidateData[0] = 'Name' then
               begin
                  T:='Get_Description';
                  ValidateData.Delete(0);
               end
               else if Copy(ValidateData[0],1,1) = '^' then
               begin
                  ValidateData.Delete(0);
                  I:=ValidateData.Count;
               end
               else
               begin
                  if Copy(ValidateData[0],1,1) <> '*' then
                  begin
                     ValidateData[0]:='ProdForm.'+ValidateData[0]+'.Text';
                  end
                  else
                  begin
                     ValidateData[0]:=#39+Copy(ValidateData[0],2,999)+#39;
                  end;
                  if T = '' then
                     T:=ValidateData[0]
                  else
                     S:=S+ValidateData[0]+'+'#39+' '+#39'+';
                  ValidateData.Delete(0);
               end;
            end;
            if Copy(S,Length(S),1) = '+' then
               Delete(S,Length(S)-4,5);
            FD.Add('   TxnLog.LogTransaction(');
            FD.Add('          Index,');
            FD.Add('          FQuantity, // Quantity');
            if Index = 0 then
            begin
               FD.Add('          Get_PLU, // PLU');
               FD.Add('          FQuantity*StrToCurrDef(ProdForm.'+FormData[1]+'.Text,0), // Value');
               FD.Add('          StrToCurrDef(ProdForm.'+FormData[1]+'.Text,0), // Price');
            end
            else
            begin
               FD.Add('          0, // PLU');
               FD.Add('          0, // Value');
               FD.Add('          0, // Price');
            end;
            if T = '' then
               FD.Add('          '+#39#39+', // Description')
            else
               FD.Add('          '+T+', // Description');
            if S = '' then
               FD.Add('          '+#39#39+', // Additional Info')
            else
               FD.Add('          '+S+', // Additional Info');
            if Index = 0 then
               FD.Add('          Get_ProgramID, // ProgID')
            else
               FD.Add('          '+#39#39+', // ProgID');
            if Index = 0 then
               FD.Add('          Enumerate(ProdForm)); // Domain Info')
            else
               FD.Add('          '+#39#39+'); // Domain Info');
            FD.Add('    Inc(Index);');
            Inc(Index);
         end;
         FD.Add('    if CombineList <> nil then');
         FD.Add('       CombineList.LogTransactions(Index,TxnLog);');
         FD.Add('   ');
         S:=FD.Text;
         Delete(S,Length(S),1);
      end;
      ReplaceTextBetweenTokens('{LogTransactionStart}','{LogTransactionEnd}',S);
      FormData.Free;
      FD.Free;
      ValidateData.Free;
   end;
   if PrintList <> '' then
   begin
      FD:=TStringList.Create;
      FD.CommaText:=PrintList;
      if FD.Count > 0 then
      begin
         if FD[0] = 'Summary' then
           SummaryType:='stSummary'
         else if FD[0] = 'Detail' then
           SummaryType:='stDetail'
         else
           SummaryType:='stEveryLine';
      end;
      if FD.Count = 2 then
      begin
         if FD[1] = 'Stock' then
            S:='   StockReport;'
         else
            S:='   TxnReport('+#39+FD[1]+#39+','+#39#39+','+#39#39+','+SummaryType+','+#39#39+');';
      end
      else if FD.Count = 4 then
      begin
         S:='   TxnReport('+#39+FD[1]+#39+',ProdForm.'+FD[2]+'.Text,ProdForm.'+FD[3]+'.Text,'+SummaryType+','+#39#39+');';
      end
      else if FD.Count = 5 then
      begin
         S:='   TxnReport('+#39+FD[1]+#39+',ProdForm.'+FD[2]+'.Text,ProdForm.'+FD[3]+'.Text,'+SummaryType+',ProdForm.'+FD[4]+'.Text);';
      end;
      FD.Clear;
      FD.Add('');
      if HasList then
         FD.Add('   LogStock(TxnLog,ProdForm.'+ListCombo+');');
      FD.Add(S);
      ReplaceTextBetweenTokens('{LogTransactionStart}','{LogTransactionEnd}',FD.Text+'   ');
      FD.Free;
   end;
   if FillList <> '' then
   begin
      FD:=TStringList.Create;
      FD.CommaText:=FillList;
      if FD.Count = 1 then
      begin
         if FD[1] = 'Declare' then
         begin
         end;
      end;
      FD.Clear;
      FD.Add('');
      FD.Add(S);
      ReplaceTextBetweenTokens('{LogTransactionStart}','{LogTransactionEnd}',FD.Text+'   ');
      FD.Free;
   end;
   DomainList.Free;
   if Snippets.Count > 0 then
   begin
      for I:=0 to (Snippets.Count-1) div 3 do
         ReplaceTextBetweenTokens(Snippets[(I*3)+0],Snippets[(I*3)+1],Snippets[(I*3)+2]);
   end;
   // Replace Class names again - after snippets have been added
   if PClass <> '' then ReplaceTokenAfter('{PClass}'      ,PClass);

   inherited SaveToFile(FileName); // Save the Token List
end;

function LabelObject(Name,Caption:String;YOffset:Integer):String;
var
   SL:TStringList;
begin
   SL:=TStringList.Create;
   SL.Add('    object '+Name+': TLabel');
   SL.Add('      Left = 4');
   SL.Add('      Top = '+IntToStr(YOffset));
   SL.Add('      Width = 110');
   SL.Add('      Height = 13');
   SL.Add('      Caption = '''+Caption+'''');
   SL.Add('    end');
   Result:=SL.Text;
   SL.Free;
end;
function DomainListObject(Name,Mask,Hint,AssocLabel,AssocProgId,Error,DefaultValue:String;TabOrder,YOffset:Integer;Enabled,Ignore:Boolean;Locale:integer):String;
var
   SL:TStringList;
   i :Integer;
   A_ProgID :String;
begin
   SL:=TStringList.Create;
   SL.Add('    object '+Name+': TDomainCombo');
   SL.Add('      Left = 122');
   SL.Add('      Top = '+IntToStr(YOffset));
   SL.Add('      Width = 121');
   SL.Add('      Height = 21');
   for i:=0 to Length(Mask)-1 do
     if Mask[i] = '(' then
     begin
       A_ProgID:=Copy(Mask,i+1,Length(Mask)-i-1);
       break;
     end;
   SL.Add('      AssociatedProgId = '''+ A_ProgID +'''');
   SL.Add('      Hint = '''+Hint+'''');
   SL.Add('      TabOrder = '+IntToStr(TabOrder));
   SL.Add('      PromptLabel = '+AssocLabel);
   if DefaultValue <> '' then
   begin
      SL.Add('      DefaultValue = '''+DefaultValue+'''');
      SL.Add('      UseDefault = True');
   end
   else
   begin
      SL.Add('      UseDefault = False');
   end;
   SL.Add('      ErrorText = '''+Error+'''');
   SL.Add('      EMaskValue = ''Mask(999999999)''');
   SL.Add('      Locale = '+IntToStr(Locale));   
   if Enabled then
      SL.Add('      Enabled = True')
   else
      SL.Add('      Enabled = False');
   if Ignore then
      SL.Add('      Ignore = True')
   else
      SL.Add('      Ignore = False');
   SL.Add('    end');
   Result:=SL.Text;
   SL.Free;
end;

function DomainObject(Name,Mask,Hint,AssocLabel,AssocProgId,Error,DefaultValue:String;TabOrder,YOffset:Integer;Enabled,Ignore:Boolean;Locale:integer):String;
var
   SL:TStringList;
begin
   if (Copy(Mask,1,8) = 'PickList')
   or (Copy(Mask,1,4) = 'List') then
   begin
      Result:=DomainListObject(Name,Mask,Hint,AssocLabel,AssocProgId,Error,DefaultValue,TabOrder,YOffset,Enabled,Ignore,Locale);
      Exit;
   end;
   SL:=TStringList.Create;
   SL.Add('    object '+Name+': TDomainEdit');
   SL.Add('      Left = 122');
   SL.Add('      Top = '+IntToStr(YOffset));
   SL.Add('      Width = 121');
   SL.Add('      Height = 21');
   SL.Add('      Validation = '''+Mask+'''');
   SL.Add('      Locale = '+IntToStr(Locale));
   SL.Add('      Hint = '''+Hint+'''');
   SL.Add('      TabOrder = '+IntToStr(TabOrder));
   SL.Add('      PromptLabel = '+AssocLabel);
   SL.Add('      DefaultValue = '''+DefaultValue+'''');
   if AssocProgId <> '' then
   begin
      if AssocProgId = 'TotalField' then
      begin
         SL.Add('      AssociatedProgId = '''+AssocProgId+'''')
      end
      else
      if AssocProgId = 'NoParams' then
      begin
         SL.Add('      UseDefault = True');
      end
      else
      begin
         SL.Add('      AssociatedProgId = ''Product.'+AssocProgId+'''');
         SL.Add('      UseDefault = True');
      end;
   end ;
   //else if DefaultValue <> '' then
   //begin
   //   SL.Add('      UseDefault = True');
   //end;
   SL.Add('      ErrorText = '''+Error+'''');
   SL.Add('      RangeFrom = 0');
   SL.Add('      RangeTo = 0');
   if Enabled then
      SL.Add('      Enabled = True')
   else
      SL.Add('      Enabled = False');
   if Ignore then
      SL.Add('      Ignore = True')
   else
      SL.Add('      Ignore = False');
   SL.Add('    end');
   Result:=SL.Text;
   SL.Free;
end;
function FormHeader:String;
var
   SL:TStringList;
begin              
   SL:=TStringList.Create;
   SL.Add('object ProdForm: TProdForm');
   SL.Add('  Left = 540');
   SL.Add('  Top = 223');
   SL.Add('  Width = 306');
   SL.Add('  Height = 494');
   SL.Add('  Font.Charset = DEFAULT_CHARSET');
   SL.Add('  Font.Color = clWindowText');
   SL.Add('  Font.Height = -11');
   SL.Add('  Font.Name = ''MS Sans Serif''');
   SL.Add('  Font.Style = []');
   SL.Add('  PixelsPerInch = 96');
   SL.Add('  TextHeight = 13');
   Result:=SL.Text;
   SL.Free;
end;
function FormFooter:String;
begin
   Result:='end';
end;
function FormField(Name,Caption,Prompt,Hint,Error,Mask,ProgId,DefaultValue:String;Enabled,Ignore:Boolean;TabOrder,Locale:Integer):String;
var
   SL:TStringList;
begin
   SL:=TStringList.Create;
   SL.Add(LabelObject(Name+'Label',Caption,TabOrder*30+15));
   SL.Add(DomainObject(Name,Mask,Hint,Name+'Label',ProgId,Error,DefaultValue,TabOrder,TabOrder*30+12,Enabled,Ignore,Locale));
   Result:=SL.Text;
   SL.Free;
end;
procedure GenerateFormFile(FileName,FieldData:String);
var
   FormStream:TFileStream;
   TextStream:TStringStream;
   FormData:TStringList;
   FieldDataList:TStringList;
   FD:TStringList;
   I,TabOrder:Integer;
begin
   FormData:=TStringList.Create;

   FieldDataList:=TStringList.Create;
   FD:=TStringList.Create;

   FieldDataList.CommaText:=FieldData;

   TabOrder:=0;
   FormData.Add(FormHeader);
   for I:=0 to FieldDataList.Count-1 do
   begin
      FD.CommaText:=FieldDataList[I];
      if FD.Count > 11 then
         FormData.Add(FormField(RemSpace(FD[0]),FD[1],FD[2],FD[3],FD[4],FD[5],
                                FD[6],FD[7],FD[8]='Y',FD[9]='Y',TabOrder,StrToIntDef(FD[11],0)))
      else if FD.Count > 9 then
      begin
         FormData.Add(FormField(RemSpace(FD[0]),FD[1],FD[2],FD[3],FD[4],FD[5],
                                FD[6],FD[7],FD[8]='Y',FD[9]='Y',TabOrder,0 ));
      end;
      Inc(TabOrder);      
   end;
   FormData.Add(FormFooter);
   
   FD.Free;
   FieldDataList.Free;
   TextStream:=TStringStream.Create(FormData.Text);   // Place Data in Stream
   FormData.Free;
   
   try
      if FileExists(FileName) then
         FormStream:=TFileStream.Create(FileName,fmOpenReadWrite) // Open Form File
      else
         FormStream:=TFileStream.Create(FileName,fmCreate); // Create Form File
   except
      FormStream:=TFileStream.Create(FileName,fmCreate); // Create Form File
   end;
   
   ObjectTextToResource(TextStream,FormStream);       // Convert From Text To Form
   FormStream.Free;                                   // Close Form
   TextStream.Free;
end;

end.
