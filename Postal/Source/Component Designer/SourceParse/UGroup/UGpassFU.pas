unit UGpassFU;

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
     Items       :TPackStringList ;
     procedure    SaveToFile(FileName:String); override;
     constructor  CreateUG( Value :String ) ;
     destructor   Destroy ; override ;
  end;
var
  Form1: TForm1;

implementation

{$R *.DFM}

{TUGroupGen}
constructor TUGroupGen.CreateUG( Value :String ) ;
begin
  Items    := TPackStringList.Create ;
  inherited Create( Value ) ;
end ;

destructor TUGroupGen.Destroy ;
begin

  Items.Free ;

  inherited ;
end ;

procedure TUGroupGen.SaveToFile(FileName:String);
var
  guid:TGUID;
  GUIDstr:Array [0..50] of WideChar;
  ItemList, ItemRes  : TPackStringList;
  ItemCount : integer ;
  ItemStr : String ;

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
    ItemList.Add( Items[0] ) ;
   end ;

   //UGroupGen.ItemRes.Add('         riItemBase     : Result:=ResItem00;');
   //UGroupGen.ItemRes.Add('         riItemBase+1   : Result:=ResItem01;');

   ReplaceCommaTextBetweenTokens('{ItemStart}','{ItemEnd}', ItemList.CommaText );
   ReplaceCommaTextBetweenTokens('{ItemResStart}','{ItemResEnd}', ItemRes.CommaText );

   inherited SaveToFile(FileName);

   ItemRes.Free ;
   ItemList.Free ;

end;
procedure TForm1.Button1Click(Sender: TObject);
var
   UGroupGen:TUGroupGen;
begin
   UGroupGen:=TUGroupGen.CreateUG('');

   UGroupGen.PClass    :='TTestUGroup';
   UGroupGen.PName     :='TestUGroup';
   UGroupGen.UName     :='TestUGroupAU';
   UGroupGen.UFile     :='TestUGroupAU.pas';
   UGroupGen.PGUID     :='';
   UGroupGen.PProgID   :='UGroup.TryUGroup';
   UGroupGen.PRegDesc  :='GPCS TryUGroup UGroup';

   UGroupGen.Version     :='1';
   UGroupGen.Count       :='2';

   UGroupGen.Items.Add('  ResItem00           =  '#39'UGroup.Try1'#39';');
   UGroupGen.Items.Add('  ResItem01           =  '#39'UGroup.Try3'#39';');


   // generated dpr
   UGroupGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\UGroup\GenFromUGroup.dpr');
   UGroupGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestUGroup.dpr');

   // generated pas
   UGroupGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\UGroup\GenFromUGroupAU.pas');
   UGroupGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestUGroupAU.pas');

   Close;
end;

end.
