// Function.h
//

UINT FAR PASCAL Function(LPCTSTR szCaption,      // Title bar caption
                         LPCTSTR szTrackingNode, // Event identifier for recording
                         CWnd* pParentWnd,       // Pointer to the parent window (*)
                         LPVOID lpReserved);     // Reserved for future use, currently ignored

// The return code (UINT) is currently ignored by IPS'96.

(*) This is a dependency on MFCs. This dependency will disappear in the future.