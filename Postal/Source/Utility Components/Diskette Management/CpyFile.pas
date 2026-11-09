unit CpyFile;

interface



uses
      ExFlpFmt,
      FFormat,
      Compress,
      FileCtrl,
      SysUtils,
      Classes,
      Dialogs,Forms ;
const
   WRITE_BLOCK_SIZE     = 18*1024; // 1 Track * 18 sectors of 1024 bytes (80 Tracks)
   errStOK              = 0 ;
   errStFileNoFound     = 1 ;
   errStReadyDevice     = 2 ;
   errStOpenInputFile   = 3 ;
   errStOpenOutputFile  = 4 ;
   errStCloseInputFile  = 5 ;
   errStCloseOutputFile = 6 ;
   errStDeleteOutputFile= 7 ;
   errStDecompressing   = 8 ;

type
   TCopyThread =class(TThread)
   private
      FIsRunning :Boolean;
      FToStream  :TMemoryStream;
      FFromStream:TStream;
   public
      procedure Execute; override;
      property IsRunning :Boolean       read FIsRunning  write FIsRunning ;
      property ToStream  :TMemoryStream read FToStream   write FToStream  ;
      property FromStream:TStream       read FFromStream write FFromStream;
   end;
   TCopyFile = class ;
   TCallBackProc = procedure of object;
   TCallBackFuncPmt = function( Txt: String ) : word of object ;


   TCallBackProcSender = procedure( Sender : TCopyFile ) of object;

// --------------

   TCopyFile = class( TComponent )
   private

      FErrorStatus   : integer ;

      FInputListNames: TStringList ;
      FOutputFile    : String ;
      FOutputDir     : String ;

      FCountName     : integer ;
      FInputFile     : String ;

      FInputStream   : TFileStream ;
      FOutputStream  : TFileStream ;
      FShowMsg       : Boolean ;

      FOnCopyFile        :TCallBackProcSender;
      FOnGetReadyDevice  :TCallBackProc;

      FFilesTotalBytes   : integer ;
      FFilesBytesWritten : integer ;

      function  GetTotalBytes : integer ;
      function  GetReadyDevice( ShwMsg : boolean ) : boolean ; virtual ; abstract ;
      function  ReadInputFileNames : string ;
      function  ReadErrorStatus : string ;

      procedure SetOutputDir( OutDir : String );
      procedure SetNextFile ;
      procedure SetInputFileNames( InFleNme : String ) ;

   public
      property OutputFile     : string  read FOutputFile ;
      property InputFile      : string  read FInputFile  ;

      property BytesWritten   : integer read FFilesBytesWritten ;
      property TotalBytes     : integer read FFilesTotalBytes ;

      property ErrorStatus   : integer read FErrorStatus ;
      property ErrorStatusStr: String  read ReadErrorStatus ;


      function    OpenOutputFile : integer ;
      function    OpenInputFile  : integer ;
      function    CloseOutputFile: integer ;
      function    CloseInputFile : integer ;
      function    CopyIntoFile( Source : TMemoryStream  ) : boolean ; virtual ; abstract ;
      constructor Create( aOwner : TComponent ) ;override ;
      destructor  Destroy ; override ;

   published

      property OutputDir      : string  read FOutputDir         write SetOutputDir      ;
      property ShowMsg        : boolean read FShowMsg           write FShowMsg    ;

      property OnCopyFile      :TCallBackProcSender read FOnCopyFile       write FOnCopyFile      ;
      property OnGetReadyDevice:TCallBackProc       read FOnGetReadyDevice write FOnGetReadyDevice;


   end ;

// --------------

   TCopyFloppy = class( TCopyFile )
   protected
      FFloppy : TFloppy;
      FDiskNumber : integer ;
      FDoFormat:Boolean;

      function  ReadOnInsertDisk : TCallBackFuncPmt ;

      procedure SetOnInsertDisk( InsDsk : TCallBackFuncPmt );

   public
      property    Floppy    : TFloppy    read FFloppy       write FFloppy ;
      constructor Create( aOwner : TComponent ) ; override ;
      destructor  Destroy ; override ;
   published
      property DoFormat           :Boolean          read FDoFormat     write FDoFormat;
      property OnInsertDisk         :TCallBackFuncPmt read ReadOnInsertDisk write SetOnInsertDisk;
   end ;

// --------------

   TCopyIntoFloppy = class( TCopyFloppy )
   private

      function  ReadDiskDrive : TDiskDrive ;
      function  ReadMediaType : TMediaType ;
      function  GetReadyDevice( ShwMsg : boolean ) : boolean ; override ;

      function  ReadOnInsertFmtDisk :  TCallBackFuncPmt ;
      function  ReadOnDiskNoRead :TCallBackProc;

      procedure SetOnInsertFmtDisk( InsDsk : TCallBackFuncPmt );
      procedure SetOnDiskNoRead( InsDsk : TCallBackProc );

      procedure SetDiskDrive( DskDrv : TDiskDrive ) ;
      procedure SetMediaType( MdaTpe : TMediaType ) ;
      procedure SetDeviceLabel( LabelNbr : integer ; Next : String ) ;


   public
      function  StartCopying : boolean   ;
      property  DiskDrive : TDiskDrive read ReadDiskDrive write SetDiskDrive ;
      property  MediaType : TMediaType read ReadMediaType write SetMediaType ;
      function  CopyIntoFile( Source : TMemoryStream  ) : boolean ; override ;

      constructor Create( aOwner : TComponent ) ;override ;

   published
      property InputFileNames : String  read ReadInputFileNames write SetInputFileNames ;
      property OnInsertFormatDisk   :TCallBackFuncPmt read ReadOnInsertFmtDisk write SetOnInsertFmtDisk;
      property OnDiskNoRead         :TCallBackProc    read ReadOnDiskNoRead write SetOnDiskNoRead ;
   end ;

// --------------

   TCopyFromFloppy = class( TCopyFloppy )
   private
      FCopyFileNames : TStringList ;

      function  GetDiskNumber : integer ;
      function  MoreInformation : boolean ;
      function  GetReadyDevice( ShwMsg : boolean ) : boolean ; override ;
      function  GetDirFileNames : string ;
      function  MarkReadDisk    : boolean ;
      function  DeleteOutputFile: boolean ;
      function  DecompressFiles   : boolean ;
   public

      function  StartCopying : boolean   ;
      function  CopyIntoFile( Source : TMemoryStream  ) : boolean ; override ;
      constructor Create( aOwner : TComponent ) ; override ;
      destructor  Destroy ; override ;

   end ;

procedure register ;


implementation

function IsReadDisk( Txt : String ) : Word ;
begin

   if ( Copy( Txt , 2, 7 ) = '__DISK_' ) then
      result := 0 // Has not been read
   else
      result := 1 ; // The label value for a read disk is '@_DISK_'

end ;

procedure register ;
begin
   registercomponents( 'DisketteVCL', [ TCopyFromFloppy, TCopyIntoFloppy ] );
end ;

constructor TCopyFile.Create( aOwner : TComponent ) ;
begin
   inherited Create( aOwner ) ;
   FOutputFile := '' ;
   FInputFile  := '' ;
   FCountName := -1 ;
   FFilesTotalBytes   := 0 ;
   FFilesBytesWritten := 0 ;

   FInputListNames := TStringList.Create ;
   FErrorStatus := errStOk ;
end ;
// -----------------------------------------------------------------------------
destructor TCopyFile.Destroy ;
begin
   FInputListNames.Free ;
   inherited Destroy ;
end ;
// -----------------------------------------------------------------------------
function TCopyFile.CloseOutputFile : integer ;
begin

   result := 0 ;
   try
      if FOutputStream <> nil then
      begin
         FOutputStream.Free ;
         FOutputStream := nil ;
      end ;
   except
      FErrorStatus := errStCloseOutputFile ;
      result := -1 ;
   end ;

end ;
// -----------------------------------------------------------------------------
function TCopyFile.OpenOutputFile : integer ;
begin

   result := 0 ;
   try
      if FileExists( FOutputFile ) then
         FOutputStream := TFileStream.Create( FOutputFile, fmOpenReadWrite	)
      else
         FOutputStream := TFileStream.Create( FOutputFile, fmCreate ) ;

      FOutputStream.Position := FOutputStream.Size ;

   except
      FErrorStatus := errStOpenOutputFile ;
      result := 1 ;
   end ;

end ;
// -----------------------------------------------------------------------------
function TCopyFile.CloseInputFile : integer ;
begin

   result := 0 ;
   try
      if FInputStream <> nil then
      begin
         FInputStream.Free ;
         FInputStream := nil ;
      end ;
   except
      result := -1 ;
      FErrorStatus := errStCloseInputFile ;
   end ;

end ;
// -----------------------------------------------------------------------------
function TCopyFile.OpenInputFile : integer ;
begin

   result := 0 ;
   try
      if FileExists( FInputFile ) then
      begin
         FInputStream := TFileStream.Create( FInputFile, fmOpenRead );
         FInputStream.Position := 0 ;
      end
      else
         FErrorStatus := errSTFileNoFound ;


   except
      result := 1 ;
      FErrorStatus := errStOpenInputFile
   end ;

end ;
// -----------------------------------------------------------------------------
function TCopyFile.GetTotalBytes: integer ;
var
   I : integer ;
   ExitLoop : boolean ;
   SearchRec : TSearchRec;
begin

   result := 0 ;
   I := 0 ;
   ExitLoop := FALSE ;

   while ( not ExitLoop ) and ( I <= FInputListNames.Count -1 ) do
   begin

      if FileExists( FInputListNames[ i ] ) then
      begin
         FindFirst( FInputListNames[ I ], $0000003F, SearchRec );
         result := result + SearchRec.Size ;
      end
      else
      begin
         FErrorStatus := errStFileNoFound ;
         result   := 0 ;
         ExitLoop := TRUE ;
      end ;
      Inc( I ) ;

   end ;

end ;
// -----------------------------------------------------------------------------
procedure TCopyFile.SetOutputDir( OutDir : String ) ;
begin
   FOutputDir := Trim( OutDir ) ;
   if Copy( FOutputDir, Length(FOutputDir), 1  ) <> '\' then
      FOutputDir := FOutputDir + '\'
end ;
// -----------------------------------------------------------------------------
function TCopyFile.ReadInputFileNames : string ;
begin
   result := FInputListNames.CommaText ;
end ;
// -----------------------------------------------------------------------------
procedure TCopyFile.SetInputFileNames( InFleNme : String ) ;
begin
   FInputListNames.CommaText := InFleNme ;
   FCountName := 0 ;
   SetNextFile ;
end ;
// -----------------------------------------------------------------------------
procedure TCopyFile.SetNextFile ;
begin

   if (( FInputListNames.Count -1 ) >= FCountName ) and ( FInputListNames.Count> 0) then
   begin
      FInputFile := FInputListNames[ FCountName ];
      FOutputFile := FOutputDir + ExtractFileName( FInputListNames[ FCountName ] ) ;
      Inc( FCountName ) ;
   end
   else
   begin
      FInputFile  := '' ;
      FOutputFile := '' ;
   end ;



end ;
// -----------------------------------------------------------------------------
function TCopyFile.ReadErrorStatus ;
begin
   case FErrorStatus of
      errStOK              :  result := 'OK'                ;
      errStFileNoFound     :  result := 'File not found'    ;
      errStReadyDevice     :  result := 'Device not ready'  ;
      errStOpenInputFile   :  result := 'Open input file'   ;
      errStOpenOutputFile  :  result := 'Open output file'  ;
      errStCloseInputFile  :  result := 'Close input file'  ;
      errStCloseOutputFile :  result := 'Close output file' ;
      errStDeleteOutputFile:  result := 'Predelete output file' ;
      errStDecompressing   :  result := 'Decompressing file' ;
   end ;

end ;

// -----------------------------------------------------------------------------
// CopyFloppy
// -----------------------------------------------------------------------------

constructor TCopyFloppy.Create( aOwner : TComponent ) ;
begin
   inherited Create( aOwner ) ;
   FFloppy := TFloppy.Create( nil ) ;
   FFloppy.MediaType := F1440 ;
   FFloppy.DiskDrive := DriveA ;
   FFloppy.CheckLabel := IsReadDisk ;
   DoFormat:=True;
   FFloppy.DoFormat:=True;
end ;
// -----------------------------------------------------------------------------
destructor TCopyFloppy.Destroy ;
begin
   Floppy.Free ;
   inherited Destroy ;
end ;
// -----------------------------------------------------------------------------
function TCopyFloppy.ReadOnInsertDisk : TCallBackFuncPmt ;
begin
   result := FFloppy.OnInsertDisk ;
end ;
// -----------------------------------------------------------------------------
procedure TCopyFloppy.SetOnInsertDisk( InsDsk : TCallBackFuncPmt );
begin
   FFloppy.OnInsertDisk := InsDsk ;
end ;

// -----------------------------------------------------------------------------
// CopyIntoFloppy
// -----------------------------------------------------------------------------

constructor TCopyIntoFloppy.Create( aOwner : TComponent ) ;
begin
   inherited Create( aOwner ) ;
   FShowMsg := TRUE ;
end ;
// -----------------------------------------------------------------------------
function TCopyIntoFloppy.StartCopying : boolean ;
var
   MemoryStream : TMemoryStream ;
   Compressor : TCompressor ;
   ExitLoop : boolean ;
begin

   FErrorStatus := errStOk ;
   ExitLoop := FALSE ;

   FFilesBytesWritten := 0 ;
   FFilesTotalBytes := GetTotalBytes ;
   FDiskNumber := 0 ;


   if (FFilesTotalBytes >0) then

      if GetReadyDevice( TRUE ) then
      begin

         Compressor := TCompressor.Create  ;
         MemoryStream := TMemoryStream.Create ;
         try

            while (FInputFile <> '') and not ExitLoop and ( FErrorStatus = errSTOk ) do
            begin

               OpenOutputFile ;
               OpenInputFile  ;

               try
                  MemoryStream.Clear ;
                  //MemoryStream.LoadFromStream( FInputStream ) ;
                  Compressor.CompressStream( FInputStream, MemoryStream );
                  MemoryStream.Position := 0 ;
                  ExitLoop := CopyIntoFile( MemoryStream ) ;

               finally
                  CloseOutputFile   ;
                  CloseInputFile ;
               end ;

              SetNextFile ;
            end ;

         finally
            Compressor.Free ;
            MemoryStream.Free ;
         end ;
         SetDeviceLabel( FDiskNumber, 'N' );
      end ;

   result := (FErrorStatus = errStOk) ;

end ;


// -----------------------------------------------------------------------------
function TCopyIntoFloppy.CopyIntoFile( Source : TMemoryStream  ) : boolean;
var
   TotalBytesWritten, PartialWrite : integer ;
   ExitLoop : Boolean ;
   MinWrite : integer ;
   CurrentPos : integer ;
begin

   TotalBytesWritten  := 0 ;
   ExitLoop := TRUE ;
   Result:=True;
   if FOutputStream <> nil then
   begin
      ExitLoop := FALSE;

      while not ExitLoop and ( TotalBytesWritten < Source.Size ) and
           ( FErrorStatus = errSTOk ) do
      begin

         if Assigned( FOnCopyFile ) then FOnCopyFile( Self ) ;

         MinWrite := WRITE_BLOCK_SIZE ;
         
         if Source.Size < MinWrite then MinWrite:=Source.Size; // MJD
         
         PartialWrite := 1 ;
         while ( MinWrite > 0 ) and ( PartialWrite > 0 ) do
         begin
            CurrentPos :=  Source.Position ;
            try
               PartialWrite := FOutputStream.CopyFrom( Source, MinWrite ) ;
            except
                Source.Position := CurrentPos ;
                PartialWrite := 0 ;
            end ;
            Application.HandleMessage;
            if Application.Terminated then Exit;

            TotalBytesWritten   := TotalBytesWritten + PartialWrite ;
            FFilesBytesWritten := FFilesBytesWritten + PartialWrite ;


            if MinWrite > ( Source.Size-TotalBytesWritten) then
               MinWrite := Source.Size-TotalBytesWritten ;

         end ;

         if ( TotalBytesWritten <> Source.Size ) then
         begin

            CloseOutputFile ;

            SetDeviceLabel( FDiskNumber, 'Y' );
            Inc( FDiskNumber ) ;

            ExitLoop := not GetReadyDevice( FALSE ) ;
            if not ExitLoop then
               ExitLoop := ( OpenOutputFile <> 0 );

         end ;

      end ;

   end ;
   result := ExitLoop ;

end ;
// -----------------------------------------------------------------------------
function  TCopyIntoFloppy.ReadDiskDrive : TDiskDrive ;
begin
   result := FFloppy.DiskDrive ;
end ;
// -----------------------------------------------------------------------------
procedure TCopyIntoFloppy.SetDiskDrive( DskDrv : TDiskDrive ) ;
begin
   FFloppy.DiskDrive := DskDrv ;
end ;
// -----------------------------------------------------------------------------
function  TCopyIntoFloppy.ReadMediaType : TMediaType ;
begin
   result := FFloppy.MediaType ;
end ;
// -----------------------------------------------------------------------------
procedure TCopyIntoFloppy.SetMediaType( MdaTpe : TMediaType ) ;
begin
   FFloppy.MediaType := MdaTpe ;
end ;
// -----------------------------------------------------------------------------
function TCopyIntoFloppy.GetReadyDevice( ShwMsg : boolean ) : boolean ;
begin

   if FShowMsg and ShwMsg then
      if Assigned (FOnGetReadyDevice) then
         FOnGetReadyDevice
      else
         ShowMessage('Your floppy disk is going to be formated') ;

   FFloppy.DoFormat:=DoFormat;
   result := ( FFloppy.InsAndForNewFloppy( FDiskNumber ) = 0 ) ;


   if not result then
      FErrorStatus := errStReadyDevice ;
end ;

// -----------------------------------------------------------------------------
procedure TCopyIntoFloppy.SetDeviceLabel( LabelNbr : integer; Next : String ) ;
begin

   try
      FFloppy.RealVolume := Next +'_'+'_DISK_'+ Format( '%3.3d', [LabelNbr] ) ;
   except
      FErrorStatus := errStReadyDevice ;
   end ;

end ;
// -----------------------------------------------------------------------------
function TCopyIntoFloppy.ReadOnInsertFmtDisk :  TCallBackFuncPmt ;
begin
   result := FFloppy.OnInsertFormatDisk ;
end ;
// -----------------------------------------------------------------------------
procedure TCopyIntoFloppy.SetOnInsertFmtDisk( InsDsk : TCallBackFuncPmt );
begin
   FFloppy.OnInsertFormatDisk := InsDsk ;
end ;
// -----------------------------------------------------------------------------
function TCopyIntoFloppy.ReadOnDiskNoRead :TCallBackProc;
begin
   result := FFloppy.OnDiskNoRead ;
end ;
// -----------------------------------------------------------------------------
procedure TCopyIntoFloppy.SetOnDiskNoRead( InsDsk : TCallBackProc );
begin
   FFloppy.OnDiskNoRead := InsDsk ;
end ;
// -----------------------------------------------------------------------------

{function TCopyIntoFloppy.IsReadDisk : boolean ;
begin

   try
      result := not ( Copy( FFloppy.RealVolume, 2, 7 ) = '__DISK_' );
   except
      result := FALSE ;
   end ;

end ;}
// -----------------------------------------------------------------------------
// CopyFromFloppy
// -----------------------------------------------------------------------------
constructor TCopyFromFloppy.Create( aOwner : TComponent ) ;
begin
   inherited Create( aOwner ) ;
   FCopyFileNames := TStringList.Create ;
   FDiskNumber := -1 ;
end ;
// -----------------------------------------------------------------------------
destructor TCopyFromFloppy.Destroy ;
begin
   inherited Destroy ;
   FCopyFileNames.Free ;
end ;

// -----------------------------------------------------------------------------
function TCopyFromFloppy.GetDiskNumber : integer ;
begin
   try
      result := StrToInt( Copy( FFloppy.RealVolume, 9, 3 )) ;
   except
      FErrorStatus := errStReadyDevice ;
      result := -1 ;
   end ;
end ;
// -----------------------------------------------------------------------------
function TCopyFromFloppy.MoreInformation : boolean ;
begin
   result := False ;
   try
      result := ( Copy( FFloppy.RealVolume, 1, 1 ) = 'Y' );
   except
      FErrorStatus := errStReadyDevice ;
   end ;
end ;
// -----------------------------------------------------------------------------
procedure TCopyThread.Execute;
begin
   FToStream.LoadFromStream(FFromStream);
   FIsRunning:=False;
end;
function TCopyFromFloppy.StartCopying : boolean ;
var
   CopyThread:TCopyThread;
   MemoryStream : TMemoryStream ;
   Compressor : TCompressor ;
   ExitLoop : boolean ;
begin

   FFilesTotalBytes   := 1400000 ;


   FErrorStatus := errStOk ;
   ExitLoop := FALSE ;
   FDiskNumber := 0 ;
   if GetReadyDevice( TRUE ) then
   begin

      Compressor := TCompressor.Create  ;
      MemoryStream := TMemoryStream.Create ;
      try

         while not ExitLoop and ( FErrorStatus = errStOk ) do
         begin

            FFilesBytesWritten := 0 ;
            SetInputFileNames( GetDirFileNames ) ;

            while ( FInputFile <> '' ) and not ExitLoop and ( FErrorStatus = errStOk ) DO
            begin

               OpenInputFile  ;

               if FInputStream <> nil then
               begin
                  DeleteOutPutFile ;
                  OpenOutputFile ;
                  try
                     MemoryStream.Clear;
                     
                     // Added by MJD
                     CopyThread:=TCopyThread.Create(True); // suspend thread
                     with CopyThread do
                     begin
                        ToStream  :=MemoryStream;          // setup streams
                        FromStream:=FInputStream;
                        IsRunning:=True;
                        Resume;                            // do the copy
                        while (IsRunning) and (not Application.Terminated) do    
                           Application.HandleMessage;      // update the progress bar
                        Free;
                     end;
                     
//                     MemoryStream.LoadFromStream( FInputStream ) ;
                     //Compressor.DeCompressStream( FInputStream, MemoryStream );
                     MemoryStream.Position := 0 ;
                     CopyIntoFile( MemoryStream ) ;

                  finally
                     CloseOutputFile   ;
                     CloseInputFile ;
                  end ;
               end ;

               SetNextFile ;

            end ;

            ExitLoop := not MarkReadDisk ;

            if not ExitLoop  then
               ExitLoop := not MoreInformation  ;

            if not ExitLoop then
            begin
               Inc( FDiskNumber ) ;
               ExitLoop := not GetReadyDevice( FALSE ) ;
            end ;


         end ;

         if FCopyFileNames.Count > 0 then
            DecompressFiles ;
      finally
         Compressor.Free ;
         MemoryStream.Free ;
      end ;

   end ;

   result := ( FErrorStatus = errStOk ) ;

end ;
// -----------------------------------------------------------------------------
function TCopyFromFloppy.CopyIntoFile( Source : TMemoryStream  ) : boolean ;
var
   CurrentPos : integer ;
begin


   if FOutputStream <> nil then
   begin

      if Assigned( FOnCopyFile ) then FOnCopyFile( Self ) ;

      // there is no check if the are enought espace in the hard disk
      CurrentPos :=  Source.Position ;
      try
         FOutputStream.CopyFrom( Source, Source.Size ) ;
      except
          Source.Position := CurrentPos ;
      end ;
      FFilesBytesWritten := FFilesBytesWritten + Source.Size ;


   end ;

   result := TRUE ;

end ;
// -----------------------------------------------------------------------------
function TCopyFromFloppy.GetReadyDevice( ShwMsg : boolean  ) : boolean ;
var
   ExitLoop : boolean ;
begin

   // FDiskNumber will have the new disk number
   if FShowMsg and ShwMsg then
      if Assigned (FOnGetReadyDevice) then
         FOnGetReadyDevice
      else
         ShowMessage('Get ready floppy with BackUp files') ;




   result := FALSE ;
   ExitLoop := FALSE ;
   while not ExitLoop do
   begin
      FErrorStatus := errStOk ;
      if not FFloppy.InsertFloppyNumber( FDiskNumber ) then
         ExitLoop := TRUE
      else
         if ( GetDiskNumber = FDiskNumber ) then
         begin
            result := TRUE   ;
            ExitLoop := TRUE ;
         end ;

   end ;

   if not result then
      FErrorStatus := errStReadyDevice

end ;
// -----------------------------------------------------------------------------
function TCopyFromFloppy.GetDirFileNames : string ;
var
   SL : TStringList ;
   SearchRec : TSearchRec;
begin
   result := '' ;
   SL := TStringList.Create ;
   try
      FindFirst( 'a:\*.*', $0000003F, SearchRec );
      repeat
         SL.Add( 'a:\'+SearchRec.Name ) ;
      until (FindNext( SearchRec )<> 0) ;
      result := Sl.CommaText ;
   finally
      SL.Free ;
   end ;

end ;
// -----------------------------------------------------------------------------
function TCopyFromFloppy.MarkReadDisk : boolean ;
var
   VolumeName : String ;
begin
   result := TRUE ;
   try
      VolumeName := FFloppy.RealVolume ;
      VolumeName := Copy( VolumeName, 1, 1 )+ '@'+
                    Copy( VolumeName, 3, Length(VolumeName)-2 );
      FFloppy.RealVolume := VolumeName ;
   except
      result := FALSE ;
   end ;
end ;
// -----------------------------------------------------------------------------
function TCopyFromFloppy.DeleteOutputFile: boolean ;
begin
   result := TRUE ;
   try
      if FCopyFileNames.IndexOf( FOutputFile ) < 0 then
      begin
         DeleteFile( FOutputFile ) ;
         FCopyFileNames.Add( FOutputFile );
      end ;
   except
      FErrorStatus := errStDeleteOutputFile ;
   end ;
end ;
// -----------------------------------------------------------------------------
function TCopyFromFloppy.DecompressFiles : boolean ;
var
   i : integer ;
   MemoryStream : TMemoryStream ;
   Compressor   : TCompressor ;
begin

   result := TRUE ;
   MemoryStream := TMemoryStream.Create ;
   Compressor   := TCompressor.Create   ;
   try
      for i := 0 to FCopyFileNames.Count -1 do
      begin
         // Load the information from file
         FInputFile := FCopyFileNames[ i ];
         OpenInputFile ;

         // Decompress the information
         MemoryStream.Clear ;
         Compressor.DeCompressStream( FInputStream, MemoryStream );
         //MemoryStream.LoadFromStream( FInputStream ) ;
         CloseInputFile ;

         // Create again the file with uncompress information
         DeleteFile( FInputFile ) ;
         FOutputFile := FInputFile ;
         OpenOutputFile ;
         MemoryStream.Position := 0 ;
         FOutputStream.CopyFrom( MemoryStream, MemoryStream.Size );
         CloseOutputFile ;

      end ;
   except
      result := FALSE ;
      FErrorStatus := errStDecompressing ;
   end ;

   MemoryStream.Free ;
   Compressor.Free ;

end ;

end.
