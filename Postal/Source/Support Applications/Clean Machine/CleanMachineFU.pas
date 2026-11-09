unit CleanMachineFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  SubTree,Registry, StdCtrls,WinExecU,DirectoryU,GPCSGUID;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
procedure UnRegisterCorvus;
var
   I:Integer;
   RegList:TStringList;
   ProgIdList:TStringList;
   SL:TStringList;
   J:Integer;
   OPString:String;
   ComponentList:TTreeBox;
begin
   ComponentList:=TTreeBox.Create(nil);
   while not ComponentList.Ready do
      Application.ProcessMessages;

   RegList:=TStringList.Create;
   ProgIdList:=TStringList.Create;
   SL:=TStringList.Create;
   for I:=0 to ComponentList.RegList.Count-1 do
   begin
      if ComponentList.RegList.Objects[I] <> nil then
      begin
         for J:=0 to ComponentList.RegList.Objects[I].Count-1 do
         begin
            if ComponentList.RegList.Objects[I].Objects[J] <> nil then
            begin
               if ComponentList.RegList.Objects[I].Objects[J].Count > 2 then
               begin
                  OPString:=ComponentList.RegList.Objects[I].Objects[J].Items[0];
                  if RegList.IndexOf(OPString) = -1 then
                     RegList.Add(OPString);
               end;
            end;
         end;
      end;
   end;
   for I:=0 to RegList.Count-1 do
      EraseKey(HKEY_CLASSES_ROOT,'CLSID\'+RegList[I]);
   Application.ProcessMessages;
   with TRegistry.Create do
   begin
      RootKey:=HKEY_CLASSES_ROOT;
      if OpenKey('CLSID',False) then
      begin
         if HasSubKeys then
         begin
            GetKeyNames(SL);
            CloseKey;
            for I:=0 to SL.Count-1 do
            begin
               if OpenKey('CLSID'+'\'+SL[I],False) then
               begin
                  if (Copy(ReadString(''),1,5) = 'GPCS ') or (Copy(ReadString(''),1,7) = 'CORVUS ') then
                  begin
                     CloseKey;
                     EraseKey(HKEY_CLASSES_ROOT,'CLSID'+'\'+SL[I]);
                  end
                  else
                  begin
                     CloseKey;
                     if OpenKey('CLSID'+'\'+SL[I]+'\ProgID',False) then
                     begin
                        if (Copy(ReadString(''),1,4) = 'GPCS') or (Copy(ReadString(''),1,6) = 'CORVUS') or (ProgIDList.IndexOf(ReadString('')) >= 0) then
                        begin
                           CloseKey;
                           EraseKey(HKEY_CLASSES_ROOT,'CLSID'+'\'+SL[I]);
                        end
                        else
                          CloseKey;
                     end;
                  end;
               end;

            end;
         end;
      end;
      Free;
   end;
   ComponentList.Free;
   SL.Free;
   RegList.Free;
   ProgIdList.Free;
end;

procedure DeleteAll(Path:String;Registry:TRegistry);
var
   SL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   Registry.GetValueNames(SL);
   for I:=0 to SL.Count-1 do
      Registry.DeleteValue(SL[I]);
   Registry.GetKeyNames(SL);
   Registry.CloseKey;
   for I:=0 to SL.Count-1 do
   begin
      Application.ProcessMessages;
      if Registry.OpenKey(Path+'\'+SL[I],False) then
         DeleteAll(Path+'\'+SL[I],Registry);
   end;
   Registry.DeleteKey(Path);
   SL.Free;
end;
procedure RemoveCompleteDir(RootPath:String);
var
   SL:TStringList;
   I:Integer;
begin
   SL:=TStringList.Create;
   FillFileList(RootPath,'*.*',True,SL);
   for I:=0 to SL.Count-1 do
   begin
      Application.ProcessMessages;
      DeleteFile(SL[I]);
   end;
   SL.Clear;
   FillDirList(RootPath,True,SL);
   for I:=0 to SL.Count-1 do
   begin
      Application.ProcessMessages;
      RemoveDir(SL[I]);
   end;
   SL.Free;
end;
procedure TForm1.Button1Click(Sender: TObject);
var
   S,RootPath:String;
begin
   Button1.Enabled:=False;
   if ParamCount > 0 then
      RootPath:=ParamStr(1)
   else
      RootPath:='C:\Botswana';

   WinExecAndWait('C:\CorvusService\CorvusService -X',S,False);
   UnRegisterCorvus;
   EraseKey(HKEY_LOCAL_MACHINE,'SOFTWARE\PSL');
   RemoveCompleteDir('C:\CorvusService');
   RemoveCompleteDir(RootPath);
   RemoveCompleteDir('C:\Messages');
   RemoveCompleteDir('C:\TxnFiles');
   DeleteFile('C:\CorvusServiceFile.dat');
   DeleteFile('C:\GPCSErr.log');
   DeleteFile('C:\PDOXUSRS.NET');
   DeleteFile('C:\StockChanges.log');
   DeleteFile('C:\StockList.txt');
   Button1.Enabled:=True;
end;

end.
