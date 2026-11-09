program SaudiPost;

uses
  Forms,
  ComServ2,
  GPCSBaseAU,
  ComObj,
  SysUtils,
  GPCSGUID,
  MainFU in 'MainFU.pas' {MainForm},
  SplashFU in 'SplashFU.pas' {Splash},
  PrintFormFU in 'PrintFormFU.pas' {PrintForm},
  FrontEndAU in 'FrontEndAU.pas',
  UserFormFU in 'UserFormFU.pas' {UserForm},
  UsersF in 'UsersF.pas' {UsersForm};

{$R *.RES}
var
   SplashImageFile:String;
begin
  TGPCSCompFactory.Create(ComServer,TRemControl,
                          StringToGUID('{ABE2ED50-2B0E-11D3-96F9-DEE8E6C0AD37}'),
                          'Application.SaudiPost','GPCS Saudi Post Application',
                          ciMultiInstance);
  Application.Initialize;
  Splash:=TSplash.Create(nil);
  SplashImageFile:=GetGPCSRegString('','Splash',ApplicationRootPath+'\Splash.bmp');
  if FileExists(SplashImageFile) then
     Splash.Image1.Picture.Bitmap.LoadFromFile(SplashImageFile);
  Splash.Color:=Splash.Image1.Picture.Bitmap.Canvas.Pixels[0,0];
  Splash.Show;        
  Splash.RePaint;
  if LoneProcess then
  begin
     Application.ProcessMessages;
     Application.CreateForm(TMainForm, MainForm);
     Application.CreateForm(TPrintForm, PrintForm);
     Application.CreateForm(TUserForm, UserForm);
     Application.CreateForm(TUsersForm, UsersForm);
     Application.Run;
  end;
end.
