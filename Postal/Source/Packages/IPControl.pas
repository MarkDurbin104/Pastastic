unit IPControl;

interface

uses
  Math,
  Dialogs, RichEdit {EM_EXLINEFROMCHAR message id}, GPCSErrorLine,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, {Dialogs,}
  StdCtrls, Domain,GPCSBase_TLB,GPCSGUID,Printers,PackStrListU,StringUtil;

type
  TIPMode  = (ipmPick,ipmForm,ipmList,ipmCols,ipmTrans,ipmAcct,ipmHelp);
  TNotifyExecute = procedure (ProgID:String) of object;
  TSetText = procedure (var Value:String) of object;
  TSetData = function (var Value:String):Boolean of object;
  TSetPick = procedure (var Value:String;Index:Integer) of object;
  TSetInt  = procedure (var Value:Integer) of object;
  TSetMode = procedure (var Value:TIPMode) of object;
  TPopUp   = procedure (ShiftState:Integer) of object;
  TIPControl = class(TDomainEdit)
  private
     FPrevRightAnchor:Boolean;
     FPrevCharSet:integer;
     FPrevLanguageCode:String;
     FRightAnchor:Boolean;
     HotKeys:IHotKeys;
     FLCurrentItem:Integer;
     FLCurrentMode:TIPMode;
     FLList:TPackStringList;
     FLItemPicked:TSetPick;
     FCurrentItem:Integer;
     FList:TPackStringList;
     FSetPrompt:TSetText;
     FSetHint  :TSetText;
     FSetError :TSetText;
     FSetList  :TSetText;
     FOnExecute :TNotifyExecute;
     FOnPopUp   :TPopUp;
     FItemPicked:TSetPick;
     FSelectItem:TSetInt;
     FSetMode   :TSetMode;
     FDataChange:TSetData;
     FErrorText:String;
     FFormModified:Boolean;
  protected
     procedure CreateParams(var Params: TCreateParams); override;
     function FindEndOfList(List:String):Integer;
     function  ZeroPad(Value,MaxVal:Integer;var Mask:String):String;
     procedure UpdateEdit(FlagError:Boolean);
     procedure PickKey(CharCode:Integer);
     procedure FormKey(CharCode:Integer);
     procedure TransKey(CharCode:Integer);
     procedure AcctKey(CharCode:Integer);
     function SaveData:Boolean;
     procedure SwapTo(Search:String);
     procedure SwapFrom(var Value:String;Index:Integer);
  public
    InSwapTo:Boolean;
    InModal:Boolean;
    KeyBoardDisabled : boolean ;
    ModalExcept:String;
    DontUpdate:Boolean;
    FCurrentMode:TIPMode;
    Locale: string ;
    procedure GetLngValues;
    procedure SetLngValues(LanguageCode:String);
    procedure SetLngBack;
    procedure MoveKey(CharCode:Integer);
    procedure AcctMoveKey(CharCode:Integer);
    procedure TransMoveKey(CharCode:Integer);
    procedure PickFrom(List,Prompt,Hint,Search:String);
    procedure TxnLog(List,Prompt,Hint:String);
    procedure AcctLog(List,Prompt,Hint:String);
    procedure ShowInfo(List:String);
    procedure ShowForm(List:String;FlagError,NewForm:Boolean);
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMSysKeyDown(var Message: TWMKeyDown); message WM_SYSKEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyDown); message WM_KEYUP;
    procedure WMSysKeyUp(var Message: TWMKeyDown); message WM_SYSKEYUP;
    function CheckHotKey(var Message: TWMKeyDown):Boolean;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure ValidateError; override;
    procedure ValidateOK; override;
    procedure SetRightAnchor(Value:Boolean);
    property  CurrentItem:Integer   read FCurrentItem;
    procedure CheckGroupPopup(ShiftState:Integer);
    procedure SetLocale( DomainString : String );
  published
    property OnSetPrompt :TSetText read FSetPrompt  write FSetPrompt ;
    property OnSetHint   :TSetText read FSetHint    write FSetHint   ;
    property OnSetError  :TSetText read FSetError   write FSetError  ;
    property OnSetList   :TSetText read FSetList    write FSetList   ;
    property OnItemPicked:TSetPick read FItemPicked write FItemPicked;
    property OnSelectItem:TSetInt  read FSelectItem write FSelectItem;
    property OnSetMode   :TSetMode read FSetMode    write FSetMode   ;
    property OnDataChange:TSetData read FDataChange write FDataChange;
    property OnPopUp     :TPopUp   read FOnPopUp    write FOnPopUp   ;
    property ErrorText   :String   read FErrorText  write FErrorText ;
    property FormModified:Boolean  read FFormModified write FFormModified;
    property OnExecute   :TNotifyExecute read FOnExecute    write FOnExecute   ;
    property RightAnchor :Boolean  read FRightAnchor write SetRightAnchor;
  end;

function FindItem(FList:TPackStringList;Text:String):Integer;
function IsNumber(Text:String):Boolean;
function GetPackTextItem(Value:String;Index:Integer):String;
//procedure SetCompleteF1Text ;

procedure Register;

var
  InPreviewDialog:Boolean;

implementation
uses
  MainFU ;
{TIPControl}
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
   if (FCurrentMode <> ipmHelp) then
   begin
      InModal:=False;
      KeyBoardDisabled :=  false ;
   end;
//   Params.Style:=Params.Style {or ES_MULTILINE} or ES_PASSWORD ;
   if not FRightAnchor then
   begin
       Params.Style:=Params.Style or ES_RIGHT;
   end;
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
//   LocaleLangueCode :String;
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

   SL:=TPackStringList.Create;

   if FcurrentItem < FList.Count then
   begin
      SL.PackText:=FList[FCurrentItem];
   {
      LocaleLangueCode:='0';
      if (SL.Count >9) then
         if (SL[2] ='M') then
            LocaleLangueCode:=SL[10]
         else if (SL[2] ='L') then
            LocaleLangueCode:=SL[8];
   }
      SetLocale( FList[FcurrentItem]);
   end;


{   if (FCurrentMode <> ipmPick) then     // the picklist should have the same language
      SetLngValues(LocaleLangueCode) ; // than the Comboedit, so it doesn't change the settings
}

   case FCurrentMode of
      ipmPick,ipmList,ipmCols :
         begin
            if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
            Text:=ZeroPad(FCurrentItem+1,FList.Count+1,S);
//            Validation:='Mask('+S+')';
            Validation:='Mask(XXXXXXXXXXXXXXXXXXXX)';
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
      ipmAcct,ipmHelp :
         begin
            Text:='';
            Validation:='';
            if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
         end;
      ipmForm :
{         if DontUpdate then
         begin
            if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
         end
{         else} if (FCurrentItem < FList.Count) and (FCurrentItem >= 0) then
         begin

{$ifdef SAUDI}
            SetThreadLocale($00000401);
            LoadKeyboardLayout('00000401',KLF_ACTIVATE);
{$endif}

            if Assigned(FSelectItem) then FSelectItem(FCurrentItem);

{  From Component
   Enabled,Focused,'M',Name,Prompt,Data,Hint,ErrorText,Mask,Locale
   Enabled,Focused,'R',Name,Prompt,Data,Hint,ErrorText,From,To,Mask
   Enabled,Focused,'L',Name,Prompt,Data,Hint,ErrorText,Locale,Item1,Item2,...
   Enabled,Focused,'E',Name,Prompt,''  ,Hint,ErrorText,Line1,Line2,...
}
            if SL.Count > 4 then S:=SL[4];
            if Assigned(FSetPrompt) then FSetPrompt(S);
            if (SL.Count > 5) and (not DontUpdate) then Text:=SL[5];
            if (SL.Count > 2) and (SL[2] = 'L') then
            begin
//MJD               ReadOnly:=True;
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

         end;
   end;
   if (not DontUpdate) and Visible and Enabled then SelectAll;

   SL.Free;
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
procedure TIPControl.ShowInfo(List:String);
const
   PreList:String='';
   PreMode:TIPMode=ipmPick;
   PreIgnore:Boolean=False;
   PrePos:Integer=0;
begin
   if List <> '' then
   begin
      if FList <> nil then
         PreList:=FList.PackText;
      PreMode:=FCurrentMode;
      PreIgnore:=Ignore;
      PrePos:=FCurrentItem;
      Ignore:=True;
      if FList <> nil then FList.Free;
      FList:=TPackStringList.Create;
      FList.PackText:=List;
      List:=FList.PackText;
      FCurrentItem:=0;
      if List <> '' then               
      begin
         FCurrentMode:=ipmHelp;
         if Assigned(FSetMode   ) then FSetMode   (FCurrentMode);
         if Assigned(FSetList   ) then FSetList   (List        );
         Text:='';
         Validation:='';
         UpdateEdit(False);
      end;
   end
   else
   begin
      List:=PreList;
      FList.PackText:=PreList;
      FCurrentMode:=PreMode;
      Ignore:=PreIgnore;
      FCurrentItem:=PrePos;
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
procedure TIPControl.PickFrom(List,Prompt,Hint,Search:String);
var
   I:Integer;
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
   Text:=Search;
   if IsNumber(Text) and (StrToIntDef(Text,0) <= FList.Count) then
   begin
      I:=StrToIntDef(Text,0);
      if (I > 0) and (I <= FList.Count) then
      begin
         FCurrentItem:=I-1;
         Search:=FList[FCurrentItem];
         SwapFrom(Search,FCurrentItem);
         Exit;
      end;
   end
   else
   begin
      I:=FindItem(FList,Text);
      if (I > 0) and (I <= FList.Count) then
      begin
         FCurrentItem:=I-1;
         if not IsNumber(FList[FCurrentItem]) and (UpperCase(FList[FCurrentItem]) = UpperCase(Search)) then
         begin
            Search:=FList[FCurrentItem];
            SwapFrom(Search,FCurrentItem);
            Exit;
         end;
      end;
   end;
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
   I := 0 ;
   while i <= FList.Count-1 do
   begin
      if GetPackTextItem(FList[i],0)='2' then // It has to be remove from the list 'To be able to log Weight later on'
         FList.Delete(i)
      else
         Inc( i );
   end ;
   List:=FList.PackText;

   //always move to first item when new form
   If NewForm then
   begin
      Text:='';
      FCurrentItem := 0;
   end;
   if (FList.Count = 1) and (Length(FList[0]) >= 5) and (GetPackTextItem(FList[0],2) = 'L') then
   begin
      FCurrentItem:=0;
      FCurrentMode:=ipmList;
      FList.PackText:=FList[0];
      if (Flist.Count > 4) then P:=FList[4];
      if (Flist.Count > 6) then H:=FList[6];
      if (Flist.Count > 7) then ErrorText:=FList[7];
      //for I:=0 to 7 do FList.Delete(0);
      SetLocale( FList.PackText );
      for I:=0 to 8 do FList.Delete(0);
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
   if FCurrentItem > FList.Count-1 then FCurrentItem:=0;
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
      if FlagError then
      FlagError := ( GetPackTextItem(FList[FCurrentItem],5) <> '' ) ;
      UpdateEdit(FlagError);
   end;
end;
procedure TIPControl.MoveKey(CharCode:Integer);
var
  CurrentLineIndex : Integer; //selection line in ipcontrol
  LineCount : Integer;        //number of lines for wrapped text
   I:Integer;
   ActItem : integer ;
   UpdatePrompt : boolean ;
begin
   UpdatePrompt := TRUE ;
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

   //adjust up or down
   //check when in a domain memo
   If (FCurrentMode = ipmForm) and (GetPackTextItem(FList[FCurrentItem],2) = 'E') then
   begin
      //determine current line in memo
      LineCount         := SendMessage(self.handle, EM_GETLINECOUNT,   0, 0);
      CurrentLineIndex  := SendMessage(self.handle, EM_EXLINEFROMCHAR, 0, SelStart);

      //move to another control
      If (CurrentLineIndex = 0) and (CharCode = VK_UP)
      or (CurrentLineIndex = LineCount -1 ) and (CharCode = VK_DOWN) then
       FCurrentItem := FCurrentItem + CharCode - 39;  //up /down
   end
   else //standard mode
       FCurrentItem := FCurrentItem + CharCode - 39;  //up /down

   //ensure current item in range
   FCurrentItem := MaxIntValue([FCurrentItem,0]);
   FCurrentItem := MinIntValue([FCurrentItem, FList.Count-1]);

   //check for read-only controls in a form
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

               // it couldn't find the a valid place
               if FCurrentItem = FList.Count then
               begin
                  FCurrentItem := ActItem;
                  UpdatePrompt := FALSE ;
               end ;
            end ;
         end ;
      end
      else if CharCode = VK_DOWN then
      begin

         ActItem := FCurrentItem ;
         if (FCurrentItem >= 0) and (FCurrentItem < FList.Count) then
         begin

            while (FCurrentItem < FList.Count) and (GetPackTextItem(FList[FCurrentItem],0) = '0') do
               Inc(FCurrentItem);

         end ;

         if FCurrentItem = FList.Count then
         begin
            FCurrentItem:= MinIntValue([ActItem, FList.Count-1]);
            while (FCurrentItem > 0 ) and (GetPackTextItem(FList[FCurrentItem],0) = '0') do
               Dec(FCurrentItem);
         end ;

         // it couldn't find a valid place.
         if (( FCurrentItem = 0 ) and (GetPackTextItem(FList[0],0) = '0') ) then
         begin
            FCurrentItem := ActItem;
            UpdatePrompt := FALSE ;
         end ;

      end;
   end;


   if UpdatePrompt then
      UpdateEdit(False)

end;
function IsNumber(Text:String):Boolean;
var
  I:Integer;
begin
   Result:=False;
   if Text = '' then Exit;
   for I:=1 to Length(Text) do
      if not (Text[I] in ['0'..'9']) then
         Exit;
   Result:=True;
end;
function FindItem(FList:TPackStringList;Text:String):Integer;
begin
   Result:=FList.IndexOf(Text);
   if Result = -1 then
      FList.Find(Text,Result);
   Inc(Result);
   if Result < 1 then Result:=1;
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
        iF ((CharCode = VK_ESCAPE) and InSwapTo) then //in a product
        begin
          S := 'ESCAPE';
          if Assigned(FItemPicked) then FItemPicked(S,FCurrentItem);
        end
        else if (Char(CharCode) in ['0'..'9','A'..'Z']) and (FCurrentMode = ipmPick) then
        begin
          if IsNumber(Text) then
          begin
             I:=StrToIntDef(Text,0);
          end
          else
          begin
             I:=FindItem(FList,Text);
          end;
          if (I > 0) and (I <> FCurrentItem+1) and (I <= FList.Count) then
          begin
             FCurrentItem:=I-1;
             if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
          end;
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
procedure TIPControl.SwapTo(Search:String);
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
   If Sl.Count = 8 then
   begin
    SL.Add('');   //may be  a blank list eg, picklist not found
    SL.Add('');
    RaiseGUIDError('{9992B080-AC5E-4FBA-9F08-00C3CCF3CB96}', 'IPControl.SwapTo ' + SL.Packtext);
   end;
   if SL.Count > 8 then
      for I:=0 to 8 do SL.Delete(0);   // Check this code with Single Combo Forms
   S:=SL.PackText;
   SL.Free;
   FItemPicked:=SwapFrom;
   PickFrom(S,P,H,Search);
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
   //update domain combo text
   if (FList.Count > 0) and (Value <> 'ESCAPE') then
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
//   if Value <> 'ESCAPE' then
//   begin
     UpdateEdit(False);
     if FList.Count > 0 then
        Value:=FList[FCurrentItem];
     SaveData;
//  end;
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
  ControlType : String;
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
            ControlType := GetPackTextItem(FList[FCurrentItem],2);

            //check for force line breaks in
            if  (ControlType = 'E')
            and (GetKeyState(VK_SHIFT) <0) then
            begin
              //allow return to go into ip
              Text := Copy(Text,1,SelStart) + #13#10 + Copy(Text,SelStart+SelLength+1,9999);
            end
           else if (ControlType = 'L') then
           begin
              if Self.Modified or IsNumber(Text) then
                 SwapTo(Text)
              else
                 SwapTo(Copy(Text,1,Length(Text)-1));
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
               SwapTo('');
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
      if ShiftState > 0 then
         CheckGroupPopup(ShiftState);
      if HotKeys = nil then HotKeys:=CreateHotKeys;
      if HotKeys = nil then Exit;
      ExecutableProgID:=HotKeys.ComponentToExecute(Message.KeyData,ShiftState);
      if ExecutableProgID <> '' then
      begin
         if ((not InModal) or (ModalExcept = ExecutableProgID)) and Assigned(FOnExecute) then 
         begin
            if ShiftState > 0 then
               CheckGroupPopup(0);
            FOnExecute(ExecutableProgID);
         end;
         Result:=True;
      end;
   end;
end;
procedure TIPControl.CheckGroupPopup(ShiftState:Integer);
begin
   if Assigned(FOnPopUp) then
   begin
      FOnPopUp(ShiftState);
   end;
end;
procedure TIPControl.WMKeyUp(var Message: TWMKeyDown);
begin
   CheckGroupPopup(0);
end;
procedure TIPControl.WMSysKeyUp(var Message: TWMKeyDown);
begin
   CheckGroupPopup(0);
end;
procedure TIPControl.WMSysKeyDown(var Message: TWMKeyDown);
begin
   if (not InModal) and CheckHotKey(Message) then Exit;
   inherited;
end;
procedure TIPControl.WMKeyDown(var Message: TWMKeyDown);
var
  CharCode:Integer;
begin

  if ((DateTimeToTimeStamp(Now).Time-
     TMainForm(Owner).TriggerStartTime.Time) > TMainForm(Owner).TriggerTimeOut) then
     TDomainEdit(Owner).StateTrigger:= noTriggerCode;

   if InModal then
   begin
      if ( not KeyBoardDisabled ) and ( Message.CharCode in [VK_F1..VK_F24,VK_ESCAPE,VK_HOME,VK_UP,VK_DOWN] ) then
         inherited ;
      Exit;
   end;

   if InPreviewDialog then
   begin
      if ( not KeyBoardDisabled ) and
         ( Message.CharCode in [VK_F1..VK_F8,VK_ESCAPE,VK_PRIOR,VK_NEXT,VK_DOWN,VK_UP,VK_HOME,VK_END]) then
         inherited ;
      Exit;
   end ;

   if CheckHotKey(Message) then Exit;
   CharCode:=Message.CharCode;
   case FCurrentMode of
      ipmList,ipmPick,ipmCols :
         begin
            inherited;
//            if Message.Result = 1 then
              if (Message.KeyData and $200000) = 0 then
                PickKey(CharCode);
         end;
      ipmForm :
         begin
            inherited;
            if StateTrigger = CancelTriggerCode then
            begin
               StateTrigger:= ReadyToStart;
            end ;
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
procedure TIPControl.WMChar(var Message: TWMChar);
var
   I:Integer;
begin

   if (StateTrigger=ReadyToStart) then
   begin
      StateTrigger:= noTriggerCode;
      exit;
   end;

   if (StateTrigger <> noTriggerCode) then
      exit ;

   if InModal or InPreviewDialog then
      Exit;
   if (FCurrentMode = ipmTrans) or (FCurrentMode = ipmAcct) then Exit;
   inherited;
   if (FCurrentMode = ipmPick) or (FCurrentMode = ipmList) or (FCurrentMode = ipmCols) then
   begin
      if IsNumber(Text) then
         I:=StrToIntDef(Text,0)
      else
         I:=FindItem(FList,Text);
      if (I > 0) and (I <> FCurrentItem+1) and (I <= FList.Count) then
      begin
         FCurrentItem:=I-1;
         if Assigned(FSelectItem) then FSelectItem(FCurrentItem);
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
procedure TIPControl.GetLngValues;
begin
   FPrevRightAnchor:=RightAnchor;
   FPrevCharSet    :=Font.Charset;
   FPrevLanguageCode:=IntToHex(GetThreadLocale,8);
end;
procedure TIPControl.SetLngValues(LanguageCode:String);

begin

   if FPrevLanguageCode <> '' then
   begin
      LanguageCode:=LeftPad( LanguageCode,8,'0');
      if (LanguageCode ='00000000') then
         LanguageCode := FPrevLanguageCode;

      if IntToHex(GetThreadLocale,8)<>LanguageCode  then
      begin
         if not SetThreadLocale(StrToInt('$'+LanguageCode)) then
            SetThreadLocale($00000409);

         if LoadKeyboardLayout(PChar(LanguageCode),KLF_ACTIVATE) = 0 then
            LoadKeyboardLayout('00000409',KLF_ACTIVATE);

         if LanguageCode = '00000401' then
         begin
            Font.Charset:=ARABIC_CHARSET;
            RightAnchor := True;
         end
         else
         begin
            Font.Charset:=FPrevCharSet;
            RightAnchor :=False;
         end;
      end;
   end;


end ;
procedure TIPControl.SetLocale( DomainString : String );
var
   LocaleLangueCode : String ;
   SL:TPackStringList;
begin
   LocaleLangueCode:='';
   SL:=TPackStringList.Create;
   SL.PackText := DomainString ;
   if (SL.Count >9) then
   begin
      if (SL[2] ='M') then
         LocaleLangueCode:=SL[10]
      else if (SL[2] ='L') then
         LocaleLangueCode:=SL[8];
   end ;
   if (FCurrentMode <> ipmPick) then     // the picklist should have the same language
   begin
      if ((FCurrentMode = ipmList) and (LocaleLangueCode <> '')) or (FCurrentMode <> ipmList) then
         SetLngValues(LocaleLangueCode) ; // than the Comboedit, so it doesn't change the settings
   end;
   SL.Free;

end ;
procedure TIPControl.SetLngBack;
begin
   SetLngValues(FPrevLanguageCode);
end ;

procedure Register;
begin
  RegisterComponents('CorvusVCL', [TIPControl]);
end;

end.

//p:\delphi3\Delphi 3\Lib;p:\delphi3\Delphi 3\Bin;p:\delphi3\Delphi 3\Imports;E:\corvus\source\base type library;E:\Corvus\Source\Support Components\Error Handler;E:\Corvus\Source\Support Components\DatabaseServer;E:\Corvus\Source\Packages;E:\corvus\source\component designer\product designer;E:\Corvus\Source\Base Components\Product;E:\corvus\source\component designer\Product Designer;E:\corvus\source\Utility Components\UserManager;E:\corvus\source\Utility Components\Diskette Management

