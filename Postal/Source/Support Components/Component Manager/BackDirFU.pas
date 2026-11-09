{  <Synopsis>      Corvus Component Manager
   <Unit>          Backup Form 
   <Copyright(c)>  Postal Solutions Limited 1996..1998
   <Author>        MJD
   <Description>   Load and manage Corvus Components via the 
                   component loader
   <Modifications> 06/01/98 - MJD
                              Original Release
                   13/02/99 - MJD
                              Change Commenting format
}                          
unit BackDirFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TBackupForm = class(TForm)
    BDir: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BackupForm: TBackupForm;

implementation

{$R *.DFM}

end.
