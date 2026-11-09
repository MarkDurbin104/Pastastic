unit About;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TActiveFormXAbout = class(TForm)
    CtlImage: TSpeedButton;
    NameLbl: TLabel;
    OkBtn: TButton;
    CopyrightLbl: TLabel;
    DescLbl: TLabel;
  end;

procedure ShowActiveFormXAbout;

implementation

{$R *.DFM}

procedure ShowActiveFormXAbout;
begin
  with TActiveFormXAbout.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

end.
