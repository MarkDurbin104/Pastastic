unit ExtQRCommon;

interface

uses
   ExtRepConst,
   SysUtils,

   Menus,
   InspectorFU,
   CompInspector,
   quickrpt,
   Messages,
   Classes,
   Graphics,
   Windows,
   Controls ;

const
   ffBounds = 5 ;
type

   ExtStatus = ( esMove, esResize, esOverLeft, esOverRight, esOverTop, esOverBottom  );
   ExtStatusSet = Set of ExtStatus ;

   TExtQRCommon = class( TObject )
      LblStatus : ExtStatusSet ;
      FPointSetX : integer ;
      FPointSetY : integer ;
      FActionMenu: TPopupMenu ;
      FCooDisp   : TSetCoordiantes ;

      procedure CreatePopUpMenu ;
      procedure SetCursorOver ;
      //procedure ResizeBox( Canvas : TCanvas );
      procedure QRCommResize( X, Y : integer ) ;
      procedure QRCommMove( X, Y : integer ) ;
      procedure QRCommMoveToLeft( X : integer ) ;
      procedure QRCommMoveToTop( Y : integer ) ;
      procedure AddCoordinates ;
      procedure ShowActionMenu( X, Y : integer ) ;
      procedure OnClickProperties( Sender : TObject );
      procedure OnClickDelete( Sender : TObject );
      procedure OnClickAlignLeft( Sender : TObject ) ;
      procedure OnClickAlignRight( Sender : TObject );
      procedure OnClickAlignTop( Sender : TObject );
      procedure OnClickAlignBottom( Sender : TObject );


   public
      // ParentCtrl : TQRPrintable ;
      ParentCtrl : TCustomControl ; //QRPrintable ;
      InspectorForm : TInspectorForm ;
      MinSize : integer ;

      procedure AttachCtrl ;

      procedure LButtonDown (var Message: TWMLButtonDown);
      procedure RButtonDown (var Message: TWMRButtonDown);
      procedure LButtonUp   (var Message: TWMLButtonUp);
      procedure RButtonUp   (var Message: TWMRButtonUp);
      procedure LButtonDblClk(var Message: TWMLButtonDblClk);
      property  CooDisp : TSetCoordiantes read FCooDisp write FCooDisp ;

      procedure QRMouseMove(X,Y: Integer);

      procedure DataChange( ComField, Value : String ) ;
      Constructor Create ;
      Destructor Destroy ; override ;
   end ;

implementation

//uses

// -----------------------------------------------------------------------------

constructor TExtQRCommon.Create ;
begin
   inherited Create ;

   FPointSetX := 0 ;
   FPointSetY := 0 ;

   CreatePopUpMenu ;
   //Compressor:=TCompressor.Create;
   //CompBitmapStr:=Compressor.CreateStringFromBitmap(QRImage1.Picture.Bitmap);
   //Compressor.Free;


end ;
// -----------------------------------------------------------------------------
Destructor TExtQRCommon.Destroy ;
begin
   FActionMenu.Free ;
   inherited ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.QRMouseMove( X, Y : Integer);
begin

   if esResize in LblStatus then
   begin
      QRCommResize( X, Y );
      ParentCtrl.Invalidate ;
   end
   else
      if esMove in LblStatus then
         QRCommMove( X, Y )
      else
      begin

         LblStatus := LblStatus - [esOverLeft, esOverRight, esOverTop, esOverBottom] ;

         if X <= ffBounds then
         begin
            if coLeft in CooDisp then
               Include( LblStatus, esOverLeft ) ;
         end
         else
            if X >= ( ParentCtrl.Width - ffBounds ) then
               if coWidth in CooDisp then
                  Include(  LblStatus, esOverRight ) ;

         if Y <= ffBounds then
         begin
            if coTop in CooDisp then
               Include(  LblStatus, esOverTop ) ;
         end
         else
            if Y >= ( ParentCtrl.Height- ffBounds ) then
               if coHeight in CooDisp then
                  Include(  LblStatus, esOverBottom );

         SetCursorOver ;

      end ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.SetCursorOver ;
var
   SetCur : boolean ;
   OverRight, OverLeft, OverTop, OverBottom : boolean ;
begin

   OverTop     := esOverTop    in LblStatus ;
   OverBottom  := esOverBottom in LblStatus ;
   OverLeft    := esOverLeft   in LblStatus ;
   OverRight   := esOverRight  in LblStatus ;

   if LBLStatus = [] then
   begin
      ParentCtrl.Cursor := crArrow ;
      SetCur := TRUE ;
   end
   else
      SetCur := FALSE ;


   if ( OverTop or OverBottom ) and not ( OverRight or OverLeft ) and not SetCur then
   begin
      ParentCtrl.Cursor := crSizeNS ;
      SetCur := TRUE ;
   end ;

   if ( OverRight or OverLeft ) and not ( OverTop or OverBottom ) and not SetCur then
   begin
      ParentCtrl.Cursor := crSizeWE ;
      SetCur := TRUE ;
   end ;


   if not SetCur then
   begin

      if OverTop then
         if OverRight then
            ParentCtrl.Cursor := crSizeNESW
         else
            ParentCtrl.Cursor := crSizeNWSE ;

      if OverBottom then
         if OverRight then
            ParentCtrl.Cursor := crSizeNWSE
         else
            ParentCtrl.Cursor := crSizeNESW ;

   end ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.LButtonDown(var Message: TWMLButtonDown);
begin


   if ( Message.XPos <> 0 ) and ( Message.YPos <> 0 )then
   begin

      inherited ;

      if LblStatus  * [ esOverLeft, esOverRight, esOverTop, esOverBottom ] = [] then
         Include( LblStatus, esMove )
      else
         Include( LblStatus, esResize ) ;

      FPointSetX := Message.XPos ;
      FPointSetY := Message.YPos ;

   end ;



end;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.RButtonDown(var Message: TWMRButtonDown);
begin
   inherited ;
   AddCoordinates ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.LButtonUp   (var Message: TWMLButtonUp);
begin


   if ( Message.XPos <> 0 ) and ( Message.YPos <> 0 )then
   begin

      inherited ;

      LblStatus := LblStatus - [ esMove, esResize ] ;
      AddCoordinates ;
      //ParentCtrl.ParentReport.Refresh ;
      ParentCtrl.Parent.Refresh ;
   end ;

   AttachCtrl ;



end ;

// -----------------------------------------------------------------------------


procedure TExtQRCommon.RButtonUp   (var Message: TWMRButtonUp);
begin
   AddCoordinates ;
   //ClientToScreen( ParentCtrl.Handle, pt );

   // it not a subgroup
   if ParentCtrl.Parent.Parent.parent = nil then
      ShowActionMenu( ParentCtrl.Parent.Parent.Left+ParentCtrl.Parent.Left + ParentCtrl.Left+ Message.XPos ,
                      ParentCtrl.Parent.Parent.Top +ParentCtrl.Parent.Top  + ParentCtrl.Top + Message.YPos )
   else
      ShowActionMenu( ParentCtrl.Parent.Parent.Parent.Left+ParentCtrl.Parent.Parent.Left + ParentCtrl.Left+ Message.XPos ,
                      ParentCtrl.Parent.Parent.Parent.Top +ParentCtrl.Parent.Parent.Top  + ParentCtrl.Parent.Top+ ParentCtrl.Top + Message.YPos );




   inherited ;
end ;
// -----------------------------------------------------------------------------
procedure TExtQRCommon.LButtonDblClk(var Message: TWMLButtonDblClk);
begin
   inherited ;
   AddCoordinates ;
   OnClickProperties( nil );
end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.QRCommResize( X, Y : integer ) ;
begin

   // Resize Width -------------------------------------------------------------
   if (esOverLeft in LblStatus) or
      (( esOverRight in LblStatus ) and (X < 0 )) then
      begin
         if (ParentCtrl.Left+X) > 1 then
         begin
            ParentCtrl.Left := ParentCtrl.Left + X ;

            if X < 0 then
               ParentCtrl.Width := ParentCtrl.Width + Abs( X )
            else
               ParentCtrl.Width := ParentCtrl.Width - X ;
         end ;
      end
      else
         if esOverRight in LblStatus then
            ParentCtrl.Width := X;

   // Resize Height ------------------------------------------------------------
   if ( esOverTop in LblStatus ) or
      (( esOverBottom in LblStatus ) and (Y < 0 )) then
   begin
      // Needs to move the top because the bottom value is less than the top value.
      if coTop in CooDisp then
         if (ParentCtrl.Top+Y) > 1 then
         begin
            ParentCtrl.Top := ParentCtrl.Top + Y ;
            if Y < 0 then
               ParentCtrl.Height := ParentCtrl.Height + Abs( Y )
            else
               ParentCtrl.Height := ParentCtrl.Height - Y ;

      end ;
   end
   else
      if esOverBottom in LblStatus then
         ParentCtrl.Height  := Y;


   if ParentCtrl.Width < MinSize then
      ParentCtrl.Width := MinSize ;

   if ParentCtrl.Height < MinSize then
      ParentCtrl.Height := MinSize ;

   ParentCtrl.Update ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.QRCommMove( X, Y : integer ) ;
begin

   QRCommMoveToLeft( ParentCtrl.Left + X - FPointSetX );
   QRCommMoveToTop( ParentCtrl.Top + Y - FPointSetY );
   ParentCtrl.Update ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.QRCommMoveToLeft( X : integer ) ;
begin

   if coLeft in CooDisp then
      if ( X > 1) and (( X+ParentCtrl.Width) < ParentCtrl.Parent.Width) then
         ParentCtrl.Left := X ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.QRCommMoveToTop( Y : integer ) ;
begin

   if coTop in CooDisp then
      if ( Y > 1 ) and (( Y+ParentCtrl.Height) < ParentCtrl.Parent.Height)then
         ParentCtrl.Top := Y ;


end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.DataChange( ComField, Value : String ) ;
begin

   if (ComField = 'Left') and (Value <> '') then
      QRCommMoveToLeft( StrToInt( Value ) )
   else if (ComField = 'Top') and (Value <> '') then
      QRCommMoveToTop( StrToInt( Value ) )
   else if (ComField = 'Width') and (Value <> '') then
   begin
      if StrToInt( Value ) >= MinSize then
         ParentCtrl.Width := StrToInt( Value ) ;

   end
   else if (ComField = 'Height') and (Value <> '') then
      if StrToInt( Value ) >= MinSize then
      begin
         ParentCtrl.Height := StrToInt( Value );
      end ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.AddCoordinates ;
begin

   with ParentCtrl do
   begin
      if coLeft in CooDisp then
         InspectorForm.Inspector.Add('Left',itInteger, IntToStr( Left ));
      if coTop in CooDisp then
         InspectorForm.Inspector.Add('Top',itInteger, IntToStr( Top ) );
      if coWidth in CooDisp then
         InspectorForm.Inspector.Add('Width',itInteger, IntToStr( Width ));
      if coHeight in CooDisp then
         InspectorForm.Inspector.Add('Height',itInteger, IntToStr( Height ));
   end ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.ShowActionMenu( X, Y : integer ) ;
begin
   FActionMenu.Popup( X, Y );
end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.OnClickProperties( Sender : TObject );
begin
   InspectorForm.Show ;
end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.OnClickDelete( Sender : TObject );
begin

   PostMessage( ParentCtrl.Parent.handle, WM_CRP_CTRLDELETE, LongInt( Pchar(ParentCtrl.Name) ), 0 );

end ;

// -----------------------------------------------------------------------------
procedure TExtQRCommon.OnClickAlignLeft( Sender : TObject );
begin
   PostMessage( ParentCtrl.Parent.handle, WM_CRP_CTRLALIGN, Word( Ord(alLeft)), 0 );
end ;
// -----------------------------------------------------------------------------
procedure TExtQRCommon.OnClickAlignRight( Sender : TObject );
begin
   PostMessage( ParentCtrl.Parent.handle, WM_CRP_CTRLALIGN, Word(Ord( alRight )), 0 );
end ;
// -----------------------------------------------------------------------------
procedure TExtQRCommon.OnClickAlignTop( Sender : TObject );
begin
   PostMessage( ParentCtrl.Parent.handle, WM_CRP_CTRLALIGN, Ord( alTop), 0 );
end ;
// -----------------------------------------------------------------------------
procedure TExtQRCommon.OnClickAlignBottom( Sender : TObject );
begin
   PostMessage( ParentCtrl.Parent.handle, WM_CRP_CTRLALIGN, Ord( alBottom ), 0 );
end ;
// -----------------------------------------------------------------------------
procedure TExtQRCommon.CreatePopUpMenu ;
var
   MItem : TMenuItem ;
   MItem2 : TMenuItem ;
begin

   FActionMenu := TPopupMenu.Create( nil );

   MItem := TMenuItem.Create( FActionMenu ) ;
   MItem.Caption := 'Properties' ;
   MItem.OnClick := OnClickProperties ;
   FActionMenu.Items.Add( MItem ) ;

   MItem := TMenuItem.Create( FActionMenu ) ;
   MItem.Caption := 'Delete' ;
   MItem.OnClick := OnClickDelete ;
   FActionMenu.Items.Add( MItem ) ;

   MItem := TMenuItem.Create( FActionMenu ) ;
   MItem.Caption := 'Align' ;

   MItem2 := TMenuItem.Create( nil );
   MItem2.Caption := 'Left';
   MItem2.OnClick := OnClickAlignLeft ;
   MItem.Add( MItem2 );

   MItem2 := TMenuItem.Create( nil );
   MItem2.Caption := 'Right';
   MItem2.OnClick := OnClickAlignRight ;
   MItem.Add( MItem2 );

   MItem2 := TMenuItem.Create( nil );
   MItem2.Caption := 'Top';
   MItem2.OnClick := OnClickAlignTop ;
   MItem.Add( MItem2 );

   MItem2 := TMenuItem.Create( nil );
   MItem2.Caption := 'Bottom';
   MItem2.OnClick := OnClickAlignBottom ;
   MItem.Add( MItem2 );

   FActionMenu.Items.Add( MItem ) ;

end ;

// -----------------------------------------------------------------------------

procedure TExtQRCommon.AttachCtrl ;
begin
   PostMessage( ParentCtrl.Parent.handle, WM_CRP_CTRLCLICK, LongInt( Pchar(ParentCtrl.Name) ), 0 );
end ;

end.
