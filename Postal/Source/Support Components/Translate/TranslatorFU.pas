unit TranslatorFU;

interface

uses
  CommonConst,
  FileCtrl,PackStrListU,StringUtil,
  Forms, Classes, Controls, StdCtrls,SysUtils,GPCSGUID,WideStringListU;

type
  TLanguage = class(TObject)
     FIsBase:Boolean;
     FPath:String;
     FName:String;
     FCode:Integer;
     FModified:Boolean;
     FSaveOnAdd:Boolean;
     FSaveOnClose:Boolean;
     StrList:TStringList;
     FindList:TStringList;
     PFindList:^TStringList;
     PStrList:^TStringList;
     function TakeOffQuotes(Text:String):String;
  public
     constructor Create(Path,Name:String;Code:Integer;IsBase:Boolean);
     destructor Destroy; override;
     procedure InvertTranslationOn;
     procedure InvertTranslationOff;
     procedure Save;
     function TranslateList(Cols,Value:WideString):WideString;
     function TranslateString(Text:WideString):WideString;
     function TranslateItem(Text:WideString):WideString;
     function TranslateColumns(Text:wideString):WideString;
     function TranslateCleanItem(Text:String):string;
     function CodeAsString:String;
     property Path:String  read FPath write FPath;
     property Name:String  read FName write FName;
     property Code:Integer read FCode write FCode;
     property Modified:Boolean read FModified write FModified;
     property SaveOnAdd  :Boolean read FSaveOnAdd   write FSaveOnAdd  ;
     property SaveOnClose:Boolean read FSaveOnClose write FSaveOnClose;
  end;
  TTransForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    DefaultLang: TEdit;
    Alternatives: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure SetLanguageName(Name:String);
    function  GetLanguageName:String;
    procedure SetLanguageCode(Code:Integer);
    function  GetLanguageCode:Integer;
  public
    LanguageList:TStringList;
    DefaultLanguage:TLanguage;
    CurrentLanguage:TLanguage;
    procedure SaveAll;
    procedure SetSaveOnClose(State:Boolean);
    procedure SetSaveOnAdd(State:Boolean);
    property LanguageName:String read GetLanguageName write SetLanguageName;
    property LanguageCode:Integer read GetLanguageCode write SetLanguageCode;
  end;

var
  TransForm: TTransForm;

implementation

{$R *.DFM}

function TLanguage.TakeOffQuotes(Text:String):String;
begin
   if (Length(Text) > 1) and (Text[1] = '"') and (Text[Length(Text)] = '"') then
      Text:=Copy(Text,2,Length(Text)-2);
   Result:=Trim(Text);
end;
function TLanguage.CodeAsString:String;
begin
   Result:=IntToHex(FCode,8);
end;

function TLanguage.TranslateString(Text:WideString):WideString;
begin

   if UpperCase(Copy(Text,1,6))<> '<GRID:' then
      result := TranslateItem(Text)
   else
      result:=TranslateColumns(Text);

end ;

function TLanguage.TranslateColumns(Text:wideString):WideString;
var
   SCol:TStringList;
   P:integer;
   SL:TPackStringList;
   I,J:integer;
   SLItem:TPackStringList;
   Max:integer;
   Col:integer;
   AllItems:boolean;
   GridParameters:String;
begin

   Max:=0;
   P:=Pos('>', Text);
   GridParameters := UpperCase( Copy(Text,7,p-1-6 )) ;
   SCol  := TStringList.Create;
   SL    := TPackStringList.Create;
   SLItem:= TPackStringList.Create;
   AllItems:=False;
   SL.CommaText:= Copy( Text, p+1, Length( Text )-p);

   if Pos( 'ALLITEMS', GridParameters ) > 0  then
      AllItems:=True
   else
      SCol.CommaText := Copy(Text,7,p-1-6 ) ;

   if not AllItems  then
   begin
      if (SL.Count-1>0) then
      begin
         SLItem.CommaText := SL[0];
         Max:= SLItem.Count-1 ;
      end;

      //Cheking for the valid columns
         J:= 0;
      while J <= SCol.Count-1 do
      begin
         Col:= StrToIntDef( Scol[j], -1 );
         if ( Col > 0) and ( Col <= Max ) then
            Inc( J )
         else
            SCol.Delete(J);
      end;
   end;

   for i:= 0 to SL.Count-1do
   begin
      SLItem.CommaText := SL[i];
      if AllItems then
      begin
         for j:=0 to SlItem.Count-1 do  // <Grid:ALLITEMS>
            //if (CopyFromCol>0) and ((ColToCopy-1)=J) then
            //   SlItem[ j ] := Copy(SLItem[j],1,CopyFromCol-1)+
            //                  Copy(TranslateItem(SlItem[j]), CopyFromCol, Length(SlItem[j] ) - CopyFromCol+1 )
            //else
              SlItem[ j ] := TranslateItem( SlItem[ j ] );
      end
      else
         for j:=0 to SCol.Count-1 do // use the columns pass in the parameters <Grid:1,2,3>
         begin
            Col:= StrToIntDef(SCol[J],0);
            if Col <= SLItem.Count -1 then
               SlItem[ Col ] := TranslateItem( SlItem[ Col ] );
         end;
      SL[i]:=SLItem.CommaText;
   end;
   result := SL.CommaText;

   SL.Free;
   SCol.Free;
   SLItem.Free;

end;
function TLanguage.TranslateItem(Text:WideString):WideString;
var
   CleanText,SubStr:string;
   P :integer;
   S:String;
begin
   S:=Text;

   Result:='';

   p:= Pos( CHRTRL,S);
   SubStr :=SubString(S,CHRTRL,CHRTRL); // find then in pears
   CleanText:=S;
   if (Length(SubStr)>0) then
      CleanText :=Copy( S,1,p-1)
   else
      if FIsBase then
      begin
         Result := S;
         Exit;
      end;


   repeat

      if FIsBase then
         Result := Result + CleanText +SubStr   // just to remove CHRTRL
      else
         Result := Result + TranslateCleanItem(CleanText)+SubStr;

      S := Copy( S, Length(CleanText+SubStr)+3, Length(S)-(Length(CleanText+SubStr)+2));

      p:= Pos( CHRTRL,S);
      SubStr :=SubString(S,CHRTRL,CHRTRL); // find then in pears
      CleanText:=S;
      if (Length(SubStr)>0) then
         CleanText :=Copy( S,1,p-1);



   until S='' ;


end ;
function TLanguage.TranslateCleanItem(Text:String):String;
var
   J,I:integer;
   S:String;
//   SpcBgn:integer;
   TxtCut:String;
begin

   Result:=Text;

   // sort out numbers !!!! MJD
   if (Text = '')
   or ((Length(Text) = 18) and ((Copy(Text,1,2)='TI') or (Copy(Text,1,2)='RC')))
   or (Copy(Text,1,25) ='Select the quantities of ') then
      Exit;

   i:=1 ;
   TxtCut:='';
   if Text<>'' then
   begin
      while (i<=Length(Text)) and
            ( (Text[i]=' ') or
              (Text[i]='^') or
              (Text[i]='<') or
              (Text[i]='>') or
              (Text[i]=':') ) do
      begin
         TxtCut:=TxtCut+Text[i];
         Inc(i);
      end;
      J:= Length(TxtCut);
      if J >0 then
         Text :=Copy(Text,J+1,Length(Text)-j);
   end;
   Text:=TakeOffQuotes(Text);
   S:=Text;
   for I:=1 to Length(S) do
   begin
      if (S[I] in ['0'..'9','-','+']) then
      begin
             if I = Length(S) then Exit;
         end
      else
      begin
         break;
      end;
   end;
   I:=PFindList^.IndexOf(Trim(Text));
   if I <> -1 then
   begin
       S:=PStrList^[I];
       S := TxtCut + S ;
       //for j :=0 to SpcBgn-1 do S :=' '+S;
      Result:=S;
      Exit;
   end;
   if (PFindList^[0]=FindList[0]) then  //if is in English to ....
   begin
      StrList.Add(Text);
      FindList.Add(Text);
      FModified:=True;
   end;
   if FSaveOnAdd then
      Save;

end;
function TLanguage.TranslateList(Cols,Value:WideString):WideString;
var
   RecordList:TStringList;
   FieldList :TStringList;
   ColsList :TStringList;
   I:Integer;
   J:Integer;
   HasComma:Boolean;
begin

   RecordList:=TStringList.Create;
   FieldList :=TStringList.Create;
   ColsList :=TStringList.Create;

   ColsList.CommaText:=Cols;

   HasComma:=False;
   for I:=1 to Length(Value) do
   begin
      if Value[I] = ',' then
      begin
         HasComma:=True;
         break;
      end;
   end;

   if HasComma then
      RecordList.CommaText:=Value
   else
      RecordList.Text:=Value;

   if RecordList.Count = 1 then
   begin
      Result:=TranslateString(Value);
   end
   else
   begin
      for I:=0 to RecordList.Count-1 do
      begin
         FieldList.CommaText:=RecordList[I];
         for J:=0 to FieldList.Count-1 do
         begin
            if (ColsList.Count < 1) or (ColsList[J] <> '0') then
               FieldList[J]:=TranslateString(FieldList[J]);
         end;
         RecordList[I]:=FieldList.CommaText;
      end;
      Result:=RecordList.CommaText;
   end;
   RecordList.Free;
   FieldList .Free;
   ColsList .Free;
end;
constructor TLanguage.Create(Path,Name:String;Code:Integer;IsBase:Boolean);
var
   SL:TStringList;
   TSL:TStringList;
   I:Integer;
begin
	 FSaveOnAdd := ('Add'=GetGPCSRegString('Language','UpdateOn',''));
   FPath:=Path;
   FName:=Name;
   FCode:=Code;
   FIsBase:=IsBase;
   if FIsBase then Exit;
   SL:=TStringList.Create;  
   StrList:=TStringList.Create;
   FindList:=TStringList.Create;
   PFindList:=@FindList;
   PStrList:=@StrList;
	 try
		If FileExists(FPath+'\'+FName+'.txt') then
			StrList.LoadFromFile(FPath+'\'+FName+'.txt');
   except
      ;
   end;
   TSL:=TStringList.Create;
   for I:=0 to StrList.Count-1 do
   begin
      SL.CommaText:=StrList[I];
      if (SL.Count = 2) and (FindList.IndexOf(SL[0]) = -1) then
      begin
         FindList.Add(TakeOffQuotes(SL[0]));
         TSL.Add(TakeOffQuotes(SL[1]));
      end;
   end;
   StrList.Clear;
   StrList.Assign(TSL);
   SL.Free;
   FModified:=False;
end;
procedure TLanguage.Save;
var
	SaveList : TStringList;
	 I:Integer;
begin
	if FIsBase then Exit;
	if FModified then
	begin
		SaveList := TStringList.Create;
		for I:=0 to StrList.Count-1 do
			SaveList.Add('"'+FindList[I]+'","'+StrList[I]+'"');
		ForceDirectories(FPath);
		SaveList.SaveToFile(FPath+'\'+FName+'.txt');
		SaveList.Free;
	end;
end;
procedure TLanguage.InvertTranslationOn;
begin
   PFindList:= @StrList;
   PStrList := @FindList;
end ;
procedure TLanguage.InvertTranslationOff;
begin
   PFindList:= @FindList;
   PStrList := @StrList;
end;
destructor TLanguage.Destroy;
begin
   if FSaveOnClose then Save;
   if not FIsBase then
   begin
      StrList.Free;
      FindList.Free;
   end;
   inherited Destroy;
end;

{TTransForm}
function TTransForm.GetLanguageName:String;
begin
   Result:=CurrentLanguage.Name
end;   
procedure TTransForm.SetLanguageName(Name:String);
var
   I:Integer;
begin          
   I:=LanguageList.IndexOf(Name);
   if I <> -1 then CurrentLanguage:=TLanguage(LanguageList.Objects[I]);
end;
function TTransForm.GetLanguageCode:Integer;
begin
   Result:=CurrentLanguage.Code
end;   
procedure TTransForm.SetLanguageCode(Code:Integer);
var
   I:Integer;
begin          
   for I:=0 to LanguageList.Count-1 do
   begin
      if TLanguage(LanguageList.Objects[I]).Code = Code then
      begin
         CurrentLanguage:=TLanguage(LanguageList.Objects[I]);
         break;
      end;
   end;
end;
procedure TTransForm.FormCreate(Sender: TObject);
var
   I:Integer;
   DefLang:String;
   Code:String;
   Path:String;
   Base:String;
   Language:TLanguage;
begin
   DefaultLanguage:=nil;
   LanguageList:=TStringList.Create;
   Base:=GetGPCSRegString('Language','BaseLanguage','00000809');
   Path:=GetGPCSRegString('Language','FilePath','C:\Language');
	 DefLang:=GetGPCSRegString('Language','LanguageID','00000809');
	 LanguageList.CommaText:=GetGPCSRegNames('Language\Alternatives','');
   for I:=0 to LanguageList.Count-1 do
   begin
			Code:=GetGPCSRegString('Language\Alternatives',LanguageList[I],'00000809');
      Language:=TLanguage.Create(Path,LanguageList[I],StrToInt('$'+Code),Base = Code);
      LanguageList.Objects[I]:=Language;
      if Language.CodeAsString = DefLang then
         DefaultLanguage:=Language
      else
         Alternatives.Items.Add(Language.Name);
   end;
   if DefaultLanguage = nil then
   begin
      DefaultLanguage:=TLanguage.Create(Path,'English',$809,True);
      LanguageList.AddObject('English',DefaultLanguage);
   end;
   DefaultLang.Text:=DefaultLanguage.Name;
   CurrentLanguage:=DefaultLanguage;
end;

procedure TTransForm.FormDestroy(Sender: TObject);
var
   I:Integer;
begin
   for I:=0 to LanguageList.Count-1 do
      if LanguageList.Objects[I] <> nil then
         TLanguage(LanguageList.Objects[I]).Free;
   LanguageList.Free;
end;
procedure TTransForm.SaveAll;
var
   I:Integer;
begin
   for I:=0 to LanguageList.Count-1 do
      TLanguage(LanguageList.Objects[I]).Save;
end;
procedure TTransForm.SetSaveOnClose(State:Boolean);
var
   I:Integer;
begin
   for I:=0 to LanguageList.Count-1 do
      TLanguage(LanguageList.Objects[I]).SaveOnClose:=State;
end;
procedure TTransForm.SetSaveOnAdd(State:Boolean);
var
   I:Integer;
begin
   for I:=0 to LanguageList.Count-1 do
      TLanguage(LanguageList.Objects[I]).SaveOnAdd:=State;
end;

end.
