unit ExtQRImageAU;

interface

uses
   Compress,
   InspectorFU,
   CompInspector,
   Forms,
   SysUtils,
   Controls,
   Classes,
   Messages,
   quickrpt, qrprntr, Qrctrls,
   Windows,Graphics,
   ExtRepConst,
   ExtQRCommon;
const
   ffMinSize = 5 ;


type

   TExtQRImage = class( TQRImage )
   private
      FPointSetX : integer ;
      FPointSetY : integer ;
      FExtQRCtrl : TExtQRCommon ;
      FInspectorForm : TInspectorForm ;
      FBmpFile   : String ;
      FBitmap    : TBitMap ;
      procedure InicInfInspector ;
      procedure SetInspector( InsPtForm : TInspectorForm );
      procedure Update ; override ;
      procedure SetBitMap( BMP : TBitMap );

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
      property  InspectorForm : TInspectorForm read FInspectorForm  write SetInspector;
      property  BmpFile       : string         read FBmpFile        write FBmpFile ;
      property  BitMap        : TBitMap        Read FBitMap         write SetBitMap ;
      Constructor Create( AWOner : TComponent ); override ;
      Destructor Destroy ; override ;

   end ;

implementation

constructor TExtQRImage.Create( AWOner : TComponent ) ;
begin
   inherited Create( AWOner );
   OnMouseMove := QROnMouseMove ;
   FExtQRCtrl := TExtQRCommon.Create ;
   FExtQRCtrl.ParentCtrl := Self ;
   FExtQRCtrl.MinSize := ffMinSize ;
   FExtQRCtrl.CooDisp := [coLeft, coTop, coWidth, coHeight] ;

   FPointSetX := 0 ;
   FPointSetY := 0 ;
   FBmpFile := '' ;
   FBitMap := TBitMap.Create ;
   FBitMap.Assign( Picture.Bitmap );

end ;
// -----------------------------------------------------------------------------
Destructor TExtQRImage.Destroy ;
begin

   FInspectorForm.Inspector.OnDataFieldChange := nil ;
   FInspectorForm.Hide ;
   FExtQRCtrl.ParentCtrl := nil ;
   FExtQRCtrl.Free ;
   FBitMap.Free ;
   inherited ;

end ;
// -----------------------------------------------------------------------------
procedure TExtQRImage.QROnMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
begin

   FExtQrCtrl.QRMouseMove( X, Y );

end ;
// -----------------------------------------------------------------------------
procedure TExtQRImage.WMLButtonDown(var Message: TWMLButtonDown);
begin
   inherited ;

   FExtQRCtrl.LButtonDown( Message );

end;
// -----------------------------------------------------------------------------
procedure TExtQRImage.WMRButtonDown(var Message: TWMLButtonDown);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonDown( Message );

end ;
// -----------------------------------------------------------------------------
procedure TExtQRImage.WMLButtonUp   (var Message: TWMLButtonUp);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonUp( Message );

end ;
// -----------------------------------------------------------------------------
procedure TExtQRImage.WMRButtonUp   (var Message: TWMRButtonUp);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonUp( Message ); ;

end ;
// -----------------------------------------------------------------------------
procedure TExtQRImage.WMLButtonDblClk(var Message: TWMLButtonDblClk) ;
begin

   if ( Message.XPos <> 0 ) and ( Message.YPos <> 0 ) then
      inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonDblClk( Message ); ;

end ;
// -----------------------------------------------------------------------------
procedure TExtQRImage.DataChange( ComField, Value : String ) ;
begin

   if ComField = 'Image' then
   begin
      FBmpFile := Value ;
      FBitMap.LoadFromFile( FBmpFile );
   end
   else
      FExtQRCtrl.DataChange( ComField, Value ) ;

end ;
// -----------------------------------------------------------------------------
procedure TExtQRImage.InicInfInspector ;
begin

   FInspectorForm.Inspector.Clear;
   FInspectorForm.Inspector.OnDataFieldChange := DataChange ;
   FInspectorForm.Inspector.AddBitMap('Image', FBmpFile, Picture.BitMap );

end ;
// -----------------------------------------------------------------------------
procedure TExtQRImage.SetInspector( InsPtForm : TInspectorForm ) ;
begin
   FInspectorForm := InsPtForm ;
   FExtQRCtrl.InspectorForm := FInspectorForm ;
end ;
// -----------------------------------------------------------------------------
procedure TExtQRImage.Update ;
begin

   inherited ;

end ;
// -----------------------------------------------------------------------------
procedure TExtQRImage.SetBitMap( BMP: TBitMap ) ;
begin
   FBitMap.Assign( BMP );
   Picture.BitMap.Assign( BMP );
end ;

// -----------------------------------------------------------------------------

procedure TExtQRImage.Attach ;
begin
   FExtQRCtrl.AttachCtrl ;
end ;



end .
