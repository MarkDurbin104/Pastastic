program GetFileList;

uses
  Classes,DirectoryU,SysUtils,Windows;

{$R *.res}

var
  FileList:TStringList;

const
  FilePath:String='C:\Proiam\Source\VU.iT BA\BA Demo\bin-release';
  SavedFileName:String='F173715D.dat';

procedure OnFile(Name:String;Details:TSearchRec);
var
  LocalPath:String;
begin
   LocalPath:=Copy(Name,Length(FilePath)+2,Length(Name));
   if (Copy(LocalPath,1,4) <> 'com\') and (LocalPath<>SavedFileName) and (Details.Size<>0) then
     FileList.Add(IntToHex(Details.Time,8)+LocalPath);
end;
procedure FillList();
var
   Dir:TDirectory;
begin
   FileList:=TStringList.Create;
   Dir:=TDirectory.Create;
   Dir.Mask:='*.*';
   Dir.Attr:=$FF;
   Dir.AllDirs:=False;
   Dir.OnFile:=Dir.DirectoryOnFile;
   Dir.OnFuncFile:=OnFile;
   Dir.Recurse:=True;
   Dir.RootPath:=FilePath;
   Dir.Free;
   FileList.SaveToFile(FilePath+'\'+SavedFileName);
end;

begin
  FillList();
end.

