unit UITypesFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Domain, Mask,UIStatesU,GPCSBase_TLB,
  GPCSGUID,UIInterfaceU,UIClientSinkU;
   
type            
  TForm1 = class(TForm)
    DogsRep: TImage;
    StartServer: TButton;
    Image1: TImage;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartServerClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    CompMan:ICompMan;
    UILink:IUILink;
    Items       :TPickList;
    HItems      :TPickList;
    FItems      :TPickList;     
    MAItems     :TPickList;                        
    MBItems     :TPickList;     
    Transactions:TTxnList;     
    Domains     :TDomainList;
    HText:String;
    UIClientSink:TUIClientSink;
  public  
    UIInterface:TUIInterface;
    procedure StartUI;
    procedure SetButtonState(Index:Integer;State:ButtonState);
    procedure SetTitle(Value:String);
    procedure SetMaxItem(Value:Integer);
    function  GetMaxItem:Integer;
    procedure SetPicture(Value:TBitMap);
    procedure SetPrompt(Value:String);
    procedure SetHint1(Value:String);
    procedure SetHint2(Value:String);
    procedure SetState(Value:FormState);
    procedure SetText(Value:String);
    procedure ClearUI;
    procedure SetButtonInfo(Index:Integer;Caption:String;Picture:TBitMap;Price:Currency;Enabled,Selected:Boolean);
    procedure SetLineInfo(Index:Integer;Caption:String);
    procedure SetCurrentLine(Value:Integer);
    function  GetCurrentLine:Integer;
    function  GetCurrentMaxLine:Integer;
  end;        

var
  Form1: TForm1;

implementation

{$R *.DFM}

{TForm1}                                
procedure TForm1.SetButtonState(Index:Integer;State:ButtonState);
begin
   if UILink <> nil then UILink.SetButtonState(Index,State);
end;   
procedure TForm1.SetPicture(Value:TBitMap);
var
   BitMap:TIBitmap;
   PictureID:Integer;
begin
   if UILink <> nil then 
   begin
      if Value <> nil then
      begin
         BitMap:=TIBitmap.Create;
         BitMap.SetFromBitMap(Value);
         PictureID:=UILink.GetPictureIdentFromCRC(BitMap.CRC);
         if PictureID < 0 then
            PictureID:=UILink.SavePicture(BitMap);
         BitMap.Free;
         UILink.SetPicture(PictureID);
      end;
   end;
end;
procedure TForm1.SetMaxItem(Value:Integer);
begin
   if UILink <> nil then UILink.MaxItem:=Value;
end;
function TForm1.GetMaxItem:Integer;
begin
   Result:=10;
   if UILink <> nil then Result:=UILink.MaxItem;
end;     
procedure TForm1.SetTitle(Value:String);
begin
   if UILink <> nil then UILink.SetTitle(Value);
end;
procedure TForm1.SetPrompt(Value:String);
begin
   if UILink <> nil then UILink.SetPrompt(Value);
end;                              
procedure TForm1.SetHint1(Value:String);
begin
   if UILink <> nil then UILink.SetHint1(Value);
end;                              
procedure TForm1.SetHint2(Value:String);
begin
   if UILink <> nil then UILink.SetHint2(Value);
end;                              
procedure TForm1.SetState(Value:FormState);
begin
   UILink.SetFormState(Value);
   if Value = uisPick then
      Color:=clBtnFace
   else if Value = uisMenu then
      Color:=clYellow
   else if Value = uisTrans then
      Color:=clRed
   else 
      Color:=clWindow;
end;
procedure TForm1.SetText(Value:String);
begin
   if UILink <> nil then UILink.SetText(Value);
end;
procedure TForm1.ClearUI;
begin
   if UILink <> nil then UILink.ClearUI;
end;                  
procedure TForm1.SetButtonInfo(Index:Integer;Caption:String;Picture:TBitMap;Price:Currency;Enabled,Selected:Boolean);
var
   BitMap:TIBitmap;
   PictureID:Integer;
begin
   if UILink <> nil then 
   begin
      if Picture <> nil then
      begin
         BitMap:=TIBitmap.Create;
         BitMap.SetFromBitMap(Picture);
         PictureID:=UILink.GetPictureIdentFromCRC(BitMap.CRC);
         if PictureID < 0 then
            PictureID:=UILink.SavePicture(BitMap);
         BitMap.Free;
         UILink.SetButtonInfo(Index,Caption,PictureID,Price,Enabled,Selected);
      end
      else
      begin
         UILink.SetButtonInfo(Index,Caption,-1,Price,Enabled,Selected);
      end;
   end;
end;
procedure TForm1.SetLineInfo(Index:Integer;Caption:String);
begin
   UILink.SetLineInfo(Index,Caption);
end;
procedure TForm1.SetCurrentLine(Value:Integer);
begin
//   if ListBox1.Items.Count > Value then 
//   begin
//      ListBox1.SetFocus;
//      ListBox1.ItemIndex:=Value;
//   end;
   UILink.SetCurrentLine(Value);
end;
function TForm1.GetCurrentLine:Integer;
begin
   Result:=UILink.GetCurrentLine;
//   Result:=ListBox1.ItemIndex;   
end;
function TForm1.GetCurrentMaxLine:Integer;
begin
   Result:=UILink.GetMaxCurrentLine;
end;
procedure TForm1.FormCreate(Sender: TObject);   
begin
   UIInterface:=TUIInterface.Create(nil);
   UIInterface.OnSetButtonState:=SetButtonState;
   UIInterface.OnSetTitle   :=SetTitle ;
   UIInterface.OnSetPicture :=SetPicture;
   UIInterface.OnSetPrompt  :=SetPrompt;
   UIInterface.OnSetHint1   :=SetHint1 ;
   UIInterface.OnSetHint2   :=SetHint2 ;
   UIInterface.OnSetFormState:=SetState;
   UIInterface.OnSetText:=SetText;
   UIInterface.OnClearUI:=ClearUI;
   UIInterface.OnSetButtonInfo:=SetButtonInfo;
   UIInterface.OnSetLineInfo:=SetLineInfo;
   UIInterface.OnSetCurrentLine   :=SetCurrentLine   ;
   UIInterface.OnGetCurrentLine   :=GetCurrentLine   ;
   UIInterface.OnGetCurrentMaxLine:=GetCurrentMaxLine;
   UIInterface.OnSetMaxItem:=SetMaxItem;
   UIInterface.OnGetMaxItem:=GetMaxItem;
   
   UIClientSink:=TUIClientSink.Create;
   UIClientSink.UIStateEngine:=UIInterface.UIStateEngine;
   
   KeyPreview:=True;
   HItems:=TPickList.Create('You have Changed This Form','Select Continue To Exit','Select Continue To Exit^or Select Return to go back to the form',Image1.Picture.Bitmap);
   HItems.Add(TPickItem.Create('Continue (Loose information)',DogsRep.Picture.Bitmap,False,True,0));
   HItems.Add(TPickItem.Create('Return',DogsRep.Picture.Bitmap,False,True,0));
   
   Domains:=TDomainList.Create;
   Domains.Add(TDomainItem.Create('Prompt1','Hint1^Hint2','Error1','Validation','Text1'));
   Domains.Add(TDomainItem.Create('Prompt2','Hint1^Hint2','Error2','Validation','Text2'));
   Domains.Add(TDomainItem.Create('Prompt3','Hint1^Hint2','Error3','Validation','Text3'));
   Domains.Add(TDomainItem.Create('Prompt4','Hint1^Hint2','Error4','Validation','Text4'));
   Domains.Add(TDomainItem.Create('Prompt5','Hint1^Hint2','Error5','Validation','Text5'));
   Domains.Add(TDomainItem.Create('Prompt6','Hint1^Hint2','Error6','Validation','Text6'));
   
   FItems:=TPickList.Create('Form Items','Select a Form Item','Select a Form Item^by pressing the function Key',Image1.Picture.Bitmap);
   FItems.Add(TPickItem.Create('Registered',DogsRep.Picture.Bitmap,False,True,3.99));
   FItems.Add(TPickItem.Create('Insured',DogsRep.Picture.Bitmap,False,True,3.99));
   FItems.Add(TPickItem.Create('Advice of Delivery',DogsRep.Picture.Bitmap,False,True,0));
   FItems.Add(TPickItem.Create('Express',DogsRep.Picture.Bitmap,False,True,3.99));
   
   Transactions:=TTxnList.Create;
   Transactions.Add(TTxnItem.Create('Transaction Line 1','Add',0.99));
   Transactions.Add(TTxnItem.Create('Transaction Line 2','Add',1.99));
   Transactions.Add(TTxnItem.Create('Transaction Line 3','Add',2.99));
   Transactions.Add(TTxnItem.Create('Transaction Line 4','Add',3.99));
   
   Items:=TPickList.Create('Item Picker','Pick an Item from the List','Pick an Item from the List^or Press the function Key',Image1.Picture.Bitmap);
   Items.Add(TPickItem.Create('AItem' ,DogsRep.Picture.Bitmap,False,True,0.00));
   Items.Add(TPickItem.Create('BItem' ,DogsRep.Picture.Bitmap,False,True,1.00));
   Items.Add(TPickItem.Create('CItem' ,DogsRep.Picture.Bitmap,False,True,2.00));
   Items.Add(TPickItem.Create('DItem' ,DogsRep.Picture.Bitmap,False,True,3.00));
   Items.Add(TPickItem.Create('EItem' ,DogsRep.Picture.Bitmap,False,True,4.00));
   Items.Add(TPickItem.Create('FItem' ,DogsRep.Picture.Bitmap,False,True,5.00));
   Items.Add(TPickItem.Create('GItem' ,DogsRep.Picture.Bitmap,False,True,6.00));
   Items.Add(TPickItem.Create('HItem' ,DogsRep.Picture.Bitmap,False,True,7.00));
   Items.Add(TPickItem.Create('IItem' ,DogsRep.Picture.Bitmap,False,True,8.00));
   Items.Add(TPickItem.Create('JItem',DogsRep.Picture.Bitmap,False,True,999.99));
   Items.Add(TPickItem.Create('KItem',nil,False,True,1.99));
   Items.Add(TPickItem.Create('LItem',nil,False,True,2.99));
   Items.Add(TPickItem.Create('MAItem',DogsRep.Picture.Bitmap,False,True,3.99));
   Items.Add(TPickItem.Create('MBItem',DogsRep.Picture.Bitmap,False,True,3.99));
   Items.Add(TPickItem.Create('MCItem',DogsRep.Picture.Bitmap,False,True,3.99));
   Items.Add(TPickItem.Create('MDItem',DogsRep.Picture.Bitmap,False,True,3.99));
   Items.Add(TPickItem.Create('NItem',nil,False,True,3.99));
   Items.Add(TPickItem.Create('OItem',nil,False,True,3.99));
   Items.Add(TPickItem.Create('PItem',nil,False,True,3.99));
   Items.Add(TPickItem.Create('QItem',nil,False,True,3.99));
   Items.Add(TPickItem.Create('RItem',nil,False,True,3.99));
   Items.Add(TPickItem.Create('SItem',nil,False,True,3.99));
   Items.Add(TPickItem.Create('TItem',nil,False,True,3.99));
   Items.Add(TPickItem.Create('UItem',nil,False,True,3.99));
   Items.Add(TPickItem.Create('VItem',nil,False,True,3.99));
   Items.Add(TPickItem.Create('WItem',nil,False,True,3.99));
   Items.Add(TPickItem.Create('XItem',nil,False,True,3.99));
   Items.Add(TPickItem.Create('YItem',DogsRep.Picture.Bitmap,False,True,3.99));
   Items.Add(TPickItem.Create('ZItem',DogsRep.Picture.Bitmap,False,True,3.99));

   MAItems:=TPickList.Create('Menu Picker','Select a Menu Option','Select a Menu Option^or Press the function Key',Image1.Picture.Bitmap);
   
   MBItems:=TPickList.Create('Menu 2 Picker','Select a Menu Option','Select a Menu Option^or Press the function Key',DogsRep.Picture.Bitmap);
   MBItems.Add(TPickItem.Create('Menu Item A',DogsRep.Picture.Bitmap,False,True,3.99));
   MBItems.Add(TPickItem.Create('Menu Item B',DogsRep.Picture.Bitmap,False,True,3.99));
   MBItems.Add(TPickItem.Create('Menu Item C',DogsRep.Picture.Bitmap,False,True,3.99));
   MBItems.Add(TPickItem.Create('Menu Item D',DogsRep.Picture.Bitmap,False,True,3.99));
   MBItems.Add(TPickItem.Create('Menu Item E',DogsRep.Picture.Bitmap,False,True,3.99));
   MBItems.Add(TPickItem.Create('Menu Item F',DogsRep.Picture.Bitmap,False,True,3.99));
   MBItems.Add(TPickItem.Create('Menu Item G',DogsRep.Picture.Bitmap,False,True,3.99));
   MBItems.Add(TPickItem.Create('Menu Item H',DogsRep.Picture.Bitmap,False,True,3.99));
   MBItems.Add(TPickItem.Create('Menu Item I',DogsRep.Picture.Bitmap,False,True,3.99));
   MBItems.Add(TPickItem.Create('Menu Item J',DogsRep.Picture.Bitmap,False,True,3.99));
   HText:='You have changed this form'+#13#10+'Do you wish to Exit';
end;
 
procedure TForm1.FormDestroy(Sender: TObject);
begin
   if UILink <> nil then
      UILink.SetUIClientSink(nil);
   UIClientSink.Free;
   UILink:=nil;
   CompMan:=nil;
   Items       .Free;
   FItems      .Free;
   MAItems     .Free;
   MBItems     .Free;
   Transactions.Free;
   Domains     .Free;
   HItems      .Free;
end;

procedure TForm1.StartUI;
begin
   if CompMan = nil then
      CompMan:=CreateCompMan;
   if CompMan <> nil then
   begin
      while not Compman.Ready do
      begin
         Application.ProcessMessages;
         Sleep(1000);
      end;
      if UILink = nil then
//         UILink:=CreateOleObject('Support.UILink') as IUILink;
         UILink:=CompMan.LoadComponent('Support.UILink') as IUILink;
      if UILink <> nil then
      begin
         UILink.SetServerName('UIServer.Blue');
         UILink.SetUIClientSink(UIClientSink);
         UILink.ClearUI;
      end;
   end;
end;
procedure TForm1.StartServerClick(Sender: TObject);
var
  ItemSelected:Integer;
begin
   if CompMan = nil then
      CompMan:=CreateCompMan;
   if CompMan <> nil then
   begin
      while not Compman.Ready do
      begin
         Application.HandleMessage;
         Sleep(1000);
      end;
      if UILink = nil then
//         UILink:=CreateOleObject('Support.UILink') as IUILink;
         UILink:=CompMan.LoadComponent('Support.UILink') as IUILink;
      if UILink <> nil then
      begin
         UILink.SetServerName('UIServer.Blue');
         UILink.SetUIClientSink(UIClientSink);
         UILink.ClearUI;
         ItemSelected:=0;
         repeat
            ItemSelected:=UIInterface.UIStateEngine.PickMenuItem(MAItems,nil,ItemSelected);
            case ItemSelected of            
               1 : UIInterface.UIStateEngine.PickItem(Items,False,True,9);
               2 : UIInterface.UIStateEngine.ShowForm(FItems,Domains,HItems,HText);
               3 : UIInterface.UIStateEngine.PickMenuItem(MBItems,Transactions,0);
               4 : begin ItemSelected:=0; Close; end;
            end;
         until (ItemSelected < 1 );
         UIInterface.Clear;
      end;
   end;
end;
procedure TForm1.Button1Click(Sender: TObject);
var
   PickItem:TPickItem;
begin
   if MaItems.Count = 0 then
   begin
      MAItems.Add(TPickItem.Create('Exit',DogsRep.Picture.Bitmap,False,True,3.99));
      MAItems.Add(TPickItem.Create('Pick Item',DogsRep.Picture.Bitmap,False,True,3.99));
      MAItems.Add(TPickItem.Create('Form',DogsRep.Picture.Bitmap,False,True,0));
      MAItems.Add(TPickItem.Create('Menu 2',DogsRep.Picture.Bitmap,False,True,3.99));
   end
   else if (MAItems.Count < 5) then
   begin
      MAItems.Add(TPickItem.Create('Complete Exit',DogsRep.Picture.Bitmap,False,True,0));
   end
   else
   begin
      PickItem:=MAItems[4];
      PickItem.Caption:='';
      PickItem.Picture:=nil;
      PickItem.Price:=0;
      PickItem.Selected:=False;
      PickItem.Enabled:=True;
      UIInterface.UIStateEngine.CurrentState.SetFormData;
      if UIInterface.CurrentLine = 4 then
         UIInterface.CurrentLine:=3;
      MAItems.Delete(4);
   end;
   UIInterface.UIStateEngine.CurrentState.Refresh;
end;


end.
 