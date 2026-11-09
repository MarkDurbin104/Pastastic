//==============================================================================
//  Type          | Unit
//  Name          | TxDataU
//  Description   | Definition of base classes that use inherent ReadComponent
//                | and WriteComponent methods of TComponent to read and
//                | write all of the published properties of a class and
//                | place them in a Variant array for passing over an Ole
//                | interface
//------------------------------------------------------------------------------
// Date     | Who | Comments
//------------------------------------------------------------------------------
// 26/01/01 | MJD | Initial Release
//==============================================================================

unit TxDataU;

interface

uses
   Classes,Compress;

type
  // class to be passed over OLE interface using variant array
  // of all it's published properties using the Details property
  TTxData = class(TComponent)
  protected
    function GetDetails:Variant; virtual;
    procedure SetDetails(Value:Variant); virtual;
    function GetString:String; virtual;
    procedure SetString(Value:String); virtual;
  public
     property Details:Variant read GetDetails write SetDetails;
     property AsString:String read GetString write SetString;
  end;

  // list class to be passed over OLE interface using variant array
  // of all it's published properties and those in its list
  // using the Details property
  TTxListData = class(TComponent)
  private
     FList:TList;
     FListCount:Integer;
  protected
     function GetDetails:Variant; virtual;
     procedure SetDetails(Value:Variant); virtual;
     function GetListCount:Integer;
     procedure SetListCount(Value:Integer);
     function GetItem(Index:Integer):TTxData;
     procedure SetItem(Index:Integer;Value:TTxData);
     function GetString:String; virtual;
     procedure SetString(Value:String); virtual;
  public
     constructor Create(AOwner:TComponent); override;
     destructor Destroy; override;
     function  Add(TxData:TTxData):Integer;
     function  Count:Integer;
     procedure Delete(Index:Integer);
     property  Item[Index:Integer]:TTxData read GetItem write SetItem; default;
     property  Details:Variant read GetDetails write SetDetails;
     property AsString:String read GetString write SetString;
  published
     property ListCount:Integer read GetListCount write SetListCount;
  end;

  // class to be passed over OLE interface using variant array
  // of all it's published properties using the Details property
  // all data is compressed before passing
  TCompTxData = class(TTxData)
  protected
    function GetDetails:Variant; override;
    procedure SetDetails(Value:Variant); override;
  end;


implementation

{TTxData}
//==============================================================================
//  Function    : ArrayFromStream
//  Description : Create a Variant array of type vtByte from the contents of a stream
//  Parameters  : The stream to convert
//  Result      : The Array
//==============================================================================
function ArrayFromStream(Stream:TStream):Variant;
var
   Data:PChar;
begin
   Result:=VarArrayCreate([0,Stream.Size-1],varByte);
   try
      Data:=VarArrayLock(Result);
      Stream.Position:=0;
      Stream.ReadBuffer(Data^,Stream.Size);
   finally
      VarArrayUnlock(Result);
   end;
end;
//==============================================================================
//  Function    : StreamFromArray
//  Description : Create a stream from the contents of a Variant array of type vtByte
//  Parameters  : The Array to convert
//  Result      : The stream - repositioned at 0
//==============================================================================
function StreamFromArray(Value:Variant):TMemoryStream;
var
   Data:PChar;
begin
   Result:=TMemoryStream.Create;
   try
      Data:=VarArrayLock(Value);
      Result.WriteBuffer(Data^,VarArrayHighBound(Value,1)+1);
      Result.Position:=0;
   finally
      VarArrayUnlock(Value);
   end;
end;
//==============================================================================
//  Method      : GetDetails
//  Description : Get a Variant array of all the published properties of this class
//  Parameters  : None
//  Result      : The Array
//==============================================================================
function TTxData.GetDetails:Variant;
var
   MS:TMemoryStream;
begin
   MS:=TMemoryStream.Create;
   MS.WriteComponent(Self); // write published properties
   Result:=ArrayFromStream(MS);
   MS.Free;
end;
//==============================================================================
//  Method      : SetDetails
//  Description : Set all the published properties of this class from a Variant array
//  Parameters  : Value - The Array
//  Result      : None
//==============================================================================
procedure TTxData.SetDetails(Value:Variant);
var
   MS:TMemoryStream;
begin
   MS:=StreamFromArray(Value);
   MS.ReadComponent(Self); // set properties
   MS.Free;
end;
//==============================================================================
//  Method      : GetString
//  Description : Get a String of all the published properties of this class
//  Parameters  : None
//  Result      : The String
//==============================================================================
function TTxData.GetString:String;
var
   MS:TMemoryStream;
   OS:TStringStream;
begin
   MS:=TMemoryStream.Create;
   OS:=TStringStream.Create('');
   MS.WriteComponent(Self); // write published properties
   MS.Position:=0;
   ObjectBinaryToText(MS,OS);
   Result:=OS.DataString;
   OS.Free;
   MS.Free;
end;
//==============================================================================
//  Method      : SetString
//  Description : Set all the published properties of this class from a String
//  Parameters  : Value - The String
//  Result      : None
//==============================================================================
procedure TTxData.SetString(Value:String);
var
   MS:TMemoryStream;
   OS:TStringStream;
begin
   MS:=TMemoryStream.Create;
   OS:=TStringStream.Create(Value);
   OS.Position:=0;
   ObjectTextToBinary(OS,MS);
   MS.Position:=0;
   MS.ReadComponent(Self); // set properties
   OS.Free;
   MS.Free;
end;
{TTxListData}
//==============================================================================
//  Method      : Create
//  Description : Create a TTxListData object
//  Parameters  : AOwner - the owning component
//  Result      : None
//==============================================================================
constructor TTxListData.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   FList:=TList.Create;
   FListCount:=0;
end;
//==============================================================================
//  Method      : Destroy
//  Description : Destroy a TTxListData object
//  Parameters  : None
//  Result      : None
//==============================================================================
destructor TTxListData.Destroy;
begin
   while FList.Count > 0 do Delete(0); // release items
   FList.Free;
   inherited Destroy;
end;
//==============================================================================
//  Method      : GetString
//  Description : Get a String of all the published properties of this class
//  Parameters  : None
//  Result      : The String
//==============================================================================
function TTxListData.GetString:String;
var
   I:Integer;
   DataFormatVersion:Integer;
   MS:TStringStream;
begin
   MS:=TStringStream.Create('');
   DataFormatVersion:=1; // save a format version number in the data
   MS.Write(DataFormatVersion,SizeOf(DataFormatVersion));
   MS.WriteComponent(Self); // write properties
   for I:=0 to FList.Count-1 do
      MS.WriteComponent(FList[I]); // write each classes properties
   Result:=MS.DataString;
   MS.Free;
end;
//==============================================================================
//  Method      : SetString
//  Description : Set all the published properties of this class from a String
//  Parameters  : Value - The String
//  Result      : None
//==============================================================================
procedure TTxListData.SetString(Value:String);
var
   MS:TStringStream;
   I:Integer;
   DataFormatVersion:Integer;
begin
   MS:=TStringStream.Create(Value);
   MS.Read(DataFormatVersion,SizeOf(DataFormatVersion));
   case DataFormatVersion of  // check the format version number in the data
      1 : begin
             MS.ReadComponent(Self); // read properties
             // NOTE FListCount is set by ReadComponent reading ListCount will reset it to FList.Count
             for I:=0 to FListCount-1 do
                Add(TTxData(MS.ReadComponent(nil))); // read and create sub class properties
          end;
   end;
   MS.Free;
end;
//==============================================================================
//  Method      : GetDetails
//  Description : Get a Variant array of all the published properties of this class
//              : and each of the classes in it's list
//  Parameters  : None
//  Result      : The Array
//==============================================================================
function TTxListData.GetDetails:Variant;
var
   MS:TMemoryStream;
   I:Integer;
   DataFormatVersion:Integer;
begin
   RegisterClasses([TTxData,TTxListData,TCompTxData]);
   MS:=TMemoryStream.Create;
   DataFormatVersion:=1; // save a format version number in the data
   MS.Write(DataFormatVersion,SizeOf(DataFormatVersion));
   MS.WriteComponent(Self); // write properties
   for I:=0 to FList.Count-1 do
      MS.WriteComponent(FList[I]); // write each classes properties
   Result:=ArrayFromStream(MS);
   MS.Free;
   UnRegisterClasses([TTxData,TTxListData,TCompTxData]);
end;                        
//==============================================================================
//  Method      : SetDetails
//  Description : Set all the published properties of this class from a Variant array
//              : and add each of the classes to it's list
//  Parameters  : Value - The Array
//  Result      : None
//==============================================================================
procedure TTxListData.SetDetails(Value:Variant);
var
   MS:TMemoryStream;
   I:Integer;
   DataFormatVersion:Integer;
begin
   RegisterClasses([TTxData,TTxListData,TCompTxData]);
   MS:=StreamFromArray(Value);
   MS.Read(DataFormatVersion,SizeOf(DataFormatVersion));
   case DataFormatVersion of  // check the format version number in the data
      1 : begin
             MS.ReadComponent(Self); // read properties
             // NOTE FListCount is set by ReadComponent reading ListCount will reset it to FList.Count
             for I:=0 to FListCount-1 do
                Add(TTxData(MS.ReadComponent(nil))); // read and create sub class properties
          end;
   end;
   MS.Free;
   UnRegisterClasses([TTxData,TTxListData,TCompTxData]);
end;
//==============================================================================
//  Method      : Count
//  Description : Number of items in list
//  Parameters  : None
//  Result      : Number of items in list
//==============================================================================
function TTxListData.Count:Integer;
begin
   FListCount:=FList.Count;
   Result:=FListCount;
end;
//==============================================================================
//  Method      : GetListCount
//  Description : Number of items in list
//  Parameters  : None
//  Result      : Number of items in list
//==============================================================================
function TTxListData.GetListCount:Integer;
begin
   FListCount:=FList.Count;
   Result:=FListCount;
end;
//==============================================================================
//  Method      : SetListCount
//  Description : Number of items that should be in the list
//  Parameters  : Number of items that should be in the list
//  Result      : None
//==============================================================================
procedure TTxListData.SetListCount(Value:Integer);
begin
   FListCount:=Value;
end;
//==============================================================================
//  Method      : GetItem
//  Description : Get one of the sub items
//  Parameters  : index in the list
//  Result      : Item or nil of Index out of bounds
//==============================================================================
function TTxListData.GetItem(Index:Integer):TTxData;
begin
   if (Index >=0) and (Index < FList.Count) then
      Result:=TTxData(FList[Index])
   else
      Result:=nil;
end;
//==============================================================================
//  Method      : SetItem
//  Description : Set one of the sub items
//  Parameters  : Index - index in the list
//              : Value - the item to place in list
//  Result      : None
//==============================================================================
procedure TTxListData.SetItem(Index:Integer;Value:TTxData);
begin
   // check for Index out of bounds
   if (Index >=0) and (Index < FList.Count) then
   begin
      if FList[Index] <> nil then Item[Index].Free; // free current item
      FList[Index]:=Value; // add new item
   end;
end;
//==============================================================================
//  Method      : Add
//  Description : Add Item to List
//  Parameters  : TxData - the item to place in list
//  Result      : Index of added item or -1 on error
//==============================================================================
function TTxListData.Add(TxData:TTxData):Integer;
begin
   Result:=FList.Add(TxData);
end;
//==============================================================================
//  Method      : Delete
//  Description : Delete item from list
//  Parameters  : Index of item
//  Result      : None
//==============================================================================
procedure TTxListData.Delete(Index:Integer);
begin
   // check for Index out of bounds
   if (Index >=0) and (Index < FList.Count) then
   begin
      if FList[Index] <> nil then Item[Index].Free; // free the item
      FList.Delete(Index); // remove from list
   end;
end;
{TCompTxData}
//==============================================================================
//  Method      : GetDetails
//  Description : Get a Variant array of all the published properties of this class
//  Parameters  : None
//  Result      : The Array
//==============================================================================
function TCompTxData.GetDetails:Variant;
var
   Compress:TCompressor;
   IMS:TMemoryStream;
   OMS:TMemoryStream;
begin
   Compress:=TCompressor.Create;
   IMS:=TMemoryStream.Create;
   OMS:=TMemoryStream.Create;

   IMS.WriteComponent(Self);

   Compress.CompressStream(IMS,OMS);
   Result:=Compress.CreateArrayFromStream(OMS);

   IMS.Free;
   OMS.Free;
   Compress.Free;
end;
//==============================================================================
//  Method      : SetDetails
//  Description : Set all the published properties of this class from a Variant array
//  Parameters  : Value - The Array
//  Result      : None
//==============================================================================
procedure TCompTxData.SetDetails(Value:Variant);
var
   IMS:TMemoryStream;
   OMS:TMemoryStream;
   Compress:TCompressor;
begin
   IMS:=TMemoryStream.Create;
   OMS:=TMemoryStream.Create;
   Compress:=TCompressor.Create;

   IMS.Size:=VarArrayHighBound(Value,1);
   Compress.CopyFromArrayToStream(Value,IMS);
   Compress.DecompressStream(IMS,OMS);
   OMS.Position:=0;
   OMS.ReadComponent(Self);
   IMS.Free;
   OMS.Free;
   Compress.Free;
end;

// Register classes for streaming into/out of the Details property
//initialization
//   try
//      RegisterClass(TTxData);
//   except
//   end;
//   try
//      RegisterClass(TTxData);
//      RegisterClass(TTxListData);
//      RegisterClass(TCompTxData);
//   except                    
//   end;
//   try
//      RegisterClass(TCompTxData);
//   except
//   end;
end.
