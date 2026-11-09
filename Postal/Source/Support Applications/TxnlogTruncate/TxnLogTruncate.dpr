program TxnLogTruncate;

uses
  Forms,
  TxnLogTruncateF in 'TxnLogTruncateF.pas' {TxnlogTruncateForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Corvus Txnlog Archive';
  Application.CreateForm(TTxnlogTruncateForm, TxnlogTruncateForm);
  Application.Run;
end.
