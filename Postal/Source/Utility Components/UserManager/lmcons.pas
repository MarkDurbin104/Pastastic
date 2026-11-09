{++

l m c o n s . p a s
Copyright (c) 1997 Alexander Staubo, all rights reserved.

Translation of lmcons.h, converted using htrans 0.3.4.

--}

unit Lmcons;

{$ALIGN ON}
{$MINENUMSIZE 4}

interface

uses
  Windows, SysUtils,
  LmErr;

{++ BUILD Version: 0003    // Increment this if a change has global effects

Copyright (c) 1990-1996  Microsoft Corporation


    LMCONS.H (was NETCONS.H in LM 2.x)

Abstract:

    This file contains constants used throughout the LAN Manager
    API header files.  It should be included in any source file
    that is going to include other LAN Manager API header files or
    call a LAN Manager API.

    NOTE:  Lengths of strings are given as the maximum lengths of the
    string in characters (not bytes).  This does not include space for the
    terminating 0-characters.  When allocating space for such an item,
    use the form:

        TCHAR username[UNLEN+1];

    Definitions of the form LN20_* define those values in effect for
    LanMan 2.0.



--}

//
// String Lengths for various LanMan names
//

const
  CNLEN = 15;
  LM20_CNLEN = 15;
  DNLEN = 15;
  LM20_DNLEN = 15;

const
  UNCLEN = (15 + 2);
  LM20_UNCLEN = (15 + 2);
  NNLEN = 80;
  LM20_NNLEN = 12;
  RMLEN = ((15 + 2) + 1 + 80);
  LM20_RMLEN = ((15 + 2) + 1 + 12);
  SNLEN = 80;
  LM20_SNLEN = 15;
  STXTLEN = 256;
  LM20_STXTLEN = 63;
  PATHLEN = 256;
  LM20_PATHLEN = 256;
  DEVLEN = 80;
  LM20_DEVLEN = 8;
  EVLEN = 16;

//
// User, Group and Password lengths
//

  UNLEN = 256;
  LM20_UNLEN = 20;
  GNLEN = 256;
  LM20_GNLEN = 20;
  PWLEN = 256;
  LM20_PWLEN = 14;
  SHPWLEN = 8;
  CLTYPE_LEN = 12;
  MAXCOMMENTSZ = 256;
  LM20_MAXCOMMENTSZ = 48;
  QNLEN = 80;
  LM20_QNLEN = 12;

//
// The ALERTSZ and MAXDEVENTRIES defines have not yet been NT'ized.
// Whoever ports these components should change these values appropriately.
//

const
  ALERTSZ = 128;
  MAXDEVENTRIES = (SizeOf(Integer)) * 8;  //!! should be Smallint?

//
// We use int bitmap to represent
//

  NETBIOS_NAME_LEN = 16;

//
// Value to be used with APIs which have a "preferred maximum length"
// parameter.  This value indicates that the API should just allocate
// "as much as it takes."
//

  MAX_PREFERRED_LENGTH = (DWORD(-1));

//
//        Constants used with encryption
//

  CRYPT_KEY_LEN = 7;
  CRYPT_TXT_LEN = 8;
  ENCRYPTED_PWLEN = 16;
  SESSION_PWLEN = 24;
  SESSION_CRYPT_KLEN = 21;

//
//  Value to be used with SetInfo calls to allow setting of all
//  settable parameters (parmnum zero option)
//

const
  PARMNUM_ALL = 0;
  PARM_ERROR_UNKNOWN = (DWORD(( - 1)));
  PARM_ERROR_NONE = 0;
  PARMNUM_BASE_INFOLEVEL = 1000;

//
//        Message File Names
//

  MESSAGE_FILENAME = 'NETMSG';
  OS2MSG_FILENAME = 'BASE';
  HELP_MSG_FILENAME = 'NETH';

{*INTERNAL_ONLY*}

  // The backup message file named here is a duplicate of net.msg. It
  // is not shipped with the product, but is used at buildtime to
  // msgbind certain messages to netapi.dll and some of the services.
  // This allows for OEMs to modify the message text in net.msg and
  // have those changes show up.        Only in case there is an error in
  // retrieving the messages from net.msg do we then get the bound
  // messages out of bak.msg (really out of the message segment).

const
  BACKUP_MSG_FILENAME = 'BAK.MSG';

{*END_INTERNAL*}

//
// Keywords used in Function Prototypes
//

// Define pseudo-keywords.

//
// The platform ID indicates the levels to use for platform-specific
// information.
//

const
  PLATFORM_ID_DOS = 300;
  PLATFORM_ID_OS2 = 400;
  PLATFORM_ID_NT = 500;
  PLATFORM_ID_OSF = 600;
  PLATFORM_ID_VMS = 700;

//
//      There message numbers assigned to different LANMAN components
//      are as defined below.
//
//      lmerr.h:        2100 - 2999     NERR_BASE
//      alertmsg.h:     3000 - 3049     ALERT_BASE
//      lmsvc.h:        3050 - 3099     SERVICE_BASE
//      lmerrlog.h:     3100 - 3299     ERRLOG_BASE
//      msgtext.h:      3300 - 3499     MTXT_BASE
//      apperr.h:       3500 - 3999     APPERR_BASE
//      apperrfs.h:     4000 - 4299     APPERRFS_BASE
//      apperr2.h:      4300 - 5299     APPERR2_BASE
//      ncberr.h:       5300 - 5499     NRCERR_BASE
//      alertmsg.h:     5500 - 5599     ALERT2_BASE
//      lmsvc.h:        5600 - 5699     SERVICE2_BASE
//      lmerrlog.h      5700 - 5799     ERRLOG2_BASE
//

  MIN_LANMAN_MESSAGE_ID = NERR_BASE;
  MAX_LANMAN_MESSAGE_ID = 5799;

implementation

end.

