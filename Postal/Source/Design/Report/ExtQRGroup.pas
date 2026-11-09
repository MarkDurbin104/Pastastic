unit ExtQRGroup;

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
   ffMinSize = 1 ;


type

   TExtQRGroup = class( TQRShape )
   private
      FExtQRCtrl : TExtQRCommon ;
      FInspectorForm : TInspectorForm ;
      procedure InicInfInspector ;
      procedure SetInspector( InsPtForm : TInspectorForm );
      function  ReadQRFontStyle : String ;
      procedure SetQRFontStyle( FStyle : String ) ;

   public

      procedure WMLButtonDown    (var Message: TWMLButtonDown);   message WM_LBUTTONDOWN;
      procedure WMRButtonDown    (var Message: TWMRButtonDown);   message WM_RBUTTONDOWN;
      Property  FontStyle     : String         read ReadQRFontStyle   write SetQRFontStyle ;
      procedure WMLButtonUp      (var Message: TWMLButtonUp);     message WM_LBUTTONUP;
      procedure WMRButtonUp      (var Message: TWMRButtonUp);     message WM_RBUTTONUP;
      procedure WMLButtonDblClk  (var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;

      //procedure QROnMouseMove(Sender: TObject; Shift: TShiftState; X,
      //                         Y: Integer);
      procedure DataChange( ComField, Value : String ) ;
      Property  InspectorForm : TInspectorForm read FInspectorForm  write SetInspector;
      Constructor Create( AWOner : TComponent ); override ;
      Destructor Destroy ; override ;

   end ;

implementation

constructor TExtQRGroup.Create( AWOner : TComponent ) ;
begin
   inherited Create( AWOner ) ;
end ;

destructor TExtQRGroup.Destroy ;
begin
   inherited
end ;
// -----------------------------------------------------------------------------

procedure TExtQRGroup.DataChange( ComField, Value : String ) ;
begin

   if ( ComField = 'Shape' ) then
     // Shape := TQRShapeType( FShapeList.IndexOf ( Value ) );
   //FExtQRCtrl.DataChange( ComField, Value ) ;


end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.InicInfInspector ;
var
   SPL : TStringList ;
begin

   SPL := TStringList.Create ;

   try
      FInspectorForm.Inspector.Clear;
      //SPL.Assign( FShapeList );
      //SPL.Insert(0, ShapeStr);
      //FInspectorForm.Inspector.Add('Shape', itComboBox, SPL.CommaText );
      FInspectorForm.Inspector.OnDataFieldChange := DataChange ;
   finally
      SPL.Free ;
   end ;

end ;
// -----------------------------------------------------------------------------

procedure TExtQRGroup.SetInspector( InsPtForm : TInspectorForm ) ;
begin

   FInspectorForm := InsPtForm ;
   //FExtQRCtrl.InspectorForm := FInspectorForm ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.WMLButtonDown(var Message: TWMLButtonDown);
begin
   inherited ;

   //FExtQRCtrl.LButtonDown( Message );

end;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.WMRButtonDown(var Message: TWMLButtonDown);
begin

   inherited ;
   InicInfInspector ;
   //FExtQRCtrl.RButtonDown( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.WMLButtonUp   (var Message: TWMLButtonUp);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonUp( Message );

end ;

// -----------------------------------------------------------------------------


procedure TExtQRGroup.WMRButtonUp   (var Message: TWMRButtonUp);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonUp( Message ); ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.WMLButtonDblClk(var Message: TWMLButtonDblClk) ;
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonDblClk( Message ); ;

end ;

// -----------------------------------------------------------------------------

function  TExtQRGroup.ReadQRFontStyle : String ;
begin
   result := ReadFontStyle( Font ); ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.SetQRFontStyle( FStyle : String ) ;
begin
   SetFontStyle( FStyle, Font );
end ;


end.
