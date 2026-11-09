unit UIStatesU;

interface
uses
   Forms,Windows,Graphics,Classes,SysUtils,ListBaseU,
   Controls,Dialogs,Buttons,GPCSBase_TLB,PackStrListU;
   
type            
  TSetButtonState = procedure(Index:Integer;State:ButtonState)  of object;
  TSetStringValue = procedure(Value:String)                     of object;
  TSetFormState   = procedure(Value:FormState)                  of object;
  TClearUI        = procedure                                   of object;
  TSetButtonInfo  = procedure(Index:Integer;Caption:String;Picture:TBitMap;Price:Currency;Enabled,Selected:Boolean) of object;
  TSetLineInfo    = procedure(Index:Integer;Caption:String)     of object;
  TSetCurrentLine = procedure (Value:Integer)                   of object;
  TGetCurrentLine = function  :Integer                          of object;
  TSetPicture     = procedure(Picture:TBitMap)                  of object;
  
  TUIInterface = class;
  TPickItem = class(TListItem)
  private
     FCaption :String;     
     FPicture :TBitMap;
     FSelected:Boolean;
     FEnabled :Boolean;
     FPrice   :Currency;
  public
     constructor Create(Caption:String;Picture:TBitMap;Selected,Enabled:Boolean;Price:Currency);
     property Caption :String   read FCaption  write FCaption ;
     property Picture :TBitMap  read FPicture  write FPicture ;
     property Selected:Boolean  read FSelected write FSelected;
     property Enabled :Boolean  read FEnabled  write FEnabled ;
     property Price   :Currency read FPrice    write FPrice   ;
  end;
  TPickList = class(TItemList)
  private
     FTitle :String;
     FPrompt:String;
     FHint  :String;
     FPicture :TBitMap;
     function GetItem(Index:Integer):TPickItem;
  public
     constructor Create(Title,Prompt,Hint:String;Picture:TBitMap);
     function Add(Item:TPickItem):Integer;
     property Items[Index:Integer]:TPickItem read GetItem; default;
     property Picture :TBitMap  read FPicture  write FPicture ;
     property Title :String read FTitle  write FTitle ;
     property Prompt:String read FPrompt write FPrompt;
     property Hint  :String read FHint   write FHint  ;
  end;            
  TDomainItem = class(TListItem)
  private
     FPrompt     :String;     
     FHint       :String;     
     FError      :String;     
     FValidation :String;     
     FText       :String;     
  public
     constructor Create(Prompt,Hint,Error,Validation,Text:String);
     property Prompt     :String read FPrompt     write FPrompt    ;
     property Hint       :String read FHint       write FHint      ;
     property Error      :String read FError      write FError     ;
     property Validation :String read FValidation write FValidation;
     property Text       :String read FText       write FText      ;
  end;
  TDomainList = class(TItemList)
  private
     function GetItem(Index:Integer):TDomainItem;
  public
     function Add(Item:TDomainItem):Integer;
     property Items[Index:Integer]:TDomainItem read GetItem; default;
  end;
  TTxnItem = class(TListItem)
  private
     FDescription:String  ;     
     FAdditional :String  ;     
     FPrice      :Currency;     
  public
     constructor Create(Description,Additional:String;Price:Currency);
     property Description:String   read FDescription write FDescription;
     property Additional :String   read FAdditional  write FAdditional ;
     property Price      :Currency read FPrice       write FPrice      ;
  end;
  TTxnList = class(TItemList)
  private
     function GetItem(Index:Integer):TTxnItem;
  public
     function Add(Item:TTxnItem):Integer;
     property Items[Index:Integer]:TTxnItem read GetItem; default;
  end;
  TUIState = class(TObject)
  private
     FTopOfs:Integer;
     FShowNumbers:Boolean;
     FDefaultIndex:Integer;
  protected
     FItems:TPickList;
     FUIInterface:TUIInterface;
     procedure SetFormLines(List:TStrings); virtual;
  public                    
     procedure SetFormData;
     procedure Refresh;
     procedure KeyPress(KeyCode:Integer;System:Boolean); virtual; abstract;
     constructor Create(UIInterface:TUIInterface);
     property UIInterface:TUIInterface read FUIInterface write FUIInterface;
  end;      
  TPickState = class(TUIState)
  private
     FIsSorted:Boolean;
     FCurrentText:String;
     FItemClicked:Integer;
     procedure SetFormLines(List:TStrings); override;
     procedure SetCurrentText(Value:String);
     function WaitForPick:Integer;
  public                    
     procedure KeyPress(KeyCode:Integer;System:Boolean); override;
     function PickItem(Items:TPickList;ShowNumbers,Sorted:Boolean;DefaultIndex:Integer):Integer;
     property ItemClicked:Integer read FItemClicked write FItemClicked;
     property CurrentText:String read FCurrentText write SetCurrentText;
  end;      
  TMenuState = class(TPickState)
  private
     FTransactions:TTxnList;
     procedure SetFormLines(List:TStrings); override;
  public                    
     procedure KeyPress(KeyCode:Integer;System:Boolean); override;
     function PickItem(Items:TPickList;Transactions:TTxnList;ShowNumbers,Sorted:Boolean;DefaultIndex:Integer):Integer;
  end;
  THelpState = class(TPickState)
  private
     FHelpText:String;
     procedure SetFormLines(List:TStrings); override;
  public                    
     procedure KeyPress(KeyCode:Integer;System:Boolean); override;
     function Show(Items:TPickList;HelpText:String):Integer;
  end;
  TFormState = class(TUIState)
  private
     FModified:Boolean;
     FFirstKeyInEdit:Boolean;
     FPreEditCurrentText:String;
     FDomains:TDomainList;
     FHItems:TPickList;
     FHText:String;
     FCurrentText:String;
     FCurrentDomain:TDomainItem;
     FFinishedProcessing:Boolean;
     procedure SetCurrentText(Value:String);
     procedure SetFormLines(List:TStrings); override;
     procedure SetCurrentLine(Value:Integer);
     function GetCurrentLine:Integer;
  public                   
     procedure KeyPress(KeyCode:Integer;System:Boolean); override;
     constructor Create(UIInterface:TUIInterface;Items:TPickList;Domains:TDomainList;HItems:TPickList;HText:String);
     procedure ProcessForm;
     property CurrentText:String read FCurrentText write SetCurrentText;
     property CurrentDomain:TDomainItem read FCurrentDomain;
     property CurrentLine:Integer read GetCurrentLine write SetCurrentLine;
     
  end;
  TUIStateEngine = class(TObject)
  private
     FUIInterface:TUIInterface;
     FCurrentState:TUIState;
  public                    
     constructor Create(UIInterface:TUIInterface);
     procedure ShowForm(Items:TPickList;Domains:TDomainList;HItems:TPickList;HText:String);
     function ShowWarning(WButtons:TPickList;Warning:String):Integer;
     procedure ShowHelp(HelpText:String);
     procedure ShowInfo(HelpText:String);
     function PickItem(Items:TPickList;ShowNumbers,Sorted:Boolean;Default:Integer):Integer;
     function PickMenuItem(Items:TPickList;Transactions:TTxnList;Default:Integer):Integer;
     procedure KeyPress(KeyCode:Integer;System:Boolean);
     property CurrentState:TUIState read FCurrentState write FCurrentState;
  end;
  TUIInterface = class(TComponent)
  private
     FState:FormState;
     FUIStateEngine:TUIStateEngine;
     FOnSetButtonState:TSetButtonState;
     FOnSetTitle :TSetStringValue;
     FOnSetPicture :TSetPicture;
     FOnSetPrompt:TSetStringValue;
     FOnSetHint1 :TSetStringValue;
     FOnSetHint2 :TSetStringValue;
     FOnSetFormState:TSetFormState;
     FOnSetText:TSetStringValue;
     FOnClearUI:TClearUI;
     FOnSetButtonInfo:TSetButtonInfo;
     FOnSetLineInfo:TSetLineInfo;
     FOnSetCurrentLine:TSetCurrentLine;
     FOnGetCurrentLine:TGetCurrentLine;
     FOnGetCurrentMaxLine:TGetCurrentLine;
     FOnSetMaxItem:TSetCurrentLine;
     FOnGetMaxItem:TGetCurrentLine;
     procedure SetState(Value:FormState);
     function GetCurrentLine:Integer;
     procedure SetCurrentLine(Value:Integer);
     function GetCurrentMaxLine:Integer;
  public
     constructor Create(AOwner:TComponent); override;
     destructor Destroy; override;
     procedure Clear;
     function GetMaxItem:Integer;
     procedure SetMaxItem(Value:Integer);
     procedure SetTitle (Value:String);
     procedure SetPicture(Value:TBitmap);
     procedure SetPrompt(Value:String);
     procedure SetHint  (Value:String);
     procedure SetButtonState(Index:Integer;State:ButtonState);
     procedure SetButtonInfo(Index:Integer;Caption:String;Picture:TBitMap;Price:Currency;Enabled,Selected:Boolean);
     procedure SetLineInfo(Index:Integer;Caption:String);
     procedure SetText(Value:String);
     property State:FormState read FState write SetState;
     property CurrentLine:Integer read GetCurrentLine write SetCurrentLine;
     property CurrentMaxLine:Integer read GetCurrentMaxLine;
     property UIStateEngine:TUIStateEngine read FUIStateEngine;
  published
     property MaxItem:Integer read GetMaxItem write SetMaxItem;
     property OnSetButtonState:TSetButtonState read FOnSetButtonState write FOnSetButtonState;
     property OnSetTitle :TSetStringValue read FOnSetTitle  write FOnSetTitle ;
     property OnSetPicture:TSetPicture read FOnSetPicture write FOnSetPicture;
     property OnSetPrompt:TSetStringValue read FOnSetPrompt write FOnSetPrompt;
     property OnSetHint1 :TSetStringValue read FOnSetHint1  write FOnSetHint1 ;
     property OnSetHint2 :TSetStringValue read FOnSetHint2  write FOnSetHint2 ;
     property OnSetFormState:TSetFormState read FOnSetFormState  write FOnSetFormState;
     property OnSetText:TSetStringValue read FOnSetText  write FOnSetText;
     property OnClearUI:TClearUI read FOnClearUI write FOnClearUI;
     property OnSetButtonInfo:TSetButtonInfo read FOnSetButtonInfo write FOnSetButtonInfo;
     property OnSetLineInfo:TSetLineInfo read FOnSetLineInfo write FOnSetLineInfo;
     property OnSetCurrentLine:TSetCurrentLine read FOnSetCurrentLine write FOnSetCurrentLine;
     property OnGetCurrentLine:TGetCurrentLine read FOnGetCurrentLine write FOnGetCurrentLine;
     property OnGetCurrentMaxLine:TGetCurrentLine read FOnGetCurrentMaxLine write FOnGetCurrentMaxLine;
     property OnSetMaxItem:TSetCurrentLine read FOnSetMaxItem write FOnSetMaxItem;
     property OnGetMaxItem:TGetCurrentLine read FOnGetMaxItem write FOnGetMaxItem;
     
  end;           

implementation
uses
  UIInterfaceU;
  
{TPickItem}
constructor TPickItem.Create(Caption:String;Picture:TBitMap;Selected,Enabled:Boolean;Price:Currency);
begin
   inherited Create;
   FCaption :=Caption ;
   FPicture :=Picture ;
   FSelected:=Selected;
   FEnabled :=Enabled ;
   FPrice   :=Price   ;
end;
{TPickList}
constructor TPickList.Create(Title,Prompt,Hint:String;Picture:TBitMap);
begin
   inherited Create;
   FTitle  :=Title ;
   FPrompt :=Prompt;
   FHint   :=Hint  ;
   FPicture:=Picture;
end;
function TPickList.GetItem(Index:Integer):TPickItem;
begin
   Result:=TPickItem(inherited Items[Index]);
end;
function TPickList.Add(Item:TPickItem):Integer;
begin
   Result:=inherited Add(Item.Caption,Item);
end;
{TFieldItem}
constructor TDomainItem.Create(Prompt,Hint,Error,Validation,Text:String);
begin
   inherited Create;
   FPrompt     :=Prompt    ;
   FHint       :=Hint      ;
   FError      :=Error     ;
   FValidation :=Validation;
   FText       :=Text      ;
end;
{TFieldList}
function TDomainList.GetItem(Index:Integer):TDomainItem;
begin
   Result:=TDomainItem(inherited Items[Index]);
end;
function TDomainList.Add(Item:TDomainItem):Integer;
begin
   Result:=inherited Add(Item.Prompt,Item);
end;
{TTxnItem}
constructor TTxnItem.Create(Description,Additional:String;Price:Currency);
begin
   inherited Create;
   FDescription:=Description;
   FAdditional :=Additional ;
   FPrice      :=Price      ;
end;
{TTxnList}
function TTxnList.GetItem(Index:Integer):TTxnItem;
begin
   Result:=TTxnItem(inherited Items[Index]);
end;
function TTxnList.Add(Item:TTxnItem):Integer;
begin
   Result:=inherited Add(Item.Description,Item);
end;
{TUIState}
constructor TUIState.Create(UIInterface:TUIInterface);
begin
   inherited Create;
   FUIInterface:=UIInterface;
end;
procedure TUIState.SetFormLines(List:TStrings);
begin
   ;
end;
procedure TUIState.SetFormData;
var
   I:Integer;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   with FUIInterface do
   begin
      I:=0;
      while (I < FUIInterface.MaxItem) and ((FTopOfs+I) < FItems.Count) do
      begin
         with FItems[FTopOfs+I] do
         begin
            SetButtonInfo(I,Caption,Picture,Price,Enabled,Selected);
            if (FShowNumbers) and (Caption <> '') then 
               SL.Add(IntToStr(FTopOfs+I+1)+' '+Caption)
            else
               SL.Add(Caption);
         end;   
         Inc(I);
      end;
   end;
   SetFormLines(SL);
   if FDefaultIndex >= 0 then
   begin
      FUIInterface.SetCurrentLine(FDefaultIndex-FTopOfs);
      FDefaultIndex:=-1;
   end;
   SL.Free;
end;
procedure TUIState.Refresh;
begin
   SetFormData;
   FUIInterface.SetCurrentLine(FUIInterface.GetCurrentLine);
end;

{TPickState}
procedure TPickState.SetFormLines(List:TStrings);
var
   I:Integer;
begin
   with FUIInterface do
   begin
      State:=uisPick;
      for I:=0 to List.Count-1 do
         SetLineInfo(I,List[I]);
   end;
end;
function TPickState.PickItem(Items:TPickList;ShowNumbers,Sorted:Boolean;DefaultIndex:Integer):Integer;
var
   Index:Integer;
begin
   FIsSorted:=Sorted;
   FItems:=Items;
   FShowNumbers:=ShowNumbers;
   FDefaultIndex:=DefaultIndex;
   if FDefaultIndex >= FItems.Count then FDefaultIndex:=0;
   Result:=PickContinue;
   with FUIInterface do
   begin
      Clear;
      SetTitle  (Items.Title );
      SetPrompt (Items.Prompt);
      SetHint   (Items.Hint  );
      SetPicture(Items.Picture);
      ItemClicked:=PickError;
      CurrentText:='';
      FTopOfs:=0;
      
      if FDefaultIndex > FUIInterface.MaxItem then
         FTopOfs:=FDefaultIndex;
            
      while Result = PickContinue do
      begin
         SetFormData;
         Result:=WaitForPick;
         case Result of
            PickError    : Exit;
            PickCancel   : Exit;
            PickUpLine   : begin
                              if FTopOfs > 0 then Dec(FTopOfs);
                              Result:=PickContinue;
                           end;            
            PickDownLine : begin
                              if FTopOfs+FUIInterface.MaxItem < Items.Count then Inc(FTopOfs);
                              Result:=PickContinue;
                           end;
            PickUpPage   : begin
                              if FTopOfs > FUIInterface.MaxItem-1 then
                              begin
                                 Dec(FTopOfs,FUIInterface.MaxItem-1);
                              end
                              else
                              begin
                                 if FTopOfs = 0 then
                                    FDefaultIndex:=0;
                                 FTopOfs:=0;
                              end;
                              Result:=PickContinue;
                           end;
            PickDownPage : begin
                              if ((FTopOfs+FUIInterface.MaxItem) <= (Items.Count-FUIInterface.MaxItem)) then
                              begin
                                 Inc(FTopOfs,FUIInterface.MaxItem-1);
                              end
                              else
                              begin
                                 if (FTopOfs = (Items.Count-FUIInterface.MaxItem)) then
                                    FDefaultIndex:=Items.Count-1;
                                 FTopOfs:=Items.Count-FUIInterface.MaxItem;
                              end;
                              Result:=PickContinue;
                           end;
            PickContinue : ; // Shouldn't be possible;
            else if Result <= PickMoveTo then
            begin
               Index:=0-(Result-PickMoveTo);
               if (Index < FTopOfs) then
                  FTopOfs:=Index
               else if (Index >= FTopOfs+FUIInterface.MaxItem) then
                  FTopOfs:=Index-(FUIInterface.MaxItem-1);
               if Index <> (FTopOfs+FUIInterface.CurrentLine) then
                  FDefaultIndex:=Index;
               Result:=PickContinue;
            end
            else
            begin
               if Result+FTopOfs >= Items.Count then
                  Result:=PickContinue;
            end;         
         end;
      end;
      if Result >= 0 then
         SetButtonState(Result,bsDown);
      Inc(Result,FTopOfs);
   end;
end;
function TPickState.WaitForPick:Integer;
begin
   Result:=PickError;
   while ItemClicked = PickError do
   begin
      Application.ProcessMessages;
      if Application.Terminated then Exit;
   end;
   Result:=ItemClicked;
   ItemClicked:=PickError;
end;
function IsNumeric(Value:String):Boolean;
begin
   Result:=StrToIntDef(Value,-1) > 0;
end;
procedure TPickState.KeyPress(KeyCode:Integer;System:Boolean);
begin
   if System then
   begin
      case KeyCode of
         Key_FuncMin..Key_FuncMax : ItemClicked:=KeyCode-Key_FuncMin;
         Key_Up       : if FUIInterface.CurrentLine > 0 then FUIInterface.CurrentLine:=FUIInterface.CurrentLine-1 else ItemClicked:=PickUpLine;
         Key_Down     : if FUIInterface.CurrentLine < (FItems.Count-FTopOfs)-1 then FUIInterface.CurrentLine:=FUIInterface.CurrentLine+1 else ItemClicked:=PickDownLine;
         Key_Select   : if FUIInterface.CurrentLine >= 0 then ItemClicked:=FUIInterface.CurrentLine;
         Key_Cancel   : ItemClicked:=PickCancel;
         Key_PageUp   : ItemClicked:=PickUpPage;
         Key_PageDown : ItemClicked:=PickDownPage;
      end;
   end
   else
   begin
      if KeyCode = Key_BackSpace then
      begin
         CurrentText:=Copy(FCurrentText,1,Length(FCurrentText)-1);
      end
      else              
      begin
         if ((FIsSorted) or (Char(KeyCode) in ['0'..'9'])) and (KeyCode > Key_ControlMax) then
            CurrentText:=FCurrentText+Char(KeyCode);
      end;
      if IsNumeric(CurrentText) and (StrToInt(CurrentText) < FItems.Count) then
         ItemClicked:=PickMoveTo-(StrToInt(CurrentText)-1)
      else if FIsSorted then
         ItemClicked:=PickMoveTo-FItems.Find(CurrentText);
   end;
end;    
procedure TPickState.SetCurrentText(Value:String);
begin
   if FCurrentText <> Value then
   begin
      FCurrentText:=Value;
      FUIInterface.SetText(Value);
   end;
end;
{TMenuState}
procedure TMenuState.KeyPress(KeyCode:Integer;System:Boolean);
begin
   if (FTransactions = nil) or (FTransactions.Count = 0) or (not System) then
   begin
      inherited KeyPress(KeyCode,System);
   end
   else
   begin
      case KeyCode of
         Key_FuncMin..Key_FuncMax,Key_Cancel : inherited KeyPress(KeyCode,System);
         Key_Select     : ; // Re-Edit Transaction   
         Key_Delete     : ; // Delete Transaction    
         Key_Up         : ; // Up TxnLog             
         Key_Down       : ; // Down TxnLog           
         Key_PageUp     : ; // Page Up TxnLog          
         Key_PageDown   : ; // Page Down TxnLog      
      end;
   end;
end;    
function TMenuState.PickItem(Items:TPickList;Transactions:TTxnList;ShowNumbers,Sorted:Boolean;DefaultIndex:Integer):Integer;
begin
   FTransactions:=Transactions;
   Result:=inherited PickItem(Items,ShowNumbers,Sorted,DefaultIndex);
end;
procedure TMenuState.SetFormLines(List:TStrings);
var
   I:Integer;
begin
   if (FTransactions = nil) or (FTransactions.Count = 0) then
   begin
      inherited SetFormLines(List);
      FUIInterface.State:=uisMenu;
   end
   else
   begin
      with FUIInterface do
      begin
         State:=uisTrans;
         for I:=0 to FTransactions.Count-1 do
            SetLineInfo(I,FTransactions.Items[I].Description);
      end;
   end;
end;  
{TFormState}
constructor TFormState.Create(UIInterface:TUIInterface;Items:TPickList;Domains:TDomainList;HItems:TPickList;HText:String);
begin
   inherited Create(UIInterface);
   FHItems:=HItems;
   FHText :=HText ;
   FItems  :=Items;
   FDomains:=Domains;
   if (FDomains <> nil) and (FDomains.Count > 0) then
   begin
      FCurrentDomain:=FDomains[0];
      FFinishedProcessing:=False;
   end
   else 
   begin
      FFinishedProcessing:=True;
   end;
end;  
procedure TFormState.SetFormLines(List:TStrings);
var
   I:Integer;
begin
   with FUIInterface do
   begin
      for I:=0 to FDomains.Count-1 do
         SetLineInfo(I,FDomains[I].Prompt+': '+FDomains[I].Text);
   end;
end;  
procedure TFormState.SetCurrentText(Value:String);
begin
   FCurrentText:=Value;
   FUIInterface.SetText(Value);
   FDomains[CurrentLine].Text:=Value;
   FUIInterface.SetLineInfo(CurrentLine,FDomains[CurrentLine].Prompt+': '+FDomains[CurrentLine].Text);
end;
procedure TFormState.SetCurrentLine(Value:Integer);
const
   LastCurrentLine:Integer =0;
begin
   if Value = -1 then Value:=LastCurrentLine;
   if FPreEditCurrentText <> FCurrentText then
      FModified:=True;
   FUIInterface.CurrentLine:=Value;
   CurrentText:=FDomains[Value].Text;
   FUIInterface.SetPrompt(FDomains[Value].Prompt);
   FUIInterface.SetHint  (FDomains[Value].Hint  );
   
   FPreEditCurrentText:=FDomains[Value].Text;
   FFirstKeyInEdit:=True;
   LastCurrentLine:=Value;
end;
function TFormState.GetCurrentLine:Integer;
begin
   Result:=FUIInterface.CurrentLine;
end;

procedure TFormState.KeyPress(KeyCode:Integer;System:Boolean);
begin
   if System then
   begin
      case KeyCode of
         0            : begin
                           FUIInterface.Clear;
                           FUIInterface.State:=uisForm;
                           SetFormData;
                           CurrentLine:=-1;
                        end;
         Key_FuncMin..
         Key_FuncMax  : begin
                           FUIInterface.SetButtonState(KeyCode-Key_FuncMin,bsToggle);
                        end;
         Key_Up       : begin
                           if CurrentLine > 0 then 
                              CurrentLine:=CurrentLine-1;
                        end;
         Key_Select   : begin
                           KeyPress(Key_Down,True);
                        end;
         Key_Down     : begin
                           if CurrentLine < FUIInterface.CurrentMaxLine-1 then 
                              CurrentLine:=CurrentLine+1;
                        end;
         Key_Cancel   : begin
                           if CurrentText = FPreEditCurrentText then
                           begin
                              if FModified then
                              begin
                                 if FUIInterface.UIStateEngine.ShowWarning(FHItems,FHText) < 1 then
                                 begin
                                    FFinishedProcessing:=True;
                                 end;
                              end     
                              else
                              begin
                                 FFinishedProcessing:=True;
                              end;
                           end
                           else
                           begin
                              CurrentText:=FPreEditCurrentText;
                           end;
                        end;   
      end;              
   end
   else
   begin
      if KeyCode = Key_BackSpace then
      begin
         CurrentText:=Copy(FCurrentText,1,Length(FCurrentText)-1);
         FFirstKeyInEdit:=False;
      end
      else if KeyCode > Key_ControlMax then
      begin
         if FFirstKeyInEdit then
             CurrentText:=Char(KeyCode)
         else
             CurrentText:=FCurrentText+Char(KeyCode);
         FFirstKeyInEdit:=False;
      end;
   end;
end;
procedure TFormState.ProcessForm;
begin
   FUIInterface.Clear;
   FUIInterface.State:=uisForm;
   SetFormData;
   CurrentLine:=0;
   FPreEditCurrentText:=CurrentText;
   FUIInterface.SetTitle(FItems.Title);
   FUIInterface.SetPicture(FItems.Picture);
   FModified:=False;
   while not FFinishedProcessing do
   begin
      Application.ProcessMessages;
      if Application.Terminated then Exit;
   end;
end;
{THelpState}     
procedure THelpState.SetFormLines(List:TStrings);
var
   I:Integer;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.Text:=FHelpText;
   with FUIInterface do
   begin
      for I:=0 to SL.Count-1 do
         SetLineInfo(I,SL[I]);
   end;
   SL.Free;
end;  
procedure THelpState.KeyPress(KeyCode:Integer;System:Boolean);
begin
   if System then
   begin
      case KeyCode of
         Key_FuncMin..
         Key_FuncMax,  
         Key_Cancel   : inherited KeyPress(KeyCode,System);
         Key_Up       : begin
                        end;
         Key_Down     : begin
                        end;
      end;              
   end
end;
function THelpState.Show(Items:TPickList;HelpText:String):Integer;
begin
   FHelpText:=HelpText;
   Result:=inherited PickItem(Items,False,False,-1);
end;

  
{TUIStateEngine}
constructor TUIStateEngine.Create(UIInterface:TUIInterface);
begin
   inherited Create;
   FUIInterface:=UIInterface;
end;
procedure TUIStateEngine.KeyPress(KeyCode:Integer;System:Boolean);
begin
   if FCurrentState <> nil then
      FCurrentState.KeyPress(KeyCode,System);
end;
procedure TUIStateEngine.ShowForm(Items:TPickList;Domains:TDomainList;HItems:TPickList;HText:String);
begin
   CurrentState:=TFormState.Create(FUIInterface,Items,Domains,HItems,HText);
   (CurrentState as TFormState).ProcessForm;
   CurrentState.Free;
   CurrentState:=nil;
end;
function TUIStateEngine.ShowWarning(WButtons:TPickList;Warning:String):Integer;
var
   SaveState:TUIState;
begin
   SaveState:=CurrentState;
   CurrentState:=THelpState.Create(FUIInterface);
   Result:=(CurrentState as THelpState).Show(WButtons,Warning);
   CurrentState.Free;
   CurrentState:=SaveState;
   CurrentState.KeyPress(0,True);
end;
procedure TUIStateEngine.ShowHelp(HelpText:String);
begin
end;
procedure TUIStateEngine.ShowInfo(HelpText:String);
begin
end;
function TUIStateEngine.PickItem(Items:TPickList;ShowNumbers,Sorted:Boolean;Default:Integer):Integer;
begin
   CurrentState:=TPickState.Create(FUIInterface);
   Result:=(CurrentState as TPickState).PickItem(Items,ShowNumbers,Sorted,Default);
   CurrentState.Free;
   CurrentState:=nil;
end;
function TUIStateEngine.PickMenuItem(Items:TPickList;Transactions:TTxnList;Default:Integer):Integer;
begin
   CurrentState:=TMenuState.Create(FUIInterface);
   Result:=(CurrentState as TMenuState).PickItem(Items,Transactions,True,False,Default);
   CurrentState.Free;
   CurrentState:=nil;
end;
{TUIInterface}
constructor TUIInterface.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   FUIStateEngine:=TUIStateEngine.Create(Self);
   FState:=uisNone;
end;
destructor TUIInterface.Destroy;
begin
   FUIStateEngine.Free;
   inherited Destroy;
end;
procedure TUIInterface.SetButtonState(Index:Integer;State:ButtonState);
begin
   if Assigned(FOnSetButtonState) then FOnSetButtonState(Index,State);
end;   

function TUIInterface.GetMaxItem:Integer;
begin
   Result:=10;
   if Assigned(FOnGetMaxItem) then 
     Result:=FOnGetMaxItem;
end;
procedure TUIInterface.SetMaxItem(Value:Integer);
begin
   if Assigned(FOnSetMaxItem) then FOnSetMaxItem(Value);
end;

procedure TUIInterface.SetTitle (Value:String);
begin
   if Assigned(FOnSetTitle) then FOnSetTitle(Value);
end;
procedure TUIInterface.SetPicture(Value:TBitMap);
begin
   if Assigned(FOnSetPicture) then FOnSetPicture(Value);
end;
procedure TUIInterface.SetPrompt(Value:String);
begin
   if Assigned(FOnSetPrompt) then FOnSetPrompt(Value);
end;
procedure TUIInterface.SetHint  (Value:String);
var
   I:Integer;
begin
   for I:=1 to Length(Value) do
   begin
      if Value[I] = '^' then
      begin
         if Assigned(FOnSetHint1) then FOnSetHint1(Copy(Value,1,I-1));
         if Assigned(FOnSetHint2) then FOnSetHint2(Copy(Value,I+1,Length(Value)));
         Exit;
      end;
   end;
   if Assigned(FOnSetHint1) then FOnSetHint1(Value);
   if Assigned(FOnSetHint2) then FOnSetHint2('');
end;
procedure TUIInterface.SetState(Value:FormState);
begin
   FState:=Value;
   if Assigned (FOnSetFormState) then FOnSetFormState(FState);
end;                                  
procedure TUIInterface.SetText(Value:String);
begin
   if Assigned(FOnSetText) then FOnSetText(Value);
end;
procedure TUIInterface.Clear;
begin
   State:=uisNone;
   if Assigned(FOnClearUI) then FOnClearUI;
end;    
procedure TUIInterface.SetButtonInfo(Index:Integer;Caption:String;Picture:TBitMap;Price:Currency;Enabled,Selected:Boolean);
begin
   if Assigned(FOnSetButtonInfo) then FOnSetButtonInfo(Index,Caption,Picture,Price,Enabled,Selected);
end;
procedure TUIInterface.SetLineInfo(Index:Integer;Caption:String);
begin
   if Assigned(FOnSetLineInfo) then FOnSetLineInfo(Index,Caption);
end;
procedure TUIInterface.SetCurrentLine(Value:Integer);
begin
   if Assigned(FOnSetCurrentLine) then FOnSetCurrentLine(Value);
end;
function TUIInterface.GetCurrentLine:Integer;
begin
   Result:=0;
   if Assigned(FOnGetCurrentLine) then Result:=FOnGetCurrentLine;
end;
function TUIInterface.GetCurrentMaxLine:Integer;
begin
   Result:=0;
   if Assigned(FOnGetCurrentMaxLine) then Result:=FOnGetCurrentMaxLine;
end;

end.

