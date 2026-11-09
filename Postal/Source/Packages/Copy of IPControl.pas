unit IPControl;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, {Dialogs,}
  StdCtrls, Domain,GPCSBase_TLB,GPCSGUID,Printers,PackStrListU;

type
  TIPMode  = (ipmPick,ipmForm,ipmList,ipmCols,ipmTrans,ipmAcct);
  TNotifyExecute = procedure (ProgID:String) of object;
  TSetText = procedure (var Value:String) of object;
  TSetData = function (var Value:String):Boolean of object;
  TSetPick = procedure (var Value:String;Index:Integer) of object;
  TSetInt  = procedure (var Value:Integer) of object;
  TSetMode = procedure (var Value:TIPMode) of object;
  TIPControl = class(TDomainEdit)
  private
     FRightAnchor:Boolean;
     HotKeys:IHotKeys;
     FLCurrentItem:Integer;
     FLCurrentMode:TIPMode;
     FLList:TPackStringList;
     FLItemPicked:TSetPick;
     FCurrentItem:Integer;
     FCurrentMode:TIPMode;
     FList:TPackStringList;
     FSetPrompt:TSetText;
     FSetHint  :TSetText;
     FSetError :TSetText;
     FSetList  :TSetText;
     FOnExecute :TNotifyExecute;
     FItemPicked:TSetPick;
     FSelectItem:TSetInt;
     FSetMode   :TSetMode;
     FDataChange:TSetData;
     FErrorText:String;
     FFormModified:Boolean;
  protected
     function FindEndOfList(List:String):Integer;
     function  ZeroPad(Value,MaxVal:Integer;var Mask:String):String;
     procedure UpdateEdit(FlagError:Boolean);
     procedure PickKey(CharCode:Integer);
     procedure FormKey(CharCode:Integer);
     procedure TransKey(CharCode:Integer);
     procedure AcctKey(CharCode:Integer);
     function SaveData:Boolean;
     procedure SwapTo;
     procedure SwapFrom(var Value:String;Index:Integer);
     procedure SetValidation(Value:String); override;
  public 
    InSwapTo:Boolean;
    InModal:Boolean;
    ModalExcept:String;
    DontUpdate:Boolean;
    procedure MoveKey(CharCode:Integer);
    procedure AcctMoveKey(CharCode:Integer);
    procedure TransMoveKey(CharCode:Integer);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure PickFrom(List,Prompt,Hint:String);
    procedure TxnLog(List,Prompt,Hint:String);
    procedure AcctLog(List,Prompt,Hint:String);
    procedure ShowForm(List:String;FlagError,NewForm:Boolean);
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMSysKeyDown(var Message: TWMKeyDown); message WM_SYSKEYDOWN;
    function CheckHotKey(var Message: TWMKeyDown):Boolean;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure ValidateError; override;
    procedure ValidateOK; override;
    procedure SetRightAnchor(Value:Boolean);
    property  CurrentItem:Integer   read FCurrentItem;
    
  published                 
    property OnSetPrompt :TSetText read FSetPrompt  write FSetPrompt ;
    property OnSetHint   :TSetText read FSetHint    write FSetHint   ;
    property OnSetError  :TSetText read FSetError   write FSetError  ;
    property OnSetList   :TSetText read FSetList    write FSetList   ;
    property OnItemPicked:TSetPick read FItemPicked write FItemPicked;
    property OnSelectItem:TSetInt  read FSelectItem write FSelectItem;
    property OnSetMode   :TSetMode read FSetMode    write FSetMode   ;
    property OnDataChange:TSetData read FDataChange write FDataChange;
    property ErrorText   :String   read FErrorText  write FErrorText ;
    property FormModified:Boolean  read FFormModified write FFormModified;
    property OnExecute   :TNotifyExecute read FOnExecute    write FOnExecute   ;
    property RightAnchor :Boolean  read FRightAnchor write SetRightAnchor;
  end;           

function GetPackTextItem(Value:String;Index:Integer):String;

procedure Register;

implementation

{TIPControl}
procedure TIPControl.SetValidation(Value:String);
begin
   inherited SetValidation(Value);
   ShowHint:=True;
   Hint:=Value;
end;
procedure TIPControl.SetRightAnchor(Value:Boolean);
begin
   if FRightAnchor <> Value then
   begin
      FRightAnchor:=Value;
      ReCreateWnd;
   end;
end;
procedure TIPControl.CreateParams(var Params: TCreateParams);
begin
   inherited CreateParams(Params);
   InModal:=False;
   if not FRightAnchor then
      Params.Style:=Params.Style+ES_RIGHT;
end;      
function TIPControl.ZeroPad(Value,MaxVal:Integer;var Mask:String):String;
var
   S:String;
   I: Integer;
begin
  I:=10;          
  Mask:='9';
  while I < MaxVal do begin I:=I*10; Mask:=Mask+'9'; end;
  S:=IntToStr(I+Value);
  Result:=Copy(S,2,999);
end;
procedure TIPControl.UpdateEdit(FlagError:Boolean);
var
   SL:TPackStringList;
   S:String;
begin
   if csLoading in ComponentState then Exit;
   ReadOnly:=False;
   if (FCurrentItem < 0) then 
   begin
      FCurrentItem:=0;
   end
   else
   begin
      if FCurrentMode = ipmTrans then
      begin
         if (FCurrentItem > FList.Count) then FCurrentItem:=FList.Count;
      end
      else
      begin
         if (FCurrentItem >= FList.Count) then FCurrentItem:=FList.Count-1;
      end;
   end;
   case FCurrentMode of
      ipmPick,ipmList,ipmCols :
         begin
            if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
            Text:=ZeroPad(FCurrentItem+1,FList.Count+1,S);
            Validation:='Mask('+S+')';
         end;
      ipmTrans :
         begin
            Text:='';
            Validation:='';
            if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
            if FCurrentItem <> FList.Count then
            begin
               S:='Modify Transactions:';
               if Assigned(FSetPrompt) then FSetPrompt(S);
               S:='Move to the Desired Transaction and^Press [Enter] to Modify it, or [Delete] to remove it';
               if Assigned(FSetHint  ) then FSetHint (S);
            end
            else
            begin
               S:='Select a menu item:';
               if Assigned(FSetPrompt) then FSetPrompt(S);
               S:='Select a menu item by pressing the function key.^To modify a transaction press [Up] or [Down]';
               if Assigned(FSetHint  ) then FSetHint  (S);
            end;
         end;                  
      ipmAcct :
         begin
            Text:='';
            Validation:='';
            if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
         end;                  
      ipmForm :                  
         if DontUpdate then
         begin
            if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
         end
         else if (FCurrentItem < FList.Count) and (FCurrentItem >= 0) then
         begin
{$ifdef SAUDI}
            SetThreadLocale($00000401);
            LoadKeyboardLayout('00000401',KLF_ACTIVATE);
{$endif}
            SL:=TPackStringList.Create;
            SL.PackText:=FList[FCurrentItem];
            if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
{  From Component
   Enabled,Focused,'M',Name,Prompt,Data,Hint,ErrorText,Mask
   Enabled,Focused,'R',Name,Prompt,Data,Hint,ErrorText,From,To,Mask
   Enabled,Focused,'L',Name,Prompt,Data,Hint,ErrorText,Item1,Item2,...
   Enabled,Focused,'E',Name,Prompt,''  ,Hint,ErrorText,Line1,Line2,...
}
            if SL.Count > 4 then S:=SL[4]; 
            if Assigned(FSetPrompt) then FSetPrompt(S);
            if SL.Count > 5 then Text:=SL[5];
            if (SL.Count > 2) and (SL[2] = 'L') then
            begin
               ReadOnly:=True;
               Validation:='';
            end
            else if (SL.Count > 2) and (SL[2] = 'R') then
            begin
               if SL.Count > 10 then Validation:=SL[10];
            end
            else if (SL.Count > 2) and (SL[2] = 'E') then
            begin
               if SL.Count > 6 then Validation:=SL[6];
            end
            else if (SL.Count > 2) and (SL[2] = 'M') then
            begin
               try
                  if SL.Count > 8 then Validation:=SL[8];
{$ifdef SAUDI}
                  if Copy(EditMask,1,3) = '>LL' then
                  begin
                     if not SetThreadLocale($00000809) then
                        SetThreadLocale($00000409);
                     if LoadKeyboardLayout('00000809',KLF_ACTIVATE) = 0 then
                        LoadKeyboardLayout('00000409',KLF_ACTIVATE);
                     // undocumented WParam = 3-Set 5-Reset Lparam = LanguageID shl 16 | LanguageID
                     PostMessage(Self.Handle,WM_INPUTLANGCHANGEREQUEST,3,$08090809);
                  end;
{$endif}
               except
                  Validation:='';
               end;
            end;
            if SL.Count > 6  then
            begin
               S:=SL[6]; if Assigned(FSetHint  ) then FSetHint  (S);
            end;
            Hint:=S;
            if SL.Count > 7  then
               ErrorText:=SL[7];
            if not Ignore then if FlagError then ValidateError;
            SL.Free;
         end;
   end; 
   if (not DontUpdate) and Visible and Enabled then SelectAll;
end;
function TIPControl.FindEndOfList(List:String):Integer;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=List;
   Result:=SL.Count;
   SL.Free;
end;
procedure TIPControl.TxnLog(List,Prompt,Hint:String);
begin
   if FList <> nil then FList.Free;
   FList:=TPackStringList.Create;
   FList.PackText:=List;
   List:=FList.PackText;
   FCurrentItem:=FindEndOfList(List);
   if List <> '' then               
   begin
      FCurrentMode:=ipmTrans;
      if Assigned(FSetMode   ) then FSetMode   (FCurrentMode);
      if Assigned(FSetList   ) then FSetList   (List        );
      if Assigned(FSetPrompt ) then FSetPrompt (Prompt      );
      if Assigned(FSetHint   ) then FSetHint   (Hint        );
      Text:='';
      Validation:='';
      UpdateEdit(False);
   end;
end;
procedure TIPControl.AcctLog(List,Prompt,Hint:String);
begin
   Ignore:=True;  
   if FList <> nil then FList.Free;
   FList:=TPackStringList.Create;
   FList.PackText:=List;
   List:=FList.PackText;
   FCurrentItem:=0;
   if List <> '' then               
   begin
      FCurrentMode:=ipmAcct;
      if Assigned(FSetMode   ) then FSetMode   (FCurrentMode);
      if Assigned(FSetList   ) then FSetList   (List        );
      if Assigned(FSetPrompt ) then FSetPrompt (Prompt      );
      if Assigned(FSetHint   ) then FSetHint   (Hint        );
      Text:='';
      Validation:='';
      UpdateEdit(False);
   end;
end;
procedure TIPControl.PickFrom(List,Prompt,Hint:String);
begin
   if FList <> nil then FList.Free;
   FCurrentItem:=0;
   FList:=TPackStringList.Create;
   FList.PackText:=List;
   List:=FList.PackText;
   FCurrentMode:=ipmPick;
   if Assigned(FSetMode   ) then FSetMode   (FCurrentMode);
   if Assigned(FSetList   ) then FSetList   (List        );
   if Assigned(FSetPrompt ) then FSetPrompt (Prompt      );
   if Assigned(FSetHint   ) then FSetHint   (Hint        );
   UpdateEdit(False);
end;
procedure TIPControl.ShowForm(List:String;FlagError,NewForm:Boolean);
var
   I:Integer;
   S:String;
   P:String;
   H:String;
   FieldList:TPackStringList;
   CurrentItemWasOn:Integer;
begin
   if FList <> nil then FList.Free;
   FList:=TPackStringList.Create;
   FList.PackText:=List;
   if (FList.Count = 1) and (Length(FList[0]) >= 5) and (GetPackTextItem(FList[0],2) = 'L') then
   begin
      FCurrentMode:=ipmList;
      FList.PackText:=FList[0];
      if (Flist.Count > 4) then P:=FList[4];
      if (Flist.Count > 6) then H:=FList[6];
      if (Flist.Count > 7) then ErrorText:=FList[7];
      for I:=0 to 7 do FList.Delete(0);
      if FList.Count = 0 then  FList.Add('');
      if FList[0] = '*' then
      begin 
         FList.Delete(0);
         FCurrentMode:=ipmCols;
      end;
      S:=FList.PackText;   
      if Assigned(FSetMode  ) then FSetMode  (FCurrentMode);
      if Assigned(FSetList  ) then FSetList  (S);
      if Assigned(FSetPrompt) then FSetPrompt(P);
      if Assigned(FSetHint  ) then FSetHint  (H);
      if not Ignore then if FlagError then ValidateError;
      Exit;
   end;
   if (not NewForm) and (FCurrentItem < FList.Count) and (FCurrentItem >= 0) then
      CurrentItemWasOn:=FCurrentItem
   else
      CurrentItemWasOn:=0;
   FCurrentItem:=-1;
   for I:=0 to FList.Count-1 do // find focused control
   begin
   
      if (Length(FList[I]) > 2) and (GetPackTextItem(FList[I],1) = '1') then 
      begin
         FCurrentItem:=I;
         break;
      end;
   end;
   if (FCurrentItem = -1) and (not FlagError) then // no focus and no error
   begin
      FieldList:=TPackStringList.Create;
      for I:=0 to FList.Count-1 do
      begin
         FieldList.PackText:=FList[I];
         if (FieldList.Count > 5) and (Trim(FieldList[5]) = '') and (Trim(FieldList[0]) = '1') then // find blank enabled field
         begin
            FCurrentItem:=I;
            break;
         end;
      end;
      FieldList.Free;
   end;
   if (DontUpdate) then FCurrentItem:=CurrentItemWasOn;
   if (FCurrentItem = -1) then
   begin
      if FlagError then
      begin
         FCurrentItem:=CurrentItemWasOn+1;
         while (FCurrentItem < FList.Count-1) and (FList[FCurrentItem]<> '') and (GetPackTextItem(FList[FCurrentItem],0) = '0') do 
            Inc(FCurrentItem);
      end
      else
      begin
{$ifdef SAUDI}
         FCurrentItem:=CurrentItemWasOn;
{$else}
         if NewForm then 
            FCurrentItem:=CurrentItemWasOn
         else
            FCurrentItem:=CurrentItemWasOn+1;
{$endif}    
      end;
   end;  
   if FCurrentItem > FList.Count then FCurrentItem:=0;
   if FList.Count > 0 then
   begin
      while (FCurrentItem < FList.Count) and (FCurrentItem > 0) and (FList[FCurrentItem]<> '') and (GetPackTextItem(FList[FCurrentItem],0) = '0') do 
         Dec(FCurrentItem);
      while (FCurrentItem < FList.Count-1) and (FList[FCurrentItem]<> '') and (GetPackTextItem(FList[FCurrentItem],0) = '0')  do 
         Inc(FCurrentItem);
   end;
   if (FCurrentItem < FList.Count) and (FCurrentItem >= 0) and (FList[FCurrentItem]<> '') and (GetPackTextItem(FList[FCurrentItem],0) = '0') then
   begin
      // no enabled fields
      S:='Press F1 to Complete';
      if Assigned(FSetPrompt) then FSetPrompt(S);
      H:='Press F1 to Complete transaction^or select optional services';
      if Assigned(FSetHint  ) then FSetHint  (H);
   end;
   if (List <> '') then
   begin
      if FCurrentItem < 0 then 
         FCurrentItem:=0;
      FCurrentMode:=ipmForm;
      if Assigned(FSetMode) then FSetMode (FCurrentMode);
      if Assigned(FSetList) then FSetList (List        );
      UpdateEdit(FlagError);
   end;
end;
{
procedure TIPControl.ShowForm(List:String;FlagError,NewForm:Boolean);
var
   I:Integer;
   S:String;
   P:String;
   H:String;
   FieldList:TPackStringList;
   CurrentItemWasOn:Integer;
begin
//   if Copy(List,1,1) <> '"' then Exit;
   if FList <> nil then FList.Free;
   FList:=TPackStringList.Create;
   FList.PackText:=List;
   if (FList.Count = 1) and (Length(FList[0]) >= 5) and (GetPackTextItem(FList[0],2) = 'L') then
   begin
      FCurrentMode:=ipmList;
      FList.PackText:=FList[0];
      if (Flist.Count > 4) then P:=FList[4];
      if (Flist.Count > 6) then H:=FList[6];
      if (Flist.Count > 7) then ErrorText:=FList[7];
      for I:=0 to 7 do FList.Delete(0);
      if FList.Count = 0 then  FList.Add('');
      if FList[0] = '*' then
      begin 
         FList.Delete(0);
         FCurrentMode:=ipmCols;
      end;
      S:=FList.PackText;   
      if Assigned(FSetMode  ) then FSetMode  (FCurrentMode);
      if Assigned(FSetList  ) then FSetList  (S);
      if Assigned(FSetPrompt) then FSetPrompt(P);
      if Assigned(FSetHint  ) then FSetHint  (H);
      if not Ignore then if FlagError then ValidateError;
      Exit;
   end;
//   if (FCurrentItem >= FList.Count) or (FCurrentItem < 0) then 
   if (not NewForm) and (FCurrentItem < FList.Count) and (FCurrentItem >= 0) then
      CurrentItemWasOn:=FCurrentItem
   else
      CurrentItemWasOn:=0;
   FCurrentItem:=-1;
   for I:=0 to FList.Count-1 do // find focused control
   begin
   
      if (Length(FList[I]) > 2) and (GetPackTextItem(FList[I],1) = '1') then 
      begin
         FCurrentItem:=I;
         break;
      end;
   end;
   if (FCurrentItem = -1) and (not FlagError) then // no focus and no error
   begin
      FieldList:=TPackStringList.Create;
      for I:=0 to FList.Count-1 do
      begin
         FieldList.PackText:=FList[I];
         if (FieldList.Count > 5) and (Trim(FieldList[5]) = '') and (Trim(FieldList[0]) = '1') then // find blank enabled field
         begin
            FCurrentItem:=I;
            break;
         end;
      end;
      FieldList.Free;
   end;
   if (DontUpdate) then FCurrentItem:=CurrentItemWasOn;
   if (FCurrentItem = -1) then
   begin
      if FlagError then
      begin
         FCurrentItem:=CurrentItemWasOn+1;
         while (FCurrentItem < FList.Count-1) and (FList[FCurrentItem]<> '') and (GetPackTextItem(FList[FCurrentItem],0) = '0') do 
            Inc(FCurrentItem);
      end
      else
      begin
{$ifdef SAUDI
         FCurrentItem:=CurrentItemWasOn;
{$else
         if NewForm then 
            FCurrentItem:=CurrentItemWasOn
         else
            FCurrentItem:=CurrentItemWasOn+1;
{$endif
      end;
   end;  
   if FCurrentItem > FList.Count then FCurrentItem:=0;
   if FList.Count > 0 then
   begin
      while (FCurrentItem < FList.Count) and (FCurrentItem > 0) and (FList[FCurrentItem]<> '') and (GetPackTextItem(FList[FCurrentItem],0) = '0') do 
         Dec(FCurrentItem);
      while (FCurrentItem < FList.Count-1) and (FList[FCurrentItem]<> '') and (GetPackTextItem(FList[FCurrentItem],0) = '0')  do 
         Inc(FCurrentItem);
   end;
   if (FCurrentItem < FList.Count) and (FCurrentItem >= 0) and (FList[FCurrentItem]<> '') and (GetPackTextItem(FList[FCurrentItem],0) = '0') then
   begin
      // no enabled fields
      S:='Press F1 to Complete';
      if Assigned(FSetPrompt) then FSetPrompt(S);
      H:='Press F1 to Complete transaction^or select optional services';
      if Assigned(FSetHint  ) then FSetHint  (H);
   end;
   if (List <> '') then
   begin
      if FCurrentItem < 0 then 
         FCurrentItem:=0;
      FCurrentMode:=ipmForm;
      if Assigned(FSetMode) then FSetMode (FCurrentMode);
      if Assigned(FSetList) then FSetList (List        );
      UpdateEdit(FlagError);
   end;
end;
}
procedure TIPControl.MoveKey(CharCode:Integer);
var
   I:Integer;
   ActItem : integer ;
begin
   if CharCode = VK_PRIOR then begin for I:=0 to 9 do MoveKey(VK_UP  ); Exit; end;
   if CharCode = VK_NEXT  then begin for I:=0 to 9 do MoveKey(VK_DOWN); Exit; end;
   if FCurrentMode = ipmTrans then
   begin
      TransMoveKey(CharCode);
      Exit;
   end
   else if FCurrentMode = ipmAcct then
   begin
      AcctMoveKey(CharCode);
      Exit;
   end;
   if CharCode = VK_UP then
   begin
      if FCurrentItem <= 0 then FCurrentItem:=1;
      Dec(FCurrentItem);
   end
   else
   begin
      if FCurrentItem >= FList.Count then FCurrentItem:=FList.Count-2;
      Inc(FCurrentItem);
   end;
   if FCurrentMode = ipmForm then
   begin
      if CharCode = VK_UP then
      begin
         if (FCurrentItem >= 0) and (FCurrentItem < FList.Count) then
         begin
            ActItem := FCurrentItem ;
            while (FCurrentItem >= 0) and (GetPackTextItem(FList[FCurrentItem],0) = '0') do
               Dec(FCurrentItem);

            if FCurrentItem < 0 then
            begin
               FCurrentItem := ActItem ;
               while (FCurrentItem < FList.Count ) and (GetPackTextItem(FList[FCurrentItem],0) = '0') do
                  Inc(FCurrentItem);
            end ;

         end ;
      end
      else if CharCode = VK_DOWN then
      begin
         if (FCurrentItem >= 0) and (FCurrentItem < FList.Count) then
         begin
            ActItem := FCurrentItem ;
            while (FCurrentItem < FList.Count) and (GetPackTextItem(FList[FCurrentItem],0) = '0') do
               Inc(FCurrentItem);

            if FCurrentItem = FList.Count then
            begin
               FCurrentItem:= ActItem;
               while (FCurrentItem > 0 ) and (GetPackTextItem(FList[FCurrentItem],0) = '0') do
                  Dec(FCurrentItem);
            end ;

         end ;

      end;
   end;     
   UpdateEdit(False);
end;
procedure TIPControl.PickKey(CharCode:Integer);
var
   I:Integer;
   S:String;
begin
   case CharCode of
      VK_RETURN :    
         if (FCurrentItem >= 0) and (FCurrentItem < FList.Count) then
         begin
            S:=FList[FCurrentItem];
            if Assigned(FItemPicked) then FItemPicked(S,FCurrentItem);
         end;
      VK_UP,VK_DOWN,VK_PRIOR,VK_NEXT :    
         MoveKey(CharCode);
      else 
      begin
         if (CharCode >= 48) and (CharCode <= 57) and (FCurrentMode = ipmPick) then
         begin
            I:=StrToIntDef(Text,0);
            if (I > 0) and (I <> FCurrentItem+1) then
            begin
               FCurrentItem:=I-1;
               if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
            end
         end;
      end;
   end;
end;
procedure TIPControl.AcctMoveKey(CharCode:Integer);
begin
   if CharCode = VK_UP then
   begin
      if FCurrentItem = 0 then Exit;
      Dec(FCurrentItem);
   end
   else                     
   begin
      if FCurrentItem >= FList.Count-1 then Exit;
      Inc(FCurrentItem);
   end;    
   UpdateEdit(False);
end;
procedure TIPControl.TransMoveKey(CharCode:Integer);
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   if CharCode = VK_UP then
   begin
      if (FCurrentItem <= 0) and (FCurrentItem >= FList.Count) then
        FCurrentItem:=0;
        
      if FCurrentItem = 0 then Exit;
      repeat
        Dec(FCurrentItem);
        SL.PackText:=FList[FCurrentItem];
      until (FCurrentItem = 0) or (SL.Count < 1) or (SL[0] = '0');
   end
   else                     
   begin
      if FCurrentItem >= FList.Count then Exit;
      if FCurrentItem = FList.Count-1 then
      begin
         FCurrentItem:=FList.Count;
      end
      else
      begin
         repeat
           Inc(FCurrentItem);
           SL.PackText:=FList[FCurrentItem];
         until (FCurrentItem >= FList.Count-1) or (SL.Count < 1) or (SL[0] = '0');
         SL.PackText:=FList[FCurrentItem];
         if (SL.Count > 0) and (SL[0] <> '0') then
            FCurrentItem:=FList.Count;
      end;
   end;    
   UpdateEdit(False);
end;
procedure TIPControl.AcctKey(CharCode:Integer);
var
   S:String;
   SL:TPackStringList;
const
   AccountList:TPackStringList = nil;
begin
   case CharCode of
      VK_ESCAPE :    
         if FCurrentItem < FList.Count then
         begin
            if AccountList = nil then 
            begin
               S:='';
               FItemPicked(S,FCurrentItem);
               Ignore:=False;
               FCurrentMode:=ipmPick;
               if Assigned(FSetMode) then FSetMode (FCurrentMode);
               Exit;     
            end;
            if AccountList.Count < 1 then
            begin
               AccountList.Free;
               AccountList:=nil;
               Ignore:=False;
               S:='';
               FItemPicked(S,FCurrentItem);
               FCurrentMode:=ipmPick;
               if Assigned(FSetMode) then FSetMode (FCurrentMode);
               Exit;      
            end;
            S:=AccountList[AccountList.Count-1];
            AccountList.Delete(AccountList.Count-1);
            if AccountList.Count < 1 then
            begin
               AccountList.Free;
               AccountList:=nil;
            end;
            if Assigned(FItemPicked) then FItemPicked(S,FCurrentItem);
         end;
      VK_RETURN :    
         begin
            if AccountList = nil then AccountList:=TPackStringList.Create;
            if FCurrentItem < FList.Count then
            begin
               S:=FList[FCurrentItem];
               SL:=TPackStringList.Create;
               SL.PackText:=S;
               
               if SL.Count > 0 then S:=SL[0];
               if (SL.Count > 4) and (SL[4] = 'IsGroup') and (Assigned(FItemPicked)) then
               begin
                  AccountList.Add(SL[3]);
                  FItemPicked(S,FCurrentItem);
               end;
               SL.Free;
            end;
         end;
      VK_UP,VK_DOWN :    
         MoveKey(CharCode);
//         AcctMoveKey(CharCode);
   end;
end;
procedure TIPControl.TransKey(CharCode:Integer);
var
   S:String;
begin
   S:='';
   case CharCode of
      VK_DELETE :
         if FCurrentItem < FList.Count then
         begin
            S:='Delete';
            if Assigned(FItemPicked) then FItemPicked(S,FCurrentItem);
         end;
      VK_RETURN :    
         if FCurrentItem < FList.Count then
         begin
            if Assigned(FItemPicked) then FItemPicked(S,FCurrentItem);
         end;
      VK_UP,VK_DOWN :    
         MoveKey(CharCode);
//         TransMoveKey(CharCode);
   end;
end;
function TIPControl.SaveData:Boolean;
var
   SL:TPackStringList;
   S:String;
begin
   SL:=TPackStringList.Create;
   if FCurrentItem < 0 then FCurrentItem:=0;
   if FCurrentItem >= FList.Count then FCurrentItem:=FList.Count-1;
   SL.PackText:=FList[FCurrentItem];
   if SL.Count > 5 then SL[5]:=Text;
   FList[FCurrentItem]:=SL.PackText;
   SL.Free;
   S:=FList.PackText;
   if Assigned(FSetList) then FSetList(S);
   Result:=False;
   if Assigned(OnDataChange) then Result:=OnDataChange(S);
end;
procedure TIPControl.SwapTo;
var
   SL:TPackStringList;
   I:Integer;
   P,H,S:String;
begin
   InSwapTo:=True;
   if FCurrentItem < 0 then FCurrentItem:=0;
   if FCurrentItem >= FList.Count then FCurrentItem:=FList.Count-1;
   FLCurrentItem:=FCurrentItem;
   FLCurrentMode:=FCurrentMode;
   FLList:=FList;
   FList:=nil;
   FLItemPicked:=FItemPicked;
   SL:=TPackStringList.Create;
   SL.PackText:=FLList[FCurrentItem];
   if SL.Count > 4 then P:=SL[4];
   if SL.Count > 6 then H:=SL[6];
//   for I:=0 to 8 do SL.Delete(0);   // Check this code with Single Combo Forms
   if SL.Count > 8 then 
      for I:=0 to 7 do SL.Delete(0);   // Check this code with Single Combo Forms
   S:=SL.PackText;
   SL.Free;
   FItemPicked:=SwapFrom;
   PickFrom(S,P,H);
end;
procedure TIPControl.SwapFrom(var Value:String;Index:Integer);
var
   SL:TPackStringList;
   S:String;
begin
   FCurrentItem:=FLCurrentItem;
   FCurrentMode:=FLCurrentMode;
   FList.Free;
   FList       :=FLList      ;
   FItemPicked :=FLItemPicked;
   SL:=TPackStringList.Create;
   if FCurrentItem >= FList.Count then FCurrentItem:=FList.Count-1;
   if FCurrentItem < 0 then FCurrentItem:=0;
   if FList.Count > 0 then
   begin
      SL.PackText:=FList[FCurrentItem];
      if SL.Count > 5 then SL[5]:=Value;
      FList[FCurrentItem]:=SL.PackText;
      SL.Free;
      if FCurrentItem >= FList.Count-1 then FCurrentItem:=-1;
      Inc(FCurrentItem);
   end;
   FCurrentMode:=ipmForm;
   if Assigned(FSetMode) then FSetMode(FCurrentMode);
   S:=FList.PackText;
   if Assigned(FSetList) then FSetList(S);
   InSwapTo:=False;
   UpdateEdit(False);
   if FList.Count > 0 then
      Value:=FList[FCurrentItem];
   SaveData;
end;
function GetPackTextItem(Value:String;Index:Integer):String;
var
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.PackText:=Value;
   if (Index >= 0) and (SL.Count > Index) then
      Result:=SL[Index]
   else
      Result:='';
   SL.Free;
end;   
procedure TIPControl.FormKey(CharCode:Integer);
var
   MoveDown:Boolean;
begin
   Try
      if FList = nil then Exit;
      if FCurrentItem < 0 then FCurrentItem:=0;
      if FCurrentItem >= FList.Count then FCurrentItem:=FList.Count-1;
      case CharCode of
         VK_RETURN :    
         begin
           FFormModified:=True;
           if GetPackTextItem(FList[FCurrentItem],2) = 'L' then
            begin
               SwapTo;
            end
            else
            begin
               MoveDown:=False;
               SaveData;
               if MoveDown then
               begin
                  if FCurrentItem >= FList.Count-1 then FCurrentItem:=-1;
                  MoveKey(VK_DOWN);
               end;
            end;
         end;
         VK_UP,VK_DOWN,VK_PRIOR,VK_NEXT :    
         begin
            MoveKey(CharCode);
            if  (GetPackTextItem(FList[FCurrentItem],2) = 'L') 
            and (GetPackTextItem(FList[FCurrentItem],5) = '' ) then
               SwapTo;
         end;
//         else 
//         begin
//            inherited;
//         end;
      end;
   except
      //
   end;
end;
function TIPControl.CheckHotKey(var Message: TWMKeyDown):Boolean;
var
  ShiftState:Integer;
  ExecutableProgID:String;
begin
   Result:=False; 
   if (Message.KeyData > 1) then
   begin
      ShiftState:=0;
      if GetKeyState(VK_MENU)    < 0 then ShiftState:=ShiftState or 1;
      if GetKeyState(VK_CONTROL) < 0 then ShiftState:=ShiftState or 2;
      if GetKeyState(VK_SHIFT)   < 0 then ShiftState:=ShiftState or 4;
      if HotKeys = nil then HotKeys:=CreateHotKeys;
      if HotKeys = nil then Exit;
      ExecutableProgID:=HotKeys.ComponentToExecute(Message.KeyData,ShiftState);
      if ExecutableProgID <> '' then
      begin
         if ((not InModal) or (ModalExcept = ExecutableProgID)) and Assigned(FOnExecute) then 
            FOnExecute(ExecutableProgID);
         Result:=True;
      end;         
   end;
end;

procedure TIPControl.WMKeyDown(var Message: TWMKeyDown);
var
  CharCode:Integer;                    
begin
   if InModal then 
   begin
      if Message.CharCode in [VK_F1..VK_F24,VK_ESCAPE] then
         inherited;  
      Exit;
   end;
   if CheckHotKey(Message) then Exit;
   CharCode:=Message.CharCode;      
   
   case FCurrentMode of
      ipmList,ipmPick,ipmCols : 
         begin 
            inherited;  
            PickKey(CharCode); 
         end;
      ipmForm : 
         begin 
            inherited; 
            FormKey(CharCode); 
         end;
      ipmTrans : 
         begin 
            inherited; 
            TransKey(CharCode); 
         end;
      ipmAcct  : 
         begin 
            AcctKey(CharCode); 
         end;
   end;                      
end;
procedure TIPControl.ValidateOK;
var
   S:String;
begin
   inherited ValidateOK;
   S:=Hint;
   if Assigned(FSetHint) then FSetHint(S);
end;
procedure TIPControl.ValidateError;
begin
   if not Ignore then 
   begin
      inherited ValidateError;
      if Assigned(FSetError) then FSetError(FErrorText);
   end;
end;
procedure TIPControl.WMSysKeyDown(var Message: TWMKeyDown);
begin
   if CheckHotKey(Message) then Exit;
   inherited;
end;
procedure TIPControl.WMChar(var Message: TWMChar);
var
   I:Integer;
begin
   if InModal then 
      Exit;
   if (FCurrentMode = ipmTrans) or (FCurrentMode = ipmAcct) then Exit;
   inherited;          
   if (FCurrentMode = ipmPick) or (FCurrentMode = ipmList) or (FCurrentMode = ipmCols) then
   begin
      I:=StrToIntDef(Text,0);
      if I <> FCurrentItem+1 then
      begin
         FCurrentItem:=I-1;
         if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
      end;
   end;
end;
procedure Register;
begin
  RegisterComponents('CorvusVCL', [TIPControl]);
end;

end.

//p:\delphi3\Delphi 3\Lib;p:\delphi3\Delphi 3\Bin;p:\delphi3\Delphi 3\Imports;E:\corvus\source\base type library;E:\Corvus\Source\Support Components\Error Handler;E:\Corvus\Source\Support Components\DatabaseServer;E:\Corvus\Source\Packages;E:\corvus\source\component designer\product designer;E:\Corvus\Source\Base Components\Product;E:\corvus\source\component designer\Product Designer;E:\corvus\source\Utility Components\UserManager;E:\corvus\source\Utility Components\Diskette Management

