unit POBoxManagerF;

interface

uses
  ComServ2,
  POBoxOfficeF,
  SavePosFormU,
  ComObj,
  TableViewF,
  POBoxManager_TLB,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Grids, DBGrids, Db, DBTables, DBCtrls,
  checklst, Buttons;

type
  TPOBoxManagerForm = class(TSavePosForm)
    MainPageControl: TPageControl;
    LogTabSheet: TTabSheet;
    LogMemo: TMemo;
    OfficeTabSheet: TTabSheet;
    OfficeTopPanel: TPanel;
    OfficeLabel: TLabel;
    OfficeEdit: TEdit;
    OfficeBottomPanel: TPanel;
    CacheTabSheet: TTabSheet;
    CacheOfficesListBox: TListBox;
    CacheBoxesListBox: TListBox;
    CacheOfficesSplitter: TSplitter;
    DataTabSheet: TTabSheet;
    StyleTabSheet: TTabSheet;
    StyleTopPanel: TPanel;
    StyleLabel: TLabel;
    StyleEdit: TEdit;
    StyleClientPanel: TPanel;
    StyleBottomPanel: TPanel;
    StyleUpdateButton: TButton;
    StyleAddButton: TButton;
    StyleWidthLabel: TLabel;
    StyleDepthLabel: TLabel;
    StyleHeightLabel: TLabel;
    StylePricingStructureLabel: TLabel;
    StyleWidthEdit: TEdit;
    StyleDepthEdit: TEdit;
    StyleHeightEdit: TEdit;
    StylePricingStructureEdit: TEdit;
    ClerkTabSheet: TTabSheet;
    ClerkPanel: TPanel;
    SiteLabel: TLabel;
    ClerkLabel: TLabel;
    WorkstationLabel: TLabel;
    SiteEdit: TEdit;
    ClerkEdit: TEdit;
    WorkstationEdit: TEdit;
    ClerkBottomPanel: TPanel;
    ClerkUpdateButton: TButton;
    CacheCustomersListBox: TListBox;
    CacheCustomersSplitter: TSplitter;
    OfficeGetButton: TButton;
    OfficeDeleteButton: TButton;
    OfficeAddButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure StyleAddButtonClick(Sender: TObject);
    procedure StyleUpdateButtonClick(Sender: TObject);
    procedure DataTabSheetEnter(Sender: TObject);
    procedure ClerkUpdateButtonClick(Sender: TObject);
    procedure OfficeGetButtonClick(Sender: TObject);
    procedure OfficeDeleteButtonClick(Sender: TObject);
    procedure OfficeAddButtonClick(Sender: TObject);
  private
    { Private declarations }
    POBoxManager  : IPOBoxManagerAuto;
  public
    { Public declarations }
    procedure AddLog(LogLine : String);
  end;

var
  POBoxManagerForm: TPOBoxManagerForm;

implementation

{$R *.DFM}
procedure TPOBoxManagerForm.AddLog(LogLine : String);
begin
  LogMemo.Lines.Add(DateTimeToStr(Now) + ' - ' + LogLine);
end;

procedure TPOBoxManagerForm.FormCreate(Sender: TObject);
begin
  If ComServer.StartMode = smStandAlone then
  begin
    POBoxManager := CreateOleObject('POBoxManager.POBoxManagerAuto') as IPOBoxManagerAuto;
    POBoxManager.Site         := StrToIntDef(SiteEdit.Text,0);
    POBoxManager.Clerk        := ClerkEdit.Text;
    POBoxManager.Workstation  := StrToIntDef(WorkstationEdit.Text, 0);
  end;
  LogMemo.Lines.Clear;

  //create table views
  With TTableViewForm.Create(self) do
  begin
    Parent := self.DataTabSheet;
    DatabaseName := 'PSLPOBox';
    TableName := 'Box.db';
    Visible := True;
  end;

  With TTableViewForm.Create(self) do
  begin
    Parent := self.DataTabSheet;
    DatabaseName := 'PSLPOBox';
    TableName := 'BoxOffice.db';
    Visible := True;
  end;

  With TTableViewForm.Create(self) do
  begin
    Parent := self.DataTabSheet;
    DatabaseName := 'PSLPOBox';
    TableName := 'BoxStyle.db';
    Visible := True;
  end;

  With TTableViewForm.Create(self) do
  begin
    Parent := self.DataTabSheet;
    DatabaseName := 'PSLPOBox';
    TableName := 'BoxCustomer.db';
    Visible := True;
  end;

end;

procedure TPOBoxManagerForm.StyleAddButtonClick(Sender: TObject);
begin
  POBoxMAnager.AddChangeBoxStyle( StrToInt(StyleEdit.Text),
                                  StrToInt(StyleWidthEdit.Text),
                                  StrToInt(StyleHeightEdit.Text),
                                  StrToInt(StyleDepthEdit.Text),
                                  StrToInt(StylePricingStructureEdit.Text));
end;

procedure TPOBoxManagerForm.StyleUpdateButtonClick(Sender: TObject);
begin
  POBoxManager.AddChangeBoxStyle( StrToInt(StyleEdit.Text),
                                  StrToInt(StyleWidthEdit.Text),
                                  StrToInt(StyleHeightEdit.Text),
                                  StrToInt(StyleDepthEdit.Text),
                                  StrToInt(StylePricingStructureEdit.Text));

end;

procedure TPOBoxManagerForm.DataTabSheetEnter(Sender: TObject);
var
  ControlIndex : Integer;
  DBGrid        : TDBGrid;
begin
  for ControlIndex := 0 to DataTabSheet.ControlCount -1 do
  begin
    If DataTabSheet.Controls[ControlIndex] Is TTableViewForm then
    begin
      DBGrid := (DataTabSheet.Controls[ControlIndex] As TTableViewForm).DBGrid;
      DBGrid.DataSource.DataSet.Refresh;
    end;
  end;
end;

procedure TPOBoxManagerForm.ClerkUpdateButtonClick(Sender: TObject);
begin
  POBoxManager.Site         := StrToIntDef(SiteEdit.Text,0);
  POBoxManager.Clerk        := ClerkEdit.Text;
  POBoxManager.Workstation  := StrToIntDef(WorkstationEdit.Text, 0);
end;

procedure TPOBoxManagerForm.OfficeGetButtonClick(Sender: TObject);
var
  Office : IPOBoxOffice;
begin
  Office := POBoxManager.Offices[StrToInt(OfficeEdit.Text)];
  If Office <> nil then
    Office.Visible := True
  else
    ShowMessage('Office ' + OfficeEdit.Text + ' not available');
end;

procedure TPOBoxManagerForm.OfficeDeleteButtonClick(Sender: TObject);
begin
  If not POBoxManager.DeleteOffice(StrToInt(OfficeEdit.Text)) then
    ShowMessage('Unable to delete office ' + OfficeEdit.Text);
end;


procedure TPOBoxManagerForm.OfficeAddButtonClick(Sender: TObject);
var
  Office : IPOBoxOffice;
begin
  Office := POBoxManager.AddOffice(StrToInt(OfficeEdit.Text), '', '');
  If Office = nil  then
    ShowMessage('Unable to add office')
  else
    Office.Visible := True;

end;

end.
