unit StockFU;

interface



uses
  StockPassU,StockU, StockData, StringUtil,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, ComCtrls,GPCSGUID,PackStrListU,
  Consts ;

const
   K_STOCK = 'Stock.dat' ;
type
  TStockForm = class(TForm)
    OD: TOpenDialog;
    PageControl1: TPageControl;
    StockItems: TTabSheet;
    Label1: TLabel;
    ItemList: TListBox;
    LoadButton: TButton;
    PassButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ItemListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure LoadButtonClick(Sender: TObject);
    procedure PassButtonClick(Sender: TObject);
    function NewFile : String ;
  private
    NewFileName : String ;
  public
    SiteStockPass:TSiteStockPass;
  end;

var
  StockForm: TStockForm;

implementation

{$R *.DFM}
uses
   ComServ2 ;

procedure CopyFile(const FileName, DestName: TFileName);
var
  CopyBuffer: Pointer; { buffer for copying }
  BytesCopied: Longint;
  Source, Dest: Integer; { handles }
  Destination: TFileName; { holder for expanded destination name }
const
  ChunkSize: Longint = 8192; { copy in 8K chunks }
begin
//  Destination := ExpandFileName(DestName); { expand the destination path }
  Destination := DestName ;
//  if HasAttr(Destination, faDirectory) then { if destination is a directory... }
//    Destination := Destination + '\' + ExtractFileName(FileName); { ...clone file name }
  GetMem(CopyBuffer, ChunkSize); { allocate the buffer }
  try
    Source := FileOpen(FileName, fmShareDenyWrite); { open source file }
    if Source < 0 then raise EFOpenError.CreateFmt(SFOpenError, [FileName]);
    try
      Dest := FileCreate(Destination); { create output file; overwrite existing }
      if Dest < 0 then raise EFCreateError.CreateFmt(SFCreateError, [Destination]);
      try
        repeat
          BytesCopied := FileRead(Source, CopyBuffer^, ChunkSize); { read chunk }
          if BytesCopied > 0 then { if we read anything... }
            FileWrite(Dest, CopyBuffer^, BytesCopied); { ...write chunk }
        until BytesCopied < ChunkSize; { until we run out of chunks }
      finally
        FileClose(Dest); { close the destination file }
      end;
    finally
      FileClose(Source); { close the source file }
    end;
  finally
    FreeMem(CopyBuffer, ChunkSize); { free the buffer }
  end;
end;


procedure TStockForm.FormCreate(Sender: TObject);
//var
//   I:Integer;
begin

   NewFileName := '';
   SiteStockPass:=TSiteStockPass.Create;

   if ComServer.StartMode = smStandalone then
      SiteStockPass.AutoSave:=False;

   SiteStockPass.StockFile := K_STOCK ;
   if GetGPCSRegString('','System Name','Tanzania Post') = 'Bermuda Post' then
      SiteStockPass.CurrentDirectory := 'C:\Bermuda\Binary\'
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post' then
      SiteStockPass.CurrentDirectory := 'C:\Tan\Binary\'
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Pakistan Post' then
      SiteStockPass.CurrentDirectory := 'C:\Pakistan\Binary\'
   else if GetGPCSRegString('','System Name','Tanzania Post') = 'Vietnam Post' then
      SiteStockPass.CurrentDirectory := 'C:\Vietnam\Binary\'
   else
      SiteStockPass.CurrentDirectory := ExtractFilePath(Application.ExeName) ;

end;

procedure TStockForm.FormDestroy(Sender: TObject);
begin
   SiteStockPass.Free;
end;

procedure TStockForm.ItemListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   Value:String;
   StockItem:TStockItem;
   FC:TColor;
begin
   with (Control as TListBox).Canvas do
   begin
      FC:=Font.Color;
      StockItem:=TStockItem((Control as TListBox).Items.Objects[Index]);
      if ((StockItem.AccountID = '') or (StockItem.Group = '')) then
      begin
         if (odSelected in State) then
            Font.Color:=clYellow
         else
            Font.Color:=clBlue;
      end;
      Value:=CurrToStrF(StockItem.Price,ffNumber,2);
      FillRect(Rect);
      TextOut(Rect.Right-(TextWidth(Value)+1),Rect.Top,Value);
      TextOut(Rect.Left+1,Rect.Top,ItemList.Items[Index]);
      Font.Color:=FC;
   end;
end;

procedure TStockForm.LoadButtonClick(Sender: TObject);
var
//   TSL:TPackStringList;
//   SL:TPackStringList;
//   LSL:TPackStringList;
   I : Integer;
begin
   NewFileName := NewFile ;
   CopyFile( SiteStockPass.CurrentDirectory+K_STOCK, SiteStockPass.CurrentDirectory+NewFileName );

   //SiteStockPass.TextSaveMode := LoadTextCheckBox.Checked ;
   SiteStockPass.LoadFromFile ;

   for I:=0 to SiteStockPass.StockItems.Count-1 do
   begin
      ItemList.Items.AddObject(SiteStockPass.StockItems[I].Description,SiteStockPass.StockItems[I]);
   end;

end;

procedure TStockForm.PassButtonClick(Sender: TObject);
begin

   try

//      SiteStockPass.TextSaveMode := SaveTextCheckBox.Checked ;
      SiteStockPass.StockFile     := K_STOCK  ;

      if GetGPCSRegString('','System Name','Tanzania Post') = 'Bermuda Post' then
         SiteStockPass.CurrentDirectory := 'C:\Bermuda\Binary\'
      else if GetGPCSRegString('','System Name','Tanzania Post') = 'Tanzania Post' then
         SiteStockPass.CurrentDirectory := 'C:\Tan\Binary\'
      else if GetGPCSRegString('','System Name','Tanzania Post') = 'Pakistan Post' then
         SiteStockPass.CurrentDirectory := 'C:\Pakistan\Binary\'
      else
        SiteStockPass.CurrentDirectory := (ExtractFilePath(Application.ExeName)) ;

      StockDataModule.EmptyDataBases ;
      SiteStockPass.SaveToStockFile ;
      SiteStockPass.SaveToStockItemFile ;
      SiteStockPass.SaveToStockUnitItemFile ;
   except
      if ( NewFileName <> '' ) and
         FileExists( SiteStockPass.CurrentDirectory+NewFileName ) then
         CopyFile( SiteStockPass.CurrentDirectory+NewFileName,
                   SiteStockPass.CurrentDirectory+K_STOCK );
   end ;


end;

function TStockForm.NewFile : String ;
var
   FileName : String ;
   NumberFile : integer ;
begin
   NumberFile := 0 ;
   FileName := 'OldStock' + LeftPad( IntToStr( NumberFile ), 6, '0' );

   while FileExists( SiteStockPass.CurrentDirectory + FileName ) do
   begin
      Inc( NumberFile ) ;
      FileName := 'OldStock' + LeftPad( IntToStr( NumberFile ), 6, '0' );
   end ;
   Result := FileName ;
end ;

end.
