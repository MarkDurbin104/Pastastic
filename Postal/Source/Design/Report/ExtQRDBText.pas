unit ExtQRDBText;

interface

uses

   //Compress,
   DBTables,
   InspectorFU,
   CompInspector,
   Forms,
   SysUtils,
   Controls,
   Classes,
   Messages,
   graphics,
   quickrpt, qrprntr, Qrctrls,
   ExtQRCommon,
   ExtRepConst,
   Windows,
   LnkFieldFU ;
const
   ffMinSize = 5 ;
type


   TExtQRDBText = class( TQRDBText )
   private
      //ArrFontStyle : TStringList ;
      FAlignmentList :  TStringList ;
      FPointSetX : integer ;
      FPointSetY : integer ;
      FExtQRCtrl : TExtQRCommon ;
      FInspectorForm : TInspectorForm ;
      procedure InicInfInspector ;
      procedure SetInspector( InsPtForm : TInspectorForm );
      function  ReadQRFontStyle : String ;
      procedure SetQRFontStyle( FStyle : String ) ;

      function  ReadAlignmentStr : string ;
      procedure SetAlignmentStr( ShpStr : string ) ;

   public

      procedure Attach ;

      procedure WMLButtonDown    (var Message: TWMLButtonDown);   message WM_LBUTTONDOWN;
      procedure WMRButtonDown    (var Message: TWMRButtonDown);   message WM_RBUTTONDOWN;
      procedure WMLButtonUp      (var Message: TWMLButtonUp);     message WM_LBUTTONUP;
      procedure WMRButtonUp      (var Message: TWMRButtonUp);     message WM_RBUTTONUP;
      procedure WMLButtonDblClk  (var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;

      procedure QROnMouseMove(Sender: TObject; Shift: TShiftState; X,
                               Y: Integer);

      procedure DataChange( ComField, Value : String ) ;
      procedure ListFieldChange  ;
      Property  FontStyle     : String         read ReadQRFontStyle   write SetQRFontStyle ;
      Property  InspectorForm : TInspectorForm read FInspectorForm  write SetInspector;
      property  AlignmentStr : string read ReadAlignmentStr write SetAlignmentStr ;
      Constructor Create( AWOner : TComponent ); override ;
      Destructor Destroy ; override ;
   end ;


implementation

uses
   ExtQuickRepAU ;

constructor TExtQRDBText.Create( AWOner : TComponent ) ;
begin
   inherited Create( AWOner );
   OnMouseMove := QROnMouseMove ;

   FExtQRCtrl := TExtQRCommon.Create ;
   FExtQRCtrl.ParentCtrl := Self ;
   FExtQRCtrl.MinSize := ffMinSize ;
   FExtQRCtrl.CooDisp := [coLeft, coTop, coWidth, coHeight] ;

   FPointSetX := 0 ;
   FPointSetY := 0 ;

   FAlignmentList :=  TStringList.Create ;

   FAlignmentList.Add('Left') ;
   FAlignmentList.Add('Right') ;
   FAlignmentList.Add('Center') ;

   //ArrFontStyle := TStringList.Create ;
   //ArrFontStyle.Commatext := FontStyleString;
   //ArrFontStyle.Add( 'Bold' );
   //ArrFontStyle.Add( 'Italic' );
   //ArrFontStyle.Add( 'Underline' );
   //ArrFontStyle.Add( 'Strikeout' );

end ;
// -----------------------------------------------------------------------------
Destructor TExtQRDBText.Destroy ;
begin

   FInspectorForm.Inspector.OnDataFieldChange := nil ;
   FInspectorForm.Hide ;
   FExtQRCtrl.ParentCtrl := nil ;
   FExtQRCtrl.Free ;
   FAlignmentList.Free ;
   //ArrFontStyle.Free ;
   inherited ;
end ;
// -----------------------------------------------------------------------------

procedure TExtQRDBText.QROnMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
begin

   //Caption := ' Left: '+IntToStr(Left) +'  Top: '+IntToStr( Top ) +' ;  X: '+IntToStr( X ) + '  Y: '+IntToStr( Y ) ;

   FExtQrCtrl.QRMouseMove( X, Y );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRDBText.WMLButtonDown(var Message: TWMLButtonDown);
begin
   inherited ;

   FExtQRCtrl.LButtonDown( Message );

end;

// -----------------------------------------------------------------------------

procedure TExtQRDBText.WMRButtonDown(var Message: TWMLButtonDown);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonDown( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRDBText.WMLButtonUp   (var Message: TWMLButtonUp);
begin

   if ( Message.XPos <> 0 ) and ( Message.YPos <> 0 ) then
      inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonUp( Message );

end ;

// -----------------------------------------------------------------------------


procedure TExtQRDBText.WMRButtonUp   (var Message: TWMRButtonUp);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonUp( Message ); ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRDBText.WMLButtonDblClk(var Message: TWMLButtonDblClk) ;
begin

   if ( Message.XPos <> 0 ) and ( Message.YPos <> 0 ) then
      inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonDblClk( Message ); ;

end ;


// -----------------------------------------------------------------------------


procedure TExtQRDBText.DataChange( ComField, Value : String ) ;
begin

   //if ComField = 'Caption' then
   //   Caption := Value
   //else
   if ComField = 'Field' then
      Self.DataField := Value
   else
   if ComField = 'Alignment' then
      Self.Alignment := TAlignment( FAlignmentList.IndexOf( Value ) )
   else
      FExtQRCtrl.DataChange( ComField, Value ) ;


end ;

// -----------------------------------------------------------------------------

procedure TExtQRDBText.ListFieldChange  ;
begin
   InicInfInspector ;
end ;
// -----------------------------------------------------------------------------

procedure TExtQRDBText.InicInfInspector ;
var
   SPL : TStringList ;
begin

   SPL := TStringList.Create ;

   SPL.Assign( FAlignmentList );
   SPL.Insert(0, AlignmentStr);

   FInspectorForm.Inspector.Clear;
   FInspectorForm.Inspector.OnDataFieldChange := DataChange ;
   TLinkFieldForm(TExtQuickRep( Owner ).LinkFieldForm).OnDataFieldChange := ListFieldChange ;

   //FInspectorForm.Inspector.Add('Caption',itString ,Caption  );
   FInspectorForm.Inspector.Add('Alignment', itComboBox, SPL.CommaText );
   FInspectorForm.Inspector.AddFont('Font', Self.Font  );
   FInspectorForm.Inspector.Add('Field', itComboBox, DataField +',' + TLinkFieldForm(TExtQuickRep( Owner ).LinkFieldForm).LinkFields );

//GetFieldNames( DataSet )  );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRDBText.SetInspector( InsPtForm : TInspectorForm ) ;
begin

   FInspectorForm := InsPtForm ;
   FExtQRCtrl.InspectorForm := FInspectorForm ;

end ;

// -----------------------------------------------------------------------------


function  TExtQRDBText.ReadQRFontStyle : String ;
begin
   result := ReadFontStyle( Font ); ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRDBText.SetQRFontStyle( FStyle : String ) ;
begin
   SetFontStyle( FStyle, Font );
end ;

// -----------------------------------------------------------------------------

function TExtQRDBText.ReadAlignmentStr : string ;
begin
   result := FAlignmentList[ integer( Alignment )] ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRDBText.SetAlignmentStr( ShpStr : string );
var
   I : integer ;
begin
   I := FAlignmentList.IndexOf( ShpStr );
   if I >= 0 then
      Alignment := TAlignment( I ) ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRDBText.Attach ;
begin
   FExtQRCtrl.AttachCtrl ;
end ;




end.
