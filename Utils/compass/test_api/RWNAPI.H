/* ========================================================================= *

    RWNAPI.H -- XcelleNet RemoteWare Node API

    This file contains the function prototypes and definitions
    for the XcelleNet RemoteWare Node APIs.

    RWNAPI Functions:
    =================

        ------------------- Dialing Directory APIs -------------------------
        INT     RWNodeDialDirConnect        ( HDDIR         hdd ) ;

        INT     RWNodeDialDirDialog         ( HWND          hwndOwner ) ;
        --------------------------------------------------------------------

        ------------------------- Node APIs --------------------------------
        WORD    RWNodeRequest               ( WORD          wRequest ) ;

        BOOL    RWNodeGetInfo               ( PXNODE_INFO   pInfo,
                                              WORD          cbInfo ) ;

        INT     RWNodeReadData              ( PXNODE_DATA   pData,
                                              WORD          cbData ) ;

        INT     RWNodeWriteData             ( PXNODE_DATA   pData,
                                              WORD          cbData ) ;
        --------------------------------------------------------------------

        ----------------------- Object APIs --------------------------------
        INT     RWNObjectQueryInfo          ( ULONG         ulSerialNumber,
                                              PSZ           pszObjectName,
                                              PRWNOBJINFO   pObjInfoRec,
                                              INT           cbObjInfoRec );

        INT     RWNObjectQueryObjects       ( ULONG         ulSerialNumber,
                                              PRWNOBJQUERY  pObjQueryRec,
                                              INT           cbObjQueryRec );
        --------------------------------------------------------------------

        ---------------------- Status APIs ---------------------------------
        RWNRET  RWNodeQueryStatusText       ( UINT          iInfoLevel,
                                              PRWNSTSINFO   pStsInfo,
                                              PSZ           pszText,
                                              PUINT         pcchText ) ;
        --------------------------------------------------------------------

        -------------------- Transaction Pipe APIs -------------------------
        RWNRET  RWNPipeOpen                 ( PHRWNPIPE     phrwp
                                            , PSZ           pszPipeName
                                            , PVOID         pvMsg
                                            , UINT          cbMsg
                                            , ULONG         fulOptions
                                            , PRWNPOPEN     prwpo ) ;

        RWNRET  RWNPipeClose                ( HRWNPIPE      hrwp
                                            , ULONG         fulOptions ) ;

        RWNRET  RWNPipeRead                 ( HRWNPIPE      hrwp
                                            , PVOID         pvMsg
                                            , UINT          cbMsg
                                            , PUINT         pcbActual
                                            , ULONG         ulTimeout ) ;

        RWNRET  RWNPipeWrite                ( HRWNPIPE      hrwp
                                            , PVOID         pvMsg
                                            , UINT          cbMsg ) ;
        --------------------------------------------------------------------

        ------------------------ Worklist APIs -----------------------------
        INT     RWNAddWorklistRecord        ( PSZ           pszWorklistFileName,
                                              SHORT         sCommand,
                                              PSZ           pszParam1,
                                              PSZ           pszParam2,
                                              BYTE          bWhere,
                                              BYTE          bWhen,
                                              ULONG         ulOptions );

        INT     RWNWorklistOpen             ( PRWHFILE      pfh,
                                              PSZ           pszWorklistFile ) ;

        INT     RWNWorklistAction           ( RWHFILE       fh,
                                              UINT          iAction,
                                              PRWWORKLIST   pWorklistRec,
                                              PUINT         puiReadWriteCount );

        INT     RWNWorklistClose            ( RWHFILE       fh,
                                              BOOL          fCompress );
        --------------------------------------------------------------------

        --------------------- Work Object APIs -------------------------------
        int RWNENTRY RWNWorkObjectSelect    ( ULONG         ulSystem,
                                              UINT          objectIds[],
                                              UINT          usIdCount );
        --------------------------------------------------------------------

    NOTES:
    ======

        The Node and Worklist APIs are included by default.

        Define the appropriate symbol to include the other (optional)
        sections.

        --------------------------------------------------------------------

        The Dialing Directory API is only available for OS/2, Windows, and
        Macintosh-OS.

        The Message API is only available for OS/2.

        The Object API is only available for OS/2 and Windows.

 * ========================================================================= */

#ifndef RWNAPI_INCLUDED
#define RWNAPI_INCLUDED


#ifndef RC_INVOKED
#pragma pack(1)                 /* force structure alignment packing */
#endif /* not RC_INVOKED */

#if defined (__cplusplus)
extern "C" {                    /* Assume C declarations for C++ */
#endif /* __cplusplus */


#ifdef OS2DEF_INCLUDED          /* OS/2 Toolkit header already included? */

    #ifndef OS2
        #define OS2
    #endif

#endif /* OS2DEF_INCLUDED */


#ifdef _INC_WINDOWS             /* Windows 3.1 SDK header already included? */

    #ifndef WINDOWS
        #define WINDOWS
    #endif

#endif /* _INC_WINDOWS */


#if !defined(STDEF_TYPES_INCLUDED)

#if !defined(WINDOWS) && !defined(OS2) && !defined(WIN32)

    #define FAR

    #define VOID            void
    #define LONG            long

    typedef unsigned short  BOOL;       /* True/False indicator */
    typedef unsigned char   BYTE;       /* 8-Bit unsigned value */

    typedef unsigned int    UINT;       /* unsigned machine-dependent value */

    typedef BYTE *          PBYTE ;

#endif /* neither WINDOWS nor OS2 */

#if !defined(WINDOWS) && !defined(WIN32)

    #define CALLBACK

    typedef unsigned short  WORD ;      /* 16-Bit unsigned value */

#endif /* not WINDOWS */

#if !defined(OS2)

    #define CHAR            char
    #define SHORT           short
    #define INT             int

    typedef unsigned short  USHORT;     /* 16-Bit unsigned value */
    typedef unsigned long   ULONG;      /* 32-Bit unsigned value */

    typedef BOOL FAR *      PBOOL ;
    typedef UINT FAR *      PUINT ;
    typedef ULONG FAR *     PULONG ;
    typedef VOID FAR *      PVOID ;

#if defined( MACINTOSH )
    typedef CHAR FAR *      PSZ ;
#else
    typedef BYTE FAR *      PSZ ;
    typedef const BYTE FAR *PCSZ ;
#endif

#endif /* not OS2 */

typedef const VOID FAR *PCVOID ;

#endif /* STDEF_TYPES_INCLUDED */


#if !defined (TRUE) || !defined (FALSE)
#define TRUE            1       /* True condition */
#define FALSE           0       /* False condition */
#endif


#if defined(OS2)

    /* OS/2 (32-bit) Function linkage specifier */

    #define RWNENTRY            APIENTRY

    typedef UINT                RWNRET ;

#elif defined(WINDOWS) || defined(WIN32)

    /* Windows Function linkage specifier */

    #if !defined ( EXPORT )
        #if defined ( _WIN32 )
            #define EXPORT
        #else
            #if defined ( _MSC_VER )  &&  (_MSC_VER <= 600)
                #define __export    _export
            #endif

            #define EXPORT          __export
        #endif
    #endif

	/*	I will define APIDECL to be "__declspec(dllimport)" unless
	**	EXPORT_API_FUNCTIONS has been defined, in which case we will
	**	will be exporting the functions and will define APIDECL to be
	**	"__declspec(dllexport)".
	*/

	#if defined ( WIN32 )
			#if defined (EXPORT_API_FUNCTIONS)
				#define APIDECL __declspec(dllexport)
			#else
				#define APIDECL __declspec(dllimport)
			#endif

			#if defined (EXPORT_PIPE_FUNCTIONS)
				#define PIPEDECL __declspec(dllexport)
			#else
				#define PIPEDECL __declspec(dllimport)
			#endif

    	#define	RWNENTRY			WINAPI
	#else
		#define APIDECL
		#define	PIPEDECL
		#define	RWNENTRY            FAR PASCAL EXPORT		
	#endif

    typedef UINT                RWNRET ;

#else

    /* Other Function linkage specifier */

    #define RWNENTRY

    typedef UINT                RWNRET ;

#endif



#define INCL_RWN_NODE
#define INCL_RWN_WORKLIST

#ifdef INCL_RWN_DIALDIR
#if !(defined(OS2) || defined(WINDOWS) || defined(MACINTOSH) || defined(_WIN32))

    #error RemoteWare Dialing Directory API is not supported on this platform

#endif /* !(OS2 || WINDOWS || MACINTOSH) */
#endif

#ifdef INCL_RWN_OBJECT
#if !(defined(OS2) || defined(WINDOWS) || defined(_WIN32))

    #error RemoteWare Object API is not supported on this platform

#endif /* !(OS2 || WINDOWS) */
#endif

#ifdef INCL_RWN_PIPE
#if !(defined(OS2) || defined(WINDOWS) || defined(_WIN32))

    #error RemoteWare Pipe API is not supported on this platform

#endif /* !(OS2 || WINDOWS) */
#if !(defined(INCL_RWN_DIALDIR))

    #define INCL_RWN_DIALDIR            /* Pipe uses Dialing Directory */

#endif /* !(OS2 || WINDOWS) */
#endif

#ifdef INCL_RWN_WORKOBJECT
#if !(defined(OS2) || defined(WINDOWS))

    #error RemoteWare Work Object API is not supported on this platform

#endif /* !(OS2 || WINDOWS) */
#endif


/*===========================================================================
 * Errors
 *==========================================================================*/

#define E_RWN_OK            0           /* Successful completion    */

#define E_RWN_EOF           -1          /* end of file              */
#define E_RWN_PARAM         -2          /* invalid parameter        */

#define RWPERR_BASE         0x1000      /* Transaction Pipe         */


/*===========================================================================
 * Definitions
 *==========================================================================*/

/*---------------------------------------------------------------------------
 * Dialing Directory API Definitions
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_DIALDIR


    /* --- hdd parameter value for default Dialing Directory entry: */

    #define HDDIR_DEFAULT               ((HDDIR)0)
    #define DEFAULT_DIALDIR_ENTRY       HDDIR_DEFAULT


    /* --- Dialing Directory handle --- */

    typedef USHORT      HDDIR ;     /* hdd */
    typedef HDDIR FAR * PHDDIR ;


#endif /* INCL_RWN_DIALDIR */


/*---------------------------------------------------------------------------
 * Node API Definitions
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_NODE


/* --- Constant values: */

#define NAME_LEN           9            /* Node name length             */
#define PASSWORD_LEN      11            /* Password length              */
#define PATH_LEN          61            /* File path and name length    */
#define PHONE_LEN         49            /* Phone number length          */


/* --- Node Request values: */

#define XR_STATUS           0x0000      /* Request Status               */
#define XR_REINIT           0x0001      /* Reinitialize, reload nodeinit*/
#define XR_REMOVE           0x0002      /* Remove Background Task       */
#define XR_CONNECT1         0x0004      /* Dial Inbound Phone #1        */
#define XR_CONNECT2         0x0008      /* Dial Inbound Phone #2        */
#define XR_CANCEL           0x0010      /* Cancel Dialing/Abort Session */
#define XR_ENABLE_AA        0x0020      /* Enable Auto Answer           */
#define XR_DISABLE_AA       0x0040      /* Disable Auto Answer          */
#define XR_RELEASE_PORT     0x0080      /* Release Comm Port            */
                                        /* Use XR_REINIT to Reload Port */
#define XR_ENABLE_ESD       0x0100      /* Enable ESD                   */
#define XR_DISABLE_ESD      0x0200      /* Disable ESD                  */

#define XR_RESERVED         0xfc00      /* Reserved for future use      */


/* --- Node Status values: */

#define XS_LOADED           0x0001      /* Background Task has Loaded   */
#define XS_AUTO_ANSWER      0x0002      /* Auto Answer Enabled          */
#define XS_DIALING          0x0004      /* Currently Dialing            */
#define XS_CONNECTING       0x0008      /* Currently Connecting         */
#define XS_PASSWORD         0x0010      /* Password Exchange            */
#define XS_CONNECTED        0x0020      /* Currently Connected          */
#define XS_DISCONNECTED     0x0040      /* Currently Disconnected       */
#define XS_ESD_DISABLED     0x0100      /* ESD is Disabled              */
#define XS_PORT_RELEASED    0x0200      /* Comm Port Released           */
#define XS_RESOURCE_READY   0x0400      /* Resource is available        */

#define XS_COUNTER_MASK     0xC000      /* Execution Counter Mask       */

#define XS_RESERVED         0x3880      /* Reserved for future use      */


/* --- bSessStatus field Session Status codes: */

#define XS_SESS_NONE                0   /* No Status Available          */
#define XS_SESS_SUCCESSFUL          1   /* Successful Session           */
#define XS_SESS_ABORTED             2   /* Aborted Session              */
#define XS_SESS_TIMEOUT             3   /* Timeout waiting for Server   */
#define XS_SESS_LOST_CONNECTION     4   /* Lost connection              */
#define XS_SESS_PASSWORD_FAIL       5   /* Password Exchange Failed     */
#define XS_SESS_CANCELED            6   /* Connect Canceled             */
#define XS_SESS_NO_ANSWER           7   /* Server didn't answer         */
#define XS_SESS_RESOURCE_ERROR      8   /* Resource Error               */
#define XS_SESS_SERVER_DOWN         9   /* Server is down               */
#define XS_SESS_SERVER_SUSPENDED    10  /* Server is suspended          */
#define XS_SESS_SCHEDULER_OFF       11  /* Server Scheduler is off      */
#define XS_SESS_NODE_DISABLED       12  /* Node is disabled             */
#define XS_SESS_NODE_UNDEFINED      13  /* Node is undefined            */
#define XS_SESS_NODEREG_DISABLED    14  /* Node Registration is disabled*/

#define XS_SESS_RESERVED            15  /* Reserved for future use      */

/* --- command field Session commands: */

#define XC_NONE            0            /* No Command Active            */
#define XC_SENDFILE        1            /* Sending file                 */
#define XC_RCVFILE         2            /* Receiving File               */
#define XC_SWO             3            /* Session Work Object          */

#define XC_RESERVED        4            /* Reserved for future use      */


/* --- bResource field Resource types: */

#define XRSC_NONE     ((BYTE)(-1))      /* No Resource                  */
#define XRSC_ASYNC         0            /* Asynchronous
                                            (Direct Connect or Modem)   */
#define XRSC_X25           1            /* X.25                         */
#define XRSC_NETBIOS       2            /* NetBIOS                      */
#define XRSC_TCPIP         5            /* TCP/IP                       */
#define XRSC_SPX           6            /* SPX                          */

#define XRSC_RESERVED      7            /* Reserved for future use      */


/* --- bRscStatus field Resource Status codes: */

/*
 *  This field indicates the current status of the resource.
 *
 *  NOTE:
 *
 *      The .bResource field indicates the currently loaded resource.
 *      The .nRscError field indicates the last error that occurred
 *      for the resource specified in the .bResource field.
 */

#define XS_RSC_OK           0           /* No error                     */
#define XS_RSC_ERROR        1           /* Resource error               */
#define XS_RSC_LOAD_FAILED  2           /* Resource failed to load      */
#define XS_RSC_OPEN_FAILED  3           /* Resource failed to open      */
#define XS_RSC_INIT_FAILED  4           /* Resource failed to initialize*/

#define XS_RSC_BUSY_MASK    0x80        /* Resource busy mask           */

#define XS_RSC_LOADING      0xFF        /* Resource busy: Loading       */
#define XS_RSC_UNLOADING    0xFE        /* Resource busy: Unloading     */
#define XS_RSC_REINITING    0xFD        /* Resource busy: Reinitializing*/
#define XS_RSC_RELEASING    0xFC        /* Resource busy: Releasing     */


/* --- nRscError field Error codes: */

/*
 *  The following error codes are only valid when the bRscStatus field
 *  is XS_RSC_LOAD_FAILED.
 */

#define XE_RSC_INTERNAL         1       /* Internal error               */
#define XE_RSC_NOT_AVAILABLE    2       /* Resource is not available    */
#define XE_RSC_DLL_NOT_FOUND    3       /* Resource DLL does not exist  */
#define XE_RSC_INVALID_DLL      4       /* Resource DLL corrupted       */
#define XE_RSC_NO_MEMORY        5       /* Insufficient memory available*/

/*
 *  ASYNC error codes/modem result codes
 */

#define XE_AS_INTERNAL      0x0100      /* Internal error                   */
#define XE_AS_DEVICE        0x0101      /* Invalid or unsupported device    */
#define XE_AS_OPEN          0x0102      /* Device is already open           */
#define XE_AS_NOT_OPEN      0x0103      /* Device is not open               */
#define XE_AS_MEMORY        0x0104      /* Insufficient memory              */
#define XE_AS_HARDWARE      0x0105      /* Hardware is not available        */
                                        /* (or is locked by another process)*/
#define XE_AS_DATA_RATE     0x0106      /* Data rate unsupported            */
#define XE_AS_NO_MODEM      0x0107      /* No modem found                   */

#define XE_AS_CARRIER       0x0001      /* Modem's Connected            */
#define XE_AS_RING          0x0002      /* Ring                         */
#define XE_AS_NO_CARRIER    0x0003      /* No Carrier                   */
#define XE_AS_MODEM_ERROR   0x0004      /* Modem Error                  */
#define XE_AS_CARRIER_1200  0x0005      /* Modem's Connected at 1200 bps*/
#define XE_AS_NO_DIALTONE   0x0006      /* No Dial Tone                 */
#define XE_AS_BUSY          0x0007      /* Busy Signal                  */
#define XE_AS_NO_ANSWER     0x0008      /* No Answer                    */

/*
 *  Other resource error codes (NetBIOS, X.25, etc.) are generally
 *  provided with their respective toolkits
 */


/* --- Node Information structure: */

typedef struct xnode_info_str
{
    WORD    status;                     /* Current Node status          */
    ULONG   last_session;               /* Time of last session         */
    BYTE    bSessStatus ;               /* Status of last session       */
    BYTE    command;                    /* Current session command      */
    ULONG   file_size;                  /* File size                    */
    ULONG   bytes_transfered;           /* Bytes Transfered             */
    CHAR    filename[PATH_LEN];         /* File being sent/rcvd         */

    /* Added in Release 1.4 */

    BYTE    node_drive;                 /* Default Node Drive           */
    BYTE    node_major;                 /* Node Major Version number    */
    BYTE    node_minor;                 /* Node Minor Version number    */

    /* Added in Release 2.0 */

    BYTE    bResource ;                 /* Current Node Resource        */
    BYTE    bRscStatus ;                /* Node Resource status         */
    WORD    nRscError ;                 /* Node Resource error          */

    ULONG   StartTime ;                 /* Session start time           */

    ULONG   ConnectedSystem ;           /* Connected System's Serial #  */

    CHAR    szPhone[PHONE_LEN] ;        /* Phone # or Address called    */
    BYTE    abReserved[3] ;             /* Reserved                     */

}   XNODE_INFO ;

typedef XNODE_INFO FAR *    PXNODE_INFO ;

#define XNODE_INFO_SIZE     sizeof(XNODE_INFO)



/* --- Node Data structure: */

typedef struct  xnode_data_str
{
    CHAR    name[NAME_LEN];             /* Node Name  (Read Only)       */
    CHAR    password[PASSWORD_LEN];     /* Node passsword               */
    CHAR    port;                       /* Port Number  (0=com1, 1=com2, etc) */
    WORD    baud_rate;                  /* Node port baud rate          */
    CHAR    server_phone1[PHONE_LEN];   /* Server phone number 1        */
    CHAR    server_phone2[PHONE_LEN];   /* Server phone number 2        */
    CHAR    schedule_active;            /* Schedule Status (1 = active) */
    CHAR    schedule_retrys;            /* Schedule Retrys (0 = None)   */
    ULONG   schedule_time;              /* Schedule Time                */

} XNODE_DATA;

typedef XNODE_DATA FAR *    PXNODE_DATA ;

#define XNODE_DATA_SIZE     sizeof(XNODE_DATA)

#endif /* INCL_RWN_NODE */


/*---------------------------------------------------------------------------
 * Object API Definitions
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_OBJECT


/* --- Constants for Node Application Information: */

#define RWNAPPPATHLGT       61
#define RWNAPPUSERDATALGT   32


/* --- bLaunchMode field values: */

#define WOLM_NONE          0
#define WOLM_USER          1
#define WOLM_AUTO_NORMAL   2
#define WOLM_AUTO_MIN      3
#define WOLM_SCHEDULED     4


/* --- WOTIME structure: */

#ifndef _WOTIME_DEFINED

    #define _WOTIME_DEFINED

    typedef struct _WOTIME
    {
        BYTE    hours;      /* 0 - 23 */
        BYTE    minutes;    /* 0 - 59 */
        BYTE    seconds;    /* 0 - 59 */
    }
        WOTIME ;

    typedef WOTIME FAR *            PWOTIME ;

#endif


/* --- WOTIMEDATE structure: */

#ifndef _WOTIMEDATE_DEFINED

    #define _WOTIMEDATE_DEFINED

    typedef struct _WOTIMEDATE
    {
        BYTE    month;      /* 1 - 12 */
        BYTE    day;        /* 1 - 31 */
        BYTE    year;       /* 0 - 99 */
        BYTE    hours;      /* 0 - 23 */
        BYTE    minutes;    /* 0 - 59 */
        BYTE    seconds;    /* 0 - 59 */
    }
        WOTIMEDATE ;

    typedef WOTIMEDATE FAR *        PWOTIMEDATE ;

#endif


/* --- Node Application Information structure: */

typedef struct _RWNAPPINFO
{
    BYTE       bLaunchMode;                 /* Launch mode ( see WOLM_* ).      */
    CHAR       szExeFile[ RWNAPPPATHLGT ];  /* Executable file spec.            */
    CHAR       szPath[ RWNAPPPATHLGT ];     /* Working dir/path.                */
    CHAR       szCmd[ RWNAPPPATHLGT ];      /* Command line string.             */
    WOTIMEDATE ScheduleStart;               /* Schedule execution: start time.  */
    WOTIMEDATE ScheduleStop;                /* Schedule execution: end time.    */
    BYTE       bScheduleRepeatDays;         /* Repeat schedule every x days.    */
    WOTIME     ScheduleRepeatTime;          /* Repeat schedule every hh:mm:ss.  */
    BOOL       fRelease;                    /* If TRUE object events will be    */
                                            /* executed if object enabled.      */
                                            /* If FALSE object events will not  */
                                            /* be executed event if object      */
                                            /* enabled.                         */
    BYTE       abUserData[ RWNAPPUSERDATALGT ]; /* User defined data.           */
}
    RWNAPPINFO ;

    typedef RWNAPPINFO FAR *        PRWNAPPINFO ;



/* --- Constants for Node Object Information: */

#define CCHRWNOBJNAME       42


/* --- flFlags field values: */

#define WOF_READONLY_ASN       0x0000001   /* Session, node, user asn       */
                                           /* cannot be modified.           */

#define WOF_READONLY_MEMBERS   0x0000002   /* Member assignments cannot     */
                                           /* be modified.                  */

#define WOF_READONLY_EVENTS    0x0000004   /* Events cannot be modified.    */


/* --- bType field values: */

#define WOTY_ESD                0
#define WOTY_WORKLIST           1
#define WOTY_GROUP              2
#define WOTY_APPLICATION        3
#define WOTY_APPLICATION_GROUP  4


/* --- bExecution field values: */

#define WOEX_DEFAULT            0
#define WOEX_FORCED             1
#define WOEX_REQUESTABLE        2


/* --- bNodeType field values: */

#define WONT_ANY                 0      /* Any node type     */
#define WONT_DOS_NODE            1      /* PC Compatible     */
#define WONT_OS2_NODE            2      /* OS/2 Node         */
#define WONT_SERVER_NODE         3      /* RW Server Node    */
#define WONT_VAX_NODE            4      /* VAX/VMS Node      */
#define WONT_XENIX_NODE          5      /* Xenix Node        */
#define WONT_UNIX_NODE           6      /* Unix Node         */
#define WONT_4680_NODE           7      /* IBM 4680 Node     */
#define WONT_NB_DOS_NODE         8      /* NetBios Dos Node  */
#define WONT_AIX_NODE            9      /* Aix Node          */
#define WONT_MAC_NODE           10      /* Macintosh Node    */
#define WONT_WINDOWS_NODE       11      /* Windows Node      */
#define WONT_ATT_NODE           12      /* AT&T Unix Node    */

#define WONT_MAX                32      /* Max Node Types    */

/* --- bPriority field values: */

#define WOPRI_MIN       0
#define WOPRI_MAX       255


/* --- Node Object Information structure: */

typedef struct _RWNOBJINFO
{
    LONG       flFlags;                 /* Flags ( see WOF_* ).             */
    CHAR       szName[ CCHRWNOBJNAME ]; /* Object name.                     */
    BYTE       bStatus;                 /* 0 = Disabled, 1 = Enabled.       */
    BYTE       bType;                   /* Object type ( see WOTY_* ).      */
    BYTE       bExecution;              /* Object execution ( see WOEX_* ). */
    BYTE       abNodeTypes[ WONT_MAX ]; /* Limit execution to node type     */
                                        /* ( see WONT_* above ).            */
                                        /* Values are valid until first     */
                                        /* WONT_ANY is found. WONT_ANY      */
                                        /* is only valid if it is the first */
                                        /* value.                           */
    BYTE       bPriority;               /* Object priority                  */
                                        /* [WOPRI_MIN..WOPRI_MAX].          */
    INT        idObject;                /* Unique object identifier.        */
    ULONG      ulTimeStamp;             /* Object creation time in seconds  */
                                        /* since 1970.                      */
    RWNAPPINFO AppInfoRec;              /* If bType is WOTY_APPLICATION.    */
}
    RWNOBJINFO ;

    typedef RWNOBJINFO FAR *        PRWNOBJINFO ;



/* --- fFlags field values: */

#define RWNOF_ALLOBJECTS        0x01    /* If set then all objects defined  */
                                        /* on the server will be returned.  */

#define RWNOF_NODEOBJECTS       0x02    /* If set then only those objects   */
                                        /* assigned to the node             */
                                        /* will be returned.                */

#define RWNOF_APPINFO           0x04    /* If set then the AppInfoRec       */
                                        /* field in the ObjInfoRec field    */
                                        /* will be filled for application   */
                                        /* objects.                         */

#define RWNOF_EXPANDAPPGRPS     0x08    /* If set then the members of any   */
                                        /* application groups will be       */
                                        /* returned instead of the          */
                                        /* the application group.           */


#define RWNOF_DESKTOP           0x10    /* If set then only the desktop     */
                                        /* assigned to the specified user   */
                                        /* will be returned.                */

/* --- Node Object Query structure: */

/* forward declaration for self-referential structure */
typedef struct _RWNOBJQUERY FAR *   PRWNOBJQUERY ;

typedef void (CALLBACK* PFRWNOBJQCALLBACK)(PRWNOBJQUERY);

typedef struct _RWNOBJQUERY
{
    /* ---------------------------------------------------------------------- */
    /* Fields to be filled in by caller before calling RWNObjectQueryObjects: */
    /* ---------------------------------------------------------------------- */

    PFRWNOBJQCALLBACK   pfCallBack ;    /* Specify function that will be    */
                                        /* called by RWNObjectQueryObjects  */
                                        /* to enumerate items.              */

    INT            fFlags;              /* Specify 1 or more of the         */
                                        /* RWNOF_XXX flags above.           */

    char           *pszFilterUser;      /* If a user's net name is specified*/
                                        /* here then only those apps that   */
                                        /* are assigned to the user will be */
                                        /* returned.                        */

    char           *pszFilterAppGrp;    /* If an application group name is  */
                                        /* specified here then only those   */
                                        /* apps that are assigned to the    */
                                        /* application group will be        */
                                        /* returned.                        */
                                        /* Can be used in combination with  */
                                        /* the pszFilterUser field above.   */

    BOOL           fStopQuery;          /* Set to TRUE if you do not want   */
                                        /* to be called back anymore.       */

    CHAR           szUserData[ 64 ];    /* Area for general use in passing  */
                                        /* info to callback function.       */

    /* ---------------------------------------------------------------------- */
    /* Fields filled in by RWNObjectQueryObjects:                             */
    /* ---------------------------------------------------------------------- */

    RWNOBJINFO     ObjInfoRec;          /* Object information.              */

    /* ---------------------------------------------------------------------- */
    /* Reserved fields.                                                       */
    /* ---------------------------------------------------------------------- */

    CHAR           szFill[ 64 ];        /* For future fields.               */
}
    RWNOBJQUERY ;

#endif /* INCL_RWN_OBJECT */


/*---------------------------------------------------------------------------
 * Status API Definitions
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_STATUS


    /* --- iInfoLevel parameter values: */

    #define SQI_NODESTATUS          1   /* Node status description (short)  */
    #define SQI_SESSIONSTATUS       2   /* short session status description */
    #define SQI_LONGSESSIONSTATUS   3   /* long session status description  */
    #define SQI_SESSERREXPLANATION  4   /* session error explanation        */
    #define SQI_RESOURCENAME        5   /* Resource type name               */
    #define SQI_RESOURCESTATUS      6   /* Current Resource staus           */


    /* --- Status Information structure: */

    typedef struct _RWNSTSINFO
    {
        UINT    cb ;                    /* size of RWNSTSINFO structure     */
                                        /* ( see CBRWNSTSINFO below )       */

        WORD    wNodeStatus ;           /* Node status ( see XS_* below )   */
                                        /* Only valid for:                  */
                                        /*     SQI_NODESTATUS               */

        BYTE    bSessStatus ;           /* Session status ( see XS_SESS_* ) */
                                        /* Only valid for:                  */
                                        /*     SQI_SESSIONSTATUS            */
                                        /*     SQI_LONGSESSIONSTATUS        */
                                        /*     SQI_SESSERREXPLANATION       */

        BYTE    bResource ;             /* Resource type ( see XRSC_* below)*/
                                        /* Only valid for:                  */
                                        /*     SQI_SESSIONSTATUS            */
                                        /*     SQI_LONGSESSIONSTATUS        */
                                        /*     SQI_SESSERREXPLANATION       */
                                        /*     SQI_RESOURCENAME             */

        BYTE    bRscStatus ;            /* Resource status ( see XS_RSC_* ) */
                                        /* Only valid for:                  */
                                        /*     SQI_SESSIONSTATUS            */
                                        /*     SQI_LONGSESSIONSTATUS        */
                                        /*     SQI_SESSERREXPLANATION       */

        WORD    nRscError ;             /* Resource-specific error code     */
                                        /* Only valid for:                  */
                                        /*     SQI_SESSIONSTATUS            */
                                        /*     SQI_LONGSESSIONSTATUS        */
                                        /*     SQI_SESSERREXPLANATION       */

    }   RWNSTSINFO ;

    #define CBRWNSTSINFO    sizeof ( RWNSTSINFO )

    typedef RWNSTSINFO FAR *        PRWNSTSINFO ;

#endif /* INCL_RWN_STATUS */


/*---------------------------------------------------------------------------
 * Transaction Pipe API Definitions
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_PIPE

    /* --- Transaction Pipe types: */

    typedef ULONG           HRWNPIPE ;
    typedef HRWNPIPE FAR *  PHRWNPIPE ;

    #define NULLHRWNPIPE    ((HRWNPIPE) 0)


    /* --- Transaction Pipe timeout values: */

    #define RWPIPE_INDEFINITE_WAIT      -1L
    #define RWPIPE_IMMEDIATE_RETURN     0L


    /* --- Transaction Pipe name length: */

    #define RWPIPE_CCHMAXNAME           ( 63 + 1 )      /* ASCIIZ string */


    /* --- Transaction Pipe notification types: */

    /** When the Transaction Pipe notifies an application, the first
    *   message parameter will contain a notification type (defined below)
    *   and the second message parameter will contain the handle of the
    *   affected pipe instance (type HRWNPIPE, defined above).
    */
    #define RWPN_CALLING                1
    #define RWPN_CONNECTED              2
    #define RWPN_DISCONNECTED           3
    #define RWPN_BROKEN                 4
    #define RWPN_MESSAGE                5
    #define RWPN_LOADING                6
    #define RWPN_UNLOADING              7
    #define RWPN_REINITIALIZING         8
    #define RWPN_CONNECTING             9


    /* --- Transaction Pipe options: */

    #define RWPF_COMPRESS                   0x00000001
    #define RWPF_CLOSE_CONNECTION           0x00000010
    #define RWPF_MAINTAIN_CONNECTION        0x00000020
    #define RWPF_EXECUTE_INBOUND_SESSION    0x00000100


    /* --- Transaction Pipe Open structure: */

    typedef struct _RWNPOPEN    /* rwpo */
    {
        ULONG   cb ;            /* size (in bytes) of this structure */
        ULONG   cbMaxInBuf ;    /* size (in bytes) of input message buffer */
        ULONG   cbMaxOutBuf ;   /* size (in bytes) of output message buffer */
        ULONG   cmsTimeout ;    /* count (in milliseconds) to wait */
        HWND    hwnd ;          /* window handle to notify */
        ULONG   uWndMsg ;       /* notification window message */
        HDDIR   hdd ;           /* Dialing Directory entry handle */

    }   RWNPOPEN, FAR * PRWNPOPEN ;


    /* --- Transaction Pipe errors: */

    #if defined (OS2DEF_INCLUDED) && defined (INCL_DOSERRORS)
        #define E_PIPE_INVALID_HANDLE       ERROR_INVALID_HANDLE
        #define E_PIPE_NOT_ENOUGH_MEMORY    ERROR_NOT_ENOUGH_MEMORY
        #define E_PIPE_INVALID_PARAMETER    ERROR_INVALID_PARAMETER
        #define E_PIPE_BROKEN               ERROR_BROKEN_PIPE
        #define E_PIPE_INSUFFICIENT_BUFFER  ERROR_INSUFFICIENT_BUFFER
        #define E_PIPE_BAD_PIPE             ERROR_BAD_PIPE
        #define E_PIPE_BUSY                 ERROR_PIPE_BUSY
        #define E_PIPE_NO_DATA              ERROR_NO_DATA
        #define E_PIPE_NOT_CONNECTED        ERROR_PIPE_NOT_CONNECTED
        #define E_PIPE_MORE_DATA            ERROR_MORE_DATA
        #define E_PIPE_TIMEOUT              ERROR_TIMEOUT
        #define E_PIPE_TOOMANY              ERROR_NO_MORE_HANDLES
    #else
        #define E_PIPE_INVALID_HANDLE       6
        #define E_PIPE_NOT_ENOUGH_MEMORY    8
        #define E_PIPE_INVALID_PARAMETER    87
        #define E_PIPE_BROKEN               109
        #define E_PIPE_INSUFFICIENT_BUFFER  122
        #define E_PIPE_BAD_PIPE             230
        #define E_PIPE_BUSY                 231
        #define E_PIPE_NO_DATA              232
        #define E_PIPE_NOT_CONNECTED        233
        #define E_PIPE_MORE_DATA            234
        #define E_PIPE_TIMEOUT              640
        #define E_PIPE_TOOMANY              32804
    #endif /* OS2DEF_INCLUDED && INCL_DOSERRORS */

    #define E_PIPE_OK                   E_RWN_OK
    #define E_PIPE_NODE_NOT_LOADED      (RWPERR_BASE + 0)
    #define E_PIPE_NOT_FOUND            (RWPERR_BASE + 1)
    #define E_PIPE_NOT_AVAILABLE        (RWPERR_BASE + 2)
    #define E_PIPE_CONNECTING           (RWPERR_BASE + 3)
    #define E_PIPE_INVALID_HDDIR        (RWPERR_BASE + 4)
    #define E_PIPE_BUFFER_FULL          (RWPERR_BASE + 5)
    #define E_PIPE_TRANSPORT_ERROR      (RWPERR_BASE + 6)

#endif /* INCL_RWN_PIPE */


/*---------------------------------------------------------------------------
 * Worklist API Definitions
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_WORKLIST

#define RWHFILE         ULONG
#define PRWHFILE        PULONG

#define WLPARAMLGT      61

/* --- iAction parameter values: */

#define WLA_READ        1
#define WLA_WRITE       2
#define WLA_DELETE      3
#define WLA_APPEND      4

/* --- Values for sCommand parameter: */

#define WL_SENDFILE         1           /* Send File to Node            */
#define WL_GETFILE          2           /* Get File from Node           */
#define WL_SENDDIR          3           /* Send Server Directory Files  */
#define WL_GETDIR           4           /* Get Node Directory Files     */
#define WL_RENAMEFILE       5           /* Rename File                  */
#define WL_DELETEFILE       6           /* Delete File                  */
#define WL_COPYFILE         7           /* Copy File                    */
#define WL_APPENDFILE       8           /* Append File                  */
#define WL_FILESTAT         9           /* Get File Stats               */
#define WL_DIRECTORY       10           /* Get Directory Listing        */
#define WL_CHECKDISK       11           /* Check Disk                   */
#define WL_MAKEDIR         12           /* Make Directory               */
#define WL_REMOVEDIR       13           /* Remove Directory             */
#define WL_SETTIME         14           /* Set Node Time                */
#define WL_EXECUTE         15           /* Execute Program              */
#define WL_WORKLIST        16           /* Insert WorkList              */
#define WL_NOTIFY          17           /* Notify Process               */
#define WL_REBOOT_NODE     19           /* Reboot Node after session    */
#define WL_WORKQUEUE       20           /* Execute A WorkQueue          */
#define WL_WAIT            21           /* Wait for File or timeout     */
#define WL_ASCII_APPEND    22           /* Append ASCII File (^Z check) */
#define WL_USER_ALARM      23           /* User Alarm and Message       */
#define WL_END_SESSION     24           /* End Session gracefully       */
#define WL_IF_TRUE         27           /* If Previous Event is True    */
#define WL_IF_FALSE        28           /* If Previous Event is False   */
#define WL_ELSE_IF         29           /* Else do the following        */
#define WL_END_IF          30           /* End IF Block                 */
#define WL_REPEAT_IF_TRUE  31           /* Repeat If Previous Event is True  */
#define WL_REPEAT_IF_FALSE 32           /* Repeat If Previous Event is False */
#define WL_END_REPEAT      33           /* End Repeat Block             */
#define WL_EXCEPTION       34           /* Exception Worklist           */
#define WL_GROUP_TEST      35           /* Test If Node is in Group     */
#define WL_COMMENT         36           /* Comment Text                 */
#define WL_SET_VARIABLE    37           /* SET Environment Variable     */
#define WL_TEST_VARIABLE   38           /* TEST Environment Variable    */
#define WL_CHECK_FILE      40           /* Check File Date/Time / Size  */


/* --- Values for bWhere parameter: */

#define WL_ON_SERVER       0x01         /* Execute on Server            */
#define WL_ON_NODE         0x02         /* Execute on Node              */

/* --- Values for bWhen parameter: */

#define WL_BEFORE          0x01         /* Execute BEFORE comm session  */
#define WL_DURING          0x02         /* Execute DURING comm session  */
#define WL_AFTER           0x04         /* Execute AFTER  comm session  */

/* --- Values for ulOptions parameter: */

#define WL_NO_OVERWRITE       0x00000001    /* Do Not Overwrite File        */
#define WL_UPDATEFILE         0x00000002    /* Update File only if changed  */
#define WL_SAFE_SEND          0x00000004    /* Send File Using Temps        */
#define WL_CRITICAL           0x00000008    /* Critical Event               */
#define WL_DELETE_AFTER       0x00000010    /* Delete file if successful    */
#define WL_CRITICAL_RETRY     0x00000020    /* Critical Event with Retrys   */
#define WL_NO_COMPRESS        0x00000040    /* No compression               */
#define WL_NOT_NEEDED         0x00000080    /* Not needed for Successful    */
#define WL_SEND_NEWER         0x00000100    /* Update only if file is newer */
#define WL_INCREMENTAL_UPDATE 0x00000200    /* Incrementally Update File    */

#define WL_CONDITIONAL_TRUE   0x40000000    /* Conditional Execute if TRUE  */
#define WL_CONDITIONAL_FALSE  0x80000000    /* Conditional Execute if FALSE */

/* --- Worklist Update Structure: */

typedef struct _RWWORKLIST
{
    USHORT  cb ;                        /* size of RWWORKLIST structure     */
                                        /* ( see CBRWWORKLIST below )       */
    SHORT   iRecordNumber ;             /* Worklist record number           */
    SHORT   sCommand ;                  /* Worklist command                 */
    BYTE    bWhere ;                    /* Where to execute: WL_ON_SERVER
                                                             WL_ON_NODE     */
    BYTE    bWhen ;                     /* When to execute:  WL_BEFORE
                                                             WL_DURING
                                                             WL_AFTER       */
    ULONG   ulOptions ;                 /* Command options:  WL_NO_OVERWRITE
                                                             .
                                                             .
                                                             WL_SEND_NEWER  */
    LONG    lUserContext ;              /* User defined context field       */
    USHORT  usReferenceCount ;          /* User reference count             */
    CHAR    szParam1[ WLPARAMLGT ] ;    /* First command parameter          */
    CHAR    szParam2[ WLPARAMLGT ] ;    /* Second command parameter         */
    BYTE    reserved[ 116 ] ;           /* reserved for future use          */

}   RWWORKLIST ;

#define CBRWWORKLIST    sizeof ( RWWORKLIST )

typedef RWWORKLIST FAR *        PRWWORKLIST ;

/* --- Worklist Comment Update Structure: */

#define WLCOMMENTLGT            CBRWWORKLIST - sizeof( USHORT ) - sizeof( SHORT ) - sizeof (SHORT )

typedef struct _RWWORKLISTCOMMENT
{
    USHORT  cb ;                        /* size of RWWORKLIST structure     */
                                        /* ( see CBRWWORKLIST below )       */
    SHORT   iRecordNumber ;             /* Worklist record number           */
    SHORT   sCommand ;                  /* Worklist command                 */
    CHAR    szComment[ WLCOMMENTLGT ];  /* Comment string                   */
} RWWORKLISTCOMMENT ;

typedef RWWORKLISTCOMMENT FAR *     PRWWORKLISTCOMMENT ;

#endif /* INCL_RWN_WORKLIST */


/*===========================================================================
 * Function Prototypes
 *==========================================================================*/

/*---------------------------------------------------------------------------
 * Dialing Directory API Prototypes
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_DIALDIR

    APIDECL INT RWNENTRY RWNodeDialDirConnect      ( HDDIR    hdd );

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Connect using the Dialing Directory
    **
    **  Parameters:
    **  ----------
    **  HDDIR        hdd   - Dialing Directory Handle
    **
    **  Notes:
    **  ----------
    **  Use HDDIR_DEFAULT to indicate the currently selected
    **  entry in the Dialing Directory.
    **
    **  Returns:
    **  -------
    **  0                   If Successful (connection has been initiated)
    **  Error Code
    **----------------------------------------------------------------------*/


    APIDECL INT RWNENTRY RWNodeDialDirDialog        ( HWND          hwnd ) ;

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Packaged Dialing Directory dialog
    **
    **  Parameters:
    **  ----------
    **  HWND        hwnd        - handle to Owner window
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/

#endif /* INCL_RWN_DIALDIR */


/*---------------------------------------------------------------------------
 * Node API Prototypes
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_NODE


    APIDECL WORD RWNENTRY RWNodeRequest             ( WORD          wRequest );

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Request Service from background task
    **
    **  Parameters:
    **  ----------
    **  WORD        wRequest    - Request
    **
    **  Returns:
    **  -------
    **  0                   If background task not loaded
    **  != 0                Status word
    **----------------------------------------------------------------------*/


    APIDECL BOOL RWNENTRY RWNodeGetInfo             ( PXNODE_INFO   pInfo,
                                              WORD          cbInfo );

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Get Information from background task
    **
    **  Parameters:
    **  ----------
    **  PXNODE_INFO pInfo       - pointer to XNODE_INFO structure
    **  WORD        cbInfo      - size of XNODE_INFO structure
    **
    **  Returns:
    **  -------
    **  FALSE               If background task not loaded
    **  TRUE                Data returned in structure
    **----------------------------------------------------------------------*/


    APIDECL INT RWNENTRY RWNodeReadData             ( PXNODE_DATA   pData,
                                              WORD          cbData );

    APIDECL INT RWNENTRY RWNodeWriteData            ( PXNODE_DATA   pData,
                                              WORD          cbData );

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  These functions read/write node setup data
    **
    **  Parameters:
    **  ----------
    **  PXNODE_DATA pData       - pointer to XNODE_DATA structure
    **  WORD        cbData      - size of XNODE_DATA structure
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/

#endif /* INCL_RWN_NODE */


/*---------------------------------------------------------------------------
 * Object API Prototypes
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_OBJECT


    APIDECL INT RWNENTRY RWNObjectQueryInfo         ( ULONG         ulSerialNumber,
                                              PSZ           pszObjectName,
                                              PRWNOBJINFO   pObjInfoRec,
                                              INT           cbObjInfoRec );

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Retrieves information about an object
    **
    **  Parameters:
    **  ----------
    **  ULONG       ulSerialNumber      - Server Serial number
    **  PSZ         pszObjectName       - name of object to get info for
    **  PRWNOBJINFO pObjInfoRec         - pointer to RWNOBJINFO structure
    **  INT         cbObjInfoRec        - size of RWNOBJINFO structure
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/


    APIDECL INT RWNENTRY RWNObjectQueryObjects      ( ULONG         ulSerialNumber,
                                              PRWNOBJQUERY  pObjQueryRec,
                                              INT           cbObjQueryRec );

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Retrieves a list of objects
    **
    **  Parameters:
    **  ----------
    **  ULONG           ulSerialNumber  - Server Serial number
    **  PRWNOBJQUERY    pObjQueryRec    - pointer to RWNOBJQUERY structure
    **  INT             cbObjQueryRec   - size of RWNOBJQUERY structure
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/

#endif /* INCL_RWN_OBJECT */


/*---------------------------------------------------------------------------
 * Status API Prototypes
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_STATUS


    APIDECL RWNRET RWNENTRY RWNodeQueryStatusText   ( UINT          iInfoLevel,
                                              PRWNSTSINFO   pStsInfo,
                                              PSZ           pszText,
                                              PUINT         pcchText ) ;

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Retrieve information (or descriptive text) about a Node or Session
    **  status, or a Resource error.
    **
    **  Parameters:
    **  ----------
    **  UINT        iInfoLevel  - Level of detail (see SQI_* above)
    **  PRWNSTSINFO pStsInfo    - pointer to RWNSTSINFO structure
    **  PSZ         pszText     - pointer to buffer to hold text
    **  PUINT       pcchText    - size of buffer, returns length of text
    **
    **  Notes:
    **  ------
    **  Passing a NULL pointer for pszText or 0 for *pcchText will
    **  return the length of the descriptive text in *pcchText, but not
    **  the actual text.
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/

#endif /* INCL_RWN_STATUS */


/*---------------------------------------------------------------------------
 * Transaction Pipe API Prototypes
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_PIPE

    PIPEDECL RWNRET RWNENTRY RWNPipeOpen        ( PHRWNPIPE     phrwp
                                                , PSZ           pszPipeName
                                                , PVOID         pvMsg
                                                , UINT          cbMsg
                                                , ULONG         fulOptions
                                                , PRWNPOPEN     prwpo ) ;

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Open connection to Transaction Pipe
    **
    **  Parameters:
    **  ----------
    **  PHRWNPIPE       phrwp       - (in/out) pointer to pipe handle
    **  PSZ             pszPipeName - (in) Transaction Pipe server name
    **  PVOID           pvMsg       - (in) pointer to message buffer
    **  UINT            cbMsg       - (in) count of bytes in message
    **  ULONG           fulOptions  - (in) options
    **  PRWNPOPEN       prwpo       - (in) pointer to RWNPOPEN structure
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/


    PIPEDECL RWNRET RWNENTRY RWNPipeClose                ( HRWNPIPE      hrwp
                                                , ULONG         fulOptions ) ;

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Close connection to Transaction Pipe
    **
    **  Parameters:
    **  ----------
    **  HRWNPIPE        hrwp        - (in) handle to pipe connection
    **  ULONG           fulOptions  - (in) options
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/


    PIPEDECL RWNRET RWNENTRY RWNPipeRead        ( HRWNPIPE      hrwp
                                                , PVOID         pvMsg
                                                , UINT          cbMsg
                                                , PUINT         pcbActual
                                                , ULONG         ulTimeout ) ;

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Read message from Transaction Pipe
    **
    **  Parameters:
    **  ----------
    **  HRWNPIPE        hrwp        - (in) handle to pipe connection
    **  PVOID           pvMsg       - (in) pointer to message buffer
    **  UINT            cbMsg       - (in) count of bytes in message
    **  PUINT           pcbActual   - (out) actual count of bytes read
    **  ULONG           ulTimeout   - (in) milliseconds to wait
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/


    PIPEDECL RWNRET RWNENTRY RWNPipeWrite       ( HRWNPIPE      hrwp
                                                , PVOID         pvMsg
                                                , UINT          cbMsg ) ;

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Write message to Transaction Pipe
    **
    **  Parameters:
    **  ----------
    **  HRWNPIPE        hrwp        - (in) handle to pipe connection
    **  PVOID           pvMsg       - (in) pointer to message buffer
    **  UINT            cbMsg       - (in) count of bytes in message
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/

#endif /* INCL_RWN_PIPE */


/*---------------------------------------------------------------------------
 * Worklist API Prototypes
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_WORKLIST

    APIDECL INT RWNENTRY RWNAddWorklistRecord       ( PSZ           pszWorklistFileName,
		                                              SHORT         sCommand,
		                                              PSZ           pszParam1,
		                                              PSZ           pszParam2,
		                                              BYTE          bWhere,
		                                              BYTE          bWhen,
		                                              ULONG         ulOptions );

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Opens a Appends a worklist record to the end of a worklist file
    **
    **  Parameters:
    **  ----------
    **  PSZ     pszWorklistFileName     Worklist File
    **  SHORT   sCommand                Worklist Command ( see WL_* )
    **  PSZ     pszParam1               Parameter 1
    **  PSZ     pszParam2               Parameter 2
    **  BYTE    bWhere                  Where to execute:
    **                                      (WL_ON_SERVER or WL_ON_NODE )
    **  BYTE    bWhen                   When to execute:
    **                                      (WL_BEFORE, WL_DURING, or WL_AFTER )
    **  ULONG   ulOptions               Worklist options ( see WL_* )
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/


    APIDECL INT RWNENTRY RWNWorklistOpen        ( PRWHFILE      pfh,
		                                          PSZ           pszWorklistFile ) ;

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Opens a specified worklist file for updating via the RWNWorklistAction
    **  function.
    **
    **  Parameters:
    **  ----------
    **  PHFILE  pfh                     - Pointer to the file handle
    **  PSZ     pszWorklistFile         - Pointer to the worklist file name
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/

    APIDECL INT RWNENTRY RWNWorklistAction      ( RWHFILE       fh,
		                                          UINT          iAction,
		                                          PRWWORKLIST   pWorklistRec,
		                                          PUINT         puiReadWriteCount );

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Used for all file I/O on a worklist. Actions are:
    **      WLA_READ    - Read worklist record(s)
    **      WLA_WRITE   - Write worklist record(s)
    **      WLA_DELETE  - Delete worklist record(s)
    **      WLA_APPEND  - Append worklist record(s) to the end of a worklist
    **
    **  Parameters:
    **  ----------
    **  HFILE       fh                  - Worklist file handle
    **  UINT        iAction             - Action to preform (see WLA_*)
    **  PRWWORKLIST pWorklistRec        - Worklist record
    **  PUINT       puiReadWriteCount   - (in)  # of records to read/write
    **                                    (out) # of valid records actually
    **                                    read/written
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  OS/2 Error Code
    **----------------------------------------------------------------------*/

    APIDECL INT RWNENTRY RWNWorklistClose       ( RWHFILE       fh,
		                                          BOOL          fCompressFile );

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Closes a worklist file.
    **
    **  Parameters:
    **  ----------
    **  HFILE   fh                     - Worklist file handle to close
    **  BOOL    fCompressFile          - Compress flag ( remove purged records )
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/


#endif /* INCL_RWN_WORKLIST */


/*---------------------------------------------------------------------------
 * Work Object API Prototypes
 *--------------------------------------------------------------------------*/

#ifdef INCL_RWN_WORKOBJECT

    APIDECL int RWNENTRY RWNWorkObjectSelect    ( ULONG         ulSystem,
                                          UINT          objectIds[],
                                          UINT          usIdCount ) ;

    /*-----------------------------------------------------------------------
    **  Description:
    **  -----------
    **  Select work objects for one time execution.
    **
    **  Parameters:
    **  ----------
    **  ULONG   ulSystem               - System Serial number
    **  UINT [] objectIds              - Array of object IDs to select
    **  UINT    usIdCount              - Number of object IDs in objectIds
    **
    **  Returns:
    **  -------
    **  0                   If Successful
    **  Error Code
    **----------------------------------------------------------------------*/

#endif /* INCL_RWN_WORKOBJECT */


#if defined (__cplusplus)
}
#endif /* __cplusplus */

#ifndef RC_INVOKED
#pragma pack()                  /* restore packing to default */
#endif /* not RC_INVOKED */


#endif /* RWNAPI_INCLUDED */

