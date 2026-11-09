/*
 *   Test_API.c - Program to test the RemoteWare Node API calls
 */

//		Includes

#include <windows.h>
#include <commdlg.h>

#include <stdio.h>   
#include <stdlib.h>
#include <string.h>
#include <time.h>   

#define	INCL_RWN_DIALDIR
#define	INCL_RWN_OBJECT

#include "rwnapi.h"               
#include "resource.h"   
#include "test_api.h"

//		Local prototypes

BOOL InitApplication (
	HANDLE	hInst
) ;

BOOL InitInstance (
	HANDLE	hInst, 
	int		nCmdShow
);

long FAR PASCAL ClientWndProc(
	HANDLE		hwnd, 
	unsigned	msg, 
	WORD		wp, 
	LONG		lp
);

BOOL FAR PASCAL QueryObjectsDlgProc( 
	HWND hDlg, 
	UINT msg, 
	WORD wp, 
	LONG lp 
);

BOOL FAR PASCAL QueryObjectInfoDlgProc( 
	HWND hDlg, 
	UINT msg, 
	WORD wp, 
	LONG lp 
);

VOID CALLBACK _export QueryObjectsCallBack( 
	RWNOBJQUERY FAR * lpRNWObjQuery 
);

BOOL FAR PASCAL WorklistDlgProc( 
	HWND hDlg, 
	UINT msg, 
	WORD wp, 
	LONG lp 
);

BOOL FAR PASCAL RequestDlgProc( 
	HWND hDlg, 
	UINT message, 
	WORD wParam, 
	LONG lParam 
);
               
BOOL FAR PASCAL GetInfoDlgProc( 
	HWND hDlg, 
	UINT message, 
	WORD wParam, 
	LONG lParam 
);

BOOL FAR PASCAL ReadWriteDlgProc(
	HWND hDlg, 
	UINT message, 
	WORD wParam, 
	LONG lParam 
);

BOOL FAR PASCAL ResultDlgProc( 
	HWND hDlg, 
	UINT message, 
	WORD wParam, 
	LONG lParam 
);

//		Global variables	

HANDLE      hInstance  = 0;
HWND        hwndClient = 0;
HWND        hwndLB  = 0;
HWND        hwndDlg = 0;          

RWHFILE		fhWorklist = 0;
                      
XNODE_INFO	xnodeInfo;                      
XNODE_DATA	xnodeData;
UINT		uiAction;
INT			apiReturnCode;

//		The usual Windows rigamarole begins here

int FAR PASCAL WinMain(
	HANDLE	hInst, 
	HANDLE	hPrevInst, 
	LPSTR	lpCmdLine, 
	int 	nCmdShow
){
    MSG     msg ;

    if (!hPrevInst)
        if (!InitApplication (hInst))
            return 0 ;

    if (!InitInstance (hInst, nCmdShow))
        return 0 ;

    while (GetMessage (&msg, NULL, NULL, NULL))
    {
        TranslateMessage (&msg) ;
        DispatchMessage (&msg) ;
    }
    
 
    return msg.wParam ;
}

BOOL InitApplication(
	HANDLE hInst
){
    WNDCLASS    wc ;

    memset (&wc, 0, sizeof (wc)) ;

    wc.lpfnWndProc    = ClientWndProc ;
    wc.hInstance      = hInst ;
    wc.hIcon          = LoadIcon (NULL, IDI_APPLICATION) ;
    wc.hCursor        = LoadCursor (NULL, IDC_ARROW) ;
    wc.hbrBackground  = GetStockObject (WHITE_BRUSH) ;
    wc.lpszMenuName   = MAKEINTRESOURCE (ID_MENU) ;
    wc.lpszClassName  = szCLASS ;

    return (RegisterClass (&wc)) ;
}

BOOL InitInstance (
	HANDLE	hInst, 
	int		nCmdShow
){
    hInstance = hInst ;

    hwndClient = CreateWindow ( szCLASS
                              , szTITLE
                              , WS_OVERLAPPEDWINDOW
                              , CW_USEDEFAULT
                              , CW_USEDEFAULT
                              , CW_USEDEFAULT
                              , CW_USEDEFAULT
                              , NULL
                              , NULL
                              , hInst
                              , NULL
                              ) ;

    if (hwndClient) {
        ShowWindow (hwndClient, nCmdShow) ;
        UpdateWindow (hwndClient) ;
    }

    return NULL != hwndClient ;
}

long FAR PASCAL ClientWndProc(
	HWND		hwnd, 
	unsigned	msg, 
	WORD		wp, 
	LONG		lp
){                                                                     
	FARPROC lpfnDlgProc;
	
    switch (msg) {
        case WM_COMMAND :
            switch (wp) {
		        case IDM_DIALDIR :
                    apiReturnCode = RWNodeDialDirConnect( 0 );
                                                               
					//		Pop up the result code from the dialog                                                               
                                                               
                    lpfnDlgProc = MakeProcInstance( (FARPROC) ResultDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "ResultDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
                    break ;           
                    
                case IDM_DIALDIALOG :
                    apiReturnCode = RWNodeDialDirDialog( hwnd );
                                                               
					//		Pop up the result code from the dialog                                                               
                                                               
                    lpfnDlgProc = MakeProcInstance( (FARPROC) ResultDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "ResultDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
                	break;
                    
		        case IDM_OBJOBJS : 
                    lpfnDlgProc = MakeProcInstance( (FARPROC) QueryObjectsDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "ObjQueryObjectsDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
                    break ;
                    
		        case IDM_OBJINFO : 
                    lpfnDlgProc = MakeProcInstance( (FARPROC) QueryObjectInfoDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "ObjQueryInfoDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
                    break ;
                    
		        case IDM_WORKLISTS_ADDWORKLISTRECORD : 
		        	uiAction = 0; 		// do not use the RWNWorklistAction API
                    lpfnDlgProc = MakeProcInstance( (FARPROC) WorklistDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "WorklistActionDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
                    break ;
                    
		        case IDM_WORKLISTS_WORKLISTOPEN : 
					{
						OPENFILENAME ofn;
						char szDirName[256],
						     szFile[256], 
							 szFileTitle[256];

						memset(&ofn, 0, sizeof(OPENFILENAME));

						szDirName[0] = '\0';
						szFile[0] = '\0';

						ofn.lStructSize = sizeof(OPENFILENAME);
						ofn.hwndOwner = hwnd;
						ofn.lpstrFilter = "All Files\0*.*\0\0";
						ofn.nFilterIndex = 1;
						ofn.lpstrFile= szFile;
						ofn.nMaxFile = sizeof(szFile);
						ofn.lpstrFileTitle = szFileTitle;
						ofn.nMaxFileTitle = sizeof(szFileTitle);
						ofn.lpstrInitialDir = szDirName;
						ofn.Flags = OFN_HIDEREADONLY | OFN_PATHMUSTEXIST ;

						if ( GetOpenFileName( &ofn ) ) {
    						RWNWorklistOpen( &fhWorklist,
    				 						 ofn.lpstrFile );
    				 
							//		Pop up the result code from the dialog                                                               
                                                               
                    		lpfnDlgProc = MakeProcInstance( (FARPROC) ResultDlgProc,
                                                    		hInstance );
                    		DialogBox( hInstance, 
                    				   "ResultDlg", 
                    		   		   hwnd, 
                               		   lpfnDlgProc );
                    		FreeProcInstance( lpfnDlgProc );
                    	}
                    }
                    break ;
                    
		        case IDM_WORKLISTS_READ :        
		        	uiAction = WLA_READ; 
                    lpfnDlgProc = MakeProcInstance( (FARPROC) WorklistDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "WorklistActionDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
		        	break;
		        	
		        case IDM_WORKLISTS_WRITE :        
		        	uiAction = WLA_WRITE;
                    lpfnDlgProc = MakeProcInstance( (FARPROC) WorklistDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "WorklistActionDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
		        	break;
		        	
		        case IDM_WORKLISTS_APPEND :        
		        	uiAction = WLA_APPEND;
                    lpfnDlgProc = MakeProcInstance( (FARPROC) WorklistDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "WorklistActionDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
		        	break;
		        	
		        case IDM_WORKLISTS_DELETE :        
		        	uiAction = WLA_DELETE;
                    lpfnDlgProc = MakeProcInstance( (FARPROC) WorklistDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "WorklistActionDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
		        	break;
                    
		        case IDM_WORKLISTS_WORKLISTCLOSE : 
                    apiReturnCode = RWNWorklistClose( fhWorklist,
                    								  FALSE );		// no compression on close
                                                               
					//		Pop up the result code from the dialog                                                               
                                                               
                    lpfnDlgProc = MakeProcInstance( (FARPROC) ResultDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "ResultDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
                    
                    fhWorklist = 0;
                    break ;
                    
				case IDM_OTHER_GETINFO :
                    lpfnDlgProc = MakeProcInstance( (FARPROC) GetInfoDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "GetInfoDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
                    break;
                    
				case IDM_OTHER_NODEREQUEST :         
                    lpfnDlgProc = MakeProcInstance( (FARPROC) RequestDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "RequestDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
					break;
					
				case IDM_OTHER_READDATA :
                    lpfnDlgProc = MakeProcInstance( (FARPROC) ReadWriteDlgProc,
                                                    hInstance );
                    DialogBox( hInstance,
                    		   "ReadWriteDlg", 
                    		   hwnd, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
					break;
            }
            break ;

        case WM_DESTROY :
            PostQuitMessage (0) ;
            break ;

        default :
            return DefWindowProc (hwnd, msg, wp, lp) ;
     }

     return 0L ;
}

///////////////////////////////////////////////////////////////////////
//		Object dialogs
        
BOOL FAR PASCAL QueryObjectsDlgProc( 
	HWND hDlg, 
	UINT message, 
	WORD wParam, 
	LONG lParam 
){
    switch ( message ) {
        case WM_INITDIALOG :
            SendDlgItemMessage( hDlg, IDCB_ALL, BM_SETCHECK, TRUE, 0L );
            SendDlgItemMessage( hDlg, IDCB_NODE, BM_SETCHECK, FALSE, 0L );
            SendDlgItemMessage( hDlg, IDCB_EXPAND, BM_SETCHECK, FALSE, 0L );
            SetFocus( GetDlgItem( hDlg, IDPB_CALLAPI ) );
            hwndLB = GetDlgItem( hDlg, IDLB_OBJECTS );
            hwndDlg = hDlg;
            return TRUE;

        case WM_COMMAND :
        	switch ( wParam ) {
                case IDPB_CALLAPI :
                {
                    FARPROC     lpfnProcInstance;
                    RWNOBJQUERY ObjQuery;

                    lpfnProcInstance = MakeProcInstance( (FARPROC) QueryObjectsCallBack,
                                                         hInstance );

                    memset( &ObjQuery, 0, sizeof( ObjQuery ) );
                    ObjQuery.pfCallBack = (PFRWNOBJQCALLBACK)lpfnProcInstance;

                    if ( SendDlgItemMessage( hDlg, 
                                             IDCB_ALL, 
                                             BM_GETCHECK, 0, 0L ) ) {
                        ObjQuery.fFlags |= RWNOF_ALLOBJECTS;
                    }

                    if ( SendDlgItemMessage( hDlg, 
                                             IDCB_NODE, 
                                             BM_GETCHECK, 0, 0L ) ) {
                        ObjQuery.fFlags |= RWNOF_NODEOBJECTS;
                    }

                    if ( SendDlgItemMessage( hDlg, 
                                             IDCB_EXPAND, 
                                             BM_GETCHECK, 0, 0L ) ) {
                        ObjQuery.fFlags |= RWNOF_EXPANDAPPGRPS;
                    }

                    SendDlgItemMessage( hDlg,
                                        IDLB_OBJECTS,
                                        LB_RESETCONTENT,
                                        0, 0L );

                    RWNObjectQueryObjects( 1, 
                                           &ObjQuery,
                                           sizeof ( ObjQuery ) );

                    FreeProcInstance( lpfnProcInstance );

                    return TRUE;
                }

                case IDCANCEL :
                    EndDialog( hDlg, 0 );
                    return TRUE;
            }
            break;
    }
    return FALSE;
}

BOOL FAR PASCAL QueryObjectInfoDlgProc(
	HWND hDlg, 
	UINT message, 
	WORD wParam, 
	LONG lParam
){
    char    szObjectName[ CCHRWNOBJNAME ];
    switch ( message ) {
        case WM_INITDIALOG :
        {
            FARPROC     lpfnProcInstance;
            RWNOBJQUERY ObjQuery;

            SetFocus( GetDlgItem( hDlg, IDPB_CALLAPI ) );
            hwndLB = GetDlgItem( hDlg, IDLB_OBJECTS );
            lpfnProcInstance = MakeProcInstance( (FARPROC) QueryObjectsCallBack,
                                                 hInstance );

            memset( &ObjQuery, 0, sizeof( ObjQuery ) );
            ObjQuery.pfCallBack = (PFRWNOBJQCALLBACK)lpfnProcInstance;

            ObjQuery.fFlags |= RWNOF_ALLOBJECTS;

            SendDlgItemMessage( hDlg,
                                IDLB_OBJECTS,
                                LB_RESETCONTENT,
                                0, 0L );

            RWNObjectQueryObjects( 1,
                                   &ObjQuery,
                                   sizeof ( ObjQuery ) );

            FreeProcInstance( lpfnProcInstance );

            SendMessage( hwndLB, LB_SETCURSEL, 0, 0L );

            return TRUE;
        }

        case WM_COMMAND :
            switch ( wParam ) {
                case IDPB_CALLAPI :
                {
                    WORD        nIndex;
                    RWNOBJINFO  ObjInfo;

                    nIndex = ( WORD ) SendMessage( hwndLB, LB_GETCURSEL, 0, 0L );

                    if ( nIndex == LB_ERR ) {
                        MessageBox( hDlg, "No Objects Selected!", "",
                                    MB_ICONINFORMATION | MB_OK );
                        break;
                    }

                    SendMessage( hwndLB, LB_GETTEXT, nIndex, 
                                (LONG) (LPSTR) szObjectName );


                    if ( RWNObjectQueryInfo( 1,
                                             (PSZ) szObjectName,
                                             (RWNOBJINFO FAR *) &ObjInfo,
                                             sizeof ObjInfo ) ) {
                        MessageBox( hDlg, "Error in RWNObjectQueryInfo()!", "Error!",
                                    MB_ICONINFORMATION | MB_OK );
                    }
                    else {
                        SendMessage( GetDlgItem( hDlg, IDTXT_NAME ),
                                    WM_SETTEXT, 0, 
                                    (LONG) (LPSTR) ObjInfo.szName );
                                    
                        switch( ObjInfo.bType ) {
                            case ( WOTY_ESD ):
                                SendMessage( GetDlgItem( hDlg, IDTXT_TYPE ),
                                             WM_SETTEXT, 0, 
                                             (LONG) (LPSTR) "ESD" );
                                break;                         
                                
                            case ( WOTY_APPLICATION ):
                                SendMessage( GetDlgItem( hDlg, IDTXT_TYPE ),
                                             WM_SETTEXT, 0, 
                                             (LONG) (LPSTR) "Application" );
                                break;
                                
                            case ( WOTY_APPLICATION_GROUP ):
                                SendMessage( GetDlgItem( hDlg, IDTXT_TYPE ),
                                             WM_SETTEXT, 0, 
                                             (LONG) (LPSTR) "Application Group" );
                                break;
                                
                            case ( WOTY_WORKLIST ):
                                SendMessage( GetDlgItem( hDlg, IDTXT_TYPE ),
                                             WM_SETTEXT, 0, 
                                             (LONG) (LPSTR) "Worklist" );
                                break;
                                
                            case ( WOTY_GROUP ):
                                SendMessage( GetDlgItem( hDlg, IDTXT_TYPE ),
                                             WM_SETTEXT, 0, 
                                             (LONG) (LPSTR) "Group" );
                                break;
                                
                            default:
                                SendMessage( GetDlgItem( hDlg, IDTXT_TYPE ),
                                             WM_SETTEXT, 0, 
                                             (LONG) (LPSTR) "??? Unknown ???" );
                                break;
                        }
                        switch( ObjInfo.bExecution ) {
                            case ( WOEX_DEFAULT ):
                                SendMessage( GetDlgItem( hDlg, IDTXT_EXEC ),
                                             WM_SETTEXT, 0, 
                                             (LONG) (LPSTR) "Default" );
                                break;               
                                
                            case ( WOEX_FORCED ):
                                SendMessage( GetDlgItem( hDlg, IDTXT_EXEC ),
                                             WM_SETTEXT, 0, 
                                             (LONG) (LPSTR) "Forced" );
                                break;
                                
                            case ( WOEX_REQUESTABLE ):
                                SendMessage( GetDlgItem( hDlg, IDTXT_EXEC ),
                                             WM_SETTEXT, 0, 
                                             (LONG) (LPSTR) "Requestable" );
                                break;
                                
                            default:
                                SendMessage( GetDlgItem( hDlg, IDTXT_EXEC ),
                                             WM_SETTEXT, 0, 
                                             (LONG) (LPSTR) "??? Unknown ???" );
                                break;
                        }
                        SendMessage( GetDlgItem( hDlg, IDTXT_STATUS ),
                                    WM_SETTEXT, 0, 
                                    (LONG) (LPSTR) ( ObjInfo.bStatus ? "ENABLED" : 
                                                                       "DISABLED" ) );

                        wsprintf( szObjectName, "%d", ObjInfo.bPriority );
                        SendMessage( GetDlgItem( hDlg, IDTXT_PRIORITY ),
                                    WM_SETTEXT, 0, 
                                    (LONG) (LPSTR) szObjectName );
                    }

                    return TRUE;
                }

                case IDCANCEL :
                    EndDialog( hDlg, 0 );
                    return TRUE;
            }
            break;
    }
    return FALSE;
}

VOID CALLBACK _export QueryObjectsCallBack( 
	RWNOBJQUERY FAR * lpObjQuery 
){
    SendMessage( hwndLB, 
                 LB_ADDSTRING, 
                 0, 
                 (LONG) (LPSTR) lpObjQuery->ObjInfoRec.szName );   
}
                                          
///////////////////////////////////////////////////////////////////////                                          
//		Worklist dialog
//		We use the same dialog to demonstrate both 
//		RWNodeAddWorklistRecord() and RWNWorklistAction().  The only
//		differences between the functions is that AddWorklistRecord
//		requires a file name and WorklistAction requires a record 
//		number.

BOOL FAR PASCAL WorklistDlgProc( 
	HWND hDlg, 
	UINT message, 
	WORD wParam, 
	LONG lParam 
){               
    INT		i;                
	HWND	hwndCB;                              
	FARPROC lpfnDlgProc;
	
	//		If the commands were ordinal values from 0, this table would be
	//		completely unnecessary.  However, some older commands have become
	//		obsolete, and so there are "holes" in the value range.
	//
	//		Here we create a table which lets us use the index returned
	//		by the drop-down combo box to fetch a specific command's value.
	//		The same table is used to stuff the listbox at dialog time.
	         
	typedef struct _WLCMD {
		INT		iCmdValue;
		PSZ		pszCmdName;
	} WLCMD, *PWLCMD;
	static WLCMD awlCmdTable[] = {
		{ WL_SENDFILE		, "Send File" 		},
		{ WL_GETFILE        , "Get File" 		},
		{ WL_SENDDIR        , "Send Dir" 		},
		{ WL_GETDIR         , "Get Dir" 		},
		{ WL_RENAMEFILE     , "Rename File" 	},
		{ WL_DELETEFILE     , "Delete File" 	},
		{ WL_COPYFILE       , "Copy File" 		},
		{ WL_APPENDFILE     , "Append File" 	},
		{ WL_FILESTAT       , "File Stat" 		},
		{ WL_DIRECTORY      , "Directory" 		},
		{ WL_CHECKDISK      , "Check Disk" 		},
		{ WL_MAKEDIR        , "Make Dir" 		},
		{ WL_REMOVEDIR      , "Remove Dir" 		},
		{ WL_SETTIME        , "Set Time"	 	},
		{ WL_EXECUTE        , "Execute" 		},
		{ WL_WORKLIST       , "Worklist" 		},
		{ WL_NOTIFY         , "Notify" 			},
		{ WL_REBOOT_NODE    , "Reboot Node" 	},
		{ WL_WORKQUEUE      , "Workqueue" 		},
		{ WL_WAIT           , "Wait" 			},
		{ WL_ASCII_APPEND   , "ASCII Append"	},
		{ WL_USER_ALARM     , "User Alarm" 		},
		{ WL_END_SESSION    , "End Session" 	},
		{ WL_IF_TRUE        , "If TRUE" 		},
		{ WL_IF_FALSE       , "If FALSE" 		},
		{ WL_ELSE_IF        , "Else" 			},
		{ WL_END_IF         , "End IF" 			},
		{ WL_GROUP_TEST     , "Group Test" 		},
		{ WL_COMMENT        , "Comment" 		},
		{ WL_SET_VARIABLE   , "Set Variable" 	},
		{ WL_TEST_VARIABLE  , "Test Variable" 	},
		{ WL_CHECK_FILE     , "Check File" 		}
	};

    switch ( message ) {
        case WM_INITDIALOG :           
        
        	//	based on the call type, set the value of the
        	//	dialog title, entryfield static text, and pushbutton
        	
        	switch ( uiAction ) {
        		case WLA_READ:
        			SetWindowText(  hDlg, "RWNWorklistAction - Read" );
        			SetDlgItemText( hDlg, IDPB_CALLAPI, "Call RWNWorklistAction" );
        			SetDlgItemText( hDlg, IDC_WL_EF,    "Record number" );
        			break;
        			
        		case WLA_WRITE:
        			SetWindowText(  hDlg, "RWNWorklistAction - Write" );
        			SetDlgItemText( hDlg, IDPB_CALLAPI, "Call RWNWorklistAction" );
        			SetDlgItemText( hDlg, IDC_WL_EF,    "Record number" );
          			break;
        			
        		case WLA_APPEND:
        			SetWindowText(  hDlg, "RWNWorklistAction - Append" );
        			SetDlgItemText( hDlg, IDPB_CALLAPI, "Call RWNWorklistAction" );
        			SetDlgItemText( hDlg, IDC_WL_EF,    "Record number" );
        			break;
        			
        		case WLA_DELETE:                                     
        			SetWindowText(  hDlg, "RWNWorklistAction - Delete" );
        			SetDlgItemText( hDlg, IDPB_CALLAPI, "Call RWNWorklistAction" );
        			SetDlgItemText( hDlg, IDC_WL_EF,    "Record number" );
        			break;
        			
        		default:
        			SetWindowText(  hDlg, "RWNAddWorklistRecord" );
        			SetDlgItemText( hDlg, IDPB_CALLAPI, "Call RWNAddWorklistRecord" );
        			SetDlgItemText( hDlg, IDC_WL_EF,    "Worklist file" );
        			break;
        	}
        
        	//	reset all checkboxes to zero
        
            CheckDlgButton( hDlg, IDCB_WL_NO_OVERWRITE,		0 );
            CheckDlgButton( hDlg, IDCB_WL_IF_CHANGED, 		0 );
            CheckDlgButton( hDlg, IDCB_WL_SAFE_XFER, 		0 );
            CheckDlgButton( hDlg, IDCB_WL_CRITICAL, 		0 );
            CheckDlgButton( hDlg, IDCB_WL_DEL_IF_SUCCESS,	0 );
            CheckDlgButton( hDlg, IDCB_WL_CRIT_RETRIES, 	0 );
            CheckDlgButton( hDlg, IDCB_WL_NOT_REQUIRED,  	0 );
            CheckDlgButton( hDlg, IDCB_WL_NO_COMPRESS, 		0 );
            CheckDlgButton( hDlg, IDCB_WL_IF_TRUE, 			0 );
            CheckDlgButton( hDlg, IDCB_WL_IF_FALSE,			0 );
            CheckDlgButton( hDlg, IDCB_WL_UPDATE_IF_NEWER, 	0 );
                                            
            //	use AT SERVER and DURING as defaults on radio button                           
                                            
            CheckRadioButton( hDlg, IDRB_WL_AT_SERVER, IDRB_WL_AT_NODE, IDRB_WL_AT_SERVER );
            CheckRadioButton( hDlg, IDRB_WL_BEFORE, IDRB_WL_AFTER, IDRB_WL_DURING );
                                                        
            //	stuff the combo box with commands, and force a default
                                                        
            hwndCB = GetDlgItem( hDlg, IDDD_WL_CMD );
            for ( i = 0; 
            	  i < (sizeof( awlCmdTable ) / sizeof( WLCMD )); 
            	  i++) {
				SendMessage( hwndCB, 
							 CB_ADDSTRING, 
							 0, 
							 (LONG) (LPSTR) awlCmdTable[i].pszCmdName );
			}
			SendDlgItemMessage( hDlg, 
								IDDD_WL_CMD, 
                                CB_SETCURSEL, 0, 0L );

            hwndDlg = hDlg;
            return TRUE;

        case WM_COMMAND :
            switch ( wParam ) {
                case IDPB_CALLAPI :
                {                                          
		        	RWWORKLIST	worklistRec;
                	CHAR	achWLfile[256],	// doubles as record number 
                							// for RWNWorklistAction calls
                			achParm1[256],
                			achParm2[256];
                	INT		iCmd;
                	BYTE	bWhere, bWhen = WL_DURING;
                	ULONG	ulOptions = 0;

					//		Get the parameters in the order needed for the call
					//		First, the worklist filename
					
					memset( achWLfile, 
							0, 
							sizeof( achWLfile ) );						                                                  
					GetWindowText( GetDlgItem( hDlg, IDEF_WL_EF ), 
									achWLfile, 
									sizeof( achWLfile ) - 1 );
									
					//		Next the command value
					
                    iCmd = (INT) SendDlgItemMessage( hDlg, 
                                               		 IDDD_WL_CMD, 
                                               		 CB_GETCURSEL,
                                               		 0, 
                                               		 0L );
                    iCmd = awlCmdTable[iCmd].iCmdValue;                       
					                                   
					//		Next the WHERE and WHEN values

					if (IsDlgButtonChecked( hDlg, IDRB_WL_AT_SERVER )) {
						bWhere = WL_ON_SERVER;
					}                         
					else {
						bWhere = WL_ON_NODE;
					}                           
					
					if (IsDlgButtonChecked( hDlg, IDRB_WL_BEFORE )) {
						bWhen = WL_BEFORE;
					}                   
					else if (IsDlgButtonChecked( hDlg, IDRB_WL_DURING )) {
						bWhen = WL_DURING;
					}                   
					else {
						bWhen = WL_AFTER;
					}                           
					
					//		Even though the parameters are optional in many cases,
					//		we get them here unconditionally to give the API user
					//		complete freedom to beat us up as needed
					
					memset( achParm1, 
							0, 
							sizeof( achParm1 ) );						                                                  
					GetWindowText( GetDlgItem( hDlg, IDEF_WL_PARM1 ), 
									achParm1, 
									sizeof( achParm1 ) - 1 );
									
					memset( achParm2, 
							0, 
							sizeof( achParm2 ) );						                                                  
					GetWindowText( GetDlgItem( hDlg, IDEF_WL_PARM2 ), 
									achParm2, 
									sizeof( achParm2 ) - 1 );
									
					//		Finally, combine all checkboxes into a flag value
					
					if (IsDlgButtonChecked( hDlg, IDCB_WL_NO_OVERWRITE )) {
						ulOptions |= WL_NO_OVERWRITE;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_WL_IF_CHANGED )) {
						ulOptions |= WL_UPDATEFILE;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_WL_SAFE_XFER )) {
						ulOptions |= WL_SAFE_SEND;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_WL_CRITICAL )) {
						ulOptions |= WL_CRITICAL;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_WL_DEL_IF_SUCCESS )) {
						ulOptions |= WL_DELETE_AFTER;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_WL_CRIT_RETRIES )) {
						ulOptions |= WL_CRITICAL_RETRY;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_WL_NO_COMPRESS )) {
						ulOptions |= WL_NO_COMPRESS;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_WL_NOT_REQUIRED )) {
						ulOptions |= WL_NOT_NEEDED;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_WL_IF_TRUE )) {
						ulOptions |= WL_CONDITIONAL_TRUE;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_WL_IF_FALSE )) {
						ulOptions |= WL_CONDITIONAL_FALSE;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_WL_UPDATE_IF_NEWER )) {
						ulOptions |= WL_SEND_NEWER;
					}                 

					//		All set - make the call
					                                                  
		        	if (uiAction > 0) {                               
			        	UINT		uiCount = 1;	// We force the count of 1
			        								// since there is only a 
			        								// single structure allocated here
		        	                                  
						worklistRec.cb = sizeof( worklistRec );
						worklistRec.iRecordNumber = atoi( achWLfile );
						worklistRec.sCommand = iCmd;
						worklistRec.bWhere = bWhere;
						worklistRec.bWhen = bWhen;
						worklistRec.ulOptions = ulOptions;
						worklistRec.lUserContext = 0;
						worklistRec.usReferenceCount = 0;
						strncpy( worklistRec.szParam1,
								 achParm1,
								 sizeof( worklistRec.szParam1 ) );
						strncpy( worklistRec.szParam2,
								 achParm2,
								 sizeof( worklistRec.szParam2 ) );
		        	                                  
            	        apiReturnCode = RWNWorklistAction( fhWorklist,
                	                                       uiAction,
                    	                                   &worklistRec,
                    									   &uiCount );
                    }
					else {                                                               
						apiReturnCode = RWNAddWorklistRecord( achWLfile,
							iCmd,
							achParm1,
							achParm2,
							bWhere,  
							bWhen,
							ulOptions );
					}
						
					//		Pop-up the result code for all to see
	
                    lpfnDlgProc = MakeProcInstance( (FARPROC) ResultDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "ResultDlg", 
                    		   hDlg, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );      
                    
                    //		If the call was for a read, then update all 
                    //		of the controls to reflect the record received

					if ( uiAction == WLA_READ ) {
								 
						//		First, the command value

						iCmd = 0;						
			            for ( i = 0; 
        			    	  i < (sizeof( awlCmdTable ) / sizeof( WLCMD )); 
            				  i++) {
							if ( awlCmdTable[i].iCmdValue == worklistRec.sCommand ) {
								iCmd = i;
							}
						}
						
        	            SendDlgItemMessage( hDlg, 
            	                            IDDD_WL_CMD, 
                	                        CB_SETCURSEL,
                    	                    iCmd, 
                        	                0L );
                        	                
						//		Next the parameters
								 
						SetWindowText( GetDlgItem( hDlg, IDEF_WL_PARM1 ), 
									   worklistRec.szParam1 );
									
						SetWindowText( GetDlgItem( hDlg, IDEF_WL_PARM2 ),
									   worklistRec.szParam2 );

						//		Next the WHERE value                             

						if ( worklistRec.bWhere == WL_ON_SERVER ) {
			            	CheckRadioButton( hDlg, IDRB_WL_AT_SERVER, IDRB_WL_AT_NODE, IDRB_WL_AT_SERVER );
		    	        }                                        
		        	    else {
		            		CheckRadioButton( hDlg, IDRB_WL_AT_SERVER, IDRB_WL_AT_NODE, IDRB_WL_AT_NODE );
			            }   	

						//		Then the WHEN value
					
						if ( worklistRec.bWhen == WL_BEFORE ) {
		    	        	CheckRadioButton( hDlg, IDRB_WL_BEFORE, IDRB_WL_AFTER, IDRB_WL_BEFORE );
		        	    }    
		            	else if ( worklistRec.bWhen == WL_DURING ) {
		            		CheckRadioButton( hDlg, IDRB_WL_BEFORE, IDRB_WL_AFTER, IDRB_WL_DURING );
			            }	                                    
			            else {
			            	CheckRadioButton( hDlg, IDRB_WL_BEFORE, IDRB_WL_AFTER, IDRB_WL_AFTER );
		    	        }
		            
						//		Finally, update all checkboxes 
					
			            CheckDlgButton( hDlg, IDCB_WL_NO_OVERWRITE, ((worklistRec.ulOptions & WL_NO_OVERWRITE) != 0) );
						CheckDlgButton( hDlg, IDCB_WL_IF_CHANGED,   ((worklistRec.ulOptions & WL_UPDATEFILE ) != 0) );
						CheckDlgButton( hDlg, IDCB_WL_SAFE_XFER,    ((worklistRec.ulOptions & WL_SAFE_SEND ) != 0) );
						CheckDlgButton( hDlg, IDCB_WL_CRITICAL,     ((worklistRec.ulOptions & WL_CRITICAL ) != 0) );
						CheckDlgButton( hDlg, IDCB_WL_DEL_IF_SUCCESS, ((worklistRec.ulOptions & WL_DELETE_AFTER ) != 0) );
						CheckDlgButton( hDlg, IDCB_WL_CRIT_RETRIES, ((worklistRec.ulOptions & WL_CRITICAL_RETRY ) != 0) );
						CheckDlgButton( hDlg, IDCB_WL_NO_COMPRESS,  ((worklistRec.ulOptions & WL_NO_COMPRESS ) != 0) );
						CheckDlgButton( hDlg, IDCB_WL_NOT_REQUIRED, ((worklistRec.ulOptions & WL_NOT_NEEDED ) != 0) );
						CheckDlgButton( hDlg, IDCB_WL_IF_TRUE,		((worklistRec.ulOptions & WL_CONDITIONAL_TRUE ) != 0) );
						CheckDlgButton( hDlg, IDCB_WL_IF_FALSE,     ((worklistRec.ulOptions & WL_CONDITIONAL_FALSE ) != 0) );
						CheckDlgButton( hDlg, IDCB_WL_UPDATE_IF_NEWER, ((worklistRec.ulOptions & WL_SEND_NEWER ) != 0) );
					}
                    return TRUE;
                }

                case IDCANCEL :
                    EndDialog( hDlg, 0 );
                    return TRUE;
            }
            break;
    }
    return FALSE;
}

///////////////////////////////////////////////////////////////////////                                          
//		Request dialog                                          

BOOL FAR PASCAL RequestDlgProc( 
	HWND hDlg, 
	UINT message, 
	WORD wParam, 
	LONG lParam 
){               
	FARPROC lpfnDlgProc;

    switch ( message ) {
        case WM_INITDIALOG :
        
        	//	reset all checkboxes to zero
        
            CheckDlgButton( hDlg, IDCB_REQ_REINIT,		0 );
            CheckDlgButton( hDlg, IDCB_REQ_REMOVE,		0 );
            CheckDlgButton( hDlg, IDCB_REQ_CONNECT1,	0 );
            CheckDlgButton( hDlg, IDCB_REQ_CONNECT2,	0 );
            CheckDlgButton( hDlg, IDCB_REQ_CANCEL,		0 );
            CheckDlgButton( hDlg, IDCB_REQ_ENABLE_AA,	0 );
            CheckDlgButton( hDlg, IDCB_REQ_DISABLE_AA,	0 );
            CheckDlgButton( hDlg, IDCB_REQ_RELEASE_PORT,0 );
            CheckDlgButton( hDlg, IDCB_REQ_ENABLE_ESD,	0 );
            CheckDlgButton( hDlg, IDCB_REQ_DISABLE_ESD,	0 );
                                            
            hwndDlg = hDlg;
            return TRUE;

        case WM_COMMAND :
            switch ( wParam ) {
                case IDPB_CALLAPI :
                {                                          
                	WORD	wOptions = 0;

					//		Get the parameters in the order needed for the call
					//		First, combine all checkboxes into a flag value
					
					if (IsDlgButtonChecked( hDlg, IDCB_REQ_REINIT )) {
						wOptions |= XR_REINIT;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_REQ_REMOVE )) {
						wOptions |= XR_REMOVE;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_REQ_CONNECT1 )) {
						wOptions |= XR_CONNECT1;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_REQ_CONNECT2 )) {
						wOptions |= XR_CONNECT2;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_REQ_CANCEL )) {
						wOptions |= XR_CANCEL;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_REQ_ENABLE_AA )) {
						wOptions |= XR_ENABLE_AA;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_REQ_DISABLE_AA )) {
						wOptions |= XR_DISABLE_AA;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_REQ_RELEASE_PORT )) {
						wOptions |= XR_RELEASE_PORT;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_REQ_ENABLE_ESD )) {
						wOptions |= XR_ENABLE_ESD;
					}
					if (IsDlgButtonChecked( hDlg, IDCB_REQ_DISABLE_ESD )) {
						wOptions |= XR_DISABLE_ESD;
					}

					//		All set - make the call  
					//		Unlike all other calls, we do mask off the
					//		"kernel is alive" bits here to keep the
					//		status code meaningful
					                                                  
					apiReturnCode = RWNodeRequest( wOptions ) & (~XS_COUNTER_MASK);
						
					//		Pop-up the result code for all to see
	
                    lpfnDlgProc = MakeProcInstance( (FARPROC) ResultDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "ResultDlg", 
                    		   hDlg, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
                    
                    return TRUE;
                }

                case IDCANCEL :
                    EndDialog( hDlg, 0 );
                    return TRUE;
            }
            break;
    }
    return FALSE;
}

///////////////////////////////////////////////////////////////////////                                          
//		Read/write node data dialog                                          

BOOL FAR PASCAL ReadWriteDlgProc( 
	HWND hDlg, 
	UINT message, 
	WORD wParam, 
	LONG lParam 
){               
	CHAR	achTimeBuffer[20];
	INT		hour, minute, second, parmcount;
	BOOL	fTranslated;
	FARPROC lpfnDlgProc;

    switch ( message ) {
        case WM_INITDIALOG :
        
					//		Update the controls to match our data structure													
				
		        	SetDlgItemText( hDlg,
        						    IDC_NAME,
        						    xnodeData.name );

		        	SetDlgItemText( hDlg,
        						    IDC_PASSWORD,
        						    xnodeData.password );

		        	SetDlgItemInt( hDlg,
        						   IDC_PORT,
        						   xnodeData.port,
        						   TRUE );

		        	SetDlgItemInt( hDlg,
        						   IDC_BAUDRATE,
        						   xnodeData.baud_rate,
        						   TRUE );

		        	SetDlgItemText( hDlg,
        						    IDC_PHONE1,
        						    xnodeData.server_phone1 );

		        	SetDlgItemText( hDlg,
        						    IDC_PHONE2,
        						    xnodeData.server_phone2 );

		            CheckDlgButton( hDlg, IDC_SCHEDULED, xnodeData.schedule_active );
		            
		        	SetDlgItemInt( hDlg,
        						   IDC_RETRIES,
        						   xnodeData.schedule_retrys,
        						   TRUE );
                                                            
                    sprintf( achTimeBuffer,
                    		 "%02d:%02d:%02d",
                    		 xnodeData.schedule_time / 3600,
                    		 xnodeData.schedule_time / 60 % 60,
                    		 xnodeData.schedule_time % 60 );
		        	SetDlgItemText( hDlg,
        						    IDC_SCHEDULETIME,
        						    achTimeBuffer );
					
            hwndDlg = hDlg;
            return TRUE;

        case WM_COMMAND :
            switch ( wParam ) {
                case IDPB_READINFO :

					//		In the case of a read, the call comes first

					apiReturnCode = RWNodeReadData( &xnodeData,
													sizeof( xnodeData ) );				
													
					//		Update the controls to match our data structure													
				
		        	SetDlgItemText( hDlg,
        						    IDC_NAME,
        						    xnodeData.name );

		        	SetDlgItemText( hDlg,
        						    IDC_PASSWORD,
        						    xnodeData.password );

		        	SetDlgItemInt( hDlg,
        						   IDC_PORT,
        						   xnodeData.port,
        						   TRUE );

		        	SetDlgItemInt( hDlg,
        						   IDC_BAUDRATE,
        						   xnodeData.baud_rate,
        						   TRUE );

		        	SetDlgItemText( hDlg,
        						    IDC_PHONE1,
        						    xnodeData.server_phone1 );

		        	SetDlgItemText( hDlg,
        						    IDC_PHONE2,
        						    xnodeData.server_phone2 );

		            CheckDlgButton( hDlg, IDC_SCHEDULED, xnodeData.schedule_active );
		            
		        	SetDlgItemInt( hDlg,
        						   IDC_RETRIES,
        						   xnodeData.schedule_retrys,
        						   TRUE );
                                                            
            		hour = (INT) xnodeData.schedule_time / 3600;
	   	        	minute = (INT) xnodeData.schedule_time / 60 % 60;
	       	    	second = (INT) xnodeData.schedule_time % 60;
           	    		 
                    sprintf( achTimeBuffer,
   	                		 "%02d:%02d:%02d",
   	                		 hour, 
   	                		 minute, 
   	                		 second );
   	                		 
		        	SetDlgItemText( hDlg,
        						    IDC_SCHEDULETIME,
        						    achTimeBuffer );
					
					//		Pop up the result code from the dialog
                                                               
                    lpfnDlgProc = MakeProcInstance( (FARPROC) ResultDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "ResultDlg", 
                    		   hDlg, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
                    
                    return TRUE;

                case IDPB_WRITEINFO :
                
                	//		First, read the contents of the controls
                	//		back into our data structure

					GetDlgItemText( hDlg, 
									IDC_NAME, 
									xnodeData.name, 
									sizeof( xnodeData.name ));

					GetDlgItemText( hDlg,
									IDC_PASSWORD, 
									xnodeData.password, 
									sizeof( xnodeData.password ));
                                
					xnodeData.port = GetDlgItemInt( hDlg,
													IDC_PORT,
													&fTranslated,
													FALSE );
                                
					xnodeData.baud_rate = GetDlgItemInt( hDlg,
														 IDC_BAUDRATE,
														 &fTranslated,
														 FALSE );
                                
					GetDlgItemText( hDlg,
									IDC_PHONE1,
									xnodeData.server_phone1,
									sizeof( xnodeData.server_phone1 ));
                                
					GetDlgItemText( hDlg,
									IDC_PHONE2, 
									xnodeData.server_phone2,
									sizeof( xnodeData.server_phone2 ));
                                
					if (IsDlgButtonChecked( hDlg, IDC_SCHEDULED )) {
						xnodeData.schedule_active = TRUE;
					}                         
					else {
						xnodeData.schedule_active = FALSE;
					}                           
									
					xnodeData.schedule_retrys = GetDlgItemInt( hDlg,
													  IDC_RETRIES,
													  &fTranslated,
													  FALSE );

					GetDlgItemText( hDlg, 
									IDC_SCHEDULETIME,
									achTimeBuffer, 
									sizeof( achTimeBuffer ));
									
					parmcount = sscanf( achTimeBuffer,
										"%d:%d:%d",
										&hour,
										&minute,
										&second );
										
					if ( parmcount == 3 ) {
						xnodeData.schedule_time = hour * 3600 
												+ minute * 60 
												+ second;
					}

					//		All set - make the call  

					apiReturnCode = RWNodeWriteData( &xnodeData,
													 sizeof( xnodeData ) );				
				
					//		Pop up the result code from the dialog                                                               
                                                               
                    lpfnDlgProc = MakeProcInstance( (FARPROC) ResultDlgProc,
                                                    hInstance );
                    DialogBox( hInstance, 
                    		   "ResultDlg", 
                    		   hDlg, 
                               lpfnDlgProc );
                    FreeProcInstance( lpfnDlgProc );
                    
                    return TRUE;
                                        
				case IDOK :                                        
                case IDCANCEL :
                    EndDialog( hDlg, 0 );
                    return TRUE;
            }
            break;
    }
    return FALSE;
}

///////////////////////////////////////////////////////////////////////
//		GetInfo dialog procedure

BOOL FAR PASCAL GetInfoDlgProc( 
	HWND hDlg, 
	UINT message, 
	WORD wParam, 
	LONG lParam 
){                          
	CHAR	pszDrive[2];
	FARPROC lpfnDlgProc;

    switch ( message ) {
        case WM_INITDIALOG :
			apiReturnCode = RWNodeGetInfo( &xnodeInfo,
											sizeof( xnodeInfo ) );				

			//		Paint the controls with the updated values
				
        	SetDlgItemInt(  hDlg,
   						    IDC_GI_STATUS,
   						    xnodeInfo.status & ~XS_COUNTER_MASK,
   						    TRUE );

        	SetDlgItemText( hDlg,
   						    IDC_GI_LAST_SESSION,
   						    ctime( &xnodeInfo.last_session ) );

        	SetDlgItemInt(  hDlg,
   						    IDC_GI_SESSION_STATUS,
   						    xnodeInfo.bSessStatus,
   						    TRUE );

        	SetDlgItemInt(  hDlg,
   						    IDC_GI_COMMAND,
   						    xnodeInfo.command,
   						    TRUE );

        	SetDlgItemInt(  hDlg,
   						    IDC_GI_FILE_SIZE,
   						    (INT) xnodeInfo.file_size,
   						    TRUE );

        	SetDlgItemInt(  hDlg,
   						    IDC_GI_BYTES_TRANSFERRED,
   						    (INT) xnodeInfo.bytes_transfered,
   						    TRUE );

        	SetDlgItemText( hDlg,
   						    IDC_GI_FILENAME,
   						    xnodeInfo.filename );
                                      
			pszDrive[0] = xnodeInfo.node_drive;
			pszDrive[1] = 0;
        	SetDlgItemText( hDlg,
   						    IDC_GI_NODE_DRIVE,
   						    pszDrive );

        	SetDlgItemInt(  hDlg,
   						    IDC_GI_NODE_MAJOR,
   						    xnodeInfo.node_major,
   						    TRUE );

        	SetDlgItemInt(  hDlg,
   						    IDC_GI_NODE_MINOR,
   						    xnodeInfo.node_minor,
   						    TRUE );

        	SetDlgItemInt(  hDlg,
   						    IDC_GI_RESOURCE,
   						    xnodeInfo.bResource,
   						    TRUE );

        	SetDlgItemInt(  hDlg,
   						    IDC_GI_RSCSTATUS,
   						    xnodeInfo.bRscStatus,
   						    TRUE );

        	SetDlgItemInt(  hDlg,
   						    IDC_GI_RSCERROR,
   						    xnodeInfo.nRscError,
   						    TRUE );

        	SetDlgItemText( hDlg,
   						    IDC_GI_STARTTIME,
   						    ctime( &xnodeInfo.StartTime ) ),

        	SetDlgItemInt(  hDlg,
   						    IDC_GI_CONNECTEDSYSTEM,
   						    (INT) xnodeInfo.ConnectedSystem,
   						    TRUE );

			//		Pop up the result code from the dialog                                                               
                                                               
			lpfnDlgProc = MakeProcInstance( (FARPROC) ResultDlgProc,
                                             hInstance );
			DialogBox( hInstance, 
					   "ResultDlg", 
					   hDlg, 
					   lpfnDlgProc );
			FreeProcInstance( lpfnDlgProc );
                                            
            hwndDlg = hDlg;
            return TRUE;

        case WM_COMMAND :
            switch ( wParam ) {
				case IDOK :                                        
                case IDCANCEL :
                    EndDialog( hDlg, 0 );
                    return TRUE;
            }
            break;
    }
    return FALSE;
}

///////////////////////////////////////////////////////////////////////                                          
//		Standard result code dialog

BOOL FAR PASCAL ResultDlgProc( 
	HWND hDlg, 
	UINT message, 
	WORD wParam, 
	LONG lParam 
){               
    switch ( message ) {
        case WM_INITDIALOG :
        
        	//		display the current API result code's value
        	
        	SetDlgItemInt( hDlg,
        				   IDC_RESULTCODE,
        				   apiReturnCode,
        				   TRUE );
        				   
            hwndDlg = hDlg;
            return TRUE;

        case WM_COMMAND :
            switch ( wParam ) {        
            	case IDOK :
                case IDCANCEL :
                    EndDialog( hDlg, 0 );
                    return TRUE;
            }
            break;
    }
    return FALSE;
}

