unit WinForm;

interface

uses
  System.Drawing, System.Collections, System.ComponentModel,
  System.Windows.Forms, System.Data, System.Resources;

type
  TWinForm = class(System.Windows.Forms.Form)
  {$REGION 'Designer Managed Code'}
  strict private
    /// <summary>
    /// Required designer variable.
    /// </summary>
    components: System.ComponentModel.IContainer;
    NotifyIcon1: System.Windows.Forms.NotifyIcon;
    ContextMenu1: System.Windows.Forms.ContextMenu;
    MenuItem1: System.Windows.Forms.MenuItem;
    MenuItem2: System.Windows.Forms.MenuItem;
    TrackBar1: System.Windows.Forms.TrackBar;
    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    procedure InitializeComponent;
    procedure NotifyIcon1_Click(sender: System.Object; e: System.EventArgs);
    procedure MenuItem2_Click(sender: System.Object; e: System.EventArgs);
    procedure MenuItem1_Click(sender: System.Object; e: System.EventArgs);
    procedure ContextMenu1_Popup(sender: System.Object; e: System.EventArgs);
    procedure TrackBar1_ValueChanged(sender: System.Object; e: System.EventArgs);
  {$ENDREGION}
  strict protected
    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    procedure Dispose(Disposing: Boolean); override;
  private
    procedure ToggleState;
    { Private Declarations }
  public
    constructor Create;
  end;

  [assembly: RuntimeRequiredAttribute(TypeOf(TWinForm))]

implementation

{$AUTOBOX ON}

{$REGION 'Windows Form Designer generated code'}
/// <summary>
/// Required method for Designer support -- do not modify
/// the contents of this method with the code editor.
/// </summary>
procedure TWinForm.InitializeComponent;
type
  TArrayOfSystem_Windows_Forms_MenuItem = array of System.Windows.Forms.MenuItem;
var
  resources: System.Resources.ResourceManager;
begin
  Self.components := System.ComponentModel.Container.Create;
  resources := System.Resources.ResourceManager.Create(TypeOf(TWinForm));
  Self.NotifyIcon1 := System.Windows.Forms.NotifyIcon.Create(Self.components);
  Self.ContextMenu1 := System.Windows.Forms.ContextMenu.Create;
  Self.MenuItem2 := System.Windows.Forms.MenuItem.Create;
  Self.MenuItem1 := System.Windows.Forms.MenuItem.Create;
  Self.TrackBar1 := System.Windows.Forms.TrackBar.Create;
  (System.ComponentModel.ISupportInitialize(Self.TrackBar1)).BeginInit;
  Self.SuspendLayout;
  // 
  // NotifyIcon1
  // 
  Self.NotifyIcon1.ContextMenu := Self.ContextMenu1;
  Self.NotifyIcon1.Icon := (System.Drawing.Icon(resources.GetObject('NotifyI' +
    'con1.Icon')));
  Self.NotifyIcon1.Text := 'NotifyIcon1';
  Self.NotifyIcon1.Visible := True;
  Include(Self.NotifyIcon1.Click, Self.NotifyIcon1_Click);
  // 
  // ContextMenu1
  // 
  Self.ContextMenu1.MenuItems.AddRange(TArrayOfSystem_Windows_Forms_MenuItem.Create(Self.MenuItem2, 
          Self.MenuItem1));
  Include(Self.ContextMenu1.Popup, Self.ContextMenu1_Popup);
  // 
  // MenuItem2
  // 
  Self.MenuItem2.Index := 0;
  Self.MenuItem2.Text := '&Hide';
  Include(Self.MenuItem2.Click, Self.MenuItem2_Click);
  // 
  // MenuItem1
  // 
  Self.MenuItem1.Index := 1;
  Self.MenuItem1.Text := 'E&xit';
  Include(Self.MenuItem1.Click, Self.MenuItem1_Click);
  // 
  // TrackBar1
  // 
  Self.TrackBar1.LargeChange := 20;
  Self.TrackBar1.Location := System.Drawing.Point.Create(32, 8);
  Self.TrackBar1.Maximum := 100;
  Self.TrackBar1.Name := 'TrackBar1';
  Self.TrackBar1.Size := System.Drawing.Size.Create(216, 45);
  Self.TrackBar1.TabIndex := 0;
  Self.TrackBar1.TickStyle := System.Windows.Forms.TickStyle.Both;
  Self.TrackBar1.Value := 50;
  Include(Self.TrackBar1.ValueChanged, Self.TrackBar1_ValueChanged);
  // 
  // TWinForm
  // 
  Self.AutoScaleBaseSize := System.Drawing.Size.Create(5, 13);
  Self.ClientSize := System.Drawing.Size.Create(292, 266);
  Self.ControlBox := False;
  Self.Controls.Add(Self.TrackBar1);
  Self.Icon := (System.Drawing.Icon(resources.GetObject('$this.Icon')));
  Self.Name := 'TWinForm';
  Self.Opacity := 0.400000005960464;
  Self.TopMost := True;
  (System.ComponentModel.ISupportInitialize(Self.TrackBar1)).EndInit;
  Self.ResumeLayout(False);
end;
{$ENDREGION}

procedure TWinForm.Dispose(Disposing: Boolean);
begin
  if Disposing then
  begin
    if Components <> nil then
      Components.Dispose();
  end;
  inherited Dispose(Disposing);
end;

constructor TWinForm.Create;
begin
  inherited Create;
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent;
  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  ToggleState;
end;

procedure TWinForm.TrackBar1_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  Self.Opacity:=TrackBar1.Value/100;
end;

procedure TWinForm.ContextMenu1_Popup(sender: System.Object; e: System.EventArgs);
begin

end;

procedure TWinForm.MenuItem1_Click(sender: System.Object; e: System.EventArgs);
begin
  Close;
end;
procedure TWinForm.ToggleState;
begin
  if Visible then
    MenuItem2.Text := '&Show'
  else
    MenuItem2.Text := '&Hide';

  Visible:=not Visible;
end;
procedure TWinForm.MenuItem2_Click(sender: System.Object; e: System.EventArgs);
begin
    ToggleState;
end;

procedure TWinForm.NotifyIcon1_Click(sender: System.Object; e: System.EventArgs);
begin

end;

end.
