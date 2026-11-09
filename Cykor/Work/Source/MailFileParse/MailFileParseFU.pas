unit MailFileParseFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,PackStrListU, ExtCtrls;

type
  TForm1 = class(TForm)
    Splitter1: TSplitter;
    Memo2: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  TStringObject = class(TObject)
  public
     val:String;
     constructor Create(S:String);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
constructor TStringObject.Create(S:String);
begin
     val:=S;
end;
function Tabs(Indent:Integer):String;
var
 I:Integer;
begin
     Result:='';
     for I:=0 to Indent-1 do
     begin
          Result:=Result+#9;
     end;
end;
function parseLine(S:string):string;
var
   P:PChar;
   Indent:Integer;
begin
     Result:='';
     P:=PChar(S);
     Indent:=0;
     while P^ <> #0 do
     begin
          Result:=Result+P^;
          if (P^ = ':') and ((P+1)^ = '<') then
          begin
               Inc(Indent);
               Result:=Result+#13#10+Tabs(Indent);
          end;
          if (P^ = '>') then
          begin
               if ((P+1)^ = '>') then
                  Dec(Indent);
               Result:=Result+#13#10+Tabs(Indent);
          end;
        Inc(P);
     end;
end;
function AddNodes(SL:TStrings;var P:PChar):string;
var
   NodeName,NodeData:String;
   NewNode:TPackStringList;
   Idx:Integer;
begin
     Result:='';
     Inc(P);
     while P^ <> #0 do
     begin
          if (P^ = ':') then
          begin
              if ((P+1)^ <> '<') then
              begin

                   Inc(P);
                   NodeData:='';
                   while (P^ <> '>') do
                   begin
                        if (P^ > #31) and (P^ < #128) then
                        begin
                           if p^ = '"' then
                              NodeData:=NodeData+'&quot;'
                           else
                              NodeData:=NodeData+P^;
                        end;
                        if p^ = '&' then
                           NodeData:=NodeData+'amp;';
                        Inc(P);
                   end;
                   if SL.IndexOf(NodeName) <> -1 then
                   begin
                        Idx:=0;
                        while SL.IndexOf(NodeName+IntToStr(Idx)) <> -1 do Inc(Idx);
                        NodeName:=NodeName+IntToStr(Idx);
                   end;
                   SL.AddObject(NodeName,TStringObject.Create(NodeData));
                   NodeName:='';
              end
              else
              begin
                   NewNode:=TPackStringList.Create;
                   SL.AddObject(NodeName,NewNode);
                   AddNodes(NewNode,P);
                   NodeName:='';
              end;
          end
          else if (P^ = '>') then
          begin
             Result:=SL.Text;
             Inc(P);
             Exit;
          end
          else if (P^ <> '<') then
              NodeName:=NodeName+P^;
        Inc(P);
     end;
end;
function formatNodes(TopNode:String;Indent:Integer;SL:TStrings):String;
var
   I:Integer;
   RSL:TPackStringList;
   Attribs:String;
   HasNodes:Boolean;
begin
     RSL:=TPackStringList.Create;
     Attribs:='';
     HasNodes:=False;
     
     if TopNode[1] in ['0'..'9'] then
       TopNode:='o'+TopNode;

     for I:=0 to SL.Count-1 do
     begin
        if (SL.Objects[I] is TPackStringList) then
        begin
             HasNodes:=True;
             break;
        end;
     end;

     for I:=0 to SL.Count-1 do
     begin
        if (SL.Objects[I] is TStringObject) then
        begin
             Attribs:=Attribs+' ';
             Attribs:=Attribs+SL[I]+'="'+TStringObject(SL.Objects[I]).val+'"';
//             TStringObject(SL.Objects[I]).Free;
        end;
     end;
     if Attribs <> '' then
     begin
          if HasNodes then
             RSL.Add(Tabs(Indent)+'<'+TopNode+Attribs+' >')
          else
             RSL.Add(Tabs(Indent)+'<'+TopNode+Attribs+' />');
     end
     else
     begin
          if HasNodes then
             RSL.Insert(0,Tabs(Indent)+'<'+TopNode+'>')
          else
             RSL.Insert(0,Tabs(Indent)+'<'+TopNode+'/>');
     end;
     for I:=0 to SL.Count-1 do
     begin
        if (SL.Objects[I] is TPackStringList) then
        begin
             RSL.Add(formatNodes(SL[I],Indent+1,TPackStringList(SL.Objects[I])));
//             TPackStringList(SL.Objects[I]).Free;
        end;
     end;
     if HasNodes then
        RSL.Add(Tabs(Indent)+'</'+TopNode+'>');
     Result:='';
     for I:=0 to RSL.Count-2 do
     begin
       Result:=Result+RSL[I]+#13#10;
     end;
     Result:=Result+RSL[RSL.Count-1];
end;
procedure AddCollection(NodeList,SL:TPackStringList);
var
   I:Integer;
   CName:String;
   CNodeIdx:Integer;
   CNode:TPackStringList;
   OName:String;
   ONodeIdx:Integer;
   ONode:TPackStringList;
begin
   I:=SL.IndexOf('Collection');
   if I <> -1 then
   begin
      CName:=TStringObject(SL.Objects[I]).val;
      CNodeIdx:=NodeList.IndexOf(CName);
      if CNodeIdx = -1 then
         CNodeIdx:=NodeList.AddObject(CName,TPackStringList.Create);
      CNode:=TPackStringList(NodeList.Objects[CNodeIdx]);

      I:=SL.IndexOf('ObjectName');
      if I <> -1 then
      begin
         OName:=TStringObject(SL.Objects[I]).val;
         ONodeIdx:=CNode.IndexOf(OName);
         if ONodeIdx = -1 then
         begin
            ONodeIdx:=CNode.AddObject(OName,TPackStringList.Create);
         end;
         ONode:=TPackStringList(CNode.Objects[ONodeIdx]);
         for I:=0 to SL.Count-1 do
         begin
            if (SL[I] <> 'Collection') and (SL[I] <> 'ObjectName') then
               ONode.AddObject(SL[I],SL.Objects[I]);
         end;
      end;
   end;
end;
procedure AddLinks(FromName:Boolean;AType:String;Service,List:TPackStringList);
var
   I:Integer;
   Index:Integer;
   CCount:Integer;
   Name:String;
   AList:TPackStringList;
begin
   Index:=Service.IndexOf(AType);
   if (Index <> -1) and (Service.Objects[Index] is TPackStringList) then
      AList:=TPackStringList(Service.Objects[Index])
   else
      AList:=nil;
   if AList <> nil then
   begin
      CCount:=AList.Count-1;
      for I:=0 to CCount do
      begin
         if FromName then
         begin
            if (AList.Objects[I] is TStringObject) then
            begin
               Name:=AList[I];
               Index:=List.IndexOf(Name);
               if Index <> -1 then
               begin
                  AList.Objects[I]:=List.Objects[Index];
                  AList.AddObject('F'+IntToStr(I),TStringObject.Create(Name));
               end;
            end;
         end
         else
         begin
            if (AList.Objects[I] is TStringObject) then
            begin
               Name:=TStringObject(AList.Objects[I]).val;
               Index:=List.IndexOf(Name);
               if (Index <> -1) and (AList.IndexOf(Name) = -1) then
                  AList.AddObject(Name,List.Objects[Index]);
            end;
         end;
      end;
   end;
end;
procedure RemoveNode(Node:TObject;Name:String);
var
   Index:Integer;
begin
   Index:=TPackStringList(Node).IndexOf(Name);
   if Index <> -1 then
      TPackStringList(Node).Delete(Index);
end;
procedure RenameNode(Node:TObject;Name,NewName:String);
var
   Index:Integer;
begin
   Index:=TPackStringList(Node).IndexOf(Name);
   if Index <> -1 then
      TPackStringList(Node)[Index]:=NewName;
end;
procedure MoveAttribs(FromNode,ToNode:TObject);
var
   Index:Integer;
begin
   for Index:=0 to TPackStringList(FromNode).Count-1 do
   begin
      TPackStringList(ToNode).AddObject(TPackStringList(FromNode)[Index],TPackStringList(FromNode).Objects[Index]);
   end;
end;
procedure DuplicateAddOnNode(Name:String;FromNode,ToNode:TObject);
var
   Index:Integer;
   I:Integer;
   SLFrom,SLTo:TPackStringList;
begin
   Index:=TPackStringList(FromNode).IndexOf('Type');
   if (Index <> -1) and (TStringObject(TPackStringList(FromNode).Objects[Index]).val='AddOn') then
   begin
      SLFrom:=TPackStringList(FromNode);
      SLTo:=TPackStringList(ToNode);
      Index:=SLTo.IndexOf('SecondaryServices');
      if (Index = -1) then
        Index:=SLTo.AddObject('SecondaryServices',TPackStringList.Create);
      SLTo:=TPackStringList(SLTo.Objects[Index]);
      Index:=SLTo.IndexOf(Name);
      if Index = -1 then
      begin
         Index:=SLTo.AddObject(Name,TPackStringList.Create);
         SLTo:=TPackStringList(SLTo.Objects[Index]);
         for I:=0 to SLFrom.Count-1 do
         begin
            if (SLFrom.Objects[I] is TStringObject) then
            begin
               SLTo.AddObject(SLFrom[I],TStringObject.Create(TStringObject(SLFrom.Objects[I]).val));
            end;
         end;
      end;
      while SLFrom.Count > 0 do
         SLFrom.delete(0);
   end;
end;
function NodeType(Node:TObject):String;
var
   Index:Integer;
begin
   Index:=TPackStringList(Node).IndexOf('Type');
   if (Index = -1) then result:='';
   result:=TStringObject(TPackStringList(Node).Objects[Index]).val;
end;
procedure CopyAndInsertImages(FromPath,ToPath:String;MailServices,FullTree:TPackStringList);
var
   I:Integer;
   SL:TPackStringList;
   Res:String;
   FromFile,ToFile,ResID:String;
   Index:Integer;
begin
     for I:=0 to MailServices.Count-1 do
     begin
        if (MailServices.Objects[I] is TPackStringList) then
        begin
           Index:=TPackStringList(MailServices.Objects[I]).IndexOf('DisplayAttributes');
           if Index <> -1 then
           begin
              SL:=TPackStringList(TPackStringList(MailServices.Objects[I]).Objects[Index]);
              Index:=SL.IndexOf('ResourceId');
              if Index <> -1 then
              begin
                 ResID:=TStringObject(SL.Objects[Index]).val;
                 Index:=SL.IndexOf('Resources');
                 if Index <> -1 then
                 begin
                    Res:=TStringObject(SL.Objects[Index]).val;
                    FromFile:=FromPath+'\'+Res+'_'+ResID+'.gif';
                    ToFile:=ToPath+'\'+Copy(MailServices[I],2,Length(MailServices[I]))+'.gif';
                    CopyFile(PChar(FromFile),PChar(ToFile),True);
                    toFile:=ExtractFileName(ToFile);
                    TStringObject(SL.Objects[Index]).val:=ToFile;
                    SL[Index]:='Icon';
                 end;
              end;
              RemoveNode(SL,'ResourceId');
              RemoveNode(SL,'CustomHotKey');
              RemoveNode(SL,'LogicalPrecedence');
              RemoveNode(SL,'HasSubMenu');
              RenameNode(SL,'BubbleHelp','Hint');
           end;
//           if NodeType(MailServices.Objects[I]) = 'Group' then
//           begin
              TPackStringList(MailServices.Objects[I]).AddObject('Name',TStringObject.Create(MailServices[I]));
//              MailServices[I]:='Group'
//           end;
           RemoveNode(MailServices.Objects[I],'Constraints');
           RemoveNode(MailServices.Objects[I],'RequiredVariables');
           RemoveNode(MailServices.Objects[I],'Functions');
           RemoveNode(MailServices.Objects[I],'DisplayFunctions');
           RemoveNode(MailServices.Objects[I],'AssetManager');
           RemoveNode(MailServices.Objects[I],'ServiceScript');
           Index:=TPackStringList(MailServices.Objects[I]).IndexOf('DisplayAttributes');
           if Index <> -1 then
           begin
              SL:=TPackStringList(TPackStringList(MailServices.Objects[I]).Objects[Index]);
              MoveAttribs(SL,MailServices.Objects[I]);
           end;
           DuplicateAddOnNode(MailServices[I],MailServices.Objects[I],FullTree);
//           RemoveNode(MailServices.Objects[I],'Type');
           RemoveNode(MailServices.Objects[I],'DisplayAttributes');
        end;
     end;
end;
procedure CopyImages(FromPath,ToPath:String;MailServices:TPackStringList);
var
   I:Integer;
   SL:TPackStringList;
   Res:String;
   FromFile,ToFile,ResID:String;
   Index:Integer;
begin
     for I:=0 to MailServices.Count-1 do
     begin
        if (MailServices.Objects[I] is TPackStringList) then
        begin
           Index:=TPackStringList(MailServices.Objects[I]).IndexOf('DisplayAttributes');
           if Index <> -1 then
           begin
              SL:=TPackStringList(TPackStringList(MailServices.Objects[I]).Objects[Index]);
              Index:=SL.IndexOf('ResourceId');
              if Index <> -1 then
              begin
                 ResID:=TStringObject(SL.Objects[Index]).val;
                 Index:=SL.IndexOf('Resources');
                 if Index <> -1 then
                 begin
                    Res:=TStringObject(SL.Objects[Index]).val;
                    FromFile:=FromPath+'\'+Res+'_'+ResID+'.gif';
                    ToFile:=ToPath+'\'+MailServices[I]+'.gif';
                    CopyFile(PChar(FromFile),PChar(ToFile),True);
                 end;
              end;
           end;
        end;
     end;
end;
procedure BuildServiceTree(ServiceName:String;Root,MailServices,MailServiceTree,MailFunctions,MailVariables,MailConstraints,MailAreas:TPackStringList);
var
   I:Integer;
   SL:TPackStringList;
   Service:TPackStringList;
   ParentService:String;
   ChildService:String;
   MailServiceIndex:Integer;
begin
   MailServiceIndex:=MailServices.IndexOf(ServiceName);
   if MailServiceIndex = -1 then
      Service:=TPackStringList.Create
   else
      Service:=TPackStringList(MailServices.Objects[MailServiceIndex]);
   Root.AddObject(ServiceName,Service);

//   AddLinks(false,'Constraints',Service,MailConstraints);
//   AddLinks(true, 'Functions',Service,MailFunctions);
//   AddLinks(false,'DisplayFunctions',Service,MailFunctions);
//   AddLinks(false,'RequiredVariables',Service,MailVariables);

   for I:=0 to MailServiceTree.Count-1 do
   begin
      SL:=TPackStringList(MailServiceTree.Objects[I]);
      ParentService:=TStringObject(SL.Objects[SL.IndexOf('ParentObjectName')]).val;
      ChildService:=TStringObject(SL.Objects[SL.IndexOf('ChildObjectName')]).val;
      if ParentService = ServiceName then
      begin
         BuildServiceTree(ChildService,Service,MailServices,MailServiceTree,MailFunctions,MailVariables,MailConstraints,MailAreas);
      end;
   end;

end;
procedure BuildShortServiceTree(ServiceName:String;Root,MailServices,MailServiceTree,MailFunctions,MailVariables,MailConstraints,MailAreas:TPackStringList);
var
   I:Integer;
   SL:TPackStringList;
   Service:TPackStringList;
   ParentService:String;
   ChildService:String;
   MailServiceIndex:Integer;
begin
   MailServiceIndex:=MailServices.IndexOf(ServiceName);
   if MailServiceIndex = -1 then
      Service:=TPackStringList.Create
   else
      Service:=TPackStringList(MailServices.Objects[MailServiceIndex]);
   Root.AddObject(ServiceName,Service);

   for I:=0 to MailServiceTree.Count-1 do
   begin
      SL:=TPackStringList(MailServiceTree.Objects[I]);
      ParentService:=TStringObject(SL.Objects[SL.IndexOf('ParentObjectName')]).val;
      ChildService:=TStringObject(SL.Objects[SL.IndexOf('ChildObjectName')]).val;
      if ParentService = ServiceName then
      begin
         BuildShortServiceTree(ChildService,Service,MailServices,MailServiceTree,MailFunctions,MailVariables,MailConstraints,MailAreas);
      end;
   end;

end;
procedure ListAttribs(Service:String;MailServices,MailServiceTree:TPackStringList);
var
   I:Integer;
   SL:TPackStringList;
begin
   Form1.Memo2.lines.Add(Service);
   SL:=TPackStringList(MailServices.Objects[MailServices.IndexOf(Service)]);
   if SL <> nil then
   begin
      SL:=TPackStringList(SL.Objects[SL.IndexOf('DisplayAttributes')]);
      if SL <> nil then
      begin
           for I:=0 to SL.Count-1 do
           begin
              if (SL.Objects[I] is TStringObject) then
              begin
                  Form1.Memo2.lines.Add('  '+SL[I]+'="'+TStringObject(SL.Objects[I]).val+'"');
              end;
           end;
      end;
   end;
end;
function appToXML(appFile:String):TPackStringList;
var
   I:Integer;
   FileSL:TPackStringList;
   ResultSL:TPackStringList;
   NodeList:TPackStringList;
   MailServices:TPackStringList;
   MailServiceTree:TPackStringList;
   SL:TPackStringList;
   MailFunctions:TPackStringList;
   MailVariables:TPackStringList;
   MailConstraints:TPackStringList;
   MailAreas:TPackStringList;
   P:PChar;
   S:String;
begin
   ResultSL:=TPackStringList.Create;
   FileSL:=TPackStringList.Create;
   SL:=TPackStringList.Create;
   NodeList:=TPackStringList.Create;

   ResultSL.Add('<'+ExtractFileName(appFile)+'>');
   FileSL.LoadFromFile(appFile);
   for I:=0 to FileSL.Count-1 do
   begin
      SL.Clear;
      S:=FileSL[I]+#0#0#0#0;
      P:=PChar(S);
      AddNodes(SL,P);
      AddCollection(NodeList,SL);
      S:=formatNodes('Line',1,SL);
      SetLength(S,Length(S));
      ResultSL.Add(S);
   end;
   ResultSL.Add('</'+ExtractFileName(appFile)+'>');
   result:=ResultSL;
   S:=formatNodes(ExtractFileName(appFile),0,NodeList);
   SetLength(S,Length(S));
   ResultSL.Text:=S;

   SL.Clear;
   MailServices:=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailServices')]);
   MailServiceTree:=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailServiceTree')]);
   MailFunctions  :=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailFunctions')]);
   MailVariables  :=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailVariables')]);
   MailConstraints:=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailConstraints')]);
   MailAreas      :=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailAreas')]);
   BuildServiceTree('ROOTSERVICE',SL,MailServices,MailServiceTree,MailFunctions,MailVariables,MailConstraints,MailAreas);

   CopyImages('..\..\DataFiles\IGI\Icons',
              '..\..\DataFiles\IGI\Icons\Needed for Mails',
              MailServices);

   S:='';
   S:=formatNodes(ExtractFileName(appFile),0,SL);
   SetLength(S,Length(S));
   form1.Memo2.Lines.Add(S);
   FileSL.Text:=S;
   FileSL.SaveToFile(appFile+'.xml');
   FileSL.Free;
   SL.Free;
end;
function ShortappToXML(appFile:String):TPackStringList;
var
   I:Integer;
   FileSL:TPackStringList;
   ResultSL:TPackStringList;
   NodeList:TPackStringList;
   MailServices:TPackStringList;
   MailServiceTree:TPackStringList;
   SL:TPackStringList;
   MailFunctions:TPackStringList;
   MailVariables:TPackStringList;
   MailConstraints:TPackStringList;
   MailAreas:TPackStringList;
   P:PChar;
   S:String;
begin
   ResultSL:=TPackStringList.Create;
   FileSL:=TPackStringList.Create;
   SL:=TPackStringList.Create;
   NodeList:=TPackStringList.Create;

   ResultSL.Add('<'+ExtractFileName(appFile)+'>');
   FileSL.LoadFromFile(appFile);
   for I:=0 to FileSL.Count-1 do
   begin
      SL.Clear;
      S:=FileSL[I]+#0#0#0#0;
      P:=PChar(S);
      AddNodes(SL,P);
      AddCollection(NodeList,SL);
      S:=formatNodes('Line',1,SL);
      SetLength(S,Length(S));
      ResultSL.Add(S);
   end;
   ResultSL.Add('</'+ExtractFileName(appFile)+'>');
   result:=ResultSL;
   S:=formatNodes(ExtractFileName(appFile),0,NodeList);
   SetLength(S,Length(S));
   ResultSL.Text:=S;

   SL.Clear;
   MailServices:=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailServices')]);
   MailServiceTree:=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailServiceTree')]);
   MailFunctions  :=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailFunctions')]);
   MailVariables  :=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailVariables')]);
   MailConstraints:=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailConstraints')]);
   MailAreas      :=TPackStringList(NodeList.Objects[NodeList.IndexOf('MailAreas')]);
   BuildServiceTree('ROOTSERVICE',SL,MailServices,MailServiceTree,MailFunctions,MailVariables,MailConstraints,MailAreas);

   CopyAndInsertImages('..\..\DataFiles\IGI\Icons',
              '..\..\DataFiles\IGI\Icons\Needed for Mails',
              MailServices,SL);

   S:='';
   S:=formatNodes(ExtractFileName(appFile),0,SL);
   SetLength(S,Length(S));
   form1.Memo2.Lines.Add(S);
   FileSL.Text:=S;
   FileSL.SaveToFile(appFile+'.xml');
   FileSL.Free;
   SL.Free;
end;
procedure AddPath(Target:TPackStringList;Data:TObject;Path:String);
var
   I:Integer;
   P:PChar;
   Element:String;
   CT:TPackStringList;
begin
   P:=PChar(Path);
   CT:=Target;
   Element:='';
   while P^ <> #0 do
   begin
      if P^ = '/' then
      begin
         if Element <> '' then
         begin
            I:=CT.IndexOf(Element);
            if I = -1 then
            begin
               I:=CT.AddObject(Element,TPackStringList.Create);
            end;
            CT:=TPackStringList(CT.Objects[I]);
            Element:='';
         end;
      end
      else
         Element:=Element+P^;
      Inc(P);
   end;
   CT.AddObject(Element,Data);
end;
procedure AddObjectsToTree(Target,BareList:TPackStringList);
var
   I:Integer;
   SL:TPackStringList;
   Path:String;
begin
   for I:=0 to BareList.Count-1 do
   begin
       try
         if (BareList[I] = 'Object') and (I < BareList.Count-1) and (BareList[I+1] = 'Data') then
         begin
            SL:=TPackStringList(BareList.Objects[I]);
            if (SL.Count > 0) and (SL[0] = 'Path') then
            begin
               Path:=TStringObject(SL.Objects[0]).val;
               SL.Delete(0);

               if I < BareList.Count-1 then
                 AddPath(Target,BareList.Objects[I+1],Path);
            end;
         end
         else if (BareList[I] = 'Object') then
         begin
            SL:=TPackStringList(BareList.Objects[I]);
            if (SL.Count > 0) and (SL[0] = 'Path') then
            begin
               Path:=TStringObject(SL.Objects[0]).val;
               SL.Delete(0);
               AddPath(Target,SL,Path);
            end;
         end;
      except
      end;
   end;
end;
function ObjToXML(objFiles:String):TPackStringList;
var
   FC,I,J:Integer;
   FileNameSL:TPackStringList;
   FileSL:TPackStringList;
   ResultSL:TPackStringList;
   NodeList:TPackStringList;
   SL:TPackStringList;
   Target:TPackStringList;
   P:PChar;
   S:String;
   objFile:String;
begin
   ResultSL:=TPackStringList.Create;
   FileSL:=TPackStringList.Create;
   SL:=TPackStringList.Create;
   NodeList:=TPackStringList.Create;
   Target:=TPackStringList.Create;
   FileNameSL:=TPackStringList.Create;

   FileNameSL.LoadFromFile(objFiles);
   for FC:=0 to FileNameSL.Count-1 do
   begin
      objFile:=ExtractFilePath(objFiles)+FileNameSL[FC];
      ResultSL.Add('<'+ExtractFileName(objFile)+'>');
      FileSL.LoadFromFile(objFile);
      for I:=0 to FileSL.Count-1 do
      begin
         if FileSL[I][1] <> '#' then
         begin
            SL.Clear;
            S:=FileSL[I]+#0#0#0#0;
            P:=PChar(S);
            AddNodes(SL,P);
            for J:=0 to SL.Count-1 do
               NodeList.AddObject(SL[J],SL.Objects[J]);
            S:=formatNodes('Line',1,SL);
            SetLength(S,Length(S));
            ResultSL.Add(S);
         end;
      end;
      ResultSL.Add('</'+ExtractFileName(objFile)+'>');
   end;
   AddObjectsToTree(Target,NodeList);
   S:=formatNodes('Objects',0,Target);
   ResultSL.text:=S;
   result:=ResultSL;
end;
function ServiceMatrix(Tree:TPackStringList):String;
var
   ZI,Idx,I,J,K,L:Integer;
   List,Item:TPackStringList;
   ResultSL,SL:TPackStringList;
   Cell:String;
   SMY,SMX:TPackStringList;
   Base,Zips,ZipList:TPackStringList;
   Output:Array[0..999,0..999] of Byte;
   FS:TFileStream;
const
    Codes:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz*#!£$%^&()}{[]-_|\+=~@:;?><,./€';
begin
   ZeroMemory(@Output,SizeOf(Output));
   SL:=TPackStringList.Create;
   SMY:=TPackStringList.Create;
   SMX:=TPackStringList.Create;
   SMX.Clear; for L:=0 to 999 do SMX.Add(' ');
   try
   Tree:=TPackStringList(Tree.Objects[0]);
   Base:=TPackStringList(Tree.Objects[0]);
   form1.Memo2.Lines.Add(Base[0]);
   Tree:=TPackStringList(Base.Objects[0]);
   form1.Memo2.Lines.Add(Tree[0]);

   Zips:=TPackStringList(Base.Objects[1]);
   form1.Memo2.Lines.Add(Base[1]);
   form1.Memo2.Lines.Add(Zips[0]);
   for I:=0 to Tree.Count-1 do
   begin
      SMY.Clear;
      SMY.Add(Tree[I]);
      List:=TPackStringList(Tree.Objects[I]);
      while List[0] <> 'ServiceStandards' do
         List:=TPackStringList(List.Objects[0]);
      List:=TPackStringList(List.Objects[0]);

      ZI:=Zips.IndexOf(Tree[I]);
      if ZI <> -1 then
      begin
         ZipList:=TPackStringList(Zips.Objects[ZI]);
         while ZipList[0] <> 'Zones' do
            ZipList:=TPackStringList(ZipList.Objects[0]);
         ZipList:=TPackStringList(ZipList.Objects[0]);
      end
      else
        ZipList:=nil;
      for J:=0 to List.Count-1 do
      begin
         if J > I then break;
         Cell:='';
         Item:=TPackStringList(List.Objects[J]);
         for K:=0 to Item.Count-1 do
         begin
           if Trim(TStringObject(Item.Objects[K]).val) = '' then
              Cell:=Cell+'0'
           else
              Cell:=Cell+TStringObject(Item.Objects[K]).val;
         end;

         if (ZipList <> nil) and (ZipList.IndexOf(List[J]) <> -1) then
         begin
            Item:=TPackStringList(ZipList.Objects[ZipList.IndexOf(List[J])]);
            for K:=0 to Item.Count-1 do
            begin
              if Trim(TStringObject(Item.Objects[K]).val) = '' then
                 Cell:=Cell+'0'
              else if Trim(TStringObject(Item.Objects[K]).val) = 'Intra' then
                 Cell:=Cell+'1'
              else if Trim(TStringObject(Item.Objects[K]).val) = 'Inter' then
                 Cell:=Cell+'2'
              else
                 Cell:=Cell+TStringObject(Item.Objects[K]).val;
            end;
         end;
         while SMY.Count <= StrToInt(List[J]) do SMY.Add('00');
         Idx:=SL.IndexOf(Trim(Cell));
         if Idx = -1 then Idx:=SL.Add(Trim(Cell));
         Output[StrToInt(Tree[I]),StrToInt(List[J])]:=Idx+1;
         SMY[StrToInt(List[J])]:=IntToHex(Idx+1,2);//Char(Idx+33);//Codes[Idx+1];
      end;
      try
         SMX[StrToInt(Tree[I])]:=SMY.commaText;
      except
        form1.Memo2.Lines.Add('Error'+Tree[I]);
      end;
   end;
   SMX[0]:=SL.CommaText;
   SMX[1]:=IntToStr(SL.count);

   FS:=TFileStream.Create('..\..\DataFiles\IGI\Objects\_ServiceLevels.bin',fmCreate or fmOpenReadWrite);
   I:=Length(SMX[0]);
   FS.Write(I,SizeOf(Integer));
   FS.Write(SMX[0][1],I);
   for I:=0 to 999 do
      FS.Write(Output[I],I+1);
   FS.Free;

   for I:=2 to SMX.Count-1 do
   begin
     SMY.CommaText:=SMX[I];
     Cell:='';
     for J:=1 to SMY.Count-1 do
     begin
        if SMY[J] = '' then SMY[J]:=' ';
        Cell:=Cell+SMY[J];
     end;
     SMX[I]:=SMY[0];
     SMY.Delete(0);
     SMX[I]:=SMX[I]+' '+Cell;
   end;
   ResultSL:=SMX;
   Result:=ResultSL.CommaText;
   ResultSL.Free;
   except
   end;
end;
function ObjToSL(objFiles:String):TPackStringList;
var
   FC,I,J:Integer;
   FileNameSL:TPackStringList;
   FileSL:TPackStringList;
   ResultSL:TPackStringList;
   NodeList:TPackStringList;
   SL:TPackStringList;
   Target:TPackStringList;
   P:PChar;
   S:String;
   objFile:String;
begin
   ResultSL:=TPackStringList.Create;
   FileSL:=TPackStringList.Create;
   SL:=TPackStringList.Create;
   NodeList:=TPackStringList.Create;
   Target:=TPackStringList.Create;
   FileNameSL:=TPackStringList.Create;

   FileNameSL.LoadFromFile(objFiles);
   for FC:=0 to FileNameSL.Count-1 do
   begin
      objFile:=ExtractFilePath(objFiles)+FileNameSL[FC];
      ResultSL.Add('<'+ExtractFileName(objFile)+'>');
      FileSL.LoadFromFile(objFile);
      for I:=0 to FileSL.Count-1 do
      begin
         if FileSL[I][1] <> '#' then
         begin
            SL.Clear;
            S:=FileSL[I]+#0#0#0#0;
            P:=PChar(S);
            AddNodes(SL,P);
            for J:=0 to SL.Count-1 do
               NodeList.AddObject(SL[J],SL.Objects[J]);
            S:=formatNodes('Line',1,SL);
            SetLength(S,Length(S));
            ResultSL.Add(S);
         end;
      end;
      ResultSL.Add('</'+ExtractFileName(objFile)+'>');
   end;
   AddObjectsToTree(Target,NodeList);
   S:=ServiceMatrix(Target);
   ResultSL.CommaText:=S;
   result:=ResultSL;
end;
function Pad(Value,Len:Integer):String;
begin
   Result:=IntToStr(Value);
   while Length(Result) < Len do Result:='0'+Result;
end;
procedure AddCityNode(Nodes:TPackStringList;State,City:String;Zip:Integer);
var
   SI:Integer;
begin
   SI:=Nodes.IndexOf(State);
   if SI = -1 then SI:=Nodes.AddObject(State,TPackStringList.Create);
   Nodes:=TPackStringList(Nodes.Objects[SI]);
   SI:=Nodes.IndexOf(City);
   if SI = -1 then SI:=Nodes.AddObject(City,TPackStringList.Create);
   Nodes:=TPackStringList(Nodes.Objects[SI]);
   Nodes.Add(Pad(Zip,5));
end;
procedure TForm1.FormCreate(Sender: TObject);
var
   SL:TPackStringList;
//   Zips,Cities,Nodes:TPackStringList;
//   City,S,State,Tmp:String;
 //  I,J,K:Integer;
 //  Zip:Integer;
begin
   SL:=ShortappToXML('..\..\DataFiles\IGI\USPSMailsCARS.app');
//   SL:=appToXML('..\..\DataFiles\IGI\USPSMailsCARS.app');
//   SL.SaveToFile('..\..\DataFiles\IGI\USPSMailsCARS.xml');

//   SL:=objToXML('..\..\DataFiles\IGI\Objects\_AllObjectFiles.txt');
//   SL.SaveToFile('..\..\DataFiles\IGI\Objects\_AllObjectFiles.xml');

//   SL:=objToXML('..\..\DataFiles\IGI\Objects\_SomeObjectFiles.txt');
//   SL.SaveToFile('..\..\DataFiles\IGI\Objects\_ZIPFiles.xml');
//   SL:=objToSL('..\..\DataFiles\IGI\Objects\_ServiceLevels.txt');
//   SL.SaveToFile('..\..\DataFiles\IGI\Objects\_ServiceLevels.csv');
{   SL:=TPackStringList.Create;
   Nodes:=TPackStringList.Create;
   SL.LoadFromFile('..\..\DataFiles\IGI\Objects\City.txt');
   I:=0;
   State:='';
   while I < SL.Count do
   begin
      if Trim(SL[I]) = '' then
         SL.Delete(I)
      else
      begin
         S:=SL[I];
         Zip:=StrToInt(Copy(S,3,5));
         City:=Copy(S,15,Length(S)-29);
         State:=Copy(S,Length(S)-5,2);
         AddCityNode(Nodes,State,City,Zip);
         SL[I]:=IntToStr(Zip)+',"'+City+'",'+State;
         Inc(I);
      end;
   end;
   SL.SaveToFile('..\..\DataFiles\IGI\Objects\City.csv');
   SL.Clear;
   for I:=0 to Nodes.Count-1 do
   begin
      SL.Add(Nodes[I]);
      Cities:=TPackStringList(Nodes.Objects[I]);
      for J:=0 to Cities.Count-1 do
      begin
         Zips:=TPackStringList(Cities.Objects[J]);
         for K:=0 to Zips.Count-1 do
         begin
            if K = 0 then
               S:=Zips[K]
            else
               S:=S+','+Zips[K];
         end;
         SL.Add(S+',"'+Cities[J]+'"');
      end;
   end;
   SL.SaveToFile('..\..\DataFiles\IGI\Objects\City.dat'); }
//   SL:=objToXML('..\..\DataFiles\IGI\Objects\_Express.txt');
//   SL.SaveToFile('..\..\DataFiles\IGI\Objects\_AllObjectFiles.xml');
//   memo2.Text:=SL.Text;
end;

end.
