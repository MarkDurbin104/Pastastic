unit MBlockFU;

interface

{$A-}

uses
  System.Drawing, System.Collections, System.ComponentModel,
  System.Windows.Forms, System.Data,Borland.Vcl.SysUtils;

type
  TWinForm1 = class(System.Windows.Forms.Form)
  {$REGION 'Designer Managed Code'}
  strict private
    /// <summary>
    /// Required designer variable.
    /// </summary>
    Components: System.ComponentModel.Container;
    Button1: System.Windows.Forms.Button;
    /// <summary>
    /// Required method for Designer support - do not modify
    /// the contents of this method with the code editor.
    /// </summary>
    procedure InitializeComponent;
    procedure Button1_Click(sender: System.Object; e: System.EventArgs);
  {$ENDREGION}
  strict protected
    /// <summary>
    /// Clean up any resources being used.
    /// </summary>
    procedure Dispose(Disposing: Boolean); override;
  private
    { Private Declarations }
  public
    constructor Create;
  end;

  TMBState = set of (mbStartBlock,mbEndBlock,mbValid,mbArchived);

  TMBDataBlock = Array[0..999] of Byte;

  TMBRecord = packed record
    Version     :Byte  ;
    OperatorCode:Byte  ;
    OfficeCode  :UInt16;
    WSCode      :Byte  ;
    BlockCode   :UInt32;
    Period      :UInt16;
    LiveFor     :UInt16;
    MType       :Byte  ;
    MLength     :UInt16;
    Status      :UInt16;
    Reserved    :UInt32;
    Data        :array[0..249] of Integer;
    CRC         :UInt16;
  end;

  TMessageBlock = Class
    private
      FMR:TMBRecord;
    public
      procedure set_BlockCode(const Value: UInt32);
      procedure set_CRC(const Value: UInt16);
      procedure set_Data(const Value:String);
      procedure set_LiveFor(const Value: UInt16);
      procedure set_MLength(const Value: UInt16);
      procedure set_MType(const Value: Byte);
      procedure set_OfficeCode(const Value: UInt16);
      procedure set_OperatorCode(const Value: Byte);
      procedure set_Period(const Value: UInt16);
      procedure set_Reserved(const Value: UInt32);
      procedure set_Status(const Value: TMBState);
      procedure set_Version(const Value: Byte);
      procedure set_WSCode(const Value: Byte);
      function  get_Version     :Byte  ;
      function  get_OperatorCode:Byte  ;
      function  get_OfficeCode  :UInt16;
      function  get_WSCode      :Byte  ;
      function  get_BlockCode   :UInt32;
      function  get_Period      :UInt16;
      function  get_LiveFor     :UInt16;
      function  get_MType       :Byte  ;
      function  get_MLength     :UInt16;
      function  get_Status      :TMBState;
      function  get_Reserved    :UInt32;
      function  get_Data        :String;
      function  get_CRC         :UInt16;
      property Version     :Byte      read get_Version      write set_Version;
      property OperatorCode:Byte      read get_OperatorCode write set_OperatorCode;
      property OfficeCode  :UInt16    read get_OfficeCode   write set_OfficeCode;
      property WSCode      :Byte      read get_WSCode       write set_WSCode;
      property BlockCode   :UInt32    read get_BlockCode    write set_BlockCode;
      property Period      :UInt16    read get_Period       write set_Period;
      property LiveFor     :UInt16    read get_LiveFor      write set_LiveFor;
      property MType       :Byte      read get_MType        write set_MType;
      property MLength     :UInt16    read get_MLength      write set_MLength;
      property Status      :TMBState  read get_Status       write set_Status;
      property Reserved    :UInt32    read get_Reserved     write set_Reserved;
      property Data        :String    read get_Data         write set_Data;
      property CRC         :UInt16    read get_CRC          write set_CRC;
      property MBlock      :TMBRecord read FMR              write FMR;
  end;


  [assembly: RuntimeRequiredAttribute(TypeOf(TWinForm1))]

implementation

{$AUTOBOX ON}

{$REGION 'Windows Form Designer generated code'}
/// <summary>
/// Required method for Designer support -- do not modify
/// the contents of this method with the code editor.
/// </summary>
procedure TWinForm1.InitializeComponent;
begin
  Self.Button1 := System.Windows.Forms.Button.Create;
  Self.SuspendLayout;
  // 
  // Button1
  // 
  Self.Button1.Location := System.Drawing.Point.Create(32, 16);
  Self.Button1.Name := 'Button1';
  Self.Button1.TabIndex := 0;
  Self.Button1.Text := 'Button1';
  Include(Self.Button1.Click, Self.Button1_Click);
  // 
  // TWinForm1
  // 
  Self.AutoScaleBaseSize := System.Drawing.Size.Create(5, 13);
  Self.ClientSize := System.Drawing.Size.Create(292, 266);
  Self.Controls.Add(Self.Button1);
  Self.Name := 'TWinForm1';
  Self.Text := 'WinForm1';
  Self.ResumeLayout(False);
end;
{$ENDREGION}

procedure TWinForm1.Dispose(Disposing: Boolean);
begin
  if Disposing then
  begin
    if Components <> nil then
      Components.Dispose();
  end;
  inherited Dispose(Disposing);
end;

constructor TWinForm1.Create;
begin
  inherited Create;
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent;
  //
  // TODO: Add any constructor code after InitializeComponent call
  //
end;

procedure TWinForm1.Button1_Click(sender: System.Object; e: System.EventArgs);
begin
  Text:='MB State = '+IntToStr(SizeOf(TMBState))+
        'MB Record = '+IntToStr(SizeOf(TMBRecord));
end;

{ TMessageBlock }

function TMessageBlock.get_BlockCode: UInt32;
begin
   Result:=FMR.BlockCode;
end;

function TMessageBlock.get_CRC: UInt16;
begin
   Result:=FMR.CRC;
end;

function TMessageBlock.get_Data: String;
begin
//   Result:=FMR.Data;
end;

function TMessageBlock.get_LiveFor: UInt16;
begin
   Result:=FMR.LiveFor;
end;

function TMessageBlock.get_MLength: UInt16;
begin
   Result:=FMR.MLength;
end;

function TMessageBlock.get_MType: Byte;
begin
   Result:=FMR.MType;
end;

function TMessageBlock.get_OfficeCode: UInt16;
begin
   Result:=FMR.OfficeCode;
end;

function TMessageBlock.get_OperatorCode: Byte;
begin
   Result:=FMR.OperatorCode;
end;

function TMessageBlock.get_Period: UInt16;
begin
   Result:=FMR.Period;
end;

function TMessageBlock.get_Reserved: UInt32;
begin
   Result:=FMR.Reserved;
end;

function TMessageBlock.get_Status: TMBState;
begin
   Result:=TMBState(FMR.Status);
end;

function TMessageBlock.get_Version: Byte;
begin
   Result:=FMR.Version;
end;

function TMessageBlock.get_WSCode: Byte;
begin
   Result:=FMR.WSCode;
end;

procedure TMessageBlock.set_BlockCode(const Value: UInt32);
begin
  FMR.BlockCode := Value;
end;

procedure TMessageBlock.set_CRC(const Value: UInt16);
begin
  FMR.CRC := Value;
end;

procedure TMessageBlock.set_Data(const Value: String);
begin
//  FMR.Data :=;
end;

procedure TMessageBlock.set_LiveFor(const Value: UInt16);
begin
  FMR.LiveFor := Value;
end;

procedure TMessageBlock.set_MLength(const Value: UInt16);
begin
  FMR.MLength := Value;
end;

procedure TMessageBlock.set_MType(const Value: Byte);
begin
  FMR.MType := Value;
end;

procedure TMessageBlock.set_OfficeCode(const Value: UInt16);
begin
  FMR.OfficeCode := Value;
end;

procedure TMessageBlock.set_OperatorCode(const Value: Byte);
begin
  FMR.OperatorCode := Value;
end;

procedure TMessageBlock.set_Period(const Value: UInt16);
begin
  FMR.Period := Value;
end;

procedure TMessageBlock.set_Reserved(const Value: UInt32);
begin
  FMR.Reserved := Value;
end;

procedure TMessageBlock.set_Status(const Value: TMBState);
begin
  FMR.Status := UInt16(Value);
end;

procedure TMessageBlock.set_Version(const Value: Byte);
begin
  FMR.Version := Value;
end;

procedure TMessageBlock.set_WSCode(const Value: Byte);
begin
  FMR.WSCode := Value;
end;

end.
