unit RepGenFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ParseNodeU,ProjectFormFU,ExtCtrls, StdCtrls, PackStrListU,StringUtil,TxnTranslateU,
  QueryMapU,ReportPreviewF,ReportIDSU;

type
  TForm1 = class(TForm)
    Panel2: TPanel;
    Memo1: TMemo;
    Panel: TPanel;
    Panel1: TPanel;
    Button1: TButton;
    SD: TSaveDialog;
    Button2: TButton;
    OD: TOpenDialog;
    Edit1: TEdit;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure ProjectLoaded(Sender: TObject);
    procedure ProjectLoad(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
procedure TForm1.ProjectLoad(Sender: TObject);
begin
   Memo1.Lines.Clear;
   Memo1.Refresh;
end;
procedure TForm1.FormShow(Sender: TObject);
begin
   ProjectsForm.OnLoaded:=ProjectLoaded;
   ProjectsForm.OnLoad:=ProjectLoad;
   ProjectsForm.PutOn(Panel1);
end;

function MangelName(S:String):String;
var
   I:Integer;
begin;
   Result:='';
   for I:=1 to Length(S) do
      if S[I] in ['0'..'9','A'..'Z','a'..'z','_'] then
         Result:=Result+S[I];

   if Result = '' then Result:='Unknown';
   Result:=Copy(Result,1,25);
end;
function DomainNames(CommaText:String):String;
var
   SL:TStringList;
   I:Integer;
   DomainNode:TDomainNode;
begin
   SL:=TStringList.Create;
   SL.CommaText:=CommaText;
   for I:=0 to SL.Count-1 do
   begin
      DomainNode:=TDomainNode(ProjectsForm.Comps.NodeNamed('Domain.'+SL[I]));
      if DomainNode <> nil then     
      begin
         if (DomainNode.Format = 'Currency') or (DomainNode.Format = 'Range') then
            SL[I]:='_'+MangelName(DomainNode.Title)
         else
            SL[I]:=MangelName(DomainNode.Title);
      end;
   end;
   Result:=SL.CommaText;
   SL.Free;
end;  
function ListDomains(ProductNode:TProductNode):String;
var
   SL:TStringList;
   LSL:TStringList; 
   I:Integer;
begin
   LSL:=TStringList.Create;
   SL:=TStringList.Create;
   for I:=0 to ProductNode.GetItemNodeCount-1 do
   begin
      if (ProductNode.ItemNode[I] is TProductNode) then
      begin
         LSL.CommaText:=ListDomains(ProductNode.ItemNode[I] as TProductNode);
         if LSL.Count > 0 then SL.Add(Trim(LSL.Text));
      end;
   end;
   LSL.CommaText:=DomainNames(ProductNode.Domains);
   if LSL.Count > 0 then SL.Insert(0,Trim(LSL.Text));
   SL.Text:=Trim(SL.Text);
   Result:=SL.CommaText;
   SL.Free;
   LSL.Free;
end;
procedure RemDup(Lines:TStrings);
var
   LSL:TStringList;
   SL:TStringList;
   I:Integer;
begin
   LSL:=TStringList.Create;
   SL:=TStringList.Create;
   for I:=0 to Lines.Count-1 do
   begin
      LSL.CommaText:=Lines[I];
      SL.Add(LSL.Text);
   end;
   SL.Text:=SL.Text;
   LSL.Assign(SL);
   SL.Clear;
   for I:=0 to LSL.Count-1 do
   begin
      if (Trim(LSL[I]) <> '') and (SL.IndexOf(Trim(LSL[I])) = -1) then
         SL.Add(Trim(LSL[I]));
   end;
   Lines.Assign(SL);
   SL.Free;
   LSL.Free;
end;
function MakeLine(S:String):String;
var
   I:Integer;
   L:Integer;
begin
   Result:='//';
   
   L:=(78-Length(S)) div 2;
   for I:=1 to L do Result:=Result+'-';
   
   Result:=Result+' '+S+' ';
   
   L:=Length(Result);
   for I:=L to 79 do Result:=Result+'-';
end;
function DomTitle(Domain:String):String;
var
   DomainNode:TDomainNode;
begin
   DomainNode:=TDomainNode(ProjectsForm.Comps.NodeNamed('Domain.'+Domain));
   if DomainNode <> nil then     
      Result:=DomainNode.Title
   else
      Result:=Domain;
end;   
procedure TForm1.ProjectLoaded(Sender: TObject);
var
   J,I,UG:Integer;
   ProductNode:TProductNode;
   GroupNode:TGroupNode;
   UserNode:TUserNode;
   GroupAdded:Boolean;
   PLUList:TStringList;
   DomList:TStringList;
   ProdList:TStringList;
   ProgIDList:TStringList;
   MainProgIDList:TStringList;
   SL:TStringList;
begin
   PLUList:=TStringList.Create;
   DomList:=TStringList.Create;
   ProdList:=TStringList.Create;
   ProgIDList:=TStringList.Create;
   MainProgIDList:=TStringList.Create;
   SL:=TStringList.Create;
   Memo1.Lines.BeginUpdate;
   try
      UserNode:=TUserNode(ProjectsForm.Comps.NodeNamed('User.Clerk'));
      if UserNode <> nil then
      begin
         Memo1.Lines.Add('// Fixed column names available in any report');
         Memo1.Lines.Add('// ''TransactionID''   ');
         Memo1.Lines.Add('// ''RecordID''        ');
         Memo1.Lines.Add('// ''WSNumber''        ');
         Memo1.Lines.Add('// ''OfficeCode''      ');
         Memo1.Lines.Add('// ''AccountingPeriod''');
         Memo1.Lines.Add('// ''TransactionType'' ');
         Memo1.Lines.Add('// ''DateTime''        ');
         Memo1.Lines.Add('// ''Teller''          ');
         Memo1.Lines.Add('// ''ProgramID''       ');
         Memo1.Lines.Add('// ''ProgramVersion''  ');
         Memo1.Lines.Add('// ''PLU''             ');
         Memo1.Lines.Add('// ''ItemPrice''       ');
         Memo1.Lines.Add('// ''ItemQuantity''    ');
         Memo1.Lines.Add('// ''ItemValue''       ');
         Memo1.Lines.Add('// ''Description''     ');
         Memo1.Lines.Add('');
         Memo1.Lines.Add('// Typical First Query:');
         Memo1.Lines.Add('// FirstQuery { ''select * from txnlog where (RecType = ''''TxnLine'''' or RecType = ''''TxnTotal'''')'' }');
         Memo1.Lines.Add('// Typical Second Query:');
         Memo1.Lines.Add('// SecondQuery { ''select Description,ItemValue from ReportResult where PLU in ( 12345678,2345678 )'' }');
         Memo1.Lines.Add('');
         Memo1.Lines.Add('// DummyReport {');
         Memo1.Lines.Add('//    Alias { ''PSL'' }  // default is PSL');
         Memo1.Lines.Add('//    TableName { ''ReportResult'' } // default is ReportResult');
         Memo1.Lines.Add('//    FirstQuery { ''select * from txnlog where (RecType = ''''TxnLine'''' or RecType = ''''TxnTotal'''')'' } // default takes username office workstation periods into account ');
         Memo1.Lines.Add('//    SecondQuery { ''select Description,ItemValue from ReportResult where PLU in (123456,234567 )'' } // default uses Column names and PLURanges');
         Memo1.Lines.Add('//    FitWidth NOT WORKING YET!!! // Fit to paper (no need to define Widths for each column)' );
         Memo1.Lines.Add('//    Title    { ''Dummy Report'' } // appears at top of report');
         Memo1.Lines.Add('//    PLURange { 12345678,2345678 } // main product PLUs');
         Memo1.Lines.Add('//    Columns {');
         Memo1.Lines.Add('//       Description {  // Column Name' );
         Memo1.Lines.Add('//          Heading { ''The Description'' } // Column Heading ');
         Memo1.Lines.Add('//          Justify { Left } // Column Justification Left Right Centre - default is Left ');
         Memo1.Lines.Add('//          Width   { -400 } // Column width negative means overflow, positive reduce font to fit');
         Memo1.Lines.Add('//       }');
         Memo1.Lines.Add('//       ItemPrice {');
         Memo1.Lines.Add('//          Heading { ''Item Price'' }');
         Memo1.Lines.Add('//          Justify { Right }');
         Memo1.Lines.Add('//          Width   { -400 }');
         Memo1.Lines.Add('//          Total // Total up this column at the end of the report');
         Memo1.Lines.Add('//       }');
         Memo1.Lines.Add('//    }');
         Memo1.Lines.Add('// }');          
         Memo1.Lines.Add('');
         Memo1.Lines.Add('Reports {');           
                                           
         for UG:=0 to UserNode.GetItemNodeCount-1 do
         begin
            GroupNode:=UserNode.ItemNode[UG];
            if GroupNode <> nil then
            begin
               GroupAdded:=False;
               for I:=0 to GroupNode.GetItemNodeCount-1 do
               begin
                  if (GroupNode.ItemNode[I] is TProductNode) then
                  begin
                     ProductNode:=(GroupNode.ItemNode[I] as TProductNode);
                     if (ProductNode <> nil) 
                     and (ProductNode.PLU <> '') 
                     and (MainProgIDList.IndexOf(ProductNode.Name) = -1) then
                     begin
                        MainProgIDList.Add(ProductNode.Name);
                        if ((ProductNode.PLU <> '') and (ProductNode.PLU[1] in ['0'..'9'])) 
                        or (ProjectsForm.Comps.NodeNamed('Constant.'+ProductNode.PLU) <> nil) then
                        begin
                           ProgIDList.Add(Trim(ProductNode.Name));
                           ProdList.Add(Trim(ProductNode.Title));
                           if (ProductNode.PLU[1] in ['0'..'9']) then
                              PLUList.Add(Trim(ProductNode.PLU))
                           else
                              PLUList.Add(Trim(ProjectsForm.Comps.NodeNamed('Constant.'+ProductNode.PLU)[0]+' '));
                           DomList.Add(Trim(ListDomains(ProductNode)));
                           GroupAdded:=True;
                        end;
                     end;
                  end;
               end;
               if GroupAdded then
               begin
                  for I:=0 to ProdList.Count-1 do 
                  begin
                     Memo1.Lines.Add(MakeLine(ProdList[I]));
                     Memo1.Lines.Add('   P'+ProgIDList[I]+' {');
                     Memo1.Lines.Add('      FitWidth');
                     Memo1.Lines.Add('      Title    { '''+ProdList[I]+''' }');
                     Memo1.Lines.Add('      PLURange { '+PLUList[I]+' }');
                     SL.CommaText:=DomList[I];
                     RemDup(SL);
                     if SL.Count > 0 then
                     begin
                        if SL.Count = 1 then
                        begin
                           Memo1.Lines.Add('      Columns  { '+SL[0]+' { Heading { '''+DomTitle(SL[0])+''' } } }');
                        end
                        else
                        begin
                           Memo1.Lines.Add('      Columns  {');
                           for J:=0 to SL.Count-1 do 
                           begin
                              if (SL[J] <> '') and (SL[J][1] = '_') then
                              begin
                                 SL[J]:=Copy(SL[J],2,Length(SL[J]));
                                 Memo1.Lines.Add('         '+RightPad(SL[J],25,' ')+' { Heading { '''+DomTitle(SL[J])+''' } Justify { Right } } ')
                              end
                              else
                                 Memo1.Lines.Add('         '+RightPad(SL[J],25,' ')+' { Heading { '''+DomTitle(SL[J])+''' } }');
                           end;
                           Memo1.Lines.Add('      }');
                        end;
                     end;
                     Memo1.Lines.Add('   }');
                  end;                         
                  if ProdList.Count > 1 then
                  begin
                     RemDup(PLUList);
                     RemDup(DomList);
                     Memo1.Lines.Add(MakeLine(GroupNode.Title));
                     Memo1.Lines.Add('   G'+GroupNode.Name+' {');
                     for I:=0 to ProgIDList.Count-1 do 
                        Memo1.Lines.Add('            // '+ProdList[I]);
//                     Memo1.Lines.Add('      Font { ''Arial'',12 }');
                     Memo1.Lines.Add('      Title    { '''+GroupNode.Title+''' }');
                     Memo1.Lines.Add('      PLURange {');
                     for I:=0 to PLUList.Count-1 do 
                        Memo1.Lines.Add('         '+PLUList[I]);
                     Memo1.Lines.Add('      }');
                     if DomList.Count > 0 then
                     begin
                        Memo1.Lines.Add('      Columns  {');
                        for I:=0 to DomList.Count-1 do 
                        begin
                           SL.CommaText:=DomList[I];
                           for J:=0 to SL.Count-1 do 
                           begin
                              if (SL[J] <> '') and (SL[J][1] = '_') then
                              begin
                                 SL[J]:=Copy(SL[J],2,Length(SL[J]));
                                 Memo1.Lines.Add('         '+RightPad(SL[J],25,' ')+' { Heading { '''+DomTitle(SL[J])+''' } Width { 400 } Justify { Right } } ')
                              end
                              else
                                 Memo1.Lines.Add('         '+RightPad(SL[J],25,' ')+' { Heading { '''+DomTitle(SL[J])+''' } Width { 200 } }');
                           end;
                        end;                                                           
                        Memo1.Lines.Add('      }');
                     end; 
                     Memo1.Lines.Add('   }');           
                  end;
               end;
               PLUList.Clear;
               DomList.Clear;
               ProdList.Clear;
               ProgIDList.Clear;
            end;
         end; 
         Memo1.Lines.Add('}');           
      end; 
   finally
      Memo1.Lines.EndUpdate;
   end; 
   MainProgIDList.Free;
   ProgIDList.Free;
   PLUList.Free;
   DomList.Free;
   ProdList.Free;
   SL.Free;
end; 

procedure TForm1.Button1Click(Sender: TObject);
var
   ReportNodes:TReportsNode;
begin
   if SD.Execute then 
   begin
      Memo1.Lines.SaveToFile(SD.Filename);
      ReportNodes:=TReportsNode.Create('Reports',SD.FileName,1);
      ReportNodes.ParseFile(ExtractFilePath(SD.FileName),SD.FileName,1);
      ReportNodes.Free;
   end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   ReportNodes:TReportsNode;
   ReportNode:TReportNode;
begin
   if OD.Execute then
   begin
      ReportNodes:=TReportsNode.Create('Reports',OD.FileName,1);
      ReportNodes.ParseFile(ExtractFilePath(OD.FileName),OD.FileName,1);
      ReportNode:=ReportNodes.ReportNamed(Edit1.Text);
      if ReportNode <> nil then ReportNode.Execute('',3201,4,1614,1614,False);
      ReportNodes.Free;
   end;
end;

end.
