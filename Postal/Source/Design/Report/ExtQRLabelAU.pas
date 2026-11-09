unit ExtQRLabelAU;

interface

uses

   //Compress,
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
   Windows ;
const
   ffMinSize = 5 ;
type


   TExtQRLabel = class( TQRLabel )
   private
      //ArrFontStyle : TStringList ;
      FPointSetX : integer ;
      FPointSetY : integer ;
      FExtQRCtrl : TExtQRCommon ;
      FInspectorForm : TInspectorForm ;
      procedure InicInfInspector ;
      procedure SetInspector( InsPtForm : TInspectorForm );
      function  ReadQRFontStyle : String ;
      procedure SetQRFontStyle( FStyle : String ) ;

   public

      procedure Attach ;

      procedure WMLButtonDown    (var Message: TWMLButtonDown);   message WM_LBUTTONDOWN;
      procedure WMRButtonDown    (var Message: TWMRButtonDown);   message WM_RBUTTONDOWN;
      procedure WMLButtonUp      (var Message: TWMLButtonUp);     message WM_LBUTTONUP;
      procedure WMRButtonUp      (var Message: TWMRButtonUp);     message WM_RBUTTONUP;
      procedure WMLButtonDblClk  (var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;

//       procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;

      procedure QROnMouseMove(Sender: TObject; Shift: TShiftState; X,
                               Y: Integer);
      procedure DataChange( ComField, Value : String ) ;
      Property  FontStyle     : String         read ReadQRFontStyle   write SetQRFontStyle ;
      Property  InspectorForm : TInspectorForm read FInspectorForm  write SetInspector;
      Constructor Create( AWOner : TComponent ); override ;
      Destructor Destroy ; override ;
   end ;


implementation

//uses
//   ExtQuickRepAU ;

constructor TExtQRLabel.Create( AWOner : TComponent ) ;
begin
   inherited Create( AWOner );
   OnMouseMove := QROnMouseMove ;
   FExtQRCtrl := TExtQRCommon.Create ;
   FExtQRCtrl.ParentCtrl := Self ;
   FExtQRCtrl.MinSize := ffMinSize ;
   FExtQRCtrl.CooDisp := [coLeft, coTop, coWidth, coHeight] ;

   FPointSetX := 0 ;
   FPointSetY := 0 ;

   //ArrFontStyle := TStringList.Create ;
   //ArrFontStyle.Commatext := FontStyleString;
   //ArrFontStyle.Add( 'Bold' );
   //ArrFontStyle.Add( 'Italic' );
   //ArrFontStyle.Add( 'Underline' );
   //ArrFontStyle.Add( 'Strikeout' );

end ;
// -----------------------------------------------------------------------------
Destructor TExtQRLabel.Destroy ;
begin

   FInspectorForm.Inspector.OnDataFieldChange := nil ;
   FInspectorForm.Hide ;
   FExtQRCtrl.ParentCtrl := nil ;
   FExtQRCtrl.Free ;
   //ArrFontStyle.Free ;
   inherited ;
end ;
// -----------------------------------------------------------------------------

procedure TExtQRLabel.QROnMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
begin

   //Caption := ' Left: '+IntToStr(Left) +'  Top: '+IntToStr( Top ) +' ;  X: '+IntToStr( X ) + '  Y: '+IntToStr( Y ) ;

   FExtQrCtrl.QRMouseMove( X, Y );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRLabel.WMLButtonDown(var Message: TWMLButtonDown);
begin
   inherited ;

   FExtQRCtrl.LButtonDown( Message );

end;

// -----------------------------------------------------------------------------

procedure TExtQRLabel.WMRButtonDown(var Message: TWMLButtonDown);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonDown( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRLabel.WMLButtonUp   (var Message: TWMLButtonUp);
begin

   if ( Message.XPos <> 0 ) and ( Message.YPos <> 0 ) then
      inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonUp( Message );

end ;

// -----------------------------------------------------------------------------


procedure TExtQRLabel.WMRButtonUp   (var Message: TWMRButtonUp);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonUp( Message ); ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRLabel.WMLButtonDblClk(var Message: TWMLButtonDblClk) ;
begin

   if ( Message.XPos <> 0 ) and ( Message.YPos <> 0 ) then
      inherited ;

   InicInfInspector ;
   FExtQRCtrl.LButtonDblClk( Message );

end ;


// -----------------------------------------------------------------------------

procedure TExtQRLabel.DataChange( ComField, Value : String ) ;
begin

   if ComField = 'Caption' then
      Caption := Value
   else
      FExtQRCtrl.DataChange( ComField, Value ) ;


end ;

// -----------------------------------------------------------------------------

procedure TExtQRLabel.InicInfInspector ;
begin

   FInspectorForm.Inspector.Clear;
   FInspectorForm.Inspector.OnDataFieldChange := DataChange ;
   FInspectorForm.Inspector.Add('Caption',itString ,Caption  );
   FInspectorForm.Inspector.AddFont('Font', Self.Font  );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRLabel.SetInspector( InsPtForm : TInspectorForm ) ;
begin

   FInspectorForm := InsPtForm ;
   FExtQRCtrl.InspectorForm := FInspectorForm ;

end ;

// -----------------------------------------------------------------------------


function  TExtQRLabel.ReadQRFontStyle : String ;
begin
   result := ReadFontStyle( Font ); ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRLabel.SetQRFontStyle( FStyle : String ) ;
begin
   SetFontStyle( FStyle, Font );
end ;

// -----------------------------------------------------------------------------

procedure TExtQRLabel.Attach ;
begin
   FExtQRCtrl.AttachCtrl ;
end ;


end.
