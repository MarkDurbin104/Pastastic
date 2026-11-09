unit TableParserU;

interface
uses
   Classes,ProjectFormFU,ParseNodeU,Dialogs,SysUtils;
type
  TColumnType = (ctText,ctDateTime,ctMoney,ctNumber);
  TTColumnNode = class(TCorvusNode)
  public
     function ColName:String;
     function ColType:TColumnType;
     function Key    :Boolean;
  end;
  TTableNode = class(TCorvusNode)
   private
     function PLUCount:Integer;
     function GetPLURange(Index:Integer):String;
     function GetColumn(Index:Integer):TTColumnNode;
   public                
     function ColumnCount:Integer;
     function RequiredTxnTypes:String;
     function SubDirectory:String;
     function Duplicate:String;
     function CSV:Boolean;
     function Yearly :Boolean;
     function Monthly:Boolean;
     function Daily  :Boolean;
     function Table:Boolean;
     function KeyColumns:String;
     property Column[Index:Integer]:TTColumnNode read GetColumn;
     function PLUs:String;
  end;
  TTablesNode = class(TParseNode)
  private
     ThePLUList:TStringList;
     function GetTable(Index:Integer):TTableNode;
  public
     constructor Create(Name,FileName:String;LineNumber:Integer); override;
     destructor Destroy; override;
     function TablesUsingPLU(PLU:Integer):String;
     function TableNamed(Name:String):TTableNode;
     function TableCount:Integer;
     function NewCompType(CurrCompType:TCorvusNode;CurrCompTypeName,Tok,FileName:String;LineNumber:Integer):Integer; override;
     property Table[Index:Integer]:TTableNode read GetTable;
  end;
implementation
{TTColumnNode}
function TTColumnNode.ColName:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('ColName');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
      Result:=TCorvusNode(Objects[I])[0];
end;
function TTColumnNode.ColType:TColumnType;
var
   I:Integer;
   S:String;
begin
   Result:=ctText;
   I:=IndexOf('ColType');
   if (I <> -1) and (Objects[I] <> nil) and (TCorvusNode(Objects[I]).Count>0) then
   begin
      S:=UpperCase(TCorvusNode(Objects[I])[0]);
      if S = 'TEXT' then
         Result:=ctText
      else if S = 'DATETIME' then
         Result:=ctDateTime
      else if S = 'MONEY' then
         Result:=ctMoney
      else if S = 'NUMBER' then
         Result:=ctNumber;
   end;
end;
function TTColumnNode.Key:Boolean;
begin
   Result:=IndexOf('Key') <> -1;
end;
{TTableNode}
function TTableNode.PLUCount:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('PLURange');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      Result:=TCorvusNode(Objects[I]).Count;
   end;
end;
function TTableNode.PLUs:String;
var
   I:Integer;
begin
   Result:='';
   for I:=0 to PLUCount-1 do
     if Result = '' then
        Result:=GetPLURange(I)
     else
        Result:=Result+','+GetPLURange(I);
end;
function TTableNode.KeyColumns:String;
var
   I:Integer;
begin
   Result:='';
   for I:=0 to ColumnCount-1 do
   begin
      if Column[I].Key then
      begin
         if Result = '' then
            Result:=Column[I].ColName
          else
            Result:=Result+';'+Column[I].ColName;
      end;    
   end;
end;
function TTableNode.Duplicate:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('Duplicate');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=Trim(TCorvusNode(Objects[I]).Text);
end;
function TTableNode.SubDirectory:String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('SubDirectory');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=Trim(TCorvusNode(Objects[I]).Text);
end;
function TTableNode.Yearly:Boolean;
var
   I:Integer;
begin
   Result:=False;
   I:=IndexOf('Yearly');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=True;
end;
function TTableNode.Monthly:Boolean;
var
   I:Integer;
begin
   Result:=False;
   I:=IndexOf('Monthly');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=True;
end;
function TTableNode.Daily:Boolean;
var
   I:Integer;
begin
   Result:=False;
   I:=IndexOf('Daily');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=True;
end;
function TTableNode.CSV:Boolean;
var
   I:Integer;
begin
   Result:=False;
   I:=IndexOf('CSV');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=True
   else
   begin
      I:=IndexOf('Table');
      if (I = -1) or (Objects[I] = nil) then
         Result:=True;
   end;                
end;                 
function TTableNode.Table:Boolean;
var
   I:Integer;
begin
   Result:=False;
   I:=IndexOf('Table');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=True;
end;                 
function TTableNode.RequiredTxnTypes:String;
var
   I:Integer;
begin
   Result:='TxnLine,TxnTotal';
   I:=IndexOf('RequiredTxnTypes');
   if (I <> -1) and (Objects[I] <> nil) then
      Result:=Trim(TCorvusNode(Objects[I]).Text);
end;
function TTableNode.ColumnCount:Integer;
var
   I:Integer;
begin
   Result:=0;
   I:=IndexOf('Columns');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      Result:=TCorvusNode(Objects[I]).Count;
   end;
end;
function TTableNode.GetColumn(Index:Integer):TTColumnNode;
var
   I:Integer;
begin
   Result:=nil;
   I:=IndexOf('Columns');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      if (Index >= 0) and (Index < ColumnCount) then
         Result:=TTColumnNode(TCorvusNode(Objects[I]).Objects[Index]);
   end;
end;
function TTableNode.GetPLURange(Index:Integer):String;
var
   I:Integer;
begin
   Result:='';
   I:=IndexOf('PLURange');
   if (I <> -1) and (Objects[I] <> nil) then
   begin
      if (Index > -1) and (Index < TCorvusNode(Objects[I]).Count) then
         Result:=TCorvusNode(Objects[I])[Index];
   end;
end;
{TTablesNode}
constructor TTablesNode.Create(Name,FileName:String;LineNumber:Integer);
begin
   inherited Create(Name,FileName,LineNumber);
end;        
destructor TTablesNode.Destroy;
begin
   if ThePLUList <> nil then
   begin
      ThePLUList.Free;
      ThePLUList:=nil;
   end;
   inherited Destroy;
end;
function TTablesNode.TableNamed(Name:String):TTableNode;
var
   CorvusNode:TCorvusNode;
   Index:Integer;
begin
   Result:=nil;
   if Copy(Name,1,7) = 'Table.' then
     Name:=Copy(Name,8,Length(Name));
   CorvusNode:=NodeNamed('Tables');
   if CorvusNode <> nil then
   begin
      Index:=CorvusNode.IndexOf(Name);
      if Index >= 0 then
         Result:=TTableNode(CorvusNode.Objects[Index]);
   end;
end;
function PLUInRange(PLU:Integer;PLURange:String):Boolean;
var
   SL:TStringList;
   P,P1,P2,I:Integer;
begin
   Result:=False;
   SL:=TStringList.Create;
   SL.CommaText:=PLURange;
   for I:=0 to  SL.Count-1 do
   begin
      P:=Pos('-',SL[I]);
      if P > 1 then
      begin
         P1:=StrToIntDef(Copy(SL[I],1,P-1),0);
         P2:=StrToIntDef(Copy(SL[I],P+1,Length(SL[I])),0);
         if (PLU >= P1) and (PLU <= P2) then
            Result:=True;
      end
      else
      begin
         if (PLU = StrToIntDef(SL[I],0)) then
            Result:=True;
      end;
      if Result then Break;
   end;
   SL.Free;
end;
function TTablesNode.TablesUsingPLU(PLU:Integer):String;
var
   Res:TStringList;
   I,TC:Integer;
begin       
   Res:=TStringList.Create;
   TC:=TableCount;
   for I:=0 to TC-1 do
   begin
      if PLUInRange(PLU,Table[I].PLUs) and (Table[I].ColumnCount > 0) then
          Res.Add(Table[I].Name);
   end;
   Result:=Res.CommaText;
   Res.Free;
end;
function TTablesNode.TableCount:Integer;
begin
   if NodeNamed('Tables') <> nil then
      Result:=NodeNamed('Tables').Count
   else
      Result:=0;
end;
function TTablesNode.GetTable(Index:Integer):TTableNode;
var
   CorvusNode:TCorvusNode;
begin
   Result:=nil;
   CorvusNode:=NodeNamed('Tables');
   if CorvusNode <> nil then
   if (Index >= 0) and (Index < CorvusNode.Count) then
   begin
      Result:=TTableNode(CorvusNode.Objects[Index]);
   end;
end;
function TTablesNode.NewCompType(CurrCompType:TCorvusNode;CurrCompTypeName,Tok,FileName:String;LineNumber:Integer):Integer;
begin
   if Pos('.'+Tok+'.','.Tables.') <> 0 then
   begin
      ShowMessage(CurrCompTypeName+' contains component named '+Tok+' in File '+FileName+'('+IntToStr(LineNumber)+')');
   end;
   if CurrCompTypeName = 'Tables' then 
      Result:=CurrCompType.AddObject(Tok,TTableNode.Create (Tok,FileName,LineNumber))
   else                                            
      Result:=CurrCompType.AddObject(Tok,TCorvusNode.Create(Tok,FileName,LineNumber));
   
end;

end.
 