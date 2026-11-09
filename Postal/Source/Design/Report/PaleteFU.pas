unit PaleteFU;

interface

uses
  ExtRepConst,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, StdCtrls, Mask, checklst;

type
  TPanelForm = class(TForm)
    ToolBar1: TToolBar;
    LabelTB: TToolButton;
    ShapeTB: TToolButton;
    ImageList1: TImageList;
    ImageTB: TToolButton;
    Label1: TLabel;
    ZoomEdit: TEdit;
    GroupTB: TToolButton;
    NewDocumentTB: TToolButton;
    OpenFileTB: TToolButton;
    SaveFileTB: TToolButton;
    PreviewTB: TToolButton;
    BandTB: TToolButton;
    DBTextTB: TToolButton;
    ComBoxCtrlList: TComboBox;
    HeaderControl1: THeaderControl;
    procedure ZoomEditKeyPress(Sender: TObject; var Key: Char);
    procedure ZoomEditExit(Sender: TObject);
    procedure NewDocumentTBClick(Sender: TObject);
    procedure OpenFileTBClick(Sender: TObject);
    procedure PreviewTBClick(Sender: TObject);
    procedure SaveFileTBClick(Sender: TObject);
    procedure ComBoxCtrlListChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
      procedure PostMessageValue ;
  public
     ParentCtrl : TWinControl ;
     procedure ShowCtrls( CtrlList : String );
    { Public declarations }
  end;

var
  PanelForm: TPanelForm;

implementation

{$R *.DFM}

procedure TPanelForm.ZoomEditKeyPress(Sender: TObject; var Key: Char);
begin
   if (Key = #13) then
      PostMessageValue ;

   if not( Key in [ '0'..'9', #8 ] ) then
         Key := Chr( 0 );

end;
procedure TPanelForm.PostMessageValue ;
begin
   try
      PostMessage( ParentCtrl.Handle,WM_CRP_ZOOM,StrToInt(Trim(ZoomEdit.Text)), 0)
   except
   end ;
end ;

procedure TPanelForm.ZoomEditExit(Sender: TObject);
begin
   PostMessageValue ;
end;

procedure TPanelForm.NewDocumentTBClick(Sender: TObject);
begin
   PostMessage( ParentCtrl.Handle,WM_CRP_DOCUMENT, ffNewDocument, 0);
 end;

procedure TPanelForm.OpenFileTBClick(Sender: TObject);
begin
   PostMessage( ParentCtrl.Handle,WM_CRP_DOCUMENT, ffOpenFile, 0) ;
end;

procedure TPanelForm.PreviewTBClick(Sender: TObject);
begin
   PostMessage( ParentCtrl.Handle,WM_CRP_DOCUMENT, ffPreview, 0) ;
end;

procedure TPanelForm.SaveFileTBClick(Sender: TObject);
begin
   PostMessage( ParentCtrl.Handle,WM_CRP_DOCUMENT, ffSaveFile, 0) ;
end;

procedure TPanelForm.ShowCtrls( CtrlList : String );
var
   CL : TStringList ;
   I : integer ;
begin
   CL := TStringList.Create ;
   CL.CommaText := CtrlList ;
   ComBoxCtrlList.Items.Clear ;
   for I := 0 to CL.Count -1 do
   begin
      // if Pos ( CL[I], '') > 0 then
   // ExtQRLabel,ExtQRShape,ExtQRImage,ExtQRGroup,ExtQRBand,ExtQRDBText,

      ComBoxCtrlList.Items.Add( CL[I] );
   end ;
   CL.Free ;
   if ComBoxCtrlList.Items.Count > 0 then
      ComBoxCtrlList.Text := 'Select in '
   else
      ComBoxCtrlList.Text := '';
   //ComBoxCtrlList.ItemIndex := 0 ;

end ;

procedure TPanelForm.ComBoxCtrlListChange(Sender: TObject);
begin
   PostMessage( ParentCtrl.Handle,WM_CRP_CTRLSHOW, LongInt(Pchar( ComBoxCtrlList.Text )), 0);
end;

procedure TPanelForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caMinimize	 ;
end;

end.





