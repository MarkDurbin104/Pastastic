unit RegUtils;

interface

uses
   Windows,Sysutils,Classes,Registry;
type
   TRegUtil = class(TObject)
   public
      procedure HiveToFile(FileName:String;Key:HKey;Path:String);
      procedure FileToHive(FileName,Value:String);
      function GetHive(Key:HKey;Path:String):String;
      procedure SetHive(Value:String);
      function GetValue(Key:HKey;Path,Name:String):String;
      function SetString(Key:HKey;Path,Name,Value:String):String;
   end;               
implementation

procedure TRegUtil.HiveToFile(FileName:String;Key:HKey;Path:String);
var
   SL:TStringList;
begin
   SL:=TStringList.Create;
   try
      SL.CommaText:=GetHive(Key,Path);
      SL.SaveToFile(FileName);
   except
      ; // Error Handling
   end;
   SL.Free
end;
procedure TRegUtil.FileToHive(FileName,Value:String);
var
   SL:TStringList;
begin
   SL:=TStringList.Create;
   try
      SL.LoadFromFile(FileName);
      SetHive(SL.CommaText);
   except
      ; // Error Handling
   end;
   SL.Free
end;
function TRegUtil.GetHive(Key:HKey;Path:String):String;
var
   SL:TStringList;
   List:TStringList;
   I:Integer;
begin              
   Result:='';
   SL:=TStringList.Create;
   List:=TStringList.Create;
   with TRegistry.Create do
   begin
      RootKey:=Key;
      if OpenKey(Path,False) then
      begin
         SL.Add('K'+IntToStr(Key));
         SL.Add('P'+Path);
         GetValueNames(List);
         for I:=0 to List.Count-1 do
            List[I]:='"'+List[I]+'","'+ReadString(List[I])+'"';
         SL.Add('V'+List.CommaText);
         if HasSubKeys then
         begin
            GetKeyNames(List);
            CloseKey;
            Free;
            for I:=0 to List.Count-1 do
               SL.Add(GetHive(Key,Path+'\'+List[I]));
         end
         else
         begin
            CloseKey;
            Free;
         end;
      end;
   end;
   Result:=SL.CommaText;
   SL.Free;
   List.Free;
end;
procedure TRegUtil.SetHive(Value:String);
var
   SL:TStringList;
   List:TStringList;
   Line:TStringList;
   I:Integer;
   Path:String;
   Key:HKey;
begin              
   if Value = '' then Exit;
   Path:='';
   Key:=-1;
   
   SL:=TStringList.Create;
   SL.CommaText:=Value;
   
   if (SL.Count > 0) and (SL[0][1] <> 'K') then
      Key:=StrToIntDef(Copy(SL[0],2,Length(SL[0])),HKEY_CLASSES_ROOT);
   if (SL.Count > 0) then SL.Delete(0);
   
   if (SL.Count > 0) and (SL[0][1] <> 'P') then
      Path:=Copy(SL[0],2,Length(SL[0]));
   if (SL.Count > 0) then SL.Delete(0);
   
   if (Path = '') or (Key = -1) then Exit;
   with TRegistry.Create do
   begin
      RootKey:=Key;
      if OpenKey(Path,True) then
      begin
         if (SL.Count > 0) and (SL[0][1] <> 'V') then
         begin
            List:=TStringList.Create;
            Line:=TStringList.Create;
            List.CommaText:=SL[0];
            for I:=0 to List.Count-1 do
            begin
               Line.CommaText:=List[I];
               if Line.Count = 2 then
                  WriteString(Line[0],Line[1]);
            end;
            Line.Free;
            List.Free;
         end;
         CloseKey;
         Free;
         SL.Delete(0);
         while SL.Count > 0 do
            SetHive(SL.CommaText);
      end;
   end;
   SL.Free;
end;
function TRegUtil.GetValue(Key:HKey;Path,Name:String):String;
begin
   Result:='';
   try
      with TRegistry.Create do
      begin
         RootKey:=Key;
         if OpenKey(Path,False) then
         begin
            Result:=ReadString(Name);
            CloseKey;
         end;
         Free;
      end;
   except
     // Log Error 
   end;
end;
function TRegUtil.SetString(Key:HKey;Path,Name,Value:String):String;
begin
   try
      with TRegistry.Create do
      begin
         RootKey:=Key;
         if OpenKey(Path,False) then
         begin
            WriteString(Name,Value);
            CloseKey;
         end;
         Free;
      end;
   except
     // Log Error 
   end;
end;

end.   
