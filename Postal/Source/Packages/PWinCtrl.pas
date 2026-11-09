{  Module          Painted WinControl
   Unit            VCL
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description     Support Class for General VCL components
   Modifications   21/03/98 - MJD
                              Original Release
}
unit PWinCtrl;

interface

uses
   Windows,Controls,Graphics,Classes,Messages;
   
type
  TPaintedWinControl = class(TWinControl)
  private
    FCanvas:TCanvas;
  protected                                    
    destructor  Destroy; override;
    constructor Create(AOwner: TComponent); override;
    procedure WMPaint(var Message: TWMPaint); message WM_Paint;
    
    procedure   Paint; virtual; abstract;
    
    property Canvas:TCanvas read FCanvas write FCanvas;
  end;
  
implementation

{TPaintedWinControl}

{===============================================================================
  Class        TPaintedWinControl
  Method       Create
  Description  Create and assign Canvas
  Params       The Owner of the Control
  Result       None
________________________________________________________________________________}
constructor TPaintedWinControl.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   ControlStyle := ControlStyle + [csReplicatable];
   FCanvas:=TControlCanvas.Create;
   TControlCanvas(FCanvas).Control:=Self;
   Width :=150;
   Height:=40;
end;
{===============================================================================
  Class        TPaintedWinControl
  Method       Destroy
  Description  Free Canvas
  Params       None
  Result       None
________________________________________________________________________________}
destructor TPaintedWinControl.Destroy;
begin
   FCanvas.Free;
   inherited Destroy;
end;
{===============================================================================
  Class        TPaintedWinControl
  Method       WMPaint
  Description  Setup Paint DC and call Paint method
  Params       Message - ignored
  Result       None
________________________________________________________________________________}
procedure TPaintedWinControl.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  PS: TPaintStruct;
begin
   try
      if FCanvas = nil then Exit;
      DC:=BeginPaint(Handle,PS);
      if DC <> 0 then 
      begin
         FCanvas.Handle:=DC;
         Paint;
      end;
   finally
      FCanvas.Handle:=0;
      EndPaint(Handle,PS);
   end;
end;
end.
