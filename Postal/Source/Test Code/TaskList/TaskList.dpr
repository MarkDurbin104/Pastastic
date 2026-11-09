program TaskList;

uses
  Forms,
  TaskListFU in 'TaskListFU.pas' {Form1},
  TaskKillerU in '..\..\Packages\TaskKillerU.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
