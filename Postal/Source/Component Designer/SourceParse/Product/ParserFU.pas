unit ParserFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,TokenParser,
  StdCtrls,ActiveX,ExtCtrls;

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
  TProductGen = class(TTokenList)
  public
     PClass      :String;
     PName       :String;
     UName       :String;
     UFile       :String;
     PGUID       :String;
     PProgID     :String;
     PRegDesc    :String;
     Version     :String;
     BarCode     :String;
     Description :String;
     EndDate     :String;
     HighDays    :String;
     MaxQuantity :String;
     MCRCode     :String;
     MinQuantity :String;
     OCRCode     :String;
     OtherCode   :String;
     PLU         :String;
     Regulations :String;
     StartDate   :String;
     UnitPrice   :String;
     UnitQuantity:String;
     UseDays     :String;
     Caption     :String;
     Title       :String;
     Prompt      :String;
     Hint        :String;
     BitMap      :TBitMap;
     procedure SaveToFile(FileName:String); override;
  end;
var
  Form1: TForm1;

implementation

{$R *.DFM}

{TProductGen}
procedure TProductGen.SaveToFile(FileName:String);
var
  guid:TGUID;
  GUIDstr:Array [0..50] of WideChar;
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
   ReplaceTokenAfter('{BarCode}'     ,#39+BarCode     +#39);
   ReplaceTokenAfter('{Description}' ,#39+Description +#39);
   ReplaceTokenAfter('{EndDate}'     ,#39+EndDate     +#39);
   ReplaceTokenAfter('{HighDays}'    ,#39+HighDays    +#39);
   ReplaceTokenAfter('{MaxQuantity}' ,#39+MaxQuantity +#39);
   ReplaceTokenAfter('{MCRCode}'     ,#39+MCRCode     +#39);
   ReplaceTokenAfter('{MinQuantity}' ,#39+MinQuantity +#39);
   ReplaceTokenAfter('{OCRCode}'     ,#39+OCRCode     +#39);
   ReplaceTokenAfter('{OtherCode}'   ,#39+OtherCode   +#39);
   ReplaceTokenAfter('{PLU}'         ,#39+PLU         +#39);
   ReplaceTokenAfter('{Regulations}' ,#39+Regulations +#39);
   ReplaceTokenAfter('{StartDate}'   ,#39+StartDate   +#39);
   ReplaceTokenAfter('{UnitPrice}'   ,#39+UnitPrice   +#39);
   ReplaceTokenAfter('{UnitQuantity}',#39+UnitQuantity+#39);
   ReplaceTokenAfter('{UseDays}'     ,#39+UseDays     +#39);
   ReplaceTokenAfter('{Caption}'     ,#39+Caption     +#39);
   ReplaceTokenAfter('{Title}'       ,#39+Title       +#39);
   ReplaceTokenAfter('{Prompt}'      ,#39+Prompt      +#39);
   ReplaceTokenAfter('{Hint}'        ,#39+Hint        +#39);

   if BitMap <> nil then
   begin
      ReplaceTextBetweenTokens('{BMPStart}','{BMPEnd}',ConvertBitmap('Glyph',BitMap));
   end;
   ReplaceTextBetweenTokens('{BMPResStart}','{BMPResEnd}',#13#10'       riBitMap       : Result:='''';'#13#10'       ');

   inherited SaveToFile(FileName);
end;
procedure TForm1.Button1Click(Sender: TObject);
var
   ProductGen:TProductGen;
begin
   ProductGen:=TProductGen.Create('');
   
   ProductGen.PClass    :='TTestProduct';
   ProductGen.PName     :='TestProduct';     
   ProductGen.UName     :='TestProductAU';
   ProductGen.UFile     :='TestProductAU.pas';
   ProductGen.PGUID     :='';
   ProductGen.PProgID   :='Product.TryProduct';
   ProductGen.PRegDesc  :='GPCS TryProduct Product';
   
   ProductGen.Version     :='1';
   ProductGen.BarCode     :='';
   ProductGen.Description :='Test Product';
   ProductGen.EndDate     :='';
   ProductGen.HighDays    :='';
   ProductGen.MaxQuantity :='0';
   ProductGen.MCRCode     :='';
   ProductGen.MinQuantity :='1';
   ProductGen.OCRCode     :='';
   ProductGen.OtherCode   :='';
   ProductGen.PLU         :='12345';
   ProductGen.Regulations :='';
   ProductGen.StartDate   :='';
   ProductGen.UnitPrice   :='100';
   ProductGen.UnitQuantity:='1';
   ProductGen.UseDays     :='';
   ProductGen.Caption     :='Test Product';
   ProductGen.Title       :='Test Product';
   ProductGen.Prompt      :='Test Product';
   ProductGen.Hint        :='Test Product';
   ProductGen.BitMap:=Image1.Picture.BitMap;
   
   // generated dpr
   ProductGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\Product\Simple\GenFromProduct.dpr');
   ProductGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestProduct.dpr');

   // generated pas
   ProductGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\Product\Simple\GenFromProductAU.pas');
   ProductGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestProductAU.pas');
   
   Close;
end;

end.
