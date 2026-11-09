unit ExtQuickRepAU;

interface

uses
   ExtHoldObj,
   ExtRepConst,
   Dialogs,
   Forms,
   PaleteFU,
   InspectorFU,
   SysUtils,
   Classes,
   Messages,
   ComCtrls,
   Controls,
   Graphics,
   Counter,
   ExtQRLabelAU,
   ExtQRShapeAU,
   ExtQRImageAU,
   ExtQRGroupAU,
   ExtQRBandAU,
   ExtQRDBText,
   quickrpt, qrprntr, Qrctrls,
   CompIDS,
   windows,
   LnkFieldFU ;

type

   THackWinHold = class( TCustomControl )
   private
   public
      ExtHoldObj :  TExtHoldObj ;
   end ;

   TExtQuickRep = class( TQuickRep )
   private

      FInspectorForm : TInspectorForm ;
      FPanelForm : TPanelForm ;
      FNumComponent: Integer ;
      FCounter : TCounter ;
      FLinkFieldForm : TLinkFieldForm ;

      procedure WMLButtonDown    (var Message: TWMLButtonDown);   message WM_LBUTTONDOWN;
      procedure WMLButtonUp      (var Message: TWMLButtonUp);     message WM_LBUTTONUP;
      procedure MsgCtrlDelete( var Message : TWMCtrlDelete ) ; message WM_CRP_CTRLDELETE ;
      procedure MsgZoom( var Message : TWMQRZoom ) ;           message WM_CRP_ZOOM ;
      procedure MsgDocument( var Message : TWMQRDocument )  ;   message WM_CRP_DOCUMENT ;
      procedure MsgCtrlClick( var Message : TWMCtrlClick )  ;  message WM_CRP_CTRLCLICK ;
      procedure MsgCtrlKey ( var message : TWMCtrlDown )    ; message WM_CRP_CTRLKEYDOWN ;
      procedure MsgCtrlAlign( var Message : TWMCtrlAlign ) ; message WM_CRP_CTRLALIGN ;
      procedure MsgCtrlShow( var Message : TWMCtrlShow ) ; message WM_CRP_CTRLSHOW ;

      procedure OpenQRFile ;
      function  CleanDocument : boolean ;
      procedure BuildDocument( CtrlLst : TWinControl; Spc : String; SL : TStringList; ComponetList : String );
      procedure SaveQRFile ;
      procedure QRPreview ;

   public
      ExtHoldObj : TExtHoldObj;

      procedure FillComponents;
      procedure InitSQL ;
      property  PanelForm : TPanelForm read FPanelForm ;
      property  LinkFieldForm : TLinkFieldForm  read FLinkFieldForm ;
      constructor Create( AOwner : TComponent ) ; override ;
      destructor  Destroy ; override ;

   end ;
implementation

// -----------------------------------------------------------------------------

constructor TExtQuickRep.Create( AOwner : TComponent ) ;
begin

   inherited Create( AOwner );
   ExtHoldObj := TExtHoldObj.Create( nil ) ;
   ExtHoldObj.OwnerCtrl  := Self ;
   ExtHoldObj.ParentCtrl := Self ;


   OnDragDrop  := ExtHoldObj.QROnDragDrop  ;
   OnDragOver  := ExtHoldObj.QROnDragOver  ;
   OnMouseMove := ExtHoldObj.QROnMouseMove ;

   FInspectorForm := TInspectorForm.Create( nil ) ;
   ExtHoldObj.InspectorForm :=  FInspectorForm ;

   FLinkFieldForm := TLinkFieldForm.Create( nil );
   FLinkFieldForm.Show ;

   FPanelForm     := TPanelForm.Create( nil ) ;
   FPanelForm.ParentCtrl := Self ;
   FPanelForm.Left  := 1 ;
   FPanelForm.Top := 1 ;


   FPanelForm.Visible := TRUE  ;
   FNumComponent := 0 ;
   FCounter := TCounter.Create ;
   ExtHoldObj.Counter := FCounter ;



end ;

// -----------------------------------------------------------------------------

destructor TExtQuickRep.Destroy ;
begin

   ExtHoldObj.Free ;


   FInspectorForm.Free ;
   FPanelForm.ParentCtrl := nil ;
   FPanelForm.Free ;
   ExtHoldObj.ParentCtrl := nil ;
   ExtHoldObj.Counter := nil ;
   FCounter.Free;
   FLinkFieldForm.Free ;

   inherited destroy ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.MsgCtrlDelete( var Message : TWMCtrlDelete ) ;
begin
   ExtHoldObj.DeleteCtrl( String( Message.QRName ) );
   Refresh ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.MsgZoom( var Message : TWMQRZoom ) ;
begin

   try
      if ( Zoom <> Message.Zoom ) and ( Message.Zoom > 5 ) and (Message.Zoom <= 300) then
         Zoom := Message.Zoom
   except
   end ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.MsgDocument( var Message : TWMQRDocument ) ;
begin

   case Message.Action of
   ffNewDocument  : CleanDocument ;
   ffOpenFile     : OpenQRFile ;
   ffSaveFile     : SaveQRFile ;
   ffPreview      : QRPreview ;
   end ;

end ;

// -----------------------------------------------------------------------------

//procedure TExtQuickRep.MsgCtrlMark( var Message : TWMQRMark ) ;
//begin
//
//   FCtrlState := TCtrlState( Message.Action ) ;
//
//end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.QRPreview ;
begin
   Preview ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.OpenQRFile ;
var
//   MemStreamBin : TMemoryStream ;
//   FileStreamText : TFileStream ;
   SL : TStringList ;
   OpenDialog : TOpenDialog ;
begin

   OpenDialog := TSaveDialog.Create( nil );
   if OpenDialog.Execute then
   begin


      if CleanDocument then
      begin
         Application.ProcessMessages ;
         SL := TStringList.Create ;
        // FileStreamText := TFileStream.Create( OpenDialog.FileName, fmOpenRead  );
        // FileStreamText.Position := 0 ;

         //MemStreamBin  := TMemoryStream.Create ;
         try
            SL.LoadFromFile( OpenDialog.FileName ) ;
         //   ObjectTextToBinary( FileStreamText, MemStreamBin );
         //   MemStreamBin.Position := 0;
         //   MemStreamBin.ReadComponent( Self  );
            IDSToComponent(SL.Text, Self );
            FillComponents ;
         finally
          //  MemStreamBin.Free ;
           // FileStreamText.Free ;
            SL.Free ;
         end ;

      end ;

      OpenDialog.Free ;


   end ;

end ;


// procedure TExtQuickRep.OpenQRFile ;
// var
//    MemStreamBin : TMemoryStream ;
//    FileStreamText : TFileStream ;
//    OpenDialog : TOpenDialog ;
//    I : integer ;
// begin
// 
//    OpenDialog := TSaveDialog.Create( nil );
//    if OpenDialog.Execute then
//    begin
// 
// 
//       if CleanDocument then
//       begin
//          Application.ProcessMessages ;
// 
//          FileStreamText := TFileStream.Create( OpenDialog.FileName, fmOpenRead  );
//          FileStreamText.Position := 0 ;
// 
//          MemStreamBin  := TMemoryStream.Create ;
//          try
//             ObjectTextToBinary( FileStreamText, MemStreamBin );
//             MemStreamBin.Position := 0;
//             MemStreamBin.ReadComponent( Self  );
//             FillComponents ;
//          finally
//             MemStreamBin.Free ;
//             FileStreamText.Free ;
//          end ;
// 
//       end ;
// 
//       OpenDialog.Free ;
// 
// 
//    end ;
// 
// end ;




// -----------------------------------------------------------------------------

function TExtQuickRep.CleanDocument : boolean ;
var
   MsgAns : Word ;
begin

   result := FALSE ;
   if ControlCount >= 0 then
   begin
      MsgAns:= MessageDlg(' Save changes ? ',mtConfirmation	, [mbYes, mbNo ,mbCancel], 0 ) ;

      case MsgAns of
      mrYes    :
         begin
            SaveQRFile ;
            ExtHoldObj.DeleteAllCtrl ;
            result := TRUE ;
         end ;
      mrCancel : Exit ;
      mrNo     :
         begin

            if MessageDlg(' Are you sure, changes will be lose ',mtConfirmation	, [mbOk, mbCancel], 0 ) = mrOk then
            begin
               ExtHoldObj.DeleteAllCtrl ;
               result := TRUE ;
            end ;

         end ;
      end ;

   end ;
   FNumComponent := 0 ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.SaveQRFile ;
 var
   SL : TStringList ;
//   MemStreamBin, MemStreamText : TMemoryStream ;
   SaveDialog : TSaveDialog ;

 begin
   Application.ProcessMessages ;

   SaveDialog := TSaveDialog.Create( nil );
   if SaveDialog.Execute then
   begin

//      MemStreamBin := TMemoryStream.Create ;
//      MemStreamText := TMemoryStream.Create ;
      SL := TStringList.Create ;
      try
//         MemStreamBin.WriteComponent( Self ); //Self );
//         MemStreamBin.Position := 0;
//        ObjectBinaryToText( MemStreamBin, MemStreamText );
//         MemStreamText.Position := 0;

//         SL.LoadFromStream( MemStreamText );
         SL.Text := ComponentToIDS( Self ) ;
         SL.SaveToFile( SaveDialog.FileName );


      finally
//         MemStreamBin.Free ;
//         MemStreamText.Free ;
         SL.Free ;
      end ;

      SaveDialog.Free ;

   end ;

end ;



//  procedure TExtQuickRep.SaveQRFile ;
//  var
//    SL : TStringList ;
//    MemStreamBin, MemStreamText : TMemoryStream ;
//    SaveDialog : TSaveDialog ;
// 
//  begin
//    Application.ProcessMessages ;
// 
//    SaveDialog := TSaveDialog.Create( nil );
//    if SaveDialog.Execute then
//    begin
// 
//       MemStreamBin := TMemoryStream.Create ;
//       MemStreamText := TMemoryStream.Create ;
//       SL := TStringList.Create ;
//       try
//          MemStreamBin.WriteComponent( Self ); //Self );
//          MemStreamBin.Position := 0;
//          ObjectBinaryToText( MemStreamBin, MemStreamText );
//          MemStreamText.Position := 0;
//
//          SL.LoadFromStream( MemStreamText );
//          SL.SaveToFile( SaveDialog.FileName );
// 
//       finally
//          MemStreamBin.Free ;
//          MemStreamText.Free ;
//          SL.Free ;
//       end ;
// 
//       SaveDialog.Free ;
// 
//    end ;
// 
// end ;



// -----------------------------------------------------------------------------
procedure  TExtQuickRep.BuildDocument( CtrlLst : TWinControl; Spc : String; SL : TStringList; ComponetList : String );
var
   I : integer ;
begin

   for I := 0 to CtrlLst.ControlCount-1 do
   begin

      if Pos( CtrlLst.Controls[ i ].Name, ComponetList ) > 0  then
      begin

         if CtrlLst.Controls[ i ].ClassName = 'TExtQuickRep' then
            SL.Add( ffReport + ' {')
         else if CtrlLst.Controls[ i ].ClassName = 'TExtQRBand' then
            SL.Add( Spc + ffBand   + ' {')
         else if CtrlLst.Controls[ i ].ClassName = 'TExtQRGroup' then
            SL.Add( Spc + ffGroup  + ' {')
         else if CtrlLst.Controls[ i ].ClassName = 'TExtQRDBText' then
         begin
            SL.Add('');
            SL.Add( Spc + ffField  + ' {');
         end
         else if CtrlLst.Controls[ i ].ClassName = 'TExtQRLabel' then
         begin
            SL.Add('');
            SL.Add( Spc + ffLabel  + ' {');
         end
         else if CtrlLst.Controls[ i ].ClassName = 'TExtQRImage' then
         begin
            SL.Add('');
            SL.Add( Spc + ffImage  + ' {')
         end
         else if CtrlLst.Controls[ i ].ClassName = 'TExtQRShape' then
         begin
            SL.Add('');
            SL.Add( Spc + ffShape  + ' {') ;
         end;


         SL.Add( Spc + ffTab + ffFont+' {' );
         SL.Add( Spc + ffTab + ffTab+ ffFontName+'  "'+ TExtQRLabel(CtrlLst.Controls[ i ] ).Font.Name +'"' );
         SL.Add( Spc + ffTab + ffTab+ ffFontSize+'  "'+ IntToStr( TExtQRLabel(CtrlLst.Controls[ i ] ).Font.Size )+'"' );
         SL.Add( Spc + ffTab + ffTab+ ffFontStyle+' "'+ TExtQRLabel(CtrlLst.Controls[ i ] ).FontStyle +'"' );
         SL.Add( Spc + ffTab + '}' );

         if ( CtrlLst.Controls[ i ].ClassName = 'TExtQRGroup' )  then
         begin
            SL.Add( Spc+ ffTab+ffHeight+' "'+ IntToStr( TExtQRGroup( CtrlLst.Controls[ i ] ).Height) +'"');
            BuildDocument( TWinControl( CtrlLst.Controls[ i ] ), Spc+ffTab, SL, TExtQRGroup( CtrlLst.Controls[ i ]).ExtHoldObj.CtrlList ) ;
         end
         else
         if  ( CtrlLst.Controls[ i ].ClassName = 'TExtQRBand')   then
         begin
            SL.Add( Spc+ ffTab+ffHeight+' "'+ IntToStr( TExtQRBand( CtrlLst.Controls[ i ] ).Height) +'"');
            BuildDocument( TWinControl( CtrlLst.Controls[ i ] ), Spc+ffTab, SL, TExtQRBand( CtrlLst.Controls[ i ]).ExtHoldObj.CtrlList ) ;
         end
         else
         if (CtrlLst.Controls[ i ].ClassName = 'TExtQuickRep')then
         begin
            SL.Add(Spc + ffTab +ffLeft+'   "'+ IntToStr( TQRCustomLabel( CtrlLst.Controls[ i ] ).Left ) + '"' );
            SL.Add(Spc + ffTab +ffWidth+'  "'+ IntToStr( TQRCustomLabel( CtrlLst.Controls[ i ] ).Width) + '"' );
            SL.Add(Spc + ffTab +ffHeight+' "'+ IntToStr( TQRCustomLabel( CtrlLst.Controls[ i ] ).Height)+ '"' );
            BuildDocument( TWinControl( CtrlLst.Controls[ i ]) , Spc+ffTab, SL, TExtQuickRep( CtrlLst.Controls[ i ]).ExtHoldObj.CtrlList ) ;
         end
         else
         begin

            if ( CtrlLst.Controls[ i ].ClassName = 'TExtQRDBText' ) then
            begin
               SL.Add( Spc + ffTab +ffID+'   "'       + CtrlLst.Controls[ i ].ClassName +'"');
               SL.Add( Spc + ffTab +ffAlignment+'   "'+ TExtQRDBText( CtrlLst.Controls[ i ]).AlignmentStr +'"');
            end ;

            if ( CtrlLst.Controls[ i ].ClassName = 'TExtQRLabel' ) then
            begin
               SL.Add( Spc + ffTab +ffCaption+'   "'+ TExtQRLabel(CtrlLst.Controls[ i ] ).Caption +'"' );
            end;

            if CtrlLst.Controls[ i ].ClassName = 'TExtQRImage' then
            begin
               SL.Add( Spc + ffTab +ffBMPFile+'   "'+ TExtQRImage(CtrlLst.Controls[ i ] ).BmpFile +'"' );
            end ;


            if CtrlLst.Controls[ i ].ClassName = 'TExtQRShape' then
            begin
               SL.Add( Spc + ffTab +ffShape+' "'+ TExtQRShape(CtrlLst.Controls[ i ] ).ShapeStr + '"');
            end ;
            //if Controls[ i ].ClassName = 'TExtImage' then

            SL.Add( Spc + ffTab +ffLeft+'   "'+ IntToStr( TQRCustomLabel( CtrlLst.Controls[ i ] ).Left )  +'"' );
            SL.Add( Spc + ffTab +ffTop+'    "'+ IntToStr( TQRCustomLabel( CtrlLst.Controls[ i ] ).Top  )  +'"' );
            SL.Add( Spc + ffTab +ffWidth+'  "'+ IntToStr( TQRCustomLabel( CtrlLst.Controls[ i ] ).Width)  +'"' );
            SL.Add( Spc + ffTab +ffHeight+' "'+ IntToStr( TQRCustomLabel( CtrlLst.Controls[ i ] ).Height) +'"' );

         end ;

         SL.Add( Spc+ '}');
      end ;

   end ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.InitSQL ;
begin

   ExtHoldObj.DataSet := DataSet ;
   DataSet.Open ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.WMLButtonDown(var Message: TWMLButtonDown);
begin

   inherited ;
   ExtHoldObj.LButtonDown( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.WMLButtonUp   (var Message: TWMLButtonUp);
begin

   inherited ;
   ExtHoldObj.LButtonUp( Message );

end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.MsgCtrlClick( var Message : TWMCtrlClick ) ;
begin

   ExtHoldObj.AddControlToGroup( String( Message.QRName ) );

end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.MsgCtrlKey ( var message : TWMCtrlDown ) ;
begin

   ExtHoldObj.SetCtrlKey( TCtrlState( message.Action ) );

end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.FillComponents;
begin
   ExtHoldObj.FillComponents
end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.MsgCtrlAlign( var Message : TWMCtrlAlign ) ;
begin
   ExtHoldObj.AlignTo( TAlign( Message.Action ) );
end ;

// -----------------------------------------------------------------------------

procedure TExtQuickRep.MsgCtrlShow( var Message : TWMCtrlShow );
var
   ExtQR : Tcomponent ;
   Msg: TWMLButtonDblClk;
begin

   ExtQR := FindComponent( Message.QRName ) ;
   if ExtQR <> nil then
   begin
      Msg.XPos := 0 ;
      Msg.YPos := 0 ;
      Refresh;
      if ( ExtQR is  TExtQRImage ) then
      begin
         TExtQRImage( ExtQR ).Attach ;
         TExtQRImage( ExtQR ).WMLButtonDblClk( Msg ) ;
      end
      else
      if ( ExtQR is TExtQRLabel ) then
      begin
         TExtQRLabel( ExtQR ).Attach ;
         TExtQRLabel( ExtQR ).WMLButtonDblClk( Msg ) ;
      end
      else
      if ( ExtQR is TExtQRShape ) then
      begin
         TExtQRShape( ExtQR ).Attach ;
         TExtQRShape( ExtQR ).WMLButtonDblClk( Msg ) ;
      end
      else
      if ( ExtQR is TExtQRDBText ) then
      begin
         TExtQRDBText( ExtQR ).Attach ; //WMLButtonUp( Msg ) ;
         TExtQRDBText( ExtQR ).WMLButtonDblClk( Msg ) ;
      end ;


   end ;

end ;



end.
