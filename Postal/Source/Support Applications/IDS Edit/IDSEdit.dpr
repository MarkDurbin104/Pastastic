program IDSEdit;

uses
  Forms,
  ProjectFormFU {ProjectsForm},
  ErrorFormFU {ErrorForm},
  IDSEditFU in 'IDSEditFU.pas' {Form1},
  UWGroupDesFU in 'UWGroupDesFU.pas' {UWGroupDes},
  PropertyEditFU in 'PropertyEditFU.pas' {PropEdit},
  ProductDesFU in 'ProductDesFU.pas' {ProductDes},
  ListOutputFU in 'ListOutputFU.pas' {ListOutput},
  SnippetDesFU in 'SnippetDesFU.pas' {SnippetDes},
  GroupDesFU in 'GroupDesFU.pas' {GroupDes},
  DomainDesFU in 'DomainDesFU.pas' {DomainDes};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.CreateForm(TProjectsForm, ProjectsForm);
  Application.CreateForm(TUWGroupDes, UWGroupDes);
  Application.CreateForm(TPropEdit, PropEdit);
  Application.CreateForm(TProductDes, ProductDes);
  Application.CreateForm(TListOutput, ListOutput);
  Application.CreateForm(TSnippetDes, SnippetDes);
  Application.CreateForm(TGroupDes, GroupDes);
  Application.CreateForm(TDomainDes, DomainDes);
  Application.Run;
end.

