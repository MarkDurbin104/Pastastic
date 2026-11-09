unit MPDelTreeU;

{
     TMPDelTree : a component to have the behaviour of the good old dos deltree command

     V1.0 april 06, 1998
     freeware (c) by markus stephany , mirbir.st@t-online.de

     Merkes' Pages = http://home.t-online.de/home/mirbir.st/


     (idea by almer tigelaar, almer-t@usa.net )

     this is freeware, not pd and may be used in any free, shareware or commercial application

     usage :
           properties :
                      Path    : TFileName   = the root of the tree to be deleted
                      Verbose : Boolean     = show a message or not, if any error occurs

           events     :
                      OnProcessFile ( Sender : TObject ; FileName : TFileName ; SearchRec : TSearchRec ;
                                      var Cancel : Boolean )

                        can be assigned to show the progress of the deletion and/or to cancel the operation

          function    :
                      Execute : Boolean = DELTREE , returns true, if the path is deleted (or doesn't exist)
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, FileCtrl;

type

  TMPDelTreeEvent = procedure ( Sender : TObject ; FileName : TFileName ; SearchRec : TSearchRec ;
                                var Cancel : Boolean ) of object;

  TMPDelTree = class(TComponent)
  private
    { Private-Deklarationen }
    fPath : TFileName;
    fVerbose : Boolean;
    fWasVerb : Boolean;
    fMPDTEvent : TMPDelTreeEvent;

    procedure Message ( MSG , Value : string );
  protected
    { Protected-Deklarationen }
  public
    { Public-Deklarationen }
    constructor Create ( AOwner : TComponent ) ; override;
    function Execute : Boolean;
  published
    { Published-Deklarationen }
    property Path : TFileName read fPath write fPath;
    property Verbose  : Boolean read fVerbose write fVerbose;
    property OnProcessFile : TMPDelTreeEvent read fMPDTEvent write fMPDTEvent;
  end;

procedure Register;

implementation

// string constants
const
     M_NotExist = 'The directory %s doesn''t exist';
     M_CantDelDir = 'Cannot delete directory %s';
     M_CantDelFile = 'Cannot delete file %s';
     M_Aborted = 'DelTree aborted by user !';

constructor TMPDelTree.Create ( AOwner : TComponent ) ;
begin
     inherited Create ( AOwner ) ;
     fPath := '<..>' ; // to avoid running without setting a specified path
     fVerbose := False;
end;

function TMPDelTree.Execute : Boolean;

         function DelBSL ( Path : TFileName ) : TFileName;
         // delete a trailing backslash
         begin

              Result := Path;
              if Path <> '' then
                 if Path [ Length ( Path ) ] = '\' then
                    Delete ( Result , Length ( Result ) , 1 );

         end;

         function DelTree ( Path : TFileName ) : Boolean;
         var SRec : TSearchRec ;
             Res  : Integer ;
             fca  : Boolean ;

         begin
              fca := False;
              Result := True;

              Path := Path + '\';
              FillChar ( SRec , SizeOf ( TSearchRec ) , 0 );
              Res := FindFirst ( Path + '*.*' , faAnyFile - faVolumeID , SRec );
              while Res = 0 do  begin

                    with SRec do begin

                         if ( Attr and faDirectory ) = faDirectory then begin

                            if ( Name <> '.' ) and ( Name <> '..' ) then

                               Result := DelTree ( Path + SRec.Name );

                         end

                         else begin

                              if Assigned ( fMPDTEvent ) then begin
                                 fca := False;
                                 fMPDTEvent ( Self , Path + Srec.Name , Srec , fca );
                                 if fca then begin

                                    Result := False;
                                    FindClose ( SRec ) ;
                                    Message ( M_Aborted , '' );
                                    Exit;

                                 end;
                              end;

                              FileSetAttr ( Path + SRec.Name , 0 );
                              Result := DeleteFile ( Path + SRec.Name ) ;
                              if not Result then begin
                                 FindClose ( SRec ) ;
                                 Message ( M_CantDelFile , Path + SRec.Name );
                                 Exit;
                              end;

                         end;
                    end;
                    Res := FindNext ( SRec ) ;
              end;

              FindClose ( SRec );

              try
                 FileSetAttr ( DelBSL ( Path ) , 0 );
                 RmDir ( DelBSL ( Path ) );
              except
                    Result := False ;
                    Message ( M_CantDelDir , DelBSL ( Path ) );
              end;

         end;

begin
     fWasVerb := False;
     SetCurrentDir ( GetCurrentDir + '\..' ); // we have to change the current directory if it is the path to be deleted
     fPath := DelBSL ( fPath );
     Result := True;
     if not DirectoryExists ( fPath ) then begin
        Message ( M_NotExist , fPath );
        // result is true cause the directory doesn't exist, and that is what we want
        Exit;
     end;
     Result := DelTree ( fPath );
end;

procedure TMPDelTree.Message ( MSG , Value : string );
begin

     if fVerbose and ( not fWasVerb ) then
        ShowMessage ( Format ( MSG , [Value] ) );
        
     fWasVerb := True;
end;


procedure Register;
begin
  RegisterComponents('Samples', [TMPDelTree]);
end;

end.
