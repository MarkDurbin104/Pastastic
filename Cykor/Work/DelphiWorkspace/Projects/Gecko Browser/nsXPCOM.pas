unit nsXPCOM;

interface

uses
  nsConsts, nsGeckoStrings, nsTypes;

const
  NS_ISUPPORTS_IID: TGUID = '{00000000-0000-0000-c000-000000000046}';

  MOZIJSSUBSCRIPTLOADER_IID: TGUID = '{8792d77e-1dd2-11b2-ac7f-9bc9be4f2916}';

  NS_ISIMPLEENUMERATOR_IID: TGUID = '{d1899240-f9d2-11d2-bdd6-000064657374}';

  NS_ICATEGORYMANAGER_IID: TGUID = '{3275b2cd-af6d-429a-80d7-f0c5120342ac}';

  NS_IREQUEST_IID: TGUID = '{ef6bfbd2-fd46-48d8-96b7-9f8f0fd387fe}';
  NS_IREQUEST_LOAD_NORMAL = 0;
  NS_IREQUEST_LOAD_BACKGROUND = 1;
  NS_IREQUEST_INHIBIT_CACHING = 128;
  NS_IREQUEST_INHIBIT_PERSISTENT_CACHING = 256;
  NS_IREQUEST_LOAD_BYPASS_CACHE = 512;
  NS_IREQUEST_LOAD_FROM_CACHE = 1024;
  NS_IREQUEST_VALIDATE_ALWAYS = 2048;
  NS_IREQUEST_VALIDATE_NEVER = 4096;
  NS_IREQUEST_VALIDATE_ONCE_PER_SESSION = 8192;

  NS_ICHANNEL_IID: TGUID = '{c63a055a-a676-4e71-bf3c-6cfa11082018}';
  NS_ICHANNEL_LOAD_DOCUMENT_URI = 65536;
  NS_ICHANNEL_LOAD_RETARGETED_DOCUMENT_URI = 131072;
  NS_ICHANNEL_LOAD_REPLACE = 262144;
  NS_ICHANNEL_LOAD_INITIAL_DOCUMENT_URI = 524288;

  NS_IPROGRAMMINGLANGUAGE_IID: TGUID = '{ea604e90-40ba-11d5-90bb-0010a4e73d9a}';
  NS_IPROGRAMMINGLANGUAGE_UNKNOWN = 0;
  NS_IPROGRAMMINGLANGUAGE_CPLUSPLUS = 1;
  NS_IPROGRAMMINGLANGUAGE_JAVASCRIPT = 2;
  NS_IPROGRAMMINGLANGUAGE_PYTHON = 3;
  NS_IPROGRAMMINGLANGUAGE_PERL = 4;
  NS_IPROGRAMMINGLANGUAGE_JAVA = 5;
  NS_IPROGRAMMINGLANGUAGE_ZX81_BASIC = 6;
  NS_IPROGRAMMINGLANGUAGE_JAVASCRIPT2 = 7;

  NS_ICLASSINFO_IID: TGUID = '{986c11d0-f340-11d4-9075-0010a4e73d9a}';
  NS_ICLASSINFO_SINGLETON = 1;
  NS_ICLASSINFO_THREADSAFE = 2;
  NS_ICLASSINFO_MAIN_THREAD_ONLY = 4;
  NS_ICLASSINFO_DOM_OBJECT = 8;
  NS_ICLASSINFO_PLUGIN_OBJECT = 16;
  NS_ICLASSINFO_EAGER_CLASSINFO = 32;
  NS_ICLASSINFO_CONTENT_NODE = 64;
  NS_ICLASSINFO_RESERVED = 2147483648;

  NS_ICLIPBOARDCOMMANDS_IID: TGUID = '{b8100c90-73be-11d2-92a5-00105a1b0d64}';

  NS_ICOMPONENTMANAGER_IID: TGUID = '{a88e5a60-205a-4bb1-94e1-2628daf51eae}';

  NS_ICOMPONENTREGISTRAR_IID: TGUID = '{2417cbfe-65ad-48a6-b4b6-eb84db174392}';

  NS_ICONTEXTMENULISTENER_IID: TGUID = '{3478b6b0-3875-11d4-94ef-0020183bf181}';
  NS_ICONTEXTMENULISTENER_CONTEXT_NONE = 0;
  NS_ICONTEXTMENULISTENER_CONTEXT_LINK = 1;
  NS_ICONTEXTMENULISTENER_CONTEXT_IMAGE = 2;
  NS_ICONTEXTMENULISTENER_CONTEXT_DOCUMENT = 4;
  NS_ICONTEXTMENULISTENER_CONTEXT_TEXT = 8;
  NS_ICONTEXTMENULISTENER_CONTEXT_INPUT = 16;

  NS_ICOOKIE_IID: TGUID = '{e9fcb9a4-d376-458f-b720-e65e7df593bc}';
  NS_ICOOKIE_STATUS_UNKNOWN = 0;
  NS_ICOOKIE_STATUS_ACCEPTED = 1;
  NS_ICOOKIE_STATUS_DOWNGRADED = 2;
  NS_ICOOKIE_STATUS_FLAGGED = 3;
  NS_ICOOKIE_STATUS_REJECTED = 4;
  NS_ICOOKIE_POLICY_UNKNOWN = 0;
  NS_ICOOKIE_POLICY_NONE = 1;
  NS_ICOOKIE_POLICY_NO_CONSENT = 2;
  NS_ICOOKIE_POLICY_IMPLICIT_CONSENT = 3;
  NS_ICOOKIE_POLICY_EXPLICIT_CONSENT = 4;
  NS_ICOOKIE_POLICY_NO_II = 5;

  NS_ICOOKIEMANAGER_IID: TGUID = '{aaab6710-0f2c-11d5-a53b-0010a401eb10}';

  NS_IDEBUG_IID: TGUID = '{3bf0c3d7-3bd9-4cf2-a971-33572c503e1e}';

  NS_IFILE_IID: TGUID = '{c8c0a080-0868-11d3-915f-d9d889d48e3c}';
  NS_IFILE_NORMAL_FILE_TYPE = 0;
  NS_IFILE_DIRECTORY_TYPE = 1;

  NS_IDIRECTORYSERVICEPROVIDER_IID: TGUID = '{bbf8cab0-d43a-11d3-8cc2-00609792278c}';

  NS_IDIRECTORYSERVICEPROVIDER2_IID: TGUID = '{2f977d4b-5485-11d4-87e2-0010a4e75ef2}';

  NS_IDIRECTORYSERVICE_IID: TGUID = '{57a66a60-d43a-11d3-8cc2-00609792278c}';

  NS_IDOM3DOCUMENTEVENT_IID: TGUID = '{090ecc19-b7cb-4f47-ae47-ed68d4926249}';

  NS_IDOM3EVENTTARGET_IID: TGUID = '{3e9c01a7-de97-4c3b-8294-b4bd9d7056d1}';

  NS_IDOMABSTRACTVIEW_IID: TGUID = '{f51ebade-8b1a-11d3-aae7-0010830123b4}';

  NS_IDOMNODE_IID: TGUID = '{a6cf907c-15b3-11d2-932e-00805f8add32}';
  NS_IDOMNODE_ELEMENT_NODE = 1;
  NS_IDOMNODE_ATTRIBUTE_NODE = 2;
  NS_IDOMNODE_TEXT_NODE = 3;
  NS_IDOMNODE_CDATA_SECTION_NODE = 4;
  NS_IDOMNODE_ENTITY_REFERENCE_NODE = 5;
  NS_IDOMNODE_ENTITY_NODE = 6;
  NS_IDOMNODE_PROCESSING_INSTRUCTION_NODE = 7;
  NS_IDOMNODE_COMMENT_NODE = 8;
  NS_IDOMNODE_DOCUMENT_NODE = 9;
  NS_IDOMNODE_DOCUMENT_TYPE_NODE = 10;
  NS_IDOMNODE_DOCUMENT_FRAGMENT_NODE = 11;
  NS_IDOMNODE_NOTATION_NODE = 12;

  NS_IDOMATTR_IID: TGUID = '{a6cf9070-15b3-11d2-932e-00805f8add32}';

  NS_IDOMBARPROP_IID: TGUID = '{9eb2c150-1d56-11d3-8221-0060083a0bcf}';

  NS_IDOMCHARACTERDATA_IID: TGUID = '{a6cf9072-15b3-11d2-932e-00805f8add32}';

  NS_IDOMTEXT_IID: TGUID = '{a6cf9082-15b3-11d2-932e-00805f8add32}';

  NS_IDOMCDATASECTION_IID: TGUID = '{a6cf9071-15b3-11d2-932e-00805f8add32}';

  NS_IDOMCOMMENT_IID: TGUID = '{a6cf9073-15b3-11d2-932e-00805f8add32}';

  NS_IDOMCSSVALUE_IID: TGUID = '{009f7ea5-9e80-41be-b008-db62f10823f2}';
  NS_IDOMCSSVALUE_CSS_INHERIT = 0;
  NS_IDOMCSSVALUE_CSS_PRIMITIVE_VALUE = 1;
  NS_IDOMCSSVALUE_CSS_VALUE_LIST = 2;
  NS_IDOMCSSVALUE_CSS_CUSTOM = 3;

  NS_IDOMCSSPRIMITIVEVALUE_IID: TGUID = '{e249031f-8df9-4e7a-b644-18946dce0019}';
  NS_IDOMCSSPRIMITIVEVALUE_CSS_UNKNOWN = 0;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_NUMBER = 1;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_PERCENTAGE = 2;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_EMS = 3;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_EXS = 4;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_PX = 5;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_CM = 6;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_MM = 7;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_IN = 8;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_PT = 9;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_PC = 10;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_DEG = 11;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_RAD = 12;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_GRAD = 13;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_MS = 14;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_S = 15;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_HZ = 16;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_KHZ = 17;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_DIMENSION = 18;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_STRING = 19;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_URI = 20;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_IDENT = 21;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_ATTR = 22;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_COUNTER = 23;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_RECT = 24;
  NS_IDOMCSSPRIMITIVEVALUE_CSS_RGBCOLOR = 25;

  NS_IDOMCSSRULE_IID: TGUID = '{a6cf90c1-15b3-11d2-932e-00805f8add32}';
  NS_IDOMCSSRULE_UNKNOWN_RULE = 0;
  NS_IDOMCSSRULE_STYLE_RULE = 1;
  NS_IDOMCSSRULE_CHARSET_RULE = 2;
  NS_IDOMCSSRULE_IMPORT_RULE = 3;
  NS_IDOMCSSRULE_MEDIA_RULE = 4;
  NS_IDOMCSSRULE_FONT_FACE_RULE = 5;
  NS_IDOMCSSRULE_PAGE_RULE = 6;

  NS_IDOMCSSRULELIST_IID: TGUID = '{a6cf90c0-15b3-11d2-932e-00805f8add32}';

  NS_IDOMCSSSTYLEDECLARATION_IID: TGUID = '{a6cf90be-15b3-11d2-932e-00805f8add32}';

  NS_IDOMSTYLESHEET_IID: TGUID = '{a6cf9080-15b3-11d2-932e-00805f8add32}';

  NS_IDOMCSSSTYLESHEET_IID: TGUID = '{a6cf90c2-15b3-11d2-932e-00805f8add32}';

  NS_IDOMCSSVALUELIST_IID: TGUID = '{8f09fa84-39b9-4dca-9b2f-db0eeb186286}';

  NS_IDOMEVENT_IID: TGUID = '{a66b7b80-ff46-bd97-0080-5f8ae38add32}';
  NS_IDOMEVENT_CAPTURING_PHASE = 1;
  NS_IDOMEVENT_AT_TARGET = 2;
  NS_IDOMEVENT_BUBBLING_PHASE = 3;

  NS_IDOMCUSTOMEVENT_IID: TGUID = '{55c7af7b-1a64-40bf-87eb-2c2cbee0491b}';

  NS_IDOMDOCUMENT_IID: TGUID = '{a6cf9075-15b3-11d2-932e-00805f8add32}';

  NS_IDOMDOCUMENTEVENT_IID: TGUID = '{46b91d66-28e2-11d4-ab1e-0010830123b4}';

  NS_IDOMDOCUMENTFRAGMENT_IID: TGUID = '{a6cf9076-15b3-11d2-932e-00805f8add32}';

  NS_IDOMDOCUMENTRANGE_IID: TGUID = '{7b9badc6-c9bc-447a-8670-dbd195aed24b}';

  NS_IDOMDOCUMENTSTYLE_IID: TGUID = '{3d9f4973-dd2e-48f5-b5f7-2634e09eadd9}';

  NS_IDOMDOCUMENTTYPE_IID: TGUID = '{a6cf9077-15b3-11d2-932e-00805f8add32}';

  NS_IDOMDOCUMENTVIEW_IID: TGUID = '{1acdb2ba-1dd2-11b2-95bc-9542495d2569}';

  NS_IDOMDOMEXCEPTION_IID: TGUID = '{a6cf910a-15b3-11d2-932e-00805f8add32}';
  NS_IDOMDOMEXCEPTION_INDEX_SIZE_ERR = 1;
  NS_IDOMDOMEXCEPTION_DOMSTRING_SIZE_ERR = 2;
  NS_IDOMDOMEXCEPTION_HIERARCHY_REQUEST_ERR = 3;
  NS_IDOMDOMEXCEPTION_WRONG_DOCUMENT_ERR = 4;
  NS_IDOMDOMEXCEPTION_INVALID_CHARACTER_ERR = 5;
  NS_IDOMDOMEXCEPTION_NO_DATA_ALLOWED_ERR = 6;
  NS_IDOMDOMEXCEPTION_NO_MODIFICATION_ALLOWED_ERR = 7;
  NS_IDOMDOMEXCEPTION_NOT_FOUND_ERR = 8;
  NS_IDOMDOMEXCEPTION_NOT_SUPPORTED_ERR = 9;
  NS_IDOMDOMEXCEPTION_INUSE_ATTRIBUTE_ERR = 10;
  NS_IDOMDOMEXCEPTION_INVALID_STATE_ERR = 11;
  NS_IDOMDOMEXCEPTION_SYNTAX_ERR = 12;
  NS_IDOMDOMEXCEPTION_INVALID_MODIFICATION_ERR = 13;
  NS_IDOMDOMEXCEPTION_NAMESPACE_ERR = 14;
  NS_IDOMDOMEXCEPTION_INVALID_ACCESS_ERR = 15;

  NS_IDOMDOMIMPLEMENTATION_IID: TGUID = '{a6cf9074-15b3-11d2-932e-00805f8add32}';

  NS_IDOMELEMENT_IID: TGUID = '{a6cf9078-15b3-11d2-932e-00805f8add32}';

  NS_IDOMENTITY_IID: TGUID = '{a6cf9079-15b3-11d2-932e-00805f8add32}';

  NS_IDOMENTITYREFERENCE_IID: TGUID = '{a6cf907a-15b3-11d2-932e-00805f8add32}';

  NS_IDOMEVENTGROUP_IID: TGUID = '{33347bee-6620-4841-8152-36091ae80c7e}';

  NS_IDOMEVENTLISTENER_IID: TGUID = '{df31c120-ded6-11d1-bd85-00805f8ae3f4}';

  NS_IDOMEVENTTARGET_IID: TGUID = '{1c773b30-d1cf-11d2-bd95-00805f8ae3f4}';

  NS_IDOMHTMLELEMENT_IID: TGUID = '{a6cf9085-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLANCHORELEMENT_IID: TGUID = '{a6cf90aa-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLAPPLETELEMENT_IID: TGUID = '{a6cf90ae-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLAREAELEMENT_IID: TGUID = '{a6cf90b0-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLBASEELEMENT_IID: TGUID = '{a6cf908b-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLBASEFONTELEMENT_IID: TGUID = '{a6cf90a6-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLBODYELEMENT_IID: TGUID = '{a6cf908e-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLBRELEMENT_IID: TGUID = '{a6cf90a5-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLBUTTONELEMENT_IID: TGUID = '{a6cf9095-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLCOLLECTION_IID: TGUID = '{a6cf9083-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLDIRECTORYELEMENT_IID: TGUID = '{a6cf909c-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLDIVELEMENT_IID: TGUID = '{a6cf90a0-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLDLISTELEMENT_IID: TGUID = '{a6cf909b-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLDOCUMENT_IID: TGUID = '{a6cf9084-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLEMBEDELEMENT_IID: TGUID = '{123f90ab-15b3-11d2-456e-00805f8add32}';

  NS_IDOMHTMLFIELDSETELEMENT_IID: TGUID = '{a6cf9097-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLFONTELEMENT_IID: TGUID = '{a6cf90a7-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLFORMELEMENT_IID: TGUID = '{a6cf908f-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLFRAMEELEMENT_IID: TGUID = '{a6cf90b9-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLFRAMESETELEMENT_IID: TGUID = '{a6cf90b8-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLHEADELEMENT_IID: TGUID = '{a6cf9087-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLHEADINGELEMENT_IID: TGUID = '{a6cf90a2-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLHRELEMENT_IID: TGUID = '{a6cf90a8-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLHTMLELEMENT_IID: TGUID = '{a6cf9086-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLIFRAMEELEMENT_IID: TGUID = '{a6cf90ba-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLIMAGEELEMENT_IID: TGUID = '{a6cf90ab-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLINPUTELEMENT_IID: TGUID = '{a6cf9093-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLISINDEXELEMENT_IID: TGUID = '{a6cf908c-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLLABELELEMENT_IID: TGUID = '{a6cf9096-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLLEGENDELEMENT_IID: TGUID = '{a6cf9098-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLLIELEMENT_IID: TGUID = '{a6cf909e-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLLINKELEMENT_IID: TGUID = '{a6cf9088-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLMAPELEMENT_IID: TGUID = '{a6cf90af-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLMENUELEMENT_IID: TGUID = '{a6cf909d-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLMETAELEMENT_IID: TGUID = '{a6cf908a-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLMODELEMENT_IID: TGUID = '{a6cf90a9-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLOBJECTELEMENT_IID: TGUID = '{a6cf90ac-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLOLISTELEMENT_IID: TGUID = '{a6cf909a-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLOPTGROUPELEMENT_IID: TGUID = '{a6cf9091-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLOPTIONELEMENT_IID: TGUID = '{a6cf9092-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLOPTIONSCOLLECTION_IID: TGUID = '{bce0213c-f70f-488f-b93f-688acca55d63}';

  NS_IDOMHTMLPARAGRAPHELEMENT_IID: TGUID = '{a6cf90a1-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLPARAMELEMENT_IID: TGUID = '{a6cf90ad-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLPREELEMENT_IID: TGUID = '{a6cf90a4-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLQUOTEELEMENT_IID: TGUID = '{a6cf90a3-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLSCRIPTELEMENT_IID: TGUID = '{a6cf90b1-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLSELECTELEMENT_IID: TGUID = '{a6cf9090-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLSTYLEELEMENT_IID: TGUID = '{a6cf908d-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLTABLECAPTIONELEMENT_IID: TGUID = '{a6cf90b3-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLTABLECELLELEMENT_IID: TGUID = '{a6cf90b7-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLTABLECOLELEMENT_IID: TGUID = '{a6cf90b4-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLTABLEELEMENT_IID: TGUID = '{a6cf90b2-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLTABLEROWELEMENT_IID: TGUID = '{a6cf90b6-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLTABLESECTIONELEMENT_IID: TGUID = '{a6cf90b5-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLTEXTAREAELEMENT_IID: TGUID = '{a6cf9094-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLTITLEELEMENT_IID: TGUID = '{a6cf9089-15b3-11d2-932e-00805f8add32}';

  NS_IDOMHTMLULISTELEMENT_IID: TGUID = '{a6cf9099-15b3-11d2-932e-00805f8add32}';

  NS_IDOMMEDIALIST_IID: TGUID = '{9b0c2ed7-111c-4824-adf9-ef0da6dad371}';

  NS_IDOMUIEVENT_IID: TGUID = '{a6cf90c3-15b3-11d2-932e-00805f8add32}';

  NS_IDOMMOUSEEVENT_IID: TGUID = '{ff751edc-8b02-aae7-0010-8301838a3123}';

  NS_IDOMNAMEDNODEMAP_IID: TGUID = '{a6cf907b-15b3-11d2-932e-00805f8add32}';

  NS_IDOMNODELIST_IID: TGUID = '{a6cf907d-15b3-11d2-932e-00805f8add32}';

  NS_IDOMNOTATION_IID: TGUID = '{a6cf907e-15b3-11d2-932e-00805f8add32}';

  NS_IDOMPROCESSINGINSTRUCTION_IID: TGUID = '{a6cf907f-15b3-11d2-932e-00805f8add32}';

  NS_IDOMRANGE_IID: TGUID = '{a6cf90ce-15b3-11d2-932e-00805f8add32}';
  NS_IDOMRANGE_START_TO_START = 0;
  NS_IDOMRANGE_START_TO_END = 1;
  NS_IDOMRANGE_END_TO_END = 2;
  NS_IDOMRANGE_END_TO_START = 3;

  NS_IDOMSTYLESHEETLIST_IID: TGUID = '{a6cf9081-15b3-11d2-932e-00805f8add32}';

  NS_IDOMWINDOW_IID: TGUID = '{a6cf906b-15b3-11d2-932e-00805f8add32}';

  NS_IDOMWINDOW2_IID: TGUID = '{65455132-b96a-40ec-adea-52fa22b1028c}';

  NS_IDOMWINDOWCOLLECTION_IID: TGUID = '{a6cf906f-15b3-11d2-932e-00805f8add32}';

  NS_IEMBEDDINGSITEWINDOW_IID: TGUID = '{3e5432cd-9568-4bd1-8cbe-d50aba110743}';
  NS_IEMBEDDINGSITEWINDOW_DIM_FLAGS_POSITION = 1;
  NS_IEMBEDDINGSITEWINDOW_DIM_FLAGS_SIZE_INNER = 2;
  NS_IEMBEDDINGSITEWINDOW_DIM_FLAGS_SIZE_OUTER = 4;

  NS_IFACTORY_IID: TGUID = '{00000001-0000-0000-c000-000000000046}';

  NS_IURI_IID: TGUID = '{07a22cc0-0ce5-11d3-9331-00104ba0fd40}';

  NS_IURL_IID: TGUID = '{d6116970-8034-11d3-9399-00104ba0fd40}';

  NS_IFILEURL_IID: TGUID = '{d26b2e2e-1dd1-11b2-88f3-8545a7ba7949}';

  NS_IGLOBALHISTORY_IID: TGUID = '{9491c383-e3c4-11d2-bdbe-0050040a9b44}';

  NS_IHISTORYENTRY_IID: TGUID = '{a41661d4-1417-11d5-9882-00c04fa02f40}';

  NS_IHTTPCHANNEL_IID: TGUID = '{9277fe09-f0cc-4cd9-bbce-581dd94b0260}';

  NS_IHTTPHEADERVISITOR_IID: TGUID = '{0cf40717-d7c1-4a94-8c1e-d6c9734101bb}';

  NS_IINPUTSTREAM_IID: TGUID = '{fa9c7f6c-61b3-11d4-9877-00c04fa0cf4a}';

  NS_IINTERFACEREQUESTOR_IID: TGUID = '{033a1470-8b2a-11d3-af88-00a024ffc08c}';

  NS_IIOSERVICE_IID: TGUID = '{bddeda3f-9020-4d12-8c70-984ee9f7935e}';

  NS_ILOADGROUP_IID: TGUID = '{3de0a31c-feaf-400f-9f1e-4ef71f8b20cc}';

  NS_ILOCALFILE_IID: TGUID = '{aa610f20-a889-11d3-8c81-000064657374}';

  NS_IMEMORY_IID: TGUID = '{59e7e77a-38e4-11d4-8cf5-0060b0fc14a3}';

  NS_IMODULE_IID: TGUID = '{7392d032-5371-11d3-994e-00805fd26fee}';

  NS_IOBSERVER_IID: TGUID = '{db242e01-e4d9-11d2-9dde-000064657374}';

  NS_IOBSERVERSERVICE_IID: TGUID = '{d07f5192-e3d1-11d2-8acd-00105a1b8860}';

  NS_IOUTPUTSTREAM_IID: TGUID = '{0d0acd2a-61b4-11d4-9877-00c04fa0cf4a}';

  NS_IPASSWORD_IID: TGUID = '{cf39c2b0-1e4b-11d5-a549-0010a401eb10}';

  NS_IPREFBRANCH_IID: TGUID = '{56c35506-f14b-11d3-99d3-ddbfac2ccf65}';
  NS_IPREFBRANCH_PREF_INVALID = 0;
  NS_IPREFBRANCH_PREF_STRING = 32;
  NS_IPREFBRANCH_PREF_INT = 64;
  NS_IPREFBRANCH_PREF_BOOL = 128;

  NS_IPREFLOCALIZEDSTRING_IID: TGUID = '{ae419e24-1dd1-11b2-b39a-d3e5e7073802}';

  NS_IPREFSERVICE_IID: TGUID = '{decb9cc7-c08f-4ea5-be91-a8fc637ce2d2}';

  NS_IPRINTSETTINGS_IID: TGUID = '{83427530-f790-11d4-a869-00105a183419}';
  NS_IPRINTSETTINGS_kInitSaveOddEvenPages = 1;
  NS_IPRINTSETTINGS_kInitSaveHeaderLeft = 2;
  NS_IPRINTSETTINGS_kInitSaveHeaderCenter = 4;
  NS_IPRINTSETTINGS_kInitSaveHeaderRight = 8;
  NS_IPRINTSETTINGS_kInitSaveFooterLeft = 16;
  NS_IPRINTSETTINGS_kInitSaveFooterCenter = 32;
  NS_IPRINTSETTINGS_kInitSaveFooterRight = 64;
  NS_IPRINTSETTINGS_kInitSaveBGColors = 128;
  NS_IPRINTSETTINGS_kInitSaveBGImages = 256;
  NS_IPRINTSETTINGS_kInitSavePaperSize = 512;
  NS_IPRINTSETTINGS_kInitSavePaperName = 1024;
  NS_IPRINTSETTINGS_kInitSavePaperSizeUnit = 2048;
  NS_IPRINTSETTINGS_kInitSavePaperSizeType = 4096;
  NS_IPRINTSETTINGS_kInitSavePaperData = 8192;
  NS_IPRINTSETTINGS_kInitSavePaperWidth = 16384;
  NS_IPRINTSETTINGS_kInitSavePaperHeight = 32768;
  NS_IPRINTSETTINGS_kInitSaveReversed = 65536;
  NS_IPRINTSETTINGS_kInitSaveInColor = 131072;
  NS_IPRINTSETTINGS_kInitSaveOrientation = 262144;
  NS_IPRINTSETTINGS_kInitSavePrintCommand = 524288;
  NS_IPRINTSETTINGS_kInitSavePrinterName = 1048576;
  NS_IPRINTSETTINGS_kInitSavePrintToFile = 2097152;
  NS_IPRINTSETTINGS_kInitSaveToFileName = 4194304;
  NS_IPRINTSETTINGS_kInitSavePageDelay = 8388608;
  NS_IPRINTSETTINGS_kInitSaveMargins = 16777216;
  NS_IPRINTSETTINGS_kInitSaveNativeData = 33554432;
  NS_IPRINTSETTINGS_kInitSavePlexName = 67108864;
  NS_IPRINTSETTINGS_kInitSaveShrinkToFit = 134217728;
  NS_IPRINTSETTINGS_kInitSaveScaling = 268435456;
  NS_IPRINTSETTINGS_kInitSaveAll = 4294967295;
  NS_IPRINTSETTINGS_kPrintOddPages = 1;
  NS_IPRINTSETTINGS_kPrintEvenPages = 2;
  NS_IPRINTSETTINGS_kEnableSelectionRB = 4;
  NS_IPRINTSETTINGS_kRangeAllPages = 0;
  NS_IPRINTSETTINGS_kRangeSpecifiedPageRange = 1;
  NS_IPRINTSETTINGS_kRangeSelection = 2;
  NS_IPRINTSETTINGS_kRangeFocusFrame = 3;
  NS_IPRINTSETTINGS_kJustLeft = 0;
  NS_IPRINTSETTINGS_kJustCenter = 1;
  NS_IPRINTSETTINGS_kJustRight = 2;
  NS_IPRINTSETTINGS_kUseInternalDefault = 0;
  NS_IPRINTSETTINGS_kUseSettingWhenPossible = 1;
  NS_IPRINTSETTINGS_kPaperSizeNativeData = 0;
  NS_IPRINTSETTINGS_kPaperSizeDefined = 1;
  NS_IPRINTSETTINGS_kPaperSizeInches = 0;
  NS_IPRINTSETTINGS_kPaperSizeMillimeters = 1;
  NS_IPRINTSETTINGS_kPortraitOrientation = 0;
  NS_IPRINTSETTINGS_kLandscapeOrientation = 1;
  NS_IPRINTSETTINGS_kNoFrames = 0;
  NS_IPRINTSETTINGS_kFramesAsIs = 1;
  NS_IPRINTSETTINGS_kSelectedFrame = 2;
  NS_IPRINTSETTINGS_kEachFrameSep = 3;
  NS_IPRINTSETTINGS_kFrameEnableNone = 0;
  NS_IPRINTSETTINGS_kFrameEnableAll = 1;
  NS_IPRINTSETTINGS_kFrameEnableAsIsAndEach = 2;

  NS_IPROFILE_IID: TGUID = '{02b0625a-e7f3-11d2-9f5a-006008a6efe9}';
  NS_IPROFILE_SHUTDOWN_PERSIST = 1;
  NS_IPROFILE_SHUTDOWN_CLEANSE = 2;

  NS_IPROFILECHANGESTATUS_IID: TGUID = '{2f977d43-5485-11d4-87e2-0010a4e75ef2}';

  NS_IPROMPT_IID: TGUID = '{a63f70c0-148b-11d3-9333-00104ba0fd40}';
  NS_IPROMPT_BUTTON_POS_0 = 1;
  NS_IPROMPT_BUTTON_POS_1 = 256;
  NS_IPROMPT_BUTTON_POS_2 = 65536;
  NS_IPROMPT_BUTTON_TITLE_OK = 1;
  NS_IPROMPT_BUTTON_TITLE_CANCEL = 2;
  NS_IPROMPT_BUTTON_TITLE_YES = 3;
  NS_IPROMPT_BUTTON_TITLE_NO = 4;
  NS_IPROMPT_BUTTON_TITLE_SAVE = 5;
  NS_IPROMPT_BUTTON_TITLE_DONT_SAVE = 6;
  NS_IPROMPT_BUTTON_TITLE_REVERT = 7;
  NS_IPROMPT_BUTTON_TITLE_IS_STRING = 127;
  NS_IPROMPT_BUTTON_POS_0_DEFAULT = 0;
  NS_IPROMPT_BUTTON_POS_1_DEFAULT = 16777216;
  NS_IPROMPT_BUTTON_POS_2_DEFAULT = 33554432;
  NS_IPROMPT_BUTTON_DELAY_ENABLE = 67108864;
  NS_IPROMPT_STD_OK_CANCEL_BUTTONS = 513;

  NS_IPROPERTIES_IID: TGUID = '{78650582-4e93-4b60-8e85-26ebd3eb14ca}';

  NS_IPROTOCOLHANDLER_IID: TGUID = '{15fd6940-8ea7-11d3-93ad-00104ba0fd40}';
  NS_IPROTOCOLHANDLER_URI_STD = 0;
  NS_IPROTOCOLHANDLER_URI_NORELATIVE = 1;
  NS_IPROTOCOLHANDLER_URI_NOAUTH = 2;
  NS_IPROTOCOLHANDLER_ALLOWS_PROXY = 4;
  NS_IPROTOCOLHANDLER_ALLOWS_PROXY_HTTP = 8;

  NS_IREQUESTOBSERVER_IID: TGUID = '{fd91e2e0-1481-11d3-9333-00104ba0fd40}';

  NS_ISCRIPTABLEINPUTSTREAM_IID: TGUID = '{a2a32f90-9b90-11d3-a189-0050041caf44}';

  NS_ISELECTION_IID: TGUID = '{b2c7ed59-8634-4352-9e37-5484c8b6e4e1}';

  NS_ISERVICEMANAGER_IID: TGUID = '{8bb35ed9-e332-462d-9155-4a002ab5c958}';

  NS_ISHISTORY_IID: TGUID = '{7294fe9b-14d8-11d5-9882-00c04fa02f40}';

  NS_ISHISTORYLISTENER_IID: TGUID = '{3b07f591-e8e1-11d4-9882-00c04fa02f40}';

  NS_ISTREAMLISTENER_IID: TGUID = '{1a637020-1482-11d3-9333-00104ba0fd40}';

  NS_ISUPPORTSPRIMITIVE_IID: TGUID = '{d0d4b136-1dd1-11b2-9371-f0727ef827c0}';
  NS_ISUPPORTSPRIMITIVE_TYPE_ID = 1;
  NS_ISUPPORTSPRIMITIVE_TYPE_CSTRING = 2;
  NS_ISUPPORTSPRIMITIVE_TYPE_STRING = 3;
  NS_ISUPPORTSPRIMITIVE_TYPE_PRBOOL = 4;
  NS_ISUPPORTSPRIMITIVE_TYPE_PRUINT8 = 5;
  NS_ISUPPORTSPRIMITIVE_TYPE_PRUINT16 = 6;
  NS_ISUPPORTSPRIMITIVE_TYPE_PRUINT32 = 7;
  NS_ISUPPORTSPRIMITIVE_TYPE_PRUINT64 = 8;
  NS_ISUPPORTSPRIMITIVE_TYPE_PRTIME = 9;
  NS_ISUPPORTSPRIMITIVE_TYPE_CHAR = 10;
  NS_ISUPPORTSPRIMITIVE_TYPE_PRINT16 = 11;
  NS_ISUPPORTSPRIMITIVE_TYPE_PRINT32 = 12;
  NS_ISUPPORTSPRIMITIVE_TYPE_PRINT64 = 13;
  NS_ISUPPORTSPRIMITIVE_TYPE_FLOAT = 14;
  NS_ISUPPORTSPRIMITIVE_TYPE_DOUBLE = 15;
  NS_ISUPPORTSPRIMITIVE_TYPE_VOID = 16;
  NS_ISUPPORTSPRIMITIVE_TYPE_INTERFACE_POINTER = 17;

  NS_ISUPPORTSID_IID: TGUID = '{d18290a0-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSCSTRING_IID: TGUID = '{d65ff270-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSSTRING_IID: TGUID = '{d79dc970-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSPRBOOL_IID: TGUID = '{ddc3b490-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSPRUINT8_IID: TGUID = '{dec2e4e0-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSPRUINT16_IID: TGUID = '{dfacb090-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSPRUINT32_IID: TGUID = '{e01dc470-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSPRUINT64_IID: TGUID = '{e13567c0-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSPRTIME_IID: TGUID = '{e2563630-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSCHAR_IID: TGUID = '{e2b05e40-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSPRINT16_IID: TGUID = '{e30d94b0-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSPRINT32_IID: TGUID = '{e36c5250-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSPRINT64_IID: TGUID = '{e3cb0ff0-4a1c-11d3-9890-006008962422}';

  NS_ISUPPORTSFLOAT_IID: TGUID = '{abeaa390-4ac0-11d3-baea-00805f8a5dd7}';

  NS_ISUPPORTSDOUBLE_IID: TGUID = '{b32523a0-4ac0-11d3-baea-00805f8a5dd7}';

  NS_ISUPPORTSVOID_IID: TGUID = '{464484f0-568d-11d3-baf8-00805f8a5dd7}';

  NS_ISUPPORTSINTERFACEPOINTER_IID: TGUID = '{995ea724-1dd1-11b2-9211-c21bdd3e7ed0}';

  NS_ITOOLTIPLISTENER_IID: TGUID = '{44b78386-1dd2-11b2-9ad2-e4eee2ca1916}';

  NS_ITOOLTIPTEXTPROVIDER_IID: TGUID = '{b128a1e6-44f3-4331-8fbe-5af360ff21ee}';

  NS_ITRACEREFCNT_IID: TGUID = '{273dc92f-0fe6-4545-96a9-21be77828039}';

  NS_IUPLOADCHANNEL_IID: TGUID = '{ddf633d8-e9a4-439d-ad88-de636fd9bb75}';

  NS_IURICONTENTLISTENER_IID: TGUID = '{94928ab3-8b63-11d3-989d-001083010e9b}';

  NS_IWEAKREFERENCE_IID: TGUID = '{9188bc85-f92e-11d2-81ef-0060083a0bcf}';

  NS_ISUPPORTSWEAKREFERENCE_IID: TGUID = '{9188bc86-f92e-11d2-81ef-0060083a0bcf}';

  NS_IWEBBROWSER_IID: TGUID = '{69e5df00-7b8b-11d3-af61-00a024ffc08c}';

  NS_IWEBBROWSERCHROME_IID: TGUID = '{ba434c60-9d52-11d3-afb0-00a024ffc08c}';
  NS_IWEBBROWSERCHROME_STATUS_SCRIPT = 1;
  NS_IWEBBROWSERCHROME_STATUS_SCRIPT_DEFAULT = 2;
  NS_IWEBBROWSERCHROME_STATUS_LINK = 3;
  NS_IWEBBROWSERCHROME_CHROME_DEFAULT = 1;
  NS_IWEBBROWSERCHROME_CHROME_WINDOW_BORDERS = 2;
  NS_IWEBBROWSERCHROME_CHROME_WINDOW_CLOSE = 4;
  NS_IWEBBROWSERCHROME_CHROME_WINDOW_RESIZE = 8;
  NS_IWEBBROWSERCHROME_CHROME_MENUBAR = 16;
  NS_IWEBBROWSERCHROME_CHROME_TOOLBAR = 32;
  NS_IWEBBROWSERCHROME_CHROME_LOCATIONBAR = 64;
  NS_IWEBBROWSERCHROME_CHROME_STATUSBAR = 128;
  NS_IWEBBROWSERCHROME_CHROME_PERSONAL_TOOLBAR = 256;
  NS_IWEBBROWSERCHROME_CHROME_SCROLLBARS = 512;
  NS_IWEBBROWSERCHROME_CHROME_TITLEBAR = 1024;
  NS_IWEBBROWSERCHROME_CHROME_EXTRA = 2048;
  NS_IWEBBROWSERCHROME_CHROME_WITH_SIZE = 4096;
  NS_IWEBBROWSERCHROME_CHROME_WITH_POSITION = 8192;
  NS_IWEBBROWSERCHROME_CHROME_WINDOW_MIN = 16384;
  NS_IWEBBROWSERCHROME_CHROME_WINDOW_POPUP = 32768;
  NS_IWEBBROWSERCHROME_CHROME_WINDOW_RAISED = 33554432;
  NS_IWEBBROWSERCHROME_CHROME_WINDOW_LOWERED = 67108864;
  NS_IWEBBROWSERCHROME_CHROME_CENTER_SCREEN = 134217728;
  NS_IWEBBROWSERCHROME_CHROME_DEPENDENT = 268435456;
  NS_IWEBBROWSERCHROME_CHROME_MODAL = 536870912;
  NS_IWEBBROWSERCHROME_CHROME_OPENAS_DIALOG = 1073741824;
  NS_IWEBBROWSERCHROME_CHROME_OPENAS_CHROME = 2147483648;
  NS_IWEBBROWSERCHROME_CHROME_ALL = 4094;

  NS_IWEBBROWSERCHROMEFOCUS_IID: TGUID = '{d2206418-1dd1-11b2-8e55-acddcd2bcfb8}';

  NS_IWEBBROWSERFIND_IID: TGUID = '{2f977d44-5485-11d4-87e2-0010a4e75ef2}';

  NS_IWEBBROWSERFINDINFRAMES_IID: TGUID = '{e0f5d182-34bc-11d5-be5b-b760676c6ebc}';

  NS_IWEBBROWSERFOCUS_IID: TGUID = '{9c5d3c58-1dd1-11b2-a1c9-f3699284657a}';

  NS_IWEBBROWSERPRINT_IID: TGUID = '{9a7ca4b0-fbba-11d4-a869-00105a183419}';
  NS_IWEBBROWSERPRINT_PRINTPREVIEW_GOTO_PAGENUM = 0;
  NS_IWEBBROWSERPRINT_PRINTPREVIEW_PREV_PAGE = 1;
  NS_IWEBBROWSERPRINT_PRINTPREVIEW_NEXT_PAGE = 2;
  NS_IWEBBROWSERPRINT_PRINTPREVIEW_HOME = 3;
  NS_IWEBBROWSERPRINT_PRINTPREVIEW_END = 4;

  NS_IWEBBROWSERSETUP_IID: TGUID = '{f15398a0-8018-11d3-af70-00a024ffc08c}';
  NS_IWEBBROWSERSETUP_SETUP_ALLOW_PLUGINS = 1;
  NS_IWEBBROWSERSETUP_SETUP_ALLOW_JAVASCRIPT = 2;
  NS_IWEBBROWSERSETUP_SETUP_ALLOW_META_REDIRECTS = 3;
  NS_IWEBBROWSERSETUP_SETUP_ALLOW_SUBFRAMES = 4;
  NS_IWEBBROWSERSETUP_SETUP_ALLOW_IMAGES = 5;
  NS_IWEBBROWSERSETUP_SETUP_FOCUS_DOC_BEFORE_CONTENT = 6;
  NS_IWEBBROWSERSETUP_SETUP_USE_GLOBAL_HISTORY = 256;
  NS_IWEBBROWSERSETUP_SETUP_IS_CHROME_WRAPPER = 7;

  NS_IWEBPROGRESS_IID: TGUID = '{570f39d0-efd0-11d3-b093-00a024ffc08c}';
  NS_IWEBPROGRESS_NOTIFY_STATE_REQUEST = 1;
  NS_IWEBPROGRESS_NOTIFY_STATE_DOCUMENT = 2;
  NS_IWEBPROGRESS_NOTIFY_STATE_NETWORK = 4;
  NS_IWEBPROGRESS_NOTIFY_STATE_WINDOW = 8;
  NS_IWEBPROGRESS_NOTIFY_STATE_ALL = 15;
  NS_IWEBPROGRESS_NOTIFY_PROGRESS = 16;
  NS_IWEBPROGRESS_NOTIFY_STATUS = 32;
  NS_IWEBPROGRESS_NOTIFY_SECURITY = 64;
  NS_IWEBPROGRESS_NOTIFY_LOCATION = 128;
  NS_IWEBPROGRESS_NOTIFY_ALL = 255;

  NS_IWEBPROGRESSLISTENER_IID: TGUID = '{570f39d1-efd0-11d3-b093-00a024ffc08c}';
  NS_IWEBPROGRESSLISTENER_STATE_START = 1;
  NS_IWEBPROGRESSLISTENER_STATE_REDIRECTING = 2;
  NS_IWEBPROGRESSLISTENER_STATE_TRANSFERRING = 4;
  NS_IWEBPROGRESSLISTENER_STATE_NEGOTIATING = 8;
  NS_IWEBPROGRESSLISTENER_STATE_STOP = 16;
  NS_IWEBPROGRESSLISTENER_STATE_IS_REQUEST = 65536;
  NS_IWEBPROGRESSLISTENER_STATE_IS_DOCUMENT = 131072;
  NS_IWEBPROGRESSLISTENER_STATE_IS_NETWORK = 262144;
  NS_IWEBPROGRESSLISTENER_STATE_IS_WINDOW = 524288;
  NS_IWEBPROGRESSLISTENER_STATE_IS_INSECURE = 4;
  NS_IWEBPROGRESSLISTENER_STATE_IS_BROKEN = 1;
  NS_IWEBPROGRESSLISTENER_STATE_IS_SECURE = 2;
  NS_IWEBPROGRESSLISTENER_STATE_SECURE_HIGH = 262144;
  NS_IWEBPROGRESSLISTENER_STATE_SECURE_MED = 65536;
  NS_IWEBPROGRESSLISTENER_STATE_SECURE_LOW = 131072;

  NS_IWINDOWCREATOR_IID: TGUID = '{30465632-a777-44cc-90f9-8145475ef999}';

  NS_IWINDOWWATCHER_IID: TGUID = '{002286a8-494b-43b3-8ddd-49e3fc50622b}';

type
  nsISupports = interface;
  mozIJSSubScriptLoader = interface;
  nsISimpleEnumerator = interface;
  nsICategoryManager = interface;
  nsIRequest = interface;
  nsIChannel = interface;
  nsIProgrammingLanguage = interface;
  nsIClassInfo = interface;
  nsIClipboardCommands = interface;
  nsIComponentManager = interface;
  nsIComponentRegistrar = interface;
  nsIContextMenuListener = interface;
  nsICookie = interface;
  nsICookieManager = interface;
  nsIDebug = interface;
  nsIFile = interface;
  nsIDirectoryServiceProvider = interface;
  nsIDirectoryServiceProvider2 = interface;
  nsIDirectoryService = interface;
  nsIDOM3DocumentEvent = interface;
  nsIDOM3EventTarget = interface;
  nsIDOMAbstractView = interface;
  nsIDOMNode = interface;
  nsIDOMAttr = interface;
  nsIDOMBarProp = interface;
  nsIDOMCharacterData = interface;
  nsIDOMText = interface;
  nsIDOMCDATASection = interface;
  nsIDOMComment = interface;
  nsIDOMCSSValue = interface;
  nsIDOMCSSPrimitiveValue = interface;
  nsIDOMCSSRule = interface;
  nsIDOMCSSRuleList = interface;
  nsIDOMCSSStyleDeclaration = interface;
  nsIDOMStyleSheet = interface;
  nsIDOMCSSStyleSheet = interface;
  nsIDOMCSSValueList = interface;
  nsIDOMEvent = interface;
  nsIDOMCustomEvent = interface;
  nsIDOMDocument = interface;
  nsIDOMDocumentEvent = interface;
  nsIDOMDocumentFragment = interface;
  nsIDOMDocumentRange = interface;
  nsIDOMDocumentStyle = interface;
  nsIDOMDocumentType = interface;
  nsIDOMDocumentView = interface;
  nsIDOMDOMException = interface;
  nsIDOMDOMImplementation = interface;
  nsIDOMElement = interface;
  nsIDOMEntity = interface;
  nsIDOMEntityReference = interface;
  nsIDOMEventGroup = interface;
  nsIDOMEventListener = interface;
  nsIDOMEventTarget = interface;
  nsIDOMHTMLElement = interface;
  nsIDOMHTMLAnchorElement = interface;
  nsIDOMHTMLAppletElement = interface;
  nsIDOMHTMLAreaElement = interface;
  nsIDOMHTMLBaseElement = interface;
  nsIDOMHTMLBaseFontElement = interface;
  nsIDOMHTMLBodyElement = interface;
  nsIDOMHTMLBRElement = interface;
  nsIDOMHTMLButtonElement = interface;
  nsIDOMHTMLCollection = interface;
  nsIDOMHTMLDirectoryElement = interface;
  nsIDOMHTMLDivElement = interface;
  nsIDOMHTMLDListElement = interface;
  nsIDOMHTMLDocument = interface;
  nsIDOMHTMLEmbedElement = interface;
  nsIDOMHTMLFieldSetElement = interface;
  nsIDOMHTMLFontElement = interface;
  nsIDOMHTMLFormElement = interface;
  nsIDOMHTMLFrameElement = interface;
  nsIDOMHTMLFrameSetElement = interface;
  nsIDOMHTMLHeadElement = interface;
  nsIDOMHTMLHeadingElement = interface;
  nsIDOMHTMLHRElement = interface;
  nsIDOMHTMLHtmlElement = interface;
  nsIDOMHTMLIFrameElement = interface;
  nsIDOMHTMLImageElement = interface;
  nsIDOMHTMLInputElement = interface;
  nsIDOMHTMLIsIndexElement = interface;
  nsIDOMHTMLLabelElement = interface;
  nsIDOMHTMLLegendElement = interface;
  nsIDOMHTMLLIElement = interface;
  nsIDOMHTMLLinkElement = interface;
  nsIDOMHTMLMapElement = interface;
  nsIDOMHTMLMenuElement = interface;
  nsIDOMHTMLMetaElement = interface;
  nsIDOMHTMLModElement = interface;
  nsIDOMHTMLObjectElement = interface;
  nsIDOMHTMLOListElement = interface;
  nsIDOMHTMLOptGroupElement = interface;
  nsIDOMHTMLOptionElement = interface;
  nsIDOMHTMLOptionsCollection = interface;
  nsIDOMHTMLParagraphElement = interface;
  nsIDOMHTMLParamElement = interface;
  nsIDOMHTMLPreElement = interface;
  nsIDOMHTMLQuoteElement = interface;
  nsIDOMHTMLScriptElement = interface;
  nsIDOMHTMLSelectElement = interface;
  nsIDOMHTMLStyleElement = interface;
  nsIDOMHTMLTableCaptionElement = interface;
  nsIDOMHTMLTableCellElement = interface;
  nsIDOMHTMLTableColElement = interface;
  nsIDOMHTMLTableElement = interface;
  nsIDOMHTMLTableRowElement = interface;
  nsIDOMHTMLTableSectionElement = interface;
  nsIDOMHTMLTextAreaElement = interface;
  nsIDOMHTMLTitleElement = interface;
  nsIDOMHTMLUListElement = interface;
  nsIDOMMediaList = interface;
  nsIDOMUIEvent = interface;
  nsIDOMMouseEvent = interface;
  nsIDOMNamedNodeMap = interface;
  nsIDOMNodeList = interface;
  nsIDOMNotation = interface;
  nsIDOMProcessingInstruction = interface;
  nsIDOMRange = interface;
  nsIDOMStyleSheetList = interface;
  nsIDOMWindow = interface;
  nsIDOMWindow2 = interface;
  nsIDOMWindowCollection = interface;
  nsIEmbeddingSiteWindow = interface;
  nsIFactory = interface;
  nsIURI = interface;
  nsIURL = interface;
  nsIFileURL = interface;
  nsIGlobalHistory = interface;
  nsIHistoryEntry = interface;
  nsIHttpChannel = interface;
  nsIHttpHeaderVisitor = interface;
  nsIInputStream = interface;
  nsIInterfaceRequestor = interface;
  nsIIOService = interface;
  nsILoadGroup = interface;
  nsILocalFile = interface;
  nsIMemory = interface;
  nsIModule = interface;
  nsIObserver = interface;
  nsIObserverService = interface;
  nsIOutputStream = interface;
  nsIPassword = interface;
  nsIPrefBranch = interface;
  nsIPrefLocalizedString = interface;
  nsIPrefService = interface;
  nsIPrintSettings = interface;
  nsIProfile = interface;
  nsIProfileChangeStatus = interface;
  nsIPrompt = interface;
  nsIProperties = interface;
  nsIProtocolHandler = interface;
  nsIRequestObserver = interface;
  nsIScriptableInputStream = interface;
  nsISelection = interface;
  nsIServiceManager = interface;
  nsISHistory = interface;
  nsISHistoryListener = interface;
  nsIStreamListener = interface;
  nsISupportsPrimitive = interface;
  nsISupportsID = interface;
  nsISupportsCString = interface;
  nsISupportsString = interface;
  nsISupportsPRBool = interface;
  nsISupportsPRUint8 = interface;
  nsISupportsPRUint16 = interface;
  nsISupportsPRUint32 = interface;
  nsISupportsPRUint64 = interface;
  nsISupportsPRTime = interface;
  nsISupportsChar = interface;
  nsISupportsPRInt16 = interface;
  nsISupportsPRInt32 = interface;
  nsISupportsPRInt64 = interface;
  nsISupportsFloat = interface;
  nsISupportsDouble = interface;
  nsISupportsVoid = interface;
  nsISupportsInterfacePointer = interface;
  nsITooltipListener = interface;
  nsITooltipTextProvider = interface;
  nsITraceRefcnt = interface;
  nsIUploadChannel = interface;
  nsIURIContentListener = interface;
  nsIWeakReference = interface;
  nsISupportsWeakReference = interface;
  nsIWebBrowser = interface;
  nsIWebBrowserChrome = interface;
  nsIWebBrowserChromeFocus = interface;
  nsIWebBrowserFind = interface;
  nsIWebBrowserFindInFrames = interface;
  nsIWebBrowserFocus = interface;
  nsIWebBrowserPrint = interface;
  nsIWebBrowserSetup = interface;
  nsIWebProgress = interface;
  nsIWebProgressListener = interface;
  nsIWindowCreator = interface;
  nsIWindowWatcher = interface;
{$IF False}
(***
 * Root idl declarations to be used by all.
 * @status FROZEN
 *)
  PRBool = PRBool;
  PRUint8 = PRUint8;
  PRUint16 = PRUint16;
  PRUnichar = PRUint16;
  PRUint32 = PRUint32;
  PRUint64 = PRUint64;
  PRTime = PRUint64;
  PRInt16 = PRInt16;
  PRInt32 = PRInt32;
  PRInt64 = PRInt64;
  nsrefcnt = PRUint32;
  nsresult = PRUint32;
  size_t = PRUint32;
{$IFEND}
  DOMTimeStamp = PRUint64;
  nsLoadFlags = PRUint32;
(*** 
 * An optional interface for accessing the HTTP or
 * javascript cookie object
 * 
 * @status FROZEN
 *)
  nsCookieStatus = PRInt32;
  nsCookiePolicy = PRInt32;
  nsISupports = interface
  ['{00000000-0000-0000-c000-000000000046}']
  end;

  mozIJSSubScriptLoader = interface(nsISupports)
  ['{8792d77e-1dd2-11b2-ac7f-9bc9be4f2916}']
    function LoadSubScript(const url: PWideChar): nsresult; stdcall;
  end;

  nsISimpleEnumerator = interface(nsISupports)
  ['{d1899240-f9d2-11d2-bdd6-000064657374}']
    function HasMoreElements(out _retval: PRBool): nsresult; stdcall;
    function GetNext(out _retval: nsISupports): nsresult; stdcall;
  end;

  nsICategoryManager = interface(nsISupports)
  ['{3275b2cd-af6d-429a-80d7-f0c5120342ac}']
    function GetCategoryEntry(const aCategory: PAnsiChar; const aEntry: PAnsiChar; out _retval: PAnsiChar): nsresult; stdcall;
    function AddCategoryEntry(const aCategory: PAnsiChar; const aEntry: PAnsiChar; const aValue: PAnsiChar; aPersist: PRBool; aReplace: PRBool; out _retval: PAnsiChar): nsresult; stdcall;
    function DeleteCategoryEntry(const aCategory: PAnsiChar; const aEntry: PAnsiChar; aPersist: PRBool): nsresult; stdcall;
    function DeleteCategory(const aCategory: PAnsiChar): nsresult; stdcall;
    function EnumerateCategory(const aCategory: PAnsiChar; out _retval: nsISimpleEnumerator): nsresult; stdcall;
    function EnumerateCategories(out _retval: nsISimpleEnumerator): nsresult; stdcall;
  end;

  nsIRequest = interface(nsISupports)
  ['{ef6bfbd2-fd46-48d8-96b7-9f8f0fd387fe}']
    function GetName(aName: nsACString): Longword; stdcall;
    function IsPending(out _retval: PRBool): nsresult; stdcall;
    function GetStatus(out aStatus: nsresult): Longword; stdcall;
    function Cancel(aStatus: nsresult): nsresult; stdcall;
    function Suspend(): nsresult; stdcall;
    function Resume(): nsresult; stdcall;
    function GetLoadGroup(out aLoadGroup: nsILoadGroup): Longword; stdcall;
    function SetLoadGroup(aLoadGroup: nsILoadGroup): Longword; stdcall;
    function GetLoadFlags(out aLoadFlags: nsLoadFlags): Longword; stdcall;
    function SetLoadFlags(aLoadFlags: nsLoadFlags): Longword; stdcall;
  end;

  nsIChannel = interface(nsIRequest)
  ['{c63a055a-a676-4e71-bf3c-6cfa11082018}']
    function GetOriginalURI(out aOriginalURI: nsIURI): Longword; stdcall;
    function SetOriginalURI(aOriginalURI: nsIURI): Longword; stdcall;
    function GetURI(out aURI: nsIURI): Longword; stdcall;
    function GetOwner(out aOwner: nsISupports): Longword; stdcall;
    function SetOwner(aOwner: nsISupports): Longword; stdcall;
    function GetNotificationCallbacks(out aNotificationCallbacks: nsIInterfaceRequestor): Longword; stdcall;
    function SetNotificationCallbacks(aNotificationCallbacks: nsIInterfaceRequestor): Longword; stdcall;
    function GetSecurityInfo(out aSecurityInfo: nsISupports): Longword; stdcall;
    function GetContentType(aContentType: nsACString): Longword; stdcall;
    function SetContentType(const aContentType: nsACString): Longword; stdcall;
    function GetContentCharset(aContentCharset: nsACString): Longword; stdcall;
    function SetContentCharset(const aContentCharset: nsACString): Longword; stdcall;
    function GetContentLength(out aContentLength: PRInt32): Longword; stdcall;
    function SetContentLength(aContentLength: PRInt32): Longword; stdcall;
    function Open(out _retval: nsIInputStream): nsresult; stdcall;
    function AsyncOpen(aListener: nsIStreamListener; aContext: nsISupports): nsresult; stdcall;
  end;

  nsIProgrammingLanguage = interface(nsISupports)
  ['{ea604e90-40ba-11d5-90bb-0010a4e73d9a}']
  end;

  nsIClassInfo = interface(nsISupports)
  ['{986c11d0-f340-11d4-9075-0010a4e73d9a}']
    function GetInterfaces(out count: PRUint32; out _array: PGUIDArray): nsresult; stdcall;
    function GetHelperForLanguage(language: PRUint32; out _retval: nsISupports): nsresult; stdcall;
    function GetContractID(out aContractID: PAnsiChar): Longword; stdcall;
    function GetClassDescription(out aClassDescription: PAnsiChar): Longword; stdcall;
    function GetClassID(out aClassID: PGUID): Longword; stdcall;
    function GetImplementationLanguage(out aImplementationLanguage: PRUint32): Longword; stdcall;
    function GetFlags(out aFlags: PRUint32): Longword; stdcall;
    function GetClassIDNoAlloc(out aClassIDNoAlloc: TGUID): Longword; stdcall;
  end;

  nsIClipboardCommands = interface(nsISupports)
  ['{b8100c90-73be-11d2-92a5-00105a1b0d64}']
    function CanCutSelection(out _retval: PRBool): nsresult; stdcall;
    function CanCopySelection(out _retval: PRBool): nsresult; stdcall;
    function CanCopyLinkLocation(out _retval: PRBool): nsresult; stdcall;
    function CanCopyImageLocation(out _retval: PRBool): nsresult; stdcall;
    function CanCopyImageContents(out _retval: PRBool): nsresult; stdcall;
    function CanPaste(out _retval: PRBool): nsresult; stdcall;
    function CutSelection(): nsresult; stdcall;
    function CopySelection(): nsresult; stdcall;
    function CopyLinkLocation(): nsresult; stdcall;
    function CopyImageLocation(): nsresult; stdcall;
    function CopyImageContents(): nsresult; stdcall;
    function Paste(): nsresult; stdcall;
    function SelectAll(): nsresult; stdcall;
    function SelectNone(): nsresult; stdcall;
  end;

  nsIComponentManager = interface(nsISupports)
  ['{a88e5a60-205a-4bb1-94e1-2628daf51eae}']
    function GetClassObject(const aClass: TGUID; const aIID: TGUID; out _result): nsresult; stdcall;
    function GetClassObjectByContractID(const aContractID: PAnsiChar; const aIID: TGUID; out _result): nsresult; stdcall;
    function CreateInstance(const aClass: TGUID; aDelegate: nsISupports; const aIID: TGUID; out _result): nsresult; stdcall;
    function CreateInstanceByContractID(const aContractID: PAnsiChar; aDelegate: nsISupports; const aIID: TGUID; out _result): nsresult; stdcall;
  end;

  nsIComponentRegistrar = interface(nsISupports)
  ['{2417cbfe-65ad-48a6-b4b6-eb84db174392}']
    function AutoRegister(aSpec: nsIFile): nsresult; stdcall;
    function AutoUnregister(aSpec: nsIFile): nsresult; stdcall;
    function RegisterFactory(const aClass: TGUID; const aClassName: PAnsiChar; const aContractID: PAnsiChar; aFactory: nsIFactory): nsresult; stdcall;
    function UnregisterFactory(const aClass: TGUID; aFactory: nsIFactory): nsresult; stdcall;
    function RegisterFactoryLocation(const aClass: TGUID; const aClassName: PAnsiChar; const aContractID: PAnsiChar; aFile: nsIFile; const aLoaderStr: PAnsiChar; const aType: PAnsiChar): nsresult; stdcall;
    function UnregisterFactoryLocation(const aClass: TGUID; aFile: nsIFile): nsresult; stdcall;
    function IsCIDRegistered(const aClass: TGUID; out _retval: PRBool): nsresult; stdcall;
    function IsContractIDRegistered(const aContractID: PAnsiChar; out _retval: PRBool): nsresult; stdcall;
    function EnumerateCIDs(out _retval: nsISimpleEnumerator): nsresult; stdcall;
    function EnumerateContractIDs(out _retval: nsISimpleEnumerator): nsresult; stdcall;
    function CIDToContractID(const aClass: TGUID; out _retval: PAnsiChar): nsresult; stdcall;
    function ContractIDToCID(const aContractID: PAnsiChar; out _retval: PGUID): nsresult; stdcall;
  end;

  nsIContextMenuListener = interface(nsISupports)
  ['{3478b6b0-3875-11d4-94ef-0020183bf181}']
    function OnShowContextMenu(aContextFlags: PRUint32; aEvent: nsIDOMEvent; aNode: nsIDOMNode): nsresult; stdcall;
  end;

  nsICookie = interface(nsISupports)
  ['{e9fcb9a4-d376-458f-b720-e65e7df593bc}']
    function GetName(aName: nsACString): Longword; stdcall;
    function GetValue(aValue: nsACString): Longword; stdcall;
    function GetIsDomain(out aIsDomain: PRBool): Longword; stdcall;
    function GetHost(aHost: nsACString): Longword; stdcall;
    function GetPath(aPath: nsACString): Longword; stdcall;
    function GetIsSecure(out aIsSecure: PRBool): Longword; stdcall;
    function GetExpires(out aExpires: PRUint64): Longword; stdcall;
    function GetStatus(out aStatus: nsCookieStatus): Longword; stdcall;
    function GetPolicy(out aPolicy: nsCookiePolicy): Longword; stdcall;
  end;

  nsICookieManager = interface(nsISupports)
  ['{aaab6710-0f2c-11d5-a53b-0010a401eb10}']
    function RemoveAll(): nsresult; stdcall;
    function GetEnumerator(out aEnumerator: nsISimpleEnumerator): Longword; stdcall;
    function Remove(const aDomain: nsACString; const aName: nsACString; const aPath: nsACString; aBlocked: PRBool): nsresult; stdcall;
  end;

  nsIDebug = interface(nsISupports)
  ['{3bf0c3d7-3bd9-4cf2-a971-33572c503e1e}']
    function Assertion(const aStr: PAnsiChar; const aExpr: PAnsiChar; const aFile: PAnsiChar; aLine: PRInt32): nsresult; stdcall;
    function Warning(const aStr: PAnsiChar; const aFile: PAnsiChar; aLine: PRInt32): nsresult; stdcall;
    function Break(const aFile: PAnsiChar; aLine: PRInt32): nsresult; stdcall;
    function Abort(const aFile: PAnsiChar; aLine: PRInt32): nsresult; stdcall;
  end;

  nsIFile = interface(nsISupports)
  ['{c8c0a080-0868-11d3-915f-d9d889d48e3c}']
    function Append(const node: nsAString): nsresult; stdcall;
    function AppendNative(const node: nsACString): nsresult; stdcall;
    function Normalize(): nsresult; stdcall;
    function Create(_type: PRUint32; permissions: PRUint32): nsresult; stdcall;
    function GetLeafName(aLeafName: nsAString): Longword; stdcall;
    function SetLeafName(const aLeafName: nsAString): Longword; stdcall;
    function GetNativeLeafName(aNativeLeafName: nsACString): Longword; stdcall;
    function SetNativeLeafName(const aNativeLeafName: nsACString): Longword; stdcall;
    function CopyTo(newParentDir: nsIFile; const newName: nsAString): nsresult; stdcall;
    function CopyToNative(newParentDir: nsIFile; const newName: nsACString): nsresult; stdcall;
    function CopyToFollowingLinks(newParentDir: nsIFile; const newName: nsAString): nsresult; stdcall;
    function CopyToFollowingLinksNative(newParentDir: nsIFile; const newName: nsACString): nsresult; stdcall;
    function MoveTo(newParentDir: nsIFile; const newName: nsAString): nsresult; stdcall;
    function MoveToNative(newParentDir: nsIFile; const newName: nsACString): nsresult; stdcall;
    function Remove(recursive: PRBool): nsresult; stdcall;
    function GetPermissions(out aPermissions: PRUint32): Longword; stdcall;
    function SetPermissions(aPermissions: PRUint32): Longword; stdcall;
    function GetPermissionsOfLink(out aPermissionsOfLink: PRUint32): Longword; stdcall;
    function SetPermissionsOfLink(aPermissionsOfLink: PRUint32): Longword; stdcall;
    function GetLastModifiedTime(out aLastModifiedTime: PRInt64): Longword; stdcall;
    function SetLastModifiedTime(aLastModifiedTime: PRInt64): Longword; stdcall;
    function GetLastModifiedTimeOfLink(out aLastModifiedTimeOfLink: PRInt64): Longword; stdcall;
    function SetLastModifiedTimeOfLink(aLastModifiedTimeOfLink: PRInt64): Longword; stdcall;
    function GetFileSize(out aFileSize: PRInt64): Longword; stdcall;
    function SetFileSize(aFileSize: PRInt64): Longword; stdcall;
    function GetFileSizeOfLink(out aFileSizeOfLink: PRInt64): Longword; stdcall;
    function GetTarget(aTarget: nsAString): Longword; stdcall;
    function GetNativeTarget(aNativeTarget: nsACString): Longword; stdcall;
    function GetPath(aPath: nsAString): Longword; stdcall;
    function GetNativePath(aNativePath: nsACString): Longword; stdcall;
    function Exists(out _retval: PRBool): nsresult; stdcall;
    function IsWritable(out _retval: PRBool): nsresult; stdcall;
    function IsReadable(out _retval: PRBool): nsresult; stdcall;
    function IsExecutable(out _retval: PRBool): nsresult; stdcall;
    function IsHidden(out _retval: PRBool): nsresult; stdcall;
    function IsDirectory(out _retval: PRBool): nsresult; stdcall;
    function IsFile(out _retval: PRBool): nsresult; stdcall;
    function IsSymlink(out _retval: PRBool): nsresult; stdcall;
    function IsSpecial(out _retval: PRBool): nsresult; stdcall;
    function CreateUnique(_type: PRUint32; permissions: PRUint32): nsresult; stdcall;
    function Clone(out _retval: nsIFile): nsresult; stdcall;
    function Equals(inFile: nsIFile; out _retval: PRBool): nsresult; stdcall;
    function Contains(inFile: nsIFile; recur: PRBool; out _retval: PRBool): nsresult; stdcall;
    function GetParent(out aParent: nsIFile): Longword; stdcall;
    function GetDirectoryEntries(out aDirectoryEntries: nsISimpleEnumerator): Longword; stdcall;
  end;

  nsIDirectoryServiceProvider = interface(nsISupports)
  ['{bbf8cab0-d43a-11d3-8cc2-00609792278c}']
    function GetFile(const prop: PAnsiChar; out persistent: PRBool; out _retval: nsIFile): nsresult; stdcall;
  end;

  nsIDirectoryServiceProvider2 = interface(nsIDirectoryServiceProvider)
  ['{2f977d4b-5485-11d4-87e2-0010a4e75ef2}']
    function GetFiles(const prop: PAnsiChar; out _retval: nsISimpleEnumerator): nsresult; stdcall;
  end;

  nsIDirectoryService = interface(nsISupports)
  ['{57a66a60-d43a-11d3-8cc2-00609792278c}']
    function Init(): nsresult; stdcall;
    function RegisterProvider(prov: nsIDirectoryServiceProvider): nsresult; stdcall;
    function UnregisterProvider(prov: nsIDirectoryServiceProvider): nsresult; stdcall;
  end;

  nsIDOM3DocumentEvent = interface(nsISupports)
  ['{090ecc19-b7cb-4f47-ae47-ed68d4926249}']
    function CreateEventGroup(out _retval: nsIDOMEventGroup): nsresult; stdcall;
  end;

  nsIDOM3EventTarget = interface(nsISupports)
  ['{3e9c01a7-de97-4c3b-8294-b4bd9d7056d1}']
    function AddGroupedEventListener(const _type: nsAString; listener: nsIDOMEventListener; useCapture: PRBool; evtGroup: nsIDOMEventGroup): nsresult; stdcall;
    function RemoveGroupedEventListener(const _type: nsAString; listener: nsIDOMEventListener; useCapture: PRBool; evtGroup: nsIDOMEventGroup): nsresult; stdcall;
    function CanTrigger(const _type: nsAString; out _retval: PRBool): nsresult; stdcall;
    function IsRegisteredHere(const _type: nsAString; out _retval: PRBool): nsresult; stdcall;
  end;

  nsIDOMAbstractView = interface(nsISupports)
  ['{f51ebade-8b1a-11d3-aae7-0010830123b4}']
    function GetDocument(out aDocument: nsIDOMDocumentView): Longword; stdcall;
  end;

  nsIDOMNode = interface(nsISupports)
  ['{a6cf907c-15b3-11d2-932e-00805f8add32}']
    function GetNodeName(aNodeName: nsAString): Longword; stdcall;
    function GetNodeValue(aNodeValue: nsAString): Longword; stdcall;
    function SetNodeValue(const aNodeValue: nsAString): Longword; stdcall;
    function GetNodeType(out aNodeType: PRUint16): Longword; stdcall;
    function GetParentNode(out aParentNode: nsIDOMNode): Longword; stdcall;
    function GetChildNodes(out aChildNodes: nsIDOMNodeList): Longword; stdcall;
    function GetFirstChild(out aFirstChild: nsIDOMNode): Longword; stdcall;
    function GetLastChild(out aLastChild: nsIDOMNode): Longword; stdcall;
    function GetPreviousSibling(out aPreviousSibling: nsIDOMNode): Longword; stdcall;
    function GetNextSibling(out aNextSibling: nsIDOMNode): Longword; stdcall;
    function GetAttributes(out aAttributes: nsIDOMNamedNodeMap): Longword; stdcall;
    function GetOwnerDocument(out aOwnerDocument: nsIDOMDocument): Longword; stdcall;
    function InsertBefore(newChild: nsIDOMNode; refChild: nsIDOMNode; out _retval: nsIDOMNode): nsresult; stdcall;
    function ReplaceChild(newChild: nsIDOMNode; oldChild: nsIDOMNode; out _retval: nsIDOMNode): nsresult; stdcall;
    function RemoveChild(oldChild: nsIDOMNode; out _retval: nsIDOMNode): nsresult; stdcall;
    function AppendChild(newChild: nsIDOMNode; out _retval: nsIDOMNode): nsresult; stdcall;
    function HasChildNodes(out _retval: PRBool): nsresult; stdcall;
    function CloneNode(deep: PRBool; out _retval: nsIDOMNode): nsresult; stdcall;
    function Normalize(): nsresult; stdcall;
    function IsSupported(const feature: nsAString; const version: nsAString; out _retval: PRBool): nsresult; stdcall;
    function GetNamespaceURI(aNamespaceURI: nsAString): Longword; stdcall;
    function GetPrefix(aPrefix: nsAString): Longword; stdcall;
    function SetPrefix(const aPrefix: nsAString): Longword; stdcall;
    function GetLocalName(aLocalName: nsAString): Longword; stdcall;
    function HasAttributes(out _retval: PRBool): nsresult; stdcall;
  end;

  nsIDOMAttr = interface(nsIDOMNode)
  ['{a6cf9070-15b3-11d2-932e-00805f8add32}']
    function GetName(aName: nsAString): Longword; stdcall;
    function GetSpecified(out aSpecified: PRBool): Longword; stdcall;
    function GetValue(aValue: nsAString): Longword; stdcall;
    function SetValue(const aValue: nsAString): Longword; stdcall;
    function GetOwnerElement(out aOwnerElement: nsIDOMElement): Longword; stdcall;
  end;

  nsIDOMBarProp = interface(nsISupports)
  ['{9eb2c150-1d56-11d3-8221-0060083a0bcf}']
    function GetVisible(out aVisible: PRBool): Longword; stdcall;
    function SetVisible(aVisible: PRBool): Longword; stdcall;
  end;

  nsIDOMCharacterData = interface(nsIDOMNode)
  ['{a6cf9072-15b3-11d2-932e-00805f8add32}']
    function GetData(aData: nsAString): Longword; stdcall;
    function SetData(const aData: nsAString): Longword; stdcall;
    function GetLength(out aLength: PRUint32): Longword; stdcall;
    function SubstringData(offset: PRUint32; count: PRUint32; _retval: nsAString): nsresult; stdcall;
    function AppendData(const arg: nsAString): nsresult; stdcall;
    function InsertData(offset: PRUint32; const arg: nsAString): nsresult; stdcall;
    function DeleteData(offset: PRUint32; count: PRUint32): nsresult; stdcall;
    function ReplaceData(offset: PRUint32; count: PRUint32; const arg: nsAString): nsresult; stdcall;
  end;

  nsIDOMText = interface(nsIDOMCharacterData)
  ['{a6cf9082-15b3-11d2-932e-00805f8add32}']
    function SplitText(offset: PRUint32; out _retval: nsIDOMText): nsresult; stdcall;
  end;

  nsIDOMCDATASection = interface(nsIDOMText)
  ['{a6cf9071-15b3-11d2-932e-00805f8add32}']
  end;

  nsIDOMComment = interface(nsIDOMCharacterData)
  ['{a6cf9073-15b3-11d2-932e-00805f8add32}']
  end;

  nsIDOMCSSValue = interface(nsISupports)
  ['{009f7ea5-9e80-41be-b008-db62f10823f2}']
    function GetCssText(aCssText: nsAString): Longword; stdcall;
    function SetCssText(const aCssText: nsAString): Longword; stdcall;
    function GetCssValueType(out aCssValueType: PRUint16): Longword; stdcall;
  end;

  nsIDOMCSSPrimitiveValue = interface(nsIDOMCSSValue)
  ['{e249031f-8df9-4e7a-b644-18946dce0019}']
    function GetPrimitiveType(out aPrimitiveType: PRUint16): Longword; stdcall;
    function SetFloatValue(unitType: PRUint16; floatValue: Single): nsresult; stdcall;
    function GetFloatValue(unitType: PRUint16; out _retval: Single): nsresult; stdcall;
    function SetStringValue(stringType: PRUint16; const stringValue: nsAString): nsresult; stdcall;
    function GetStringValue(_retval: nsAString): nsresult; stdcall;
    function GetCounterValue(out _retval: nsIDOMCounter): nsresult; stdcall;
    function GetRectValue(out _retval: nsIDOMRect): nsresult; stdcall;
    function GetRGBColorValue(out _retval: nsIDOMRGBColor): nsresult; stdcall;
  end;

  nsIDOMCSSRule = interface(nsISupports)
  ['{a6cf90c1-15b3-11d2-932e-00805f8add32}']
    function GetType(out aType: PRUint16): Longword; stdcall;
    function GetCssText(aCssText: nsAString): Longword; stdcall;
    function SetCssText(const aCssText: nsAString): Longword; stdcall;
    function GetParentStyleSheet(out aParentStyleSheet: nsIDOMCSSStyleSheet): Longword; stdcall;
    function GetParentRule(out aParentRule: nsIDOMCSSRule): Longword; stdcall;
  end;

  nsIDOMCSSRuleList = interface(nsISupports)
  ['{a6cf90c0-15b3-11d2-932e-00805f8add32}']
    function GetLength(out aLength: PRUint32): Longword; stdcall;
    function Item(index: PRUint32; out _retval: nsIDOMCSSRule): nsresult; stdcall;
  end;

  nsIDOMCSSStyleDeclaration = interface(nsISupports)
  ['{a6cf90be-15b3-11d2-932e-00805f8add32}']
    function GetCssText(aCssText: nsAString): Longword; stdcall;
    function SetCssText(const aCssText: nsAString): Longword; stdcall;
    function GetPropertyValue(const propertyName: nsAString; _retval: nsAString): nsresult; stdcall;
    function GetPropertyCSSValue(const propertyName: nsAString; out _retval: nsIDOMCSSValue): nsresult; stdcall;
    function RemoveProperty(const propertyName: nsAString; _retval: nsAString): nsresult; stdcall;
    function GetPropertyPriority(const propertyName: nsAString; _retval: nsAString): nsresult; stdcall;
    function SetProperty(const propertyName: nsAString; const value: nsAString; const priority: nsAString): nsresult; stdcall;
    function GetLength(out aLength: PRUint32): Longword; stdcall;
    function Item(index: PRUint32; _retval: nsAString): nsresult; stdcall;
    function GetParentRule(out aParentRule: nsIDOMCSSRule): Longword; stdcall;
  end;

  nsIDOMStyleSheet = interface(nsISupports)
  ['{a6cf9080-15b3-11d2-932e-00805f8add32}']
    function GetType(aType: nsAString): Longword; stdcall;
    function GetDisabled(out aDisabled: PRBool): Longword; stdcall;
    function SetDisabled(aDisabled: PRBool): Longword; stdcall;
    function GetOwnerNode(out aOwnerNode: nsIDOMNode): Longword; stdcall;
    function GetParentStyleSheet(out aParentStyleSheet: nsIDOMStyleSheet): Longword; stdcall;
    function GetHref(aHref: nsAString): Longword; stdcall;
    function GetTitle(aTitle: nsAString): Longword; stdcall;
    function GetMedia(out aMedia: nsIDOMMediaList): Longword; stdcall;
  end;

  nsIDOMCSSStyleSheet = interface(nsIDOMStyleSheet)
  ['{a6cf90c2-15b3-11d2-932e-00805f8add32}']
    function GetOwnerRule(out aOwnerRule: nsIDOMCSSRule): Longword; stdcall;
    function GetCssRules(out aCssRules: nsIDOMCSSRuleList): Longword; stdcall;
    function InsertRule(const rule: nsAString; index: PRUint32; out _retval: PRUint32): nsresult; stdcall;
    function DeleteRule(index: PRUint32): nsresult; stdcall;
  end;

  nsIDOMCSSValueList = interface(nsIDOMCSSValue)
  ['{8f09fa84-39b9-4dca-9b2f-db0eeb186286}']
    function GetLength(out aLength: PRUint32): Longword; stdcall;
    function Item(index: PRUint32; out _retval: nsIDOMCSSValue): nsresult; stdcall;
  end;

  nsIDOMEvent = interface(nsISupports)
  ['{a66b7b80-ff46-bd97-0080-5f8ae38add32}']
    function GetType(aType: nsAString): Longword; stdcall;
    function GetTarget(out aTarget: nsIDOMEventTarget): Longword; stdcall;
    function GetCurrentTarget(out aCurrentTarget: nsIDOMEventTarget): Longword; stdcall;
    function GetEventPhase(out aEventPhase: PRUint16): Longword; stdcall;
    function GetBubbles(out aBubbles: PRBool): Longword; stdcall;
    function GetCancelable(out aCancelable: PRBool): Longword; stdcall;
    function GetTimeStamp(out aTimeStamp: DOMTimeStamp): Longword; stdcall;
    function StopPropagation(): nsresult; stdcall;
    function PreventDefault(): nsresult; stdcall;
    function InitEvent(const eventTypeArg: nsAString; canBubbleArg: PRBool; cancelableArg: PRBool): nsresult; stdcall;
  end;

  nsIDOMCustomEvent = interface(nsIDOMEvent)
  ['{55c7af7b-1a64-40bf-87eb-2c2cbee0491b}']
    function SetCurrentTarget(target: nsIDOMNode): nsresult; stdcall;
    function SetEventPhase(phase: PRUint16): nsresult; stdcall;
  end;

  nsIDOMDocument = interface(nsIDOMNode)
  ['{a6cf9075-15b3-11d2-932e-00805f8add32}']
    function GetDoctype(out aDoctype: nsIDOMDocumentType): Longword; stdcall;
    function GetImplementation(out aImplementation: nsIDOMDOMImplementation): Longword; stdcall;
    function GetDocumentElement(out aDocumentElement: nsIDOMElement): Longword; stdcall;
    function CreateElement(const tagName: nsAString; out _retval: nsIDOMElement): nsresult; stdcall;
    function CreateDocumentFragment(out _retval: nsIDOMDocumentFragment): nsresult; stdcall;
    function CreateTextNode(const data: nsAString; out _retval: nsIDOMText): nsresult; stdcall;
    function CreateComment(const data: nsAString; out _retval: nsIDOMComment): nsresult; stdcall;
    function CreateCDATASection(const data: nsAString; out _retval: nsIDOMCDATASection): nsresult; stdcall;
    function CreateProcessingInstruction(const target: nsAString; const data: nsAString; out _retval: nsIDOMProcessingInstruction): nsresult; stdcall;
    function CreateAttribute(const name: nsAString; out _retval: nsIDOMAttr): nsresult; stdcall;
    function CreateEntityReference(const name: nsAString; out _retval: nsIDOMEntityReference): nsresult; stdcall;
    function GetElementsByTagName(const tagname: nsAString; out _retval: nsIDOMNodeList): nsresult; stdcall;
    function ImportNode(importedNode: nsIDOMNode; deep: PRBool; out _retval: nsIDOMNode): nsresult; stdcall;
    function CreateElementNS(const namespaceURI: nsAString; const qualifiedName: nsAString; out _retval: nsIDOMElement): nsresult; stdcall;
    function CreateAttributeNS(const namespaceURI: nsAString; const qualifiedName: nsAString; out _retval: nsIDOMAttr): nsresult; stdcall;
    function GetElementsByTagNameNS(const namespaceURI: nsAString; const localName: nsAString; out _retval: nsIDOMNodeList): nsresult; stdcall;
    function GetElementById(const elementId: nsAString; out _retval: nsIDOMElement): nsresult; stdcall;
  end;

  nsIDOMDocumentEvent = interface(nsISupports)
  ['{46b91d66-28e2-11d4-ab1e-0010830123b4}']
    function CreateEvent(const eventType: nsAString; out _retval: nsIDOMEvent): nsresult; stdcall;
  end;

  nsIDOMDocumentFragment = interface(nsIDOMNode)
  ['{a6cf9076-15b3-11d2-932e-00805f8add32}']
  end;

  nsIDOMDocumentRange = interface(nsISupports)
  ['{7b9badc6-c9bc-447a-8670-dbd195aed24b}']
    function CreateRange(out _retval: nsIDOMRange): nsresult; stdcall;
  end;

  nsIDOMDocumentStyle = interface(nsISupports)
  ['{3d9f4973-dd2e-48f5-b5f7-2634e09eadd9}']
    function GetStyleSheets(out aStyleSheets: nsIDOMStyleSheetList): Longword; stdcall;
  end;

  nsIDOMDocumentType = interface(nsIDOMNode)
  ['{a6cf9077-15b3-11d2-932e-00805f8add32}']
    function GetName(aName: nsAString): Longword; stdcall;
    function GetEntities(out aEntities: nsIDOMNamedNodeMap): Longword; stdcall;
    function GetNotations(out aNotations: nsIDOMNamedNodeMap): Longword; stdcall;
    function GetPublicId(aPublicId: nsAString): Longword; stdcall;
    function GetSystemId(aSystemId: nsAString): Longword; stdcall;
    function GetInternalSubset(aInternalSubset: nsAString): Longword; stdcall;
  end;

  nsIDOMDocumentView = interface(nsISupports)
  ['{1acdb2ba-1dd2-11b2-95bc-9542495d2569}']
    function GetDefaultView(out aDefaultView: nsIDOMAbstractView): Longword; stdcall;
  end;

  nsIDOMDOMException = interface(nsISupports)
  ['{a6cf910a-15b3-11d2-932e-00805f8add32}']
    function GetCode(out aCode: PRUint32): Longword; stdcall;
  end;

  nsIDOMDOMImplementation = interface(nsISupports)
  ['{a6cf9074-15b3-11d2-932e-00805f8add32}']
    function HasFeature(const feature: nsAString; const version: nsAString; out _retval: PRBool): nsresult; stdcall;
    function CreateDocumentType(const qualifiedName: nsAString; const publicId: nsAString; const systemId: nsAString; out _retval: nsIDOMDocumentType): nsresult; stdcall;
    function CreateDocument(const namespaceURI: nsAString; const qualifiedName: nsAString; doctype: nsIDOMDocumentType; out _retval: nsIDOMDocument): nsresult; stdcall;
  end;

  nsIDOMElement = interface(nsIDOMNode)
  ['{a6cf9078-15b3-11d2-932e-00805f8add32}']
    function GetTagName(aTagName: nsAString): Longword; stdcall;
    function GetAttribute(const name: nsAString; _retval: nsAString): nsresult; stdcall;
    function SetAttribute(const name: nsAString; const value: nsAString): nsresult; stdcall;
    function RemoveAttribute(const name: nsAString): nsresult; stdcall;
    function GetAttributeNode(const name: nsAString; out _retval: nsIDOMAttr): nsresult; stdcall;
    function SetAttributeNode(newAttr: nsIDOMAttr; out _retval: nsIDOMAttr): nsresult; stdcall;
    function RemoveAttributeNode(oldAttr: nsIDOMAttr; out _retval: nsIDOMAttr): nsresult; stdcall;
    function GetElementsByTagName(const name: nsAString; out _retval: nsIDOMNodeList): nsresult; stdcall;
    function GetAttributeNS(const namespaceURI: nsAString; const localName: nsAString; _retval: nsAString): nsresult; stdcall;
    function SetAttributeNS(const namespaceURI: nsAString; const qualifiedName: nsAString; const value: nsAString): nsresult; stdcall;
    function RemoveAttributeNS(const namespaceURI: nsAString; const localName: nsAString): nsresult; stdcall;
    function GetAttributeNodeNS(const namespaceURI: nsAString; const localName: nsAString; out _retval: nsIDOMAttr): nsresult; stdcall;
    function SetAttributeNodeNS(newAttr: nsIDOMAttr; out _retval: nsIDOMAttr): nsresult; stdcall;
    function GetElementsByTagNameNS(const namespaceURI: nsAString; const localName: nsAString; out _retval: nsIDOMNodeList): nsresult; stdcall;
    function HasAttribute(const name: nsAString; out _retval: PRBool): nsresult; stdcall;
    function HasAttributeNS(const namespaceURI: nsAString; const localName: nsAString; out _retval: PRBool): nsresult; stdcall;
  end;

  nsIDOMEntity = interface(nsIDOMNode)
  ['{a6cf9079-15b3-11d2-932e-00805f8add32}']
    function GetPublicId(aPublicId: nsAString): Longword; stdcall;
    function GetSystemId(aSystemId: nsAString): Longword; stdcall;
    function GetNotationName(aNotationName: nsAString): Longword; stdcall;
  end;

  nsIDOMEntityReference = interface(nsIDOMNode)
  ['{a6cf907a-15b3-11d2-932e-00805f8add32}']
  end;

  nsIDOMEventGroup = interface(nsISupports)
  ['{33347bee-6620-4841-8152-36091ae80c7e}']
    function IsSameEventGroup(other: nsIDOMEventGroup; out _retval: PRBool): nsresult; stdcall;
  end;

  nsIDOMEventListener = interface(nsISupports)
  ['{df31c120-ded6-11d1-bd85-00805f8ae3f4}']
    function HandleEvent(event: nsIDOMEvent): nsresult; stdcall;
  end;

  nsIDOMEventTarget = interface(nsISupports)
  ['{1c773b30-d1cf-11d2-bd95-00805f8ae3f4}']
    function AddEventListener(const _type: nsAString; listener: nsIDOMEventListener; useCapture: PRBool): nsresult; stdcall;
    function RemoveEventListener(const _type: nsAString; listener: nsIDOMEventListener; useCapture: PRBool): nsresult; stdcall;
    function DispatchEvent(evt: nsIDOMEvent; out _retval: PRBool): nsresult; stdcall;
  end;

  nsIDOMHTMLElement = interface(nsIDOMElement)
  ['{a6cf9085-15b3-11d2-932e-00805f8add32}']
    function GetId(aId: nsAString): Longword; stdcall;
    function SetId(const aId: nsAString): Longword; stdcall;
    function GetTitle(aTitle: nsAString): Longword; stdcall;
    function SetTitle(const aTitle: nsAString): Longword; stdcall;
    function GetLang(aLang: nsAString): Longword; stdcall;
    function SetLang(const aLang: nsAString): Longword; stdcall;
    function GetDir(aDir: nsAString): Longword; stdcall;
    function SetDir(const aDir: nsAString): Longword; stdcall;
    function GetClassName(aClassName: nsAString): Longword; stdcall;
    function SetClassName(const aClassName: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLAnchorElement = interface(nsIDOMHTMLElement)
  ['{a6cf90aa-15b3-11d2-932e-00805f8add32}']
    function GetAccessKey(aAccessKey: nsAString): Longword; stdcall;
    function SetAccessKey(const aAccessKey: nsAString): Longword; stdcall;
    function GetCharset(aCharset: nsAString): Longword; stdcall;
    function SetCharset(const aCharset: nsAString): Longword; stdcall;
    function GetCoords(aCoords: nsAString): Longword; stdcall;
    function SetCoords(const aCoords: nsAString): Longword; stdcall;
    function GetHref(aHref: nsAString): Longword; stdcall;
    function SetHref(const aHref: nsAString): Longword; stdcall;
    function GetHreflang(aHreflang: nsAString): Longword; stdcall;
    function SetHreflang(const aHreflang: nsAString): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetRel(aRel: nsAString): Longword; stdcall;
    function SetRel(const aRel: nsAString): Longword; stdcall;
    function GetRev(aRev: nsAString): Longword; stdcall;
    function SetRev(const aRev: nsAString): Longword; stdcall;
    function GetShape(aShape: nsAString): Longword; stdcall;
    function SetShape(const aShape: nsAString): Longword; stdcall;
    function GetTabIndex(out aTabIndex: PRInt32): Longword; stdcall;
    function SetTabIndex(aTabIndex: PRInt32): Longword; stdcall;
    function GetTarget(aTarget: nsAString): Longword; stdcall;
    function SetTarget(const aTarget: nsAString): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function SetType(const aType: nsAString): Longword; stdcall;
    function Blur(): nsresult; stdcall;
    function Focus(): nsresult; stdcall;
  end;

  nsIDOMHTMLAppletElement = interface(nsIDOMHTMLElement)
  ['{a6cf90ae-15b3-11d2-932e-00805f8add32}']
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetAlt(aAlt: nsAString): Longword; stdcall;
    function SetAlt(const aAlt: nsAString): Longword; stdcall;
    function GetArchive(aArchive: nsAString): Longword; stdcall;
    function SetArchive(const aArchive: nsAString): Longword; stdcall;
    function GetCode(aCode: nsAString): Longword; stdcall;
    function SetCode(const aCode: nsAString): Longword; stdcall;
    function GetCodeBase(aCodeBase: nsAString): Longword; stdcall;
    function SetCodeBase(const aCodeBase: nsAString): Longword; stdcall;
    function GetHeight(aHeight: nsAString): Longword; stdcall;
    function SetHeight(const aHeight: nsAString): Longword; stdcall;
    function GetHspace(out aHspace: PRInt32): Longword; stdcall;
    function SetHspace(aHspace: PRInt32): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetObject(aObject: nsAString): Longword; stdcall;
    function SetObject(const aObject: nsAString): Longword; stdcall;
    function GetVspace(out aVspace: PRInt32): Longword; stdcall;
    function SetVspace(aVspace: PRInt32): Longword; stdcall;
    function GetWidth(aWidth: nsAString): Longword; stdcall;
    function SetWidth(const aWidth: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLAreaElement = interface(nsIDOMHTMLElement)
  ['{a6cf90b0-15b3-11d2-932e-00805f8add32}']
    function GetAccessKey(aAccessKey: nsAString): Longword; stdcall;
    function SetAccessKey(const aAccessKey: nsAString): Longword; stdcall;
    function GetAlt(aAlt: nsAString): Longword; stdcall;
    function SetAlt(const aAlt: nsAString): Longword; stdcall;
    function GetCoords(aCoords: nsAString): Longword; stdcall;
    function SetCoords(const aCoords: nsAString): Longword; stdcall;
    function GetHref(aHref: nsAString): Longword; stdcall;
    function SetHref(const aHref: nsAString): Longword; stdcall;
    function GetNoHref(out aNoHref: PRBool): Longword; stdcall;
    function SetNoHref(aNoHref: PRBool): Longword; stdcall;
    function GetShape(aShape: nsAString): Longword; stdcall;
    function SetShape(const aShape: nsAString): Longword; stdcall;
    function GetTabIndex(out aTabIndex: PRInt32): Longword; stdcall;
    function SetTabIndex(aTabIndex: PRInt32): Longword; stdcall;
    function GetTarget(aTarget: nsAString): Longword; stdcall;
    function SetTarget(const aTarget: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLBaseElement = interface(nsIDOMHTMLElement)
  ['{a6cf908b-15b3-11d2-932e-00805f8add32}']
    function GetHref(aHref: nsAString): Longword; stdcall;
    function SetHref(const aHref: nsAString): Longword; stdcall;
    function GetTarget(aTarget: nsAString): Longword; stdcall;
    function SetTarget(const aTarget: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLBaseFontElement = interface(nsIDOMHTMLElement)
  ['{a6cf90a6-15b3-11d2-932e-00805f8add32}']
    function GetColor(aColor: nsAString): Longword; stdcall;
    function SetColor(const aColor: nsAString): Longword; stdcall;
    function GetFace(aFace: nsAString): Longword; stdcall;
    function SetFace(const aFace: nsAString): Longword; stdcall;
    function GetSize(out aSize: PRInt32): Longword; stdcall;
    function SetSize(aSize: PRInt32): Longword; stdcall;
  end;

  nsIDOMHTMLBodyElement = interface(nsIDOMHTMLElement)
  ['{a6cf908e-15b3-11d2-932e-00805f8add32}']
    function GetALink(aALink: nsAString): Longword; stdcall;
    function SetALink(const aALink: nsAString): Longword; stdcall;
    function GetBackground(aBackground: nsAString): Longword; stdcall;
    function SetBackground(const aBackground: nsAString): Longword; stdcall;
    function GetBgColor(aBgColor: nsAString): Longword; stdcall;
    function SetBgColor(const aBgColor: nsAString): Longword; stdcall;
    function GetLink(aLink: nsAString): Longword; stdcall;
    function SetLink(const aLink: nsAString): Longword; stdcall;
    function GetText(aText: nsAString): Longword; stdcall;
    function SetText(const aText: nsAString): Longword; stdcall;
    function GetVLink(aVLink: nsAString): Longword; stdcall;
    function SetVLink(const aVLink: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLBRElement = interface(nsIDOMHTMLElement)
  ['{a6cf90a5-15b3-11d2-932e-00805f8add32}']
    function GetClear(aClear: nsAString): Longword; stdcall;
    function SetClear(const aClear: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLButtonElement = interface(nsIDOMHTMLElement)
  ['{a6cf9095-15b3-11d2-932e-00805f8add32}']
    function GetForm(out aForm: nsIDOMHTMLFormElement): Longword; stdcall;
    function GetAccessKey(aAccessKey: nsAString): Longword; stdcall;
    function SetAccessKey(const aAccessKey: nsAString): Longword; stdcall;
    function GetDisabled(out aDisabled: PRBool): Longword; stdcall;
    function SetDisabled(aDisabled: PRBool): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetTabIndex(out aTabIndex: PRInt32): Longword; stdcall;
    function SetTabIndex(aTabIndex: PRInt32): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function GetValue(aValue: nsAString): Longword; stdcall;
    function SetValue(const aValue: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLCollection = interface(nsISupports)
  ['{a6cf9083-15b3-11d2-932e-00805f8add32}']
    function GetLength(out aLength: PRUint32): Longword; stdcall;
    function Item(index: PRUint32; out _retval: nsIDOMNode): nsresult; stdcall;
    function NamedItem(const name: nsAString; out _retval: nsIDOMNode): nsresult; stdcall;
  end;

  nsIDOMHTMLDirectoryElement = interface(nsIDOMHTMLElement)
  ['{a6cf909c-15b3-11d2-932e-00805f8add32}']
    function GetCompact(out aCompact: PRBool): Longword; stdcall;
    function SetCompact(aCompact: PRBool): Longword; stdcall;
  end;

  nsIDOMHTMLDivElement = interface(nsIDOMHTMLElement)
  ['{a6cf90a0-15b3-11d2-932e-00805f8add32}']
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLDListElement = interface(nsIDOMHTMLElement)
  ['{a6cf909b-15b3-11d2-932e-00805f8add32}']
    function GetCompact(out aCompact: PRBool): Longword; stdcall;
    function SetCompact(aCompact: PRBool): Longword; stdcall;
  end;

  nsIDOMHTMLDocument = interface(nsIDOMDocument)
  ['{a6cf9084-15b3-11d2-932e-00805f8add32}']
    function GetTitle(aTitle: nsAString): Longword; stdcall;
    function SetTitle(const aTitle: nsAString): Longword; stdcall;
    function GetReferrer(aReferrer: nsAString): Longword; stdcall;
    function GetDomain(aDomain: nsAString): Longword; stdcall;
    function GetURL(aURL: nsAString): Longword; stdcall;
    function GetBody(out aBody: nsIDOMHTMLElement): Longword; stdcall;
    function SetBody(aBody: nsIDOMHTMLElement): Longword; stdcall;
    function GetImages(out aImages: nsIDOMHTMLCollection): Longword; stdcall;
    function GetApplets(out aApplets: nsIDOMHTMLCollection): Longword; stdcall;
    function GetLinks(out aLinks: nsIDOMHTMLCollection): Longword; stdcall;
    function GetForms(out aForms: nsIDOMHTMLCollection): Longword; stdcall;
    function GetAnchors(out aAnchors: nsIDOMHTMLCollection): Longword; stdcall;
    function GetCookie(aCookie: nsAString): Longword; stdcall;
    function SetCookie(const aCookie: nsAString): Longword; stdcall;
    function Open(): nsresult; stdcall;
    function Close(): nsresult; stdcall;
    function Write(const text: nsAString): nsresult; stdcall;
    function Writeln(const text: nsAString): nsresult; stdcall;
    function GetElementsByName(const elementName: nsAString; out _retval: nsIDOMNodeList): nsresult; stdcall;
  end;

  nsIDOMHTMLEmbedElement = interface(nsIDOMHTMLElement)
  ['{123f90ab-15b3-11d2-456e-00805f8add32}']
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetHeight(aHeight: nsAString): Longword; stdcall;
    function SetHeight(const aHeight: nsAString): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetSrc(aSrc: nsAString): Longword; stdcall;
    function SetSrc(const aSrc: nsAString): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function SetType(const aType: nsAString): Longword; stdcall;
    function GetWidth(aWidth: nsAString): Longword; stdcall;
    function SetWidth(const aWidth: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLFieldSetElement = interface(nsIDOMHTMLElement)
  ['{a6cf9097-15b3-11d2-932e-00805f8add32}']
    function GetForm(out aForm: nsIDOMHTMLFormElement): Longword; stdcall;
  end;

  nsIDOMHTMLFontElement = interface(nsIDOMHTMLElement)
  ['{a6cf90a7-15b3-11d2-932e-00805f8add32}']
    function GetColor(aColor: nsAString): Longword; stdcall;
    function SetColor(const aColor: nsAString): Longword; stdcall;
    function GetFace(aFace: nsAString): Longword; stdcall;
    function SetFace(const aFace: nsAString): Longword; stdcall;
    function GetSize(aSize: nsAString): Longword; stdcall;
    function SetSize(const aSize: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLFormElement = interface(nsIDOMHTMLElement)
  ['{a6cf908f-15b3-11d2-932e-00805f8add32}']
    function GetElements(out aElements: nsIDOMHTMLCollection): Longword; stdcall;
    function GetLength(out aLength: PRInt32): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetAcceptCharset(aAcceptCharset: nsAString): Longword; stdcall;
    function SetAcceptCharset(const aAcceptCharset: nsAString): Longword; stdcall;
    function GetAction(aAction: nsAString): Longword; stdcall;
    function SetAction(const aAction: nsAString): Longword; stdcall;
    function GetEnctype(aEnctype: nsAString): Longword; stdcall;
    function SetEnctype(const aEnctype: nsAString): Longword; stdcall;
    function GetMethod(aMethod: nsAString): Longword; stdcall;
    function SetMethod(const aMethod: nsAString): Longword; stdcall;
    function GetTarget(aTarget: nsAString): Longword; stdcall;
    function SetTarget(const aTarget: nsAString): Longword; stdcall;
    function Submit(): nsresult; stdcall;
    function Reset(): nsresult; stdcall;
  end;

  nsIDOMHTMLFrameElement = interface(nsIDOMHTMLElement)
  ['{a6cf90b9-15b3-11d2-932e-00805f8add32}']
    function GetFrameBorder(aFrameBorder: nsAString): Longword; stdcall;
    function SetFrameBorder(const aFrameBorder: nsAString): Longword; stdcall;
    function GetLongDesc(aLongDesc: nsAString): Longword; stdcall;
    function SetLongDesc(const aLongDesc: nsAString): Longword; stdcall;
    function GetMarginHeight(aMarginHeight: nsAString): Longword; stdcall;
    function SetMarginHeight(const aMarginHeight: nsAString): Longword; stdcall;
    function GetMarginWidth(aMarginWidth: nsAString): Longword; stdcall;
    function SetMarginWidth(const aMarginWidth: nsAString): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetNoResize(out aNoResize: PRBool): Longword; stdcall;
    function SetNoResize(aNoResize: PRBool): Longword; stdcall;
    function GetScrolling(aScrolling: nsAString): Longword; stdcall;
    function SetScrolling(const aScrolling: nsAString): Longword; stdcall;
    function GetSrc(aSrc: nsAString): Longword; stdcall;
    function SetSrc(const aSrc: nsAString): Longword; stdcall;
    function GetContentDocument(out aContentDocument: nsIDOMDocument): Longword; stdcall;
  end;

  nsIDOMHTMLFrameSetElement = interface(nsIDOMHTMLElement)
  ['{a6cf90b8-15b3-11d2-932e-00805f8add32}']
    function GetCols(aCols: nsAString): Longword; stdcall;
    function SetCols(const aCols: nsAString): Longword; stdcall;
    function GetRows(aRows: nsAString): Longword; stdcall;
    function SetRows(const aRows: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLHeadElement = interface(nsIDOMHTMLElement)
  ['{a6cf9087-15b3-11d2-932e-00805f8add32}']
    function GetProfile(aProfile: nsAString): Longword; stdcall;
    function SetProfile(const aProfile: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLHeadingElement = interface(nsIDOMHTMLElement)
  ['{a6cf90a2-15b3-11d2-932e-00805f8add32}']
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLHRElement = interface(nsIDOMHTMLElement)
  ['{a6cf90a8-15b3-11d2-932e-00805f8add32}']
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetNoShade(out aNoShade: PRBool): Longword; stdcall;
    function SetNoShade(aNoShade: PRBool): Longword; stdcall;
    function GetSize(aSize: nsAString): Longword; stdcall;
    function SetSize(const aSize: nsAString): Longword; stdcall;
    function GetWidth(aWidth: nsAString): Longword; stdcall;
    function SetWidth(const aWidth: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLHtmlElement = interface(nsIDOMHTMLElement)
  ['{a6cf9086-15b3-11d2-932e-00805f8add32}']
    function GetVersion(aVersion: nsAString): Longword; stdcall;
    function SetVersion(const aVersion: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLIFrameElement = interface(nsIDOMHTMLElement)
  ['{a6cf90ba-15b3-11d2-932e-00805f8add32}']
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetFrameBorder(aFrameBorder: nsAString): Longword; stdcall;
    function SetFrameBorder(const aFrameBorder: nsAString): Longword; stdcall;
    function GetHeight(aHeight: nsAString): Longword; stdcall;
    function SetHeight(const aHeight: nsAString): Longword; stdcall;
    function GetLongDesc(aLongDesc: nsAString): Longword; stdcall;
    function SetLongDesc(const aLongDesc: nsAString): Longword; stdcall;
    function GetMarginHeight(aMarginHeight: nsAString): Longword; stdcall;
    function SetMarginHeight(const aMarginHeight: nsAString): Longword; stdcall;
    function GetMarginWidth(aMarginWidth: nsAString): Longword; stdcall;
    function SetMarginWidth(const aMarginWidth: nsAString): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetScrolling(aScrolling: nsAString): Longword; stdcall;
    function SetScrolling(const aScrolling: nsAString): Longword; stdcall;
    function GetSrc(aSrc: nsAString): Longword; stdcall;
    function SetSrc(const aSrc: nsAString): Longword; stdcall;
    function GetWidth(aWidth: nsAString): Longword; stdcall;
    function SetWidth(const aWidth: nsAString): Longword; stdcall;
    function GetContentDocument(out aContentDocument: nsIDOMDocument): Longword; stdcall;
  end;

  nsIDOMHTMLImageElement = interface(nsIDOMHTMLElement)
  ['{a6cf90ab-15b3-11d2-932e-00805f8add32}']
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetAlt(aAlt: nsAString): Longword; stdcall;
    function SetAlt(const aAlt: nsAString): Longword; stdcall;
    function GetBorder(aBorder: nsAString): Longword; stdcall;
    function SetBorder(const aBorder: nsAString): Longword; stdcall;
    function GetHeight(out aHeight: PRInt32): Longword; stdcall;
    function SetHeight(aHeight: PRInt32): Longword; stdcall;
    function GetHspace(out aHspace: PRInt32): Longword; stdcall;
    function SetHspace(aHspace: PRInt32): Longword; stdcall;
    function GetIsMap(out aIsMap: PRBool): Longword; stdcall;
    function SetIsMap(aIsMap: PRBool): Longword; stdcall;
    function GetLongDesc(aLongDesc: nsAString): Longword; stdcall;
    function SetLongDesc(const aLongDesc: nsAString): Longword; stdcall;
    function GetSrc(aSrc: nsAString): Longword; stdcall;
    function SetSrc(const aSrc: nsAString): Longword; stdcall;
    function GetUseMap(aUseMap: nsAString): Longword; stdcall;
    function SetUseMap(const aUseMap: nsAString): Longword; stdcall;
    function GetVspace(out aVspace: PRInt32): Longword; stdcall;
    function SetVspace(aVspace: PRInt32): Longword; stdcall;
    function GetWidth(out aWidth: PRInt32): Longword; stdcall;
    function SetWidth(aWidth: PRInt32): Longword; stdcall;
  end;

  nsIDOMHTMLInputElement = interface(nsIDOMHTMLElement)
  ['{a6cf9093-15b3-11d2-932e-00805f8add32}']
    function GetDefaultValue(aDefaultValue: nsAString): Longword; stdcall;
    function SetDefaultValue(const aDefaultValue: nsAString): Longword; stdcall;
    function GetDefaultChecked(out aDefaultChecked: PRBool): Longword; stdcall;
    function SetDefaultChecked(aDefaultChecked: PRBool): Longword; stdcall;
    function GetForm(out aForm: nsIDOMHTMLFormElement): Longword; stdcall;
    function GetAccept(aAccept: nsAString): Longword; stdcall;
    function SetAccept(const aAccept: nsAString): Longword; stdcall;
    function GetAccessKey(aAccessKey: nsAString): Longword; stdcall;
    function SetAccessKey(const aAccessKey: nsAString): Longword; stdcall;
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetAlt(aAlt: nsAString): Longword; stdcall;
    function SetAlt(const aAlt: nsAString): Longword; stdcall;
    function GetChecked(out aChecked: PRBool): Longword; stdcall;
    function SetChecked(aChecked: PRBool): Longword; stdcall;
    function GetDisabled(out aDisabled: PRBool): Longword; stdcall;
    function SetDisabled(aDisabled: PRBool): Longword; stdcall;
    function GetMaxLength(out aMaxLength: PRInt32): Longword; stdcall;
    function SetMaxLength(aMaxLength: PRInt32): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetReadOnly(out aReadOnly: PRBool): Longword; stdcall;
    function SetReadOnly(aReadOnly: PRBool): Longword; stdcall;
    function GetSize(out aSize: PRUint32): Longword; stdcall;
    function SetSize(aSize: PRUint32): Longword; stdcall;
    function GetSrc(aSrc: nsAString): Longword; stdcall;
    function SetSrc(const aSrc: nsAString): Longword; stdcall;
    function GetTabIndex(out aTabIndex: PRInt32): Longword; stdcall;
    function SetTabIndex(aTabIndex: PRInt32): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function SetType(const aType: nsAString): Longword; stdcall;
    function GetUseMap(aUseMap: nsAString): Longword; stdcall;
    function SetUseMap(const aUseMap: nsAString): Longword; stdcall;
    function GetValue(aValue: nsAString): Longword; stdcall;
    function SetValue(const aValue: nsAString): Longword; stdcall;
    function Blur(): nsresult; stdcall;
    function Focus(): nsresult; stdcall;
    function Select(): nsresult; stdcall;
    function Click(): nsresult; stdcall;
  end;

  nsIDOMHTMLIsIndexElement = interface(nsIDOMHTMLElement)
  ['{a6cf908c-15b3-11d2-932e-00805f8add32}']
    function GetForm(out aForm: nsIDOMHTMLFormElement): Longword; stdcall;
    function GetPrompt(aPrompt: nsAString): Longword; stdcall;
    function SetPrompt(const aPrompt: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLLabelElement = interface(nsIDOMHTMLElement)
  ['{a6cf9096-15b3-11d2-932e-00805f8add32}']
    function GetForm(out aForm: nsIDOMHTMLFormElement): Longword; stdcall;
    function GetAccessKey(aAccessKey: nsAString): Longword; stdcall;
    function SetAccessKey(const aAccessKey: nsAString): Longword; stdcall;
    function GetHtmlFor(aHtmlFor: nsAString): Longword; stdcall;
    function SetHtmlFor(const aHtmlFor: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLLegendElement = interface(nsIDOMHTMLElement)
  ['{a6cf9098-15b3-11d2-932e-00805f8add32}']
    function GetForm(out aForm: nsIDOMHTMLFormElement): Longword; stdcall;
    function GetAccessKey(aAccessKey: nsAString): Longword; stdcall;
    function SetAccessKey(const aAccessKey: nsAString): Longword; stdcall;
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLLIElement = interface(nsIDOMHTMLElement)
  ['{a6cf909e-15b3-11d2-932e-00805f8add32}']
    function GetType(aType: nsAString): Longword; stdcall;
    function SetType(const aType: nsAString): Longword; stdcall;
    function GetValue(out aValue: PRInt32): Longword; stdcall;
    function SetValue(aValue: PRInt32): Longword; stdcall;
  end;

  nsIDOMHTMLLinkElement = interface(nsIDOMHTMLElement)
  ['{a6cf9088-15b3-11d2-932e-00805f8add32}']
    function GetDisabled(out aDisabled: PRBool): Longword; stdcall;
    function SetDisabled(aDisabled: PRBool): Longword; stdcall;
    function GetCharset(aCharset: nsAString): Longword; stdcall;
    function SetCharset(const aCharset: nsAString): Longword; stdcall;
    function GetHref(aHref: nsAString): Longword; stdcall;
    function SetHref(const aHref: nsAString): Longword; stdcall;
    function GetHreflang(aHreflang: nsAString): Longword; stdcall;
    function SetHreflang(const aHreflang: nsAString): Longword; stdcall;
    function GetMedia(aMedia: nsAString): Longword; stdcall;
    function SetMedia(const aMedia: nsAString): Longword; stdcall;
    function GetRel(aRel: nsAString): Longword; stdcall;
    function SetRel(const aRel: nsAString): Longword; stdcall;
    function GetRev(aRev: nsAString): Longword; stdcall;
    function SetRev(const aRev: nsAString): Longword; stdcall;
    function GetTarget(aTarget: nsAString): Longword; stdcall;
    function SetTarget(const aTarget: nsAString): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function SetType(const aType: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLMapElement = interface(nsIDOMHTMLElement)
  ['{a6cf90af-15b3-11d2-932e-00805f8add32}']
    function GetAreas(out aAreas: nsIDOMHTMLCollection): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLMenuElement = interface(nsIDOMHTMLElement)
  ['{a6cf909d-15b3-11d2-932e-00805f8add32}']
    function GetCompact(out aCompact: PRBool): Longword; stdcall;
    function SetCompact(aCompact: PRBool): Longword; stdcall;
  end;

  nsIDOMHTMLMetaElement = interface(nsIDOMHTMLElement)
  ['{a6cf908a-15b3-11d2-932e-00805f8add32}']
    function GetContent(aContent: nsAString): Longword; stdcall;
    function SetContent(const aContent: nsAString): Longword; stdcall;
    function GetHttpEquiv(aHttpEquiv: nsAString): Longword; stdcall;
    function SetHttpEquiv(const aHttpEquiv: nsAString): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetScheme(aScheme: nsAString): Longword; stdcall;
    function SetScheme(const aScheme: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLModElement = interface(nsIDOMHTMLElement)
  ['{a6cf90a9-15b3-11d2-932e-00805f8add32}']
    function GetCite(aCite: nsAString): Longword; stdcall;
    function SetCite(const aCite: nsAString): Longword; stdcall;
    function GetDateTime(aDateTime: nsAString): Longword; stdcall;
    function SetDateTime(const aDateTime: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLObjectElement = interface(nsIDOMHTMLElement)
  ['{a6cf90ac-15b3-11d2-932e-00805f8add32}']
    function GetForm(out aForm: nsIDOMHTMLFormElement): Longword; stdcall;
    function GetCode(aCode: nsAString): Longword; stdcall;
    function SetCode(const aCode: nsAString): Longword; stdcall;
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetArchive(aArchive: nsAString): Longword; stdcall;
    function SetArchive(const aArchive: nsAString): Longword; stdcall;
    function GetBorder(aBorder: nsAString): Longword; stdcall;
    function SetBorder(const aBorder: nsAString): Longword; stdcall;
    function GetCodeBase(aCodeBase: nsAString): Longword; stdcall;
    function SetCodeBase(const aCodeBase: nsAString): Longword; stdcall;
    function GetCodeType(aCodeType: nsAString): Longword; stdcall;
    function SetCodeType(const aCodeType: nsAString): Longword; stdcall;
    function GetData(aData: nsAString): Longword; stdcall;
    function SetData(const aData: nsAString): Longword; stdcall;
    function GetDeclare(out aDeclare: PRBool): Longword; stdcall;
    function SetDeclare(aDeclare: PRBool): Longword; stdcall;
    function GetHeight(aHeight: nsAString): Longword; stdcall;
    function SetHeight(const aHeight: nsAString): Longword; stdcall;
    function GetHspace(out aHspace: PRInt32): Longword; stdcall;
    function SetHspace(aHspace: PRInt32): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetStandby(aStandby: nsAString): Longword; stdcall;
    function SetStandby(const aStandby: nsAString): Longword; stdcall;
    function GetTabIndex(out aTabIndex: PRInt32): Longword; stdcall;
    function SetTabIndex(aTabIndex: PRInt32): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function SetType(const aType: nsAString): Longword; stdcall;
    function GetUseMap(aUseMap: nsAString): Longword; stdcall;
    function SetUseMap(const aUseMap: nsAString): Longword; stdcall;
    function GetVspace(out aVspace: PRInt32): Longword; stdcall;
    function SetVspace(aVspace: PRInt32): Longword; stdcall;
    function GetWidth(aWidth: nsAString): Longword; stdcall;
    function SetWidth(const aWidth: nsAString): Longword; stdcall;
    function GetContentDocument(out aContentDocument: nsIDOMDocument): Longword; stdcall;
  end;

  nsIDOMHTMLOListElement = interface(nsIDOMHTMLElement)
  ['{a6cf909a-15b3-11d2-932e-00805f8add32}']
    function GetCompact(out aCompact: PRBool): Longword; stdcall;
    function SetCompact(aCompact: PRBool): Longword; stdcall;
    function GetStart(out aStart: PRInt32): Longword; stdcall;
    function SetStart(aStart: PRInt32): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function SetType(const aType: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLOptGroupElement = interface(nsIDOMHTMLElement)
  ['{a6cf9091-15b3-11d2-932e-00805f8add32}']
    function GetDisabled(out aDisabled: PRBool): Longword; stdcall;
    function SetDisabled(aDisabled: PRBool): Longword; stdcall;
    function GetLabel(aLabel: nsAString): Longword; stdcall;
    function SetLabel(const aLabel: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLOptionElement = interface(nsIDOMHTMLElement)
  ['{a6cf9092-15b3-11d2-932e-00805f8add32}']
    function GetForm(out aForm: nsIDOMHTMLFormElement): Longword; stdcall;
    function GetDefaultSelected(out aDefaultSelected: PRBool): Longword; stdcall;
    function SetDefaultSelected(aDefaultSelected: PRBool): Longword; stdcall;
    function GetText(aText: nsAString): Longword; stdcall;
    function GetIndex(out aIndex: PRInt32): Longword; stdcall;
    function GetDisabled(out aDisabled: PRBool): Longword; stdcall;
    function SetDisabled(aDisabled: PRBool): Longword; stdcall;
    function GetLabel(aLabel: nsAString): Longword; stdcall;
    function SetLabel(const aLabel: nsAString): Longword; stdcall;
    function GetSelected(out aSelected: PRBool): Longword; stdcall;
    function SetSelected(aSelected: PRBool): Longword; stdcall;
    function GetValue(aValue: nsAString): Longword; stdcall;
    function SetValue(const aValue: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLOptionsCollection = interface(nsISupports)
  ['{bce0213c-f70f-488f-b93f-688acca55d63}']
    function GetLength(out aLength: PRUint32): Longword; stdcall;
    function SetLength(aLength: PRUint32): Longword; stdcall;
    function Item(index: PRUint32; out _retval: nsIDOMNode): nsresult; stdcall;
    function NamedItem(const name: nsAString; out _retval: nsIDOMNode): nsresult; stdcall;
  end;

  nsIDOMHTMLParagraphElement = interface(nsIDOMHTMLElement)
  ['{a6cf90a1-15b3-11d2-932e-00805f8add32}']
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLParamElement = interface(nsIDOMHTMLElement)
  ['{a6cf90ad-15b3-11d2-932e-00805f8add32}']
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function SetType(const aType: nsAString): Longword; stdcall;
    function GetValue(aValue: nsAString): Longword; stdcall;
    function SetValue(const aValue: nsAString): Longword; stdcall;
    function GetValueType(aValueType: nsAString): Longword; stdcall;
    function SetValueType(const aValueType: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLPreElement = interface(nsIDOMHTMLElement)
  ['{a6cf90a4-15b3-11d2-932e-00805f8add32}']
    function GetWidth(out aWidth: PRInt32): Longword; stdcall;
    function SetWidth(aWidth: PRInt32): Longword; stdcall;
  end;

  nsIDOMHTMLQuoteElement = interface(nsIDOMHTMLElement)
  ['{a6cf90a3-15b3-11d2-932e-00805f8add32}']
    function GetCite(aCite: nsAString): Longword; stdcall;
    function SetCite(const aCite: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLScriptElement = interface(nsIDOMHTMLElement)
  ['{a6cf90b1-15b3-11d2-932e-00805f8add32}']
    function GetText(aText: nsAString): Longword; stdcall;
    function SetText(const aText: nsAString): Longword; stdcall;
    function GetHtmlFor(aHtmlFor: nsAString): Longword; stdcall;
    function SetHtmlFor(const aHtmlFor: nsAString): Longword; stdcall;
    function GetEvent(aEvent: nsAString): Longword; stdcall;
    function SetEvent(const aEvent: nsAString): Longword; stdcall;
    function GetCharset(aCharset: nsAString): Longword; stdcall;
    function SetCharset(const aCharset: nsAString): Longword; stdcall;
    function GetDefer(out aDefer: PRBool): Longword; stdcall;
    function SetDefer(aDefer: PRBool): Longword; stdcall;
    function GetSrc(aSrc: nsAString): Longword; stdcall;
    function SetSrc(const aSrc: nsAString): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function SetType(const aType: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLSelectElement = interface(nsIDOMHTMLElement)
  ['{a6cf9090-15b3-11d2-932e-00805f8add32}']
    function GetType(aType: nsAString): Longword; stdcall;
    function GetSelectedIndex(out aSelectedIndex: PRInt32): Longword; stdcall;
    function SetSelectedIndex(aSelectedIndex: PRInt32): Longword; stdcall;
    function GetValue(aValue: nsAString): Longword; stdcall;
    function SetValue(const aValue: nsAString): Longword; stdcall;
    function GetLength(out aLength: PRUint32): Longword; stdcall;
    function SetLength(aLength: PRUint32): Longword; stdcall;
    function GetForm(out aForm: nsIDOMHTMLFormElement): Longword; stdcall;
    function GetOptions(out aOptions: nsIDOMHTMLOptionsCollection): Longword; stdcall;
    function GetDisabled(out aDisabled: PRBool): Longword; stdcall;
    function SetDisabled(aDisabled: PRBool): Longword; stdcall;
    function GetMultiple(out aMultiple: PRBool): Longword; stdcall;
    function SetMultiple(aMultiple: PRBool): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetSize(out aSize: PRInt32): Longword; stdcall;
    function SetSize(aSize: PRInt32): Longword; stdcall;
    function GetTabIndex(out aTabIndex: PRInt32): Longword; stdcall;
    function SetTabIndex(aTabIndex: PRInt32): Longword; stdcall;
    function Add(element: nsIDOMHTMLElement; before: nsIDOMHTMLElement): nsresult; stdcall;
    function Remove(index: PRInt32): nsresult; stdcall;
    function Blur(): nsresult; stdcall;
    function Focus(): nsresult; stdcall;
  end;

  nsIDOMHTMLStyleElement = interface(nsIDOMHTMLElement)
  ['{a6cf908d-15b3-11d2-932e-00805f8add32}']
    function GetDisabled(out aDisabled: PRBool): Longword; stdcall;
    function SetDisabled(aDisabled: PRBool): Longword; stdcall;
    function GetMedia(aMedia: nsAString): Longword; stdcall;
    function SetMedia(const aMedia: nsAString): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function SetType(const aType: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLTableCaptionElement = interface(nsIDOMHTMLElement)
  ['{a6cf90b3-15b3-11d2-932e-00805f8add32}']
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLTableCellElement = interface(nsIDOMHTMLElement)
  ['{a6cf90b7-15b3-11d2-932e-00805f8add32}']
    function GetCellIndex(out aCellIndex: PRInt32): Longword; stdcall;
    function GetAbbr(aAbbr: nsAString): Longword; stdcall;
    function SetAbbr(const aAbbr: nsAString): Longword; stdcall;
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetAxis(aAxis: nsAString): Longword; stdcall;
    function SetAxis(const aAxis: nsAString): Longword; stdcall;
    function GetBgColor(aBgColor: nsAString): Longword; stdcall;
    function SetBgColor(const aBgColor: nsAString): Longword; stdcall;
    function GetCh(aCh: nsAString): Longword; stdcall;
    function SetCh(const aCh: nsAString): Longword; stdcall;
    function GetChOff(aChOff: nsAString): Longword; stdcall;
    function SetChOff(const aChOff: nsAString): Longword; stdcall;
    function GetColSpan(out aColSpan: PRInt32): Longword; stdcall;
    function SetColSpan(aColSpan: PRInt32): Longword; stdcall;
    function GetHeaders(aHeaders: nsAString): Longword; stdcall;
    function SetHeaders(const aHeaders: nsAString): Longword; stdcall;
    function GetHeight(aHeight: nsAString): Longword; stdcall;
    function SetHeight(const aHeight: nsAString): Longword; stdcall;
    function GetNoWrap(out aNoWrap: PRBool): Longword; stdcall;
    function SetNoWrap(aNoWrap: PRBool): Longword; stdcall;
    function GetRowSpan(out aRowSpan: PRInt32): Longword; stdcall;
    function SetRowSpan(aRowSpan: PRInt32): Longword; stdcall;
    function GetScope(aScope: nsAString): Longword; stdcall;
    function SetScope(const aScope: nsAString): Longword; stdcall;
    function GetVAlign(aVAlign: nsAString): Longword; stdcall;
    function SetVAlign(const aVAlign: nsAString): Longword; stdcall;
    function GetWidth(aWidth: nsAString): Longword; stdcall;
    function SetWidth(const aWidth: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLTableColElement = interface(nsIDOMHTMLElement)
  ['{a6cf90b4-15b3-11d2-932e-00805f8add32}']
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetCh(aCh: nsAString): Longword; stdcall;
    function SetCh(const aCh: nsAString): Longword; stdcall;
    function GetChOff(aChOff: nsAString): Longword; stdcall;
    function SetChOff(const aChOff: nsAString): Longword; stdcall;
    function GetSpan(out aSpan: PRInt32): Longword; stdcall;
    function SetSpan(aSpan: PRInt32): Longword; stdcall;
    function GetVAlign(aVAlign: nsAString): Longword; stdcall;
    function SetVAlign(const aVAlign: nsAString): Longword; stdcall;
    function GetWidth(aWidth: nsAString): Longword; stdcall;
    function SetWidth(const aWidth: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLTableElement = interface(nsIDOMHTMLElement)
  ['{a6cf90b2-15b3-11d2-932e-00805f8add32}']
    function GetCaption(out aCaption: nsIDOMHTMLTableCaptionElement): Longword; stdcall;
    function SetCaption(aCaption: nsIDOMHTMLTableCaptionElement): Longword; stdcall;
    function GetTHead(out aTHead: nsIDOMHTMLTableSectionElement): Longword; stdcall;
    function SetTHead(aTHead: nsIDOMHTMLTableSectionElement): Longword; stdcall;
    function GetTFoot(out aTFoot: nsIDOMHTMLTableSectionElement): Longword; stdcall;
    function SetTFoot(aTFoot: nsIDOMHTMLTableSectionElement): Longword; stdcall;
    function GetRows(out aRows: nsIDOMHTMLCollection): Longword; stdcall;
    function GetTBodies(out aTBodies: nsIDOMHTMLCollection): Longword; stdcall;
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetBgColor(aBgColor: nsAString): Longword; stdcall;
    function SetBgColor(const aBgColor: nsAString): Longword; stdcall;
    function GetBorder(aBorder: nsAString): Longword; stdcall;
    function SetBorder(const aBorder: nsAString): Longword; stdcall;
    function GetCellPadding(aCellPadding: nsAString): Longword; stdcall;
    function SetCellPadding(const aCellPadding: nsAString): Longword; stdcall;
    function GetCellSpacing(aCellSpacing: nsAString): Longword; stdcall;
    function SetCellSpacing(const aCellSpacing: nsAString): Longword; stdcall;
    function GetFrame(aFrame: nsAString): Longword; stdcall;
    function SetFrame(const aFrame: nsAString): Longword; stdcall;
    function GetRules(aRules: nsAString): Longword; stdcall;
    function SetRules(const aRules: nsAString): Longword; stdcall;
    function GetSummary(aSummary: nsAString): Longword; stdcall;
    function SetSummary(const aSummary: nsAString): Longword; stdcall;
    function GetWidth(aWidth: nsAString): Longword; stdcall;
    function SetWidth(const aWidth: nsAString): Longword; stdcall;
    function CreateTHead(out _retval: nsIDOMHTMLElement): nsresult; stdcall;
    function DeleteTHead(): nsresult; stdcall;
    function CreateTFoot(out _retval: nsIDOMHTMLElement): nsresult; stdcall;
    function DeleteTFoot(): nsresult; stdcall;
    function CreateCaption(out _retval: nsIDOMHTMLElement): nsresult; stdcall;
    function DeleteCaption(): nsresult; stdcall;
    function InsertRow(index: PRInt32; out _retval: nsIDOMHTMLElement): nsresult; stdcall;
    function DeleteRow(index: PRInt32): nsresult; stdcall;
  end;

  nsIDOMHTMLTableRowElement = interface(nsIDOMHTMLElement)
  ['{a6cf90b6-15b3-11d2-932e-00805f8add32}']
    function GetRowIndex(out aRowIndex: PRInt32): Longword; stdcall;
    function GetSectionRowIndex(out aSectionRowIndex: PRInt32): Longword; stdcall;
    function GetCells(out aCells: nsIDOMHTMLCollection): Longword; stdcall;
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetBgColor(aBgColor: nsAString): Longword; stdcall;
    function SetBgColor(const aBgColor: nsAString): Longword; stdcall;
    function GetCh(aCh: nsAString): Longword; stdcall;
    function SetCh(const aCh: nsAString): Longword; stdcall;
    function GetChOff(aChOff: nsAString): Longword; stdcall;
    function SetChOff(const aChOff: nsAString): Longword; stdcall;
    function GetVAlign(aVAlign: nsAString): Longword; stdcall;
    function SetVAlign(const aVAlign: nsAString): Longword; stdcall;
    function InsertCell(index: PRInt32; out _retval: nsIDOMHTMLElement): nsresult; stdcall;
    function DeleteCell(index: PRInt32): nsresult; stdcall;
  end;

  nsIDOMHTMLTableSectionElement = interface(nsIDOMHTMLElement)
  ['{a6cf90b5-15b3-11d2-932e-00805f8add32}']
    function GetAlign(aAlign: nsAString): Longword; stdcall;
    function SetAlign(const aAlign: nsAString): Longword; stdcall;
    function GetCh(aCh: nsAString): Longword; stdcall;
    function SetCh(const aCh: nsAString): Longword; stdcall;
    function GetChOff(aChOff: nsAString): Longword; stdcall;
    function SetChOff(const aChOff: nsAString): Longword; stdcall;
    function GetVAlign(aVAlign: nsAString): Longword; stdcall;
    function SetVAlign(const aVAlign: nsAString): Longword; stdcall;
    function GetRows(out aRows: nsIDOMHTMLCollection): Longword; stdcall;
    function InsertRow(index: PRInt32; out _retval: nsIDOMHTMLElement): nsresult; stdcall;
    function DeleteRow(index: PRInt32): nsresult; stdcall;
  end;

  nsIDOMHTMLTextAreaElement = interface(nsIDOMHTMLElement)
  ['{a6cf9094-15b3-11d2-932e-00805f8add32}']
    function GetDefaultValue(aDefaultValue: nsAString): Longword; stdcall;
    function SetDefaultValue(const aDefaultValue: nsAString): Longword; stdcall;
    function GetForm(out aForm: nsIDOMHTMLFormElement): Longword; stdcall;
    function GetAccessKey(aAccessKey: nsAString): Longword; stdcall;
    function SetAccessKey(const aAccessKey: nsAString): Longword; stdcall;
    function GetCols(out aCols: PRInt32): Longword; stdcall;
    function SetCols(aCols: PRInt32): Longword; stdcall;
    function GetDisabled(out aDisabled: PRBool): Longword; stdcall;
    function SetDisabled(aDisabled: PRBool): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetReadOnly(out aReadOnly: PRBool): Longword; stdcall;
    function SetReadOnly(aReadOnly: PRBool): Longword; stdcall;
    function GetRows(out aRows: PRInt32): Longword; stdcall;
    function SetRows(aRows: PRInt32): Longword; stdcall;
    function GetTabIndex(out aTabIndex: PRInt32): Longword; stdcall;
    function SetTabIndex(aTabIndex: PRInt32): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function GetValue(aValue: nsAString): Longword; stdcall;
    function SetValue(const aValue: nsAString): Longword; stdcall;
    function Blur(): nsresult; stdcall;
    function Focus(): nsresult; stdcall;
    function Select(): nsresult; stdcall;
  end;

  nsIDOMHTMLTitleElement = interface(nsIDOMHTMLElement)
  ['{a6cf9089-15b3-11d2-932e-00805f8add32}']
    function GetText(aText: nsAString): Longword; stdcall;
    function SetText(const aText: nsAString): Longword; stdcall;
  end;

  nsIDOMHTMLUListElement = interface(nsIDOMHTMLElement)
  ['{a6cf9099-15b3-11d2-932e-00805f8add32}']
    function GetCompact(out aCompact: PRBool): Longword; stdcall;
    function SetCompact(aCompact: PRBool): Longword; stdcall;
    function GetType(aType: nsAString): Longword; stdcall;
    function SetType(const aType: nsAString): Longword; stdcall;
  end;

  nsIDOMMediaList = interface(nsISupports)
  ['{9b0c2ed7-111c-4824-adf9-ef0da6dad371}']
    function GetMediaText(aMediaText: nsAString): Longword; stdcall;
    function SetMediaText(const aMediaText: nsAString): Longword; stdcall;
    function GetLength(out aLength: PRUint32): Longword; stdcall;
    function Item(index: PRUint32; _retval: nsAString): nsresult; stdcall;
    function DeleteMedium(const oldMedium: nsAString): nsresult; stdcall;
    function AppendMedium(const newMedium: nsAString): nsresult; stdcall;
  end;

  nsIDOMUIEvent = interface(nsIDOMEvent)
  ['{a6cf90c3-15b3-11d2-932e-00805f8add32}']
    function GetView(out aView: nsIDOMAbstractView): Longword; stdcall;
    function GetDetail(out aDetail: PRInt32): Longword; stdcall;
    function InitUIEvent(const typeArg: nsAString; canBubbleArg: PRBool; cancelableArg: PRBool; viewArg: nsIDOMAbstractView; detailArg: PRInt32): nsresult; stdcall;
  end;

  nsIDOMMouseEvent = interface(nsIDOMUIEvent)
  ['{ff751edc-8b02-aae7-0010-8301838a3123}']
    function GetScreenX(out aScreenX: PRInt32): Longword; stdcall;
    function GetScreenY(out aScreenY: PRInt32): Longword; stdcall;
    function GetClientX(out aClientX: PRInt32): Longword; stdcall;
    function GetClientY(out aClientY: PRInt32): Longword; stdcall;
    function GetCtrlKey(out aCtrlKey: PRBool): Longword; stdcall;
    function GetShiftKey(out aShiftKey: PRBool): Longword; stdcall;
    function GetAltKey(out aAltKey: PRBool): Longword; stdcall;
    function GetMetaKey(out aMetaKey: PRBool): Longword; stdcall;
    function GetButton(out aButton: PRUint16): Longword; stdcall;
    function GetRelatedTarget(out aRelatedTarget: nsIDOMEventTarget): Longword; stdcall;
    function InitMouseEvent(const typeArg: nsAString; canBubbleArg: PRBool; cancelableArg: PRBool; viewArg: nsIDOMAbstractView; detailArg: PRInt32; screenXArg: PRInt32; screenYArg: PRInt32; clientXArg: PRInt32; clientYArg: PRInt32; ctrlKeyArg: PRBool; altKeyArg: PRBool; shiftKeyArg: PRBool; metaKeyArg: PRBool; buttonArg: PRUint16; relatedTargetArg: nsIDOMEventTarget): nsresult; stdcall;
  end;

  nsIDOMNamedNodeMap = interface(nsISupports)
  ['{a6cf907b-15b3-11d2-932e-00805f8add32}']
    function GetNamedItem(const name: nsAString; out _retval: nsIDOMNode): nsresult; stdcall;
    function SetNamedItem(arg: nsIDOMNode; out _retval: nsIDOMNode): nsresult; stdcall;
    function RemoveNamedItem(const name: nsAString; out _retval: nsIDOMNode): nsresult; stdcall;
    function Item(index: PRUint32; out _retval: nsIDOMNode): nsresult; stdcall;
    function GetLength(out aLength: PRUint32): Longword; stdcall;
    function GetNamedItemNS(const namespaceURI: nsAString; const localName: nsAString; out _retval: nsIDOMNode): nsresult; stdcall;
    function SetNamedItemNS(arg: nsIDOMNode; out _retval: nsIDOMNode): nsresult; stdcall;
    function RemoveNamedItemNS(const namespaceURI: nsAString; const localName: nsAString; out _retval: nsIDOMNode): nsresult; stdcall;
  end;

  nsIDOMNodeList = interface(nsISupports)
  ['{a6cf907d-15b3-11d2-932e-00805f8add32}']
    function Item(index: PRUint32; out _retval: nsIDOMNode): nsresult; stdcall;
    function GetLength(out aLength: PRUint32): Longword; stdcall;
  end;

  nsIDOMNotation = interface(nsIDOMNode)
  ['{a6cf907e-15b3-11d2-932e-00805f8add32}']
    function GetPublicId(aPublicId: nsAString): Longword; stdcall;
    function GetSystemId(aSystemId: nsAString): Longword; stdcall;
  end;

  nsIDOMProcessingInstruction = interface(nsIDOMNode)
  ['{a6cf907f-15b3-11d2-932e-00805f8add32}']
    function GetTarget(aTarget: nsAString): Longword; stdcall;
    function GetData(aData: nsAString): Longword; stdcall;
    function SetData(const aData: nsAString): Longword; stdcall;
  end;

  nsIDOMRange = interface(nsISupports)
  ['{a6cf90ce-15b3-11d2-932e-00805f8add32}']
    function GetStartContainer(out aStartContainer: nsIDOMNode): Longword; stdcall;
    function GetStartOffset(out aStartOffset: PRInt32): Longword; stdcall;
    function GetEndContainer(out aEndContainer: nsIDOMNode): Longword; stdcall;
    function GetEndOffset(out aEndOffset: PRInt32): Longword; stdcall;
    function GetCollapsed(out aCollapsed: PRBool): Longword; stdcall;
    function GetCommonAncestorContainer(out aCommonAncestorContainer: nsIDOMNode): Longword; stdcall;
    function SetStart(refNode: nsIDOMNode; offset: PRInt32): nsresult; stdcall;
    function SetEnd(refNode: nsIDOMNode; offset: PRInt32): nsresult; stdcall;
    function SetStartBefore(refNode: nsIDOMNode): nsresult; stdcall;
    function SetStartAfter(refNode: nsIDOMNode): nsresult; stdcall;
    function SetEndBefore(refNode: nsIDOMNode): nsresult; stdcall;
    function SetEndAfter(refNode: nsIDOMNode): nsresult; stdcall;
    function Collapse(toStart: PRBool): nsresult; stdcall;
    function SelectNode(refNode: nsIDOMNode): nsresult; stdcall;
    function SelectNodeContents(refNode: nsIDOMNode): nsresult; stdcall;
    function CompareBoundaryPoints(how: PRUint16; sourceRange: nsIDOMRange; out _retval: PRInt16): nsresult; stdcall;
    function DeleteContents(): nsresult; stdcall;
    function ExtractContents(out _retval: nsIDOMDocumentFragment): nsresult; stdcall;
    function CloneContents(out _retval: nsIDOMDocumentFragment): nsresult; stdcall;
    function InsertNode(newNode: nsIDOMNode): nsresult; stdcall;
    function SurroundContents(newParent: nsIDOMNode): nsresult; stdcall;
    function CloneRange(out _retval: nsIDOMRange): nsresult; stdcall;
    function ToString(_retval: nsAString): nsresult; stdcall;
    function Detach(): nsresult; stdcall;
  end;

  nsIDOMStyleSheetList = interface(nsISupports)
  ['{a6cf9081-15b3-11d2-932e-00805f8add32}']
    function GetLength(out aLength: PRUint32): Longword; stdcall;
    function Item(index: PRUint32; out _retval: nsIDOMStyleSheet): nsresult; stdcall;
  end;

  nsIDOMWindow = interface(nsISupports)
  ['{a6cf906b-15b3-11d2-932e-00805f8add32}']
    function GetDocument(out aDocument: nsIDOMDocument): Longword; stdcall;
    function GetParent(out aParent: nsIDOMWindow): Longword; stdcall;
    function GetTop(out aTop: nsIDOMWindow): Longword; stdcall;
    function GetScrollbars(out aScrollbars: nsIDOMBarProp): Longword; stdcall;
    function GetFrames(out aFrames: nsIDOMWindowCollection): Longword; stdcall;
    function GetName(aName: nsAString): Longword; stdcall;
    function SetName(const aName: nsAString): Longword; stdcall;
    function GetTextZoom(out aTextZoom: Single): Longword; stdcall;
    function SetTextZoom(aTextZoom: Single): Longword; stdcall;
    function GetScrollX(out aScrollX: PRInt32): Longword; stdcall;
    function GetScrollY(out aScrollY: PRInt32): Longword; stdcall;
    function ScrollTo(xScroll: PRInt32; yScroll: PRInt32): nsresult; stdcall;
    function ScrollBy(xScrollDif: PRInt32; yScrollDif: PRInt32): nsresult; stdcall;
    function GetSelection(out _retval: nsISelection): nsresult; stdcall;
    function ScrollByLines(numLines: PRInt32): nsresult; stdcall;
    function ScrollByPages(numPages: PRInt32): nsresult; stdcall;
    function SizeToContent(): nsresult; stdcall;
  end;

  nsIDOMWindow2 = interface(nsIDOMWindow)
  ['{65455132-b96a-40ec-adea-52fa22b1028c}']
    function GetWindowRoot(out aWindowRoot: nsIDOMEventTarget): Longword; stdcall;
  end;

  nsIDOMWindowCollection = interface(nsISupports)
  ['{a6cf906f-15b3-11d2-932e-00805f8add32}']
    function GetLength(out aLength: PRUint32): Longword; stdcall;
    function Item(index: PRUint32; out _retval: nsIDOMWindow): nsresult; stdcall;
    function NamedItem(const name: nsAString; out _retval: nsIDOMWindow): nsresult; stdcall;
  end;

  nsIEmbeddingSiteWindow = interface(nsISupports)
  ['{3e5432cd-9568-4bd1-8cbe-d50aba110743}']
    function SetDimensions(flags: PRUint32; x: PRInt32; y: PRInt32; cx: PRInt32; cy: PRInt32): nsresult; stdcall;
    function GetDimensions(flags: PRUint32; out x: PRInt32; out y: PRInt32; out cx: PRInt32; out cy: PRInt32): nsresult; stdcall;
    function SetFocus(): nsresult; stdcall;
    function GetVisibility(out aVisibility: PRBool): Longword; stdcall;
    function SetVisibility(aVisibility: PRBool): Longword; stdcall;
    function GetTitle(out aTitle: PWideChar): Longword; stdcall;
    function SetTitle(const aTitle: PWideChar): Longword; stdcall;
    function GetSiteWindow(out aSiteWindow: Pointer): Longword; stdcall;
  end;

  nsIFactory = interface(nsISupports)
  ['{00000001-0000-0000-c000-000000000046}']
    function CreateInstance(aOuter: nsISupports; const iid: TGUID; out _result): nsresult; stdcall;
    function LockFactory(lock: PRBool): nsresult; stdcall;
  end;

  nsIURI = interface(nsISupports)
  ['{07a22cc0-0ce5-11d3-9331-00104ba0fd40}']
    function GetSpec(aSpec: nsACString): Longword; stdcall;
    function SetSpec(const aSpec: nsACString): Longword; stdcall;
    function GetPrePath(aPrePath: nsACString): Longword; stdcall;
    function GetScheme(aScheme: nsACString): Longword; stdcall;
    function SetScheme(const aScheme: nsACString): Longword; stdcall;
    function GetUserPass(aUserPass: nsACString): Longword; stdcall;
    function SetUserPass(const aUserPass: nsACString): Longword; stdcall;
    function GetUsername(aUsername: nsACString): Longword; stdcall;
    function SetUsername(const aUsername: nsACString): Longword; stdcall;
    function GetPassword(aPassword: nsACString): Longword; stdcall;
    function SetPassword(const aPassword: nsACString): Longword; stdcall;
    function GetHostPort(aHostPort: nsACString): Longword; stdcall;
    function SetHostPort(const aHostPort: nsACString): Longword; stdcall;
    function GetHost(aHost: nsACString): Longword; stdcall;
    function SetHost(const aHost: nsACString): Longword; stdcall;
    function GetPort(out aPort: PRInt32): Longword; stdcall;
    function SetPort(aPort: PRInt32): Longword; stdcall;
    function GetPath(aPath: nsACString): Longword; stdcall;
    function SetPath(const aPath: nsACString): Longword; stdcall;
    function Equals(other: nsIURI; out _retval: PRBool): nsresult; stdcall;
    function SchemeIs(const scheme: PAnsiChar; out _retval: PRBool): nsresult; stdcall;
    function Clone(out _retval: nsIURI): nsresult; stdcall;
    function Resolve(const relativePath: nsACString; _retval: nsACString): nsresult; stdcall;
    function GetAsciiSpec(aAsciiSpec: nsACString): Longword; stdcall;
    function GetAsciiHost(aAsciiHost: nsACString): Longword; stdcall;
    function GetOriginCharset(aOriginCharset: nsACString): Longword; stdcall;
  end;

  nsIURL = interface(nsIURI)
  ['{d6116970-8034-11d3-9399-00104ba0fd40}']
    function GetFilePath(aFilePath: nsACString): Longword; stdcall;
    function SetFilePath(const aFilePath: nsACString): Longword; stdcall;
    function GetParam(aParam: nsACString): Longword; stdcall;
    function SetParam(const aParam: nsACString): Longword; stdcall;
    function GetQuery(aQuery: nsACString): Longword; stdcall;
    function SetQuery(const aQuery: nsACString): Longword; stdcall;
    function GetRef(aRef: nsACString): Longword; stdcall;
    function SetRef(const aRef: nsACString): Longword; stdcall;
    function GetDirectory(aDirectory: nsACString): Longword; stdcall;
    function SetDirectory(const aDirectory: nsACString): Longword; stdcall;
    function GetFileName(aFileName: nsACString): Longword; stdcall;
    function SetFileName(const aFileName: nsACString): Longword; stdcall;
    function GetFileBaseName(aFileBaseName: nsACString): Longword; stdcall;
    function SetFileBaseName(const aFileBaseName: nsACString): Longword; stdcall;
    function GetFileExtension(aFileExtension: nsACString): Longword; stdcall;
    function SetFileExtension(const aFileExtension: nsACString): Longword; stdcall;
    function GetCommonBaseSpec(aURIToCompare: nsIURI; _retval: nsACString): nsresult; stdcall;
    function GetRelativeSpec(aURIToCompare: nsIURI; _retval: nsACString): nsresult; stdcall;
  end;

  nsIFileURL = interface(nsIURL)
  ['{d26b2e2e-1dd1-11b2-88f3-8545a7ba7949}']
    function GetFile(out aFile: nsIFile): Longword; stdcall;
    function SetFile(aFile: nsIFile): Longword; stdcall;
  end;

  nsIGlobalHistory = interface(nsISupports)
  ['{9491c383-e3c4-11d2-bdbe-0050040a9b44}']
    function AddPage(const aURL: PAnsiChar): nsresult; stdcall;
    function IsVisited(const aURL: PAnsiChar; out _retval: PRBool): nsresult; stdcall;
  end;

  nsIHistoryEntry = interface(nsISupports)
  ['{a41661d4-1417-11d5-9882-00c04fa02f40}']
    function GetURI(out aURI: nsIURI): Longword; stdcall;
    function GetTitle(out aTitle: PWideChar): Longword; stdcall;
    function GetIsSubFrame(out aIsSubFrame: PRBool): Longword; stdcall;
  end;

  nsIHttpChannel = interface(nsIChannel)
  ['{9277fe09-f0cc-4cd9-bbce-581dd94b0260}']
    function GetRequestMethod(aRequestMethod: nsACString): Longword; stdcall;
    function SetRequestMethod(const aRequestMethod: nsACString): Longword; stdcall;
    function GetReferrer(out aReferrer: nsIURI): Longword; stdcall;
    function SetReferrer(aReferrer: nsIURI): Longword; stdcall;
    function GetRequestHeader(const aHeader: nsACString; _retval: nsACString): nsresult; stdcall;
    function SetRequestHeader(const aHeader: nsACString; const aValue: nsACString; aMerge: PRBool): nsresult; stdcall;
    function VisitRequestHeaders(aVisitor: nsIHttpHeaderVisitor): nsresult; stdcall;
    function GetAllowPipelining(out aAllowPipelining: PRBool): Longword; stdcall;
    function SetAllowPipelining(aAllowPipelining: PRBool): Longword; stdcall;
    function GetRedirectionLimit(out aRedirectionLimit: PRUint32): Longword; stdcall;
    function SetRedirectionLimit(aRedirectionLimit: PRUint32): Longword; stdcall;
    function GetResponseStatus(out aResponseStatus: PRUint32): Longword; stdcall;
    function GetResponseStatusText(aResponseStatusText: nsACString): Longword; stdcall;
    function GetRequestSucceeded(out aRequestSucceeded: PRBool): Longword; stdcall;
    function GetResponseHeader(const header: nsACString; _retval: nsACString): nsresult; stdcall;
    function SetResponseHeader(const header: nsACString; const value: nsACString; merge: PRBool): nsresult; stdcall;
    function VisitResponseHeaders(aVisitor: nsIHttpHeaderVisitor): nsresult; stdcall;
    function IsNoStoreResponse(out _retval: PRBool): nsresult; stdcall;
    function IsNoCacheResponse(out _retval: PRBool): nsresult; stdcall;
  end;

  nsIHttpHeaderVisitor = interface(nsISupports)
  ['{0cf40717-d7c1-4a94-8c1e-d6c9734101bb}']
    function VisitHeader(const aHeader: nsACString; const aValue: nsACString): nsresult; stdcall;
  end;

  nsWriteSegmentFun = function (aInStream: nsIInputStream; 
                                aClosure: Pointer;
                                const aFromSegment: Pointer;
                                aToOffset: PRUint32;
                                aCount: PRUint32;
                                out aWriteCount: PRUint32): nsresult; stdcall;
  nsIInputStream = interface(nsISupports)
  ['{fa9c7f6c-61b3-11d4-9877-00c04fa0cf4a}']
    function Close(): nsresult; stdcall;
    function Available(out _retval: PRUint32): nsresult; stdcall;
    function Read(aBuf: PAnsiChar; aCount: PRUint32; out _retval: PRUint32): nsresult; stdcall;
    function ReadSegments(aWriter: nsWriteSegmentFun; aClosure: Pointer; aCount: PRUint32; out _retval: PRUint32): nsresult; stdcall;
    function IsNonBlocking(out _retval: PRBool): nsresult; stdcall;
  end;

  nsIInterfaceRequestor = interface(nsISupports)
  ['{033a1470-8b2a-11d3-af88-00a024ffc08c}']
    function GetInterface(const uuid: TGUID; out _result): nsresult; stdcall;
  end;

  nsIIOService = interface(nsISupports)
  ['{bddeda3f-9020-4d12-8c70-984ee9f7935e}']
    function GetProtocolHandler(const aScheme: PAnsiChar; out _retval: nsIProtocolHandler): nsresult; stdcall;
    function GetProtocolFlags(const aScheme: PAnsiChar; out _retval: PRUint32): nsresult; stdcall;
    function NewURI(const aSpec: nsACString; const aOriginCharset: PAnsiChar; aBaseURI: nsIURI; out _retval: nsIURI): nsresult; stdcall;
    function NewFileURI(aFile: nsIFile; out _retval: nsIURI): nsresult; stdcall;
    function NewChannelFromURI(aURI: nsIURI; out _retval: nsIChannel): nsresult; stdcall;
    function NewChannel(const aSpec: nsACString; const aOriginCharset: PAnsiChar; aBaseURI: nsIURI; out _retval: nsIChannel): nsresult; stdcall;
    function GetOffline(out aOffline: PRBool): Longword; stdcall;
    function SetOffline(aOffline: PRBool): Longword; stdcall;
    function AllowPort(aPort: PRInt32; const aScheme: PAnsiChar; out _retval: PRBool): nsresult; stdcall;
    function ExtractScheme(const urlString: nsACString; _retval: nsACString): nsresult; stdcall;
  end;

  nsILoadGroup = interface(nsIRequest)
  ['{3de0a31c-feaf-400f-9f1e-4ef71f8b20cc}']
    function GetGroupObserver(out aGroupObserver: nsIRequestObserver): Longword; stdcall;
    function SetGroupObserver(aGroupObserver: nsIRequestObserver): Longword; stdcall;
    function GetDefaultLoadRequest(out aDefaultLoadRequest: nsIRequest): Longword; stdcall;
    function SetDefaultLoadRequest(aDefaultLoadRequest: nsIRequest): Longword; stdcall;
    function AddRequest(aRequest: nsIRequest; aContext: nsISupports): nsresult; stdcall;
    function RemoveRequest(aRequest: nsIRequest; aContext: nsISupports; aStatus: nsresult): nsresult; stdcall;
    function GetRequests(out aRequests: nsISimpleEnumerator): Longword; stdcall;
    function GetActiveCount(out aActiveCount: PRUint32): Longword; stdcall;
    function GetNotificationCallbacks(out aNotificationCallbacks: nsIInterfaceRequestor): Longword; stdcall;
    function SetNotificationCallbacks(aNotificationCallbacks: nsIInterfaceRequestor): Longword; stdcall;
  end;

  nsILocalFile = interface(nsIFile)
  ['{aa610f20-a889-11d3-8c81-000064657374}']
    function InitWithPath(const filePath: nsAString): nsresult; stdcall;
    function InitWithNativePath(const filePath: nsACString): nsresult; stdcall;
    function InitWithFile(aFile: nsILocalFile): nsresult; stdcall;
    function GetFollowLinks(out aFollowLinks: PRBool): Longword; stdcall;
    function SetFollowLinks(aFollowLinks: PRBool): Longword; stdcall;
    function OpenNSPRFileDesc(flags: PRInt32; mode: PRInt32; out _retval: PPRFileDesc): nsresult; stdcall;
    function OpenANSIFileDesc(const mode: PAnsiChar; out _retval: PFILE): nsresult; stdcall;
    function Load(out _retval: PPRLibrary): nsresult; stdcall;
    function GetDiskSpaceAvailable(out aDiskSpaceAvailable: PRInt64): Longword; stdcall;
    function AppendRelativePath(const relativeFilePath: nsAString): nsresult; stdcall;
    function AppendRelativeNativePath(const relativeFilePath: nsACString): nsresult; stdcall;
    function GetPersistentDescriptor(aPersistentDescriptor: nsACString): Longword; stdcall;
    function SetPersistentDescriptor(const aPersistentDescriptor: nsACString): Longword; stdcall;
    function Reveal(): nsresult; stdcall;
    function Launch(): nsresult; stdcall;
    function GetRelativeDescriptor(fromFile: nsILocalFile; _retval: nsACString): nsresult; stdcall;
    function SetRelativeDescriptor(fromFile: nsILocalFile; const relativeDesc: nsACString): nsresult; stdcall;
  end;

  nsIMemory = interface(nsISupports)
  ['{59e7e77a-38e4-11d4-8cf5-0060b0fc14a3}']
    function Alloc(size: size_t): Pointer; stdcall;
    function Realloc(ptr: Pointer; newSize: size_t): Pointer; stdcall;
    procedure Free(ptr: Pointer); stdcall;
    function HeapMinimize(immediate: PRBool): nsresult; stdcall;
    function IsLowMemory(out _retval: PRBool): nsresult; stdcall;
  end;

  nsIModule = interface(nsISupports)
  ['{7392d032-5371-11d3-994e-00805fd26fee}']
    function GetClassObject(aCompMgr: nsIComponentManager; const aClass: TGUID; const aIID: TGUID; out aResult): nsresult; stdcall;
    function RegisterSelf(aCompMgr: nsIComponentManager; aLocation: nsIFile; const aLoaderStr: PAnsiChar; const aType: PAnsiChar): nsresult; stdcall;
    function UnregisterSelf(aCompMgr: nsIComponentManager; aLocation: nsIFile; const aLoaderStr: PAnsiChar): nsresult; stdcall;
    function CanUnload(aCompMgr: nsIComponentManager; out _retval: PRBool): nsresult; stdcall;
  end;

  nsIObserver = interface(nsISupports)
  ['{db242e01-e4d9-11d2-9dde-000064657374}']
    function Observe(aSubject: nsISupports; const aTopic: PAnsiChar; const aData: PWideChar): nsresult; stdcall;
  end;

  nsIObserverService = interface(nsISupports)
  ['{d07f5192-e3d1-11d2-8acd-00105a1b8860}']
    function AddObserver(anObserver: nsIObserver; const aTopic: PAnsiChar; ownsWeak: PRBool): nsresult; stdcall;
    function RemoveObserver(anObserver: nsIObserver; const aTopic: PAnsiChar): nsresult; stdcall;
    function NotifyObservers(aSubject: nsISupports; const aTopic: PAnsiChar; const someData: PWideChar): nsresult; stdcall;
    function EnumerateObservers(const aTopic: PAnsiChar; out _retval: nsISimpleEnumerator): nsresult; stdcall;
  end;

  nsReadSegmentFun = function (aOutStream: nsIOutputStream;
                               aClosure: Pointer;
                               aToSegment: Pointer;
                               aFromOffset: PRUint32;
                               aCount: PRUint32;
                               out aReadCount: PRUint32): nsresult; stdcall;
  nsIOutputStream = interface(nsISupports)
  ['{0d0acd2a-61b4-11d4-9877-00c04fa0cf4a}']
    function Close(): nsresult; stdcall;
    function Flush(): nsresult; stdcall;
    function Write(const aBuf: PAnsiChar; aCount: PRUint32; out _retval: PRUint32): nsresult; stdcall;
    function WriteFrom(aFromStream: nsIInputStream; aCount: PRUint32; out _retval: PRUint32): nsresult; stdcall;
    function WriteSegments(aReader: nsReadSegmentFun; aClosure: Pointer; aCount: PRUint32; out _retval: PRUint32): nsresult; stdcall;
    function IsNonBlocking(out _retval: PRBool): nsresult; stdcall;
  end;

  nsIPassword = interface(nsISupports)
  ['{cf39c2b0-1e4b-11d5-a549-0010a401eb10}']
    function GetHost(aHost: nsACString): Longword; stdcall;
    function GetUser(aUser: nsAString): Longword; stdcall;
    function GetPassword(aPassword: nsAString): Longword; stdcall;
  end;

  nsIPrefBranch = interface(nsISupports)
  ['{56c35506-f14b-11d3-99d3-ddbfac2ccf65}']
    function GetRoot(out aRoot: PAnsiChar): Longword; stdcall;
    function GetPrefType(const aPrefName: PAnsiChar; out _retval: PRInt32): nsresult; stdcall;
    function GetBoolPref(const aPrefName: PAnsiChar; out _retval: PRBool): nsresult; stdcall;
    function SetBoolPref(const aPrefName: PAnsiChar; aValue: PRInt32): nsresult; stdcall;
    function GetCharPref(const aPrefName: PAnsiChar; out _retval: PAnsiChar): nsresult; stdcall;
    function SetCharPref(const aPrefName: PAnsiChar; const aValue: PAnsiChar): nsresult; stdcall;
    function GetIntPref(const aPrefName: PAnsiChar; out _retval: PRInt32): nsresult; stdcall;
    function SetIntPref(const aPrefName: PAnsiChar; aValue: PRInt32): nsresult; stdcall;
    function GetComplexValue(const aPrefName: PAnsiChar; const aType: TGUID; out aValue): nsresult; stdcall;
    function SetComplexValue(const aPrefName: PAnsiChar; const aType: TGUID; aValue: nsISupports): nsresult; stdcall;
    function ClearUserPref(const aPrefName: PAnsiChar): nsresult; stdcall;
    function LockPref(const aPrefName: PAnsiChar): nsresult; stdcall;
    function PrefHasUserValue(const aPrefName: PAnsiChar; out _retval: PRBool): nsresult; stdcall;
    function PrefIsLocked(const aPrefName: PAnsiChar; out _retval: PRBool): nsresult; stdcall;
    function UnlockPref(const aPrefName: PAnsiChar): nsresult; stdcall;
    function DeleteBranch(const aStartingAt: PAnsiChar): nsresult; stdcall;
    function GetChildList(const aStartingAt: PAnsiChar; out aCount: PRUint32; out aChildArray: PPAnsiCharArray): nsresult; stdcall;
    function ResetBranch(const aStartingAt: PAnsiChar): nsresult; stdcall;
  end;

  nsIPrefLocalizedString = interface(nsISupports)
  ['{ae419e24-1dd1-11b2-b39a-d3e5e7073802}']
    function GetData(out aData: PWideChar): Longword; stdcall;
    function SetData(const aData: PWideChar): Longword; stdcall;
    function ToString(out _retval: PWideChar): nsresult; stdcall;
    function SetDataWithLength(length: PRUint32; const data: PWideChar): nsresult; stdcall;
  end;

  nsIPrefService = interface(nsISupports)
  ['{decb9cc7-c08f-4ea5-be91-a8fc637ce2d2}']
    function ReadUserPrefs(aFile: nsIFile): nsresult; stdcall;
    function ResetPrefs(): nsresult; stdcall;
    function ResetUserPrefs(): nsresult; stdcall;
    function SavePrefFile(aFile: nsIFile): nsresult; stdcall;
    function GetBranch(const aPrefRoot: PAnsiChar; out _retval: nsIPrefBranch): nsresult; stdcall;
    function GetDefaultBranch(const aPrefRoot: PAnsiChar; out _retval: nsIPrefBranch): nsresult; stdcall;
  end;

  nsIPrintSettings = interface(nsISupports)
  ['{83427530-f790-11d4-a869-00105a183419}']
    function SetPrintOptions(aType: PRInt32; aTurnOnOff: PRBool): nsresult; stdcall;
    function GetPrintOptions(aType: PRInt32; out _retval: PRBool): nsresult; stdcall;
    function GetPrintOptionsBits(out _retval: PRInt32): nsresult; stdcall;
    function GetPageSizeInTwips(out aWidth: PRInt32; out aHeight: PRInt32): nsresult; stdcall;
    function Clone(out _retval: nsIPrintSettings): nsresult; stdcall;
    function Assign(aPS: nsIPrintSettings): nsresult; stdcall;
    function GetPrintSession(out aPrintSession: nsIPrintSession): Longword; stdcall;
    function SetPrintSession(aPrintSession: nsIPrintSession): Longword; stdcall;
    function GetStartPageRange(out aStartPageRange: PRInt32): Longword; stdcall;
    function SetStartPageRange(aStartPageRange: PRInt32): Longword; stdcall;
    function GetEndPageRange(out aEndPageRange: PRInt32): Longword; stdcall;
    function SetEndPageRange(aEndPageRange: PRInt32): Longword; stdcall;
    function GetMarginTop(out aMarginTop: Double): Longword; stdcall;
    function SetMarginTop(aMarginTop: Double): Longword; stdcall;
    function GetMarginLeft(out aMarginLeft: Double): Longword; stdcall;
    function SetMarginLeft(aMarginLeft: Double): Longword; stdcall;
    function GetMarginBottom(out aMarginBottom: Double): Longword; stdcall;
    function SetMarginBottom(aMarginBottom: Double): Longword; stdcall;
    function GetMarginRight(out aMarginRight: Double): Longword; stdcall;
    function SetMarginRight(aMarginRight: Double): Longword; stdcall;
    function GetScaling(out aScaling: Double): Longword; stdcall;
    function SetScaling(aScaling: Double): Longword; stdcall;
    function GetPrintBGColors(out aPrintBGColors: PRBool): Longword; stdcall;
    function SetPrintBGColors(aPrintBGColors: PRBool): Longword; stdcall;
    function GetPrintBGImages(out aPrintBGImages: PRBool): Longword; stdcall;
    function SetPrintBGImages(aPrintBGImages: PRBool): Longword; stdcall;
    function GetPrintRange(out aPrintRange: PRInt16): Longword; stdcall;
    function SetPrintRange(aPrintRange: PRInt16): Longword; stdcall;
    function GetTitle(out aTitle: PWideChar): Longword; stdcall;
    function SetTitle(const aTitle: PWideChar): Longword; stdcall;
    function GetDocURL(out aDocURL: PWideChar): Longword; stdcall;
    function SetDocURL(const aDocURL: PWideChar): Longword; stdcall;
    function GetHeaderStrLeft(out aHeaderStrLeft: PWideChar): Longword; stdcall;
    function SetHeaderStrLeft(const aHeaderStrLeft: PWideChar): Longword; stdcall;
    function GetHeaderStrCenter(out aHeaderStrCenter: PWideChar): Longword; stdcall;
    function SetHeaderStrCenter(const aHeaderStrCenter: PWideChar): Longword; stdcall;
    function GetHeaderStrRight(out aHeaderStrRight: PWideChar): Longword; stdcall;
    function SetHeaderStrRight(const aHeaderStrRight: PWideChar): Longword; stdcall;
    function GetFooterStrLeft(out aFooterStrLeft: PWideChar): Longword; stdcall;
    function SetFooterStrLeft(const aFooterStrLeft: PWideChar): Longword; stdcall;
    function GetFooterStrCenter(out aFooterStrCenter: PWideChar): Longword; stdcall;
    function SetFooterStrCenter(const aFooterStrCenter: PWideChar): Longword; stdcall;
    function GetFooterStrRight(out aFooterStrRight: PWideChar): Longword; stdcall;
    function SetFooterStrRight(const aFooterStrRight: PWideChar): Longword; stdcall;
    function GetHowToEnableFrameUI(out aHowToEnableFrameUI: PRInt16): Longword; stdcall;
    function SetHowToEnableFrameUI(aHowToEnableFrameUI: PRInt16): Longword; stdcall;
    function GetIsCancelled(out aIsCancelled: PRBool): Longword; stdcall;
    function SetIsCancelled(aIsCancelled: PRBool): Longword; stdcall;
    function GetPrintFrameTypeUsage(out aPrintFrameTypeUsage: PRInt16): Longword; stdcall;
    function SetPrintFrameTypeUsage(aPrintFrameTypeUsage: PRInt16): Longword; stdcall;
    function GetPrintFrameType(out aPrintFrameType: PRInt16): Longword; stdcall;
    function SetPrintFrameType(aPrintFrameType: PRInt16): Longword; stdcall;
    function GetPrintSilent(out aPrintSilent: PRBool): Longword; stdcall;
    function SetPrintSilent(aPrintSilent: PRBool): Longword; stdcall;
    function GetShrinkToFit(out aShrinkToFit: PRBool): Longword; stdcall;
    function SetShrinkToFit(aShrinkToFit: PRBool): Longword; stdcall;
    function GetShowPrintProgress(out aShowPrintProgress: PRBool): Longword; stdcall;
    function SetShowPrintProgress(aShowPrintProgress: PRBool): Longword; stdcall;
    function GetPaperName(out aPaperName: PWideChar): Longword; stdcall;
    function SetPaperName(const aPaperName: PWideChar): Longword; stdcall;
    function GetPaperSizeType(out aPaperSizeType: PRInt16): Longword; stdcall;
    function SetPaperSizeType(aPaperSizeType: PRInt16): Longword; stdcall;
    function GetPaperData(out aPaperData: PRInt16): Longword; stdcall;
    function SetPaperData(aPaperData: PRInt16): Longword; stdcall;
    function GetPaperWidth(out aPaperWidth: Double): Longword; stdcall;
    function SetPaperWidth(aPaperWidth: Double): Longword; stdcall;
    function GetPaperHeight(out aPaperHeight: Double): Longword; stdcall;
    function SetPaperHeight(aPaperHeight: Double): Longword; stdcall;
    function GetPaperSizeUnit(out aPaperSizeUnit: PRInt16): Longword; stdcall;
    function SetPaperSizeUnit(aPaperSizeUnit: PRInt16): Longword; stdcall;
    function GetPlexName(out aPlexName: PWideChar): Longword; stdcall;
    function SetPlexName(const aPlexName: PWideChar): Longword; stdcall;
    function GetPrintReversed(out aPrintReversed: PRBool): Longword; stdcall;
    function SetPrintReversed(aPrintReversed: PRBool): Longword; stdcall;
    function GetPrintInColor(out aPrintInColor: PRBool): Longword; stdcall;
    function SetPrintInColor(aPrintInColor: PRBool): Longword; stdcall;
    function GetPaperSize(out aPaperSize: PRInt32): Longword; stdcall;
    function SetPaperSize(aPaperSize: PRInt32): Longword; stdcall;
    function GetOrientation(out aOrientation: PRInt32): Longword; stdcall;
    function SetOrientation(aOrientation: PRInt32): Longword; stdcall;
    function GetPrintCommand(out aPrintCommand: PWideChar): Longword; stdcall;
    function SetPrintCommand(const aPrintCommand: PWideChar): Longword; stdcall;
    function GetNumCopies(out aNumCopies: PRInt32): Longword; stdcall;
    function SetNumCopies(aNumCopies: PRInt32): Longword; stdcall;
    function GetPrinterName(out aPrinterName: PWideChar): Longword; stdcall;
    function SetPrinterName(const aPrinterName: PWideChar): Longword; stdcall;
    function GetPrintToFile(out aPrintToFile: PRBool): Longword; stdcall;
    function SetPrintToFile(aPrintToFile: PRBool): Longword; stdcall;
    function GetToFileName(out aToFileName: PWideChar): Longword; stdcall;
    function SetToFileName(const aToFileName: PWideChar): Longword; stdcall;
    function GetPrintPageDelay(out aPrintPageDelay: PRInt32): Longword; stdcall;
    function SetPrintPageDelay(aPrintPageDelay: PRInt32): Longword; stdcall;
    function GetIsInitializedFromPrinter(out aIsInitializedFromPrinter: PRBool): Longword; stdcall;
    function SetIsInitializedFromPrinter(aIsInitializedFromPrinter: PRBool): Longword; stdcall;
    function GetIsInitializedFromPrefs(out aIsInitializedFromPrefs: PRBool): Longword; stdcall;
    function SetIsInitializedFromPrefs(aIsInitializedFromPrefs: PRBool): Longword; stdcall;
    function SetMarginInTwips(var aMargin: nsMargin): nsresult; stdcall;
    function GetMarginInTwips(var aMargin: nsMargin): nsresult; stdcall;
  end;

  nsIProfile = interface(nsISupports)
  ['{02b0625a-e7f3-11d2-9f5a-006008a6efe9}']
    function GetProfileCount(out aProfileCount: PRInt32): Longword; stdcall;
    function GetProfileList(out length: PRUint32; out profileNames: PPWideCharArray): nsresult; stdcall;
    function ProfileExists(const profileName: PWideChar; out _retval: PRBool): nsresult; stdcall;
    function GetCurrentProfile(out aCurrentProfile: PWideChar): Longword; stdcall;
    function SetCurrentProfile(const aCurrentProfile: PWideChar): Longword; stdcall;
    function ShutDownCurrentProfile(shutDownType: PRUint32): nsresult; stdcall;
    function CreateNewProfile(const profileName: PWideChar; const nativeProfileDir: PWideChar; const langcode: PWideChar; useExistingDir: PRBool): nsresult; stdcall;
    function RenameProfile(const oldName: PWideChar; const newName: PWideChar): nsresult; stdcall;
    function DeleteProfile(const name: PWideChar; canDeleteFiles: PRBool): nsresult; stdcall;
    function CloneProfile(const profileName: PWideChar): nsresult; stdcall;
  end;

  nsIProfileChangeStatus = interface(nsISupports)
  ['{2f977d43-5485-11d4-87e2-0010a4e75ef2}']
    function VetoChange(): nsresult; stdcall;
    function ChangeFailed(): nsresult; stdcall;
  end;

  nsIPrompt = interface(nsISupports)
  ['{a63f70c0-148b-11d3-9333-00104ba0fd40}']
    function Alert(const dialogTitle: PWideChar; const text: PWideChar): nsresult; stdcall;
    function AlertCheck(const dialogTitle: PWideChar; const text: PWideChar; const checkMsg: PWideChar; out checkValue: PRBool): nsresult; stdcall;
    function Confirm(const dialogTitle: PWideChar; const text: PWideChar; out _retval: PRBool): nsresult; stdcall;
    function ConfirmCheck(const dialogTitle: PWideChar; const text: PWideChar; const checkMsg: PWideChar; out checkValue: PRBool; out _retval: PRBool): nsresult; stdcall;
    function ConfirmEx(const dialogTitle: PWideChar; const text: PWideChar; buttonFlags: PRUint32; const button0Title: PWideChar; const button1Title: PWideChar; const button2Title: PWideChar; const checkMsg: PWideChar; out checkValue: PRBool; out _retval: PRInt32): nsresult; stdcall;
    function Prompt(const dialogTitle: PWideChar; const text: PWideChar; out value: PWideChar; const checkMsg: PWideChar; out checkValue: PRBool; out _retval: PRBool): nsresult; stdcall;
    function PromptPassword(const dialogTitle: PWideChar; const text: PWideChar; out password: PWideChar; const checkMsg: PWideChar; out checkValue: PRBool; out _retval: PRBool): nsresult; stdcall;
    function PromptUsernameAndPassword(const dialogTitle: PWideChar; const text: PWideChar; out username: PWideChar; out password: PWideChar; const checkMsg: PWideChar; out checkValue: PRBool; out _retval: PRBool): nsresult; stdcall;
    function Select(const dialogTitle: PWideChar; const text: PWideChar; count: PRUint32; const selectList: PPWideCharArray; out outSelection: PRInt32; out _retval: PRBool): nsresult; stdcall;
  end;

  nsIProperties = interface(nsISupports)
  ['{78650582-4e93-4b60-8e85-26ebd3eb14ca}']
    function Get(const prop: PAnsiChar; const iid: TGUID; out _result): nsresult; stdcall;
    function _Set(const prop: PAnsiChar; value: nsISupports): nsresult; stdcall;
    function Has(const prop: PAnsiChar; out _retval: PRBool): nsresult; stdcall;
    function Undefine(const prop: PAnsiChar): nsresult; stdcall;
    function GetKeys(out count: PRUint32; out keys: PPAnsiCharArray): nsresult; stdcall;
  end;

  nsIProtocolHandler = interface(nsISupports)
  ['{15fd6940-8ea7-11d3-93ad-00104ba0fd40}']
    function GetScheme(aScheme: nsACString): Longword; stdcall;
    function GetDefaultPort(out aDefaultPort: PRInt32): Longword; stdcall;
    function GetProtocolFlags(out aProtocolFlags: PRUint32): Longword; stdcall;
    function NewURI(const aSpec: nsACString; const aOriginCharset: PAnsiChar; aBaseURI: nsIURI; out _retval: nsIURI): nsresult; stdcall;
    function NewChannel(aURI: nsIURI; out _retval: nsIChannel): nsresult; stdcall;
    function AllowPort(port: PRInt32; const scheme: PAnsiChar; out _retval: PRBool): nsresult; stdcall;
  end;

  nsIRequestObserver = interface(nsISupports)
  ['{fd91e2e0-1481-11d3-9333-00104ba0fd40}']
    function OnStartRequest(aRequest: nsIRequest; aContext: nsISupports): nsresult; stdcall;
    function OnStopRequest(aRequest: nsIRequest; aContext: nsISupports; aStatusCode: nsresult): nsresult; stdcall;
  end;

  nsIScriptableInputStream = interface(nsISupports)
  ['{a2a32f90-9b90-11d3-a189-0050041caf44}']
    function Close(): nsresult; stdcall;
    function Init(aInputStream: nsIInputStream): nsresult; stdcall;
    function Available(out _retval: PRUint32): nsresult; stdcall;
    function Read(aCount: PRUint32; out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISelection = interface(nsISupports)
  ['{b2c7ed59-8634-4352-9e37-5484c8b6e4e1}']
    function GetAnchorNode(out aAnchorNode: nsIDOMNode): Longword; stdcall;
    function GetAnchorOffset(out aAnchorOffset: PRInt32): Longword; stdcall;
    function GetFocusNode(out aFocusNode: nsIDOMNode): Longword; stdcall;
    function GetFocusOffset(out aFocusOffset: PRInt32): Longword; stdcall;
    function GetIsCollapsed(out aIsCollapsed: PRBool): Longword; stdcall;
    function GetRangeCount(out aRangeCount: PRInt32): Longword; stdcall;
    function GetRangeAt(index: PRInt32; out _retval: nsIDOMRange): nsresult; stdcall;
    function Collapse(parentNode: nsIDOMNode; offset: PRInt32): nsresult; stdcall;
    function Extend(parentNode: nsIDOMNode; offset: PRInt32): nsresult; stdcall;
    function CollapseToStart(): nsresult; stdcall;
    function CollapseToEnd(): nsresult; stdcall;
    function ContainsNode(node: nsIDOMNode; entirelyContained: PRBool; out _retval: PRBool): nsresult; stdcall;
    function SelectAllChildren(parentNode: nsIDOMNode): nsresult; stdcall;
    function AddRange(range: nsIDOMRange): nsresult; stdcall;
    function RemoveRange(range: nsIDOMRange): nsresult; stdcall;
    function RemoveAllRanges(): nsresult; stdcall;
    function DeleteFromDocument(): nsresult; stdcall;
    function SelectionLanguageChange(langRTL: PRBool): nsresult; stdcall;
    function ToString(out _retval: PWideChar): nsresult; stdcall;
  end;

  nsIServiceManager = interface(nsISupports)
  ['{8bb35ed9-e332-462d-9155-4a002ab5c958}']
    function GetService(const aClass: TGUID; const aIID: TGUID; out _result): nsresult; stdcall;
    function GetServiceByContractID(const aContractID: PAnsiChar; const aIID: TGUID; out _result): nsresult; stdcall;
    function IsServiceInstantiated(const aClass: TGUID; const aIID: TGUID; out _retval: PRBool): nsresult; stdcall;
    function IsServiceInstantiatedByContractID(const aContractID: PAnsiChar; const aIID: TGUID; out _retval: PRBool): nsresult; stdcall;
  end;

  nsISHistory = interface(nsISupports)
  ['{7294fe9b-14d8-11d5-9882-00c04fa02f40}']
    function GetCount(out aCount: PRInt32): Longword; stdcall;
    function GetIndex(out aIndex: PRInt32): Longword; stdcall;
    function GetMaxLength(out aMaxLength: PRInt32): Longword; stdcall;
    function SetMaxLength(aMaxLength: PRInt32): Longword; stdcall;
    function GetEntryAtIndex(index: PRInt32; modifyIndex: PRBool; out _retval: nsIHistoryEntry): nsresult; stdcall;
    function PurgeHistory(numEntries: PRInt32): nsresult; stdcall;
    function AddSHistoryListener(aListener: nsISHistoryListener): nsresult; stdcall;
    function RemoveSHistoryListener(aListener: nsISHistoryListener): nsresult; stdcall;
    function GetSHistoryEnumerator(out aSHistoryEnumerator: nsISimpleEnumerator): Longword; stdcall;
  end;

  nsISHistoryListener = interface(nsISupports)
  ['{3b07f591-e8e1-11d4-9882-00c04fa02f40}']
    function OnHistoryNewEntry(aNewURI: nsIURI): nsresult; stdcall;
    function OnHistoryGoBack(aBackURI: nsIURI; out _retval: PRBool): nsresult; stdcall;
    function OnHistoryGoForward(aForwardURI: nsIURI; out _retval: PRBool): nsresult; stdcall;
    function OnHistoryReload(aReloadURI: nsIURI; aReloadFlags: PRUint32; out _retval: PRBool): nsresult; stdcall;
    function OnHistoryGotoIndex(aIndex: PRInt32; aGotoURI: nsIURI; out _retval: PRBool): nsresult; stdcall;
    function OnHistoryPurge(aNumEntries: PRInt32; out _retval: PRBool): nsresult; stdcall;
  end;

  nsIStreamListener = interface(nsIRequestObserver)
  ['{1a637020-1482-11d3-9333-00104ba0fd40}']
    function OnDataAvailable(aRequest: nsIRequest; aContext: nsISupports; aInputStream: nsIInputStream; aOffset: PRUint32; aCount: PRUint32): nsresult; stdcall;
  end;

  nsISupportsPrimitive = interface(nsISupports)
  ['{d0d4b136-1dd1-11b2-9371-f0727ef827c0}']
    function GetType(out aType: PRUint16): Longword; stdcall;
  end;

  nsISupportsID = interface(nsISupportsPrimitive)
  ['{d18290a0-4a1c-11d3-9890-006008962422}']
    function GetData(out aData: PGUID): Longword; stdcall;
    function SetData(const aData: PGUID): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsCString = interface(nsISupportsPrimitive)
  ['{d65ff270-4a1c-11d3-9890-006008962422}']
    function GetData(aData: nsACString): Longword; stdcall;
    function SetData(const aData: nsACString): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsString = interface(nsISupportsPrimitive)
  ['{d79dc970-4a1c-11d3-9890-006008962422}']
    function GetData(aData: nsAString): Longword; stdcall;
    function SetData(const aData: nsAString): Longword; stdcall;
    function ToString(out _retval: PWideChar): nsresult; stdcall;
  end;

  nsISupportsPRBool = interface(nsISupportsPrimitive)
  ['{ddc3b490-4a1c-11d3-9890-006008962422}']
    function GetData(out aData: PRBool): Longword; stdcall;
    function SetData(aData: PRBool): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsPRUint8 = interface(nsISupportsPrimitive)
  ['{dec2e4e0-4a1c-11d3-9890-006008962422}']
    function GetData(out aData: PRUint8): Longword; stdcall;
    function SetData(aData: PRUint8): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsPRUint16 = interface(nsISupportsPrimitive)
  ['{dfacb090-4a1c-11d3-9890-006008962422}']
    function GetData(out aData: PRUint16): Longword; stdcall;
    function SetData(aData: PRUint16): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsPRUint32 = interface(nsISupportsPrimitive)
  ['{e01dc470-4a1c-11d3-9890-006008962422}']
    function GetData(out aData: PRUint32): Longword; stdcall;
    function SetData(aData: PRUint32): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsPRUint64 = interface(nsISupportsPrimitive)
  ['{e13567c0-4a1c-11d3-9890-006008962422}']
    function GetData(out aData: PRUint64): Longword; stdcall;
    function SetData(aData: PRUint64): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsPRTime = interface(nsISupportsPrimitive)
  ['{e2563630-4a1c-11d3-9890-006008962422}']
    function GetData(out aData: PRTime): Longword; stdcall;
    function SetData(aData: PRTime): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsChar = interface(nsISupportsPrimitive)
  ['{e2b05e40-4a1c-11d3-9890-006008962422}']
    function GetData(out aData: AnsiChar): Longword; stdcall;
    function SetData(aData: AnsiChar): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsPRInt16 = interface(nsISupportsPrimitive)
  ['{e30d94b0-4a1c-11d3-9890-006008962422}']
    function GetData(out aData: PRInt16): Longword; stdcall;
    function SetData(aData: PRInt16): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsPRInt32 = interface(nsISupportsPrimitive)
  ['{e36c5250-4a1c-11d3-9890-006008962422}']
    function GetData(out aData: PRInt32): Longword; stdcall;
    function SetData(aData: PRInt32): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsPRInt64 = interface(nsISupportsPrimitive)
  ['{e3cb0ff0-4a1c-11d3-9890-006008962422}']
    function GetData(out aData: PRInt64): Longword; stdcall;
    function SetData(aData: PRInt64): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsFloat = interface(nsISupportsPrimitive)
  ['{abeaa390-4ac0-11d3-baea-00805f8a5dd7}']
    function GetData(out aData: Single): Longword; stdcall;
    function SetData(aData: Single): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsDouble = interface(nsISupportsPrimitive)
  ['{b32523a0-4ac0-11d3-baea-00805f8a5dd7}']
    function GetData(out aData: Double): Longword; stdcall;
    function SetData(aData: Double): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsVoid = interface(nsISupportsPrimitive)
  ['{464484f0-568d-11d3-baf8-00805f8a5dd7}']
    function GetData(out aData: Pointer): Longword; stdcall;
    function SetData(aData: Pointer): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsISupportsInterfacePointer = interface(nsISupportsPrimitive)
  ['{995ea724-1dd1-11b2-9211-c21bdd3e7ed0}']
    function GetData(out aData: nsISupports): Longword; stdcall;
    function SetData(aData: nsISupports): Longword; stdcall;
    function GetDataIID(out aDataIID: PGUID): Longword; stdcall;
    function SetDataIID(const aDataIID: PGUID): Longword; stdcall;
    function ToString(out _retval: PAnsiChar): nsresult; stdcall;
  end;

  nsITooltipListener = interface(nsISupports)
  ['{44b78386-1dd2-11b2-9ad2-e4eee2ca1916}']
    function OnShowTooltip(aXCoords: PRInt32; aYCoords: PRInt32; const aTipText: PWideChar): nsresult; stdcall;
    function OnHideTooltip(): nsresult; stdcall;
  end;

  nsITooltipTextProvider = interface(nsISupports)
  ['{b128a1e6-44f3-4331-8fbe-5af360ff21ee}']
    function GetNodeText(aNode: nsIDOMNode; out aText: PWideChar; out _retval: PRBool): nsresult; stdcall;
  end;

  nsITraceRefcnt = interface(nsISupports)
  ['{273dc92f-0fe6-4545-96a9-21be77828039}']
    function LogAddRef(aPtr: Pointer; aNewRefcnt: nsrefcnt; const aTypeName: PAnsiChar; aInstanceSize: PRUint32): nsresult; stdcall;
    function LogRelease(aPtr: Pointer; aNewRefcnt: nsrefcnt; const aTypeName: PAnsiChar): nsresult; stdcall;
    function LogCtor(aPtr: Pointer; const aTypeName: PAnsiChar; aInstanceSize: PRUint32): nsresult; stdcall;
    function LogDtor(aPtr: Pointer; const aTypeName: PAnsiChar; aInstanceSize: PRUint32): nsresult; stdcall;
    function LogAddCOMPtr(aPtr: Pointer; aObject: nsISupports): nsresult; stdcall;
    function LogReleaseCOMPtr(aPtr: Pointer; aObject: nsISupports): nsresult; stdcall;
  end;

  nsIUploadChannel = interface(nsISupports)
  ['{ddf633d8-e9a4-439d-ad88-de636fd9bb75}']
    function SetUploadStream(aStream: nsIInputStream; const aContentType: nsACString; aContentLength: PRInt32): nsresult; stdcall;
    function GetUploadStream(out aUploadStream: nsIInputStream): Longword; stdcall;
  end;

  nsIURIContentListener = interface(nsISupports)
  ['{94928ab3-8b63-11d3-989d-001083010e9b}']
    function OnStartURIOpen(aURI: nsIURI; out _retval: PRBool): nsresult; stdcall;
    function DoContent(const aContentType: PAnsiChar; aIsContentPreferred: PRBool; aRequest: nsIRequest; out aContentHandler: nsIStreamListener; out _retval: PRBool): nsresult; stdcall;
    function IsPreferred(const aContentType: PAnsiChar; out aDesiredContentType: PAnsiChar; out _retval: PRBool): nsresult; stdcall;
    function CanHandleContent(const aContentType: PAnsiChar; aIsContentPreferred: PRBool; out aDesiredContentType: PAnsiChar; out _retval: PRBool): nsresult; stdcall;
    function GetLoadCookie(out aLoadCookie: nsISupports): Longword; stdcall;
    function SetLoadCookie(aLoadCookie: nsISupports): Longword; stdcall;
    function GetParentContentListener(out aParentContentListener: nsIURIContentListener): Longword; stdcall;
    function SetParentContentListener(aParentContentListener: nsIURIContentListener): Longword; stdcall;
  end;

  nsIWeakReference = interface(nsISupports)
  ['{9188bc85-f92e-11d2-81ef-0060083a0bcf}']
    function QueryReferent(const uuid: TGUID; out _result): nsresult; stdcall;
  end;

  nsISupportsWeakReference = interface(nsISupports)
  ['{9188bc86-f92e-11d2-81ef-0060083a0bcf}']
    function GetWeakReference(out _retval: nsIWeakReference): nsresult; stdcall;
  end;

  nsIWebBrowser = interface(nsISupports)
  ['{69e5df00-7b8b-11d3-af61-00a024ffc08c}']
    function AddWebBrowserListener(aListener: nsIWeakReference; const aIID: TGUID): nsresult; stdcall;
    function RemoveWebBrowserListener(aListener: nsIWeakReference; const aIID: TGUID): nsresult; stdcall;
    function GetContainerWindow(out aContainerWindow: nsIWebBrowserChrome): Longword; stdcall;
    function SetContainerWindow(aContainerWindow: nsIWebBrowserChrome): Longword; stdcall;
    function GetParentURIContentListener(out aParentURIContentListener: nsIURIContentListener): Longword; stdcall;
    function SetParentURIContentListener(aParentURIContentListener: nsIURIContentListener): Longword; stdcall;
    function GetContentDOMWindow(out aContentDOMWindow: nsIDOMWindow): Longword; stdcall;
  end;

  nsIWebBrowserChrome = interface(nsISupports)
  ['{ba434c60-9d52-11d3-afb0-00a024ffc08c}']
    function SetStatus(statusType: PRUint32; const status: PWideChar): nsresult; stdcall;
    function GetWebBrowser(out aWebBrowser: nsIWebBrowser): Longword; stdcall;
    function SetWebBrowser(aWebBrowser: nsIWebBrowser): Longword; stdcall;
    function GetChromeFlags(out aChromeFlags: PRUint32): Longword; stdcall;
    function SetChromeFlags(aChromeFlags: PRUint32): Longword; stdcall;
    function DestroyBrowserWindow(): nsresult; stdcall;
    function SizeBrowserTo(aCX: PRInt32; aCY: PRInt32): nsresult; stdcall;
    function ShowAsModal(): nsresult; stdcall;
    function IsWindowModal(out _retval: PRBool): nsresult; stdcall;
    function ExitModalEventLoop(aStatus: nsresult): nsresult; stdcall;
  end;

  nsIWebBrowserChromeFocus = interface(nsISupports)
  ['{d2206418-1dd1-11b2-8e55-acddcd2bcfb8}']
    function FocusNextElement(): nsresult; stdcall;
    function FocusPrevElement(): nsresult; stdcall;
  end;

  nsIWebBrowserFind = interface(nsISupports)
  ['{2f977d44-5485-11d4-87e2-0010a4e75ef2}']
    function FindNext(out _retval: PRBool): nsresult; stdcall;
    function GetSearchString(out aSearchString: PWideChar): Longword; stdcall;
    function SetSearchString(const aSearchString: PWideChar): Longword; stdcall;
    function GetFindBackwards(out aFindBackwards: PRBool): Longword; stdcall;
    function SetFindBackwards(aFindBackwards: PRBool): Longword; stdcall;
    function GetWrapFind(out aWrapFind: PRBool): Longword; stdcall;
    function SetWrapFind(aWrapFind: PRBool): Longword; stdcall;
    function GetEntireWord(out aEntireWord: PRBool): Longword; stdcall;
    function SetEntireWord(aEntireWord: PRBool): Longword; stdcall;
    function GetMatchCase(out aMatchCase: PRBool): Longword; stdcall;
    function SetMatchCase(aMatchCase: PRBool): Longword; stdcall;
    function GetSearchFrames(out aSearchFrames: PRBool): Longword; stdcall;
    function SetSearchFrames(aSearchFrames: PRBool): Longword; stdcall;
  end;

  nsIWebBrowserFindInFrames = interface(nsISupports)
  ['{e0f5d182-34bc-11d5-be5b-b760676c6ebc}']
    function GetCurrentSearchFrame(out aCurrentSearchFrame: nsIDOMWindow): Longword; stdcall;
    function SetCurrentSearchFrame(aCurrentSearchFrame: nsIDOMWindow): Longword; stdcall;
    function GetRootSearchFrame(out aRootSearchFrame: nsIDOMWindow): Longword; stdcall;
    function SetRootSearchFrame(aRootSearchFrame: nsIDOMWindow): Longword; stdcall;
    function GetSearchSubframes(out aSearchSubframes: PRBool): Longword; stdcall;
    function SetSearchSubframes(aSearchSubframes: PRBool): Longword; stdcall;
    function GetSearchParentFrames(out aSearchParentFrames: PRBool): Longword; stdcall;
    function SetSearchParentFrames(aSearchParentFrames: PRBool): Longword; stdcall;
  end;

  nsIWebBrowserFocus = interface(nsISupports)
  ['{9c5d3c58-1dd1-11b2-a1c9-f3699284657a}']
    function Activate(): nsresult; stdcall;
    function Deactivate(): nsresult; stdcall;
    function SetFocusAtFirstElement(): nsresult; stdcall;
    function SetFocusAtLastElement(): nsresult; stdcall;
    function GetFocusedWindow(out aFocusedWindow: nsIDOMWindow): Longword; stdcall;
    function SetFocusedWindow(aFocusedWindow: nsIDOMWindow): Longword; stdcall;
    function GetFocusedElement(out aFocusedElement: nsIDOMElement): Longword; stdcall;
    function SetFocusedElement(aFocusedElement: nsIDOMElement): Longword; stdcall;
  end;

  nsIWebBrowserPrint = interface(nsISupports)
  ['{9a7ca4b0-fbba-11d4-a869-00105a183419}']
    function GetGlobalPrintSettings(out aGlobalPrintSettings: nsIPrintSettings): Longword; stdcall;
    function GetCurrentPrintSettings(out aCurrentPrintSettings: nsIPrintSettings): Longword; stdcall;
    function GetCurrentChildDOMWindow(out aCurrentChildDOMWindow: nsIDOMWindow): Longword; stdcall;
    function GetDoingPrint(out aDoingPrint: PRBool): Longword; stdcall;
    function GetDoingPrintPreview(out aDoingPrintPreview: PRBool): Longword; stdcall;
    function GetIsFramesetDocument(out aIsFramesetDocument: PRBool): Longword; stdcall;
    function GetIsFramesetFrameSelected(out aIsFramesetFrameSelected: PRBool): Longword; stdcall;
    function GetIsIFrameSelected(out aIsIFrameSelected: PRBool): Longword; stdcall;
    function GetIsRangeSelection(out aIsRangeSelection: PRBool): Longword; stdcall;
    function GetPrintPreviewNumPages(out aPrintPreviewNumPages: PRInt32): Longword; stdcall;
    function Print(aThePrintSettings: nsIPrintSettings; aWPListener: nsIWebProgressListener): nsresult; stdcall;
    function PrintPreview(aThePrintSettings: nsIPrintSettings; aChildDOMWin: nsIDOMWindow; aWPListener: nsIWebProgressListener): nsresult; stdcall;
    function PrintPreviewNavigate(aNavType: PRInt16; aPageNum: PRInt32): nsresult; stdcall;
    function Cancel(): nsresult; stdcall;
    function EnumerateDocumentNames(out aCount: PRUint32; out aResult: PPWideCharArray): nsresult; stdcall;
    function ExitPrintPreview(): nsresult; stdcall;
  end;

  nsIWebBrowserSetup = interface(nsISupports)
  ['{f15398a0-8018-11d3-af70-00a024ffc08c}']
    function SetProperty(aId: PRUint32; aValue: PRUint32): nsresult; stdcall;
  end;

  nsIWebProgress = interface(nsISupports)
  ['{570f39d0-efd0-11d3-b093-00a024ffc08c}']
    function AddProgressListener(listener: nsIWebProgressListener; aNotifyMask: PRUint32): nsresult; stdcall;
    function RemoveProgressListener(listener: nsIWebProgressListener): nsresult; stdcall;
    function GetDOMWindow(out aDOMWindow: nsIDOMWindow): Longword; stdcall;
    function GetIsLoadingDocument(out aIsLoadingDocument: PRBool): Longword; stdcall;
  end;

  nsIWebProgressListener = interface(nsISupports)
  ['{570f39d1-efd0-11d3-b093-00a024ffc08c}']
    function OnStateChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aStateFlags: PRUint32; aStatus: nsresult): nsresult; stdcall;
    function OnProgressChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aCurSelfProgress: PRInt32; aMaxSelfProgress: PRInt32; aCurTotalProgress: PRInt32; aMaxTotalProgress: PRInt32): nsresult; stdcall;
    function OnLocationChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; location: nsIURI): nsresult; stdcall;
    function OnStatusChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; aStatus: nsresult; const aMessage: PWideChar): nsresult; stdcall;
    function OnSecurityChange(aWebProgress: nsIWebProgress; aRequest: nsIRequest; state: PRUint32): nsresult; stdcall;
  end;

  nsIWindowCreator = interface(nsISupports)
  ['{30465632-a777-44cc-90f9-8145475ef999}']
    function CreateChromeWindow(parent: nsIWebBrowserChrome; chromeFlags: PRUint32; out _retval: nsIWebBrowserChrome): nsresult; stdcall;
  end;

  nsIWindowWatcher = interface(nsISupports)
  ['{002286a8-494b-43b3-8ddd-49e3fc50622b}']
    function OpenWindow(aParent: nsIDOMWindow; const aUrl: PAnsiChar; const aName: PAnsiChar; const aFeatures: PAnsiChar; aArguments: nsISupports; out _retval: nsIDOMWindow): nsresult; stdcall;
    function RegisterNotification(aObserver: nsIObserver): nsresult; stdcall;
    function UnregisterNotification(aObserver: nsIObserver): nsresult; stdcall;
    function GetWindowEnumerator(out _retval: nsISimpleEnumerator): nsresult; stdcall;
    function GetNewPrompter(aParent: nsIDOMWindow; out _retval: nsIPrompt): nsresult; stdcall;
    function GetNewAuthPrompter(aParent: nsIDOMWindow; out _retval: nsIAuthPrompt): nsresult; stdcall;
    function SetWindowCreator(creator: nsIWindowCreator): nsresult; stdcall;
    function GetChromeForWindow(aWindow: nsIDOMWindow; out _retval: nsIWebBrowserChrome): nsresult; stdcall;
    function GetWindowByName(const aTargetName: PWideChar; aCurrentWindow: nsIDOMWindow; out _retval: nsIDOMWindow): nsresult; stdcall;
    function GetActiveWindow(out aActiveWindow: nsIDOMWindow): Longword; stdcall;
    function SetActiveWindow(aActiveWindow: nsIDOMWindow): Longword; stdcall;
  end;

implementation

end.
