{  Module          Compress Bitmaps
   Unit            Compress
   Copyright(c)    Postal Solutions Limited 1998..1998
   Author          DDB
   Description     Compress and Decompress From/To BitMap, From/To Variant array
                              Original Release
}
unit Compress;

interface

uses Graphics, classes, ZLib ;
type 
   TCompressor =class(TObject)
   public
      function  CreateArrayFromBitmap( BitMap : TBitmap ) : Variant ;
      function  CreateBitmapFromArray( V : Variant ) : TBitmap ;

      function  CreateArrayFromString( Str : String ) : variant ;
      function  CreateArrayFromStream( Stream : TStream ) : variant ;

      procedure CopyFromArrayToStream( V : Variant; Stream : TStream )  ;
      function  CreateStringFromArray( V : Variant ) : String ;

      procedure CompressStream( StreamIn, StreamOut : TStream ) ;
      procedure DecompressStream( StreamIn, StreamOut : TStream ) ;
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
function  TCompressor.CreateArrayFromStream( Stream : TStream ) : variant ;
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

<StreamOut>       will receive a compressed strean.

________________________________________________________________________________}
procedure TCompressor.CompressStream( StreamIn, StreamOut : TStream ) ;
var
   ZCompression : TCompressionStream ;
begin

   ZCompression := TCompressionStream.Create(clMax, StreamOut );
   ZCompression.CopyFrom( StreamIn, 0 );
   ZCompression.Free ;

end ;
{===============================================================================

<Sysnopsis>       Decompress a stream.

<Description>     Get a normal stream from a compressed stream usin ZLib
                  decompress algoriths.

<Post state>      StreamOut will receive a decompress stream.

<StreamIn>        a stream to compress.

<StreamOut>       will receive a uncompressed stream.

________________________________________________________________________________}
procedure TCompressor.DecompressStream( StreamIn, StreamOut : TStream ) ;
var
   Count : integer ;
   Buffer: array[0..BufferSize-1] of Byte;
   ZDeCompression : TDecompressionStream ;
begin
   ZDecompression := TDecompressionStream.Create( StreamIn );
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
function TCompressor.CreateArrayFromBitmap( BitMap : TBitmap ) : Variant ;
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
function TCompressor.CreateBitmapFromArray( V : Variant ) : TBitmap ;
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

      MemoryStreamIn.Free ;

   end;

end ;
{===============================================================================

<Sysnopsis>       Create a variant array from a string.

<Description>     Create a variant array from a string using a temporal
                  TStringStream variable and the funciton CreateArrayFromStream.

<Result>          Variant array.

________________________________________________________________________________}
function TCompressor.CreateArrayFromString( Str : String ) : variant ;
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
procedure  TCompressor.CopyFromArrayToStream( V : Variant; Stream : TStream ) ;
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
function  TCompressor.CreateStringFromArray( V : Variant ) : String ;
var
  SStream : TStringStream ;
begin

  SStream := TStringStream.Create('')  ;
  try
    SSTream.Position := 0;
    // copy information from a varian array into a stream.
    CopyFromArrayToStream( V, SStream ) ;
  finally
    result := SSTream.DataString ;
    SSTream.Free ;
  end ;

end ;

end.                      
