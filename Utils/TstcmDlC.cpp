//----------------------------------------------------------------------------
//  Project Testcom
//  
//  Copyright © 1996. All Rights Reserved.
//
//  SUBSYSTEM:    Testcom Application
//  FILE:         tstcmdlc.cpp
//  AUTHOR:       
//
//  OVERVIEW
//  ~~~~~~~~
//  Source file for implementation of TTestcomDlgClient (TDialog).
//
//----------------------------------------------------------------------------

#include <owl/pch.h>

#include "tstcmapp.h"
#include "tstcmdlc.h"


//{{TTestcomDlgClient Implementation}}


//
// Build a response table for all messages/commands handled
// by the application.
//
DEFINE_RESPONSE_TABLE1(TTestcomDlgClient, TDialog)
//{{TTestcomDlgClientRSP_TBL_BEGIN}}
//{{TTestcomDlgClientRSP_TBL_END}}
END_RESPONSE_TABLE;


//--------------------------------------------------------
// TTestcomDlgClient
// ~~~~~~~~~~
// Construction/Destruction handling.
//
TTestcomDlgClient::TTestcomDlgClient(TDocument& doc, TWindow* parent)
:
  TView(doc), TDialog(parent, IDD_CLIENT)
{
  // INSERT>> Your constructor code here.

}


TTestcomDlgClient::~TTestcomDlgClient()
{
  // INSERT>> Your destructor code here.

}


bool TTestcomDlgClient::CanClose()
{
  return TWindow::CanClose() && Doc->CanClose();
}
