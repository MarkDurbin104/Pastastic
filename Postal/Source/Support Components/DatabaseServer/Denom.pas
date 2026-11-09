{ Module          Database Server
  Unit            Denom
  Copyright(c)    Postal Solutions Limited 1996..1999
  Author          ASH
  Description     Support functions for cash denomination calculations
  Modifications   09/1998     - ASH
                                Original Release
                  25/01/1999  - ASH
                                Header comments and code formatting

}
unit Denom;

interface
uses
  GPCSErrorLine,
  SysUtils;

type
  //defines avaliable denomination
  TDenom = (dn1, dn2, dn5, dn10, dn20, dn50, dn100,
            dn200, dn500, dn1000, dn2000, dn5000, dn10000);

const
  //defines denomination values
  DenomValues : Array[TDenom] Of Integer=
  (1,2,5,10,20,50,100,200, 500,1000,2000,5000,10000);

procedure CalcDenoms(Total : Integer; var DenomArray : Array Of Integer);

implementation

{===============================================================================
  Class         Denom
  Method        DenomNumber
  Description   Returns number of units required to give total
                Decreases Total by corresponding amount
  Params        var Total : Integer - Total to be fulfilled
                Denom     : Integer - Denomination value
  Result        Integer             - Number of units of denomination
________________________________________________________________________________}
function DenomNumber(var Total : Integer; Denom : Integer) : Integer;
begin
  try
    Result := Total div Denom;
    Dec(Total, Result * Denom);
  except
    On E : Exception do
    begin
      Result := -1; //problem, div by 0?
      RaiseException($160,E);
    end;
  end;
end;

{===============================================================================
  Class         Denom
  Method        CalcDenoms
  Description   Returns array of denominations to fulfill a required total
  Params        Total           : Integer           - Total to be fulfilled
                var DenomArray  : Array of Integer  - Number of each Denomination value required
  Result        None
________________________________________________________________________________}
procedure CalcDenoms(Total : Integer; var DenomArray : Array Of Integer);
var
  DenomIndex : Integer;
begin
  try
    For DenomIndex := High(DenomArray) downto Low(DenomArray) do
    begin
      DenomArray[DenomIndex] := DenomNumber(Total, DenomArray[DenomIndex]);
      //total reduced
    end;
  except
    On E : Exception do
    begin
      RaiseException($132,E);
    end;
  end;
end;


end.
