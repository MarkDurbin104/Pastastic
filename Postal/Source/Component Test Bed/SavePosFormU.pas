{  <Synopsis>      Corvus Save Position Form 
   <Unit>          Save Position Form 
   <Copyright(c)>  Postal Solutions Limited 1996..1998
   <Author>        MJD
   <Description>   Save Position of the Form in the registry on close
                   and load it form the registry on open
   <Modifications> 12/06/98 - MJD
                              Original Release
                   13/02/99 - MJD
                              Change Commenting format
}                          
unit SavePosFormU;

interface

uses
    Windows,Forms,Registry,Classes,SysUtils;
    
const
    SM_CMONITORS = 80;
   
type
   TSavePosForm=class(TForm)
      constructor Create(AOwner:TComponent); override;
      destructor Destroy; override;
   end;
implementation

constructor TSavePosForm.Create(AOwner:TComponent);
var
   SL:TStringList;
begin
   inherited Create(AOwner);
   with TRegistry.Create do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('\SOFTWARE\PSL\FORMPOS\'+Application.Title+'.'+Name,False) then
      begin
         SL:=TStringList.Create;
         SL.CommaText:=ReadString('Position');
         if SL.Count > 3 then
         begin
            SetBounds(StrToIntDef(SL[0],Left  ),
                      StrToIntDef(SL[1],Top   ),
                      StrToIntDef(SL[2],Width ),
                      StrToIntDef(SL[3],Height));
         end;
         SL.Free;
      end;    
      Free;
   end;
   if GetSystemMetrics(SM_CMONITORS) < 2 then
   begin
      if Left+Width > Screen.Width  then Left:=Screen.Width-Width;
      if Top+Height > Screen.Height then Top:=Screen.Height-Height;
      if Left < 0 then Left:=0;
      if Top < 0 then Top:=0;
   end;
end;
destructor TSavePosForm.Destroy;
begin
   with TRegistry.Create do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('\SOFTWARE\PSL\FORMPOS\'+Application.Title+'.'+Name,True) then
      begin
         WriteString('Position',
            IntToStr(Left  )+','+
            IntToStr(Top   )+','+
            IntToStr(Width )+','+
            IntToStr(Height));
      end;    
      Free;
   end;
   inherited Destroy;
end;
end.                    
