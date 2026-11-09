unit GppassFU;

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
     Caption     :String;
     Key         :String;
     Count       :String;
     Title       :String;
     Prompt      :String;
     Hint        :String;
     BitMap      :TBitMap;
     Items       :TPackStringList;
     ItemResStart:String;
     ItemResEnd  :String;
     procedure SaveToFile(FileName:String); override;
     constructor CreateGp( Value :String ) ;
     destructor  Destroy ; override ;
  end;
var
  Form1: TForm1;

implementation

{$R *.DFM}

{TGroupGen}
constructor TGroupGen.CreateGp( Value :String ) ;
begin
  Items := TPackStringList.Create ;
  inherited Create( Value ) ;

end ;

destructor TGroupGen.Destroy ;
begin
  Items.Free ;
  inherited ;
end ;

procedure TGroupGen.SaveToFile(FileName:String);
var
  guid:TGUID;
  GUIDstr:Array [0..50] of WideChar;
  ItemResItems, ItemsInf :TPackStringList;
  ItemNum : integer ;
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
   ReplaceTokenAfter('{Caption}'     ,#39+Caption     +#39);
   ReplaceTokenAfter('{Key}'         ,#39+Key         +#39);
   ReplaceTokenAfter('{Count}'       ,#39+Count       +#39);
   ReplaceTokenAfter('{Title}'       ,#39+Title       +#39);
   ReplaceTokenAfter('{Prompt}'      ,#39+Prompt      +#39);
   ReplaceTokenAfter('{Hint}'        ,#39+Hint        +#39);


   ItemResItems := TPackStringList.Create ;
   ItemsInf     := TPackStringList.Create ;

   ItemsInf.Add( '' );
   for ItemNum := 1 to Items.Count -1 do
   begin
     ItemsInf.Add( '  '+Items[ ItemNum ]+'           = '#39'Product.Try'+Format('%2.2d', [ItemNum])+''#39';  ');
   end ;

   ItemsInf[1] := '  ResItem00           = '#39'Group.Try2'#39';  ';

   ItemResItems.Add('');
   for ItemNum := 0 to Items.Count -1 do
   begin
     ItemResItems.Add('         riItemBase'+IntToStr(ItemNum)+'     : Result:=ResItem'+Format('%2.2d', [ItemNum])+';');
   end ;


   if BitMap <> nil then
   begin
      ReplaceTextBetweenTokens('{BMPStart}','{BMPEnd}',ConvertBitmap('Glyph',BitMap));
   end;
   ReplaceTextBetweenTokens('{BMPResStart}','{BMPResEnd}',#13#10'         riBitMap       : Result:='''';'#13#10'       ');

   ReplaceCommaTextBetweenTokens('{ItemStart}','{ItemEnd}', ItemsInf.CommaText );
   ReplaceCommaTextBetweenTokens('{ItemResStart}','{ItemResEnd}',ItemResItems.CommaText );

   inherited SaveToFile(FileName);

   ItemResItems.Free ;
   ItemsInf.Free ;

end;
procedure TForm1.Button1Click(Sender: TObject);
var
   GroupGen:TGroupGen;
begin
   GroupGen:=TGroupGen.CreateGp('');

   GroupGen.PClass    :='TTestGroup';
   GroupGen.PName     :='TestGroup';
   GroupGen.UName     :='TestGroupAU';
   GroupGen.UFile     :='TestGroupAU.pas';
   GroupGen.PGUID     :='';
   GroupGen.PProgID   :='Group.TryGroup';
   GroupGen.PRegDesc  :='GPCS TryGroup Group';

   GroupGen.Version     :='1';
   GroupGen.Caption     :='Test Group';
   GroupGen.Title       :='Test Group';
   GroupGen.Prompt      :='Test Group';
   GroupGen.Hint        :='Test Group';
   GroupGen.BitMap:=Image1.Picture.BitMap;


   GroupGen.Items.Add( 'ResItem00' );
   GroupGen.Items.Add( 'ResItem01' );
   GroupGen.Items.Add( 'ResItem02' );
   GroupGen.Items.Add( 'ResItem03' );
   GroupGen.Items.Add( 'ResItem04' );
   GroupGen.Items.Add( 'ResItem05' );
   GroupGen.Items.Add( 'ResItem06' );
   GroupGen.Items.Add( 'ResItem07' );
   GroupGen.Items.Add( 'ResItem08' );
   GroupGen.Items.Add( 'ResItem09' );


   // generated dpr
   GroupGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\Group\GenFromGroup.dpr');
   GroupGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestGroup.dpr');

   // generated pas
   GroupGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\Group\GenFromGroupAU.pas');
   GroupGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestGroupAU.Pas');

   GroupGen.Items.Free ;
   Close;
end;

end.
