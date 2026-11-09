unit ExFlpFmt;

interface
uses
     FFormat,
     Windows,WinExecU,
     Classes, SysUtils, Dialogs, Controls,Forms;



type

   TCallBackFPmt = function( Txt: String ) : Word ;
   TCallBackFuncPmt = function( Txt: String ) : Word of object;
   TcallBackProc = procedure of object ;
   TCallBack = function:Integer of object;
   TFloppy = class( TFloppyFormat)
   private
      FDoFormat    : Boolean ;
      FErrorFormat : integer ;
      FShowMsg     : boolean ;
      FOnInsertDisk     :TCallBackFuncPmt;
      FOnInsertFmtDisk  :TCallBackFuncPmt;
      FOnDiskNoRead     :TCallBackProc;
      FCheckLabel       :TCallBackFPmt ;

      function  ReadVolume : string ;
      procedure SetVolume( Volume: String ) ;

   public

      function  GetError : String ;
      function  InsAndForNewFloppy( DskNbr : integer ) : integer ;
      function  InsertFloppyNumber( DskNbr : integer ) : boolean ;
      function  CheckDisk : integer;

      property  ErrorFormat : integer  read FErrorFormat ;
      property  ShowMsg     : boolean  read FShowMsg write FShowMsg ;
      property  RealVolume  : string   read ReadVolume write SetVolume ;
      property  CheckLabel  : TCallBackFPmt write FCheckLabel ;

      constructor Create( AOwner: TComponent ) ; override ;
//      function FormatDisk:Integer;
      Destructor  Destroy ; override ;

      property OnInsertDisk       :TCallBackFuncPmt read FOnInsertDisk write FOnInsertDisk;
      property OnInsertFormatDisk :TCallBackFuncPmt read FOnInsertFmtDisk write FOnInsertFmtDisk;
      property OnDiskNoRead       :TCallBackProc    read FOnDiskNoRead write FOnDiskNoRead ;
      property DoFormat           :Boolean          read FDoFormat     write FDoFormat;
   end ;

implementation


// -----------------------------------------------------------------------------
constructor TFloppy.Create( AOwner: TComponent ) ;
begin
   Inherited Create( AOwner );
   FErrorFormat   := 0   ;
   FShowMsg       := TRUE ; //FALSE ;
end ;
// -----------------------------------------------------------------------------
Destructor TFloppy.Destroy ;
begin
   inherited destroy ;
end ;
// -----------------------------------------------------------------------------
function  TFloppy.CheckDisk : integer;
begin
   DiskSize( 1 ) ;
   result := 0 ;
end ;

// -----------------------------------------------------------------------------
function  TFloppy.InsertFloppyNumber( DskNbr : integer ) : boolean ;
var
   MsgRtn : word ;
begin


   if Assigned (FOnInsertDisk) then
       MsgRtn := FOnInsertDisk( IntToStr( DskNbr ) )
   else
      MsgRtn := MessageDlg( 'Insert floppy number ' + IntToStr(DskNbr),
                             mtConfirmation, [ mbOK, mbAbort ], 0 );

   result := ( MsgRtn = mrOk ) ;


end ;
// -----------------------------------------------------------------------------
function TFloppy.InsAndForNewFloppy( DskNbr : integer ) : integer ;
var
   ExitLoop : boolean ;
   MsgRtn : word ;
begin

   result := 0 ;
   ExitLoop := FALSE ;

   while not ExitLoop do
   begin

      if Assigned(FOnInsertFmtDisk) then
          MsgRtn := FOnInsertFmtDisk( IntToStr( DskNbr ) )
      else
         MsgRtn := MessageDlg( 'Insert floppy disk number '+ IntToStr(DskNbr)+', it will be formated',
                                mtConfirmation, [ mbOK, mbAbort ], 0 );

      if ( MsgRtn <> mrOK ) then
      begin
         ExitLoop := TRUE ;
         result := -1 ;
      end
      else
      begin

         if FCheckLabel( ReadVolume ) = 0 then // Disk has not been read
         begin

            if Assigned( FOnDiskNoRead ) then
               FOnDiskNoRead
            else
               ShowMessage( 'Enter another disk, this has not been read' ) ;

         end
         else
         begin
            if FDoFormat then
               FErrorFormat := FormatDisk
            else
               FErrorFormat := 0;
               
            if ErrorFormat = 0 then
            begin
               ExitLoop := TRUE ;
               result := 0 ;
            end ;
          end ;

      end ;

   end ;


end ;
// -----------------------------------------------------------------------------
procedure TFloppy.SetVolume( Volume: String ) ;
begin

   SetVolumeLabel( PChar( 'a:\' ), PChar( Volume ) );

end ;
// -----------------------------------------------------------------------------
function TFloppy.ReadVolume : string ;
var
   //lpRootPathName           : Pchar ; // address of root directory of the file system
   lpVolumeNameBuffer       : PChar ; // address of name of the volume
   nVolumeNameSize	       : DWORD ; // length of lpVolumeNameBuffer
   lpVolumeSerialNumber     : DWORD ; // address of volume serial number
   lpMaximumComponentLength : DWORD ; // address of system's maximum filename length
   lpFileSystemFlags        : DWORD ; // address of file system flags
   lpFileSystemNameBuffer   : Pchar ; // address of name of file system
   nFileSystemNameSize 	    : DWORD ; // length of lpFileSystemNameBuffer
begin

   //lpRootPathName := 'A:\' ;

   GetMem(lpVolumeNameBuffer, 128 );     // 128 to alocate
   GetMem(lpFileSystemNameBuffer, 128 ); // 128 to alocate

   nFileSystemNameSize := 128 ;
   nVolumeNameSize     := 128 ;

   GetVolumeInformation(
      PChar( 'A:\'),	         // address of root directory of the file system
      lpVolumeNameBuffer,	   // address of name of the volume
      nVolumeNameSize,	      // length of lpVolumeNameBuffer,
      @lpVolumeSerialNumber,	// address of volume serial number
      lpMaximumComponentLength,// address of system's maximum filename length
      lpFileSystemFlags,	   // address of file system flags
      lpFileSystemNameBuffer,	// address of name of file system
      nFileSystemNameSize 	   // length of lpFileSystemNameBuffer
   ) ;

   result := lpVolumeNameBuffer ;

   FreeMem(lpVolumeNameBuffer, 128 );
   FreeMem(lpFileSystemNameBuffer, 128 );


end ;

// -----------------------------------------------------------------------------
function TFloppy.GetError : String ;
begin

   case FErrorFormat of
       0: Result := 'OK';
      01: Result := 'Reset failed';
      02: Result := 'Unable to get drive type';
      03: Result := 'No such drive';
      04: Result := 'Unknown drive type';
      05: Result := 'Incompatible media types';
      06: Result := 'Unable to set disk type';
      07: Result := 'Unable to set media type';
      08: Result := 'Error formatting track';
      09: Result := 'Error verifying track';
      10: Result := 'Error writing boot sector';
      11: Result := 'Error writing fat';
      12: Result := 'Error writing root';
      13: Result := 'Error creating system';
      14: Result := 'Unable to clear disk';
      15: Result := 'Disk access violation';
      16: Result := 'System error';
      17: Result := 'No memory';
      18: Result := 'Sector does not exist';
      19: Result := 'Track does not exist';
      98: Result := 'Process already running';
   end ;

end ;

end.


