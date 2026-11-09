library SMBG;

uses
  Forms,SysUtils,Classes,DataGramU in '..\DataGramU.pas';
var
   DGram:TDGram;
begin
   DGram:=TDGram.Create;
   DGram.DGInterval:=5000;
   Application.Initialize;
   while not Application.Terminated do
      Application.ProcessMessages;
end.
 