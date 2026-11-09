unit ExtQRBandAU;

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
   Dialogs,
   Windows ;


const
   ffMinSize = 10 ;


type


   TExtQRBand = class( TQRBand )
   private
      FBandTypeList :  TStringList ;
      FExtQRCtrl : TExtQRCommon ;
      FInspectorForm : TInspectorForm ;

      FDataSet  : TDataSet ;
      procedure InicInfInspector ;
      procedure SetInspector( InsPtForm : TInspectorForm );
      procedure SetCounter( Counter : TCounter ) ;
      function  ReadQRFontStyle : String ;
      procedure SetQRFontStyle( FStyle : String ) ;

   public
      ExtHoldObj : TExtHoldObj;
      procedure WMLButtonDown    (var Message: TWMLButtonDown);   message WM_LBUTTONDOWN;
      procedure WMRButtonDown    (var Message: TWMRButtonDown);   message WM_RBUTTONDOWN;

      property  FontStyle  : String         read ReadQRFontStyle   write SetQRFontStyle ;
      property  Counter    : TCounter       write SetCounter ;
      procedure WMLButtonUp      (var Message: TWMLButtonUp);     message WM_LBUTTONUP;
      procedure WMRButtonUp      (var Message: TWMRButtonUp);     message WM_RBUTTONUP;
      procedure WMLButtonDblClk  (var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
      procedure WMPaint          (var Message: TWMPaint);         message WM_PAINT;
      procedure MsgCtrlDelete( var Message : TWMCtrlDelete ) ; message WM_CRP_CTRLDELETE ;
      procedure MsgCtrlClick ( var Message : TWMCtrlClick ) ; message WM_CRP_CTRLCLICK ;
      procedure MsgCtrlKey ( var message : TWMCtrlDown )    ; message WM_CRP_CTRLKEYDOWN ;
      procedure MsgCtrlAlign( var Message : TWMCtrlAlign ) ; message WM_CRP_CTRLALIGN ;
      procedure QROnMouseMove(Sender: TObject; Shift: TShiftState; X,
                               Y: Integer);

      procedure FillComponents;
      procedure InitSQL ;
      function BandTypeStr : String ;
      procedure DataChange( ComField, Value : String ) ;
      property  DataSet  : TDataSet            read FDataSet        write FDataSet ;
      Property  InspectorForm : TInspectorForm read FInspectorForm  write SetInspector;
      Constructor Create( AWOner : TComponent ); override ;
      Destructor Destroy ; override ;

   end ;

implementation

constructor TExtQRBand.Create( AWOner : TComponent ) ;
begin
   inherited Create( AWOner ) ;


   FBandTypeList := TStringList.Create ;

   FExtQRCtrl := TExtQRCommon.Create ;
   FExtQRCtrl.ParentCtrl := Self ;
   FExtQRCtrl.MinSize := ffMinSize ;
   FExtQRCtrl.CooDisp := [coHeight] ;

   ExtHoldObj := TExtHoldObj.Create( nil ) ;
   ExtHoldObj.OwnerCtrl  := AWOner ;
   ExtHoldObj.ParentCtrl := Self ;


   OnDragDrop  := ExtHoldObj.QROnDragDrop ;
   OnDragOver  := ExtHoldObj.QROnDragOver ;
//   OnPaint     := ExtHoldObj.QROnRepaint  ;
   OnMouseMove := QROnMouseMove ;


   FBandTypeList.Add('rbTitle');
   FBandTypeList.Add('rbPageHeader');
   FBandTypeList.Add('rbDetail');
   FBandTypeList.Add('rbPageFooter');
   FBandTypeList.Add('rbSummary');
   FBandTypeList.Add('rbGroupHeader');
   FBandTypeList.Add('rbGroupFooter');
   FBandTypeList.Add('rbSubDetail');
   FBandTypeList.Add('rbColumnHeader');
   FBandTypeList.Add('rbOverlay');
   FBandTypeList.Add('rbChild');


end ;

// -----------------------------------------------------------------------------

destructor TExtQRBand.Destroy ;
begin

   FInspectorForm.Inspector.OnDataFieldChange := nil ;
   FInspectorForm.Hide ;
   FExtQRCtrl.ParentCtrl := nil ;
   ExtHoldObj.Counter := nil ;
   FExtQRCtrl.Free ;
   FBandTypeList.Free ;
   inherited
end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.QROnMouseMove(Sender: TObject; Shift: TShiftState; X,
            Y: Integer);
begin

   FExtQrCtrl.QRMouseMove( X, Y );
   ExtHoldObj.QROnMouseMove(Sender,Shift, X, Y );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.DataChange( ComField, Value : String ) ;
begin

   if ( ComField = 'BandType' ) then
      BandType := TQRBandType( FBandTypeList.IndexOf ( Value ) )
   else
      FExtQRCtrl.DataChange( ComField, Value ) ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.InicInfInspector ;
var
   BTL : TStringList ;
begin

   BTL := TStringList.Create ;

   try
      FInspectorForm.Inspector.Clear;
      FInspectorForm.Inspector.AddFont('Font', Self.Font  );

      BTL.Assign( FBandTypeList );
      BTL.Insert(0, BandTypeStr );

      FInspectorForm.Inspector.Add('BandType', itComboBox, BTL.CommaText );
      FInspectorForm.Inspector.OnDataFieldChange := DataChange ;
   finally
      BTL.Free ;
   end ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.SetInspector( InsPtForm : TInspectorForm ) ;
begin

   FInspectorForm := InsPtForm ;
   ExtHoldObj.InspectorForm := FInspectorForm ;
   FExtQRCtrl.InspectorForm := FInspectorForm ;


end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.WMLButtonDown(var Message: TWMLButtonDown);
begin
   inherited ;

   FExtQRCtrl.LButtonDown( Message );
   ExtHoldObj.LButtonDown( Message );

end;

// -----------------------------------------------------------------------------

procedure TExtQRBand.WMRButtonDown(var Message: TWMLButtonDown);
begin


   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonDown( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.WMLButtonUp   (var Message: TWMLButtonUp);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonUp( Message );
   ExtHoldObj.LButtonUp( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.WMRButtonUp   (var Message: TWMRButtonUp);
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.RButtonUp( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.WMLButtonDblClk(var Message: TWMLButtonDblClk) ;
begin

   inherited ;
   InicInfInspector ;
   FExtQRCtrl.LButtonDblClk( Message );

end ;

// -----------------------------------------------------------------------------

function TExtQRBand.BandTypeStr : String;
begin
   result := FBandTypeList[ integer( BandType )] ;
end ;

// -----------------------------------------------------------------------------

function TExtQRBand.ReadQRFontStyle : String ;
begin
   result := ReadFontStyle( Font ); ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.SetQRFontStyle( FStyle : String ) ;
begin
   SetFontStyle( FStyle, Font );
end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.MsgCtrlDelete( var Message : TWMCtrlDelete ) ;
begin
   ExtHoldObj.DeleteCtrl( String( Message.QRName ) );
end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.SetCounter( Counter : TCounter ) ;
begin
   ExtHoldObj.Counter := Counter ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.InitSQL ;
begin
   ExtHoldObj.DataSet := FDataSet ;
//   DataSet.Open ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.MsgCtrlClick( var Message : TWMCtrlClick ) ;
begin

   ExtHoldObj.AddControlToGroup( String( Message.QRName ) );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.MsgCtrlKey ( var message : TWMCtrlDown ) ;
begin

   ExtHoldObj.SetCtrlKey( TCtrlState( message.Action ) );

end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.FillComponents;
begin
   ExtHoldObj.FillComponents
end ;

// -----------------------------------------------------------------------------

procedure TExtQRBand.MsgCtrlAlign( var Message : TWMCtrlAlign ) ;
begin
   ExtHoldObj.AlignTo( TAlign( Message.Action ) );
end ;

// -----------------------------------------------------------------------------


procedure TExtQRBand.WMPaint(var Message: TWMPaint);
begin
   inherited ;
   ExtHoldObj.QRRepaint ;
end ;


end.
