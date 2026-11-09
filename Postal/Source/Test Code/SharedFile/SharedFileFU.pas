unit SharedFileFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  PItemHeader = ^TItemHeader;
  TItemHeader = record 
     NextItem:PItemHeader; 
  end;
  String80 = String[80];
  PStockItemStruct = ^TStockItemStruct;
  TStockItemStruct = packed record
     Description:String80;
     Price      :Currency;
     PLU        :Integer ;
     ProgID     :String80;
     AccountID  :String80;
     Group      :String80;
     Identifier :Integer ;
     Agency     :String80;
     ReportLine :String80;
  end;
  PStockUnitStruct = ^TStockUnitStruct;
  TStockUnitStruct = packed record
     Owner     :String80;
     TransferTo:String80;
     ItemCount :Integer ;
  end;
  PStockUnitItemStruct = ^TStockUnitItemStruct;
  TStockUnitItemStruct = packed record
     Quantity  :Integer;
     TempAdjust:Integer;
     MinLevel  :Integer;
     MaxLevel  :Integer;
     NomLevel  :Integer;
     ItemIndex :Integer;
  end;
  PStockUnitTypeStruct = ^TStockUnitTypeStruct;
  TStockUnitTypeStruct = packed record
     Name:String80;                            
  end;
  TSharedFile = class(TObject)
  private
    FBasePointer     :PItemHeader;
    FileMappingHandle:THandle;
    FileHandle       :THandle;
    FileCreated      :Boolean;
    procedure ReadOldStockUnitTypeIntoShare(Stream:TStream;StockUnitTypeStruct:PStockUnitTypeStruct);
    procedure ReadOldStockItemIntoShare(Stream:TStream;StockItemStruct:PStockItemStruct);
    procedure ReadOldStockUnitItemIntoShare(Stream:TStream;StockUnitItemStruct:PStockUnitItemStruct);
    procedure ReadOldStockUnitIntoShare(Stream:TStream;StockUnitStruct:PStockUnitStruct);
  public
    constructor Create(FileName,Name:String;MaxFileSize:Integer;ClearFile,DontCreate:Boolean);
    destructor Destroy; override;
    property BasePointer:PItemHeader read FBasePointer;
    procedure PopulateFromOldStockDat(FileName:String);
  end;
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  public
    SharedFile:TSharedFile;
  end;
  
var
  Form1: TForm1;
  FLastBlock:PItemHeader;


implementation

{$R *.DFM}

function IntFromStream(Stream:TStream):Integer ;
begin
   Stream.ReadBuffer(Result,SizeOf(Result));
end;
function CurFromStream(Stream:TStream):Currency;
begin
   Result:=IntFromStream(Stream) / 1000;
end;
function StrFromStream(Stream:TStream):String;
var
   Len:Integer;
begin
   Len:=IntFromStream(Stream);
   SetLength(Result,Len);
   Stream.ReadBuffer(Pointer(@Result[1])^,Len);
end;
{TSharedFile}
constructor TSharedFile.Create(FileName,Name:String;MaxFileSize:Integer;ClearFile,DontCreate:Boolean);
begin
   FBasePointer     :=nil;
   FileHandle       :=0;
   FileCreated:=False;
   FileMappingHandle:=OpenFileMapping(FILE_MAP_ALL_ACCESS,True,PChar(Name));
   
   if (FileMappingHandle = 0) and (DontCreate) then Abort;
   
   if (FileMappingHandle = 0) then
   begin
      if not FileExists(FileName) then ClearFile:=True;
      FileHandle:=CreateFile(PChar(FileName),GENERIC_READ or GENERIC_WRITE,
                     FILE_SHARE_READ or FILE_SHARE_WRITE,nil,OPEN_ALWAYS,
                     FILE_ATTRIBUTE_NORMAL,0);
      FileMappingHandle:=CreateFileMapping(FileHandle,nil,PAGE_READWRITE,
                                           0,MaxFileSize,PChar(Name));
      FileCreated:=True;
   end;
   FBasePointer:=MapViewOfFile(FileMappingHandle,FILE_MAP_ALL_ACCESS,0,0,0);
   if FileCreated and ClearFile then ZeroMemory(FBasePointer,MaxFileSize);
   FLastBlock:=FBasePointer;
   while FLastBlock.NextItem <> nil do
      FLastBlock:=FLastBlock.NextItem;
end;

destructor TSharedFile.Destroy;
begin
   if FBasePointer      <> nil then begin UnmapViewOfFile(FBasePointer);   FBasePointer     :=nil; end;
   if FileMappingHandle <> 0   then begin CloseHandle(FileMappingHandle);  FileMappingHandle:=0  ; end;
   if FileHandle        <> 0   then begin CloseHandle(FileHandle);         FileHandle       :=0  ; end;
   FBasePointer:=nil;
   inherited Destroy;
end;      

function NewGetMem(Size:Integer):Pointer;
var
   BlockItem:PItemHeader;
begin         
   BlockItem:=FLastBlock;
   Inc(BlockItem,((Size div Sizeof(FLastBlock))+1));
   FLastBlock.NextItem:=BlockItem;
   BlockItem:=FLastBlock;
   FLastBlock:=FLastBlock.NextItem;
   Inc(BlockItem);
   Result:=BlockItem;
end;
function NewFreeMem(P:Pointer):Integer;
begin
   Result:=0;
end;
function NewReallocMem(P:Pointer;Size:Integer):Pointer;
var
   BlockItem,NextItem:PItemHeader;
begin    
   BlockItem:=PItemHeader(P);
   Dec(BlockItem);
   NextItem:=BlockItem.NextItem;
   Inc(BlockItem);
   Result:=NewGetMem(Size);         
   CopyMemory(Result,BlockItem,Integer(NextItem)-Integer(BlockItem));
end;
procedure TSharedFile.ReadOldStockUnitTypeIntoShare(Stream:TStream;StockUnitTypeStruct:PStockUnitTypeStruct);
var
  I:Integer;
begin
   StockUnitTypeStruct^.Name:=StrFromStream(Stream);
   for I:=0 to StockUnitStruct^.ItemCount-1 do
   begin
      ReadOldStockUnitItemIntoShare(Stream,PStockUnitItemStruct(FLastBlock));
      Inc(PStockUnitItemStruct(FLastBlock));
   end;
end;
procedure TSharedFile.ReadOldStockUnitItemIntoShare(Stream:TStream;StockUnitItemStruct:PStockUnitItemStruct);
begin
   StockUnitItemStruct^.Quantity  :=IntFromStream(Stream);
   StockUnitItemStruct^.TempAdjust:=IntFromStream(Stream);
   StockUnitItemStruct^.MinLevel  :=IntFromStream(Stream);
   StockUnitItemStruct^.MaxLevel  :=IntFromStream(Stream);
   StockUnitItemStruct^.NomLevel  :=IntFromStream(Stream);
   StockUnitItemStruct^.ItemIndex :=IntFromStream(Stream);
end;
procedure TSharedFile.ReadOldStockUnitIntoShare(Stream:TStream;StockUnitStruct:PStockUnitStruct);
var
  I:Integer;
begin
   StockUnitStruct^.Owner     :=StrFromStream(Stream);
   StockUnitStruct^.TransferTo:=StrFromStream(Stream);
   StockUnitStruct^.ItemCount :=IntFromStream(Stream);
   for I:=0 to StockUnitStruct^.ItemCount-1 do
   begin
      ReadOldStockUnitItemIntoShare(Stream,PStockUnitItemStruct(FLastBlock));
      Inc(PStockUnitItemStruct(FLastBlock));
   end;
end;
procedure TSharedFile.ReadOldStockItemIntoShare(Stream:TStream;StockItemStruct:PStockItemStruct);
begin
   StockItemStruct^.Description:=StrFromStream(Stream);
   StockItemStruct^.Price      :=CurFromStream(Stream);
   StockItemStruct^.Identifier :=IntFromStream(Stream);
   StockItemStruct^.AccountID  :=StrFromStream(Stream);
   StockItemStruct^.Group      :=StrFromStream(Stream);
   StockItemStruct^.PLU        :=IntFromStream(Stream);
   StockItemStruct^.ProgID     :=StrFromStream(Stream);
   StockItemStruct^.Agency     :=StrFromStream(Stream);
   StockItemStruct^.ReportLine :=StrFromStream(Stream);
end;
procedure TSharedFile.PopulateFromOldStockDat(FileName:String);
var
   FileStream:TFileStream;
   I,ItemCount:Integer;
begin    
   if FileExists(FileName) then
   begin
      FileStream:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
      // Stock Items
      FileStream.ReadBuffer(ItemCount,SizeOf(ItemCount));
      PInteger(FLastBlock)^:=ItemCount;
      Inc(PInteger(FLastBlock));
      for I:=0 to ItemCount-1 do
      begin
         ReadOldStockItemIntoShare(FileStream,PStockItemStruct(FLastBlock));
         Inc(PStockItemStruct(FLastBlock));
      end;
      // Stock Units
      FileStream.ReadBuffer(ItemCount,SizeOf(ItemCount));
      PInteger(FLastBlock)^:=ItemCount;
      Inc(PInteger(FLastBlock));
      for I:=0 to ItemCount-1 do
      begin
         ReadOldStockUnitIntoShare(FileStream,PStockUnitStruct(FLastBlock));
         Inc(PStockUnitStruct(FLastBlock));
      end;
      // Stock Unit Types
      FileStream.ReadBuffer(ItemCount,SizeOf(ItemCount));
      PInteger(FLastBlock)^:=ItemCount;
      Inc(PInteger(FLastBlock));
      for I:=0 to ItemCount-1 do
      begin
         ReadOldStockUnitTypeIntoShare(FileStream,PStockUnitTypeStruct(FLastBlock));
         Inc(PStockUnitTypeStruct(FLastBlock));
      end;
      
      FileStream.Free;
   end;
end;
procedure TForm1.Button1Click(Sender: TObject);
var
   SharedFile:TSharedFile;
begin
   SharedFile:=TSharedFile.Create('C:\Test.dat','SharedFile',$FFFFF,False,False);
   SharedFile.PopulateFromOldStockDat('C:\Botswana\Binary\Stock.dat');
   SharedFile.Free;                             
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   with TSharedFile.Create('C:\Test.dat','SharedFile',$FFFFF,True,False) do
      Free;
   Memo1.Clear;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   SharedFile:TSharedFile;
begin
   SharedFile:=TSharedFile.Create('C:\Test.dat','SharedFile',$FFFFF,False,False);
   SharedFile.Free;
end;

end.
