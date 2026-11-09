unit EditButton;

interface

uses
//  Windows, Messages, SysUtils,  Graphics, Controls, Forms,
//  Dialogs, ,ComCtrls,
  Controls, StdCtrls, Classes, extctrls ;


type

  TEditButton = class(TPanel)
  private
     ButtonPress : TButton ;
     FText       : String ;

     function ReadOnClickButton : TNotifyEvent ;
     procedure SetOnClickButton( CkBtn : TNotifyEvent ) ;

     procedure SetText( Txt : String );


  public
    EditBT      : TEdit ;
    procedure PaceCtrl ;
    property Text          : String       Read FText              write SetText ;
    property OnClickButton : TNotifyEvent read ReadOnClickButton  write SetOnClickButton ;
    constructor Create(AOwner: TComponent); override;
    Destructor  Destroy ; override ;
  end ;



implementation

//{$IFNDEF uses extctrls }
//{$ENDIF}


constructor TEditButton.Create(AOwner: TComponent);
begin
   inherited ;
   Height := 18 ;
   Width := 121 ;
   Caption := '' ;


   ButtonPress := TButton.Create( Self ) ;
   InsertControl( ButtonPress );
   ButtonPress.Caption:= '...';

   EditBT          := TEdit.Create( Self ) ;
   InsertControl( EditBT );
   EditBT.ReadOnly := TRUE ;

   Resize ;

   BevelOuter  := bvNone ;
   BevelInner  := bvNone ;


end ;

destructor TEditButton.Destroy ;
begin
   ButtonPress.Free ;
   EditBT.Free ;

   inherited Destroy ;
end ;

function TEditButton.ReadOnClickButton : TNotifyEvent ;
begin
   result := ButtonPress.OnClick ;
end ;

procedure TEditButton.SetOnClickButton( CkBtn : TNotifyEvent ) ;
begin
   ButtonPress.OnClick := CkBtn ;
end ;

procedure TEditButton.SetText( Txt : String );
begin
   EditBT.Text := Txt ;
end ;

procedure TEditButton.PaceCtrl ;
begin
   ButtonPress.Width  := Self.Height ;
   ButtonPress.Height := Self.Height ;
   ButtonPress.Left   := Self.Width - ButtonPress.Height-1 ;

   EditBT.Width    := Self.Width - ButtonPress.Width;
   EditBT.Height   := Self.Height ;
end ;


end.
