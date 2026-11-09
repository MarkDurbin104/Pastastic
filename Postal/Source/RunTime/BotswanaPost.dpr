program BotswanaPost;

uses
  Forms,
  Windows,
  ComServ2,
  GPCSBaseAU,
  ComObj,
  SysUtils,
  GPCSGUID,
  MainFU in 'MainFU.pas' {MainForm},
  SplashFU in 'SplashFU.pas' {Splash},
  PrintFormFU in 'PrintFormFU.pas' {PrintForm},
  FrontEndAU,
  UserFormFU,
  UsersF in 'UsersF.pas' {UsersForm};

{$R *.RES}
var
   SplashImageFile:String;
const
   ExitNow:Boolean = False;
begin
  if (ParamCount > 0) and (Copy(ParamStr(1),1,1) = '!') then
  begin
     if GetUserLoginName = Copy(ParamStr(1),2,Length(ParamStr(1))) then
     begin
        WinExec('Explorer',SW_SHOW);
        ExitNow:=True;
     end;
  end;
  if not ExitNow then
  begin
     TGPCSCompFactory.Create(ComServer,TRemControl,
                             StringToGUID('{38EC6ED4-BD79-40F0-BB95-BD840DED85BA}'),
                             'Application.Botswana','CORVUS Botswana Post Application',
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
  end;
end.
