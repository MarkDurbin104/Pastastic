#if !defined(__gdmdichl_h)              // Sentry, use file only if it's not already included.
#define __gdmdichl_h

/*  Project gd
    Unisys Ltd.
    Copyright Unisys Ltd. © 1994. All Rights Reserved.

    SUBSYSTEM:    gd.exe Application
    FILE:         gdmdichl.h
    AUTHOR:       Mark Durbin


    OVERVIEW
    ========
    Class definition for gdMDIChild (TMDIChild).      
*/


#include <owl\owlpch.h>
#pragma hdrstop

#include <owl\editfile.h>
#include <owl\listbox.h>

#include "gd.rh"            // Definition of all resources.


//{{TMDIChild = gdMDIChild}}
class gdMDIChild : public TMDIChild {
public:
    gdMDIChild (TMDIClient &parent, const char far *title, TWindow *clientWnd, BOOL shrinkToClient = FALSE, TModule* module = 0);
    virtual ~gdMDIChild ();

//{{gdMDIChildVIRTUAL_BEGIN}}
public:
    virtual void Paint (TDC& dc, BOOL erase, TRect& rect);
//{{gdMDIChildVIRTUAL_END}}
//{{gdMDIChildRSP_TBL_BEGIN}}
protected:
    void EvGetMinMaxInfo (MINMAXINFO far& minmaxinfo);
//{{gdMDIChildRSP_TBL_END}}
DECLARE_RESPONSE_TABLE(gdMDIChild);
};    //{{gdMDIChild}}


#endif                                      // __gdmdichl_h sentry.
