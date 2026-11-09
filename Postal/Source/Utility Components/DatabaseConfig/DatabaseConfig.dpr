program DatabaseConfig;

uses
  Forms,
  DatabaseConfigF in 'DatabaseConfigF.pas' {CorvusDatabaseConfigForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.ShowMainForm := False;
  Application.CreateForm(TCorvusDatabaseConfigForm, CorvusDatabaseConfigForm);
  //command line interface
	If ParamStr(1) <> '' then
  	CorvusDatabaseConfigForm.Close
  else
	  CorvusDatabaseConfigForm.Show;


  Application.Run;
end.
