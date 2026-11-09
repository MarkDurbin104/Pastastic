unit Unit7;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,System.IO, System.ComponentModel, Borland.Vcl.StdCtrls, xmldom,
  XMLIntf, Borland.Vcl.ClrXmlDom, Borland.Vcl.XmlDoc;

type
  TForm7 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    XMLDocument1: TXMLDocument;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form7: TForm7;

implementation

{$R *.nfm}

procedure TForm7.Button1Click(Sender: TObject);
var
  XMLNode:IXMLNode;
  I,J:Integer;
begin
  XMLDocument1.LoadFromFile('C:\UI.xml');
  for I:=0 to XMLDocument1.ChildNodes.Count-1 do
  begin
    XMLNode:=XMLDocument1.ChildNodes[I];
    if XMLNode.NodeName = 'screen' then
    begin
      for J:=0 to XMLNode.ChildNodes.Count-1 do
         ShowMessage(XMLNode.ChildNodes[J].NodeName);
    end;
  end;
end;

end.
