unit DomainsFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids;

type
  TDomainsForm = class(TForm)
    SG: TStringGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DomainsForm: TDomainsForm;

implementation

{$R *.DFM}

procedure TDomainsForm.FormCreate(Sender: TObject);
begin
   SG.RowCount:=2;
end;

end.
