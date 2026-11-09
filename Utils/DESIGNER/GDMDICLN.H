#if !defined(__gdmdicln_h)              // Sentry, use file only if it's not already included.
#define __gdmdicln_h

/*  Project gd
    Unisys Ltd.
    Copyright Unisys Ltd. © 1994. All Rights Reserved.

    SUBSYSTEM:    gd.exe Application
    FILE:         gdmdicln.h
    AUTHOR:       Mark Durbin


    OVERVIEW
    ========
    Class definition for gdMDIClient (TMDIClient).      
*/


#include <owl\owlpch.h>
#pragma hdrstop

#include <owl\opensave.h>

#include "gd.rh"            // Definition of all resources.


//{{TMDIClient = gdMDIClient}}
class gdMDIClient : public TMDIClient {
public:
    int                     ChildCount;                 // Number of child window created. 
    TOpenSaveDialog::TData  FileData;                   // Data to control open/saveas standard dialog.

    gdMDIClient ();
    virtual ~gdMDIClient ();

    void OpenFile (const char *fileName = 0);

private:
    void LoadTextFile ();

//{{gdMDIClientVIRTUAL_BEGIN}}
protected:
    virtual void SetupWindow ();
//{{gdMDIClientVIRTUAL_END}}

//{{gdMDIClientRSP_TBL_BEGIN}}
protected:
    void CmFileNew ();
    void CmFileOpen ();
    void CmFilePrint ();
    void CmFilePrintSetup ();
    void CmFilePrintPreview ();
    void CmPrintEnable (TCommandEnabler &tce);
    void EvDropFiles (TDropInfo);
//{{gdMDIClientRSP_TBL_END}}
DECLARE_RESPONSE_TABLE(gdMDIClient);
};    //{{gdMDIClient}}


#endif                                      // __gdmdicln_h sentry.
