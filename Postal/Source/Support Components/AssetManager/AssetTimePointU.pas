unit AssetTimePointU;

interface
uses
  ComObj,
  AssetManager_TLB, SysUtils;

type

  TAssetTimePoint = class(TAutoObject, IAssetTimePoint)
  private
    FDateTime             : TDateTime;
    FSystem    : String;
    function  GetDateTime : TDateTime;
    procedure SetDateTime(Value : TDateTime);
    function  GetYear     : Word;
    procedure SetYear(Value : Word);
    function  GetMonth    : Word;
    procedure SetMonth(Value : Word);
    function  GetDay      : Word;
    procedure SetDay(Value : Word);
    function  GetHour     : Word;
    procedure SetHour(Value : Word);
    function  GetMinute   : Word;
    procedure SetMinute(Value : Word);
    function  GetSecond   : Word;
    procedure SetSecond(Value : Word);
    function  GetSystem   : String;
    procedure SetSystem(Value : String);

  public
    property DateTime : TDateTime read GetDateTime write SetDateTime;
    property Year     : Word      read GetYear write SetYear;
    property Month    : Word      read GetMonth write SetMonth;
    property Day      : Word      read GetDay write SetDay;
    property Hour     : Word      read GetHour write SetHour;
    property Minute   : Word      read GetMinute write SetMinute;
    property Second   : Word      read GetSecond write SetSecond;
    property System  : String     read GetSystem write SetSystem;
  end;

  TAssetTimeRange = class
  private
    FStart  : TAssetTimePoint;
    FFinish : TAssetTimePoint;
    function GetStart : TAssetTimePoint;
    procedure SetStart(Value : TAssetTimePoint);
    function GetFinish : TAssetTimePoint;
    procedure SetFinish(Value : TAssetTimePoint);
  public
    constructor Create;
    destructor Destroy; override;
    property Start : TAssetTimePoint read GetStart write SetStart;
    property Finish: TAssetTimePoint read GetFinish write SetFinish;
  end;

implementation

function TAssetTimePoint.GetDateTime : TDateTime;
begin
  Result := FDateTime;
end;

procedure TAssetTimePoint.SetDateTime(Value : TDateTime);
begin
  If FDateTime <> Value then
  begin
    FDateTime := Value;
  end;
end;

function TAssetTimePoint.GetDay : Word;
var
  Year, Month, Day : Word;
begin
  DecodeDate(FDateTime, Year, Month, Day);
  Result := Day;
end;

procedure TAssetTimePoint.SetDay(Value : Word);
var
  Year, Month, Day : Word;
begin
  DecodeDate(FDateTime, Year, Month, Day);
  FDateTime := EncodeDate(Year, Month, Value);
end;

function  TAssetTimePoint.GetYear : Word;
var
  Year, Month, Day : Word;
begin
  DecodeDate(FDateTime, Year, Month, Day);
  Result := Year;
end;

procedure TAssetTimePoint.SetYear(Value : Word);
var
  Year, Month, Day : Word;
begin
  DecodeDate(FDateTime, Year, Month, Day);
  FDateTime := EncodeDate(Value, Month, Day);
end;

function  TAssetTimePoint.GetMonth    : Word;
var
  Year, Month, Day : Word;
begin
  DecodeDate(FDateTime, Year, Month, Day);
  Result := Month;
end;

procedure TAssetTimePoint.SetMonth(Value : Word);
var
  Year, Month, Day : Word;
begin
  DecodeDate(FDateTime, Year, Month, Day);
  FDateTime := EncodeDate(Year, Value, Day);
end;

function  TAssetTimePoint.GetHour : Word;
var
  Hour, Minute, Second, MSecond : Word;
begin
  DecodeTime(FDateTime, Hour, Minute, Second, MSecond);
  Result := Hour;
end;

procedure TAssetTimePoint.SetHour(Value : Word);
var
  Hour, Minute, Second, MSecond : Word;
begin
  DecodeTime(FDateTime, Hour, Minute, Second, MSecond);
  FDateTime := EncodeTime(Value, Minute, Second, MSecond);
end;

function  TAssetTimePoint.GetMinute   : Word;
var
  Hour, Minute, Second, MSecond : Word;
begin
  DecodeTime(FDateTime, Hour, Minute, Second, MSecond);
  Result := Minute;
end;

procedure TAssetTimePoint.SetMinute(Value : Word);
var
  Hour, Minute, Second, MSecond : Word;
begin
  DecodeTime(FDateTime, Hour, Minute, Second, MSecond);
  FDateTime := EncodeTime(Hour, Value, Second, MSecond);
end;

function  TAssetTimePoint.GetSecond : Word;
var
  Hour, Minute, Second, MSecond : Word;
begin
  DecodeTime(FDateTime, Hour, Minute, Second, MSecond);
  Result := Second;
end;

procedure TAssetTimePoint.SetSecond(Value : Word);
var
  Hour, Minute, Second, MSecond : Word;
begin
  DecodeTime(FDateTime, Hour, Minute, Second, MSecond);
  FDateTime := EncodeTime(Hour, Minute, Value, MSecond);
end;

function  TAssetTimePoint.GetSystem   : String;
begin
  Result := FSystem;
end;

procedure TAssetTimePoint.SetSystem(Value : String);
begin
  If FSystem <> Value then
  begin
    FSystem := Value;
  end;
end;

constructor TAssetTimeRange.Create;
begin
  Inherited Create;

  FStart  := TAssetTimePoint.Create;
  FFinish := TAssetTimePoint.Create;
end;

destructor TAssetTimeRange.Destroy;
begin
  FStart.Free;
  FFinish.Free;

  Inherited Destroy;
end;


function TAssetTimeRange.GetStart : TAssetTimePoint;
begin
  Result := FStart;
end;

procedure TAssetTimeRange.SetStart(Value : TAssetTimePoint);
begin
  If FStart.DateTime <> Value.DateTime then
  begin
    FStart.DateTime := Value.DateTime;
  end;
end;

function TAssetTimeRange.GetFinish : TAssetTimePoint;
begin
  Result := FFinish;
end;

procedure TAssetTimeRange.SetFinish(Value : TAssetTimePoint);
begin
  If FFinish.DateTime <> Value.DateTime then
  begin
    FFinish.DateTime := Value.DateTime;
  end;
end;


end.
