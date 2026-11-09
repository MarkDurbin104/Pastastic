{  <Synopsis>      Corvus Component Loader
   <Unit>          OLE Automation
   <Copyright(c)>  Postal Solutions Limited 1996..1998
   <Author>        MJD
   <Description>   Implement all Component Loading Functions for Corvus
                   by loading COM objects via GUID and returning variant
                   references to each component.
                   When a maximum number of components (MaxLoad) is Loaded
                   start a new version of self to load additional components
   <Modifications> 06/01/98 - MJD
                              Original Release
                   13/02/99 - MJD
                              Change Commenting format
________________________________________________________________________________}

unit CompLoadAU;

interface

uses
  SysUtils,
  Classes,ComObj,GPCSBase_TLB,CompLoadFU,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode;
  
const
   MaxLoad = 50; // Number of components Loaded before new instance started
   
type
  TCompLoad = class(TGPCSBaseComponent, ICompLoad)
  private
    List:TStringList;                      // list of GUID's Loaded
    VarList:Array[0..MaxLoad] of IUnknown; // list of Variants for GUID's Loaded
    NextCompLoad:ICompLoad;                // subordinate loader or nil
  protected
    function LoadComponent(const GUID: WideString): IUnknown; safecall;
    procedure Show; safecall;   // show form with list of ProgID's
    procedure Hide; safecall;   // hide form with list of ProgID's
  end;

implementation

uses ComServ2; // for Class Factory

{===============================================================================
  <Synopsis>     Load a component
  <Description>  Load a component given it's GUID and return a variant 
                 referencing it's instance
  <GUID>         Globaly Unique IDentifier of the component to load
  <Result>       Loaded component or (nil) on error
________________________________________________________________________________}
function TCompLoad.LoadComponent(const GUID: WideString): IUnknown;
var
   Index:Integer;     // index of GUID in list of loaded components
   Instance:IUnknown;  // temp var for loading component 
begin
   if List = nil then            // first use? 
      List:=TStringList.Create;  // then create list to hold GUID's
   
   Index:=List.IndexOf(GUID);   // get index of GUID from list
   
   if (Index = -1) and (List.Count = MaxLoad) then  // reached maximum for this executable ?
   begin
      if NextCompLoad = nil then                // if we dont have a subordinate
      begin
         NextCompLoad:=CreateCompLoad;          // then create one
         if MainForm.Visible then                          // and it's visible state
            NextCompLoad.Show
         else
            NextCompLoad.Hide;
      end;
      
      Result:=NextCompLoad.LoadComponent(GUID); // now pass on request to subordinate
      Exit;                                     // we're done
   end;
   
   if Index = -1 then // if this is a new component
   begin
      try
         Instance:=CreateComObject(StringToGUID(GUID)); // load it!
         Index:=List.Add(GUID);                         // add the GUID to the list
         VarList[Index]:=Instance;                      // add the variant to the list
         // update list in form
         MainForm.ProgIDList.Items.Add(ClassIDToProgID(StringToGUID(GUID))); 
         Result:=VarList[Index];
      except // error loading component !
        On E: Exception do
        begin
          RaiseGUIDException('{35CE4A81-6947-44B4-907D-7E576A498C8B}', E);
          RaiseError($03010101,2,2,ClassIDToProgID(StringToGUID(GUID))+' '+GUID);
          // update list in form with error
          MainForm.ProgIDList.Items.Add('? '+ClassIDToProgID(StringToGUID(GUID)));
          Result:=nil; // set result for error
        end;
      end;
   end
   else // we have previously loaded this component
   begin
      Result:=VarList[Index];
   end;
end; 

{===============================================================================
  <Synopsis>     Show form with list of ProgID's
  <Description>  Show form with list of ProgID's
________________________________________________________________________________}
procedure TCompLoad.Show;
begin
   if NextCompLoad <> nil then NextCompLoad.Show; // show subordinates
   MainForm.Visible:=True;                        // show form
end;

{===============================================================================
  <Synopsis>   Hide form with list of ProgID's
  <Description>  Hide form with list of ProgID's
________________________________________________________________________________}
procedure TCompLoad.Hide;
begin
   if NextCompLoad <> nil then NextCompLoad.Hide; // hide subordinates
   MainForm.Visible:=False;                       // hide form
end;

initialization
  TGPCSCompFactory.Create(ComServer,TCompLoad,Class_GPCSCompLoad,
                          'Support.Compload','GPCS Component Loader',
                          ciSingleInstance);
end.
