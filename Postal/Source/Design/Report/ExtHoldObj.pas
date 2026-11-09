unit ExtHoldObj;

interface

uses
   Handles,
   DB,
   InspectorFU,
   ExtRepConst,
   SysUtils,
   Windows,
   Controls,
   Menus,
   CompInspector,
   ComCtrls,
   quickrpt,
   Messages,
   Classes,
   Graphics,
   Counter,
   ExtQRDBText,
   ExtQRLabelAU,
   ExtQRShapeAU,
   ExtQRImageAU,
   Dialogs ;


const
   ffBounds = 5 ;
type

   THackCutomCtrl = class ( TCustomControl )
   private
   public
      property Canvas;
   end ;

   TExtHoldObj = class( TWinControl )
   private
      FCtrlList : TStringList ;
      FCtrlState : TCtrlState ;
      FInspectorForm : TInspectorForm ;
      FCounter : TCounter ;
      FDataSet   : TDataSet ;
      XOrig, YOrig  : integer ;
      FGetXYValues : boolean ;
      FStretchhandle : TStretchhandle ;
      FParentCtrl : TCustomControl ;
      FOwnerCtrl  : TComponent ;
      FOldRect    : TRect ;

      procedure SetParentCtrl( PtCtrl : TCustomControl ) ;
      function  GetXYControls( XOrig, YOrig, XEnd, YEnd : integer ) : String ;
      procedure GroupXYControl( SCtrl : String );
      procedure SendCtrlList ;


   public

      function IsControl( CtrlName : String ) : Boolean ;
      function CtrlList : String ;
      procedure AlignTo( CtrlAlign : TAlign );

      procedure SetCtrlKey ( CtrlKey : TCtrlState ) ;
      procedure QROnDragOver(Sender, Source: TObject; X, Y: Integer;
                               State: TDragState; var Accept: Boolean);
      procedure QROnDragDrop(Sender, Source: TObject; X, Y: Integer);
      procedure QROnMouseMove( Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure QRRepaint ;

      procedure LButtonDown (var Message: TWMLButtonDown);
      procedure LButtonUp (var Message: TWMLButtonUp);

      procedure AddControlToGroup( CtrlName : String );
      procedure DeleteAllCtrl ;
      procedure FreeCtrl( CtrlPos : integer ) ;
      procedure DeleteCtrl( CtrlName : String  ) ;
      procedure FillComponents ;
      procedure AddLabel( Left, Top, Width, Height : integer;  Name, Caption, FontName, FontSize, FontStyle : String  ) ;
      procedure AddDBText( Left, Top, Width, Height : integer; Name, Caption, FontName, FontSize, FontStyle : String  ) ;
      procedure AddShape( Left, Top, Width, Height : integer;  Name, Shape   : String ) ;
      procedure AddImage( Left, Top, Width, Height : integer;  Name, ImageFile: String ) ;
      procedure AddGroup( Name, FontName, FontSize, FontStyle : String ) ;
      procedure AddBand ( Name,FontName, FontSize, FontStyle : String );

      property  DataSet  : TDataSet            read FDataSet       write FDataSet ;
      property  InspectorForm : TInspectorForm read FInspectorForm write FInspectorForm ;
      property  Counter : TCounter             read FCounter       write FCounter ;
      property  ParentCtrl : TCustomControl    read FParentCtrl    write SetParentCtrl ;
      property  OwnerCtrl  : TComponent        read FOwnerCtrl     write FOwnerCtrl  ;
      constructor Create( AOwner : TComponent ) ; override ;
      destructor  Destroy ; override ;

   end ;

implementation

uses
   ExtQRGroupAU, ExtQRBandAU,  ExtQuickRepAU ;
// -----------------------------------------------------------------------------

constructor TExtHoldObj.Create( AOwner : TComponent ) ;
begin

   inherited Create( AOwner );
   FCtrlList := TStringList.Create ;
   XOrig := 0 ;
   YOrig := 0 ;
   FGetXYValues := FALSE ;
   FCtrlState := ffCtrlUp ;

end ;

// -----------------------------------------------------------------------------

destructor TExtHoldObj.Destroy ;
var
   I : integer ;
begin

   for i := 0 to FCtrlList.Count -1 do
   begin
      TCustomControl( FCtrlList.Objects[ i ] ).Parent := nil ;
      TCustomControl( FCtrlList.Objects[ i ] ).Free ;
   end ;

   FCtrlList.Free ;
   FStretchhandle.Free ;

   inherited destroy ;

end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.QROnDragOver(Sender, Source: TObject; X, Y: Integer;
                            State: TDragState; var Accept: Boolean);
begin

   if ( Source.ClassType = TToolButton )then
   begin
      accept := TRUE ;
      // to Avoid any band or group contain any other band or group.
      if Pos( TToolButton( Source ).Name, 'GroupTB,BandTB' ) <> 0 then
         if Pos( FParentCtrl.ClassName, 'TExtQRGroup,TExtQRBand' ) <> 0 then
            accept := FALSE ;
   end
   else
      accept := FALSE ;

end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.QROnDragDrop(Sender, Source: TObject; X, Y: Integer);
begin

   if Source.ClassName = 'TToolButton' then
   begin

      if TToolButton( Source ).Name = 'LabelTB' then
      begin
         FCounter.Add ;
         AddLabel( X, Y,0, 0,
                  'TExtQuickRep' +IntToStr( FCounter.Value ),
                  'TExtQuickRep' +IntToStr( FCounter.Value ),
                  '', '', ''  )
      end
      else
      if TToolButton( Source ).Name = 'DBTextTB' then
      begin
         FCounter.Add ;
         AddDBText( X, Y,0, 0,
                  'TExtQuickRep' +IntToStr( FCounter.Value ),
                  'TExtQuickRep' +IntToStr( FCounter.Value ),
                  '', '', ''  )
      end
      else
      if TToolButton( Source ).Name = 'ShapeTB' then
      begin
         FCounter.Add ;
         AddShape( X, Y, 0, 0, 'TExtQuickRep' +IntToStr( FCounter.Value ), '' )
      end
      else
      if TToolButton( Source ).Name = 'ImageTB' then
      begin
         FCounter.Add ;
         AddImage( X, Y, 0, 0, 'TExtQuickRep' +IntToStr( FCounter.Value ), '' )
      end
      else
      if TToolButton( Source ).Name = 'GroupTB' then
      begin
         FCounter.Add ;
         AddGroup( 'TExtQuickRep' +IntToStr( FCounter.Value ),'', '', '' )
      end
      else
      if TToolButton( Source ).Name = 'BandTB' then
      begin
         FCounter.Add ;
         AddBand( 'TExtQuickRep' +IntToStr( FCounter.Value ),'', '', '' );
      end;

      SendCtrlList ;
      Refresh ;
   end ;
end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.DeleteAllCtrl ;
begin
   while FCtrlList.Count <> 0 do
      FreeCtrl(0) ;
end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.DeleteCtrl( CtrlName : String  ) ;
var
   CtrlPos : integer ;
   CtrlStretchName : String ;
begin


   CtrlPos := FCtrlList.IndexOf( CtrlName );
   if CtrlPos >=0 then
   begin

      if FStretchHandle.IndexOf( TControl( FCtrlList.Objects[ CtrlPos ] ) ) > 0 then
      begin

         while FStretchHandle.ChildCount > 0 do
         begin
            CtrlStretchName := FStretchHandle.Children[ 0 ].Name;
            FStretchHandle.ReleaseChild( FStretchHandle.Children[ 0 ] ) ;
            DeleteCtrl( CtrlStretchName ) ;
         end ;

      end
      else
         FreeCtrl( CtrlPos );

   end ;
   SendCtrlList ;
   TExtQuickRep( FOwnerCtrl ).Refresh ;


end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.FreeCtrl( CtrlPos : integer ) ;
begin
   TCustomControl(  FCtrlList.Objects[ CtrlPos ] ).Parent := nil ;
   FCtrlList.Objects[ CtrlPos ].Free ;
   FCtrlList.Delete( CtrlPos ) ;
   Refresh ;
end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.AddLabel( Left, Top, Width, Height : integer; Name, Caption, FontName, FontSize, FontStyle : String ) ;
var
   ItemQRLabel : TExtQRLabel ;
begin
//d   ItemQRLabel := TExtQRLabel.Create( self ) ;
   ItemQRLabel := TExtQRLabel.Create( FOwnerCtrl );//( FParentCtrl ) ;
   ItemQRLabel.Name     := Name ;
   ItemQRLabel.Caption  := Caption ;
   ItemQRLabel.Parent   := FParentCtrl ;
   ItemQRLabel.Top      := Top  ;
   ItemQRLabel.Left     := Left ;
   //ItemQRLabel.Color    := clSilver ;
   if Width <> 0 then
      ItemQRLabel.Width := Width ;
   if Height <> 0 then
      ItemQRLabel.Height:= Height ;

   if ( FontName <> '' ) then
      ItemQRLabel.Font.Name := FontName ;

   if ( FontSize <> '' ) then
      ItemQRLabel.Font.Size := StrToInt( FontSize );

   ItemQRLabel.FontStyle := FontStyle ;

   ItemQRLabel.AutoSize := FALSE ;

   ItemQRLabel.InspectorForm := FInspectorForm ;

   FCtrlList.AddObject( ItemQRLabel.Name, ItemQRLabel ) ;
end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.AddDBText( Left, Top, Width, Height : integer; Name, Caption, FontName, FontSize, FontStyle : String ) ;
var
   ItemQRDBText : TExtQRDBText ;
begin
//d   ItemQRDBText := TExtQRDBText.Create( self ) ;
   ItemQRDBText := TExtQRDBText.Create( FOwnerCtrl );//( FParentCtrl ) ;
   ItemQRDBText.Name     := Name ;
   ItemQRDBText.Caption  := Caption ;
   ItemQRDBText.Parent   := FParentCtrl ;
   ItemQRDBText.Top      := Top  ;
   ItemQRDBText.Left     := Left ;
   //ItemQRDBText.Color    := clSilver ;
   ItemQRDBText.DataSet  := FDataSet ;
   if Width <> 0 then
      ItemQRDBText.Width := Width ;
   if Height <> 0 then
      ItemQRDBText.Height:= Height ;

   if ( FontName <> '' ) then
      ItemQRDBText.Font.Name := FontName ;

   if ( FontSize <> '' ) then
      ItemQRDBText.Font.Size := StrToInt( FontSize );

   ItemQRDBText.FontStyle := FontStyle ;

   ItemQRDBText.AutoSize := FALSE ;

   ItemQRDBText.InspectorForm := FInspectorForm ;

   FCtrlList.AddObject( ItemQRDBText.Name, ItemQRDBText ) ;
end ;
// -----------------------------------------------------------------------------

procedure TExtHoldObj.AddShape( Left, Top, Width, Height : integer; Name, Shape   : String ) ;
var
   ItemQRShape : TExtQRShape ;
begin

//d  ItemQRShape := TExtQRShape.Create( self ) ;
   ItemQRShape := TExtQRShape.Create( FOwnerCtrl );//( FParentCtrl ) ;
   ItemQRShape.Name     := Name;
   if Shape <> '' then
      ItemQRShape.ShapeStr := Shape ;

   ItemQRShape.Parent   := FParentCtrl;
   ItemQRShape.Top      := Top ;
   ItemQRShape.Left     := Left ;
   if Width <> 0 then
      ItemQRShape.Width := Width ;
   if Height <> 0 then
      ItemQRShape.Height:= Height ;


   ItemQRShape.InspectorForm := FInspectorForm ;

   FCtrlList.AddObject( ItemQRShape.Name, ItemQRShape ) ;

end ;
// -----------------------------------------------------------------------------
procedure TExtHoldObj.AddImage( Left, Top, Width, Height : integer; Name, ImageFile: String ) ;
var
   ItemQRImage : TExtQRImage ;
begin

//d   ItemQRImage := TExtQRImage.Create( self ) ;
   ItemQRImage := TExtQRImage.Create( FOwnerCtrl );//( FParentCtrl ) ;
   ItemQRImage.Name     := Name;
   ItemQRIMage.Parent   := FParentCtrl;
   ItemQRImage.Top      := Top ;
   ItemQRIMage.Left     := Left ;
   if ImageFile <> '' then
   begin
      ItemQRIMage.BmpFile  := ImageFile;
      ItemQRImage.Picture.BitMap.LoadFromFile( ImageFile );
   end
   else
      ItemQRImage.Update ;

   if Width <> 0 then
      ItemQRIMage.Width := Width ;
   if Height <> 0 then
      ItemQRIMage.Height:= Height ;

   ItemQRImage.InspectorForm := FInspectorForm ;

   FCtrlList.AddObject( ItemQRImage.Name, ItemQRImage ) ;


end ;

// -----------------------------------------------------------------------------
procedure TExtHoldObj.AddGroup( Name, FontName, FontSize, FontStyle : String );
var
   ItemQRGroup : TExtQRGroup ;
begin
   ItemQRGroup := TExtQRGroup.Create( FOwnerCtrl );//( FParentCtrl ) ;
   ItemQRGroup.Name     := Name ;
   TExtQuickRep(FParentCtrl).InsertControl(ItemQRGroup);
   ItemQRGroup.Parent := FParentCtrl;
   if ( FontName <> '' ) then
      ItemQRGroup.Font.Name := FontName ;

   if ( FontSize <> '' ) then
      ItemQRGroup.Font.Size := StrToInt( FontSize );

   ItemQRGroup.FontStyle := FontStyle ;

   ItemQRGroup.InspectorForm := FInspectorForm ;
   ItemQRGroup.Counter := FCounter ;
   ItemQRGroup.DataSet := FDataSet ;
   ItemQRGroup.InitSQL ;

   FCtrlList.AddObject( ItemQRGroup.Name, ItemQRGroup ) ;

end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.AddBand( Name, FontName, FontSize, FontStyle : String );
var
   ItemQRBand : TExtQRBand ;
begin

   ItemQRBand := TExtQRBand.Create( FOwnerCtrl );//( FParentCtrl ) ;
   ItemQRBand.Name     := Name;
   TExtQuickRep(FParentCtrl).InsertControl(ItemQRBand);
   ItemQRBand.Parent   := FParentCtrl;
   ItemQRBand.Top      := Top ;
   ItemQRBand.Left     := Left ;
   if ( FontName <> '' ) then
      ItemQRBand.Font.Name := FontName ;

   if ( FontSize <> '' ) then
      ItemQRBand.Font.Size := StrToInt( FontSize );

   ItemQRBand.FontStyle := FontStyle ;

   ItemQRBand.InspectorForm := FInspectorForm ;
   ItemQRBand.Counter := FCounter ;
   ItemQRBand.DataSet := FDataSet ;
   ItemQRBand.InitSQL ;

   FCtrlList.AddObject( ItemQRBand.Name, ItemQRBand ) ;

end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.FillComponents ;
var
   I : integer ;
begin

   for I := 0 to FParentCtrl.ControlCount-1 do
   begin

      if FCtrlList.IndexOf( FParentCtrl.Controls[ i ].Name ) < 0 then
      begin

         if Pos( FParentCtrl.Controls[ i ].ClassName,
                'TExtQRBand,TExtQRGroup,TExtQRDBText,TExtQRLabel,TExtQRShape,TExtQRImage' ) > 0 then
         begin

            FCtrlList.AddObject( FParentCtrl.Controls[ i ].Name, FParentCtrl.Controls[ i ] ) ;
            if FParentCtrl.Controls[ i ].ClassName = 'TExtQRBand' then
            begin
               TExtQRBand(FParentCtrl.Controls[ i ] ).InspectorForm := FInspectorForm ;
               TExtQRBand(FParentCtrl.Controls[ i ] ).FillComponents ;
            end
            else if FParentCtrl.Controls[ i ].ClassName = 'TExtQRGroup' then
            begin
               TExtQRGroup(FParentCtrl.Controls[ i ] ).InspectorForm := FInspectorForm ;
               TExtQRGroup(FParentCtrl.Controls[ i ] ).FillComponents ;
            end 
            else if FParentCtrl.Controls[ i ].ClassName = 'TExtQRDBText' then
               TExtQRDBText(FParentCtrl.Controls[ i ] ).InspectorForm := FInspectorForm
            else if FParentCtrl.Controls[ i ].ClassName = 'TExtQRLabel' then
               TExtQRLabel(FParentCtrl.Controls[ i ] ).InspectorForm := FInspectorForm
            else if FParentCtrl.Controls[ i ].ClassName = 'TExtQRShape' then
               TExtQRShape(FParentCtrl.Controls[ i ] ).InspectorForm := FInspectorForm
            else if FParentCtrl.Controls[ i ].ClassName = 'TExtQRImage' then
               TExtQRImage(FParentCtrl.Controls[ i ] ).InspectorForm := FInspectorForm ;
         end ;

      end ;
   end ;


end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.QROnMouseMove( Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   XDif, YDif : integer ;
   X1,X2,Y1,Y2 :integer ;
   ScreenDC: HDC;
   PtA, PtB: TPoint;
   NewRect : TRect ;
begin

//   if ( ssCtrl in Shift ) and
   if ( ssLeft in Shift )	then
   begin

      if FGetXYValues then
      begin
         FGetXYValues := FALSE ;
         XOrig := X ;
         YOrig := Y ;
      end ;

      XDif := X - XOrig ;
      YDif := Y - YOrig ;

      if ( XDif + XOrig > 0 ) and
         ( XDif + XOrig < FParentCtrl.Width-2 ) and
         ( YDif + YOrig > 0 ) and
         ( YDif + YOrig < FParentCtrl.Height-2 ) then
      begin

         if XOrig < XOrig+XDif+2 then
         begin
            X1 := XOrig        +2;
            X2 := XOrig+XDif+2 -2;
         end
         else
         begin
            X1 := XOrig+XDif+2 -2;
            X2 := XOrig        +2;
         end ;

         if YOrig < YOrig+YDif+2 then
         begin
            Y1 := YOrig        +2;
            Y2 := YOrig+YDif+2 -2;
         end
         else
         begin
            Y1 := YOrig+YDif+2 -2;
            Y2 := YOrig        +2;
         end ;

         ScreenDC := GetDC(0);

         if (FOldRect.Left    <> 0) or
            (FOldRect.Top     <> 0) or
            (FOldRect.Right   <> 0) or
            (FOldRect.Bottom  <> 0) then
         begin
            DrawFocusRect( ScreenDC,  FOldRect );
         end ;

         PtA := TWinControl( FParentCtrl).ClientToScreen(Point(X1, Y1));
         PtB := TWinControl( FParentCtrl).ClientToScreen(Point(X2, Y2));

         NewRect := Rect( PtA.X,PtA.Y,PtB.X,PtB.Y ) ;
         DrawFocusRect( ScreenDC,  NewRect  );
         FOldRect := NewRect ;

         ReleaseDC(0, ScreenDC);
      end ;

   end ;

end;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.SetParentCtrl( PtCtrl : TCustomControl  ) ;
begin
   FParentCtrl := PtCtrl ;
   if FStretchHandle = nil then
   begin
      FStretchHandle := TStretchhandle.Create( nil ); //PtCtrl ) ;
      FStretchHandle.MoveOffParent := FALSE ;
   end;

   FstretchHandle.Parent := PtCtrl ;
end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.LButtonDown(var Message: TWMLButtonDown);
begin

   FOldRect := Rect(0,0,0,0) ;
   XOrig := Message.XPos ;
   YOrig := Message.YPos ;

   SendCtrlList ;

//   PostMessage( ParentCtrl.Parent.handle, WM_CRP_CTRLLIST, LongInt( Pchar(FCtrlList.CommaText) ), 0 );

end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.LButtonUp(var Message: TWMLButtonDown);
var
   S : String ;
   I : integer ;
begin

   FParentCtrl.Refresh ;
   for I := 0 to FParentCtrl.ControlCount-1 do
      if FParentCtrl.Controls[ I ] is TExtQRBand then
         TExtQRBand( FParentCtrl.Controls[ I ] ).Repaint 
      else
      if FParentCtrl.Controls[ I ] is TExtQRGroup then
         TExtQRGroup( FParentCtrl.Controls[ I ] ).Repaint  ;


   S:= GetXYControls( XOrig, YOrig, Message.XPos,  Message.YPos );
   GroupXYControl( S ) ;
   TExtQuickRep( FOwnerCtrl ).PanelForm.ShowCtrls( FCtrlList.CommaText );

end ;

// -----------------------------------------------------------------------------

function TExtHoldObj.GetXYControls( XOrig, YOrig, XEnd, YEnd : integer ) : String;
var
   CooLeft, CooRight, CooTop, CooBottom : integer ;
   I : integer ;
   QRPrntTbl: TQRPrintable ;
   IsinX, IsInY : Boolean ;
   SLCtrl : TStringList ;
begin

   SLCtrl := TStringList.Create ;

   if XOrig <= XEnd then
   begin
      CooLeft  := XOrig ;
      CooRight := XEnd  ;
   end
   else
   begin
      CooLeft  := XEnd  ;
      CooRight := XOrig ;
   end ;

   if YOrig <= YEnd then
   begin
      CooTop    := YOrig ;
      CooBottom := YEnd  ;
   end
   else
   begin
      CooTop    := YEnd  ;
      CooBottom := YOrig ;
   end ;


   for I := 0 to ParentCtrl.ControlCount -1 do
   begin

      if ParentCtrl.Controls[ I ] is TQRPrintable then
      begin

         QRPrntTbl := TQRPrintable( ParentCtrl.Controls[ I ] ) ;
         IsInX := FALSE ;
         IsInY := FALSE ;

         // X ---------------------------
         if ( CooLeft > QRPrntTbl.Left ) then
            IsInX := ( CooLeft < QRPrntTbl.Left + QRPrntTbl.Width )
         else
            IsInX := ( CooRight > QRPrntTbl.Left ) ;

         // Y ---------------------------
         if ( CooTop > QRPrntTbl.Top  ) then
            IsInY := ( CooTop < QRPrntTbl.Top + QRPrntTbl.Height )
         else
            IsInY := ( CooBottom > QRPrntTbl.Top   ) ;


         if IsInX and IsInY then
            SLCtrl.Add( QRPrntTbl.Name );

      end;

   end;

   result := SLCtrl.CommaText ;
   SLCtrl.Free ;

end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.GroupXYControl( SCtrl : String );
var
   I : integer ;
   SLCtrl : TStringList ;
begin

   SLCtrl := TStringList.Create ;
   SLCtrl.CommaText := SCtrl ;
   FStretchhandle.Detach ;
   FCtrlState := ffCtrlDown ;
   for I := 0 to SLCtrl.Count -1 do
      AddControlToGroup( SlCtrl[ I ] ) ;

   FCtrlState := ffCtrlUp ;
   SLCtrl.Free

end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.AddControlToGroup( CtrlName : String );
var
   C : integer ;
   Found : Boolean ;
begin

   if FCtrlState = ffCtrlUp then
      FStretchHandle.Detach ;

   C:=0;
   Found := FALSE ;

   while ( C <= ParentCtrl.ControlCount -1 ) and not Found do
   begin
      if ParentCtrl.Controls[ C ].Name = CtrlName then
      begin
         if ParentCtrl.Controls[ C ] is TQRPrintable then
            if FStretchHandle.IndexOf( ParentCtrl.Controls[ C ] ) < 0 then
               FStretchhandle.Attach( ParentCtrl.Controls[ C ] );
         Found := TRUE ;
      end ;

      Inc( C );
   end;


end ;

// -----------------------------------------------------------------------------
procedure TExtHoldObj.SetCtrlKey ( CtrlKey : TCtrlState ) ;
begin
   FCtrlState := CtrlKey ;
end ;

// -----------------------------------------------------------------------------

function TExtHoldObj.IsControl( CtrlName : String ) : Boolean ;
begin
   result := ( FCtrlList.IndexOf( CtrlName ) >= 0 );
end ;

// -----------------------------------------------------------------------------

function TExtHoldObj.CtrlList : String ;
begin
   result := FCtrlList.CommaText ;
end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.AlignTo( CtrlAlign : TAlign );
var
   CtrlLeft, CtrlRight, CtrlTop, CtrlBottom : integer ;
   I : Integer ;
begin

   if FStretchHandle.ChildCount > 0 then
   begin
      CtrlLeft    := TCustomControl( FStretchHandle.Children[ 0 ] ).Left ;

      CtrlRight   := TCustomControl( FStretchHandle.Children[ 0 ] ).Left +
                     TCustomControl( FStretchHandle.Children[ 0 ] ).Width ;

      CtrlTop     := TCustomControl( FStretchHandle.Children[ 0 ] ).Top ;

      CtrlBottom  := TCustomControl( FStretchHandle.Children[ 0 ] ).Top +
                     TCustomControl( FStretchHandle.Children[ 0 ] ).Height ;

      I := 1 ;
      while ( I <= FStretchHandle.ChildCount -1 ) do
      begin

         case CtrlAlign of
         alLeft   :  begin
                        TCustomControl( FStretchHandle.Children[ I ] ).Left := CtrlLeft;
                     end ;
         alRight  :  begin
                        TCustomControl( FStretchHandle.Children[ I ] ).Left :=
                        CtrlRight - TCustomControl( FStretchHandle.Children[ I ] ).Width ;
                     end ;
         alTop    :  begin
                        TCustomControl( FStretchHandle.Children[ I ] ).Top := CtrlTop;
                     end ;
         alBottom :  begin
                        TCustomControl( FStretchHandle.Children[ I ] ).Top :=
                        CtrlBottom - TCustomControl( FStretchHandle.Children[ I ] ).Height ;
                     end ;
         end ;

         Inc( I );
      end ;

   end ;
   FParentCtrl.Refresh ;

end;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.SendCtrlList ;
var
   SL : TStringList ;
   I : integer ;
   Cp : TComponent ;
begin
   SL := TStringList.Create ;

   for I := 0 to FCtrlList.Count -1 do
   begin


      Cp := TWinControl(FOwnerCtrl).FindComponent( FCtrlList[ i ] ) ;
      if Cp <> nil then
         if not( ( Cp is TExtQRBand ) or ( Cp is TExtQRGroup )) then
            Sl.Add( FctrlList[ i ] ) ;



   end ;

   TExtQuickRep( FOwnerCtrl ).PanelForm.ShowCtrls( Sl.CommaText );
   SL.Free ;


end ;

// -----------------------------------------------------------------------------

procedure TExtHoldObj.QRRepaint ;
var
   I : integer ;
begin
   for I := 0 to FParentCtrl.ControlCount-1 do
      TWincontrol(FParentCtrl.Controls[ I ]).Repaint ;
end ;

end.
