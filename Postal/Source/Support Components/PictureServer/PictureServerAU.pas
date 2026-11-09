unit PictureServerAU;

interface
uses
  Windows,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  PictureServerFU,Compress;
  
type
  TGPCSPictureServer = class(TPictureServer, IPictureServer)
  public
    function Bitmap(const Named:WideString):WideString; override;
    function Get_PictureNames:WideString;         override;
    function ZLBitMap(const Named: WideString): OleVariant; override;
  end;                  
  
implementation
uses
   ComServ2;

function TGPCSPictureServer.Bitmap(const Named:WideString):WideString;
begin
   Result:='';
   if Form1 <> nil then Result:=Form1.GetPicture(Named);
end;
function TGPCSPictureServer.Get_PictureNames:WideString;
begin
   Result:='';
   if Form1 <> nil then Result:=Form1.GetNames;
end;
function TGPCSPictureServer.ZLBitMap(const Named: WideString): OleVariant;
var
   Compressor:TCompressor;
begin
   Result:='';
   if Form1 <> nil then 
   begin
   Compressor:=TCompressor.Create;
      try
         Result:=Compressor.CreateArrayFromBitmap(Form1.GetBitmapByName(Named));
      except
      end;
   Compressor.Free;
   end;
end;
initialization
  TGPCSCompFactory.Create(ComServer,TGPCSPictureServer,Class_GPCSPictureServer,
                          'Support.PictureServer','GPCS Picture Server',
                          ciMultiInstance);
end.
