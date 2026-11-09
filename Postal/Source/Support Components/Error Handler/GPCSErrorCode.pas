{  Module          Corvus Error Handler
   Unit            Error Codes
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description     List of all Error Codes for Component,Class and Method
   Modifications   19/03/98 - MJD
                              Original Release
}
unit GPCSErrorCode;

interface
const
  
// ============================ Error Origin Codes==============================

// Base Components
  EC_ErrMan	     = $0100; // Error Manager	    
  EC_CompMan	  = $0200; // Component Manager	 
  EC_CompLoad	  = $0300; // Component Loader	 
  EC_UserServ	  = $0400; // User Interface Server
  EC_UserClient  = $0500; // User Interface Client
  EC_TransLog	  = $0600; // Transaction Log	    
  EC_Stock	     = $0700; // Stock	             
  EC_Scale	     = $0800; // Scale	             
  EC_Receipt	  = $0900; // Receipt	          
  EC_Product	  = $0A00; // Product	          
  EC_Group	     = $0B00; // Group	             
  EC_LookUp	     = $0C00; // LookUp	          
  EC_PickList	  = $0D00; // Pick List	       
  EC_Service	  = $0E00; // Service	          
  EC_WSGroup	  = $0F00; // Work Station Group	 
  EC_UserGroup   = $1000; // User Group	       
  EC_Account	  = $1100; // Accounting	       
  EC_Calc	     = $1200; // Calculator	       
  EC_OPOSDev	  = $1300; // OPOS Device Manager	 
  EC_SiteMan	  = $1400; // Site Manager	       
  EC_DistMan	  = $1500; // Distribution Manager
  EC_Customer	  = $1600; // Customer Session	 
  EC_CompDes	  = $1700; // Component Designer	 
  EC_PostBank	  = $1800; // Post Bank Application
  EC_Support	  = $1900; // Support Package	    
  EC_PSLVCL	     = $1A00; // PSL VCL Controls	    
  EC_GPCSBase    = $1B00; // GPCS Base Classes
  
// Error Manager Classes
  EC_ErrMan_TErrorHandler = (EC_ErrMan + $01) shl 8;
    // ErrMan TErrorHandler Methods
    EC_ErrMan_TErrorHandler_ErrorMessage = (EC_ErrMan_TErrorHandler + $01) shl 8;
    EC_ErrMan_TErrorHandler_Initialize   = (EC_ErrMan_TErrorHandler + $02) shl 8;
    EC_ErrMan_TErrorHandler_Destroy      = (EC_ErrMan_TErrorHandler + $03) shl 8;
    EC_ErrMan_TErrorHandler_RaiseError   = (EC_ErrMan_TErrorHandler + $04) shl 8;
    EC_ErrMan_TErrorHandler_Get_LogFile  = (EC_ErrMan_TErrorHandler + $05) shl 8;
    EC_ErrMan_TErrorHandler_Get_Visible  = (EC_ErrMan_TErrorHandler + $06) shl 8;
    EC_ErrMan_TErrorHandler_Set_LogFile  = (EC_ErrMan_TErrorHandler + $07) shl 8;
    EC_ErrMan_TErrorHandler_Set_Visible  = (EC_ErrMan_TErrorHandler + $08) shl 8;
    
  EC_ErrMan_TErrorForm = (EC_ErrMan + $02) shl 8;
    // ErrMan TErrorForm Methods
    EC_ErrMan_TErrorForm_CompleteButtonClick = (EC_ErrMan_TErrorForm + $01) shl 8;
    EC_ErrMan_TErrorForm_FormCreate          = (EC_ErrMan_TErrorForm + $02) shl 8;

  EC_GPCSBase_TGPCSCompFactory = (EC_GPCSBase + $01) shl 8;
    EC_GPCSBase_TGPCSCompFactory_GetProgID = (EC_GPCSBase_TGPCSCompFactory + $01) shl 8;
    
  EC_GPCSBase_TGPCSComponent = (EC_GPCSBase + $02) shl 8;
    EC_GPCSBase_TGPCSComponent_Get_InterfaceVersion = (EC_GPCSBase_TGPCSComponent + $01) shl 8;
    
  EC_GPCSBase_TGPCSExecComponent = (EC_GPCSBase + $03) shl 8;
    EC_GPCSBase_TGPCSExecComponent_Destroy       = (EC_GPCSBase_TGPCSExecComponent + $01) shl 8;
    EC_GPCSBase_TGPCSExecComponent_Get_Parent    = (EC_GPCSBase_TGPCSExecComponent + $02) shl 8;
    EC_GPCSBase_TGPCSExecComponent_Get_EventSink = (EC_GPCSBase_TGPCSExecComponent + $03) shl 8;
    EC_GPCSBase_TGPCSExecComponent_Set_Parent    = (EC_GPCSBase_TGPCSExecComponent + $04) shl 8;
    EC_GPCSBase_TGPCSExecComponent_Set_EventSink = (EC_GPCSBase_TGPCSExecComponent + $05) shl 8;
    EC_GPCSBase_TGPCSExecComponent_FireHadClick  = (EC_GPCSBase_TGPCSExecComponent + $06) shl 8;
    EC_GPCSBase_TGPCSExecComponent_FireMouseMove = (EC_GPCSBase_TGPCSExecComponent + $07) shl 8;
    EC_GPCSBase_TGPCSExecComponent_Get_PMessage  = (EC_GPCSBase_TGPCSExecComponent + $08) shl 8;
    EC_GPCSBase_TGPCSExecComponent_Get_Prompt    = (EC_GPCSBase_TGPCSExecComponent + $09) shl 8;
    EC_GPCSBase_TGPCSExecComponent_Get_Title     = (EC_GPCSBase_TGPCSExecComponent + $0A) shl 8;
    
  EC_GPCSBase_TButtonFront = (EC_GPCSBase + $04) shl 8;
    EC_GPCSBase_TButtonFront_WMEraseBkgnd     = (EC_GPCSBase_TButtonFront + $01) shl 8;
    EC_GPCSBase_TButtonFront_WndProc          = (EC_GPCSBase_TButtonFront + $02) shl 8;
    EC_GPCSBase_TButtonFront_CreateParams     = (EC_GPCSBase_TButtonFront + $03) shl 8;
    EC_GPCSBase_TButtonFront_FillParentWindow = (EC_GPCSBase_TButtonFront + $04) shl 8;
    
  EC_Product_TBaseProduct = (EC_Product + $01) shl 8;
    EC_Product_TBaseProduct_GetResourceString = (EC_Product_TBaseProduct + $01) shl 8;
    EC_Product_TBaseProduct_Get_Version       = (EC_Product_TBaseProduct + $02) shl 8;
    EC_Product_TBaseProduct_Design            = (EC_Product_TBaseProduct + $03) shl 8;
    EC_Product_TBaseProduct_TerminateDesign   = (EC_Product_TBaseProduct + $04) shl 8;
    EC_Product_TBaseProduct_TerminateExecute  = (EC_Product_TBaseProduct + $05) shl 8;
    EC_Product_TBaseProduct_Get_BarCode       = (EC_Product_TBaseProduct + $06) shl 8;
    EC_Product_TBaseProduct_Get_Description   = (EC_Product_TBaseProduct + $07) shl 8;
    EC_Product_TBaseProduct_Get_EndDate       = (EC_Product_TBaseProduct + $08) shl 8;
    EC_Product_TBaseProduct_Get_HighDays      = (EC_Product_TBaseProduct + $09) shl 8;
    EC_Product_TBaseProduct_Get_MaxQuantity   = (EC_Product_TBaseProduct + $0A) shl 8;
    EC_Product_TBaseProduct_Get_MCRCode       = (EC_Product_TBaseProduct + $0B) shl 8;
    EC_Product_TBaseProduct_Get_MinQuantity   = (EC_Product_TBaseProduct + $0C) shl 8;
    EC_Product_TBaseProduct_Get_OCRCode       = (EC_Product_TBaseProduct + $0D) shl 8;
    EC_Product_TBaseProduct_Get_OtherCode     = (EC_Product_TBaseProduct + $0E) shl 8;
    EC_Product_TBaseProduct_Get_PLU           = (EC_Product_TBaseProduct + $0F) shl 8;
    EC_Product_TBaseProduct_Get_Regulations   = (EC_Product_TBaseProduct + $10) shl 8;
    EC_Product_TBaseProduct_Get_StartDate     = (EC_Product_TBaseProduct + $11) shl 8;
    EC_Product_TBaseProduct_Get_UnitPrice     = (EC_Product_TBaseProduct + $12) shl 8;
    EC_Product_TBaseProduct_Get_UnitQuantity  = (EC_Product_TBaseProduct + $13) shl 8;
    EC_Product_TBaseProduct_Get_UseDays       = (EC_Product_TBaseProduct + $14) shl 8;
    EC_Product_TBaseProduct_Get_BitMap        = (EC_Product_TBaseProduct + $15) shl 8;
    EC_Product_TBaseProduct_Get_Caption       = (EC_Product_TBaseProduct + $16) shl 8;
    EC_Product_TBaseProduct_Get_Price         = (EC_Product_TBaseProduct + $17) shl 8;
    EC_Product_TBaseProduct_Get_Count         = (EC_Product_TBaseProduct + $18) shl 8;
    EC_Product_TBaseProduct_Get_Item          = (EC_Product_TBaseProduct + $19) shl 8;
    
  EC_Group_TBaseGroup = (EC_Group + $01) shl 8;
    EC_Group_TBaseGroup_GetResourceString = (EC_Group_TBaseGroup + $01) shl 8;
    EC_Group_TBaseGroup_Get_Version       = (EC_Group_TBaseGroup + $02) shl 8;
    EC_Group_TBaseGroup_Design            = (EC_Group_TBaseGroup + $03) shl 8;
    EC_Group_TBaseGroup_TerminateDesign   = (EC_Group_TBaseGroup + $04) shl 8;
    EC_Group_TBaseGroup_TerminateExecute  = (EC_Group_TBaseGroup + $05) shl 8;
    EC_Group_TBaseGroup_Get_BitMap        = (EC_Group_TBaseGroup + $06) shl 8;
    EC_Group_TBaseGroup_Get_Caption       = (EC_Group_TBaseGroup + $07) shl 8;
    EC_Group_TBaseGroup_Get_Price         = (EC_Group_TBaseGroup + $08) shl 8;
    EC_Group_TBaseGroup_Get_Count         = (EC_Group_TBaseGroup + $09) shl 8;
    EC_Group_TBaseGroup_Get_Item          = (EC_Group_TBaseGroup + $0A) shl 8;
    EC_Group_TBaseGroup_Get_Key           = (EC_Group_TBaseGroup + $0B) shl 8;
                                                 
// ======================== Error Code To Index List ===========================
// Look up an error code in ECToIndexList to find the index of the error message 
// in the ECToStringList array
// =============================================================================

  ECToIndexListCount = 98;
  ECToIndexList:Array[0..ECToIndexListCount-1] of Integer = (
    EC_ErrMan	                                      , // 0
    EC_CompMan	                                      , // 1
    EC_CompLoad                                      , // 2
    EC_UserServ                                      , // 3
    EC_UserClient                                    , // 4
    EC_TransLog                                      , // 5
    EC_Stock	                                      , // 6
    EC_Scale	                                      , // 7
    EC_Receipt	                                      , // 8
    EC_Product	                                      , // 9
    EC_Group	                                      , // 10
    EC_LookUp	                                      , // 11
    EC_PickList                                      , // 12
    EC_Service	                                      , // 13
    EC_WSGroup	                                      , // 14
    EC_UserGroup                                     , // 15
    EC_Account	                                      , // 16
    EC_Calc	                                         , // 17
    EC_OPOSDev	                                      , // 18
    EC_SiteMan	                                      , // 19
    EC_DistMan	                                      , // 20
    EC_Customer                                      , // 21
    EC_CompDes	                                      , // 22
    EC_PostBank                                      , // 23
    EC_Support	                                      , // 24
    EC_PSLVCL	                                      , // 25
    EC_GPCSBase                                      , // 26
    EC_ErrMan_TErrorHandler                          , // 27
    EC_ErrMan_TErrorHandler_ErrorMessage             , // 28
    EC_ErrMan_TErrorHandler_Initialize               , // 29
    EC_ErrMan_TErrorHandler_Destroy                  , // 30
    EC_ErrMan_TErrorHandler_RaiseError               , // 31
    EC_ErrMan_TErrorHandler_Get_LogFile              , // 32
    EC_ErrMan_TErrorHandler_Get_Visible              , // 33
    EC_ErrMan_TErrorHandler_Set_LogFile              , // 34
    EC_ErrMan_TErrorHandler_Set_Visible              , // 35
    EC_ErrMan_TErrorForm                             , // 36
    EC_ErrMan_TErrorForm_CompleteButtonClick         , // 37
    EC_ErrMan_TErrorForm_FormCreate                  , // 38
    EC_GPCSBase_TGPCSCompFactory                     , // 39
    EC_GPCSBase_TGPCSCompFactory_GetProgID           , // 40
    EC_GPCSBase_TGPCSComponent                       , // 41
    EC_GPCSBase_TGPCSComponent_Get_InterfaceVersion  , // 42
    EC_GPCSBase_TGPCSExecComponent                   , // 43
    EC_GPCSBase_TGPCSExecComponent_Destroy           , // 44
    EC_GPCSBase_TGPCSExecComponent_Get_Parent        , // 45
    EC_GPCSBase_TGPCSExecComponent_Get_EventSink     , // 46
    EC_GPCSBase_TGPCSExecComponent_Set_Parent        , // 47
    EC_GPCSBase_TGPCSExecComponent_Set_EventSink     , // 48
    EC_GPCSBase_TGPCSExecComponent_FireHadClick      , // 49
    EC_GPCSBase_TGPCSExecComponent_FireMouseMove     , // 50
    EC_GPCSBase_TButtonFront                         , // 51
    EC_GPCSBase_TButtonFront_WMEraseBkgnd            , // 52
    EC_GPCSBase_TButtonFront_WndProc                 , // 53
    EC_GPCSBase_TButtonFront_CreateParams            , // 54
    EC_GPCSBase_TButtonFront_FillParentWindow        , // 55
    EC_Product_TBaseProduct                          , // 56
    EC_Product_TBaseProduct_GetResourceString        , // 57
    EC_Product_TBaseProduct_Get_Version              , // 58
    EC_Product_TBaseProduct_Design                   , // 59
    EC_Product_TBaseProduct_TerminateDesign          , // 60
    EC_Product_TBaseProduct_TerminateExecute         , // 61
    EC_Product_TBaseProduct_Get_BarCode              , // 62
    EC_Product_TBaseProduct_Get_Description          , // 63
    EC_Product_TBaseProduct_Get_EndDate              , // 64
    EC_Product_TBaseProduct_Get_HighDays             , // 65
    EC_Product_TBaseProduct_Get_MaxQuantity          , // 66
    EC_Product_TBaseProduct_Get_MCRCode              , // 67
    EC_Product_TBaseProduct_Get_MinQuantity          , // 68
    EC_Product_TBaseProduct_Get_OCRCode              , // 69
    EC_Product_TBaseProduct_Get_OtherCode            , // 70
    EC_Product_TBaseProduct_Get_PLU                  , // 71
    EC_Product_TBaseProduct_Get_Regulations          , // 72
    EC_Product_TBaseProduct_Get_StartDate            , // 73
    EC_Product_TBaseProduct_Get_UnitPrice            , // 74
    EC_Product_TBaseProduct_Get_UnitQuantity         , // 75
    EC_Product_TBaseProduct_Get_UseDays              , // 76
    EC_Product_TBaseProduct_Get_BitMap               , // 77
    EC_Product_TBaseProduct_Get_Caption              , // 78
    EC_Product_TBaseProduct_Get_Price                , // 79
    EC_Product_TBaseProduct_Get_Count                , // 80
    EC_Product_TBaseProduct_Get_Item                 , // 81
    EC_Group_TBaseGroup                              , // 82
    EC_Group_TBaseGroup_GetResourceString            , // 83
    EC_Group_TBaseGroup_Get_Version                  , // 84
    EC_Group_TBaseGroup_Design                       , // 85
    EC_Group_TBaseGroup_TerminateDesign              , // 86
    EC_Group_TBaseGroup_TerminateExecute             , // 87
    EC_Group_TBaseGroup_Get_BitMap                   , // 88
    EC_Group_TBaseGroup_Get_Caption                  , // 89
    EC_Group_TBaseGroup_Get_Price                    , // 90
    EC_Group_TBaseGroup_Get_Count                    , // 91
    EC_Group_TBaseGroup_Get_Item                     , // 92
    EC_Group_TBaseGroup_Get_Key                      , // 93
    EC_GPCSBase_TGPCSExecComponent_Get_PMessage      , // 94
    EC_GPCSBase_TGPCSExecComponent_Get_Prompt        , // 95
    EC_GPCSBase_TGPCSExecComponent_Get_Title         , // 96

                                                                 
    -1 // included to make adding lines easier            
  );
// ======================== Error Code To String List ==========================
  ECToStringList:Array[0..ECToIndexListCount-1] of String = (
    'Error Manager'         , // 0
    'Component Manager'     , // 1
    'Component Loader'      , // 2
    'User Interface Server' , // 3
    'User Interface Client' , // 4
    'Transaction Log'       , // 5
    'Stock'                 , // 6
    'Scale'                 , // 7
    'Receipt'               , // 8
    'Product'               , // 9
    'Group'                 , // 10
    'LookUp'                , // 11
    'Pick List'             , // 12
    'Service'               , // 13
    'Work Station Group'    , // 14
    'User Group'            , // 15
    'Accounting'            , // 16
    'Calculator'            , // 17
    'OPOS Device Manager'   , // 18
    'Site Manager'          , // 19
    'Distribution Manager'  , // 20
    'Customer Session'      , // 21
    'Component Designer'    , // 22
    'Post Bank Application' , // 23
    'Support Package'       , // 24
    'PSL VCL Controls'      , // 25
    'GPCS Base Classes'     , // 26
    'TErrorHandler'         , // 27
    'ErrorMessage'          , // 28
    'Initialize'            , // 29
    'Destroy'               , // 30
    'RaiseError'            , // 31
    'Get_LogFile'           , // 32
    'Get_Visible'           , // 33
    'Set_LogFile'           , // 34
    'Set_Visible'           , // 35
    'TErrorForm'            , // 36
    'CompleteButtonClick'   , // 37
    'FormCreate'            , // 38
    'TGPCSCompFactory'      , // 39
    'GetProgID'             , // 40
    'TGPCSComponent'        , // 41
    'Get_InterfaceVersion'  , // 42
    'TGPCSExecComponent'    , // 43
    'Destroy'               , // 44
    'Get_Parent'            , // 45
    'Get_EventSink'         , // 46
    'Set_Parent'            , // 47
    'Set_EventSink'         , // 48
    'FireHadClick'          , // 49
    'FireMouseMove'         , // 50
    'TButtonFront'          , // 51
    'WMEraseBkgnd'          , // 52
    'WndProc'               , // 53
    'CreateParams'          , // 54
    'FillParentWindow'      , // 55
    'TBaseProduct'          , // 56
    'GetResourceString'     , // 57
    'Get_Version'           , // 58
    'Design'                , // 59
    'TerminateDesign'       , // 60
    'TerminateExecute'      , // 61
    'Get_BarCode'           , // 62
    'Get_Description'       , // 63
    'Get_EndDate'           , // 64
    'Get_HighDays'          , // 65
    'Get_MaxQuantity'       , // 66
    'Get_MCRCode'           , // 67
    'Get_MinQuantity'       , // 68
    'Get_OCRCode'           , // 69
    'Get_OtherCode'         , // 70
    'Get_PLU'               , // 71
    'Get_Regulations'       , // 72
    'Get_StartDate'         , // 73
    'Get_UnitPrice'         , // 74
    'Get_UnitQuantity'      , // 75
    'Get_UseDays'           , // 76
    'Get_BitMap'            , // 77
    'Get_Caption'           , // 78
    'Get_Price'             , // 79
    'Get_Count'             , // 80
    'Get_Item'              , // 81
    'TBaseGroup'            , // 82
    'GetResourceString'     , // 83
    'Get_Version'           , // 84
    'Design'                , // 85
    'TerminateDesign'       , // 86
    'TerminateExecute'      , // 87
    'Get_BitMap'            , // 88
    'Get_Caption'           , // 89
    'Get_Price'             , // 90
    'Get_Count'             , // 91
    'Get_Item'              , // 92
    'Get_Key'               , // 93
    'Get_PMessage'          , // 94
    'Get_Prompt'            , // 95
    'Get_Title'             , // 96
    'Array Over Run' // included to make adding lines easier
  );                         
  
implementation
end.                        
                            
                            
                            
                            