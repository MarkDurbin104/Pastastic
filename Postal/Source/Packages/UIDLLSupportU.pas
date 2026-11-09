unit UIDLLSupportU;

interface

uses
   Windows,Graphics,Classes,SysUtils,
   PackStrListU,ShareDataU;
type
   TCallBack = function(Name:String;Modal:Boolean):Integer;
   
function GetOfficeName(Code:Integer):String;
function GetFieldContents(FieldName:String):String;
procedure SetFieldContents(FieldName,Value:String);
procedure ClearForm;
function GetFocusedFieldName:String;
procedure SetFocus(FieldName:String); 
procedure OfficeCodeMapping(var OfficeCodes:Array of Integer);
function GetOfficeType(Code:Integer):String;
                                      
   // you must create/destroy this var in your UIDLLStartup/UIDLLShutdown routines
   // before calling GetFieldContents, SetFieldContents, GetFocusedFieldName or SetFocus
var
   SharedData:TSharedData;
   MainCallBack:TCallBack;  
                    
implementation

function GetOfficeName(Code:Integer):String;
var
   S:String;
begin
   if (@MainCallBack <> nil) then
   begin
      S:='OfficeName.'+IntToStr(Code);
      MainCallBack(S,False);
      Result:=SharedData.GetVariable(S);
   end;
end;
function GetOfficeType(Code:Integer):String;
var
   S:String;
begin
   if (@MainCallBack <> nil) then
   begin
      S:='OfficeType.'+IntToStr(Code);
      MainCallBack(S,False);
      Result:=SharedData.GetVariable('OfficeType');
   end;
end;
procedure OfficeCodeMapping(var OfficeCodes:Array of Integer);
var
   I:Integer;
   SL:TPackStringlist;
begin
   for I:=0 to 1023 do 
      OfficeCodes[I]:=0;
   SL:=TPackStringlist.Create;
   SL.PackText:=SharedData.GetVariable('OfficeCodeMapping');
   for I:=0 to SL.Count-1 do 
      OfficeCodes[I]:=StrToIntDef(SL[I],0);
   SL.Free;
end;
function GetFocusedFieldName:String;
var
   I:Integer;
   LSL:TPackStringList;
   SL:TPackStringList;
   FormData:String;
begin
   FormData:=SharedData.GetVariable('FormData');
   Result:='';
   SL:=TPackStringList.Create;
   LSL:=TPackStringList.Create;
   SL.PackText:=FormData;
   for I:=0 to SL.Count-1 do
   begin
      LSL.PackText:=SL[I];
      if (LSL.Count > 2) and (LSL[2] = 'Focused') then
      begin
         Result:=LSL[0];
         LSL.Free;
         SL.Free;
         Exit;
      end;
   end;
   LSL.Free;
   SL.Free;
end;
procedure SetFocus(FieldName:String); 
var
   I:Integer;
   LSL:TPackStringList;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   LSL:=TPackStringList.Create;
   SL.PackText:=SharedData.GetVariable('FormData');
   for I:=0 to SL.Count-1 do
   begin
      LSL.PackText:=SL[I];
      if (LSL.Count > 2) and (LSL[2] = 'Focused') then
         LSL.Delete(2);
      if (LSL.Count > 1) and (LSL[0] = FieldName) then
         LSL.Add('Focused');
      SL[I]:=LSL.PackText;
   end;   
   SharedData.SetVariable('FormData',SL.PackText);
   LSL.Free;
   SL.Free;
end;                            
function GetFieldContents(FieldName:String):String;
var
   I:Integer;
   LSL:TPackStringList;
   SL:TPackStringList;
   FormData:String;
begin
   FormData:=SharedData.GetVariable('FormData');
   Result:='';
   SL:=TPackStringList.Create;
   LSL:=TPackStringList.Create;
   SL.PackText:=FormData;
   for I:=0 to SL.Count-1 do
   begin
      LSL.PackText:=SL[I];
      if (LSL.Count > 1) and (LSL[0] = FieldName) then
      begin
         Result:=LSL[1];
         LSL.Free;
         SL.Free;
         Exit;
      end;
   end;
   LSL.Free;
   SL.Free;
end;
procedure SetFieldContents(FieldName,Value:String);
var
   I:Integer;
   LSL:TPackStringList;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   LSL:=TPackStringList.Create;
   SL.PackText:=SharedData.GetVariable('FormData');
   for I:=0 to SL.Count-1 do
   begin
      LSL.PackText:=SL[I];
      if LSL.Count > 1 then
      begin
         if LSL[0] = FieldName then
         begin
            LSL[1]:=Value;
            SL[I]:=LSL.PackText;
            SharedData.SetVariable('FormData',SL.PackText);
            LSL.Free;
            SL.Free;
            Exit;
         end;
      end;
   end;
   LSL.Free;
   SL.Free;
end;

// Sets all Form fields to ''
procedure ClearForm;
var
   I:Integer;
   FormSL:TPackStringList;
   FieldSL:TPackStringList;
begin
   FormSL:=TPackStringList.Create;
   FieldSL:=TPackStringList.Create;
   FormSL.PackText:=SharedData.GetVariable('FormData');
   for I:=0 to FormSL.Count-1 do
   begin
      FieldSL.PackText:=FormSL[I];
      SetFieldContents(FieldSL[0],'');
   end;
   FieldSL.Free;
   FormSL.Free;
end;

end.
