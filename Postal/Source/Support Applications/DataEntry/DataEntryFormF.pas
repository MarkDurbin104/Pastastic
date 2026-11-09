unit DataEntryFormF;

interface

uses
	DataEntryMainF,
	StringUtil,
	DragLabelU,
	ComCtrls,
	SavePosFormEx,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, DBCtrls, Db, DBTables, StdCtrls, Mask, Handles, Menus, Grids,
  DBGrids, RecentListU,DBCompressImageU, Buttons, ToolWin;

type

	TInPlaceEdit = class(TEdit)
  private
  	FStaticText : TStaticText;
    procedure SetStaticText(NewValue : TStaticText);
		procedure InPlaceKeyPress(Sender:TObject;var Key:Char);
		procedure InPlaceExit(Sender: TObject);
  public
  	constructor Create(AOwner : TComponent); override;
    property StaticText : TStaticText read FStaticText write SetStaticText ;
  end;

	TDataControl = class(TWinControl)
  end;

  TDataEntryFormForm = class(TSavePosForm)
    Table: TTable;
    DataSource: TDataSource;
    StretchHandle: TStretchHandle;
    ControlPopupMenu: TPopupMenu;
    DeleteMenu: TMenuItem;
    StatusBar: TStatusBar;
    DBToolBar: TToolBar;
    FirstSpeedButton: TSpeedButton;
    PreviousSpeedButton: TSpeedButton;
    NextSpeedButton: TSpeedButton;
    LastSpeedButton: TSpeedButton;
    AddSpeedButton: TSpeedButton;
    DelSpeedButton: TSpeedButton;
    PostSpeedButton: TSpeedButton;
    CancelSpeedButton: TSpeedButton;
    RefreshSpeedButton: TSpeedButton;
    SearchSpeedButton: TSpeedButton;
    procedure FormDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ControlDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ControlDragDrop(Sender, Source: TObject; X, Y: Integer);
		procedure ControlDblClick(Sender: TObject);
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClick(Sender: TObject);
    procedure StretchHandleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StretchHandleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DeleteMenuClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ControlEnter(Sender: TObject);
    procedure ControlExit(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FirstSpeedButtonClick(Sender: TObject);
    procedure PreviousSpeedButtonClick(Sender: TObject);
    procedure NextSpeedButtonClick(Sender: TObject);
    procedure LastSpeedButtonClick(Sender: TObject);
    procedure AddSpeedButtonClick(Sender: TObject);
    procedure DelSpeedButtonClick(Sender: TObject);
    procedure PostSpeedButtonClick(Sender: TObject);
    procedure CancelSpeedButtonClick(Sender: TObject);
    procedure RefreshSpeedButtonClick(Sender: TObject);
    procedure SearchSpeedButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FDesigning 													: Boolean;
    LastControlMouseDown 								: TPoint;	//last mouse down point for control resizing
    ResizingControl			 								: Boolean;	//whether control is being resized
		procedure SetDataSource(Sender, Source : TObject; X,Y : Integer);
    procedure SetDataField(DataControl 	: TWinControl; DataField : String);
    procedure SetTabOrder;

  protected
  	procedure SetDesigning(Value : Boolean);
  public
    { Public declarations }
    WindowMenuItem : TMenuItem;
    InPlaceEdit	: TInPlaceEdit;
		function SaveForm 	: Boolean;
  published
    property Designing 	: Boolean read FDesigning write SetDesigning;
  end;

var
  DataEntryFormForm: TDataEntryFormForm;

implementation

{$R *.DFM}

uses
ComponentUtil,
DataControlPaletteF;

constructor TInPlaceEdit.Create(AOwner : TComponent);
begin
	Inherited Create(AOwner);
  Name      	:= 'InPlaceEdit';
  Ctl3D      	:= False;
  BorderStyle	:= bsNone;
  Color      	:= clWindow;
  TabOrder   	:= 0;
  Enabled    	:= True;
  Left 			 	:= 0;
  Top         := 0;
  Width				:= 50;
  Height     	:= 17;
  OnExit     	:= InPlaceExit;
  OnKeyPress 	:= InPlaceKeyPress;
end;

procedure TInPlaceEdit.SetStaticText(NewValue : TStaticText);
begin
	If NewValue <> FStaticText then
  begin
  	FStaticText := NewValue;
    If FStaticText <> nil then
    begin
    	Left 			:= FStaticText.Left;
      Top 			:= FStaticText.Top;
      Width			:= FStaticText.Width;
      Height		:= FStaticText.Height;
      Text 			:= FStaticText.Caption;
      Visible 	:= True;
      SetFocus;
			SelectAll;
    end
    else
    begin
    	Visible := False;
    end;
  end;
end;

procedure TDataEntryFormForm.SetDesigning(Value : Boolean);
var
	ControlIndex : Integer;
begin
	If Value <> FDesigning then
  begin
  	FDesigning := Value;
    If FDesigning then Color := clWhite
    else Color := clBtnFace;
    
    //enable drag labels
    For ControlIndex := 0 to ControlCount -1 do
    begin
    	If Controls[ControlIndex] is TDragLabel then (Controls[ControlIndex] as TDragLabel).DragEnabled := FDesigning;
    end;
  end;

end;
procedure TDataEntryFormForm.FormDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
	SetDataSource(Sender, Source, X, Y);
end;

procedure TDataEntryFormForm.FormDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin

	Accept := False;
  If not Designing then Exit;
	If (Source is TTreeView) and ((Source as TTreeView).Name = 'DatabaseTreeView') //dragging from database tree
	or (Source is TControl) and ((Source as TControl).Parent = ControlPaletteForm.ToolBar) //dragging from control toolbar
  then
		Accept := True;

end;

procedure TDataEntryFormForm.SetTabOrder;
var
	ControlIndex : Integer;
  ControlList	: TStringList;
begin
	ControlList := TStringList.Create;
  try
    for ControlIndex := 0 to ControlCount do
    begin

    end;
  finally
  	ControlList.Free;
  end;

end;

procedure TDataEntryFormForm.ControlDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin

  If not Designing then Exit;
	Accept := False;
	If (Source is TTreeView)
  and ((Source as TTreeView).Name = 'DatabaseTreeView')
	and ((Source as TTreeView).Selected.Level = 2) //field
  then //dragging from database tree
		Accept := True;

end;

procedure TDataEntryFormForm.ControlDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
	SetDataSource(Sender, Source, X, Y);
end;

procedure TDataEntryFormForm.SetDataField(DataControl : TWinControl; DataField : String);
begin
  If DataControl.ClassType = TDBGrid then
  begin
    (DataControl as TDBGrid).DataSource 	:= DataSource;
  end
  else If DataControl.ClassType = TDBEdit then
  begin
    (DataControl as TDBEdit).DataSource 	:= DataSource;
    (DataControl as TDBEdit).DataField 	:= DataField;
  end
  else If DataControl.ClassType = TDBMemo then
  begin
    (DataControl as TDBMemo).DataSource 	:= DataSource;
    (DataControl as TDBMemo).DataField 	:= DataField;
  end
  else If DataControl.ClassType = TDBCompressImage then
  begin
    (DataControl as TDBCompressImage).DataSource := DataSource;
    (DataControl as TDBCompressImage).DataField 	:= DataField;
  end;
end;

procedure TDataEntryFormForm.ControlDblClick(Sender: TObject);
var
	SenderDragLabel  : TDragLabel;
begin
	If Designing and (Sender is TDragLabel) then
  begin
  	SenderDragLabel := Sender as TDragLabel;
    InPlaceEdit.StaticText := (SenderDragLabel as TStaticText);
		InPlaceEdit.BringToFront;
  end;
end;

procedure TDataEntryFormForm.ControlMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	DragLabel : TDragLabel;
begin
  If not Designing then Exit;
	If (Sender is TDragLabel) then
  begin
    DragLabel := Sender as TDragLabel;
    If Shift <> [] then DragLabel.Dragging := False;	//stop control dragging
    If (ssLeft in Shift)
    and (	(ssCtrl in Shift) or (ssShift in Shift)) then	//adding from selected
    begin
      StretchHandle.Attach(DragLabel);
      StretchHandle.Attach(DragLabel.FocusControl);
      //remove popup from attached controls
      DragLabel.PopupMenu := nil;
    end
  end
  else //assume data control
  begin
		If (Sender as TControl).Cursor <> crDefault then	//resizing
    begin
    	ResizingControl := True;
      LastControlMouseDown := Point(X,Y);
  	end;
  end;
end;

procedure TDataEntryFormForm.FormClick(Sender: TObject);
begin
  If not Designing then Exit;
	StretchHandle.Detach;
end;

procedure TDataEntryFormForm.StretchHandleMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	ChildIndex : Integer;
begin
  If not Designing then Exit;
  for ChildIndex :=  0 to StretchHandle.ChildCount-1  do
  begin
		StretchHandle.Children[ChildIndex].Refresh;
  end;
end;

procedure TDataEntryFormForm.StretchHandleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	ChildControl 	: TControl;
  ChildIndex 		: Integer;

	function ChildUnderPoint(P: TPoint): TControl;
  var
    i: integer;
    ARect: TRect;
    AControl: TControl;
  begin
		//determine whether X, Y is over any child  }
    Result := nil;
    for i := 0 to StretchHandle.ChildCount - 1 do
    begin
      AControl := TControl(StretchHandle.Children[i]);
      ARect := Rect(AControl.Left - 2,
                    AControl.Top - 2,
                    AControl.Left + AControl.Width + 2,
                    AControl.Top + AControl.Height + 2);
                                       { P is relative to the Parent }
      if PtInRect(ARect, P) then
        begin
          Result := TControl(StretchHandle.Children[i]);
          break;
        end;
    end;
  end;

begin
  If not Designing then Exit;
  If (ssLeft in Shift)
  and (	(ssCtrl in Shift) or (ssShift in Shift)) then	//removing from selected
  begin
		ChildControl := ChildUnderPoint(Point(StretchHandle.Left + X,StretchHandle.Top + Y));
    If ChildControl is TDragLabel then	//release label and datacontrol
    begin
    	StretchHandle.ReleaseChild(ChildControl);
			StretchHandle.ReleaseChild((ChildControl as TDragLabel).FocusControl);
      (ChildControl as TDragLabel).PopupMenu := ControlPopUpMenu;	//reassign popup
    end
    else If ChildControl <> nil then	//must be a data control
    begin
    	StretchHandle.ReleaseChild(ChildControl);
      //find data control
      For ChildIndex := 0 to StretchHandle.ChildCount-1 do
      begin
      	If (StretchHandle.Children[ChildIndex] is TDragLabel)
        and ((StretchHandle.Children[ChildIndex] as TDragLabel).FocusControl = ChildControl) then
	    		StretchHandle.ReleaseChild(StretchHandle.Children[ChildIndex] as TDragLabel);
      end;
    end
  end;
end;

procedure TDataEntryFormForm.DeleteMenuClick(Sender: TObject);
var
	DeleteControl : TControl;
begin
  If not Designing then Exit;
	If ControlPopupMenu.PopupComponent is TDragLabel then
  begin
		(ControlPopupMenu.PopupComponent as TDragLabel).FocusControl.Free;
		(ControlPopupMenu.PopupComponent as TDragLabel).Free;
	end
  else If ControlPopupMenu.PopupComponent is TStretchHandle then
  begin
  	With ControlPopupMenu.PopupComponent as TStretchHandle do
    begin
      While ChildCount > 0 do
      begin
      	DeleteControl := Children[0] ;
	      ReleaseChild(DeleteControl);
        DeleteControl.Free;
      end;
    end;
  end;
end;

procedure TDataEntryFormForm.ControlMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
const
	RESIZE_MARGIN = 5;
var
	Control : TControl;
begin
  If not Designing then Exit;
	Control := (Sender as TControl);

  With Control do
  begin
    If ResizingControl = True then	//resizing
    begin
    	If (Control.Cursor = crSizeWE) or (Control.Cursor= crSizeNWSE) 	then Width	:= Width 	+ X-LastControlMouseDown.X;
      if (Control.Cursor = crSizeNS) or (Control.Cursor = crSizeNWSE) then Height := Height	+ Y-LastControlMouseDown.Y;
      LastControlMouseDown := Point(X, Y);
    end
    else
    begin
      //check for resize zone
      If 			(X >= ClientWidth-RESIZE_MARGIN) 	and (Y >= ClientHeight -RESIZE_MARGIN)	then Cursor := crSizeNWSE
      else if (X >= ClientWidth-RESIZE_MARGIN)	then Cursor := crSizeWE
      else if (Y >= ClientHeight-RESIZE_MARGIN)	then Cursor := crSizeNS
      else Cursor := crDefault;
    end;
  end;
end;

procedure TDataEntryFormForm.ControlMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  If not Designing then Exit;
	(Sender as TControl).Cursor := crDefault;
  ResizingControl := False;
end;

procedure TDataEntryFormForm.ControlEnter(Sender: TObject);
begin
  If not Designing then Exit;
	If (Sender is TDBMemo) then (Sender as TDBMemo).ScrollBars := ssBoth;
end;

procedure TDataEntryFormForm.ControlExit(Sender: TObject);
begin
  If not Designing then Exit;
	If (Sender is TDBMemo) then (Sender as TDBMemo).ScrollBars := ssNone;
end;

procedure TDataEntryFormForm.FormActivate(Sender: TObject);
begin
	DataEntryMainForm.ActiveDataEntryForm := self;
end;

function TDataEntryFormForm.SaveForm : Boolean;
var
	CompIndex 	: Integer;
	FileStream 	: TFileStream;
begin
	Result := True;
	//free any inplaceedit
  For CompIndex := ComponentCount -1  downto 0 do
  begin
  	If Components[CompIndex] is TInPlaceEdit then
			Components[CompIndex].Free;
  end;

	DataEntryMainForm.SaveDialog.Title := 'Save Form';
  If LeftString(Caption, 8) = 'UnTitled' then
  begin
    If (DataEntryMainForm.SaveDialog.Execute) then
      Caption := DataEntryMainForm.SaveDialog.FileName
    else
      Result := False;//
  end;

  WindowMenuItem.Caption := DelimitedString(WindowMenuItem.Caption,' ', False) //window number
  													+ ' ' + self.Caption;

  If LeftString(Caption, 8) <> 'UnTitled' then
  begin
    FileStream := TFileStream.Create(Caption, fmCreate);
    try
      FileStream.WriteComponent(self);
      DataEntryMainForm.RecentList.AddRecent(Caption);
    finally
      FileStream.Free;
    end;
  end;
end;

procedure TDataEntryFormForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin

  If (DataEntryMainForm.DesignFormSpeedButton.visible) and  (mrYes = MessageDlg('Save changes to form?', mtConfirmation, [mbYes, mbNo], 0)) then
  begin
    If not SaveForm then
    	CanClose := False;
  end;	//if save

	//remove menu item from window menu
  try
		DataEntryMainForm.WindowMenu.Remove(self.WindowMenuItem);
  except
  end;
  WindowMenuItem := nil;
end;

procedure TDataEntryFormForm.SetDataSource(Sender, Source : TObject; X,Y : Integer);
var
	DatabaseTreeView : TTreeView;
  NewDragLabel : TDragLabel;

  function NewControl(ControlClass : TWinControlClass; DataField : String) : TWinControl;
  begin
  	Result := nil;
  	//test and cast to valid control class
    If (ControlClass = TDBGrid) or (ControlClass = TDBEdit) or (ControlClass = TDBMemo) or (ControlClass = TDBCompressImage) then
    begin
    	NewDragLabel := TDragLabel.Create(self) ;
      With NewDragLabel do
      begin
        Parent 			:= self;
       	DragEnabled := True;
        AutoSize 		:= True;
      	Name 				:= ValidControlName(NewDragLabel);
      	OnDragOver 	:= ControlDragOver;
        OnDragDrop 	:= ControlDragDrop;
        OnMouseDown := ControlMouseDown;
        OnDblClick  := ControlDblClick;
        PopupMenu   := ControlPopUpMenu;
        If DataField <> '' then	Caption := DataField
        else Caption := Name;

        //special case
        If (ControlClass = TDBGrid) and (Table.TableName <> '')then Caption := Table.TableName;

      end;	///with TDragLabel

	    Result := ControlClass.Create(self);
      Result.Parent := self;
      If (Result is TDBMemo) then
      begin
      	(Result as TDBMemo).ScrollBars 	:= ssBoth;
				(Result as TDBMemo).WordWrap		:= True;
      end;
      Result.Name := ValidControlName(Result);
    	SetDataField(Result, DataField);
      TDataControl(Result).OnMouseMove 	:= ControlMouseMove;
      TDataControl(Result).OnMouseDown 	:= ControlMouseDown;
			TDataControl(Result).OnMouseUp 		:= ControlMouseUp;
			TDataControl(Result).OnEnter 			:= ControlEnter;
			TDataControl(Result).OnExit 			:= ControlExit;
			If (Sender is TDBMemo) then (Sender as TDBMemo).ScrollBars := ssBoth;

      With NewDragLabel do
      begin
	     	Enabled := FDesigning;
        FocusControl := Result;
        Left := X;
        Top  := Y;
        FocusControl.SetBounds(Left + Width + 10,
                                Top,
                                FocusControl.Width,
                                FocusControl.Height);
    	end;	//with NewDragLabel
		end;	//If ControlClass
  end;	//Function

begin
  If not Designing then Exit;

	//from table tree view
	If (Source is TTreeView) and ((Source as TTreeView).Name = 'DatabaseTreeView') then	//dragging from database tree
  begin
    DatabaseTreeView := (Source as TTreeView);
    Table.Active 	:= False;
    Case DatabaseTreeView.Selected.Level of
      0	:
      begin
      	Table.DatabaseName 				:= DatabaseTreeView.Selected.Text;
        StatusBar.Panels[0].Text	:= Table.DatabaseName;
      end;
      1	:
      begin
      	Table.DatabaseName 				:= DatabaseTreeView.Selected.Parent.Text;
        StatusBar.Panels[0].Text	:= Table.DatabaseName;
      	Table.TableName 					:= DatabaseTreeView.Selected.Text;
        StatusBar.Panels[1].Text	:= Table.TableName
      end;
      2	: //field
      begin
      	Table.DatabaseName 				:= DatabaseTreeView.Selected.Parent.Parent.Text;
        StatusBar.Panels[0].Text	:= Table.DatabaseName;
      	Table.TableName 					:= DatabaseTreeView.Selected.Parent.Text;
        StatusBar.Panels[1].Text	:= Table.TableName;

        If Sender is TDragLabel then	//update datafield
        begin
        	With (Sender as TDragLabel) do
          begin
            Caption := (Source as TTreeView).Selected.Text;
            FocusControl.SetBounds(Left + Width + 10,
                                    Top,
                                    FocusControl.Width,
                                    FocusControl.Height);
          	SetDataField(FocusControl, (Source as TTreeView).Selected.Text)
          end;

        end
        else	//new field
        begin
          NewControl(TDBEdit, DatabaseTreeView.Selected.Text);
          SetTabOrder;
        end;
      end;
    end;
  end;

  //from control palette
  If (Source is TControl) and ((Source as TControl).Parent = ControlPaletteForm.ToolBar) then
  begin
    NewControl(TWinControlClass(ControlPaletteForm.SelectedControlClass) ,'');
		SetTabOrder;
  end;

  //activate table
  If (Table.DatabaseName <> '') and (Table.TableName <> '') then
  	Table.Active := True;
end;

procedure TDataEntryFormForm.FirstSpeedButtonClick(Sender: TObject);
begin
	Table.First;
end;

procedure TDataEntryFormForm.PreviousSpeedButtonClick(Sender: TObject);
begin
	Table.Prior;
end;

procedure TDataEntryFormForm.NextSpeedButtonClick(Sender: TObject);
begin
	Table.Next;
end;

procedure TDataEntryFormForm.LastSpeedButtonClick(Sender: TObject);
begin
	Table.Last;
end;

procedure TDataEntryFormForm.AddSpeedButtonClick(Sender: TObject);
begin
	Table.Append;
end;

procedure TDataEntryFormForm.DelSpeedButtonClick(Sender: TObject);
begin
	Table.Delete;
end;

procedure TDataEntryFormForm.PostSpeedButtonClick(Sender: TObject);
begin
	Table.Post
end;

procedure TDataEntryFormForm.CancelSpeedButtonClick(Sender: TObject);
begin
	Table.Cancel;
end;

procedure TDataEntryFormForm.RefreshSpeedButtonClick(Sender: TObject);
begin
	Table.Refresh;
end;

procedure TDataEntryFormForm.SearchSpeedButtonClick(Sender: TObject);
var
	Component  			: TComponent;
	ComponentIndex 	: Integer;
	KeyFields 			: TStringList;
  KeyFieldsString	: String;
  KeyIndex				: Integer;
  KeyValues				: Variant;
  KeyValuesString	: String;

	procedure AddSearchItem(SearchFieldName, SearchFieldValue : String);
	begin
		If Trim(SearchFieldValue) <> '' then
    begin
    	KeyFields.Add(SearchFieldname);
      VarArrayRedim(KeyValues, KeyFields.Count-1);
      KeyValues[KeyFields.Count-1] := SearchFieldValue;
    end;
  end;

begin
  //prepare search storage
  KeyFields := TStringList.Create;
  try
	  KeyValues := VarArrayCreate([0, 0], varVariant);

		//build key fields that have been filled
    For ComponentIndex := 0  to ComponentCount -1 do
    begin
      Component := Components[ComponentIndex] ;
      If Component is TDBEdit then AddSearchItem((Component As TDBEdit).DataField, (Component As TDBEdit).Text)
      else If Component is TDBMemo then AddSearchItem((Component As TDBMemo).DataField, (Component As TDBMemo).Text);
    end;

    //build list of fields and values
    For KeyIndex := 0 to KeyFields.Count -1 do
    begin
			KeyFieldsString := KeyFieldsString + KeyFields[KeyIndex] + ';';
      KeyValuesString := KeyValuesString + KeyValues[KeyIndex] + ';';
    end;
    ShowMessage(KeyFieldsString + ' - ' + KeyValuesString);
	finally
  	KeyFields.Free;
  end;
end;


procedure TInPlaceEdit.InPlaceKeyPress(Sender:TObject;var Key:Char);
begin
	If FStaticText <> nil then
  begin
    if Key = #27 then
    begin
      Text := FStaticText.Caption;
			StaticText := nil;
    end
    else if Key = #13 then
    begin
    	FStaticText.Caption := Text;
      StaticText := nil;
      //PostMessage(InPlaceEdit.Handle,CM_EXIT,0,0); // Post call to InPlaceExit()
    end;
  end;
end;

procedure TInPlaceEdit.InPlaceExit(Sender: TObject);
begin
	If FStaticText <> nil then  FStaticText.Caption := Text;
	StaticText := nil;
end;

procedure TDataEntryFormForm.FormCreate(Sender: TObject);
begin
	InPlaceEdit := TInPlaceEdit.Create(self);
	InPlaceEdit.Parent := self;
	InPlaceEdit.Visible := False;
end;

end.
