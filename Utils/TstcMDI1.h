//----------------------------------------------------------------------------
//  Project Testcom
//  
//  Copyright © 1996. All Rights Reserved.
//
//  SUBSYSTEM:    Testcom Application
//  FILE:         tstcmdi1.h
//  AUTHOR:       
//
//  OVERVIEW
//  ~~~~~~~~
//  Class definition for TTestcomMDIChild (TMDIChild).
//
//----------------------------------------------------------------------------
#if !defined(tstcmdi1_h)              // Sentry, use file only if it's not already included.
#define tstcmdi1_h

#include "tstcmapp.rh"            // Definition of all resources.


//{{TMDIChild = TTestcomMDIChild}}
class TTestcomMDIChild : public TMDIChild {
  public:
    TTestcomMDIChild(TMDIClient& parent, const char far* title, TWindow* clientWnd, bool shrinkToClient = false, TModule* module = 0);
    virtual ~TTestcomMDIChild();
};    //{{TTestcomMDIChild}}


#endif  // tstcmdi1_h sentry.
