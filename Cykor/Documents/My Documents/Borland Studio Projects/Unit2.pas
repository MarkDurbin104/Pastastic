unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ShellCtrls, ExtCtrls;

type
  TForm2 = class(TForm)
    ShellListView1: TShellListView;
    Panel1: TPanel;
    Splitter1: TSplitter;
    ShellTreeView1: TShellTreeView;
    Panel2: TPanel;
    ShellComboBox1: TShellComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

end.
