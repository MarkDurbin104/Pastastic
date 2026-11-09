unit DirectoryU;

interface

uses
  SysUtils,Classes,Forms;

// Example:
//
// procedure TForm1.DirectoryOnDir(Name:String;Details:TSearchRec);
// begin
//    Memo1.Lines.Add('Dir: ['+IntToStr(Details.Attr)+'] '+Name);
// end;
// procedure TForm1.DirectoryOnFile(Name:String;Details:TSearchRec);
// begin
//    Memo1.Lines.Add('File: ['+IntToStr(Details.Size)+'] '+Name);
// end;
// procedure TForm1.FormCreate(Sender: TObject);
// var
//    Dir:TDirectory;
// begin
//    Dir:=TDirectory.Create;
//    Dir.Mask:='*.pas;*.dpr;*.dfm';
//    Dir.Attr:=faReadOnly or faHidden or faSysFile or faArchive;
//    Dir.AllDirs:=False; // don't process empty directories
//    Dir.OnFile:=DirectoryOnFile;
//    Dir.OnDir:=DirectoryOnDir;
//    Dir.Recurse:=True;
//    Dir.RootPath:='E:\CorvusV3\Corvus\Source\'; // process dirs
//    Dir.Free;
// end;
//

type
  TItemEvent = procedure(Name:String;Details:TSearchRec) of object;
  TItemFuncEvent = procedure(Name:String;Details:TSearchRec);
  TDirectory = class(TObject)
   private
     FRootPath:String;
     FMask   :TStringList;
     FOnDir  :TItemEvent;
     FOnFile :TItemEvent;
     FOnFuncDir :TItemFuncEvent;
     FOnFuncFile:TItemFuncEvent;
     FAttr   :Integer;
     FAllDirs:Boolean;
     FRecurse:Boolean;
     procedure SetRootPath(Value:String);
     procedure ProcessPath(Path:String);
     function GetMask:String;
     procedure SetMask(Value:String);
     procedure DirectoryOnDir(Name:String;Details:TSearchRec);
     procedure DirectoryOnFile(Name:String;Details:TSearchRec);
   public
     constructor Create;
     destructor Destroy; override;
     property RootPath  :String         read FRootPath     write SetRootPath;
     property Mask      :String         read GetMask       write SetMask    ;
     property Attr      :Integer        read FAttr         write FAttr      ;
     property AllDirs   :Boolean        read FAllDirs      write FAllDirs   ;
     property Recurse   :Boolean        read FRecurse      write FRecurse   ;
     property OnDir     :TItemEvent     read FOnDir        write FOnDir     ;
     property OnFile    :TItemEvent     read FOnFile       write FOnFile    ;
     property OnFuncDir :TItemFuncEvent read FOnFuncDir    write FOnFuncDir ;
     property OnFuncFile:TItemFuncEvent read FOnFuncFile   write FOnFuncFile;
  end;

procedure FillDirList(RootPath:String;Recurse:Boolean;List:TStrings);
procedure FillFileList(RootPath,Mask:String;Recurse:Boolean;List:TStrings);

implementation
{TDirectory}
constructor TDirectory.Create;
begin
   inherited Create;
   FMask:=TStringList.Create;
   FRecurse:=True;
end;
destructor TDirectory.Destroy;
begin
   FMask.Free;
   inherited Destroy;
end;
function TDirectory.GetMask:String;
var
   I:Integer;
begin
   Result:='';
   for I:=0 to FMask.Count-1 do
   begin
     if I <> FMask.Count-1 then
        Result:=Result+FMask[I]+';'
     else
        Result:=Result+FMask[I];
   end;
end;
procedure TDirectory.SetMask(Value:String);
var
   I:Integer;
   MVal:String;
begin
   MVal:='';
   for I:=1 to Length(Value) do
   begin
      if Value[I] = ';' then
      begin
         if MVal <> '' then FMask.Add(MVal);
         MVal:='';
      end
      else
      begin
         MVal:=MVal+Value[I];
      end;        
   end;
   if MVal <> '' then FMask.Add(MVal);
end;   
procedure TDirectory.ProcessPath(Path:String);
var
   PathSearchRec:TSearchRec;
   SearchRec:TSearchRec;
   Res,I:Integer;
   DoneDir:Boolean;
begin
   if Path[Length(Path)] <> '\' then Path:=Path+'\';
   if Mask = '' then Mask:='*.*';
   if FAttr = 0 then FAttr:=$27; // all files not Dirs or Vols
   if FRecurse then
   begin
      Res:=FindFirst(Path+'*.*',faDirectory,PathSearchRec);
      while Res = 0 do
      begin
         if (PathSearchRec.Name <> '.') and (PathSearchRec.Name <> '..') then
               ProcessPath(Path+PathSearchRec.Name);
         Res:=FindNext(PathSearchRec);
         Application.ProcessMessages;
         if Application.Terminated then Exit;
      end;
      FindClose(PathSearchRec);
   end;
   DoneDir:=False;
   for I:=0 to FMask.Count-1 do
   begin
      Application.ProcessMessages;
      Res:=FindFirst(Path+FMask[I],FAttr,SearchRec);
      if (not DoneDir) and (FAllDirs or (Res = 0)) and Assigned(OnDir) then
      begin
         DoneDir:=True;
         FindFirst(Path+'*.*',faDirectory,PathSearchRec);
         OnDir(Path,PathSearchRec);
         FindClose(PathSearchRec);
      end;

      Application.ProcessMessages;
      if Application.Terminated then Exit;
      if Res = 0 then
      begin
         while Res = 0 do
         begin
            if Assigned(OnFile) then OnFile(Path+SearchRec.Name,SearchRec);
            Res:=FindNext(SearchRec);
         end;

         FindClose(SearchRec);
      end;
   end;
end;
procedure TDirectory.SetRootPath(Value:String);
begin
   FRootPath:=Value;
   ProcessPath(FRootPath);
end;
procedure TDirectory.DirectoryOnDir(Name:String;Details:TSearchRec);
begin
   if Assigned(OnFuncDir) then
      OnFuncDir(Name,Details);
end;
procedure TDirectory.DirectoryOnFile(Name:String;Details:TSearchRec);
begin
   if Assigned(OnFuncFile) then
      OnFuncFile(Name,Details);
end;
// -----------------------------------------------------------------------------
//                            support functions
// -----------------------------------------------------------------------------
var
   GlobList:TStrings;

procedure ProcessFunc(Name:String;Details:TSearchRec);
begin
   if GlobList <> nil then
   begin
      if Copy(Name,Length(Name),1) = '\' then
         GlobList.AddObject(Copy(Name,1,Length(Name)-1),TObject(Details.Time))
      else
         GlobList.AddObject(Name,TObject(Details.Time));
   end;
end;
procedure FillFileList(RootPath,Mask:String;Recurse:Boolean;List:TStrings);
var
   Dir:TDirectory;
begin
   if List = nil then Exit;
   GlobList:=List;
   Dir:=TDirectory.Create;
   Dir.Mask:=Mask;
   Dir.AllDirs:=False;
   Dir.OnFile:=Dir.DirectoryOnFile;
   Dir.OnDir:=Dir.DirectoryOnDir;
   Dir.OnFuncFile:=ProcessFunc;
   Dir.Recurse:=Recurse;
   Dir.RootPath:=RootPath;
   Dir.Free;
   GlobList:=nil;
end;
procedure FillDirList(RootPath:String;Recurse:Boolean;List:TStrings);
var
   Dir:TDirectory;
begin
   if List = nil then Exit;
   GlobList:=List;
   Dir:=TDirectory.Create;
   Dir.AllDirs:=False;
   Dir.Attr:=$FF;
   Dir.OnFile:=Dir.DirectoryOnFile;
   Dir.OnDir:=Dir.DirectoryOnDir;
   Dir.OnFuncDir:=ProcessFunc;
   Dir.Recurse:=Recurse;
   Dir.RootPath:=RootPath;
   Dir.Free;
   GlobList:=nil;
end;

end.
