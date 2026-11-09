unit SavePosFormU;

interface
uses
  ComCtrls,
  StdCtrls,
  Controls,
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

procedure Register;

implementation

constructor TSavePosForm.Create(AOwner : TComponent);
var
  Registry : TRegistry;
  CompIndex : Integer;
  CurrControl: TControl;
  Index : Integer;
begin
  inherited ;
  If not FRevertToDesign then
  begin
    Registry := TRegistry.Create;
    with Registry do
    begin
      RootKey:=HKEY_CURRENT_USER;
      if OpenKey('\SOFTWARE\PSL\FORMPOS\'+Application.Title+'\'+Name,False) then
      begin
        //get form coords
        SetBounds(ReadInteger('Left'),
                  ReadInteger('Top'),
                  ReadInteger('Width'),
                  ReadInteger('Height'));

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
          If Components[CompIndex] is TControl then
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

            If CurrControl is TToolButton then
              If ValueExists('Down') then
                (CurrControl As TToolButton).Down := ReadBool('Down');

            If CurrControl is TComboBox then
              If ValueExists('Items.CommaText') then
                (CurrControl As TComboBox).Items.CommaText := ReadString('Items.CommaText');

          end;  //if is TControl
        end;  //for all comps
      end;  //if openkey
      Registry.Free;
    end;  //With registry
  end;  //if nor revertto design
end;


destructor TSavePosForm.Destroy;
var
  CompIndex : Integer;
  CurrControl : TControl;
  Index : Integer;
  Registry : TRegistry;
begin
  Registry := TRegistry.Create ;
  with Registry do
  begin
    RootKey:=HKEY_CURRENT_USER;
    If Registry.KeyExists('\SOFTWARE\PSL\FORMPOS\' + Application.Title + '\' + Name) then
      Registry.DeleteKey('\SOFTWARE\PSL\FORMPOS\' + Application.Title + '\' + Name);  //start afresh
    if OpenKey('\SOFTWARE\PSL\FORMPOS\' + Application.Title + '\' + Name,True) then
    begin
      WriteInteger('Left',Left);
      WriteInteger('Top',Top);
      WriteInteger('Width',Width);
      WriteInteger('Height',Height);
    end;

    //try all components
    For CompIndex := 0 to ComponentCount -1 do
    begin
      If Components[CompIndex] is TControl then
      begin
        CurrControl := Components[CompIndex] as TControl;
        If OpenKey('\SOFTWARE\PSL\FORMPOS\'+Application.Title+'\'+Name + '\'
                   + CurrControl.Name,True) then
        begin
          WriteInteger('Left',CurrControl.Left);
          WriteInteger('Top',CurrControl.Top);
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
          If CurrControl is TToolButton then
            WriteBool('Down', (CurrControl As TToolButton).Down);
          If CurrControl is TComboBox then
            WriteString('Items.CommaText',(CurrControl As TComboBox).Items.CommaText);

        end;//if openkey
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
