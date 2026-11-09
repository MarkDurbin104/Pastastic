unit RegDocGenFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,ComObj,Registry,StringUtil,DirectoryU,GPCSGUID;

type
  TFindCallBack = procedure(P:PChar;FileName:String;LineNumber:Integer);
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    OD: TOpenDialog;
    Memo2: TMemo;
    Memo3: TMemo;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Button4: TButton;
    Memo4: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

const
  wdBorderTop = -1;
  wdBorderLeft = -2;
  wdBorderBottom = -3;
  wdBorderRight = -4;
  wdBorderHorizontal = -5;
  wdBorderVertical = -6;
  wdBorderDiagonalDown = -7;
  wdBorderDiagonalUp = -8;
var
    LineNumber:Integer;
    TotalLines:Integer;
    
function GetToken(var P:PChar;MovePointer:Boolean;var IsIdent,IsString:Boolean):String;
var
  TokenPtr:PChar;
  SP:PChar;
  procedure RemWSpace;
  begin
     while ((P^ <> #0) and (P^ <= ' ')) do  // remove whitespace
     begin
        if P^ = #10 then begin Inc(LineNumber); Inc(TotalLines); end;
        Inc(P);
     end;
  end;
begin
  SP:=P;
  IsIdent:=False;
  IsString:=False;
  Result:='';
  RemWSpace;
  while (P^ = '/') or ((P^ = '(') and ((P+1)^ = '*')) or (P^ = '{')  do
  begin
     if (P^ = '/') then
     begin
        Inc(P);
        if (P^ = '/') then // single line commenting '// .. EOL'
        begin
           while (P^ <> #0) and (P^ <> #10) do Inc(P);
        end;
     end
     else if ((P^ = '(') and ((P+1)^ = '*')) then
     begin
        Inc(P);
        while (P^ <> #0) do 
        begin
           if (P^ = '*') and ((P+1)^ = ')') then 
           begin
              Inc(P,2);
              break;
           end;
           if P^ = #10 then begin Inc(LineNumber); Inc(TotalLines); end;
           Inc(P);
        end;
     end
     else if (P^ = '{') then
     begin
        Inc(P);
        while (P^ <> #0) do 
        begin
           if (P^ = '}')then 
           begin
              Inc(P);
              break;
           end;
           if P^ = #10 then begin Inc(LineNumber); Inc(TotalLines); end;
           Inc(P);
        end;
     end;   
     RemWSpace;
  end;
  TokenPtr := P;
  case P^ of
    'A'..'Z', 'a'..'z', '_', #$81..#$fe:
      begin
        Inc(P);
        while P^ in ['0'..'9','A'..'Z','a'..'z','_','-',#$81..#$fe] do Inc(P);
        IsIdent:=True;
      end;
    '''':
      begin
        Inc(P);
        while True do
        begin
          if P^ = #0 then Exit;
          if P^ = #10 then begin Inc(LineNumber); Inc(TotalLines); end;
          if P^ = '''' then
          begin
            Inc(P);
            if P^ <> '''' then Break;
          end;
          Inc(P);
        end;
        IsString:=True;
      end;
    '+','-','0'..'9':
      begin
        Inc(P);                                                                                 
        while P^ in ['0'..'9', '.', 'e', 'E', '+', '-'] do Inc(P);
      end;
    '<':
      begin
        Inc(P);
        case P^ of
          '=':
            begin
              Inc(P);
            end;
          '>':
            begin
              Inc(P);
            end;
        end;
      end;
    '>':
      begin
        Inc(P);
        if P^ = '=' then
        begin
          Inc(P);
        end
      end;
    else
       Inc(P);
  end;
  if P <> TokenPtr then
  begin
     SetString(Result,TokenPtr,P-TokenPtr);
  end;
  if not MovePointer then P:=SP;
end;
function GetUsesList(FileName:String;UsesList,TokenList,StringsList:TStrings):String;
var
   S:String;
   P:PChar;
   MS:TMemoryStream;
   IsIdent:Boolean;
   IsString:Boolean;
   I,Idx:Integer;
   CollectTokens:Boolean;
begin
   Result:=UsesList.CommaText;
   CollectTokens:=False;
   if not FileExists(FileName) then Exit;
   MS:=TMemoryStream.Create;
   MS.LoadFromFile(FileName);
   MS.Position:=MS.Size;
   I:=0;
   MS.Write(I,SizeOf(Integer));
   MS.Position:=0;
   P:=MS.Memory;
   While P^ <> #0 do
   begin
      S:=GetToken(P,True,IsIdent,IsString);
      if IsString and (StringsList <> nil) then
      begin
         Idx:=StringsList.IndexOf(S);
         if Idx <> -1 then
            StringsList.Objects[Idx]:=TObject(Integer(StringsList.Objects[Idx])+1)
         else
            StringsList.AddObject(S,TObject(1));
      end
      else if (TokenList <> nil) then 
      begin
         Idx:=TokenList.IndexOf(S);
         if Idx <> -1 then
            TokenList.Objects[Idx]:=TObject(Integer(TokenList.Objects[Idx])+1)
         else
            TokenList.AddObject(S,TObject(1));
      end;
      if UsesList <> nil then
      begin
         if CollectTokens then
         begin
            if (S = ';') then 
               CollectTokens:=False
            else if IsIdent and (S <> 'in') and (UsesList.IndexOf(S) = -1) then 
               UsesList.Add(S);
         end; 
         if Uppercase(S) = 'USES' then 
            CollectTokens:=True;
      end; 
   end;    
   MS.Free;
   Result:=UsesList.CommaText;
end;
procedure FindAllPasFiles(FileName,SearchPath:String;UsesList,TokenList,StringsList:TStrings);
var
   S:String;
   SL:TStringList;
   I,Idx:Integer;
begin
   if not FileExists(FileName) then Exit;
   SL:=TStringList.Create;
   FillFileList(SearchPath,'*.pas',True,SL);
   FillFileList(ExtractFilePath(FileName),'*.pas',False,SL);
   for I:=0 to SL.Count-1 do
   begin
      S:=SL[I];
      SL[I]:=ExtractFileName(SL[I]);
      SL[I]:=Copy(SL[I],1,Length(SL[I])-Length(ExtractFileExt(SL[I])));
      SL.Objects[I]:=TStringObject.Create(S);
   end;
   GetUsesList(FileName,UsesList,TokenList,StringsList);
   I:=0;
   while I < UsesList.Count do
   begin
      Idx:=SL.IndexOf(UsesList[I]);
      if Idx <> -1 then
      begin
         GetUsesList(TStringObject(SL.Objects[Idx]).Value,UsesList,TokenList,StringsList);
      end;
      Inc(I);
   end;   
   I:=0;
   while I < UsesList.Count do
   begin
      Idx:=SL.IndexOf(UsesList[I]);
      if Idx <> -1 then
      begin
         UsesList[I]:=TStringObject(SL.Objects[Idx]).Value;
         Inc(I);
      end
      else
         UsesList.Delete(I);
   end;   
   UsesList.Insert(0,FileName);
   
   for I:=0 to SL.Count-1 do
      TStringObject(SL.Objects[I]).Free;
   SL.Free;
end;
procedure CallForEachInstance(FileName,Str:String;CallBack:TFindCallBack);
var
   P:PChar;
   S:String;
   MS:TMemoryStream;
   IsIdent:Boolean;
   IsString:Boolean;
   I:Integer;
begin
   if not FileExists(FileName) then Exit;
   MS:=TMemoryStream.Create;
   MS.LoadFromFile(FileName);
   MS.Position:=MS.Size;
   I:=0;
   MS.Write(I,SizeOf(Integer));
   MS.Position:=0;
   P:=MS.Memory;
   LineNumber:=1;
   While P^ <> #0 do
   begin
      S:=GetToken(P,True,IsIdent,IsString);
      if IsIdent and (S = Str) then
         CallBack((P-Length(Str)),FileName,LineNumber);
   end;    
   MS.Free;
end;

procedure FindAllInstancesOf(SearchPath,Str:String;CallBack:TFindCallBack);
var
   SL:TStringList;
begin
   SL:=TStringList.Create;
   FillFileList(SearchPath,'*.pas',True,SL);
   while SL.Count > 0 do
   begin
      CallForEachInstance(SL[0],Str,CallBack);
      SL.Delete(0);
   end;
   SL.Free;
end;
procedure InsertPBreakInWord(WordApp:Variant);
begin
   WordApp.Selection.InsertBreak(Type:=0); // page break
end;
procedure InsertTableInWord(WordApp:Variant;List:TStrings;WithBreak:Boolean);
var
   I:Integer;
   Table:Variant;
   Shape:Variant;
   LastCell:String;
begin
   WordApp.Selection.TypeParagraph;
   Table:=WordApp.ActiveDocument.Tables.Add(Range:=WordApp.Selection.Range,NumRows:=2,NumColumns:=2);
   Table.AutoFormat(0,False,False,False,False,False,False,False,False,Unassigned);
   WordApp.Selection.SelectColumn;
   WordApp.Selection.Columns.PreferredWidthType := 3; // wdPreferredWidthPoints
   WordApp.Selection.Columns.PreferredWidth := 80;
   WordApp.Selection.Font.Size:=10;
   WordApp.Selection.Font.Bold:=9999998; // wdToggle
   WordApp.Selection.ParagraphFormat.Alignment:=2; // wdAlignParagraphRight
   WordApp.Selection.MoveRight(Unit:=1,Count:=1); // 1 = wdCharacter
   WordApp.Selection.SelectColumn;
   WordApp.Selection.Columns.PreferredWidthType := 3; // wdPreferredWidthPoints
   WordApp.Selection.Columns.PreferredWidth := 350;
   WordApp.Selection.Font.Size:=12;
   WordApp.Selection.MoveLeft(Unit:=1,Count:=1); // 1 = wdCharacter
   WordApp.Selection.SelectRow;
   WordApp.Selection.Font.Bold:=9999998; // wdToggle
   WordApp.Selection.Font.Bold:=9999998; // wdToggle
   WordApp.Selection.Font.Size:=12;
   WordApp.Selection.MoveLeft(Unit:=1,Count:=1); // 1 = wdCharacter
//   Table.AutoFitBehavior(2); // wdAutoFitContent
   LastCell:='';
   for I:=0 to List.Count-1 do
   begin
      if LastCell = 'Bitmap' then
      begin
//         if FileExists(AbsolutePath(List[I])) then
         if FileExists(List[I]) then
         begin
            WordApp.Selection.TypeParagraph;
            WordApp.Selection.InlineShapes.AddPicture(List[I],False,True);
//            WordApp.Selection.InlineShapes.AddPicture(AbsolutePath(List[I]),False,True);
            WordApp.Selection.MoveLeft(Unit:=1,Count:=1,Extend:=1); // Select Picture
            Shape:=WordApp.Selection.InlineShapes.item(WordApp.Selection.InlineShapes.Count);
            Shape.Height:=50;
            Shape.Width:=75;
            WordApp.Selection.MoveRight(Unit:=1,Count:=1); // De-Select Picture
            WordApp.Selection.TypeParagraph;
         end
         else
         begin
            WordApp.Selection.TypeText('File Not Found ('+List[I]+')');
         end;
      end
      else
      begin
         if (I mod 2 = 1) or (List[I] <> ' ') then
         begin
            WordApp.Selection.TypeText(List[I]);
            if (Copy(List[I],1,8) = 'Product.')
            or (Copy(List[I],1,6) = 'Group.')
            or (Copy(List[I],1,7) = 'UGroup.')
            or (Copy(List[I],1,7) = 'WGroup.')
            or (Copy(List[I],1,9) = 'PickList.')
            or (Copy(List[I],1,7) = 'LookUp.') then
            begin
                WordApp.Selection.MoveLeft(Unit:=2,Count:=3,Extend:=1); // Select Text
                WordApp.ActiveDocument.Indexes.MarkEntry(Range:=WordApp.Selection.Range,Entry:=List[I],EntryAutoText:=List[I]);
                WordApp.Selection.MoveRight(Unit:=1,Count:=1); // De-Select Text
            end;
         end;
      end;
      LastCell:=List[I];
      if I <> List.Count-1 then
      begin
         if (I mod 2 = 1) and (List[I+1] = ' ') then
            WordApp.Selection.TypeParagraph
         else if not ((I mod 2 = 0) and (List[I] = ' ')) then
            WordApp.Selection.MoveRight(Unit:=12); // 12 = wdCell
      end;
   end;
   WordApp.Selection.MoveDown(Unit:=5,Count:=1); // 5=wdLine
   if WithBreak then
   begin
      WordApp.Selection.InsertBreak(Type:=0); // page break
   end
   else
   begin
      WordApp.Selection.TypeText('_____________________________________________________________________');
      WordApp.Selection.TypeParagraph;
   end;
{
    Selection.HomeKey Unit:=wdLine, Extend:=wdExtend
    ActiveDocument.Indexes.MarkEntry Range:=Selection.Range, Entry:= _
        "Group.Main", EntryAutoText:="Group.Main", CrossReference:="", _
        CrossReferenceAutoText:="", BookmarkName:="", Bold:=False, Italic:=False
    Selection.EndKey Unit:=wdLine
    With ActiveDocument
        .Indexes.Add Range:=Selection.Range, HeadingSeparator:= _
            wdHeadingSeparatorNone, Type:=wdIndexIndent, RightAlignPageNumbers:= _
            False, NumberOfColumns:=2, IndexLanguage:=wdEnglishUS
        .Indexes(1).TabLeader = wdTabLeaderDots

}
   
end;
procedure ExpandRegKey(Path,Name:String;WordApp:Variant;DescList:TStrings);
var
   I:Integer;
   S:String;
   SL:TStringList;
   Table:TStringList;
   Registry:TRegistry;
   Desc:String;
begin
   SL:=TStringList.Create;
   Table:=TStringList.Create;
   Registry:=TRegistry.Create;
   Registry.RootKey:=HKEY_LOCAL_MACHINE;
   if Registry.OpenKey(Path+'\'+Name,False) then
   begin
      Registry.GetValueNames(SL);
      if DescList.IndexOf(Name) >= 0 then
         Desc:=TStringObject(DescList.Objects[DescList.IndexOf(Name)]).Value
      else
         Desc:='';
      if (SL.Count > 0) or (Desc <> '') then
      begin
         if Desc <> '' then
         begin
            Table.Clear;
            Table.Add('Key Name'); Table.Add(Name);
            Table.Add('Path'); Table.Add('[HKLM\'+Path+'\'+Name+']');
            Table.Add('Description'); Table.Add(Desc);
            for I:=0 to SL.Count-1 do
            begin
               if I = 0 then 
                  Table.Add('Entrys')
               else
                  Table.Add(''); 
               
               S:=Registry.ReadString(SL[I]);
               if S <> '' then
                  Table.Add(SL[I]+' = '+S)
               else
                  Table.Add(SL[I]);
            end;
            InsertTableInWord(WordApp,Table,False);
            for I:=0 to SL.Count-1 do
            begin
               if DescList.IndexOf(Name+SL[I]) >= 0 then
                  Desc:=TStringObject(DescList.Objects[DescList.IndexOf(Name+SL[I])]).Value
               else
                  Desc:='';
               if Desc <> '' then
               begin
                  Table.Clear;
                  Table.Add('Entry Name'); Table.Add(SL[I]);
                  Table.Add('Key'); Table.Add('[HKLM\'+Path+'\'+Name+']');
                  Table.Add('Description'); Table.Add(Desc);
                  Table.Add('Used by'); Table.Add(' ');
                  Table.Add('Default Value'); Table.Add(Registry.ReadString(SL[I]));
                  Table.Add('Possible Values'); Table.Add(Registry.ReadString(SL[I]));
                  InsertTableInWord(WordApp,Table,False);
               end
//               else
//               begin
//                  Table.Add('Entry Name'); Table.Add(SL[I]);
//                  Table.Add('Key'); Table.Add('[HKLM\'+Path+'\'+Name+']');
//                  Table.Add('Description'); Table.Add('NO DESCRIPTION AVAILABLE');
//                  InsertTableInWord(WordApp,Table,False);
//               end;   
            end;    
            if SL.Count > 0 then
               InsertPBreakInWord(WordApp);
         end
//         else
//         begin
//            Table.Add('Key Name'); Table.Add(Name);
//            Table.Add('Path'); Table.Add('[HKLM\'+Path+'\'+Name+']');
//            Table.Add('Description'); Table.Add('NO DESCRIPTION AVAILABLE');
//            InsertTableInWord(WordApp,Table,False);
//         end;
      end;    
      if (Registry.HasSubKeys) then
      begin
         Registry.GetKeyNames(SL);
         Registry.CloseKey;
         for I:=0 to SL.Count-1 do
            ExpandRegKey(Path+'\'+Name,SL[I],WordApp,DescList)
      end
      else
         Registry.CloseKey;
   end;
   Registry.Free;
   Table.Free;
   SL.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   WordApp:Variant;
   SL:TStringList;
   DescList:TStringList;
   I,P:Integer;
begin
   SL:=TStringList.Create;
   DescList:=TStringList.Create;
   DescList.LoadFromFile('C:\RegDesc.txt');
   for I:=0 to DescList.Count-1 do
   begin
      P:=Pos('^',DescList[I]);
      if P <> 0 then
      begin
         DescList.Objects[I]:=TStringObject.Create(Copy(DescList[I],P+1,Length(DescList[I])));
         DescList[I]:=Copy(DescList[I],1,P-1);
      end;
   end;
   WordApp:=CreateOleObject('Word.Application');
   WordApp.Documents.Add;
   WordApp.Visible:=True;
   WordApp.ActiveDocument.PageSetup.Orientation :=0; // Portrait
   try
      ExpandRegKey(Edit1.Text,Edit2.Text,WordApp,DescList);
   except
   end;
   WordApp:=Unassigned;
   DescList.Free;
   SL.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   WordApp:Variant;
   SL:TStringList;
   DescList:TStringList;
   I,P:Integer;
begin
   SL:=TStringList.Create;
   DescList:=TStringList.Create;
   DescList.LoadFromFile('C:\RegDesc.txt');
   for I:=0 to DescList.Count-1 do
   begin
      P:=Pos('^',DescList[I]);
      if P <> 0 then
      begin
         SL.Add(Copy(DescList[I],1,P-1));
         SL.Add(Copy(DescList[I],P+1,Length(DescList[I])));
      end;
   end;
   WordApp:=CreateOleObject('Word.Application');
   WordApp.Documents.Add;
   WordApp.Visible:=True;
   WordApp.ActiveDocument.PageSetup.Orientation :=0; // Portrait
   InsertTableInWord(WordApp,SL,False);
   WordApp:=Unassigned;
   SL.Free;
   DescList.Free;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   Memo1.Lines.BeginUpdate;
   Memo2.Lines.BeginUpdate;
   Memo3.Lines.BeginUpdate;
   Memo1.Lines.Clear;
   Memo2.Lines.Clear;
   Memo3.Lines.Clear;
   if OD.Execute then
      FindAllPasFiles(OD.FileName,'E:\CorvusV3\Corvus\Source',Memo1.Lines,Memo2.Lines,Memo3.Lines);
   Memo1.Lines.EndUpdate;
   Memo2.Lines.EndUpdate;
   Memo3.Lines.EndUpdate;     
   Edit3.Text:=IntToStr(Memo1.Lines.Count);
   Edit4.Text:=IntToStr(Memo2.Lines.Count);
   Edit5.Text:=IntToStr(Memo3.Lines.Count);
end;                       

procedure FindCallBack(P:PChar;FileName:String;LineNumber:Integer);
var
  S:String;
  KeyWord:String;
  RS:String;
  ii,iss:Boolean;
  LN:Integer;
  BCount:Integer;
begin                 
   LN:=LineNumber;
   RS:='';
   KeyWord:=GetToken(P,True,ii,iss);
   S:=GetToken(P,True,ii,iss);
   S:=GetToken(P,True,ii,iss);
   BCount:=1;
   while BCount > 0 do
   begin
      if S = '(' then Inc(BCount)
      else if S = ')' then Dec(BCount);
//      if (BCount > 0) and iss then
         RS:=RS+S;
      S:=GetToken(P,True,ii,iss);
   end;         
   LineNumber:=LN;
   if (KeyWord = 'SetGPCSRegString') and (RS <> '') and (RS[1] = '''') then
      S:='[HKLM\Software\PSL\GPCS\'+RS
   else
      S:=KeyWord+'('+RS;
   S:=S+'      -     '+FileName;
   if Form1.Memo4.Lines.IndexOf(S) = -1 then
      Form1.Memo4.Lines.Add(S);
end;
procedure TForm1.Button4Click(Sender: TObject);
begin
   Memo4.Lines.Clear;
   FindAllInstancesOf('E:\CorvusV3\Corvus\Source','SetGPCSRegString',FindCallBack);
   FindAllInstancesOf('E:\CorvusV3\Corvus\Source','GetGPCSRegString',FindCallBack);
   FindAllInstancesOf('E:\CorvusV3\Corvus\Source','SetPSLRegString' ,FindCallBack);
   FindAllInstancesOf('E:\CorvusV3\Corvus\Source','GetPSLRegString' ,FindCallBack);
end;

end.
