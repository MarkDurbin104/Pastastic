unit ExtQRGroupAU;

interface

uses
   Db,
   ExtHoldObj,
   InspectorFU,
   CompInspector,
   Forms,
   SysUtils,
   Controls,
   Classes,
   Messages,
   graphics,
   counter,
   quickrpt, qrprntr, Qrctrls,
   ExtQRCommon,
   ExtRepConst,
   Windows ;

const
   ffMinSize = 10 ;


type


   TExtQRGroup = class( TQRGroup )
   private
      FExtQRCtrl : TExtQRCommon ;
      FInspectorForm : TInspectorForm ;

      FDataSet   : TDataSet ;
      procedure InicInfInspector ;
      procedure SetInspector( InsPtForm : TInspectorForm );
      function  ReadQRFontStyle : String ;
      procedure SetQRFontStyle( FStyle : String ) ;
      procedure SetCounter( Counter : TCounter ) ;

   public

      ExtHoldObj : TExtHoldObj;
      procedure WMLButtonDown    (var Message: TWMLButtonDown);   message WM_LBUTTONDOWN;
      procedure WMRButtonDown    (var Message: TWMRButtonDown);   message WM_RBUTTONDOWN;
      Property  FontStyle  : String         read ReadQRFontStyle   write SetQRFontStyle ;
      procedure WMLButtonUp      (var Message: TWMLButtonUp);     message WM_LBUTTONUP;
      procedure WMRButtonUp      (var Message: TWMRButtonUp);     message WM_RBUTTONUP;
      procedure WMLButtonDblClk  (var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
      procedure WMPaint          (var Message: TWMPaint);         message WM_PAINT;
      procedure MsgCtrlDelete( var Message : TWMCtrlDelete ) ; message WM_CRP_CTRLDELETE ;
      procedure MsgCtrlClick( var Message : TWMCtrlClick ) ; message WM_CRP_CTRLCLICK ;
      procedure MsgCtrlAlign( var Message : TWMCtrlAlign ) ; message WM_CRP_CTRLALIGN ;
      procedure QROnMouseMove(Sender: TObject; Shift: TShiftState; X,
                               Y: Integer);

      procedure FillComponents;
      procedure InitSQL ;
      procedure DataChange( ComField, Value : String ) ;
      property  DataSet       : TDataSet       read FDataSet        write FDataSet ;
      Property  InspectorForm : TInspectorForm read FInspectorForm  write SetInspector;
      property  Counter    : TCounter       write SetCounter ;
      Constructor Create( AWOner : TComponent ); override ;
      Destructor Destroy ; override ;

   end ;

implementation

constructor TExtQRGroup.Create( AWOner : TComponent ) ;
begin
   inherited Create( AWOner ) ;

   FExtQRCtrl := TExtQRCommon.Create ;
   FExtQRCtrl.ParentCtrl := Self ;
   FExtQRCtrl.MinSize := ffMinSize ;
   FExtQRCtrl.CooDisp := [coHeight] ;

   ExtHoldObj := TExtHoldObj.Create( nil ) ;
   ExtHoldObj.OwnerCtrl  := AWOner ;
   ExtHoldObj.ParentCtrl := Self ;

   OnDragDrop  := ExtHoldObj.QROnDragDrop ;
   OnDragOver  := ExtHoldObj.QROnDragOver ;
   OnMouseMove := QROnMouseMove ;

end ;

// -----------------------------------------------------------------------------

destructor TExtQRGroup.Destroy ;
begin

   FInspectorForm.Inspector.OnDataFieldChange := nil ;
   FInspectorForm.Hide ;
   FExtQRCtrl.ParentCtrl := nil ;
   FExtQRCtrl.Free ;
   inherited
end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.QROnMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
begin

   FExtQrCtrl.QRMouseMove( X, Y );
   ExtHoldObj.QROnMouseMove(Sender,Shift, X, Y );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.DataChange( ComField, Value : String ) ;
begin

   if ( ComField = 'Expression' ) then
      Expression := Value
   else
      FExtQRCtrl.DataChange( ComField, Value ) ;


end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.InicInfInspector ;
var
   SPL : TStringList ;
begin

   SPL := TStringList.Create ;

   try
      FInspectorForm.Inspector.Clear;
      FInspectorForm.Inspector.AddFont('Font', Self.Font  );
      FInspectorForm.Inspector.Add('Expression', itString, Expression );
      FInspectorForm.Inspector.OnDataFieldChange := DataChange ;
   finally
      SPL.Free ;
   end ;

end ;
// -----------------------------------------------------------------------------

procedure TExtQRGroup.SetInspector( InsPtForm : TInspectorForm ) ;
begin

   FInspectorForm := InsPtForm ;
   ExtHoldObj.InspectorForm := FInspectorForm ;
   FExtQRCtrl.InspectorForm := FInspectorForm ;


end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.WMLButtonDown(var Message: TWMLButtonDown);
begin
   inherited ;
   FExtQRCtrl.LButtonDown( Message );
   ExtHoldObj.LButtonDown( Message );


end;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.WMRButtonDown(var Message: TWMLButtonDown);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonDown( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.WMLButtonUp   (var Message: TWMLButtonUp);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonUp( Message );
   ExtHoldObj.LButtonUp( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.WMRButtonUp   (var Message: TWMRButtonUp);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonUp( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.WMLButtonDblClk(var Message: TWMLButtonDblClk) ;
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonDblClk( Message );

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

// -----------------------------------------------------------------------------

procedure TExtQRGroup.MsgCtrlDelete( var Message : TWMCtrlDelete ) ;
begin
   ExtHoldObj.DeleteCtrl( String( Message.QRName ) );
end ;

// -----------------------------------------------------------------------------
procedure TExtQRGroup.SetCounter( Counter : TCounter ) ;
begin
   ExtHoldObj.Counter := Counter ;
end ;
// -----------------------------------------------------------------------------
procedure TExtQRGroup.InitSQL ;
begin
   ExtHoldObj.DataSet := FDataSet ;
//   DataSet.Open ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.MsgCtrlClick( var Message : TWMCtrlClick ) ;
begin

   ExtHoldObj.AddControlToGroup( String( Message.QRName ) );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.FillComponents;
begin
   ExtHoldObj.FillComponents
end ;

// -----------------------------------------------------------------------------

procedure TExtQRGroup.MsgCtrlAlign( var Message : TWMCtrlAlign ) ;
begin
   ExtHoldObj.AlignTo( Talign ( Message.Action ) ) ;
end ;

// -----------------------------------------------------------------------------
procedure TExtQRGroup.WMPaint(var Message: TWMPaint);
begin
   inherited ;
   ExtHoldObj.QRRepaint ;
end ;

end.
