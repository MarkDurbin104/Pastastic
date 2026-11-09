unit ShareDataU;

interface
uses
   Classes,Windows,SysUtils;
   
const
  ShareSize = $FFFFF;                     // 1 Megabyte
  MemoryFileName:String = 'C:\MemoryFile.Dat';   // Data file
  
type
  TItemHeader = packed record
     FNextItemOffset:Integer;
     FPrevItemOffset:Integer;
     NameLength    :Byte;
     ItemType      :Integer;
     ItemLength    :Integer;
  end;
  PItemHeader = ^TItemHeader;
  TItem = Class(TObject)
  private
     FBasePointer:PItemHeader;
  public
     Name:String;
     Data:Variant;
     constructor Create(BasePointer:Pointer;Item:PItemHeader);
     destructor Destroy; override;
     function AsString:String;
     function DataType:String;
     function Put(Item:PItemHeader):PItemHeader;
  end;
  TItemList = Class(TObject)
  private
     FBasePointer:PItemHeader;
  public
     Items:TStringList;
     constructor Create(Base:PItemHeader);
     destructor Destroy; override;
     procedure RemoveItem(Name:String;Base:PItemHeader);
  end;
  TSharedData = Class(TObject)
  private
     FIsValid:Boolean;
     FileCreated:Boolean;
     FBasePointer:PItemHeader;
     FileHandle:THandle;
     FileMappingHandle:THandle;
     function GetLastBlock:PItemHeader;
  public
     constructor Create(Name:String;DontCreate:Boolean);
     destructor  Destroy; override;
     procedure   SetVariable(Name:String;Value:Variant);
     procedure   RemoveVariable(Name:String);
     function    GetVariable(Name:String):Variant;
     function    List:TStringList;
     property    IsValid:Boolean read FIsValid write FIsValid;
     procedure   Clear;
  end;

var
   LocalSharedData:TSharedData;

function SetSharedVariable(ShareName, VarName : String; VarValue : Variant) : Boolean;

implementation

{TSharedData}

function SetSharedVariable(ShareName, VarName : String; VarValue : Variant) : Boolean;
begin
  If LocalSharedData = nil then LocalSharedData := TSharedData.Create(ShareName, False);
  If LocalSharedDAta <> nil then
    LocalSharedData.SetVariable(VarName, VarValue);
  Result := True;
end;

function NextItem(BasePointer, IH:PItemHeader):PItemHeader;
begin
   Result:=PItemHeader(Integer(BasePointer)+IH.FNextItemOffset);
end;
function PrevItem(BasePointer, IH:PItemHeader):PItemHeader;
begin
   Result:=PItemHeader(Integer(BasePointer)+IH.FPrevItemOffset);
end;
procedure SetNextItem(BasePointer, IH:PItemHeader;Offset:Integer);
begin
   IH.FNextItemOffset:=Offset-Integer(BasePointer);
end;
procedure SetPrevItem(BasePointer, IH:PItemHeader;Offset:Integer);
begin
   IH.FPrevItemOffset:=Offset-Integer(BasePointer);
end;
constructor TSharedData.Create(Name:String;DontCreate:Boolean);
begin
   FBasePointer     :=nil;
   FileHandle       :=0;
   FileCreated:=False;
   FIsValid:=False;
   FileMappingHandle:=OpenFileMapping(FILE_MAP_ALL_ACCESS,True,PChar(Name));
   
   if (FileMappingHandle = 0) and (DontCreate) then Exit;
   
   if (FileMappingHandle = 0) then
   begin
      FileHandle:=CreateFile(PChar(MemoryFileName),GENERIC_READ or GENERIC_WRITE,
                     FILE_SHARE_READ or FILE_SHARE_WRITE,nil,CREATE_ALWAYS,
                     FILE_ATTRIBUTE_NORMAL,0);
      FileMappingHandle:=CreateFileMapping(FileHandle,nil,PAGE_READWRITE,
                                           0,ShareSize,PChar(Name));
      FileCreated:=True;
   end;
   FIsValid:=True;
   FBasePointer:=MapViewOfFile(FileMappingHandle,FILE_MAP_ALL_ACCESS,0,0,0);
   if FileCreated then ZeroMemory(FBasePointer,ShareSize);
end;

destructor TSharedData.Destroy;
begin
   if FBasePointer      <> nil then UnmapViewOfFile(FBasePointer);
   if FileMappingHandle <> 0   then CloseHandle(FileMappingHandle);
   if FileHandle        <> 0   then CloseHandle(FileHandle);
   FBasePointer:=nil;
   FIsValid:=False;
   inherited Destroy;
end;      
function TSharedData.GetLastBlock:PItemHeader;
var
   CurrentBlock:PItemHeader;
begin
   CurrentBlock:=FBasePointer;
   while CurrentBlock.FNextItemOffset <> 0 do
   begin
      CurrentBlock:=NextItem(FBasePointer,CurrentBlock);
      if Integer(CurrentBlock) > Integer(FBasePointer)+ShareSize then
      begin
         Result:=nil;
         Exit;
      end;
   end;
   Result:=CurrentBlock;
end;
function TSharedData.List:TStringList;
var
   Items:TItemList;
   I:Integer;
   Item:TItem;
begin
   Result:=TStringList.Create;
   Items:=TItemList.Create(FBasePointer);
   for I:=0 to Items.Items.Count-1 do
   begin
      Item:=TItem(Items.Items.Objects[I]);
      Result.Add(Item.Name+'='+Item.AsString);
   end;
   Items.Free;
end;
procedure TSharedData.RemoveVariable(Name:String);
var
   Items:TItemList;
begin
   Items:=TItemList.Create(FBasePointer);
   if Items.Items.IndexOf(Name) <> -1 then
      Items.RemoveItem(Name,FBasePointer);
   Items.Free;
end;

procedure TSharedData.SetVariable(Name:String;Value:Variant);
var
   LastBlock:PItemHeader;
   NameBlock:PChar;
   DataBlock:Pointer;
   FSmallint  :Smallint  ;
   FInteger   :Integer   ;
   FSingle    :Single    ;
   FDouble    :Double    ;
   FCurrency  :Currency  ;
   FTDateTime :TDateTime ;
   FWordBool  :WordBool  ;
   FByte      :Byte      ;
   FWideString:WideString;
   FAnsiString:AnsiString;
   Items:TItemList;
begin
   Items:=TItemList.Create(FBasePointer);
   if Items.Items.IndexOf(Name) <> -1 then
      Items.RemoveItem(Name,FBasePointer);
   Items.Free;
   
   LastBlock:=GetLastBlock;
   if LastBlock = nil then Exit;
   LastBlock.NameLength:=Length(Name);
   LastBlock.ItemType:=VarType(Value);
   NameBlock:=PChar(Integer(LastBlock)+SizeOf(TItemHeader));
   MoveMemory(NameBlock,PChar(Name),LastBlock.NameLength);
   DataBlock:=Pointer(Integer(NameBlock)+LastBlock.NameLength);
   case VarType(Value) of
      varSmallint : begin FSmallint  :=Value; MoveMemory(DataBlock,@FSmallint  ,SizeOf(Smallint  ) ); LastBlock.ItemLength:=SizeOf(Smallint  ) end;
      varInteger  : begin FInteger   :=Value; MoveMemory(DataBlock,@FInteger   ,SizeOf(Integer   ) ); LastBlock.ItemLength:=SizeOf(Integer   ) end;
      varSingle   : begin FSingle    :=Value; MoveMemory(DataBlock,@FSingle    ,SizeOf(Single    ) ); LastBlock.ItemLength:=SizeOf(Single    ) end;
      varDouble   : begin FDouble    :=Value; MoveMemory(DataBlock,@FDouble    ,SizeOf(Double    ) ); LastBlock.ItemLength:=SizeOf(Double    ) end;
      varCurrency : begin FCurrency  :=Value; MoveMemory(DataBlock,@FCurrency  ,SizeOf(Currency  ) ); LastBlock.ItemLength:=SizeOf(Currency  ) end;
      varDate	   : begin FTDateTime :=Value; MoveMemory(DataBlock,@FTDateTime ,SizeOf(TDateTime ) ); LastBlock.ItemLength:=SizeOf(TDateTime ) end;
      varBoolean  : begin FWordBool  :=Value; MoveMemory(DataBlock,@FWordBool  ,SizeOf(WordBool  ) ); LastBlock.ItemLength:=SizeOf(WordBool  ) end;
      varByte     : begin FByte      :=Value; MoveMemory(DataBlock,@FByte      ,SizeOf(Byte      ) ); LastBlock.ItemLength:=SizeOf(Byte      ) end;
      varOleStr   : begin FWideString:=Value; MoveMemory(DataBlock,Pointer(FWideString),Length(FWideString)); LastBlock.ItemLength:=Length(FWideString) end;
      varString   : begin FAnsiString:=Value; MoveMemory(DataBlock,Pointer(FAnsiString),Length(FAnsiString)); LastBlock.ItemLength:=Length(FAnsiString) end;
      else Exit;
   end;
   SetNextItem(FBasePointer,LastBlock,Integer(DataBlock)+LastBlock.ItemLength);
   LastBlock:=NextItem(FBasePointer,LastBlock);
   LastBlock.FNextItemOffset:=0;
end;
function TSharedData.GetVariable(Name:String):Variant;
var
   Items:TItemList;
   Index:Integer;
begin
   try
      Items:=TItemList.Create(FBasePointer);
      Index:=Items.Items.IndexOf(Name);
      if Index <> -1 then
         Result:=TItem(Items.Items.Objects[Index]).Data
      else
         Result:=Unassigned;
      Items.Free;
   except
      Result:=Unassigned;
   end;
end;
procedure TSharedData.Clear;
begin
   PItemHeader(FBasePointer).FNextItemOffset:=0;
end;

{TItemList}

constructor TItemList.Create(Base:PItemHeader);
var
   Item:TItem;
begin
   FBasePointer:=Base;
   Items:=TStringList.Create;
   Items.Sorted:=True;
   try
      while Base.FNextItemOffset <> 0 do
      begin
         Item:=TItem.Create(FBasePointer, Base);
         Items.AddObject(Item.Name,Item);
         Base:=NextItem(FBasePointer,Base);
      end;
   except
   end;
end;
destructor TItemList.Destroy;
var
   I:Integer;
begin
   for I:=0 to Items.Count-1 do
      if Items.Objects[I] <> nil then TItem(Items.Objects[I]).Free;
   Items.Free;
   inherited Destroy;
end;
procedure TItemList.RemoveItem(Name:String;Base:PItemHeader);
var
   I:Integer;
begin
   I:=Items.IndexOf(Name);
   if I <> -1 then
   begin
      if Items.Objects[I] <> nil then 
      begin
         TItem(Items.Objects[I]).Free;
         Items.Objects[I]:=nil;
      end;
      Items.Delete(I);
   end;
   Base.FNextItemOffset:=0;
   for I:=0 to Items.Count-1 do
   begin
      if Items.Objects[I] <> nil then 
      begin
         Base:=TItem(Items.Objects[I]).Put(Base);
      end;
   end;
   Base.FNextItemOffset:=0;
end;     

{TItem}

constructor TItem.Create(BasePointer:Pointer; Item:PItemHeader);
var
   NameBlock:PChar;
   DataBlock:Pointer;
   FSmallint  :Smallint  ;
   FInteger   :Integer   ;
   FSingle    :Single    ;
   FDouble    :Double    ;
   FCurrency  :Currency  ;
   FTDateTime :TDateTime ;
   FWordBool  :WordBool  ;
   FByte      :Byte      ;
   FWideString:WideString;
   FAnsiString:AnsiString;
begin
   FBasePointer:=BasePointer;
   SetLength(Name,Item.NameLength);
   NameBlock:=PChar(Integer(Item)+SizeOf(TItemHeader));
   DataBlock:=Pointer(Integer(NameBlock)+Item.NameLength);
   MoveMemory(Pointer(Name),Pointer(NameBlock),Item.NameLength);
   case Item.ItemType of
      varSmallint : begin 
                       MoveMemory(@FSmallint ,DataBlock,SizeOf(Smallint  ));
                       Data:=FSmallint ;
                    end;
      varInteger  : begin  
                       MoveMemory(@FInteger  ,DataBlock,SizeOf(Integer   ));
                       Data:=FInteger  ;
                    end;
      varSingle   : begin  
                       MoveMemory(@FSingle   ,DataBlock,SizeOf(Single    ));
                       Data:=FSingle   ;
                    end;
      varDouble   : begin  
                       MoveMemory(@FDouble   ,DataBlock,SizeOf(Double    ));
                       Data:=FDouble   ;
                    end;
      varCurrency : begin  
                       MoveMemory(@FCurrency ,DataBlock,SizeOf(Currency  ));
                       Data:=FCurrency ;
                    end;
      varDate	   : begin  
                       MoveMemory(@FTDateTime,DataBlock,SizeOf(TDateTime ));
                       Data:=FTDateTime;
                    end;
      varBoolean  : begin  
                       MoveMemory(@FWordBool ,DataBlock,SizeOf(WordBool  ));
                       Data:=FWordBool ;
                    end;
      varByte     : begin  
                       MoveMemory(@FByte     ,DataBlock,SizeOf(Byte      ));
                       Data:=FByte     ;
                    end;
      varOleStr   : begin 
                       SetLength(FWideString,Item.ItemLength); 
                       MoveMemory(Pointer(FWideString),DataBlock,Item.ItemLength); 
                       Data:=FWideString;
                    end;
      varString   : begin 
                       SetLength(FAnsiString,Item.ItemLength); 
                       MoveMemory(Pointer(FAnsiString),DataBlock,Item.ItemLength); 
                       Data:=FAnsiString;
                    end;                 
      else begin
              Data:=''; 
           end;
   end;
end;
destructor TItem.Destroy;
begin
   inherited Destroy;
end;
function TItem.AsString:String;
begin
   case VarType(Data) of
      varSmallint : Result:=IntToStr(Data);
      varInteger  : Result:=IntToStr(Data);
      varSingle   : Result:=FloatToStr(Data);
      varDouble   : Result:=FloatToStr(Data);
      varCurrency : Result:=CurrToStr(Data);
      varDate	   : Result:=DateTimeToStr(Data);
      varBoolean  : if Data then Result:='True' else Result:='False';
      varByte     : Result:=IntToStr(Data);
      varOleStr   : Result:=Data;
      varString   : Result:=Data;
      else          Result:='';
   end;
end;
function TItem.DataType:String;
begin
   case VarType(Data) of
      varSmallint : Result:='Smallint  ';
      varInteger  : Result:='Integer   ';
      varSingle   : Result:='Single    ';
      varDouble   : Result:='Double    ';
      varCurrency : Result:='Currency  ';
      varDate	   : Result:='Date	   ';
      varBoolean  : Result:='Boolean   ';
      varByte     : Result:='Byte      ';
      varOleStr   : Result:='WideString';
      varString   : Result:='String    ';
      else          Result:='';
   end;
end;
function TItem.Put(Item:PItemHeader):PItemHeader;
var
   NameBlock:PChar;
   DataBlock:Pointer;
   FSmallint  :Smallint  ;
   FInteger   :Integer   ;
   FSingle    :Single    ;
   FDouble    :Double    ;
   FCurrency  :Currency  ;
   FTDateTime :TDateTime ;
   FWordBool  :WordBool  ;
   FByte      :Byte      ;
   FWideString:WideString;
   FAnsiString:AnsiString;
begin 
   Result:=Item;
   Item.NameLength:=Length(Name);
   Item.ItemType:=VarType(Data);
   NameBlock:=PChar(Integer(Item)+SizeOf(TItemHeader));
   MoveMemory(NameBlock,PChar(Name),Item.NameLength);
   DataBlock:=Pointer(Integer(NameBlock)+Item.NameLength);
   case Item.ItemType of
      varSmallint : begin FSmallint  :=Data; MoveMemory(DataBlock,@FSmallint  ,SizeOf(Smallint  ) ); Item.ItemLength:=SizeOf(Smallint  ) end;
      varInteger  : begin FInteger   :=Data; MoveMemory(DataBlock,@FInteger   ,SizeOf(Integer   ) ); Item.ItemLength:=SizeOf(Integer   ) end;
      varSingle   : begin FSingle    :=Data; MoveMemory(DataBlock,@FSingle    ,SizeOf(Single    ) ); Item.ItemLength:=SizeOf(Single    ) end;
      varDouble   : begin FDouble    :=Data; MoveMemory(DataBlock,@FDouble    ,SizeOf(Double    ) ); Item.ItemLength:=SizeOf(Double    ) end;
      varCurrency : begin FCurrency  :=Data; MoveMemory(DataBlock,@FCurrency  ,SizeOf(Currency  ) ); Item.ItemLength:=SizeOf(Currency  ) end;
      varDate	   : begin FTDateTime :=Data; MoveMemory(DataBlock,@FTDateTime ,SizeOf(TDateTime ) ); Item.ItemLength:=SizeOf(TDateTime ) end;
      varBoolean  : begin FWordBool  :=Data; MoveMemory(DataBlock,@FWordBool  ,SizeOf(WordBool  ) ); Item.ItemLength:=SizeOf(WordBool  ) end;
      varByte     : begin FByte      :=Data; MoveMemory(DataBlock,@FByte      ,SizeOf(Byte      ) ); Item.ItemLength:=SizeOf(Byte      ) end;
      varOleStr   : begin FWideString:=Data; MoveMemory(DataBlock,Pointer(FWideString),Length(FWideString)); Item.ItemLength:=Length(FWideString) end;
      varString   : begin FAnsiString:=Data; MoveMemory(DataBlock,Pointer(FAnsiString),Length(FAnsiString)); Item.ItemLength:=Length(FAnsiString) end;
      else Exit;
   end;
   SetNextItem(FBasePointer, Item,Integer(DataBlock)+Item.ItemLength);
   Result:=NextItem(FBasePointer, Item);
end;

end.
