unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    TreeView1: TTreeView;
    ListView1: TListView;
    Splitter1: TSplitter;
    ImageList1: TImageList;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
   TreeView1.SaveToFile('C:\Treeview.txt');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   TreeView1.LoadFromFile('C:\Treeview.txt');
end;

end.
