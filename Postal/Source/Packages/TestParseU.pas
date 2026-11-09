unit TestParseU;

interface

uses
  SysUtils,ParseNodeU,Dialogs;

type
  TUITestNode = class(TCorvusNode)
  private
     FSequence:String;
  public
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
     property Sequence:String read FSequence write FSequence;
  end;   
  TTestNode = class(TParseNode)
   private
     FTests:TCorvusNode;
   public        
     constructor Create(Name,FileName:String;LineNumber:Integer); override;
     function NodeNamed(Name:String):TCorvusNode; override;
     function NewCompType(CurrCompType:TCorvusNode;CurrCompTypeName,Tok,FileName:String;LineNumber:Integer):Integer; override;
     property Tests:TCorvusNode read FTests write FTests;
  end;
  
implementation
{TUITestNode}
function TUITestNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'Sequence') then S:=@FSequence
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;

   FIsLoaded:=False;
end;
{TTestNode}
function TTestNode.NodeNamed(Name:String):TCorvusNode;
begin
        if StrCmp(Copy(Name,1,4),'Test') then  Result:=FTests.NodeNamed(Copy(Name, 6,Length(Name)))
   else                                        Result:=nil;
end;
constructor TTestNode.Create(Name,FileName:String;LineNumber:Integer);
begin
   inherited Create(Name,FileName,LineNumber);
   FTests:=TCorvusNode.Create('Tests',FileName,LineNumber); AddObject('Tests',FTests);
end;
function TTestNode.NewCompType(CurrCompType:TCorvusNode;CurrCompTypeName,Tok,FileName:String;LineNumber:Integer):Integer;
begin
   if Pos('.'+Tok+'.','.Tests') <> 0 then
   begin
      ShowMessage('Error- '+CurrCompTypeName+' contains component named '+Tok+' in File '+FileName+'('+IntToStr(LineNumber)+')');
   end;
   
        if CurrCompTypeName = 'Tests' then Result:=CurrCompType.AddObject(Tok,TUITestNode.Create(Tok,FileName,LineNumber))
   else                                    Result:=CurrCompType.AddObject(Tok,TCorvusNode.Create(Tok,FileName,LineNumber));
end;
     
end.
