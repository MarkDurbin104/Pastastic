unit LocaleU;

interface

	function DateTimeToLocaleString(dateTime : TDateTime) : String;

implementation

uses
	SysUtils,Windows;

function DateTimeToLocaleString(dateTime : TDateTime) : String;
var
	S : String;
	SystemTime : TSystemTime;
	buf : Array[0..255] of Char;
begin
	try
{    DateTimeToSystemTime(Now, SystemTime);
    //hijri date
    GetDateFormat(LOCALE_SYSTEM_DEFAULT	,
    							DATE_USE_ALT_CALENDAR,
                  @SystemTime,	//use current time
                  'dd/MM/yyyy',
    							buf, 256);

    Result := buf;
    Result := Trim(Result);
}

      S:=FormatDateTime('dddd',Now);
      DateTimeToSystemTime(Now,SystemTime);
      GetDateFormat($00000401,DATE_LONGDATE,@SystemTime,nil,Buf,SizeOf(Buf));
//      GetDateFormat(GetThreadLocale,DATE_LONGDATE,@SystemTime,nil,Buffer,SizeOf(Buffer));
      S:=S+'  '+Buf;
      S:=S+'  '+FormatDateTime('hh:nn',Now);
      Result := S;

  except
  	Result := '';
  end;
end;
end.
