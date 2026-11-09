unit SavePosFormEx;

interface
uses
  FileCtrl,
  Grids,
  ComCtrls,
  DBGrids,
  StdCtrls,
  Controls,
  Spin,
  Windows,Forms,Registry,Classes,SysUtils;
const
  SM_CMONITORS    = 80;

type
  TSavePosForm=class(TForm)
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  private
    FRevertToDesign : Boolean;
  published
    property RevertToDesign : Boolean read FRevertToDesign write FRevertToDesign;
  end;

  //enables text saving for custom combo boxes
  TMyCustomComboBox = class (TCustomComboBox)
  public
    property Text;
  end;

procedure Register;

implementation

constructor TSavePosForm.Create(AOwner : TComponent);
var
  Registry : TRegistry;
  CompIndex : Integer;
  CurrControl: TControl;
  Index : Integer;
  SaveVisible : Boolean;
  StringStream : TStringStream;
begin
  inherited ;
  SaveVisible := Visible;
  Visible := False;
  If not FRevertToDesign then
  begin
    Registry := TRegistry.Create;
    with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      if OpenKey('\SOFTWARE\PSL\FORMPOS\'+Application.Title+'\'+Name,False) then
      begin
        //check date
        if ValueExists('EXEDate') then
          If ReadDate('EXEDate') <> FileDateToDateTime(FileAge(Application.ExeName)) then
            Exit;
        //get form coords
        SetBounds(ReadInteger('Left'),
                  ReadInteger('Top'),
                  ReadInteger('Width'),
                  ReadInteger('Height'));

        //change to last directory
        ChDir(ReadString('LastDir'));

        if GetSystemMetrics(SM_CMONITORS) < 2 then
        begin
           if Left+Width > Screen.Width  then Left:=Screen.Width-Width;
           if Top+Height > Screen.Height then Top:=Screen.Height-Height;
           if Left < 0 then Left:=0;
           if Top < 0 then Top:=0;
        end;

        //try all components
        For CompIndex := 0 to self.ComponentCount -1 do
        begin
          If (Components[CompIndex] is TControl)then
          begin
            CurrControl := Components[CompIndex] as TControl;
            If OpenKey('\SOFTWARE\PSL\FORMPOS\'+Application.Title+'\'+Name + '\' +
                        CurrControl.Name,False) then
            begin
              CurrControl.SetBounds(ReadInteger('Left'),
                                    ReadInteger('Top'),
                                    CurrControl.Width,
                                    CurrControl.Height);

            end;

            //specific controls
            If CurrControl Is TEdit then
              if ValueExists('Text') then
                (CurrControl As TEdit).Text := ReadString('Text');

            If CurrControl Is TMemo then
              if ValueExists('Text') then
                (CurrControl As TMemo).Text := ReadString('Text');

            If CurrControl is TCheckBox then
              If ValueExists('Checked') then
                (CurrControl As TCheckBox).Checked := ReadBool('Checked');

            If CurrControl is TDirectoryListBox then
              If ValueExists('Directory') then
                (CurrControl As TDirectoryListBox).Directory := ReadString('Directory');

            If CurrControl is TRadioButton then
              If ValueExists('Checked') then
                (CurrControl As TRadioButton).Checked := ReadBool('Checked');

            If CurrControl is TPageControl then
              If ValueExists('ActivePageIndex') then
                (CurrControl As TPageControl).ActivePage := (CurrControl As TPageControl).Pages[ReadInteger('ActivePageIndex')];

            If CurrControl is TListView then  //read viewstyle and column positions
            begin
              If ValueExists('ViewStyle') then
                (CurrControl As TListView).ViewStyle := TViewStyle(ReadInteger('ViewStyle'));
              //read column values
              For Index := 0 to (CurrControl As TListView).Columns.Count -1 do
              begin
                If ValueExists(Format('Col%2d',[Index])) then
                  (CurrControl As TListView).Columns[Index].Width := ReadInteger(Format('Col%2d',[Index]));
              end;
            end;

            If CurrControl is TSpinEdit then
              If ValueExists('Value') then
                (CurrControl As TSpinEdit).Value := ReadInteger('Value');

            If CurrControl is TStringGrid then  //read column positions
            begin
              //read column values
              For Index := 0 to (CurrControl As TStringGrid).ColCount -1 do
              begin
                If ValueExists(Format('Col%2d',[Index])) then
                  (CurrControl As TStringGrid).ColWidths[Index] := ReadInteger(Format('Col%2d',[Index]));

              end;
            end;

            If CurrControl is TToolButton then
              If ValueExists('Down') then
                (CurrControl As TToolButton).Down := ReadBool('Down');

            If CurrControl is TCustomComboBox then
            begin
              If ValueExists('Items.CommaText') then
                TMyCustomComboBox(CurrControl).Items.CommaText := ReadString('Items.CommaText');
              If ValueExists('Text') then
                TMyCustomComboBox(CurrControl).Text := ReadString('Text');
            end;

            If CurrControl is TDriveComboBox then
              If ValueExists('Drive') then
                (CurrControl As TDriveComboBox).Drive := ReadString('Drive')[1];

            If (CurrControl is TCustomTreeView) then
            begin
              If ValueExists('Items') then
              begin
                StringStream := TStringStream.Create(ReadString('Items'));
                try
                  (CurrControl as TCustomTreeView).LoadFromStream(StringStream);
                finally
                  StringStream.Free;
                end;
              end;
            end;


          end;  //if is TControl
        end;  //for all comps
      end;  //if openkey
      Registry.Free;
    end;  //With registry
  end;  //if nor revertto design
  Visible := SaveVisible;
end;


destructor TSavePosForm.Destroy;
var
  CompIndex : Integer;
  CurrControl : TControl;
  Index : Integer;
  Registry : TRegistry;
  StringStream : TStringStream;
begin
  Registry := TRegistry.Create ;
  with Registry do
  begin
    RootKey:=HKEY_CURRENT_USER;
    If Registry.KeyExists('\SOFTWARE\PSL\FORMPOS\' + Application.Title + '\' + Name) then
      Registry.DeleteKey('\SOFTWARE\PSL\FORMPOS\' + Application.Title + '\' + Name);  //start afresh

    if OpenKey('\SOFTWARE\PSL\FORMPOS\' + Application.Title + '\' + Name,True) then
    begin
    	WriteDate('EXEDate', FileDateToDateTime(FileAge(Application.ExeName)));
      WriteInteger('Left',Left);
      WriteInteger('Top',Top);
      WriteInteger('Width',Width);
      WriteInteger('Height',Height);
    end;

    WriteString('LastDrive', ExtractFilePath(Application.ExeName)[1]);
		WriteString('LastDir', 	ExtractFilePath(Application.ExeName));
    //try all components
    For CompIndex := 0 to ComponentCount -1 do
    begin
      If Components[CompIndex] is TControl then
      begin
        CurrControl := Components[CompIndex] as TControl;
        If CurrControl.Name <> '' then
        begin
          If OpenKey('\SOFTWARE\PSL\FORMPOS\'+Application.Title+'\'+Name + '\'
                     + CurrControl.Name,True) then
          begin
            WriteInteger('Left',CurrControl.Left);
            WriteInteger('Top',CurrControl.Top);
            If CurrControl is TDirectoryListBox then
              WriteString('Directory', (CurrControl As TDirectoryListBox).Directory);
            If CurrControl is TDriveComboBox then
              WriteString('Drive', (CurrControl As TDriveComboBox).Drive);
            If CurrControl Is TEdit then
              WriteString('Text',(CurrControl As TEdit).Text);
            If CurrControl Is TMemo then
              WriteString('Text',(CurrControl As TMemo).Text);
            If CurrControl is TCheckBox then
              WriteBool('Checked', (CurrControl As TCheckBox).Checked);
            If CurrControl is TRadioButton then
              WriteBool('Checked', (CurrControl As TRadioButton).Checked);
            If CurrControl is TPageControl then
              WriteInteger('ActivePageIndex', (CurrControl As TPageControl).ActivePage.PageIndex);
            If CurrControl is TListView then  //write viewstyle and column positions
            begin
              WriteInteger('ViewStyle', Integer((CurrControl As TListView).ViewStyle));
              //write column values
              For Index := 0 to (CurrControl As TListView).Columns.Count -1 do
                WriteInteger(Format('Col%2d',[Index]),Integer((CurrControl As TListView).Columns[Index].Width));
            end;

            If CurrControl is TSpinEdit then
            	WriteInteger('Value', (CurrControl As TSpinEdit).Value);

            If CurrControl is TStringGrid then  //write column positions
            begin
              For Index := 0 to (CurrControl As TStringGrid).ColCount -1 do
                WriteInteger(Format('Col%2d',[Index]),Integer((CurrControl As TStringGrid).ColWidths[Index]));
            end;
            If CurrControl is TToolButton then
              WriteBool('Down', (CurrControl As TToolButton).Down);
            If CurrControl is TCustomComboBox then
            begin
              WriteString('Items.CommaText',(CurrControl As TCustomComboBox).Items.CommaText);
              WriteString('Text', TMyCustomComboBox(CurrControl).Text);
            end;
            If (CurrControl is TCustomTreeView) then
            begin
              StringStream := TStringStream.Create('');
              try
                (CurrControl as TCustomTreeView).SaveToStream(StringStream);
                WriteString('Items', StringStream.DataString);
              finally
                StringStream.Free;
              end;
            end;

          end;//if openkey
        end;  //if currcontrol has  a name
      end;//is TControl

     end;  //for all comps
     Registry.Free;
  end;
  inherited Destroy;
end;

procedure Register;
begin
//  RegisterCustomFormClass(TSAvePosForm);
end;

end.
