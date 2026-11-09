unit WGpassFU;

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
  TWGroupGen = class(TTokenList)
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
     Items       :TPackStringList ;

     procedure    SaveToFile(FileName:String); override;
     constructor  CreateUG( Value :String ) ;
     destructor   Destroy ; override ;
  end;
var
  Form1: TForm1;

implementation

{$R *.DFM}

{TWGroupGen}
constructor TWGroupGen.CreateUG( Value :String ) ;
begin
  Items    := TPackStringList.Create ;
  inherited Create( Value ) ;
end ;

destructor TWGroupGen.Destroy ;
begin
  Items.Free ;
  inherited ;
end ;

procedure TWGroupGen.SaveToFile(FileName:String);
var
  ItemList, ItemRes   : TPackStringList ;
  ItemCount : integer ;
  ItemStr   : String ;
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

   ItemRes  := TPackStringList.Create ;
   ItemList := TPackStringList.Create ;

   ReplaceTokenAfter('{PClass}'      ,PClass);
   ReplaceTokenAfter('{PName}'       ,PName);
   ReplaceTokenAfter('{UName}'       ,UName);
   ReplaceTokenAfter('{UFile}'       ,#39+UFile       +#39);
   ReplaceTokenAfter('{PGUID}'       ,#39+PGUID       +#39);
   ReplaceTokenAfter('{PProgID}'     ,#39+PProgID     +#39);
   ReplaceTokenAfter('{PRegDesc}'    ,#39+PRegDesc    +#39);

   ReplaceTokenAfter('{Version}'     ,#39+Version     +#39);
   ReplaceTokenAfter('{Count}'       ,#39+Count       +#39);

   ItemRes.Add('');
   ItemList.Add('');
   for ItemCount := 0 to Items.Count -1 do
   begin
    ItemStr :='         riItemBase'+IntToStr(ItemCount)+'          ';
    ItemStr := Copy( ItemStr, 1, 24);

    ItemRes.Add( ItemStr + ': Result:=ResItem'+Format('%2.2d', [ItemCount])+';' );
    ItemList.Add( Items[ ItemCount ] );
   end ;


   ReplaceCommaTextBetweenTokens('{ItemStart}','{ItemEnd}', ItemList.CommaText );
   ReplaceCommaTextBetweenTokens('{ItemResStart}','{ItemResEnd}', ItemRes.CommaText );

   inherited SaveToFile(FileName);

  ItemRes.Free ;
  ItemList.Free ;

end;
procedure TForm1.Button1Click(Sender: TObject);
var
   WGroupGen:TWGroupGen;
begin
   WGroupGen:=TWGroupGen.CreateUG('');

   WGroupGen.PClass    :='TTestWGroup';
   WGroupGen.PName     :='TestWGroup';
   WGroupGen.UName     :='TestWGroupAU';
   WGroupGen.UFile     :='TestWGroupAU.pas';
   WGroupGen.PGUID     :='';
   WGroupGen.PProgID   :='WGroup.TryWGroup';
   WGroupGen.PRegDesc  :='GPCS TryWGroup WGroup';

   WGroupGen.Version     :='1';
   WGroupGen.Count       :='2';


   WGroupGen.Items.Add('  ResItem00           =  '#39'WGroup.Try1'#39';');
   WGroupGen.Items.Add('  ResItem01           =  '#39'WGroup.Try3'#39';');


   // generated dpr
   WGroupGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\WGroup\GenFromWGroup.dpr');
   WGroupGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestWGroup.dpr');

   // generated pas
   WGroupGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\WGroup\GenFromWGroupAU.pas');
   WGroupGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestWGroupAU.pas');

   Close;
end;

end.
