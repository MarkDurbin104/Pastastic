unit Domain;

interface
uses
  GPCSErrorLine, RegistryEx,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls,Utils,GPCSBase_TLB,GPCSGUID,Dialogs,PackStrListU, StringUtil;

  function CheckDomainFilled(DomainToCheck : TComponent) : Boolean;
  procedure SetAllControlProperties(Parent : TWinControl ;DomainClassName, PropertyName : String; PropertyValue : Variant);
//  function SetIgnore(DomainArray :Variant);

type
  TStateTriggerCode = ( GetTriggerCode, CancelTriggerCode, ReadyToStart, NoTriggerCode );

  TOptionsString = class(TObject)
  private
    FPosOptions : TStringList ;
  public
    function  IsInOption( Pos:integer; var Ch:Char ):boolean;
    function  GetOnlyOption( Pos:integer; var ch:char ): boolean ;
    function  Count : integer ;
    procedure Add( Pos : integer; Value:string ) ;
    procedure Clear ;
    constructor Create ;
    destructor Destroy ; override ;
  end ;

  TGenericDomain = class(TComponent)
  private
    FDomain : TComponent;
    function GetEnabled : Boolean;
    function GetIgnore  : Boolean;
    function GetText    : TCaption;
    procedure SetDomain(Value : TComponent);
    procedure SetEnabled(Value : Boolean);
    procedure SetIgnore(Value : Boolean);
    procedure SetText(Value : Tcaption);
  public
    property Domain  : TComponent read FDomain write SetDomain;
    property Enabled : Boolean    read GetEnabled write SetEnabled;
    property Ignore  : Boolean    read GetIgnore write SetIgnore;
    property Text    : TCaption   read GetText   write SetText;
  end;

  TValidType = (vtRange,vtMask,vtCRange);

  TDomainEdit = class(TEdit)
  private
    FTestLength     :Boolean;
    FPreKeyData     :String;
    FDontCheck      :Boolean;
    FPreKeySelStart :Integer;
    FPreKeySelEnd   :Integer;
    FValidation     :String;
    //FOrgValidation  :String;
    FForceLgTil     :Integer;
    FMask           :String;
    FRangeFrom      :Integer;
    FRangeTo        :Integer;
    FCRangeFrom     :Currency;
    FCRangeTo       :Currency;
    FSilenceBell    :Boolean;
    FIgnore         :Boolean;
    FPrompt         :TLabel;
    FErrorText      :String;
    FAssocProgId    :String;
    FDefaultValue   :String;
    FUseDefault     :Boolean;
    FOptions        :TOptionsString;
    AutoComplete    : Boolean;
    AutoCompleteExclusions : TStringList;
    FLocale         :integer;
    procedure SetPrompt(Value:TLabel);
    function ValidType:TValidType;
    function MaskValOK(var Text : string; Mask:String;Index:Integer):Boolean;
    function GetText:TCaption;
    procedure SetText(Value:TCaption);
    function Validate:Boolean;
  protected
    procedure Change; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure SetValidation(Value:String); virtual;
    function  GetValidation:String;
    procedure SetPasswordChar(Value:Char);
    function  CleanMask(Value:String):string ;
    procedure FillEditWithMask( var key : Char ) ;
    procedure CheckCharMask( var ch : Char; PosKey : integer );
  public
    function ValidationComplete:Boolean;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure SetLineData(Value:TPackStringList);
    function LineData:String;
    procedure ValidateOK; virtual;
    //procedure SetDontGetText(Value:Boolean);
    procedure SetStateTrigger(Value:TStateTriggerCode); //FStateTrigger
    //function  GetDontGetText:Boolean;
    function GetStateTrigger:TStateTriggerCode;
    procedure ValidateError; virtual;
    property CRangeFrom:Currency read FCRangeFrom write FCRangeFrom;
    property CRangeTo  :Currency read FCRangeTo   write FCRangeTo  ;
    //property DontGetText:Boolean read GetDontGetText write SetDontGetText ;
    property StateTrigger:TStateTriggerCode read GetStateTrigger write SetStateTrigger;

  published
    property Locale      :integer    read FLocale       write FLocale ;
    property PromptLabel :TLabel     read FPrompt       write SetPrompt;
    property ErrorText   :String     read FErrorText    write FErrorText;
    property RangeFrom   :Integer    read FRangeFrom    write FRangeFrom;
    property RangeTo     :Integer    read FRangeTo      write FRangeTo  ;
    property Ignore      :Boolean    read FIgnore       write FIgnore;
    property DefaultValue:String     read FDefaultValue write FDefaultValue;
    property UseDefault  :Boolean    read FUseDefault   write FUseDefault;
    property Validation  :String     read GetValidation write SetValidation;
    property Text        :TCaption   read GetText       write SetText;
    property SilenceBell :Boolean    read FSilenceBell  write FSilenceBell;
    property AssociatedProgId:String read FAssocProgId  write FAssocProgId;
  end;
  TDomainCombo = class(TComboBox)
  private
     FIgnore:Boolean;
     FPrompt:TLabel;
     FErrorText:String;
     FAssocProgId:String;
     FDefaultValue:String;
     FUseDefault:Boolean;
     FEMaskValue:String;
     FLocale:integer;     
     procedure SetPrompt(Value:TLabel);
  public
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function LineData:String;
    procedure SetLineData(Value:TPackStringList);
    function LineEditData:String;
    procedure SetLineEditData(Value:String);
  published
    property Locale:integer     read FLocale write FLocale ;
    property PromptLabel:TLabel read FPrompt write SetPrompt;
    property ErrorText:String   read FErrorText write FErrorText;
    property Ignore:Boolean read FIgnore write FIgnore;
    property AssociatedProgId:String read FAssocProgId write FAssocProgId;
    property DefaultValue:String read FDefaultValue write FDefaultValue;
    property UseDefault:Boolean read FUseDefault write FUseDefault;
    property EMaskValue:String read FEMaskValue write FEMaskValue;
  end;
  TDomainMemo = class(TMemo)
  private
     FIgnore:Boolean;
     FPrompt:TLabel;
     FErrorText:String;
     FAssocProgId:String;
     FDefaultValue:String;
     FUseDefault:Boolean;
     procedure SetPrompt(Value:TLabel);
  public
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function LineData:String;
    procedure SetLineData(Value:TPackStringList);
  published
    property PromptLabel:TLabel read FPrompt write SetPrompt;
    property ErrorText:String   read FErrorText write FErrorText;
    property Ignore:Boolean read FIgnore write FIgnore;
    property AssociatedProgId:String read FAssocProgId write FAssocProgId;
    property DefaultValue:String read FDefaultValue write FDefaultValue;
    property UseDefault:Boolean read FUseDefault write FUseDefault;
  end;

function EnumerateData(Form:TCustomForm):String;
function Enumerate(Form:TCustomForm):String;
function EnumerateText(Form : TCustomForm) : String;
procedure ReFill(Value:String;Form:TCustomForm);
procedure MoveFocusTo(Component:TComponent);
procedure ClearFocus(Form:TCustomForm);
procedure SetAssociated(Form:TCustomForm;ProgID:String;Price:Currency);
function CheckDomain(Domain : TComponent; ValidCondition : Boolean; var CurrentResult : Boolean) : Boolean;
function DomainComboResult(DomainCombo : TDomainCombo) : String;
//returns string object's value of selected item



var
   FirstTime:Boolean;
   FStateTrigger : TStateTriggerCode;
   //FDontGetText:Boolean;
procedure Register;

implementation

function DomainComboResult(DomainCombo : TDomainCombo) : String;
//returns string object's value of selected item
var
  MatchIndex : Integer;
begin
  result := '';
  try
    If DomainCombo.Text <> '' then
    begin
      matchIndex := DomainCombo.Items.IndexOf(DomainCombo.Text);
      If MatchIndex <> -1 then
      begin
        If DomainCombo.Items.Objects[MatchIndex] is TStringObject then
          result := (DomainCombo.Items.Objects[MatchIndex] as TstringObject).Value;
      end;
    end;
  except
    On E : Exception do
      RaiseGUIDException('{282E37DC-6B83-4FE6-A30B-8D18DBA3CFA9}', E);
  end;
end;

function CheckDomain(Domain : TComponent; ValidCondition : Boolean; var CurrentResult : Boolean) : Boolean;
var
  TheDomain : TGenericDomain;
begin
  TheDomain := TGenericDomain.create(nil);
  try try
    TheDomain.Domain := Domain;
    If not TheDomain.Ignore and TheDomain.Enabled and CurrentResult and (not ValidCondition) then
    begin
      MoveFocusTo(Domain);
      CurrentResult := False;
    end;
  except
    On E : Exception do
      RaiseGUIDException('{E2292CBF-DAA6-49E3-8067-733AC2EB2FA3}',E);
  end
  finally
    TheDomain.Free;
  end;
  Result := CurrentResult;
end;

procedure SetAllControlProperties(Parent : TWinControl ;DomainClassName, PropertyName : String; PropertyValue : Variant);
var
  ControlIndex : Integer;
begin
  For ControlIndex := 0 to Parent.ControlCount -1 do
  begin
    //check for a specified classname
    If (DomainClassName = '')
    or (Parent.Controls[ControlIndex].ClassName = DomainClassName ) then
    begin
      try
        SetObjectProperty(parent.Controls[ControlIndex], PropertyName, PropertyValue);
      except
        On E : Exception do
          RaiseGUIDException('{C233D6EC-73D8-4CCF-8127-D6B5B406A50C}', E);
      end;
    end;
  end;
end;

procedure TOptionsString.Clear;
begin
   while FPosOptions.Count > 0 do
   begin
      TStringObject( FPosOptions.Objects[0] ).Free ;
      FPosOptions.Delete(0);
   end ;
end ;

Constructor TOptionsString.Create;
begin
   inherited Create ;
   FPosOptions := TStringList.Create ;

end ;

destructor TOptionsString.Destroy ;
begin
   Clear ;
   FPosOptions.Free ;
   inherited Destroy ;
end ;

function TOptionsString.IsInOption( Pos:integer; var Ch:Char ):boolean;
var
   s : String ;
   I : integer ;
begin
   result := false ;
   if FPosOptions.IndexOf( IntToStr( Pos ) ) >= 0 then
   begin
      s:= TStringObject( FPosOptions.Objects[ FPosOptions.IndexOf( IntToStr( Pos ) ) ] ).Value;
      I := 1;
      while ( I <= Length( S ) ) and not Result do
      begin
         if ( s[I] = ch ) then result:= true ;
         Inc( I ) ;
      end ;
      //try case conversion
      I := 1;
      while ( I <= Length( S ) ) and not Result do
      begin
         if ( UpperCase(s[I]) = UpperCase(ch) ) then
         begin
           ch := s[i];
            result:= true ;
         end;
         Inc( I ) ;
      end ;
   end ;
end ;

function TOptionsString.Count:integer;
begin
  result := FPosOptions.Count ;
end;

function TOptionsString.GetOnlyOption( Pos:integer; var ch:char ): boolean;
var
  S : string ;
begin

   result := false ;
   if FPosOptions.IndexOf( IntToStr( Pos ) ) >= 0 then
   begin
      s:= TStringObject( FPosOptions.Objects[ FPosOptions.IndexOf( IntToStr( Pos ) ) ] ).Value;
      if Length( s ) = 1 then
      begin
        ch := s[1];
        result := true;
      end;
   end;

end ;

procedure TOptionsString.Add( Pos : integer; Value:string ) ;
begin
   FPosOptions.AddObject( IntToStr( Pos ), TStringObject.Create(Value));
end;



function CheckDomainFilled(DomainToCheck : TComponent) : Boolean;
begin
  With TGenericDomain.Create(nil) do
  begin
    try
      Domain := DomainToCheck;
      If Trim(Text) = '' then
      begin
        Result := False;
        MoveFocusTo(Domain);
      end
      else
        Result := True;

    finally
      Free;
    end;
  end;

end;

procedure TGenericDomain.SetDomain(Value : TComponent);
begin
  If FDomain <> Value then
  begin
    FDomain := Value;
    Name := FDomain.Name;
  end;
end;

function TGenericDomain.GetEnabled : Boolean;
begin
  Result := False;
        If (Domain is TDomainEdit)  then Result := (Domain as TDomainEdit)  .Enabled
  else  If (Domain is TDomainCombo) then Result := (Domain as TDomainCombo) .Enabled
  else  If (Domain is TDomainMemo)  then Result := (Domain as TDomainMemo)  .Enabled;
end;

function TGenericDomain.GetIgnore : Boolean;
begin
  Result := False;
        If (Domain is TDomainEdit)  then Result := (Domain as TDomainEdit)  .Ignore
  else  If (Domain is TDomainCombo) then Result := (Domain as TDomainCombo) .Ignore
  else  If (Domain is TDomainMemo)  then Result := (Domain as TDomainMemo)  .Ignore;
end;

function  TGenericDomain.GetText : TCaption;
begin
  Result := '';
        If (Domain is TDomainEdit)  then Result := (Domain as TDomainEdit)  .Text
  else  If (Domain is TDomainCombo) then Result := (Domain as TDomainCombo) .Text
  else  If (Domain is TDomainMemo)  then Result := (Domain as TDomainMemo)  .Text;
end;

procedure TGenericDomain.SetEnabled(Value : Boolean);
begin
        If (Domain is TDomainEdit)   then (FDomain as TDomainEdit) .Enabled := Value
  else  If (Domain is TDomainCombo)  then (FDomain as TDomainCombo).Enabled := Value
  else  If (Domain is TDomainMemo)   then (FDomain as TDomainMemo) .Enabled := Value;
end;

procedure TGenericDomain.SetIgnore(Value : Boolean);
begin
        If (Domain is TDomainEdit)   then (FDomain as TDomainEdit) .Ignore := Value
  else  If (Domain is TDomainCombo)  then (FDomain as TDomainCombo).Ignore := Value
  else  If (Domain is TDomainMemo)   then (FDomain as TDomainMemo) .Ignore := Value;
end;

procedure TGenericDomain.SetText(Value : Tcaption);
begin
        If (Domain is TDomainEdit)   then (FDomain as TDomainEdit) .Text := Value
  else  If (Domain is TDomainCombo)  then (FDomain as TDomainCombo).Text := Value
  else  If (Domain is TDomainMemo)   then (FDomain as TDomainMemo) .Text := Value;
end;

function EnumerateText(Form : TCustomForm) : String;
var
  GenDomain   : TGenericDomain;
  DomainIndex : Integer;
begin
  GenDomain := TGenericDomain.Create(nil);
  with TStringList.Create, GenDomain do
  begin
    try
      For DomainIndex := 0 to Form.ComponentCount-1 do
      begin
        if (Form.Components[DomainIndex] is TDomainEdit)
        or (Form.Components[DomainIndex] is TDomainCombo)
        or (Form.Components[DomainIndex] is TDomainMemo) then
        begin
          GenDomain.Domain := Form.Components[DomainIndex];
          Values[GenDomain.Name] := GenDomain.Text;
        end
      end;  //for all domains
      Result := CommaText;
    finally
      Free;
    end;
  end;  //with sl
end;

function Enumerate(Form:TCustomForm):String;
var
   I:Integer;
   SL:TPackStringList;
   ISL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   ISL:=TPackStringList.Create;
   if FirstTime then
   begin
      for I:=0 to Form.ComponentCount-1 do
      begin
         if (Form.Components[I] is TDomainEdit) then
         begin
            if ((Form.Components[I] as TDomainEdit).DefaultValue = 'Now') and (Copy((Form.Components[I] as TDomainEdit).Validation,1,4) = 'Date') then
            begin
               (Form.Components[I] as TDomainEdit).DefaultValue:=FormatDateTime('dd/mm/yy',Now);
               (Form.Components[I] as TDomainEdit).Text:=(Form.Components[I] as TDomainEdit).DefaultValue;
            end
            //else if ((Form.Components[I] as TDomainEdit).UseDefault) then
            else if ((Form.Components[I] as TDomainEdit).DefaultValue <> '') then
               (Form.Components[I] as TDomainEdit).Text:=(Form.Components[I] as TDomainEdit).DefaultValue
//            else if ((Form.Components[I] as TDomainEdit).UseDefault) then
//               (Form.Components[I] as TDomainEdit).Text:=(Form.Components[I] as TDomainEdit).DefaultValue
         end
         else if (Form.Components[I] is TDomainCombo)
         and ((Form.Components[I] as TDomainCombo).UseDefault) then
            (Form.Components[I] as TDomainCombo).Text:=(Form.Components[I] as TDomainCombo).DefaultValue
         else if (Form.Components[I] is TDomainMemo)
         and ((Form.Components[I] as TDomainMemo).UseDefault) then
            (Form.Components[I] as TDomainMemo).Text:=(Form.Components[I] as TDomainMemo).DefaultValue;
      end;
      FirstTime:=False;
   end;
   for I:=0 to Form.ComponentCount-1 do
   begin
      if (Form.Components[I] is TDomainEdit) and
         ( (not (Form.Components[I] as TDomainEdit).Ignore) or (TDomainEdit(Form.Components[I]).Name = 'Weight') )then
         SL.Add((Form.Components[I] as TDomainEdit).LineData)
      else if (Form.Components[I] is TDomainCombo) and (not (Form.Components[I] as TDomainCombo).Ignore) then
         SL.Add((Form.Components[I] as TDomainCombo).LineData)
      else if (Form.Components[I] is TDomainMemo) and (not (Form.Components[I] as TDomainMemo).Ignore) then
         SL.Add((Form.Components[I] as TDomainMemo).LineData);
   end;
   SL.Sort;
   // remove SortIndex
   for I:=0 to SL.Count-1 do
   begin
      ISL.PackText:=SL[I];
      ISL.Delete(0);
      SL[I]:=ISL.PackText;
   end;
   Result:=SL.PackText;
   SL.Free;
   ISL.Free;
end;
function EnumerateData(Form:TCustomForm):String;
var
   I:Integer;
   SL:TPackStringList;
   ISL:TPackStringList;
   LineSL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   ISL:=TPackStringList.Create;
   LineSL:=TPackStringList.Create;
   for I:=0 to Form.ComponentCount-1 do
   begin
      if (Form.Components[I] is TDomainEdit) and (not (Form.Components[I] as TDomainEdit).Ignore) then
      begin
         LineSL.PackText:=(Form.Components[I] as TDomainEdit).LineData;
         while LineSL.Count > 7 do LineSL.Delete(6);
         SL.Add(LineSL.PackText);
      end
      else if (Form.Components[I] is TDomainCombo) and (not (Form.Components[I] as TDomainCombo).Ignore) then
      begin
         LineSL.PackText:=(Form.Components[I] as TDomainCombo).LineData;
         while LineSL.Count > 7 do LineSL.Delete(6);
         SL.Add(LineSL.PackText);
      end
      else if (Form.Components[I] is TDomainMemo) and (not (Form.Components[I] as TDomainMemo).Ignore) then
      begin
         LineSL.PackText:=(Form.Components[I] as TDomainMemo).LineData;
         while LineSL.Count > 7 do LineSL.Delete(6);
         SL.Add(LineSL.PackText);
      end;
   end;
   LineSL.Free;
   SL.Sort;
   // remove SortIndex
   for I:=0 to SL.Count-1 do 
   begin
      ISL.PackText:=SL[I];
      ISL.Delete(0);
      SL[I]:=ISL.PackText;
   end;
   Result:=SL.PackText;
   SL.Free;
   ISL.Free;
end;        
procedure ClearFocus(Form:TCustomForm);
var
   I:Integer;
begin
   if Form <> nil then
   begin
      for I:=0 to Form.ComponentCount-1 do
      begin
         Form.Components[I].Tag:=0;
      end;
   end;
end;
procedure MoveFocusTo(Component:TComponent);
var
   I:Integer;
   Form:TCustomForm;
begin
   Form:=nil;
   if Component = nil then Exit;
   if (Component is TDomainEdit) then
      Form:=TForm((Component as TDomainEdit).Parent)
   else if (Component is TDomainCombo) then
      Form:=TForm((Component as TDomainCombo).Parent)
   else if (Component is TDomainMemo) then
      Form:=TForm((Component as TDomainMemo).Parent);
   if Form <> nil then
   begin
      for I:=0 to Form.ComponentCount-1 do
      begin
         if Form.Components[I] = Component then 
            Form.Components[I].Tag:=1
         else
            Form.Components[I].Tag:=0;
      end;
   end;
end;        
procedure ReFill(Value:String;Form:TCustomForm);
var
   Index,I:Integer;
   SL:TPackStringList;
   TSL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=Value;

   for I:=0 to SL.Count-1 do
   begin
      TSL:=TPackStringList.Create;
      TSL.PackText:=SL[I];
      SL.Objects[I]:=TObject(TSL);
      //check component name is in list
      If TSL.Count > 3 then
        SL.Strings[I]:=TSL[3];
   end;

   for I:=0 to Form.ComponentCount-1 do
   begin
      Index:=SL.IndexOf(Form.Components[I].Name);
      if Index <> -1 then
      begin
         TSL:=TPackStringList(SL.Objects[Index]);
         if (Form.Components[I] is TDomainEdit) then
            (Form.Components[I] as TDomainEdit).SetLineData(TSL)
         else if (Form.Components[I] is TDomainCombo) then
            (Form.Components[I] as TDomainCombo).SetLineData(TSL)
         else if (Form.Components[I] is TDomainMemo) then
            (Form.Components[I] as TDomainMemo).SetLineData(TSL);
         TSL.Free;
         SL.Objects[Index]:=nil;
      end;
   end;
   SL.Free;
end;
procedure PopulateCombo(Field:TDomainCombo);
var
  CompMan      : ICompMan;
  PickList     : IPickList;
  PickListName : TStringObject;
  I            : Integer;
  SO           : TStringObject;
  Translator   : ITranslate;
begin
  //clear current domaincombo
  for I:=0 to Field.Items.Count-1 do
    if (Field.Items.Objects[I] <> nil)
    and (Field.Items.Objects[I] is TStringObject) then
      (Field.Items.Objects[I] as TStringObject).Free;
  Field.Items.Clear;

  PickListName := TStringObject.Create(Field.AssociatedProgID);
  CompMan:=CreateCompMan;
  Translator:=CreateTranslator;
  try
    if CompMan <> nil then
    begin
      //fill with picklists' content
      While PickListName.Strings.Count > 0 do
      begin
        if LeftOf(PickListName.Strings[0],'PickList.') then
        begin
          PickList:=CompMan.LoadComponent(PickListName.Strings[0]) as IPickList;
          if PickList <> nil then
          begin
            PickList.CurrentColumn:='';
            for I:=0 to PickList.RowCount-1 do
              Field.Items.Add(Translator.Translate(PickList.Item[I]));
            PickList.CurrentColumn:='Zone';
            for I:=0 to PickList.RowCount-1 do
            begin
              SO:=TStringObject.Create(PickList.Item[I]);
              Field.Items.Objects[I]:=SO;
            end;
            PickList:=nil;
          end;
        end;
        PickListName.Strings.Delete(0);
      end;  //while more pick lists used
    end;  //if CompMan <> nil
  finally
    PickListName.Free;
    CompMan:=nil;
    Translator:=nil;
  end;
end;

procedure SetDefaultValues(Form : TCustomForm);
//fills form componetns with default values where required
var
  DomainEdit  : TDomainEdit;
  I           : Integer;
begin
  for I:=0 to Form.ComponentCount-1 do
  begin
    //TDomainEdit
    if (Form.Components[I] is TDomainEdit) then
    begin
      DomainEdit := Form.Components[I] as TDomainEdit;
      if (DomainEdit.DefaultValue = 'Now')
      and (Copy(DomainEdit.Validation,1,4) = 'Date') then
      begin
         DomainEdit.DefaultValue  :=  FormatDateTime('dd/mm/yy',Now);
         DomainEdit.Text          :=  DomainEdit.DefaultValue;
      end
      else if DomainEdit.UseDefault then
        DomainEdit.Text := DomainEdit.DefaultValue
    end
    //TDomainCombo
    else if (Form.Components[I]is TDomainCombo)
    and ((Form.Components[I] as TDomainCombo).UseDefault) then
    begin
      (Form.Components[I] as TDomainCombo).Text:=(Form.Components[I] as TDomainCombo).DefaultValue
    end;
  end;
end;

procedure SetAssociated(Form:TCustomForm;ProgID:String;Price:Currency);
var
   I:Integer;
begin
  for I:=0 to Form.ComponentCount-1 do
  begin
    if (Form.Components[I] is TDomainEdit)
    and ((Form.Components[I] as TDomainEdit).AssociatedProgID = ProgID)
    and (Price <> 0) then
       (Form.Components[I] as TDomainEdit).DefaultValue:=CurrToStrF(Price,ffNumber,CurrencyDecimals)
    else if (Form.Components[I] is TDomainCombo) then
      PopulateCombo(Form.Components[I] as TDomainCombo);

  end;
  SetDefaultValues(Form); //now set any default values in domains
end;

{TDomainEdit}
function TDomainEdit.GetText:TCaption;
begin
   Result:=inherited Text;
end;
procedure TDomainEdit.SetText(Value:TCaption);
begin
   FDontCheck:=True;
   inherited Text:=Value;
   FDontCheck:=False;
end;

procedure TDomainEdit.SetValidation(Value:String);
begin
  FValidation := Value;
  If ValidType = vtMask then
  begin
    If AutoCompleteExclusions.IndexOf(SubString(Validation,'(', ')')) <> -1 then  //check exclusions
      AutoComplete := False
    else
      AutoComplete := StrToIntDef(GetGPCSRegString('System Parameters', 'Domain Autocomplete','1'),1) <> 0; //otherwise use global setting
  end;
end;

function TDomainEdit.GetValidation:String;
begin
   result := FValidation ; //FOrgValidation;
end;
constructor TDomainEdit.Create(AOwner: TComponent);
var
  RegValues : Variant;
begin
   inherited Create(AOwner);
   AutoCompleteExclusions := TStringList.Create;
   RegValues := VarArrayCreate([0, 1], varVariant);
   RegistryEx.GetRegistryValues('HKLM\Software\PSL\GPCS\System Parameters\AutoComplete Exclusions', AutoCompleteExclusions, RegValues);
   AutoComplete := StrToIntDef(GetGPCSRegString('System Parameters', 'Domain Autocomplete','1'),1) <> 0;

   FSilenceBell:=False;
   FForceLgTil:=0;
   FPrompt:=nil;
   FOptions:=TOptionsString.Create ;
   //FDontGetText:=False;
   StateTrigger:=NoTriggerCode;
end;
destructor TDomainEdit.Destroy;
begin
   AutoCompleteExclusions.Free;
   if FOptions<> nil then
   begin
      FOptions.Free ;
      FOptions:=nil;
   end ;
   inherited Destroy ;
end ;

//procedure TDomainEdit.SetDontGetText(Value:Boolean);
//begin
//   FDontGetText:=Value;
//end ;
//function  TDomainEdit.GetDontGetText:Boolean;
//begin
//   result := FDontGetText;
//end ;
procedure TDomainEdit.SetStateTrigger(Value:TStateTriggerCode);
begin
   FStateTrigger:=Value;
end ;
function  TDomainEdit.GetStateTrigger:TStateTriggerCode;
begin
   result := FStateTrigger;
end ;


procedure TDomainEdit.ValidateOK;
begin
end;
procedure TDomainEdit.ValidateError;
begin
   if not FSilenceBell then
     Beep;
end;
procedure TDomainEdit.SetLineData(Value:TPackStringList);
begin
   if Value.Count > 5 then
      Text:=Value[5]
   else
      Text:='';
end; 
procedure TDomainEdit.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
   inherited;
   if FPrompt<> nil then
   begin
      FPrompt.Left:=Left-(FPrompt.Width+3);
      FPrompt.Top:=Top+3;
   end;
end;                    
procedure TDomainEdit.SetPrompt(Value:TLabel);
begin
   FPrompt:=Value;
   if FPrompt <> nil then
   begin
      FPrompt.Left:=Left-(FPrompt.Width+3);
      FPrompt.Top:=Top+3;
   end;
end;
function TDomainEdit.LineData:String;
var
  SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(IntToHex(TabOrder,3));
   if (Ignore and (Name='Weight')) then
      SL.Add('2')
   else
      if Enabled then SL.Add('1') else SL.Add('0');
   if Tag = 1 then SL.Add('1') else SL.Add('0');
   SL.Add('M');
   SL.Add(Name);
   if PromptLabel = nil then SL.Add('') else SL.Add(PromptLabel.Caption);
   SL.Add(Text);
   SL.Add(Hint);
   SL.Add(ErrorText);
   SL.Add(FValidation);
   SL.Add(AssociatedProgId);
   SL.Add(IntToStr(Locale));
   Result:=SL.PackText;
   SL.Free;
end;
procedure TDomainEdit.CheckCharMask( var ch : Char; PosKey : integer );
begin
  if ( PosKey < Length(FMask)) and (ch in ['A'..'Z','a'..'z']) then
  begin
    case FMask[PosKey+1] of
      'U' : ch:=UpCase(ch);
      'L' : ch:=LoCase(ch);
      '9' : ;
      '+' : ;
      'X' : ch:=UpCase(ch);
      'x' : ;
      else
        //force to mask case
        if UpCase(FMask[PosKey+1]) = UpCase(ch) then
          ch:=FMask[PosKey+1];
    end;  //Case
  end;  //

end ;
procedure TDomainEdit.KeyPress(var Key: Char);
begin

  if StateTrigger = noTriggerCode then
  begin
     CheckCharMask( Key, FPreKeySelStart ) ;
     FillEditWithMask( Key ) ;
     //requires the typed char
     If (FPreKeySelStart  < Length(FMask))
     or (Integer(Key) in [VK_BACK]) then //literals not at end of mask
       inherited KeyPress(Key)
     else
       Key := #0;
  end;

end;
procedure TDomainEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin

   FPreKeyData:=Text;
   inherited KeyDown(Key,Shift);
   SendMessage(Handle,EM_GETSEL,Integer(@FPreKeySelStart),Integer(@FPreKeySelEnd));

end;
procedure TDomainEdit.WMChar(var Message: TWMChar);
begin

//   if not (Message.CharCode in [VK_RETURN,VK_ESCAPE,VK_F1..VK_F12])then
   if (Message.CharCode <> VK_RETURN) and (Message.CharCode <> VK_ESCAPE) then
      inherited;
end;
procedure TDomainEdit.Change;
begin

    if StateTrigger = noTriggerCode  then
    begin

      if FDontCheck then Exit;
      if not Validate then
      begin
         FDontCheck:=True;
         Text:=FPreKeyData;
         FDontCheck:=False;
         SendMessage(Handle,EM_SETSEL,FPreKeySelStart,FPreKeySelEnd);
      end
      else
         inherited Change;
    end ;

end;

procedure TDomainEdit.SetPasswordChar(Value:Char);
begin
   if FDontCheck then
   begin
      PasswordChar:=Value;
   end
   else
   begin
     FDontCheck:=True;
     PasswordChar:=Value;
     FDontCheck:=False;
   end;
end;
function TDomainEdit.ValidType:TValidType;
var
   S:String;
   I:Integer;
   RMC:Currency;
begin
   result:=vtMask;
   FMask:='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
   if Validation = '' then Validation:='Mask(xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)';
   if Copy(Validation,1,8) <> 'Password' then SetPasswordChar(#0);
   if Copy(Validation,1,4) = 'Mask' then
   begin
      result:=vtMask;
      FMask:=CleanMask(Copy(Validation,6,Length(Validation)-6));
   end
   else if Copy(Validation,1,4) = 'List'    then
   begin
   end
   else if Copy(Validation,1,5) = 'Range'    then
   begin
      result:=vtRange;
      FMask:=Copy(Validation,7,Length(Validation)-7);
      for I:=7 to Length(Validation) do
      begin
         if Validation[I] = ',' then
         begin
            S:=Copy(Validation,7,I-7);
            FRangeFrom:=StrToIntDef(S,0);
            S:=Copy(Validation,I+1,9999);
            S:=Copy(S,1,Length(S)-1);
            FRangeTo:=StrToIntDef(S,0);
            break;
         end;
      end;
      S:=IntToStr(FRangeTo);
      FMask:='';
      for I:=1 to Length(S) do
        FMask:=FMask+'9';
   end
   else if Copy(Validation,1,8) = 'PickList' then
   begin
   end
   else if Copy(Validation,1,8) = 'Currency' then
   begin
      result:=vtCRange;
      FMask:=Copy(Validation,10,Length(Validation)-10);
      for I:=7 to Length(Validation) do
      begin
         if Validation[I] = ',' then
         begin
            S:=Copy(Validation,10,I-10);
            FCRangeFrom:=StrToCurrDef(S,0);
            S:=Copy(Validation,I+1,9999);
            S:=Copy(S,1,Length(S)-1);
            FCRangeTo:=StrToCurrDef(S,0);
            RMC:=StrToCurrDef(GetGPCSRegString('','Max Currency','0'),0);
            if (RMC > 0) and (RMC < FCRangeTo) then
               FCRangeTo:=RMC;
            break;
         end;
      end;
      S:=CurrToStrF(FCRangeTo,ffNumber,CurrencyDecimals);
      FMask:='';
      for I:=1 to Length(S) do
        FMask:=FMask+'+';
   end
   else if Copy(Validation,1,4) = 'Date'     then
   begin
      FMask:='99/99/99';
   end
   else if Copy(Validation,1,8) = 'Password' then
   begin
//      FMask:='xxxxxxxxxxxx';
      SetPasswordChar('*');
   end;
   FTestLength:=False;
   for I:=1 to Length(FMask) do
   begin
      if ((FMask[I] <> 'x') and (FMask[I] <> 'X')) then
      begin
         FTestLength:=True;
         break;
      end;
   end;
end;
function HasDot(Text:String;Index:Integer):Boolean;
var
   I:Integer;
begin
   Result:=True;
   for I:=1 to Length(Text) do
      if (Text[I] = '.') and (I <> Index) then Exit;
   Result:=False;
end;
function TDomainEdit.MaskValOK(var Text : string; Mask:String;Index:Integer):Boolean;
var
  ch : Char;
begin
   Result:=False;
   if Index > Length(Mask) then Exit;
   case Mask[Index] of
      '9' : if not (Text[Index] in ['0'..'9']) then Exit;
      '+' : begin
               if Index = 1 then
               begin
                  if not (Text[Index] in ['0'..'9','+','-','.',',']) then Exit;
               end
               else
               begin
                  if (Text[Index] = '.') and HasDot(Text,Index) then Exit;
                  if not (Text[Index] in ['0'..'9','.',',']) then Exit;
               end;
               if not ((Index = 1) and (Text[Index] in ['+','-','.'])) then
               begin
                  if (StrToCurrDef(Text,FCRangeFrom-1) < FCRangeFrom)
                  or (StrToCurrDef(Text,FCRangeTo+1) > FCRangeTo) then Exit;
               end;
            end;
      'U' : if not (UpCase(Text[Index]) in ['A'..'Z']) then Exit;
      'L' : if not (LoCase(Text[Index]) in ['a'..'z']) then Exit;
      'X' : if not (Text[Index] in ['0'..'9','A'..'Z']) then Exit;
      'x' : ;
      '!' : begin
              ch := Text[Index];
              if not FOptions.IsInOption( Index, ch) then
                Exit
              else
                Text[Index] := ch;
            end;
      else if UpCase(Text[Index]) <> UpCase(Mask[Index]) then Exit;
   end;
   Result:=True;
end;
function TDomainEdit.ValidationComplete:Boolean;
begin
   FSilenceBell:=True;
   Result:=Validate;
   FSilenceBell:=False;

   if (Text = '') then
      Result:=False ;

   if Result then
   begin

      if(FForceLgTil>0) and (ValidType = vtMask) then
      begin
         if (FForceLgTil > Length( Text ) ) then
         Result:=False
      end
      else
         if (ValidType = vtMask) and (FTestLength ) and
            (Length(Text) <> Length(FMask))  then
            Result:=False;
   end ;

end;
function TDomainEdit.Validate:Boolean;
var
  I:Integer;
  Val:Integer;
  Curr:Currency;
  Txt : String;
  OrigPos : Integer;
begin
  Result:=False;
  Txt := Text;
  OrigPos := SelStart;
  Case ValidType of
      vtMask  :
      begin
        for I:=1 to Length(Txt) do
          if not MaskValOK(Txt,FMask,I) then
          begin
            ValidateError;
            Exit;
          end;
        Result:=True;
      end;

      vtRange :
         begin
            for I:=1 to Length(Txt) do
            begin
               if not MaskValOK(Txt,FMask,I) then
               begin
                  ValidateError;
                  Exit;
               end;
            end;

            Val:=StrToIntDef(Text,$0);
            if (Length(IntToStr(FRangeTo)) = Length(IntToStr(FRangeFrom))) and (Length(Txt) >= Length(IntToStr(FRangeFrom))) then
            begin
               if (Val <= FRangeTo) and (Val >= FRangeFrom) then
                  Result:=True;
            end
            else if (Length(Txt) > Length(IntToStr(FRangeFrom))) then
            begin
                  if (Val <= FRangeTo) then
                     Result:=True;
            end;
            begin
               if Val <= FRangeTo then
                  Result:=True;
            end;
         end;
      vtCRange :
         begin
            for I:=1 to Length(Txt) do
            begin
               if not MaskValOK(Txt,FMask,I) then
               begin
                  ValidateError;
                  Exit;
               end;
            end;

            Curr:=StrToCurrDef(Txt,0);
            if (Length(Txt) >= Length(CurrToStrF(FCRangeFrom,ffNumber,CurrencyDecimals))) then
            begin
               if (Curr <= FCRangeTo) and (Curr >= FCRangeFrom) then
                  Result:=True;
            end
            else
            begin
               if Curr <= FCRangeTo then
                  Result:=True;
            end;
         end;
   end; //case
   Text := Txt;
   SelStart := OrigPos;
   if not Result then ValidateError else ValidateOK;
end;

function TDomainEdit.CleanMask(Value:String):string ;
var
   BreakLoop :Boolean ;
   PosOpenBracket,PosCloseBracket,PosAt:integer;
   Options:String;
begin

   BreakLoop := False ;
   FOptions.Clear ;
   while not BreakLoop do
   begin

      PosOpenBracket := Pos( '[', Value );
      PosCloseBracket:= Pos( ']', Value );
      PosAt          := Pos( '@', Value );

      if (PosAt > 0 ) and ((PosAt < PosCloseBracket) OR (PosCloseBracket =0)) then
      begin
         Value := Copy( Value, 1, PosAt-1)+
                        Copy( Value, PosAt+1, 999 );
         FForceLgTil := PosAt-1
       end
      else
         if PosCloseBracket>0 then
         begin
            Options := Copy( Value, PosOpenBracket+1, PosCloseBracket-PosOpenBracket-1);
            Value:=Copy( Value,1,PosOpenBracket-1)+'!'+Copy(Value,PosCloseBracket+1,999);
            FOptions.Add( PosOpenBracket, Options );
         end
         else
            BreakLoop:=True ;

   end ;

   Result:=Value;

end ;

procedure TDomainEdit.FillEditWithMask( var key : Char ) ;
var
   I : integer ;
   scape : boolean;
   EditText : String ;
   ch : char ;
begin
  //insert mask char(s)
   EditText := Text + key ;
   I := Length(Text)+1 ;
   Scape := False ;
   While AutoComplete
   and not (UpCase(FMask[I])  in ['U', 'L', '+', 'X', '9']) //literal mask char
   and     (I <= Length(FMask))
   and not (Integer(key) in [VK_BACK,VK_DELETE,VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN]) //not a modify or navigation key
   and not Scape
   and not MaskValOK(EditText, FMask, I ) do                                    //more chars allowed
   begin
        //handle optional lists
      ch:= FMask[I] ;  //single mask char
      If (ch = '!') and not FOptions.GetOnlyOption(I, ch ) then //multi options for this position
      begin
        I := Length(FMask)+1 ;
        ch:=#0;
        Scape  := True ;
      end;

      if not Scape then
      begin
         Text := Text + ch ;
         Inc(I);
         SelStart := I;
      end ;
      EditText := Text ;

   end;

   FPreKeySelStart := SelStart;
   CheckCharMask( Key, Length(Text) ) ;


end ;

{TDomainCombo}
constructor TDomainCombo.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FPrompt:=nil;
end;
destructor TDomainCombo.Destroy;
//var
//   I:Integer;
begin
//   for I:=0 to Items.Count-1 do
//      if (Items.Objects[I] <> nil) and (Items.Objects[I] is TStringObject) then
//         (Items.Objects[I] as TStringObject).Free;
   inherited Destroy;
end;
procedure TDomainCombo.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
   inherited;
   if FPrompt<> nil then
   begin
      FPrompt.Left:=Left-(FPrompt.Width+3);
      FPrompt.Top:=Top+3;
   end;
end;
procedure TDomainCombo.SetPrompt(Value:TLabel);
begin
   FPrompt:=Value;
   if FPrompt <> nil then
   begin
      FPrompt.Left:=Left-(FPrompt.Width+3);
      FPrompt.Top:=Top+3;
   end;
end;
function TDomainCombo.LineEditData:String;
var
  Index:Integer;
  SL:TPackStringList;
  ResSL:TPackStringList;
  InResSL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   ResSL:=TPackStringList.Create;
   InResSL:=TPackStringList.Create;
   for Index:=0 to Items.Count-1 do
   begin
      SL.PackText:=Items[Index];
      InResSL.Clear;
      if SL.Count > 3 then InResSL.Add(SL[3]) else InResSL.Add('1');
      if SL.Count > 2 then InResSL.Add(SL[2]) else InResSL.Add('0');
      InResSL.Add('M');
      InResSL.Add(IntToHex(Index,3));
      if SL.Count > 0 then InResSL.Add(SL[0]) else InResSL.Add('');
      if SL.Count > 1 then InResSL.Add(SL[1]) else InResSL.Add('');
      InResSL.Add(Hint);
      InResSL.Add(ErrorText);
      InResSL.Add(FEMaskValue);
      InResSL.Add('');//AssociatedProgId;
      InResSL.Add(IntToStr(FLocale));      
      ResSL.Add(InResSL.PackText);
   end;   
   Result:=ResSL.PackText;
   SL.Free;
   ResSL.Free;
   InResSL.Free;
end;         
procedure TDomainCombo.SetLineEditData(Value:String);
var
   SL:TPackStringList;
   ItemSL:TPackStringList;
   ComboSL:TPackStringList;        
   I:Integer;
begin
   SL:=TPackStringList.Create;
   ItemSL:=TPackStringList.Create;
   ComboSL:=TPackStringList.Create;
   SL.PackText:=Value;
   for I:=0 to SL.Count-1 do
   begin
      ItemSL.PackText:=SL[I];
      ComboSL.PackText:=Items[I];
      if (ItemSL.Count > 5) and (ComboSL.Count > 1) then 
      begin
         ComboSL[1]:=ItemSL[5];
         Items[I]:=ComboSL.PackText;
      end;
   end;
   SL.Free;
   ItemSL.Free;
   ComboSL.Free;
end;
function TDomainCombo.LineData:String;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Add(IntToHex(TabOrder,3));
   if Enabled then SL.Add('1') else SL.Add('0');
   if Tag = 1 then SL.Add('1') else SL.Add('0');
   SL.Add('L');
   SL.Add(Name);
   if PromptLabel <> nil then SL.Add(PromptLabel.Caption) else SL.Add('');
   SL.Add(Text);
   SL.Add(Hint);
   SL.Add(ErrorText);
   SL.Add(IntToStr(Locale));
   SL.AddStrings(Items);
   Result:=SL.PackText;
   SL.Free;
end;
procedure TDomainCombo.SetLineData(Value:TPackStringList);
begin
   if Value.Count > 5 then
      Text:=Value[5]
   else
      Text:='';
end;   
{TDomainMemo}
constructor TDomainMemo.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FPrompt:=nil;
end;
destructor TDomainMemo.Destroy;
begin
   inherited Destroy;
end;
procedure TDomainMemo.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
   inherited;
   if FPrompt<> nil then
   begin
      FPrompt.Left:=Left-(FPrompt.Width+3);
      FPrompt.Top:=Top+3;
   end;
end;                    
procedure TDomainMemo.SetPrompt(Value:TLabel);
begin
   FPrompt:=Value;
   if FPrompt <> nil then
   begin
      FPrompt.Left:=Left-(FPrompt.Width+3);
      FPrompt.Top:=Top+3;
   end;
end;
function TDomainMemo.LineData:String;
var
   SL:TPackStringList;
   ISL:TPackStringList;
begin
   ISL:=TPackStringList.Create;
   ISL.Text:=Lines.Text;
   SL:=TPackStringList.Create;
   SL.Add(IntToHex(TabOrder,3));
   if Enabled then SL.Add('1') else SL.Add('0');
   if Tag = 1 then SL.Add('1') else SL.Add('0');
   SL.Add('E');
   SL.Add(Name);
   if PromptLabel <> nil then SL.Add(PromptLabel.Caption) else SL.Add('');
   SL.Add(Text);
   SL.Add(Hint);
   SL.Add(ErrorText);
   SL.Add(ISL.PackText);
   ISL.Free;
   Result:=SL.PackText;
   SL.Free;
end;  
procedure TDomainMemo.SetLineData(Value:TPackStringList);
begin
   if Value.Count > 5 then
      Text:=Value[5]
   else
      Text:='';
end;
procedure Register;
begin
  RegisterComponents('CorvusVCL', [TDomainEdit,TDomainCombo,TDomainMemo]);
end;

end.
