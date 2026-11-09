unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm4 = class(TForm)
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
    OfficeCode  :Word;
    WSCode      :Byte  ;
    BlockCode   :LongInt;
    Period      :Word;
    LiveFor     :Word;
    MType       :Byte  ;
    MLength     :Word;
    Status      :Word;
    Reserved    :LongInt;
    Data        :Array[0..999] of Byte;
    CRC         :Word;
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.Button1Click(Sender: TObject);
begin
   ShowMessage(IntToStr(SizeOf(TMBRecord)));
end;

end.
