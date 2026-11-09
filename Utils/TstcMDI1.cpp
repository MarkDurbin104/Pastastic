//----------------------------------------------------------------------------
//  Project Testcom
//  
//  Copyright © 1996. All Rights Reserved.
//
//  SUBSYSTEM:    Testcom Application
//  FILE:         tstcmdi1.cpp
//  AUTHOR:       
//
//  OVERVIEW
//  ~~~~~~~~
//  Source file for implementation of TTestcomMDIChild (TMDIChild).
//
//----------------------------------------------------------------------------

#include <owl/pch.h>

#include "tstcmapp.h"
#include "tstcmdi1.h"


//{{TTestcomMDIChild Implementation}}


//--------------------------------------------------------
// TTestcomMDIChild
// ~~~~~~~~~~
// Construction/Destruction handling.
//
TTestcomMDIChild::TTestcomMDIChild(TMDIClient& parent, const char far* title, TWindow* clientWnd, bool shrinkToClient, TModule* module)
:
  TMDIChild(parent, title, clientWnd, shrinkToClient, module)
{
  // INSERT>> Your constructor code here.

}


TTestcomMDIChild::~TTestcomMDIChild()
{
  Destroy();

  // INSERT>> Your destructor code here.

}
