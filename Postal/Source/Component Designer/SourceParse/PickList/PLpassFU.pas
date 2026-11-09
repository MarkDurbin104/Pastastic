unit PLpassFU;

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
     Count       :String;
     ColumnCount :String;
     ColumnNameItems    :TPackStringList ;
     DimensionItems     :TPackStringList ;
     ColumnNameResItems :TPackStringList ;
     DimensionResItems  :TPackStringList ;

     procedure SaveToFile(FileName:String); override;
     constructor CreateGp( Value :String ) ;
     destructor  Destroy ; override ;
  end;
var
  Form1: TForm1;

implementation

{$R *.DFM}

{TPickListGen}
constructor TPickListGen.CreateGp( Value :String ) ;
begin

  ColumnNameItems     :=TPackStringList.Create;
  DimensionItems      :=TPackStringList.Create;
  ColumnNameResItems  :=TPackStringList.Create;
  DimensionResItems   :=TPackStringList.Create;


  inherited Create( Value ) ;

end ;

destructor TPickListGen.Destroy ;
begin

  ColumnNameItems.Free    ;
  DimensionItems.Free     ;
  ColumnNameResItems.Free ;
  DimensionResItems.Free  ;

  inherited ;

end ;

procedure TPickListGen.SaveToFile(FileName:String);
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
   ReplaceTokenAfter('{Count}'       ,#39+Count       +#39);
   ReplaceTokenAfter('{ColumnCount}' ,#39+ColumnCount +#39);

   ReplaceCommaTextBetweenTokens('{ColumnNameStart}','{ColumnNameEnd}', ColumnNameItems.CommaText );
   ReplaceCommaTextBetweenTokens('{DimensionStart}','{DimensionEnd}',DimensionItems.CommaText );
   ReplaceCommaTextBetweenTokens('{ColumnNameResStart}','{ColumnNameResEnd}',ColumnNameResItems.CommaText );
   ReplaceCommaTextBetweenTokens('{DimensionResStart}','{DimensionResEnd}',DimensionResItems.CommaText );

   inherited SaveToFile(FileName);
end;
procedure TForm1.Button1Click(Sender: TObject);
var
   PickListGen:TPickListGen;
begin
   PickListGen:=TPickListGen.CreateGp('');

   PickListGen.PClass    :='TTestPickList';
   PickListGen.PName     :='TestPickList';
   PickListGen.UName     :='TestPickListAU';
   PickListGen.UFile     :='TestPickListAU.pas';
   PickListGen.PGUID     :='';
   PickListGen.PProgID   :='PickList.TryPickList';
   PickListGen.PRegDesc  :='GPCS TryPickList PickList';

   PickListGen.Version     :='1';
   PickListGen.Count       :='1';
   PickListGen.ColumnCount :='1';


   PickListGen.ColumnNameItems.Add('');
   PickListGen.ColumnNameItems.Add('  ResColumnName00     = '#39'Test Column 0'#39';');
   PickListGen.DimensionItems.Add('');
   PickListGen.DimensionItems.Add('  ResDimension00           = '#39'1'#39';');

   PickListGen.ColumnNameResItems.Add('') ;
   PickListGen.ColumnNameResItems.Add('         riColumnName   : Result:=ResColumnName00;');
   PickListGen.DimensionResItems.Add('');
   PickListGen.DimensionResItems.Add('         riDimensionBase    : Result:=ResDimension00;');


   // generated dpr
   PickListGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\PickList\GenFromPickList.dpr');
   PickListGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestPickList.dpr');

   // generated pas
   PickListGen.LoadFromFile('e:\Corvus\Generated Components\Generate From\PickList\GenFromPickListAU.pas');
   PickListGen.SaveToFile('e:\Corvus\Source\Build Components\TokenParser\TestPickListAU.Pas');

   Close;
end;

end.
