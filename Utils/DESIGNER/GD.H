#if !defined(__gd_h)              // Sentry, use file only if it's not already included.
#define __gd_h

/*  Project gd
    Unisys Ltd.
    Copyright Unisys Ltd. © 1994. All Rights Reserved.

    SUBSYSTEM:    gd.exe Application
    FILE:         gd.h
    AUTHOR:       Mark Durbin


    OVERVIEW
    ========
    Class definition for gdApp (TApplication).      
*/


#include <owl\owlpch.h>
#pragma hdrstop

#include <owl\statusba.h>
#include <owl\controlb.h>
#include <owl\buttonga.h>
#include <owl\printer.h>

#include <classlib\bags.h>


#include "gd.rh"            // Definition of all resources.


// TFileDrop class Maintains information about a dropped file, its name, where it was dropped,
// and whether or not it was in the client area
class TFileDrop {
public:
    operator == (const TFileDrop& other) const {return this == &other;}

    char*   FileName;
    TPoint  Point;
    BOOL    InClientArea;

    HICON   Icon;
    BOOL    DefIcon;

    TFileDrop (char*, TPoint&, BOOL, TModule* module);
    ~TFileDrop ();

    const char* WhoAmI ();
private:
    //
    // hidden to prevent accidental copying or assignment
    //
    TFileDrop (const TFileDrop&);
    TFileDrop & operator = (const TFileDrop&);
};

typedef TIBagAsVector<TFileDrop> TFileList;
typedef TIBagAsVectorIterator<TFileDrop> TFileListIter;


//{{TApplication = gdApp}}
class gdApp : public TApplication {
private:
    BOOL            HelpState;                          // Has the help engine been used.
    BOOL            ContextHelp;                        // SHIFT-F1 state (context sensitive HELP)
    HCURSOR         HelpCursor;                         // Context sensitive help cursor

private:
    void SetupSpeedBar (TDecoratedMDIFrame *frame);
    void AddFiles (TFileList* files);

public:
    gdApp ();
    virtual ~gdApp ();

    // Public data members used by the print menu commands and Paint routine in MDIChild.
    TPrinter        *Printer;                           // Printer support.
    BOOL            Printing;                           // Printing in progress.

//{{gdAppVIRTUAL_BEGIN}}
public:
    virtual void InitMainWindow();
    virtual void InitInstance();
    virtual BOOL CanClose ();
    virtual BOOL ProcessAppMsg (MSG& msg);
//{{gdAppVIRTUAL_END}}
//{{gdAppRSP_TBL_BEGIN}}
protected:
    void CmHelpContents ();
    void CmHelpUsing ();
    void CmHelpAbout ();
    void EvDropFiles (TDropInfo drop);
    void EvWinIniChange (char far* section);
//{{gdAppRSP_TBL_END}}
DECLARE_RESPONSE_TABLE(gdApp);
};    //{{gdApp}}


#endif                                      // __gd_h sentry.
