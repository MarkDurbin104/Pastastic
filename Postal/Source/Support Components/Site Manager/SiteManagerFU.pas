{  Module          Corvus Site Manager
   Unit            Form       
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description     
   Modifications   
                              Original Release
________________________________________________________________________________}
unit SiteManagerFU;

interface

uses
  Windows,Forms, Classes, Controls, StdCtrls,DataGramU,RegUtils;

type
  TSiteManagerForm = class(TForm)
    WhosHereLB: TListBox;
    ErrorMemo: TMemo;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
  private
    procedure DGramWhosHere(List:TStrings);
    procedure DGramError(ErrorMessage:String);
  public        
    DGram:TDGram;
  end;

var
  SiteManagerForm: TSiteManagerForm;

implementation

{$R *.DFM}

procedure TSiteManagerForm.FormCreate(Sender: TObject);
begin
   DGram:=TDGram.Create;
   DGram.OnWhosHere:=DGramWhosHere;
   DGram.OnError:=DGramError;
   DGram.DGInterval:=1000;
end;
procedure TSiteManagerForm.DGramWhosHere(List:TStrings);
begin
   WhosHereLB.Items.Assign(List);
end;
procedure TSiteManagerForm.DGramError(ErrorMessage:String);
begin
   ErrorMemo.Lines.Add(ErrorMessage);
end;

end.
