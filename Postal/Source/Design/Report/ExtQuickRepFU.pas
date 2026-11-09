       unit ExtQuickRepFU;

interface

uses
  Handles,
  ExtRepConst,
  DBTables,
  ExtQRLabelAU,
  ExtQRBandAU,
  ExtQRGroupAU,
  ExtQRDBText,
  ExtQRShapeAU,
  ExtQRImageAU,
  ExtQuickRepAU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls,
  quickrpt,
  Qrctrls;

type
  TExtQuickRepForm = class(TForm)
    procedure ReportClose ;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    ExtQuickRep : TExtQuickRep ;
    FQuery : TQuery ;
    FKeyDown : Boolean ;
  public

    { Public declarations }
      property Query : TQuery read FQuery write FQuery ;
  end;

var
  ExtQuickRepForm: TExtQuickRepForm;
  FS : boolean ;

implementation

{$R *.DFM}

procedure TExtQuickRepForm.FormCreate(Sender: TObject);
//var
//   FileStream : TFileStream;
begin

   FQuery := TQuery.Create( Self ) ;
   FQuery.Name := 'Query1' ;
   ExtQuickRep := TExtQuickRep.Create( Self );
   ExtQuickRep.Name := 'ExtQuickRep0' ;
   ExtQuickRep.Parent := self ;
   ExtQuickRep.DataSet := FQuery ;

   Application.ProcessMessages ;
   FQuery.SQL.Text := 'select * from txnlog order by Period, Teller';
   FQuery.DataBaseName := 'PSL';
   ExtQuickRep.InitSQL ;

   try

//      FileStream := TFileStream.Create( ffOutPutDir + '/' +ffOutPutFile, fmOpenRead );
//      FileStream.ReadComponent( ExtQuickRep );
//      FileStream.Free;
      //ExtQuickRep.FillComponents ;
   except
   end;

end;

procedure TExtQuickRepForm.FormDestroy(Sender: TObject);
//var
//   FileStream : TFileStream;
begin
   //save to stream
   //FileStream := TFileStream.Create('c:\form.txt', fmCreate);
   //FileStream.WriteComponent( ExtQuickRep );
   //FileStream.Free;

   ReportClose ;

end;

procedure TExtQuickRepForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

   if ssCtrl in Shift then
      if not FKeyDown then
      begin
         FKeyDown := TRUE ;
         PostMessage( ExtQuickRep.handle, WM_CRP_CTRLKEYDOWN, Ord( ffCtrlDown ), 0 );
      end ;

end;

procedure TExtQuickRepForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

   FKeyDown := FALSE ;
   if not( ssCtrl in Shift ) then
      PostMessage( ExtQuickRep.handle, WM_CRP_CTRLKEYDOWN, Ord( ffCtrlUp ), 0 );

end;

procedure TExtQuickRepForm.ReportClose ;
begin
    FQuery.Close ;
   ExtQuickRep.DataSet := nil ;
   FQuery.Free ;

   ExtQuickRep.Free ;
   ExtQuickRep := nil ;

end ;

initialization

   RegisterClass(TExtQuickRep);
   RegisterClass(TExtQRBand);
   RegisterClass(TExtQRGroup);
   RegisterClass(TExtQRLabel);
   RegisterClass(TExtQRShape);
   RegisterClass(TExtQRImage);
   RegisterClass(TExtQRDBText);
   RegisterClass(TStretchhandle);

end.
