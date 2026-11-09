unit AssetFilterU;

interface

uses
  AssetEntryU, AssetOwnerU, AssetTimePointU;

type

  TAssetFilter = class
  private
    FAsset        : TObject;
    FBooked       : Boolean;
    FCharged      : Boolean;
    FCreator      : TAssetOwner;
    FSite         : String;
    FTimeRange    : TAssetTimeRange;
    FWorkstation  : String;

    function GetAsset    : TObject;
    procedure SetAsset(Value : TObject);
    function GetBooked    : Boolean;
    procedure SetBooked(Value : Boolean);
    function GetCharged   : Boolean;
    procedure SetCharged(Value : Boolean);
    function GetCreator   : TAssetOwner;
    procedure  SetCreator(Value : TAssetOwner);
    function GetSite  : String;
    procedure SetSite(Value : String);
    function GetTimeRange : TAssetTimeRange;
    procedure SetTimeRange(Value : TAssetTimeRange);
    function GetWorkstation : String;
    procedure SetWorkstation(Value : String);
  public
    property Asset  	    : TObject         read GetAsset       write SetAsset;
    property Booked  	    : Boolean         read GetBooked      write SetBooked;
    property Charged 	    : Boolean         read GetCharged     write SetCharged;
    property Creator      : TAssetOwner     read GetCreator     write SetCreator;
    property Site         : String          read GetSite        write SetSite;
    property TimeRange    : TAssetTimeRange read GetTimeRange   write SetTimeRange;
    property Workstation  : String          read GetWorkstation write SetWorkstation;

    function IsIncluded(AssetEntry : TAssetEntry) 	: Boolean;
    function SelectEntries : TAssetEntries;
  end;

implementation

uses
  AssetU;

function TAssetFilter.GetAsset    : TObject;
begin
  Result := FAsset As TAsset;
end;

procedure TAssetFilter.SetAsset(Value : TObject);
var
  NewAsset : TAsset;
begin
  NewAsset := Value As TAsset;
  If FAsset <> NewAsset then
  begin
    FAsset := NewAsset;
  end;
end;

function TAssetFilter.GetBooked    : Boolean;
begin
  Result := FBooked;
end;

procedure TAssetFilter.SetBooked(Value : Boolean);
begin
  If FBooked <> Value then
  begin
    FBooked := Value;
  end;
end;

function TAssetFilter.GetCharged   : Boolean;
begin
  Result := FCharged;
end;

procedure TAssetFilter.SetCharged(Value : Boolean);
begin
  If FCharged <> Value then
  begin
    FCharged := Value;
  end;
end;

function TAssetFilter.GetCreator   : TAssetOwner;
begin
  Result := FCreator;
end;

procedure  TAssetFilter.SetCreator(Value : TAssetOwner);
begin
  If FCreator <> Value then
  begin
    FCreator := Value;
  end;
end;

function TAssetFilter.GetSite  : String;
begin
  Result := FSite;
end;

procedure TAssetFilter.SetSite(Value : String);
begin
  If FSite <> Value then
  begin
    FSite := Value;
  end;
end;

function TAssetFilter.GetTimeRange : TAssetTimeRange;
begin
  Result := FTimeRange;
end;

procedure TAssetFilter.SetTimeRange(Value : TAssetTimeRange);
begin
  If FTimeRange <> Value then
  begin
    FTimeRange := Value;
  end;
end;

function TAssetFilter.GetWorkstation : String;
begin
  Result := FWorkstation;
end;

procedure TAssetFilter.SetWorkstation(Value : String);
begin
  If FWorkstation <> Value then
  begin
    FWorkstation := Value;
  end;
end;

function TAssetFilter.IsIncluded(AssetEntry : TAssetEntry) 	: Boolean;
begin
  Result := False;
end;

function TAssetFilter.SelectEntries : TAssetEntries;
begin
  Result := nil;
end;

end.
