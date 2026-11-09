unit nsTypes;

interface

type
  PRBool = LongBool;
  PRUint8 = Byte;
  PRUint16 = Word;
  PRUint32 = Longword;
  PRUint64 = Int64;
  PRTime = Int64;
  PRInt8 = Shortint;
  PRInt16 = Smallint;
  PRInt32 = Longint;
  PRInt64 = Int64;

  nsresult = PRUint32;
  nsrefcnt = PRUint32;

  size_t = PRUint32;

  PRFileDesc = type Pointer;
  PRLibrary = type Pointer;

  nsPoint = record
    x, y: Longint;
  end;

  nsRect = record
    left, top, right, bottom: Longint;
  end;
  
  nsMargin = record
    left, top, right, bottom: Longint;
  end;

  TGUIDArray = array[0..16383] of TGUID;

  nsHashKey = type Pointer;

  // not FROZEN interfaces
  nsIDOMCounter = interface end;
  nsIDOMRect = interface end;
  nsIDOMRGBColor = interface end;
  nsIPrintSession = interface end;
  nsIAuthPrompt = interface end;
  imgIContainer = interface end;
  mozISqlResult = interface end;
  nsIRDFResource = interface end;
  nsIPresShell = interface end;

  PPWideCharArray = ^PWideCharArray;
  PWideCharArray = array[0..16383] of PWideChar;
  PPAnsiCharArray = ^PAnsiCharArray;
  PAnsiCharArray = array[0..16383] of PAnsiChar;

  PGUIDArray = array[0..16383] of PGUID;

  PPRFileDesc = type Pointer;
  PFile = type Pointer;
  PPRLibrary = type Pointer;

implementation

end.
