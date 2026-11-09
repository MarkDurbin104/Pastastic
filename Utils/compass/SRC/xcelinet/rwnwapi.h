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

typedef unsigned short  WORD ;      /* 16-Bit unsigned value */

#define	RWNENTRY            FAR PASCAL _export
#define APIDECL

APIDECL WORD RWNENTRY RWNodeRequest(WORD wRequest);

