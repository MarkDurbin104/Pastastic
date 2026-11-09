unit Unit5;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, System.ComponentModel, Borland.Vcl.StdCtrls;

type
  TForm5 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TMBRecord = packed record
    Version     :Byte  ;
    OperatorCode:Byte  ;
    OfficeCode  :UInt16;
    WSCode      :Byte  ;
    BlockCode   :UInt32;
    Period      :UInt16;
    LiveFor     :UInt16;
    MType       :Byte  ;
    MLength     :UInt16;
    Status      :UInt16;
    Reserved    :UInt32;
    Data        :Array[0..249] of Integer;
    CRC         :UInt16;
  end;
var
  Form5: TForm5;

implementation

{$R *.nfm}

procedure TForm5.Button1Click(Sender: TObject);
begin
   ShowMessage(IntToStr(SizeOf(TMBRecord)));
end;

end.
