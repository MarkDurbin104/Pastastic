unit PError;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,ZebraEMS, Buttons;

type
  TErrorForm = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    Button2: TBitBtn;
    Button1: TBitBtn;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    Z:TZebraEMS;
    { Public declarations }
  end;

var
  ErrorForm: TErrorForm;

implementation

{$R *.DFM}

procedure TErrorForm.FormShow(Sender: TObject);
begin
    if (not Z.FPortOpen) or (not Z.FPortSetup ) 
       then CheckBox1.Checked:=True else CheckBox1.Checked:=False;
    if (Z.FNoResponse ) or (Z.FCommsError)      
       then CheckBox2.Checked:=True else CheckBox2.Checked:=False;
    if Z.FPaperOut                              
       then CheckBox3.Checked:=True else CheckBox3.Checked:=False;
    if Z.FRibonOut                              
       then CheckBox4.Checked:=True else CheckBox4.Checked:=False;
    if Z.FHeadUp                                
       then CheckBox5.Checked:=True else CheckBox5.Checked:=False;
    if (Z.FBufferFull) or (Z.FCorruptRAM)        
       then CheckBox6.Checked:=True else CheckBox6.Checked:=False;
    if Z.FOverTemp                              
       then CheckBox7.Checked:=True else CheckBox7.Checked:=False;
    if Z.FUnderTemp                             
       then CheckBox8.Checked:=True else CheckBox8.Checked:=False;
    if Z.FPaused 
       then CheckBox9.Checked:=True else CheckBox9.Checked:=False;
         
end;

end.
 