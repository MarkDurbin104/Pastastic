{ This demo illustrates using the HTTP control to retrieve HTML documents from
  a server.  This example is similar to the HTML control demo but it only displays
  the text of the retrieved document without HTML tags or graphics. }
program HTTPDemo;

uses
  Forms,
  main in 'main.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
