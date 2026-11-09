unit CompListFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GPCSBase_TLB, GPCSRegistry, StdCtrls, ComCtrls, ExtCtrls, Menus,
  SelectorU, Buttons,DesInterfaceU,ComObj,PackStrListU;

type
  TComponentPalette = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    N2: TMenuItem;
    Register1: TMenuItem;
    RegisterOn1: TMenuItem;
    N3: TMenuItem;
    View1: TMenuItem;
    Products1: TMenuItem;
    Groups1: TMenuItem;
    Lookups1: TMenuItem;
    Picklists1: TMenuItem;
    Services1: TMenuItem;
    UserGroups1: TMenuItem;
    WSGroups1: TMenuItem;
    Window1: TMenuItem;
    CloseAll1: TMenuItem;
    Options1: TMenuItem;
    DisplayOptions1: TMenuItem;
    Products2: TMenuItem;
    Groups2: TMenuItem;
    LookUps2: TMenuItem;
    PickLists2: TMenuItem;
    Services2: TMenuItem;
    UserGroups2: TMenuItem;
    WSGroups2: TMenuItem;
    N4: TMenuItem;
    CompilerOptions1: TMenuItem;
    DefaultDirectories1: TMenuItem;
    Close2: TMenuItem;
    SaveDialog1: TSaveDialog;
    Panel1: TPanel;
    PL: TListBox;
    Selector1: TSelector;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    PopupMenu1: TPopupMenu;
    Delete1: TMenuItem;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    procedure Save1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure PLMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure PLDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure Selector1ItemSelected(Sender: TSelector);
    procedure Panel1Resize(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure PLDblClick(Sender: TObject);
    procedure Selector1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure Selector1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure CompilerOptions1Click(Sender: TObject);
    procedure Selector1Rename(Sender: TSelector; OldName, NewName: String);
    procedure Selector1Delete(Sender: TSelector; Name: String);
    procedure Delete1Click(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure DefaultDirectories1Click(Sender: TObject);
  private
     GR:TGPCSRegistry;
     FFileName:String;
     FBuildOptions:String;
     FProjectName:String;
     CompType:String;
     procedure SetFileName(Value:String);
     procedure SetProjectOptions(S:String);
     function  GetProjectOptions:String;
  public
     property ProjectName:String read FProjectName write FProjectName;
     property BuildOptions:String read FBuildOptions write FBuildOptions;
     property FileName:String read FFileName write SetFileName;
  end;

var
  ComponentPalette: TComponentPalette;

implementation

uses WaitBoxFU, CompOptionsFU, BuildProgFU,CDMain,ProjOptionsFU;

{$R *.DFM}

procedure TComponentPalette.SetProjectOptions(S:String);
var
  SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.CommaText:=S;
   if StrToIntDef(SL[0],-1) = -1 then
   begin
      FProjectName:=SL[0];
      SL.Delete(0);
   end;
   FBuildOptions:=SL.CommaText;
   SL.Free;
end;
function TComponentPalette.GetProjectOptions:String;
var
  SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   SL.CommaText:=FBuildOptions;
   SL.Insert(0,FProjectName);
   Result:=SL.CommaText;
   SL.Free;
end;
procedure TComponentPalette.SetFileName(Value:String);
var
   SL:TPackStringList;
   S:String;
begin
   if Value <> FFileName then
   begin
      FFileName:=Value;     
      GR.LoadFromFile(FFileName,S);
      SetProjectOptions(S);
      SL:=GR.CreateGroupList(CompType);
      Selector1.Items.Assign(SL);
      SL.Free;
      Selector1.Selected:=0;
      Caption:='Project - '+FFileName;
      SaveDialog1.FileName:=FFileName;
   end
   else
   begin
      // Do you want to revert ?
   end;
end;
procedure TComponentPalette.Save1Click(Sender: TObject);
begin
   if SaveDialog1.FileName = '' then
   begin
      if SaveDialog1.Execute then
      begin
         GR.SaveToFile(SaveDialog1.FileName,GetProjectOptions);
      end;
   end
   else
   begin
      GR.SaveToFile(SaveDialog1.FileName,GetProjectOptions);
   end;
end;

procedure TComponentPalette.FormCreate(Sender: TObject);
begin
   SaveDialog1.FileName:='';
   GR:=TGPCSRegistry.Create;
   CompType:='Product';
   if (PL.Width < 100) or ((PL.Width div 100) < 2) then
      PL.Columns:=0
   else
      PL.Columns:=PL.Width div 100;
end;

procedure TComponentPalette.FormDestroy(Sender: TObject);
begin
   MainForm.CurrentProject:=nil;
   GR.free;
end;

procedure TComponentPalette.SaveAs1Click(Sender: TObject);
begin
   if SaveDialog1.Execute then
      GR.SaveToFile(SaveDialog1.FileName,GetProjectOptions);
end;

procedure TComponentPalette.PLMeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
begin
   Height:=94;
end;
procedure AdjustRatio(var Rect:TRect;IW,IH:Integer);
var
 IRatio:Real;
 MRatio:Real;
 MW,MH:Integer;
begin
  MW:=Rect.Right-Rect.Left;
  MH:=Rect.Bottom-Rect.Top;

  if (IH = 0) or (MH = 0)  or (IW = 0)  or (MW = 0) then Exit;
  if (IW <= MW) and (IH <= MH) then
  begin
    Rect.Left :=Rect.Left+((MW-IW) div 2);
    Rect.Top  :=Rect.Top +((MH-IH) div 2);
    Rect.Right :=Rect.Left+IW;
    Rect.Bottom:=Rect.Top +IH;
  end
  else
  begin
    IRatio:=IW/IH;
    MRatio:=MW/MH;
    if IRatio > MRatio then
    begin
     Rect.Top  :=Rect.Top +((MH-Trunc(MW/IRatio)) div 2);
     Rect.Right :=Rect.Left+MW;
     Rect.Bottom:=Rect.Top +Trunc(MW/IRatio);
    end
    else
    begin
     Rect.Left :=Rect.Left+((MW-Trunc(MH*IRatio)) div 2);
     Rect.Right :=Rect.Left+Trunc(MH*IRatio);
     Rect.Bottom:=Rect.Top +MH;
    end;
  end;
end;
procedure TComponentPalette.PLDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   RegEntry:TGPCSRegistryEntry;
   Image:TBitmap;
   DR:TRect;
   IW:Integer;
   TH:Integer;
   Desc:String;
   BC:TColor;
begin
   with PL.Canvas do
   begin
      IW:=Rect.Right-Rect.Left;
      RegEntry:=TGPCSRegistryEntry(PL.Items.Objects[Index]);
      BC:=Brush.Color;
      Brush.Color:=PL.Color;
      FillRect(Rect);
      Brush.Color:=BC;
      
      if BC = PL.Color then Brush.Color:=$00F0F0F0;
      with Rect do Rectangle(Left+1,Top+1,Right-1,Bottom-1);
//      Brush.Style:=bsClear;
      OffsetRect(Rect,1,1);
      Rect.Right:=Rect.Right-2;
      Rect.Bottom:=Rect.Bottom-2;

      Font.Style:=[fsBold];
      TextOut(Rect.Left+2,Rect.Bottom-(TextHeight('Wg')+1),RegEntry.Version);
      if RegEntry.Caption <> '' then Desc:=RegEntry.Caption else Desc:=RegEntry.Description;
      DR:=Rect;
      DrawText(PL.Canvas.Handle,PChar(Desc),Length(Desc),DR,DT_WORDBREAK or DT_CALCRECT); 
      OffsetRect(DR,((Rect.Right-Rect.Left)-(DR.Right-DR.Left)) div 2,1);
      TH:=DrawText(PL.Canvas.Handle,PChar(Desc),Length(Desc),DR,DT_WORDBREAK or DT_CENTER); 
      Font.Style:=[];
      Desc:=Copy(RegEntry.ProgID,Length(RegEntry.ComponentType)+2,Length(RegEntry.ProgID));
      TextOut(Rect.Left+(IW-TextWidth(Desc)) div 2,Rect.Top+TH+2,Desc);
      if RegEntry.BitMap <> '' then 
      begin
         Image:=RegEntry.Image;
         DR:=Rect;
         DR.Top:=DR.Top+TH+1+TextHeight('Wg');
         DR.Bottom:=DR.Bottom-2;
         AdjustRatio(DR,Image.Width,Image.Height);
         BrushCopy(DR,Image,Bounds(0,0,Image.Width,Image.Height),Image.TransparentColor);
         Image.Free;
      end;
//      Brush.Style:=bsSolid;
      Brush.Color:=BC;
   end;      
end;

procedure TComponentPalette.Selector1ItemSelected(Sender: TSelector);
var
   SL:TPackStringList;
begin
   SL:=GR.CreateCompList(CompType,Sender.Items[Sender.Selected]);
   if (CompType = 'Product') or (CompType = 'Group') then
      PL.ItemHeight:=88
   else
      PL.ItemHeight:=32;
   PL.Items.Assign(SL);
   SL.Free;
   if SpeedButton1.Down then
      SpeedButton1.Tag:=Sender.Selected
   else if SpeedButton2.Down then
      SpeedButton2.Tag:=Sender.Selected
   else if SpeedButton3.Down then
      SpeedButton3.Tag:=Sender.Selected
   else if SpeedButton4.Down then
      SpeedButton4.Tag:=Sender.Selected
   else if SpeedButton5.Down then
      SpeedButton5.Tag:=Sender.Selected
   else if SpeedButton6.Down then
      SpeedButton6.Tag:=Sender.Selected
   else if SpeedButton7.Down then
      SpeedButton7.Tag:=Sender.Selected;
end;                                   

procedure TComponentPalette.Panel1Resize(Sender: TObject);
begin
   if (PL.Width < 100) or ((PL.Width div 100) < 2) then
      PL.Columns:=0
   else
      PL.Columns:=PL.Width div 100;
   PL.Invalidate;
end;

procedure TComponentPalette.SpeedButton1Click(Sender: TObject);
var
   SL:TPackStringList;
begin
   Products1.Checked:=True;
   SpeedButton1.Down:=True;
   CompType:='Product';
   SL:=GR.CreateGroupList(CompType);
   Selector1.Items.Assign(SL);
   SL.Free;
   Selector1.Selected:=SpeedButton1.Tag;
end;

procedure TComponentPalette.SpeedButton2Click(Sender: TObject);
var
   SL:TPackStringList;
begin
   Groups1.Checked:=True;
   SpeedButton2.Down:=True;
   CompType:='Group';
   SL:=GR.CreateGroupList(CompType);
   Selector1.Items.Assign(SL);
   SL.Free;
   Selector1.Selected:=SpeedButton2.Tag;
end;

procedure TComponentPalette.PLDblClick(Sender: TObject);
var
   ExecComponent:IExecComponent;
   DesInterface:TDesInterface;
   I:Integer;
begin
   I:=GR.IndexOf(TGPCSRegistryEntry(PL.Items.Objects[PL.ItemIndex]).ProgID);
   if I <> -1 then
   begin
      try               
         ExecComponent:=CreateComObject(StringToGUID(GR[I].GUID)) as IExecComponent;
         if ExecComponent <> nil then
         begin
           try               
               DesInterface:=TDesInterface.Create;
               DesInterface.Set_Parent(Application.Handle);
               DesInterface.Set_BuildParams(CompOptions.OutPASDir.Text+'\'+CompType+'\'+Selector1.Items[Selector1.Selected]);
               ExecComponent.Design('',DesInterface);
            except
               ShowMessage('Design Not Available');
            end;
         end
         else
         begin
            ShowMessage('Version 1 Component');
         end;
      except
         ShowMessage('Error Loading Component');
      end;
   end;
end;

procedure TComponentPalette.Selector1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   if (Source is TComponent) 
   and (((Source as TComponent).Name = 'PL') or ((Source as TComponent).Name = 'Selector1')) 
   and (Sender <> Source) then
      Accept:=True
   else
      Accept:=False;
end;
procedure TComponentPalette.Selector1DragDrop(Sender,Source:TObject;X,Y:Integer);
var
  LB:TListBox;
  I,J:Integer;
  ItemIndex:Integer;
  RegEntry:TGPCSRegistryEntry;
  P:TControl;
  Group:String;
  SL:TPackStringList;
begin
   if (Source is TComponent) and ((Source as TComponent).Name = 'PL') then
   begin
      LB:=(Source as TListBox);
      ItemIndex:=Y div (Selector1.Height div Selector1.Count);
      for I:=0 to LB.Items.Count-1 do
      begin
         if LB.Selected[I] then
         begin
            RegEntry:=TGPCSRegistryEntry(LB.Items.Objects[I]);
            RegEntry:=GR.Item[GR.Add(RegEntry)];
            RegEntry.Group:=Selector1.Items[ItemIndex];
         end;
      end;
      Selector1ItemSelected(Selector1);
   end;
   if (Source is TControl) and ((Source as TControl).Name = 'Selector1') and (Sender <> Source) then
   begin
      P:=(Source as TControl).Parent;
      while (P <> nil) and (not (P is TForm)) do P:=P.Parent;
      for J:=0 to P.ComponentCount-1 do
      begin
         if P.Components[J].Name = 'PL' then
         begin
            Group:=(Source as TSelector).Items[(Source as TSelector).Selected];
            LB:=(P.Components[J] as TListBox);
            for I:=0 to LB.Items.Count-1 do
            begin
               RegEntry:=TGPCSRegistryEntry(LB.Items.Objects[I]);
               RegEntry:=GR.Item[GR.Add(RegEntry)];
               RegEntry.Group:=Group;
            end;
            SL:=GR.CreateGroupList(CompType);
            Selector1.Items.Assign(SL);
            SL.Free;
            for I:=0 to Selector1.Count-1 do
               if Selector1.Item[I] = Group then
                  Selector1.Selected:=I;
            Selector1ItemSelected(Selector1);
            break;
         end;
      end;
   end;
end;

procedure TComponentPalette.SpeedButton3Click(Sender: TObject);
var
   SL:TPackStringList;
begin
   LookUps1.Checked:=True;
   SpeedButton3.Down:=True;
   CompType:='LookUp';
   SL:=GR.CreateGroupList(CompType);
   Selector1.Items.Assign(SL);
   SL.Free;
   Selector1.Selected:=SpeedButton3.Tag;
end;

procedure TComponentPalette.SpeedButton4Click(Sender: TObject);
var
   SL:TPackStringList;
begin
   PickLists1.Checked:=True;
   SpeedButton4.Down:=True;
   CompType:='PickList';
   SL:=GR.CreateGroupList(CompType);
   Selector1.Items.Assign(SL);
   SL.Free;
   Selector1.Selected:=SpeedButton4.Tag;
end;

procedure TComponentPalette.SpeedButton5Click(Sender: TObject);
var
   SL:TPackStringList;
begin
   Services1.Checked:=True;
   SpeedButton5.Down:=True;
   CompType:='Service';
   SL:=GR.CreateGroupList(CompType);
   Selector1.Items.Assign(SL);
   SL.Free;
   Selector1.Selected:=SpeedButton5.Tag;
end;

procedure TComponentPalette.SpeedButton6Click(Sender: TObject);
var
   SL:TPackStringList;
begin
   UserGroups1.Checked:=True;
   SpeedButton6.Down:=True;
   CompType:='UGroup';
   SL:=GR.CreateGroupList(CompType);
   Selector1.Items.Assign(SL);
   SL.Free;
   Selector1.Selected:=SpeedButton6.Tag;
end;

procedure TComponentPalette.SpeedButton7Click(Sender: TObject);
var
   SL:TPackStringList;
begin
   WSGroups1.Checked:=True;
   SpeedButton7.Down:=True;
   CompType:='WGroup';
   SL:=GR.CreateGroupList(CompType);
   Selector1.Items.Assign(SL);
   SL.Free;
   Selector1.Selected:=SpeedButton7.Tag;
end;

procedure TComponentPalette.SpeedButton8Click(Sender: TObject);
begin
   WaitBox.Caption:='Erase Registry...';
   WaitBox.Show;
   GR.EraseRegistry;
   WaitBox.Caption:='Fill Registry...';
   if GR.Count > 0 then
      GR.FillRegistry;
   WaitBox.Hide;
end;

procedure TComponentPalette.SpeedButton9Click(Sender: TObject);
begin
   PL.Clear;
   Selector1.Items.Clear;
   WaitBox.Caption:='Loading Values...';
   WaitBox.Show;                
   GR.LoadFromRegistry;
   WaitBox.Hide;
   SpeedButton1Click(SpeedButton1);
end;

procedure TComponentPalette.CompilerOptions1Click(Sender: TObject);
begin
   MainForm.CompilerOptions1Click(Sender);
end;

procedure TComponentPalette.Selector1Rename(Sender: TSelector; OldName,
  NewName: String);
var
   I:Integer;
begin
   for I:=0 to GR.Count-1 do
       if GR.Item[I].Group = OldName then
          GR.Item[I].Group:=NewName;
end;

procedure TComponentPalette.Selector1Delete(Sender: TSelector; Name: String);
var
   I:Integer;
begin
   for I:=0 to GR.Count-1 do
       if GR.Item[I].Group = Name then
          GR.Item[I].Group:='All';
end;

procedure TComponentPalette.Delete1Click(Sender: TObject);
begin
   GR.Delete(PL.Items[PL.ItemIndex]);
   PL.Items.Delete(PL.ItemIndex);
end;

procedure TComponentPalette.SpeedButton10Click(Sender: TObject);
var
   SL:TPackStringList;
begin
//   WSGroups1.Checked:=True;
   SpeedButton10.Down:=True;
   CompType:='Others';
   SL:=GR.CreateGroupList(CompType);
   Selector1.Items.Assign(SL);
   SL.Free;
   Selector1.Selected:=SpeedButton10.Tag;
end;

procedure TComponentPalette.SpeedButton11Click(Sender: TObject);
var
   Group:String;
   J:Integer;
begin
   if PL.SelCount = 0 then Exit;
   Group:=Selector1.Items[Selector1.Selected];
   for J:=0 to PL.Items.Count-1 do
      if PL.Selected[J] then
         BuildProg.Comps.AddObject(PL.Items[J],PL.Items.Objects[J]);
   BuildProg.CompType:=CompType;
   BuildProg.Group   :=Group;
   BuildProg.ShowModal;
end;

procedure TComponentPalette.FormActivate(Sender: TObject);
begin
   MainForm.CurrentProject:=Self;
end;

procedure TComponentPalette.FormShow(Sender: TObject);
begin
   MainForm.CurrentProject:=Self;
end;

procedure TComponentPalette.FormHide(Sender: TObject);
begin
   MainForm.CurrentProject:=nil;
end;

procedure TComponentPalette.DefaultDirectories1Click(Sender: TObject);
begin
   ProjOptions.ProjectName.Text:=ProjectName;
   ProjOptions.ShowModal;
   if ProjOptions.ModalResult = mrOK then
   begin
      ProjectName:=ProjOptions.ProjectName.Text;
   end;
end;

end.
