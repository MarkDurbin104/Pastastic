{  Module          Compress Bitmaps
   Unit            Compress
   Copyright(c)    Postal Solutions Limited 1998..1998
   Author          DDB
   Description     Compress and Decompress From/To BitMap, From/To Variant array
                              Original Release
}
unit Compress;

interface

uses Windows,SysUtils,Graphics, classes, ZLibEx,GPCSGUID  ;
type
   TCompressor =class(TObject)
   public
      class function  CreateArrayFromBitmap( BitMap : TBitmap ) : Variant ;
      class function  CreateBitmapFromArray( V : Variant ) : TBitmap ;

      class function  CreateArrayFromString( Str : String ) : variant ;
      class function  CreateArrayFromStream( Stream : TStream ) : variant ;

      class procedure CopyFromArrayToStream( V : Variant; Stream : TStream )  ;
      class function  CreateStringFromArray( V : Variant ) : String ;

      class function  CreateStringFromBitmap( BitMap : TBitmap ) : String ;
      class function  CreateBitmapFromString( Str : String  ) : TBitmap ;

      class procedure CopyFromBitmapToStream( BitMap : TBitmap; Stream : TStream )  ;

      class procedure CompressStream( StreamIn, StreamOut : TStream ) ;
      class procedure DecompressStream( StreamIn, StreamOut : TStream ) ;

      class procedure CompressFile( FileInPath, FileOutPath : String ) ;
      class procedure DeCompressFile( FileInPath, FileOutPath : String ) ;

      class function  CompressString(Value:String):String;
      class function  DeCompressString(Value:String):String;
   end;
   
const
//  BufferSize = 4096;
  BufferSize = 65536;

implementation
{===============================================================================

<Sysnopsis>       Create a variant array from a stream.

<Description>     Create a variant array from a stream.

<Stream>          Stream to convert into a variant array.

<Result>          a variant array.

________________________________________________________________________________}
class function  TCompressor.CreateArrayFromStream( Stream : TStream ) : variant ;
var
   Data : PChar ;      // Pointer to data in variant array
begin
   result := VarArrayCreate([0, Stream.Size-1], varByte ) ;
   try
      Data := VarArrayLock( result );
      Stream.Position := 0 ;
      Stream.ReadBuffer( Data^, Stream.Size ) ;
   finally
      VarArrayUnlock( Result );
   end ;

end ;
{===============================================================================

<Sysnopsis>       Compress a stream.

<Description>     Get a normal stream and will create a stream compressed.

<Post state>       StreamOut will receive a compressed stream.

<StreamIn>        a Strean to compress.

<StreamOut>       will receive a compressed stream.

________________________________________________________________________________}
class procedure TCompressor.CompressStream( StreamIn, StreamOut : TStream ) ;
var
//   ZCompression : TCompressionStream ;
   ZCompression:TZCompressionStream ;
   StreamToCompress:TMemoryStream;
   CompressedStream:TMemoryStream;
   TestDeCompressStream:TMemoryStream;
   DeCompressOK,CompressOK:Boolean;
begin
   if GetGPCSRegString('','Compress','Y') <> 'Y' then
   begin
      StreamOut.Position:=0;
      StreamOut.CopyFrom(StreamIn,0);
      StreamOut.Position:=0;
      Exit;
   end;
//   ZCompression:=TCompressionStream.Create( clMax,StreamOut);

   StreamToCompress:=TMemoryStream.Create;
   CompressedStream:=TMemoryStream.Create;
   StreamToCompress.CopyFrom(StreamIn,StreamIn.Size-StreamIn.Position);
   StreamToCompress.Position:=0;
   CompressOK:=True;
   try
      ZCompression:=TZCompressionStream.Create(CompressedStream,zcDefault);
      ZCompression.CopyFrom(StreamToCompress,StreamToCompress.Size);
      ZCompression.Free;
   except
      CompressOK:=False;
   end;
   DeCompressOK:=False;
   if CompressOK then
   begin
      TestDeCompressStream:=TMemoryStream.Create;
      DeCompressOK:=True;
      CompressedStream.Position:=0;
      try
         TCompressor.DeCompressStream(CompressedStream,TestDeCompressStream);
      except
         DeCompressOK:=False;
      end;
      TestDeCompressStream.Free;
   end;
   if DeCompressOK and (StreamToCompress.Size > CompressedStream.Size) then
   begin
      CompressedStream.Position:=0;
      StreamOut.CopyFrom(CompressedStream,CompressedStream.Size);
   end
   else
   begin
      StreamToCompress.Position:=0;
      StreamOut.CopyFrom(StreamToCompress,StreamToCompress.Size);
   end;
end ;
{===============================================================================

<Sysnopsis>       Decompress a stream.

<Description>     Get a normal stream from a compressed stream usin ZLib
                  decompress algoriths.

<Post state>      StreamOut will receive a decompress stream.

<StreamIn>        a stream to compress.

<StreamOut>       will receive a uncompressed stream.

________________________________________________________________________________}
class procedure TCompressor.DecompressStream( StreamIn, StreamOut : TStream ) ;
var
   Count : integer ;
   Buffer: array[0..BufferSize-1] of Byte;
//   ZDeCompression : TDecompressionStream ;
   ZDeCompression : TZDecompressionStream ;
begin
   if GetGPCSRegString('','Compress','Y') <> 'Y' then
   begin
      StreamOut.Position:=0;
      StreamOut.CopyFrom(StreamIn,0);
      StreamOut.Position:=0;
      Exit;
   end;
   ZDecompression := TZDecompressionStream.Create( StreamIn );
   try
      while True do
      begin
         // read from the compression stream
         Count := ZDecompression.Read(Buffer, BufferSize);
         if Count <> 0 then
            // write the information in a normal stream ------------------------
            StreamOut.WriteBuffer(Buffer, Count)
         else
            Break;
      end;
   finally
      ZDecompression.Free ;
   end ;

end ;
{===============================================================================

<Sysnopsis>       Create a variant array compressed from a bitmap.

<Description>     Using ZLib decompress algoriths will process the bitmap
                  information using TStream.

<BitMap>          a bitmap to compress inside a variant array.

<Result>          a variant array.

________________________________________________________________________________}
class function TCompressor.CreateArrayFromBitmap( BitMap : TBitmap ) : Variant ;
var
   MemoryStreamIn, MemoryStreamOut : TMemoryStream ;
begin

   MemoryStreamIn  := TMemoryStream.Create ;
   MemoryStreamOut  := TMemoryStream.Create ;

   try

      // Pass the bitmap in a stream -------------------------------------------
      BitMap.SaveToStream( MemoryStreamIn ) ;

     // Compress MemoryStreamIn into MemoryStreamOut --------------------------
      CompressStream( MemoryStreamIn, MemoryStreamOut );

      // Create a variant array from a string ----------------------------------
      result := CreateArrayFromStream( MemoryStreamOut );

   finally

      MemoryStreamIn.Free ;
      MemoryStreamOut.Free ;

   end ;


end ;
{===============================================================================

<Sysnopsis>       Create a bitmap from a variant compress array.

<Description>    Using CopyFromArrayToStream and DecompressStream functions
                 will process the data and the result bitmap will load the
                 processed data.

<Result>          a bitmap.

________________________________________________________________________________}
class function TCompressor.CreateBitmapFromArray( V : Variant ) : TBitmap ;
var
   MemoryStreamIn, MemoryStreamOut : TMemoryStream ; // TStream to work with
begin

   result := TBitmap.create ;
   MemoryStreamIn := TMemoryStream.Create ;
   MemoryStreamOut := TMemoryStream.Create ;
   try

      // Get information from the variant array --------------------------------
      CopyFromArrayToStream( V, MemoryStreamIn ) ;

      // Decompress MemoryStreamIn into MemoryStreamOut ------------------------
      DecompressStream( MemoryStreamIn, MemoryStreamOut ) ;

      // Load the information into the Bitmap ----------------------------------
      MemoryStreamOut.Position := 0 ;
      result.LoadFromStream( MemoryStreamOut );
   finally

      MemoryStreamOut.Free; // Added By MJD
      MemoryStreamIn.Free ;

   end;

end ;
{===============================================================================

<Sysnopsis>       Create a variant array from a string.

<Description>     Create a variant array from a string using a temporal
                  TStringStream variable and the funciton CreateArrayFromStream.

<Result>          Variant array.

________________________________________________________________________________}
class function TCompressor.CreateArrayFromString( Str : String ) : variant ;
var
   SStream : TStringStream ;
begin

   SSTream := TStringStream.Create( Str ) ;
   try
      result := CreateArrayFromStream( SSTream );
   finally
      SSTream.Free ;
   end ;

end ;
{===============================================================================

<Sysnopsis>       Create a stream from a variant array

<Description>     Create a stream from a variant array

<Post state>      stream will receive the value from the variant array.

<Stream>          will get the result stream

________________________________________________________________________________}
class procedure  TCompressor.CopyFromArrayToStream( V : Variant; Stream : TStream ) ;
var
   Size : Integer ;
   Data : PChar ;
begin
   Size := VarArrayHighBound( V, 1 ) ;
   Data := VarArrayLock( V );
   try
      Stream.Position := 0 ;
      Stream.WriteBuffer( Data^, Size );
      Stream.Position := 0 ;
   finally
      VarArrayUnLock(V); // Added by MJD
   end;
end ;
{===============================================================================

<Sysnopsis>       Create a string from a variant array.

<Description>     Create a string from a variant array using
                  a temporal TStringStream variable and CopyFromArrayToStream
                  function.

<Result>          a string.

________________________________________________________________________________}
class function  TCompressor.CreateStringFromArray( V : Variant ) : String ;
var
  SStream : TStringStream ;
begin

  SStream := TStringStream.Create('')  ;
  try
    SSTream.Position := 0;
    // copy information from a varian array into a stream.
    CopyFromArrayToStream( V, SStream ) ;
    result := SSTream.DataString ;
  finally
    SSTream.Free ;
  end ;

end ;
class function TCompressor.CreateStringFromBitmap( BitMap : TBitmap ) : String ;
var
   V:Variant;
begin
   V:=CreateArrayFromBitmap(Bitmap);
   Result:=CreateStringFromArray(V);
   V:=UnAssigned;
end;
class function TCompressor.CreateBitmapFromString( Str : String  ) : TBitmap ;
var
   V:Variant;
begin
   V:=CreateArrayFromString(Str);
   Result:=CreateBitmapFromArray(V);
   V:=UnAssigned;
end;

class procedure TCompressor.CompressFile( FileInPath, FileOutPath : String ) ;
var
  FileInStream	: TFileStream;
  FileOutStream : TFileStream;
begin
  FileInStream 		:= TFileStream.Create(FileInPath, 	fmOpenRead);
  FileOutStream 	:= TFileStream.Create(FileOutPath, 	fmCreate);
	try
    CompressStream(FileInStream, FileOutStream);
  finally
	  FileInStream.Free;
    FileOutStream.Free;
  end;
end;

class procedure TCompressor.DeCompressFile( FileInPath, FileOutPath : String);
var
  FileInStream	: TFileStream;
  FileOutStream : TFileStream;
begin
  FileInStream 		:= TFileStream.Create(FileInPath, 	fmOpenRead);
  FileOutStream 	:= TFileStream.Create(FileOutPath, 	fmCreate);
	try
    DeCompressStream(FileInStream, FileOutStream);
  finally
	  FileInStream.Free;
    FileOutStream.Free;
  end;
end;
class procedure TCompressor.CopyFromBitmapToStream(BitMap:TBitmap;Stream:TStream);
var
   V:Variant;
begin
   V:=CreateArrayFromBitmap(Bitmap);
   CopyFromArrayToStream(V,Stream);
   V:=UnAssigned;
end;
class function TCompressor.CompressString(Value:String):String;
var
   ISS:TStringStream;
   OSS:TStringStream;
begin
   ISS:=TStringStream.Create(Value);
   OSS:=TStringStream.Create('');
   ISS.Position:=0;
   OSS.Position:=0;
   CompressStream(ISS,OSS);
   Result:=OSS.DataString;
   ISS.Free;                
   OSS.Free;
end;
class function TCompressor.DeCompressString(Value:String):String;
var
   ISS:TStringStream;
   OSS:TStringStream;
begin
   ISS:=TStringStream.Create(Value);
   OSS:=TStringStream.Create('');
   ISS.Position:=0;
   OSS.Position:=0;
   DeCompressStream(ISS,OSS);
   Result:=OSS.DataString;
   ISS.Free;
   OSS.Free;
end;

end.
