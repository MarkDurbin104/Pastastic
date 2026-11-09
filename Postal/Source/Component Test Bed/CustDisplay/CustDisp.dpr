program CustDisp;

uses
  Forms,
  ComServ2,
  CustDispAU in 'CustDispAU.pas',
  CustDispFU in 'CustDispFU.pas'; {TCustomerDisplay}
                                        
{$R *.RES}

begin
   Application.Initialize;
   Application.CreateForm(TCustomerDisplay, CustomerDisplay);
   Application.Run;
end.
