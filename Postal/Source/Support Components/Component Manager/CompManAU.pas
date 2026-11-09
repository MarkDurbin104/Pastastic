{  <Synopsis>      Corvus Component Manager
   <Unit>          OLÉ Automation
   <Copyright(c)>  Postal Solutions Limited 1996..1998
   <Author>        MJD
   <Description>   Load and manage Corvus Components via the 
                   component loader
   <Modifications> 06/01/98 - MJD
                              Original Release
                   13/02/99 - MJD
                              Change Commenting format
}                          
unit CompManAU;
                                                     
interface

uses
  Forms, Controls, Classes,SubTree, ComObj, ActiveX, SysUtils,
  GPCSBase_TLB,GPCSBaseAU,GPCSGUID,ExtendedGroupU;
   
type
  THolder = Class
     Instance:IUnknown;
  end;
  TCompMan = class(TGPCSBaseComponent, ICompMan)
  private
    FAsToolBar:Boolean; // True if viewing as a Tool Bar
  public
    procedure Initialize; override;
    destructor Destroy; override;
  protected
    function LoadComponent(const Name: WideString): IUnknown; safecall;
    procedure Hide; safecall;
    procedure Show; safecall;
    function  Get_AsToolBar: WordBool; safecall;
    procedure Set_AsToolBar(Value: WordBool); safecall;
    function Get_Ready:WordBool; safecall;
  end;

var
   QuickList:TStringList;
   MultiGroup:IExtGroup;

implementation

uses ComServ2,CompManFU;

{===============================================================================
  Class        TCompMan
  Method       initialize
  Description  Initialize instance
  Params       None
  Result       None
________________________________________________________________________________}
procedure TCompMan.Initialize;
begin
  inc(ReferenceCount);
  Logevent('Initialise : ' + IntToStr(ReferenceCount));
   if QuickList = nil then
      QuickList:=TStringList.Create;
   inherited Initialize;
end;
{===============================================================================
  Class        TCompMan
  Method       Destroy
  Description  Destroy instance
  Params       None
  Result       None
________________________________________________________________________________}
destructor TCompMan.Destroy;
begin
  Dec(ReferenceCount);
  Logevent('Destroy : ' + IntToStr(ReferenceCount));
   inherited Destroy;
end;
{===============================================================================
  Class        TCompMan
  Method       LoadComponent
  Description  Load a Corvus Component
  Params       Name - the name of the component
  Result       a variant of the component or unassigned on error
________________________________________________________________________________}
function TCompMan.Get_Ready:WordBool;
begin
   if (MainForm <> nil) and (MainForm.ComponentList <> nil) then
      Result:=MainForm.ComponentList.Ready
   else
      Result:=False;
end;
function TCompMan.LoadComponent(const Name: WideString): IUnknown;
var
   NameEntry:TGPCSRegistryEntry;
   Holder:THolder;
   I:Integer;
begin
  LogEvent('LoadComponent : ' + Name);
   if Name = 'Empty' then
   begin
      if QuickList <> nil then
      begin
         for I:=0 to QuickList.Count-1 do
         begin
            Holder:=THolder(QuickList.Objects[I]);
            Holder.Instance:=nil;
            Holder.Free;
         end;
         QuickList.Free;
         QuickList:=nil;
      end;
      MultiGroup:=nil;
      CompLoad:=nil;
//      MainForm.ComponentList.ReleaseAll;
      Exit;
   end;
   I:=QuickList.IndexOf(Name);
   if I = -1 then
   begin
      if UpperCase(Copy(Name,1,5)) = 'GROUP' then
      begin
         try
            if MultiGroup = nil then
               MultiGroup:=CreateOleObject('Group.Multi') as IExtGroup;
            MultiGroup.SetProgID(Name);
            Result:=MultiGroup;
         except
            NameEntry:=MainForm.ComponentList.GetNamedNode(Name); // Get the Reg Entry
            if NameEntry <> nil then     // if the name is valid
              Result:=NameEntry.Instance // return the instance
            else
              Result:=nil;        // or unassinged for error
            Holder:=THolder.Create;
            Holder.Instance:=Result;
            QuickList.AddObject(Name,Holder);
         end;
      end
      else
      begin
         NameEntry:=MainForm.ComponentList.GetNamedNode(Name); // Get the Reg Entry
         if NameEntry <> nil then     // if the name is valid
           Result:=NameEntry.Instance // return the instance
         else
           Result:=nil;        // or unassinged for error
         Holder:=THolder.Create;
         Holder.Instance:=Result;
         QuickList.AddObject(Name,Holder);
      end;
   end
   else
   begin
      Result:=THolder(QuickList.Objects[I]).Instance;// return the instance
   end;
end;    
{===============================================================================
  Class        TCompMan
  Method       Show
  Description  Show form with list of ProgID's
  Params       None
  Result       None
________________________________________________________________________________}
procedure TCompMan.Show;
begin
   MainForm.Visible:=True;                       // show form
   if MainForm.ShowCL.Tag = 1 then               // currently showing component loader ?
      MainForm.ComponentList.ShowCompLoad(True); // the show 
end;

{===============================================================================
  Class        TCompMan
  Method       Hide
  Description  Hide form with list of ProgID's
  Params       None
  Result       None
________________________________________________________________________________}
procedure TCompMan.Hide;
begin
   MainForm.Visible:=False;                       // hide form
   if MainForm.ShowCL.Tag = 1 then                // currently showing component loader ?
      MainForm.ComponentList.ShowCompLoad(False); // then hide
end;

{===============================================================================
  Class        TCompMan
  Method       Get_AsToolBar
  Description  Get View as Tool Bar Flag
  Params       None
  Result       None
________________________________________________________________________________}
function TCompMan.Get_AsToolBar: WordBool;
begin
   Result:=FAsToolBar; 
end;

{===============================================================================
  Class        TCompMan
  Method       Set_AsToolBar
  Description  Set View as Tool Bar Flag and set form to view as toolbar
  Params       None
  Result       None
________________________________________________________________________________}
procedure TCompMan.Set_AsToolBar(Value: WordBool);
begin
   if FAsToolBar <> Value then // if not already set
   begin
      FAsToolBar:=Value;       // set internal flag
      if FAsToolBar then
      begin
         MainForm.Panel1.Visible:=False;     // hide the top controls
         MainForm.BorderStyle:=bsToolWindow; // change to tool window 
      end
      else
      begin
         MainForm.Panel1.Visible:=True;      // show the top controls
         MainForm.BorderStyle:=bsSizeable;   // change to normal window 
      end;
   end;  
end;

initialization
  TGPCSCompFactory.Create(ComServer,TCompMan,Class_GPCSCompMan,
                          'Support.CompMan','GPCS Component Manager',
                          ciMultiInstance);
end.
