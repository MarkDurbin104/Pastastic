unit ExtQRShapeAU;

interface

uses
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

   TExtQRShape = class( TQRShape )
   private
      FShapeList :  TStringList ;
      FPointSetX : integer ;
      FPointSetY : integer ;
      FExtQRCtrl : TExtQRCommon ;
      FInspectorForm : TInspectorForm ;
      procedure InicInfInspector ;
      procedure SetInspector( InsPtForm : TInspectorForm );
      function  ReadShapeStr : string ;
      procedure SetShapeStr( ShpStr : string ) ;

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
      property  ShapeStr : string read ReadShapeStr write SetShapeStr ;
      Property  InspectorForm : TInspectorForm read FInspectorForm  write SetInspector;
      Constructor Create( AWOner : TComponent ); override ;
      Destructor Destroy ; override ;

   end ;

implementation

constructor TExtQRShape.Create( AWOner : TComponent ) ;
begin
   inherited Create( AWOner );
   OnMouseMove := QROnMouseMove ;
   FExtQRCtrl := TExtQRCommon.Create ;
   FExtQRCtrl.ParentCtrl := Self ;
   FExtQRCtrl.MinSize := ffMinSize ;
   FExtQRCtrl.CooDisp := [coLeft, coTop, coWidth, coHeight] ;

   FShapeList :=  TStringList.Create ;

   FShapeList.Add('Rectangle') ;
   FShapeList.Add('Circle') ;
   FShapeList.Add('VerLine') ;
   FShapeList.Add('HorLine') ;
   FShapeList.Add('Top And Bottom') ;
   FShapeList.Add('Right And Left') ;

   FPointSetX := 0 ;
   FPointSetY := 0 ;

end ;
// -----------------------------------------------------------------------------
Destructor TExtQRShape.Destroy ;
begin

   FInspectorForm.Inspector.OnDataFieldChange := nil ;
   FInspectorForm.Hide ;
   FExtQRCtrl.ParentCtrl := nil ;
   FExtQRCtrl.Free ;
   FShapeList.Free ;
   inherited ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRShape.QROnMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
begin

   FExtQrCtrl.QRMouseMove( X, Y );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRShape.WMLButtonDown(var Message: TWMLButtonDown);
begin
   inherited ;

   FExtQRCtrl.LButtonDown( Message );

end;

// -----------------------------------------------------------------------------

procedure TExtQRShape.WMRButtonDown(var Message: TWMLButtonDown);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonDown( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRShape.WMLButtonUp   (var Message: TWMLButtonUp);
begin

   if ( Message.XPos <> 0 ) and ( Message.YPos <> 0 ) then
      inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonUp( Message );

end ;

// -----------------------------------------------------------------------------


procedure TExtQRShape.WMRButtonUp   (var Message: TWMRButtonUp);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonUp( Message ); ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRShape.WMLButtonDblClk(var Message: TWMLButtonDblClk) ;
begin

   if ( Message.XPos <> 0 ) and ( Message.YPos <> 0 ) then
      inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonDblClk( Message ); ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRShape.DataChange( ComField, Value : String ) ;
begin

   if ( ComField = 'Shape' ) then
      Shape := TQRShapeType( FShapeList.IndexOf ( Value ) );
   FExtQRCtrl.DataChange( ComField, Value ) ;


end ;

// -----------------------------------------------------------------------------

procedure TExtQRShape.InicInfInspector ;
var
   SPL : TStringList ;
begin

   SPL := TStringList.Create ;

   try
      FInspectorForm.Inspector.Clear;
      SPL.Assign( FShapeList );
      SPL.Insert(0, ShapeStr);
      FInspectorForm.Inspector.Add('Shape', itComboBox, SPL.CommaText );
      FInspectorForm.Inspector.OnDataFieldChange := DataChange ;
   finally
      SPL.Free ;
   end ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRShape.SetInspector( InsPtForm : TInspectorForm ) ;
begin

   FInspectorForm := InsPtForm ;
   FExtQRCtrl.InspectorForm := FInspectorForm ;

end ;

// -----------------------------------------------------------------------------

function TExtQRShape.ReadShapeStr : string ;
begin
   result := FShapeList[ integer( Shape )] ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRShape.SetShapeStr( ShpStr : string );
var
   I : integer ;
begin
   I := FShapeList.IndexOf( ShpStr );
   if I >= 0 then
      Shape := TQRShapeType( I ) ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRShape.Attach ;
begin
   FExtQRCtrl.AttachCtrl ;
end ;


end .