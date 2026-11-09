unit LnkFieldFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ExtCtrls;

type
  TChangeFieldProc = Procedure of object ;

  TLinkFieldForm = class(TForm)
    StringGrid1: TStringGrid;
    procedure StringGrid1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StringGrid1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }

    FOldValue : String ;
    FOnDataFieldChange : TChangeFieldProc ;
    function  GetLnkFields : string ;
    procedure SetLnkFields( StrFields : String );
  public
    { Public declarations }
    property OnDataFieldChange : TChangeFieldProc read FOnDataFieldChange write FOnDataFieldChange ;
    property LinkFields : string read GetLnkFields write SetLnkFields ;// ;//
  end;

var
  LinkFieldForm: TLinkFieldForm;

implementation

{$R *.DFM}


procedure TLinkFieldForm.StringGrid1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

   if ( StringGrid1.Cells[ 0,StringGrid1.RowCount-1 ] <> '' ) then
      StringGrid1.RowCount := StringGrid1.RowCount + 1 ;

   if ( StringGrid1.Cells[ 0,StringGrid1.RowCount-1 ] = '' ) and
      ( StringGrid1.Cells[ 0,StringGrid1.RowCount-2 ] = '' ) and
      ( StringGrid1.RowCount > 50 ) then
         StringGrid1.RowCount := StringGrid1.RowCount -1 ;

   if ( StringGrid1.Row < StringGrid1.RowCount ) and
      ( ( Key = 13 ) or ( Key = 9 ) ) then
      StringGrid1.Row := StringGrid1.Row +1 ;

   if FOldValue <> StringGrid1.Cells[ 0,StringGrid1.Row ] then
      if Assigned( FOnDataFieldChange ) then FOnDataFieldChange ;
end;

procedure TLinkFieldForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Action := caMinimize	 ;
end;

function TLinkFieldForm.GetLnkFields : String;
var
   I : integer ;
   SL : TStringList ;
begin
   SL := TStringList.Create ;
   for I := 0 to StringGrid1.RowCount -1 do
      if StringGrid1.Cells[0,I] <> '' then
         SL.Add(StringGrid1.Cells[0,I]);

   result := SL.CommaText ;
   SL.Free ;

end ;

procedure TLinkFieldForm.SetLnkFields( StrFields : String );
var
   I : integer ;
   SL : TStringList ;
begin
   SL := TStringList.Create ;
   SL.CommaText := StrFields ;
   if SL.Count > 50 then
      StringGrid1.RowCount := SL.Count ;

   for I := 0 to SL.Count -1 do
      StringGrid1.Cells[ 0, I ] ;

   SL.Free ;

end ;


//               if Assigned( FOnDataFieldChange ) then
//                  FOnDataFieldChange( ItemDsgList[ItemDsgList.Selected].Prompt, ItemDsgList[ItemDsgList.Selected].Data ) ;

procedure TLinkFieldForm.FormCreate(Sender: TObject);
begin
   FOnDataFieldChange := nil ;
end;

procedure TLinkFieldForm.StringGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
      FOldValue :=  StringGrid1.Cells[ 0,StringGrid1.Row ]
end;

procedure TLinkFieldForm.StringGrid1KeyPress(Sender: TObject;
  var Key: Char);
begin
   if Key = #32 then
      Key := chr(0);
end;

end.
