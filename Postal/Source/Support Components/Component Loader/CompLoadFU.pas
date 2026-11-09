{  <Synopsis>      Corvus Component Loader
   <Unit>          Form
   <Copyright(c)>  Postal Solutions Limited 1996..1998
   <Author>        MJD
   <Description>   Implement all Component Loading Functions for Corvus
                   by loading COM objects via GUID and returning variant
                   references to each component.
                   When a maximum number of components (MaxLoad) is Loaded
                   start a new version of self to load additional components
   <Modifications> 06/01/98 - MJD
                              Original Release
                   13/02/99 - MJD
                              Change Commenting format
________________________________________________________________________________}
unit CompLoadFU;

interface

uses
  Forms, Classes, Controls, StdCtrls;

type
  TMainForm = class(TForm)
    ProgIDList: TListBox; // List of loaded components
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

end.
