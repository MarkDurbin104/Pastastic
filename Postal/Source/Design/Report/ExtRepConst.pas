unit ExtRepConst;

interface

uses
   db,
   classes,
   graphics,
   Controls ;

type

   TCoordinates = ( coLeft, coTop, coWidth, coHeight );
   TSetCoordiantes = set of TCoordinates ;

   TCtrlState   = ( ffCtrlUp, ffCtrlDown );

   TWMCtrlShow = record
      Msg: Cardinal;
      QRName: PChar;
   end;

   TWMCtrlDelete = record
      Msg: Cardinal;
      QRName: PChar;
   end;

   TWMQRZoom = record
      Msg: Cardinal;
      Zoom: integer;
   end;

   TWMQRDocument = record
      Msg : Cardinal;
      Action : integer ;
   end ;

   TWMQRPreview = record
      Msg : Cardinal;
      Action : integer ;
   end ;

   TWMCtrlClick = record
      Msg : Cardinal;
      QRName: PChar;
   end ;

   TWMCtrlDown = record
      Msg : Cardinal;
      Action: integer;
   end ;

   TWMCtrlAlign = record
      Msg : Cardinal;
      Action: integer;
   end ;


const

   WM_CRP_CTRLDELETE       = CM_BASE + $100 ;
   WM_CRP_ZOOM             = CM_BASE + $101 ;
   WM_CRP_DOCUMENT         = CM_BASE + $102 ;
   WM_CRP_CTRLCLICK        = CM_BASE + $103 ;
   WM_CRP_CTRLKEYDOWN      = CM_BASE + $104 ;
   WM_CRP_READDOC          = CM_BASE + $105 ;
   WM_CRP_WRITEDOC         = CM_BASE + $106 ;
   WM_CRP_CTRLALIGN        = CM_BASE + $107 ;
   WM_CRP_CTRLLIST         = CM_BASE + $108 ;
   WM_CRP_CTRLSHOW         = CM_BASE + $109 ;



   ffNewDocument= 1;
   ffOpenFile   = 2;
   ffSaveFile   = 3;
   ffPreview    = 4;

   ffOutPutDir  = 'e:\David\QuickReport' ;
   ffOutPutFile = 'temp.txt'   ;


   ffTab      = '   ' ;

   ffDocument = 'Document' ;
   ffCaption  = 'Caption'  ;
   ffBMPFile  = 'ImageFile';
   ffShape    = 'Shape'    ;
   ffLeft     = 'Left'     ;
   ffTop      = 'Top'      ;
   ffWidth    = 'Width'    ;
   ffHeight   = 'Height'   ;
   ffObject   = 'Object'   ;
   ffClass    = 'Class'    ;
   ffFont     = 'Font'     ;
   ffFontName = 'Name'     ;
   ffFontSize = 'Size'     ;
   ffFontStyle= 'Style'    ;
   ffReport   = 'Report'   ;
   ffLabel    = 'Label'    ;
   ffImage    = 'Image'    ;
   ffGroup    = 'Group'    ;
   ffBand     = 'Band'     ;
   ffField    = 'Field'    ;
   ffAlignment= 'Alignment'; 
   ffID       = 'ID'       ;

   ffComponentName = 'TExtQuickRep' ;


function FontStyleString : String ;
function  ReadFontStyle( Font : TFont ) : String ;
procedure SetFontStyle( FStyle : String; Font : TFont ) ;
function GetFieldNames ( DataSet : TDataSet ) : String ;

implementation

// -----------------------------------------------------------------------------

function FontStyleString : String ;
begin
   result := 'Bold,Italic,Underline,Strikeout' ;

//   ArrFontStyle.Add( 'Bold' );
//   ArrFontStyle.Add( 'Italic' );
//   ArrFontStyle.Add( 'Underline' );
//   ArrFontStyle.Add( 'Strikeout' );

end ;

// -----------------------------------------------------------------------------

function  ReadFontStyle( Font : TFont ) : String ;
var
   FSL, ArrFontStyle : TStringList ;
   i : integer ;
begin
   result := '' ;
   FSL := TStringList.Create ;
   ArrFontStyle := TStringList.Create ;
   ArrFontStyle.CommaText := FontStyleString ;

   for i := 0 to SizeOf( TFontStyle ) do
   begin
      if TFontStyle( i ) in Font.Style then
         FSL.Add( ArrFontStyle[ i ] )
   end ;
   result := FSL.CommaText ;
   FSL.Free ;
   ArrFontStyle.Free;

end ;

// -----------------------------------------------------------------------------

procedure SetFontStyle( FStyle : String; Font : TFont ) ;
var
   FSL, ArrFontStyle : TStringList ;
   I : integer ;
begin
   FSL := TStringList.Create ;
   ArrFontStyle := TStringList.Create ;
   ArrFontStyle.CommaText := FontStyleString ;
   FSL.CommaText := FStyle ;
   Font.Style := [] ;
   for i := 0 to FSL.Count -1 do
   begin
      if ArrFontStyle.IndexOf( FSL[ i ] ) >= 0 then
         Font.Style := Font.Style + [ TFontStyle( ArrFontStyle.IndexOf( FSL[ i ] ) ) ];
   end ;

   FSL.Free ;
   ArrFontStyle.Free ;
end ;


// -----------------------------------------------------------------------------

function GetFieldNames ( DataSet : TDataSet ) : String ;
var
   SL : TStringList ;
   I : integer ;
begin
   result := '' ;
   if ( DataSet <> nil ) and  DataSet.Active then
   begin
      SL := TStringList.Create ;
      try
         for I := 0 to DataSet.FieldCount-1 do
            SL.Add( DataSet.Fields[ I ].FieldName );

         result := SL.CommaText ;
      finally
         SL.Free
      end ;
   end ;
end;

end.
