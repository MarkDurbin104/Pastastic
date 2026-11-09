unit ODomain;

interface         
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,Mask;

type
  TDomainEdit = class(TMaskEdit)            
  private
     FIgnore:Boolean;
     FPrompt:TLabel;
     FErrorText:String;
     FRangeFrom:Integer;
     FRangeTo  :Integer;
     FAssocProgId:String;
     FDefaultValue:String;
     FUseDefault:Boolean;
     procedure SetPrompt(Value:TLabel);
     procedure SetRangeFrom(Value:Integer);
     procedure SetRangeTo  (Value:Integer);
  public
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetLineData(Value:TStringList);
    function LineData:String;
  published
    property PromptLabel:TLabel read FPrompt write SetPrompt;
    property ErrorText:String   read FErrorText write FErrorText;
    property RangeFrom:Integer read FRangeFrom write SetRangeFrom;
    property RangeTo  :Integer read FRangeTo   write SetRangeTo  ;
    property Ignore:Boolean read FIgnore write FIgnore;
    property AssociatedProgId:String read FAssocProgId write FAssocProgId;
    property DefaultValue:String read FDefaultValue write FDefaultValue;
    property UseDefault:Boolean read FUseDefault write FUseDefault;
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
     procedure SetPrompt(Value:TLabel);
  public
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function LineData:String;
    procedure SetLineData(Value:TStringList);
    function LineEditData:String;
    procedure SetLineEditData(Value:String);
  published                                  
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
    procedure SetLineData(Value:TStringList);
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
procedure ReFill(Value:String;Form:TCustomForm);
procedure MoveFocusTo(Component:TComponent);
procedure ClearFocus(Form:TCustomForm);
procedure SetAssociated(Form:TCustomForm;ProgID:String;Price:Currency);

var
   FirstTime:Boolean;
procedure Register;

implementation
{TDomainEdit}
constructor TDomainEdit.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FPrompt:=nil;
   FRangeFrom:=0;
   FRangeTo  :=0;
end;
destructor TDomainEdit.Destroy;
begin
   inherited Destroy;
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

procedure TDomainEdit.SetRangeFrom(Value:Integer);
begin
   if FRangeFrom <> Value then
   begin
      FRangeFrom:=Value;
      if RangeFrom > RangeTo then FRangeFrom:=RangeTo;
      SetRangeTo(RangeTo);
   end;
end;
procedure TDomainEdit.SetRangeTo(Value:Integer);  
var
   S:String;
   I:Integer;
begin
   if FRangeTo <> Value then
   begin
      FRangeTo:=Value;
      if RangeTo < 0 then FRangeTo:=0;
      if RangeFrom > RangeTo then FRangeFrom:=RangeTo;
      if RangeTo = 0 then Exit;
      S:=IntToStr(FRangeTo);
      for I:=1 to Length(S) do S[I]:='9';
      S:=S+';1;_';
      EditMask:=S;
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
  I:Integer;
  V,S,T,E,F:String;
begin
   T:='M';
   V:='"'+EditMask+'"';
   S:='';
   if PromptLabel <> nil then S:=PromptLabel.Caption;
   if (FRangeFrom <> FRangeTo) and (FRangeFrom < FRangeTo) then
   begin
      V:=IntToStr(FRangeTo);
      for I:=1 to Length(V) do V[I]:='9';
      V:=IntTostr(RangeFrom)+','+IntTostr(RangeTo)+','+V+';1;_';
      T:='R';
   end;   
   if Tag = 1 then F:='1' else F:='0';
   if Enabled then E:='1' else E:='0';
   Result:=IntToHex(TabOrder,3)+','+E+','+F+','+T+',"'+Name+'","'+S+'","'+Text+'","'+Hint+'","'+ErrorText+'",'+V;
end;
function Enumerate(Form:TCustomForm):String;
var
   I:Integer;
   SL:TStringList;
begin
   SL:=TStringList.Create;
   if FirstTime then
   begin
      for I:=0 to Form.ComponentCount-1 do
      begin
         if (Form.Components[I] is TDomainEdit)
         and ((Form.Components[I] as TDomainEdit).UseDefault) then
            (Form.Components[I] as TDomainEdit).Text:=(Form.Components[I] as TDomainEdit).DefaultValue
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
      if (Form.Components[I] is TDomainEdit) and (not (Form.Components[I] as TDomainEdit).Ignore) then
         SL.Add((Form.Components[I] as TDomainEdit).LineData)
      else if (Form.Components[I] is TDomainCombo) and (not (Form.Components[I] as TDomainCombo).Ignore) then
         SL.Add((Form.Components[I] as TDomainCombo).LineData)
      else if (Form.Components[I] is TDomainMemo) and (not (Form.Components[I] as TDomainMemo).Ignore) then
         SL.Add((Form.Components[I] as TDomainMemo).LineData);
   end;
   SL.Sort;
   // remove SortIndex
   for I:=0 to SL.Count-1 do SL[I]:=Copy(SL[I],5,Length(SL[I]));
   Result:=SL.CommaText;
   SL.Free;
end;        
function EnumerateData(Form:TCustomForm):String;
var
   I:Integer;
   SL:TStringList;
   LineSL:TStringList;
begin
   SL:=TStringList.Create;
   LineSL:=TStringList.Create;
   for I:=0 to Form.ComponentCount-1 do
   begin
      if (Form.Components[I] is TDomainEdit) and (not (Form.Components[I] as TDomainEdit).Ignore) then
      begin
         LineSL.CommaText:=(Form.Components[I] as TDomainEdit).LineData;
         while LineSL.Count > 7 do LineSL.Delete(6);
         SL.Add(LineSL.CommaText);
      end
      else if (Form.Components[I] is TDomainCombo) and (not (Form.Components[I] as TDomainCombo).Ignore) then
      begin
         LineSL.CommaText:=(Form.Components[I] as TDomainCombo).LineData;
         while LineSL.Count > 7 do LineSL.Delete(6);
         SL.Add(LineSL.CommaText);
      end
      else if (Form.Components[I] is TDomainMemo) and (not (Form.Components[I] as TDomainMemo).Ignore) then
      begin
         LineSL.CommaText:=(Form.Components[I] as TDomainMemo).LineData;
         while LineSL.Count > 7 do LineSL.Delete(6);
         SL.Add(LineSL.CommaText);
      end;
   end;
   LineSL.Free;
   SL.Sort;
   // remove SortIndex
   for I:=0 to SL.Count-1 do SL[I]:=Copy(SL[I],5,Length(SL[I]));
   Result:=SL.CommaText;
   SL.Free;
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
procedure TDomainEdit.SetLineData(Value:TStringList);
begin
   Text:=Value[5];
end; 
procedure ReFill(Value:String;Form:TCustomForm);
var
   Index,I:Integer;
   SL:TStringList;
   TSL:TStringList;
begin
   SL:=TStringList.Create;
   SL.CommaText:=Value;
   
   for I:=0 to SL.Count-1 do
   begin
      TSL:=TStringList.Create;
      TSL.CommaText:=SL[I];
      SL.Objects[I]:=TObject(TSL);
      SL.Strings[I]:=TSL[3];
   end;
   
//   Form:=GetParentForm(Self);
   for I:=0 to Form.ComponentCount-1 do
   begin
      Index:=SL.IndexOf(Form.Components[I].Name);
      if Index <> -1 then
      begin
         TSL:=TStringList(SL.Objects[Index]);
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
procedure SetAssociated(Form:TCustomForm;ProgID:String;Price:Currency);
var
   I:Integer;
begin
   for I:=0 to Form.ComponentCount-1 do
   begin
      if (Form.Components[I] is TDomainEdit) 
      and ((Form.Components[I] as TDomainEdit).AssociatedProgID = ProgID) then
         (Form.Components[I] as TDomainEdit).DefaultValue:=CurrToStr(Price)
      else if (Form.Components[I] is TDomainCombo)
      and ((Form.Components[I] as TDomainCombo).AssociatedProgID = ProgID) then
         (Form.Components[I] as TDomainCombo).DefaultValue:=CurrToStr(Price)
      else if (Form.Components[I] is TDomainMemo)
      and ((Form.Components[I] as TDomainMemo).AssociatedProgID = ProgID) then
         (Form.Components[I] as TDomainMemo).DefaultValue:=CurrToStr(Price)
   end;    
end;
{TDomainCombo}
constructor TDomainCombo.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FPrompt:=nil;
end;
destructor TDomainCombo.Destroy;
begin
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
  V,S,T,E,F:String;
  Index:Integer;
  SL:TStringList;
  ResSL:TStringList;
  Txt:String;
begin
   SL:=TStringList.Create;
   ResSL:=TStringList.Create;
   for Index:=0 to Items.Count-1 do
   begin
      SL.CommaText:=Items[Index];
      T:='M';         
      V:='"'+FEMaskValue+'"';
      S:='';
      if SL.Count >= 0 then S:=SL[0];
      if SL.Count > 0 then Txt:=SL[1];
      if SL.Count > 1 then F:=SL[2] else F:='0';
      if SL.Count > 2 then E:=SL[3] else E:='1';
      ResSL.Add(E+','+F+','+T+',"'+IntToHex(Index,3)+'","'+S+'","'+Txt+'","'+Hint+'","'+ErrorText+'",'+V);
   end;   
   Result:=ResSL.CommaText;
   SL.Free;
   ResSL.Free;
end;         
procedure TDomainCombo.SetLineEditData(Value:String);
var
   SL:TStringList;
   ItemSL:TStringList;
   ComboSL:TStringList;        
   I:Integer;
begin
   SL:=TStringList.Create;
   ItemSL:=TStringList.Create;
   ComboSL:=TStringList.Create;
   SL.CommaText:=Value;
   for I:=0 to SL.Count-1 do
   begin
      ItemSL.CommaText:=SL[I];
      ComboSL.CommaText:=Items[I];
      if (ItemSL.Count > 4) and (ComboSL.Count > 0) then 
      begin
         ComboSL[1]:=ItemSL[5];
         Items[I]:=ComboSL.CommaText;
      end;
   end;
   SL.Free;
   ItemSL.Free;
   ComboSL.Free;
end;
function TDomainCombo.LineData:String;
var
   S:String;
   F:String;
   E:String;
begin
   if Tag = 1 then F:='1' else F:='0';
   if Enabled then E:='1' else E:='0';
   if PromptLabel <> nil then S:=PromptLabel.Caption else S:='';
   Result:=IntToHex(TabOrder,3)+','+E+','+F+',L,"'+
           Name                +'","'+
           S                   +'","'+
           Text                +'","'+
           Hint                +'","'+
           ErrorText           +'",'+
           Items.CommaText;
end;
procedure TDomainCombo.SetLineData(Value:TStringList);
begin
   Text:=Value[5];
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
   S:String;
   F:String;
   E:String;
begin
   if Tag = 1 then F:='1' else F:='0';
   if Enabled then E:='1' else E:='0';
   if PromptLabel <> nil then S:=PromptLabel.Caption else S:='';
   Result:=IntToHex(TabOrder,3)+','+E+','+F+',E,"'+
           Name                +'","'+
           S                   +'",,"'+
           Text                +'","'+
           Hint                +'","'+
           ErrorText           +'",'+
           Lines.CommaText;
end;  
procedure TDomainMemo.SetLineData(Value:TStringList);
var
   I:Integer;
begin
   for I:=0 to 7 do Value.Delete(0);
   Lines.Assign(Value);
end; 
procedure Register;
begin
  RegisterComponents('CorvusVCL', [TDomainEdit,TDomainCombo,TDomainMemo]);
end;

end.
