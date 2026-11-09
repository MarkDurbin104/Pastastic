unit I3UIParseU;

interface

uses
  SysUtils,ParseNodeU,Dialogs;

type
  TOfficeField = ( ofName, ofScode, ofTelephone, ofCode, ofI3Code, ofParentNode, ofIsAutomated, ofIsSorting );
  TOffice = class(TCorvusNode)
   private
     function GetName        :String;
     function GetSCode       :String;
     function GetTelephone   :String;
     function GetCode        :Integer;
     function GetI3Code      :Integer;
     function GetParentNode  :Integer;
     function GetIsAutomated :Boolean;
     function GetIsSorting   :Boolean;
     function GetMOTypes     :String;
   public
     property Name        :String  read GetName        ;
     property SCode       :String  read GetSCode       ;
     property Telephone   :String  read GetTelephone   ;
     property Code        :Integer read GetCode        ;
     property I3Code      :Integer read GetI3Code      ;
     property ParentNode  :Integer read GetParentNode  ;
     property IsAutomated :Boolean read GetIsAutomated ;
     property IsSorting   :Boolean read GetIsSorting   ;
     property MOTypes     :String  read GetMOTypes     ;
  end;
  TUINode = class(TCorvusNode)
  private
     FTitle:String;
  public
     property Title :String read FTitle;
  end;
  TSystemNode = class(TUINode)
  private
     FBitmap  :String;
     FLUButton:String;
     FLDButton:String;
     FMUButton:String;
     FMDButton:String;
     FSUButton:String;
     FSDButton:String;
     FLogo    :String;
     FPad     :String;
     FHColour :String;
     FFColour :String;
     FTUPanel :String;                
     FEmboss  :String;                
     function GetStringValue(Index:Integer):String;
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     property Bitmap  :String index  0 read GetStringValue;
     property Title   :String index  1 read GetStringValue;
     property LUButton:String index  2 read GetStringValue;
     property LDButton:String index  3 read GetStringValue;
     property MUButton:String index  4 read GetStringValue;
     property MDButton:String index  5 read GetStringValue;
     property SUButton:String index  6 read GetStringValue;
     property SDButton:String index  7 read GetStringValue;
     property Logo    :String index  8 read GetStringValue;
     property Pad     :String index  9 read GetStringValue;
     property HColour :String index 10 read GetStringValue;
     property FColour :String index 11 read GetStringValue;
     property TUPanel :String index 12 read GetStringValue;
     property Emboss  :String index 13 read GetStringValue;                
  end;        
  TUIMenuNode = class(TUINode)
  private
     FForm  :String;
     FPrompt:String;
     FHint  :String;
     FItems :String;
     FSelect:String;
     FBarCodeFormat:String;
     FAutoCompletWith:String;
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     property Form  :String read FForm  ;
     property Prompt:String read FPrompt;
     property Hint  :String read FHint  ;
     property Items :String read FItems ;
     property Select:String read FSelect;
     property BarCodeFormat:String read FBarCodeFormat;
     property AutoCompletWith:String read FAutoCompletWith;
  end;                      
  TUIFormNode = class(TUINode)
  private
     FDomains  :String;
     FTimer    :String;
     FOnCreate :String;
     FOnDestroy:String;
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     property Domains      :String read FDomains      ;
     property Timer        :String read FTimer        ;
     property OnCreate     :String read FOnCreate     ;
     property OnDestroy    :String read FOnDestroy    ;
  end;                     
  TUIFunctionNode = class(TUINode)
  private
     FDLL        :String;
     FFunc       :String;
     FExecuteType:String;
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     property DLL        :String read FDLL        ;
     property Func       :String read FFunc       ;
     property ExecuteType:String read FExecuteType;
  end;
  TUIDomainNode = class(TUINode)
  private
     FDefaultValue:String;
     FFormat      :String;
     FHint        :String;
     FPrompt      :String;
     FCompType    :String;
     FCheckWith   :String;
     FOnChange    :String;
     FOnEnter     :String;
     FDrawWith    :String;
     FBarCodeFormat:String;
     FErrorS      :String;
     function GetIsReadOnly:Boolean;
     function GetListName  :String;
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     property DefaultValue :String  read FDefaultValue;
     property Format       :String  read FFormat      ;
     property Hint         :String  read FHint        ;
     property Prompt       :String  read FPrompt      ;
     property ErrorS       :String  read FErrorS      ;
     property CompType     :String  read FCompType    ;
     property IsReadOnly   :Boolean read GetIsReadOnly;
     property ListName     :String  read GetListName  ;
     property CheckWith    :String  read FCheckWith   ;
     property OnChange     :String  read FOnChange    ;
     property OnEnter      :String  read FOnEnter     ;
     property DrawWith     :String  read FDrawWith    ;
     property BarCodeFormat:String  read FBarCodeFormat;
  end;
  TUIListNode     = class(TUINode)
  private
     FDefaultValue:String;
     FSorted      :String;
     function AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer; override;
  public
     property DefaultValue:String read FDefaultValue;
     property Sorted      :String read FSorted      ;
  end;
  TUIDispatchNode = class(TUIListNode)
   private   
      function GetDispList(Index:Integer):String;
   public           
      function GetDispListByCode(Code:Integer):String;
      property DispList[Index:Integer]:String read GetDispList; default;
  end;                   
  TUIOfficeNode = class(TUIListNode)
   private
      function GetOffice(Index:Integer):TOffice;
   public
      property Office[Index:Integer]:TOffice read GetOffice; default;
      function OfficeNamed(Name:String):TOffice;
      function HasChildern(Office:TOffice):Boolean;
      function OfficeCoded(Code:Integer):TOffice;
  end;
  TI3UINode = class(TParseNode)
  private
     FMenus       :TCorvusNode;
     FForms       :TCorvusNode;
     FFunctions   :TCorvusNode;
     FDomains     :TCorvusNode;
     FLists       :TCorvusNode;
     FSystem      :TSystemNode;
     FOfficeNode  :TUIOfficeNode;
     FDispatchNode:TUIDispatchNode;
  public        
     constructor Create(Name,FileName:String;LineNumber:Integer); override;
     function NodeNamed(Name:String):TCorvusNode; override;
     function NewCompType(CurrCompType:TCorvusNode;CurrCompTypeName,Tok,FileName:String;LineNumber:Integer):Integer; override;
     property Menus       :TCorvusNode     read FMenus        write FMenus       ;
     property Forms       :TCorvusNode     read FForms        write FForms       ;
     property Functions   :TCorvusNode     read FFunctions    write FFunctions   ;
     property Domains     :TCorvusNode     read FDomains      write FDomains     ;
     property Lists       :TCorvusNode     read FLists        write FLists       ;
     property System      :TSystemNode     read FSystem       write FSystem      ;
     property OfficeNode  :TUIOfficeNode   read FOfficeNode   write FOfficeNode  ;
     property DispatchNode:TUIDispatchNode read FDispatchNode write FDispatchNode;
  end;           
  

implementation
{TOffice}
function TOffice.GetName        :String;
begin
   Result:='';
   if Count > 0 then Result:=Get(0);
end;
function TOffice.GetSCode       :String;
begin
   Result:='';
   if Count > 1 then Result:=Get(1);
end;
function TOffice.GetTelephone   :String;
begin
   Result:='';
   if Count > 3 then Result:=Get(3);
end;
function TOffice.GetCode        :Integer;
begin
   Result:=0;
   if Count > 2 then Result:=StrToIntDef(Get(2),0);
end;
function TOffice.GetParentNode  :Integer;
begin
   Result:=0;
   if Count > 4 then Result:=StrToIntDef(Get(4),0);
end;
function TOffice.GetIsAutomated :Boolean;
begin
   Result:=False;
   if Count > 5 then Result:=UpperCase(Get(5)) = 'A';
end;
function TOffice.GetIsSorting :Boolean;
begin
   Result:=False;
   if Count > 6 then Result:=UpperCase(Get(6)) = 'S';
end;
function TOffice.GetI3Code      :Integer;
begin
   Result:=0;
   if Count > 7 then Result:=StrToIntDef(Get(7),0);
end;
function TOffice.GetMOTypes :String;
begin
   Result:='';
   if Count > 8 then Result:=Get(8);
end;
{TSystemNode}
function TSystemNode.GetStringValue(Index:Integer):String;
var
   I:Integer;
   CN:TCorvusNode;
begin
   case Index of
       0 : Result:=FBitmap  ;      
       1 : Result:=FTitle   ;      
       2 : Result:=FLUButton;      
       3 : Result:=FLDButton;      
       4 : Result:=FMUButton;      
       5 : Result:=FMDButton;      
       6 : Result:=FSUButton;      
       7 : Result:=FSDButton;      
       8 : Result:=FLogo    ;      
       9 : Result:=FPad     ;      
      10 : Result:=FHColour ;      
      11 : Result:=FFColour ;      
      12 : Result:=FTUPanel ;
      13 : Result:=FEmboss  ;
   end;
   if Result = '' then
   begin
      case Index of
          0 : I:=IndexOf('Bitmap'  );
          1 : I:=IndexOf('Title'   );
          2 : I:=IndexOf('LUButton');
          3 : I:=IndexOf('LDButton');
          4 : I:=IndexOf('MUButton');
          5 : I:=IndexOf('MDButton');
          6 : I:=IndexOf('SUButton');
          7 : I:=IndexOf('SDButton');
          8 : I:=IndexOf('Logo'    );
          9 : I:=IndexOf('Pad'     );
         10 : I:=IndexOf('HColour' );
         11 : I:=IndexOf('FColour' );
         12 : I:=IndexOf('TUPanel' );
         13 : I:=IndexOf('Emboss'  );
         else I:=-1;             
      end;
      if I <> -1 then
      begin
         CN:=TCorvusNode(Objects[I]);
         if CN.Count > 0 then
            Result:=CN[0];
      end;
      case Index of
          0 : FBitmap  :=Result;      
          1 : FTitle   :=Result;      
          2 : FLUButton:=Result;      
          3 : FLDButton:=Result;      
          4 : FMUButton:=Result;      
          5 : FMDButton:=Result;      
          6 : FSUButton:=Result;      
          7 : FSDButton:=Result;      
          8 : FLogo    :=Result;      
          9 : FPad     :=Result;      
         10 : FHColour :=Result;      
         11 : FFColour :=Result;      
         12 : FTUPanel :=Result;      
         13 : FEmboss  :=Result;      
      end;                          
   end; 
end;
function TSystemNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'Bitmap'       ) then S:=@FBitmap
   else if StrCmp(Name,'Title'        ) then S:=@FTitle
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;

   FIsLoaded:=False;
end;
{TUIDomainNode}
function TUIDomainNode.GetListName:String;
var
  I:Integer;
begin
   Result:='';
   if FCompType = 'PickList' then
   begin
      I:=IndexOf('Type');
      if (I <> -1) 
      and (Objects[I] <> nil) 
      and (TCorvusNode(Objects[I]).Objects[0] <> nil) 
      and (TCorvusNode(TCorvusNode(Objects[I]).Objects[0]).Count > 0) then
      begin
         Result:=TCorvusNode(TCorvusNode(Objects[I]).Objects[0])[0];
      end;
   end;
end;
function TUIDomainNode.GetIsReadOnly:Boolean;
begin
   Result:=IndexOf('ReadOnly') <> -1;
end;
function TUIDomainNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin

   Result:=0;
        if StrCmp(Name,'Default'        ) then S:=@FDefaultValue
   else if StrCmp(Name,'DefaultValue'   ) then S:=@FDefaultValue
   else if StrCmp(Name,'Format'         ) then S:=@FFormat
   else if StrCmp(Name,'Hint'           ) then S:=@FHint
   else if StrCmp(Name,'Type'           ) then S:=@FCompType
   else if StrCmp(Name,'CheckWith'      ) then S:=@FCheckWith
   else if StrCmp(Name,'OnChange'       ) then S:=@FOnChange
   else if StrCmp(Name,'OnEnter'        ) then S:=@FOnEnter
   else if StrCmp(Name,'DrawWith'       ) then S:=@FDrawWith
   else if StrCmp(Name,'BarCodeFormat'  ) then S:=@FBarCodeFormat
   else if StrCmp(Name,'Prompt'         ) then S:=@FPrompt
   else if StrCmp(Name,'Error'          ) then S:=@FErrorS
   else if StrCmp(Name,'Title'          ) then S:=@FTitle
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;

   FIsLoaded:=False;
end;
{TUIMenuNode}
function TUIMenuNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'Form'           ) then S:=@FForm 
   else if StrCmp(Name,'Title'          ) then S:=@FTitle
   else if StrCmp(Name,'Prompt'         ) then S:=@FPrompt
   else if StrCmp(Name,'Hint'           ) then S:=@FHint 
   else if StrCmp(Name,'Select'         ) then S:=@FSelect
   else if StrCmp(Name,'BarCodeFormat'  ) then S:=@FBarCodeFormat
   else if StrCmp(Name,'AutoCompletWith') then S:=@FAutoCompletWith
   else if StrCmp(Name,'Items'          ) then S:=@FItems
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;

   FIsLoaded:=False;
end;

{TUIFormNode}
function TUIFormNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'Domains'  ) then S:=@FDomains
   else if StrCmp(Name,'Title'    ) then S:=@FTitle
   else if StrCmp(Name,'Timer'    ) then S:=@FTimer
   else if StrCmp(Name,'OnCreate' ) then S:=@FOnCreate
   else if StrCmp(Name,'OnDestroy') then S:=@FOnDestroy
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;

   FIsLoaded:=False;
end;

{TUIFunctionNode}
function TUIFunctionNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'Title'      ) then S:=@FTitle
   else if StrCmp(Name,'DLL'        ) then S:=@FDLL  
   else if StrCmp(Name,'ExecuteType') then S:=@FExecuteType  
   else if StrCmp(Name,'Func'       ) then S:=@FFunc 
   else S:=@Temp;                   

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;

   FIsLoaded:=False;
end;

{TUIListNode}
function TUIListNode.AddAttr(FileName:String;LineNumber:Integer;Name,Value:String):Integer;
var
   S:^String;
   Temp:String;
begin
   Result:=0;
        if StrCmp(Name,'Title') then S:=@FTitle
   else if StrCmp(Name,'Default'      ) then S:=@FDefaultValue
   else if StrCmp(Name,'DefaultValue' ) then S:=@FDefaultValue
   else if StrCmp(Name,'Sorted'       ) then S:=@FSorted      
   else S:=@Temp;

   if IndexOf(Name) = -1 then
      Result:=Add(Name);
   TCorvusNode(Objects[IndexOf(Name)]).Add(Trim(Value));
   if S^ = '' then S^:=Value else S^:=S^+','+Value;

   FIsLoaded:=False;
end;
{TUIDispatchNode}
function TUIDispatchNode.GetDispList(Index:Integer):String;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TCorvusNode(Objects[Index]).Text
   else
      Result:='';
end;
function TUIDispatchNode.GetDispListByCode(Code:Integer):String;
begin
   Result:=GetDispList(IndexOf(IntToStr(Code)));
end;
{TUIOfficeNode}
function TUIOfficeNode.GetOffice(Index:Integer):TOffice;
begin
   if (Index >= 0) and (Index < Count) then
      Result:=TOffice(Objects[Index])
   else
      Result:=nil;
end;        
function TUIOfficeNode.OfficeCoded(Code:Integer):TOffice;
var
   I:Integer;
begin
   for I:=0 to Count-1 do
   begin
      if TOffice(Objects[I]).Code = Code then
      begin
         Result:=TOffice(Objects[I]);
         Exit;
      end;
   end;
   Result:=nil;
end;
function TUIOfficeNode.HasChildern(Office:TOffice):Boolean;
var
   I:Integer;
begin
   Result:=True;
   for I:=0 to Count-1 do
      if TOffice(Objects[I]).ParentNode = Office.Code then
         Exit;
   Result:=False;
end;
function TUIOfficeNode.OfficeNamed(Name:String):TOffice;
var
   I:Integer;
begin
   for I:=0 to Count-1 do
   begin
      if TOffice(Objects[I]).Name = Name then
      begin
         Result:=TOffice(Objects[I]);
         Exit;
      end;
   end;
   Result:=nil;
end;
{TI3UINode}
function TI3UINode.NodeNamed(Name:String):TCorvusNode;
begin
        if StrCmp(Copy(Name,1,4),'Menu') then  Result:=FMenus    .NodeNamed(Copy(Name, 6,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Form') then  Result:=FForms    .NodeNamed(Copy(Name, 6,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Func') then  Result:=FFunctions.NodeNamed(Copy(Name,10,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'Doma') then  Result:=FDomains  .NodeNamed(Copy(Name, 8,Length(Name)))
   else if StrCmp(Copy(Name,1,4),'List') then  Result:=FLists    .NodeNamed(Copy(Name, 6,Length(Name)))
   else                                        Result:=nil;
end;
constructor TI3UINode.Create(Name,FileName:String;LineNumber:Integer);
begin
   inherited Create(Name,FileName,LineNumber);
   FMenus    :=TCorvusNode.Create('Menus'    ,FileName,LineNumber); AddObject('Menus'    ,FMenus    );
   FForms    :=TCorvusNode.Create('Forms'    ,FileName,LineNumber); AddObject('Forms'    ,FForms    );
   FFunctions:=TCorvusNode.Create('Functions',FileName,LineNumber); AddObject('Functions',FFunctions);
   FDomains  :=TCorvusNode.Create('Domains'  ,FileName,LineNumber); AddObject('Domains'  ,FDomains  );
   FLists    :=TCorvusNode.Create('Lists'    ,FileName,LineNumber); AddObject('Lists'    ,FLists    );
   FSystem   :=TSystemNode.Create('System'   ,FileName,LineNumber); AddObject('System'   ,FSystem   );
end;
function TI3UINode.NewCompType(CurrCompType:TCorvusNode;CurrCompTypeName,Tok,FileName:String;LineNumber:Integer):Integer;
begin
   if Pos('.'+Tok+'.','.Domains.Menus.Forms.Lists.Functions.') <> 0 then
   begin
      ShowMessage('Error- '+CurrCompTypeName+' contains component named '+Tok+' in File '+FileName+'('+IntToStr(LineNumber)+')');
   end;
   
        if CurrCompTypeName = 'Menus'     then Result:=CurrCompType.AddObject(Tok,TUIMenuNode    .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Forms'     then Result:=CurrCompType.AddObject(Tok,TUIFormNode    .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Functions' then Result:=CurrCompType.AddObject(Tok,TUIFunctionNode.Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Domains'   then Result:=CurrCompType.AddObject(Tok,TUIDomainNode  .Create(Tok,FileName,LineNumber))
   else if CurrCompTypeName = 'Lists'     then 
   begin
      if Tok = 'DirectDispatch' then
      begin
         FDispatchNode:=TUIDispatchNode.Create(Tok,FileName,LineNumber);
         Result:=CurrCompType.AddObject(Tok,FDispatchNode);
      end
      else if Tok = 'Offices' then
      begin
         FOfficeNode:=TUIOfficeNode.Create(Tok,FileName,LineNumber);
         Result:=CurrCompType.AddObject(Tok,FOfficeNode);
      end
      else
         Result:=CurrCompType.AddObject(Tok,TUIListNode    .Create(Tok,FileName,LineNumber));
   end
   else                                        Result:=CurrCompType.AddObject(Tok,TCorvusNode    .Create(Tok,FileName,LineNumber));
end;

end.
