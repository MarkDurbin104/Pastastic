unit Office_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ Microsoft Office 9.0 Object Library }
{ Version 2.1 }

{ Conversion log:
  Warning: 'Type' is a reserved word. Parameter 'Type' in _CommandBars.FindControl changed to 'Type_'
  Warning: 'Type' is a reserved word. Parameter 'Type' in _CommandBars.FindControls changed to 'Type_'
  Warning: 'Type' is a reserved word. Parameter 'Type' in CommandBar.FindControl changed to 'Type_'
  Warning: 'Type' is a reserved word. CommandBar.Type changed to Type_
  Warning: 'Type' is a reserved word. Parameter 'Type' in CommandBarControls.Add changed to 'Type_'
  Warning: 'Type' is a reserved word. CommandBarControl.Type changed to Type_
  Warning: 'Type' is a reserved word. CalloutFormat.Type changed to Type_
  Warning: 'Type' is a reserved word. ColorFormat.Type changed to Type_
  Warning: 'Type' is a reserved word. ConnectorFormat.Type changed to Type_
  Warning: 'Type' is a reserved word. FillFormat.Type changed to Type_
  Warning: 'Type' is a reserved word. ShadowFormat.Type changed to Type_
  Warning: 'Type' is a reserved word. Shape.Type changed to Type_
  Warning: 'Type' is a reserved word. ShapeRange.Type changed to Type_
  Warning: 'Type' is a reserved word. Parameter 'Type' in Shapes.AddCallout changed to 'Type_'
  Warning: 'Type' is a reserved word. Parameter 'Type' in Shapes.AddConnector changed to 'Type_'
  Warning: 'Type' is a reserved word. Parameter 'Type' in Shapes.AddShape changed to 'Type_'
  Warning: 'Private' is a reserved word. Balloon.Private changed to Private_
  Warning: 'On' is a reserved word. Parameter 'On' in Assistant.StartWizard changed to 'On_'
  Warning: 'On' is a reserved word. Assistant.On changed to On_
  Warning: 'Type' is a reserved word. DocumentProperty.Type changed to Type_
  Warning: 'Type' is a reserved word. Parameter 'Type' in DocumentProperties.Add changed to 'Type_'
  Warning: 'Object' is a reserved word. COMAddIn.Object changed to Object_
  Warning: Parent Interface has a member with name: QueryInterface. _CommandBarsEvents.QueryInterface changed to QueryInterface_
  Warning: Parent Interface has a member with name: AddRef. _CommandBarsEvents.AddRef changed to AddRef_
  Warning: Parent Interface has a member with name: Release. _CommandBarsEvents.Release changed to Release_
  Warning: Parent Interface has a member with name: GetTypeInfoCount. _CommandBarsEvents.GetTypeInfoCount changed to GetTypeInfoCount_
  Warning: Parent Interface has a member with name: GetTypeInfo. _CommandBarsEvents.GetTypeInfo changed to GetTypeInfo_
  Warning: Parent Interface has a member with name: GetIDsOfNames. _CommandBarsEvents.GetIDsOfNames changed to GetIDsOfNames_
  Warning: _CommandBarsEvents.GetIDsOfNames_ parameter rgszNames: Too many indirections, type changed to Pointer.. [ ^^Shortint ]
  Warning: Parent Interface has a member with name: Invoke. _CommandBarsEvents.Invoke changed to Invoke_
  Warning: Parent Interface has a member with name: QueryInterface. _CommandBarComboBoxEvents.QueryInterface changed to QueryInterface_
  Warning: Parent Interface has a member with name: AddRef. _CommandBarComboBoxEvents.AddRef changed to AddRef_
  Warning: Parent Interface has a member with name: Release. _CommandBarComboBoxEvents.Release changed to Release_
  Warning: Parent Interface has a member with name: GetTypeInfoCount. _CommandBarComboBoxEvents.GetTypeInfoCount changed to GetTypeInfoCount_
  Warning: Parent Interface has a member with name: GetTypeInfo. _CommandBarComboBoxEvents.GetTypeInfo changed to GetTypeInfo_
  Warning: Parent Interface has a member with name: GetIDsOfNames. _CommandBarComboBoxEvents.GetIDsOfNames changed to GetIDsOfNames_
  Warning: _CommandBarComboBoxEvents.GetIDsOfNames_ parameter rgszNames: Too many indirections, type changed to Pointer.. [ ^^Shortint ]
  Warning: Parent Interface has a member with name: Invoke. _CommandBarComboBoxEvents.Invoke changed to Invoke_
  Warning: Parent Interface has a member with name: QueryInterface. _CommandBarButtonEvents.QueryInterface changed to QueryInterface_
  Warning: Parent Interface has a member with name: AddRef. _CommandBarButtonEvents.AddRef changed to AddRef_
  Warning: Parent Interface has a member with name: Release. _CommandBarButtonEvents.Release changed to Release_
  Warning: Parent Interface has a member with name: GetTypeInfoCount. _CommandBarButtonEvents.GetTypeInfoCount changed to GetTypeInfoCount_
  Warning: Parent Interface has a member with name: GetTypeInfo. _CommandBarButtonEvents.GetTypeInfo changed to GetTypeInfo_
  Warning: Parent Interface has a member with name: GetIDsOfNames. _CommandBarButtonEvents.GetIDsOfNames changed to GetIDsOfNames_
  Warning: _CommandBarButtonEvents.GetIDsOfNames_ parameter rgszNames: Too many indirections, type changed to Pointer.. [ ^^Shortint ]
  Warning: Parent Interface has a member with name: Invoke. _CommandBarButtonEvents.Invoke changed to Invoke_
 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_Office: TGUID = '{2DF8D04C-5BFA-101B-BDE5-00AA0044DE52}';

const

{ MsoLineDashStyle }

  msoLineDashStyleMixed = -2;
  msoLineSolid = 1;
  msoLineSquareDot = 2;
  msoLineRoundDot = 3;
  msoLineDash = 4;
  msoLineDashDot = 5;
  msoLineDashDotDot = 6;
  msoLineLongDash = 7;
  msoLineLongDashDot = 8;

{ MsoLineStyle }

  msoLineStyleMixed = -2;
  msoLineSingle = 1;
  msoLineThinThin = 2;
  msoLineThinThick = 3;
  msoLineThickThin = 4;
  msoLineThickBetweenThin = 5;

{ MsoArrowheadStyle }

  msoArrowheadStyleMixed = -2;
  msoArrowheadNone = 1;
  msoArrowheadTriangle = 2;
  msoArrowheadOpen = 3;
  msoArrowheadStealth = 4;
  msoArrowheadDiamond = 5;
  msoArrowheadOval = 6;

{ MsoArrowheadWidth }

  msoArrowheadWidthMixed = -2;
  msoArrowheadNarrow = 1;
  msoArrowheadWidthMedium = 2;
  msoArrowheadWide = 3;

{ MsoArrowheadLength }

  msoArrowheadLengthMixed = -2;
  msoArrowheadShort = 1;
  msoArrowheadLengthMedium = 2;
  msoArrowheadLong = 3;

{ MsoFillType }

  msoFillMixed = -2;
  msoFillSolid = 1;
  msoFillPatterned = 2;
  msoFillGradient = 3;
  msoFillTextured = 4;
  msoFillBackground = 5;
  msoFillPicture = 6;

{ MsoGradientStyle }

  msoGradientMixed = -2;
  msoGradientHorizontal = 1;
  msoGradientVertical = 2;
  msoGradientDiagonalUp = 3;
  msoGradientDiagonalDown = 4;
  msoGradientFromCorner = 5;
  msoGradientFromTitle = 6;
  msoGradientFromCenter = 7;

{ MsoGradientColorType }

  msoGradientColorMixed = -2;
  msoGradientOneColor = 1;
  msoGradientTwoColors = 2;
  msoGradientPresetColors = 3;

{ MsoTextureType }

  msoTextureTypeMixed = -2;
  msoTexturePreset = 1;
  msoTextureUserDefined = 2;

{ MsoPresetTexture }

  msoPresetTextureMixed = -2;
  msoTexturePapyrus = 1;
  msoTextureCanvas = 2;
  msoTextureDenim = 3;
  msoTextureWovenMat = 4;
  msoTextureWaterDroplets = 5;
  msoTexturePaperBag = 6;
  msoTextureFishFossil = 7;
  msoTextureSand = 8;
  msoTextureGreenMarble = 9;
  msoTextureWhiteMarble = 10;
  msoTextureBrownMarble = 11;
  msoTextureGranite = 12;
  msoTextureNewsprint = 13;
  msoTextureRecycledPaper = 14;
  msoTextureParchment = 15;
  msoTextureStationery = 16;
  msoTextureBlueTissuePaper = 17;
  msoTexturePinkTissuePaper = 18;
  msoTexturePurpleMesh = 19;
  msoTextureBouquet = 20;
  msoTextureCork = 21;
  msoTextureWalnut = 22;
  msoTextureOak = 23;
  msoTextureMediumWood = 24;

{ MsoPatternType }

  msoPatternMixed = -2;
  msoPattern5Percent = 1;
  msoPattern10Percent = 2;
  msoPattern20Percent = 3;
  msoPattern25Percent = 4;
  msoPattern30Percent = 5;
  msoPattern40Percent = 6;
  msoPattern50Percent = 7;
  msoPattern60Percent = 8;
  msoPattern70Percent = 9;
  msoPattern75Percent = 10;
  msoPattern80Percent = 11;
  msoPattern90Percent = 12;
  msoPatternDarkHorizontal = 13;
  msoPatternDarkVertical = 14;
  msoPatternDarkDownwardDiagonal = 15;
  msoPatternDarkUpwardDiagonal = 16;
  msoPatternSmallCheckerBoard = 17;
  msoPatternTrellis = 18;
  msoPatternLightHorizontal = 19;
  msoPatternLightVertical = 20;
  msoPatternLightDownwardDiagonal = 21;
  msoPatternLightUpwardDiagonal = 22;
  msoPatternSmallGrid = 23;
  msoPatternDottedDiamond = 24;
  msoPatternWideDownwardDiagonal = 25;
  msoPatternWideUpwardDiagonal = 26;
  msoPatternDashedUpwardDiagonal = 27;
  msoPatternDashedDownwardDiagonal = 28;
  msoPatternNarrowVertical = 29;
  msoPatternNarrowHorizontal = 30;
  msoPatternDashedVertical = 31;
  msoPatternDashedHorizontal = 32;
  msoPatternLargeConfetti = 33;
  msoPatternLargeGrid = 34;
  msoPatternHorizontalBrick = 35;
  msoPatternLargeCheckerBoard = 36;
  msoPatternSmallConfetti = 37;
  msoPatternZigZag = 38;
  msoPatternSolidDiamond = 39;
  msoPatternDiagonalBrick = 40;
  msoPatternOutlinedDiamond = 41;
  msoPatternPlaid = 42;
  msoPatternSphere = 43;
  msoPatternWeave = 44;
  msoPatternDottedGrid = 45;
  msoPatternDivot = 46;
  msoPatternShingle = 47;
  msoPatternWave = 48;

{ MsoPresetGradientType }

  msoPresetGradientMixed = -2;
  msoGradientEarlySunset = 1;
  msoGradientLateSunset = 2;
  msoGradientNightfall = 3;
  msoGradientDaybreak = 4;
  msoGradientHorizon = 5;
  msoGradientDesert = 6;
  msoGradientOcean = 7;
  msoGradientCalmWater = 8;
  msoGradientFire = 9;
  msoGradientFog = 10;
  msoGradientMoss = 11;
  msoGradientPeacock = 12;
  msoGradientWheat = 13;
  msoGradientParchment = 14;
  msoGradientMahogany = 15;
  msoGradientRainbow = 16;
  msoGradientRainbowII = 17;
  msoGradientGold = 18;
  msoGradientGoldII = 19;
  msoGradientBrass = 20;
  msoGradientChrome = 21;
  msoGradientChromeII = 22;
  msoGradientSilver = 23;
  msoGradientSapphire = 24;

{ MsoShadowType }

  msoShadowMixed = -2;
  msoShadow1 = 1;
  msoShadow2 = 2;
  msoShadow3 = 3;
  msoShadow4 = 4;
  msoShadow5 = 5;
  msoShadow6 = 6;
  msoShadow7 = 7;
  msoShadow8 = 8;
  msoShadow9 = 9;
  msoShadow10 = 10;
  msoShadow11 = 11;
  msoShadow12 = 12;
  msoShadow13 = 13;
  msoShadow14 = 14;
  msoShadow15 = 15;
  msoShadow16 = 16;
  msoShadow17 = 17;
  msoShadow18 = 18;
  msoShadow19 = 19;
  msoShadow20 = 20;

{ MsoPresetTextEffect }

  msoTextEffectMixed = -2;
  msoTextEffect1 = 0;
  msoTextEffect2 = 1;
  msoTextEffect3 = 2;
  msoTextEffect4 = 3;
  msoTextEffect5 = 4;
  msoTextEffect6 = 5;
  msoTextEffect7 = 6;
  msoTextEffect8 = 7;
  msoTextEffect9 = 8;
  msoTextEffect10 = 9;
  msoTextEffect11 = 10;
  msoTextEffect12 = 11;
  msoTextEffect13 = 12;
  msoTextEffect14 = 13;
  msoTextEffect15 = 14;
  msoTextEffect16 = 15;
  msoTextEffect17 = 16;
  msoTextEffect18 = 17;
  msoTextEffect19 = 18;
  msoTextEffect20 = 19;
  msoTextEffect21 = 20;
  msoTextEffect22 = 21;
  msoTextEffect23 = 22;
  msoTextEffect24 = 23;
  msoTextEffect25 = 24;
  msoTextEffect26 = 25;
  msoTextEffect27 = 26;
  msoTextEffect28 = 27;
  msoTextEffect29 = 28;
  msoTextEffect30 = 29;

{ MsoPresetTextEffectShape }

  msoTextEffectShapeMixed = -2;
  msoTextEffectShapePlainText = 1;
  msoTextEffectShapeStop = 2;
  msoTextEffectShapeTriangleUp = 3;
  msoTextEffectShapeTriangleDown = 4;
  msoTextEffectShapeChevronUp = 5;
  msoTextEffectShapeChevronDown = 6;
  msoTextEffectShapeRingInside = 7;
  msoTextEffectShapeRingOutside = 8;
  msoTextEffectShapeArchUpCurve = 9;
  msoTextEffectShapeArchDownCurve = 10;
  msoTextEffectShapeCircleCurve = 11;
  msoTextEffectShapeButtonCurve = 12;
  msoTextEffectShapeArchUpPour = 13;
  msoTextEffectShapeArchDownPour = 14;
  msoTextEffectShapeCirclePour = 15;
  msoTextEffectShapeButtonPour = 16;
  msoTextEffectShapeCurveUp = 17;
  msoTextEffectShapeCurveDown = 18;
  msoTextEffectShapeCanUp = 19;
  msoTextEffectShapeCanDown = 20;
  msoTextEffectShapeWave1 = 21;
  msoTextEffectShapeWave2 = 22;
  msoTextEffectShapeDoubleWave1 = 23;
  msoTextEffectShapeDoubleWave2 = 24;
  msoTextEffectShapeInflate = 25;
  msoTextEffectShapeDeflate = 26;
  msoTextEffectShapeInflateBottom = 27;
  msoTextEffectShapeDeflateBottom = 28;
  msoTextEffectShapeInflateTop = 29;
  msoTextEffectShapeDeflateTop = 30;
  msoTextEffectShapeDeflateInflate = 31;
  msoTextEffectShapeDeflateInflateDeflate = 32;
  msoTextEffectShapeFadeRight = 33;
  msoTextEffectShapeFadeLeft = 34;
  msoTextEffectShapeFadeUp = 35;
  msoTextEffectShapeFadeDown = 36;
  msoTextEffectShapeSlantUp = 37;
  msoTextEffectShapeSlantDown = 38;
  msoTextEffectShapeCascadeUp = 39;
  msoTextEffectShapeCascadeDown = 40;

{ MsoTextEffectAlignment }

  msoTextEffectAlignmentMixed = -2;
  msoTextEffectAlignmentLeft = 1;
  msoTextEffectAlignmentCentered = 2;
  msoTextEffectAlignmentRight = 3;
  msoTextEffectAlignmentLetterJustify = 4;
  msoTextEffectAlignmentWordJustify = 5;
  msoTextEffectAlignmentStretchJustify = 6;

{ MsoPresetLightingDirection }

  msoPresetLightingDirectionMixed = -2;
  msoLightingTopLeft = 1;
  msoLightingTop = 2;
  msoLightingTopRight = 3;
  msoLightingLeft = 4;
  msoLightingNone = 5;
  msoLightingRight = 6;
  msoLightingBottomLeft = 7;
  msoLightingBottom = 8;
  msoLightingBottomRight = 9;

{ MsoPresetLightingSoftness }

  msoPresetLightingSoftnessMixed = -2;
  msoLightingDim = 1;
  msoLightingNormal = 2;
  msoLightingBright = 3;

{ MsoPresetMaterial }

  msoPresetMaterialMixed = -2;
  msoMaterialMatte = 1;
  msoMaterialPlastic = 2;
  msoMaterialMetal = 3;
  msoMaterialWireFrame = 4;

{ MsoPresetExtrusionDirection }

  msoPresetExtrusionDirectionMixed = -2;
  msoExtrusionBottomRight = 1;
  msoExtrusionBottom = 2;
  msoExtrusionBottomLeft = 3;
  msoExtrusionRight = 4;
  msoExtrusionNone = 5;
  msoExtrusionLeft = 6;
  msoExtrusionTopRight = 7;
  msoExtrusionTop = 8;
  msoExtrusionTopLeft = 9;

{ MsoPresetThreeDFormat }

  msoPresetThreeDFormatMixed = -2;
  msoThreeD1 = 1;
  msoThreeD2 = 2;
  msoThreeD3 = 3;
  msoThreeD4 = 4;
  msoThreeD5 = 5;
  msoThreeD6 = 6;
  msoThreeD7 = 7;
  msoThreeD8 = 8;
  msoThreeD9 = 9;
  msoThreeD10 = 10;
  msoThreeD11 = 11;
  msoThreeD12 = 12;
  msoThreeD13 = 13;
  msoThreeD14 = 14;
  msoThreeD15 = 15;
  msoThreeD16 = 16;
  msoThreeD17 = 17;
  msoThreeD18 = 18;
  msoThreeD19 = 19;
  msoThreeD20 = 20;

{ MsoExtrusionColorType }

  msoExtrusionColorTypeMixed = -2;
  msoExtrusionColorAutomatic = 1;
  msoExtrusionColorCustom = 2;

{ MsoAlignCmd }

  msoAlignLefts = 0;
  msoAlignCenters = 1;
  msoAlignRights = 2;
  msoAlignTops = 3;
  msoAlignMiddles = 4;
  msoAlignBottoms = 5;

{ MsoDistributeCmd }

  msoDistributeHorizontally = 0;
  msoDistributeVertically = 1;

{ MsoConnectorType }

  msoConnectorTypeMixed = -2;
  msoConnectorStraight = 1;
  msoConnectorElbow = 2;
  msoConnectorCurve = 3;

{ MsoHorizontalAnchor }

  msoHorizontalAnchorMixed = -2;
  msoAnchorNone = 1;
  msoAnchorCenter = 2;

{ MsoVerticalAnchor }

  msoVerticalAnchorMixed = -2;
  msoAnchorTop = 1;
  msoAnchorTopBaseline = 2;
  msoAnchorMiddle = 3;
  msoAnchorBottom = 4;
  msoAnchorBottomBaseLine = 5;

{ MsoOrientation }

  msoOrientationMixed = -2;
  msoOrientationHorizontal = 1;
  msoOrientationVertical = 2;

{ MsoZOrderCmd }

  msoBringToFront = 0;
  msoSendToBack = 1;
  msoBringForward = 2;
  msoSendBackward = 3;
  msoBringInFrontOfText = 4;
  msoSendBehindText = 5;

{ MsoSegmentType }

  msoSegmentLine = 0;
  msoSegmentCurve = 1;

{ MsoEditingType }

  msoEditingAuto = 0;
  msoEditingCorner = 1;
  msoEditingSmooth = 2;
  msoEditingSymmetric = 3;

{ MsoAutoShapeType }

  msoShapeMixed = -2;
  msoShapeRectangle = 1;
  msoShapeParallelogram = 2;
  msoShapeTrapezoid = 3;
  msoShapeDiamond = 4;
  msoShapeRoundedRectangle = 5;
  msoShapeOctagon = 6;
  msoShapeIsoscelesTriangle = 7;
  msoShapeRightTriangle = 8;
  msoShapeOval = 9;
  msoShapeHexagon = 10;
  msoShapeCross = 11;
  msoShapeRegularPentagon = 12;
  msoShapeCan = 13;
  msoShapeCube = 14;
  msoShapeBevel = 15;
  msoShapeFoldedCorner = 16;
  msoShapeSmileyFace = 17;
  msoShapeDonut = 18;
  msoShapeNoSymbol = 19;
  msoShapeBlockArc = 20;
  msoShapeHeart = 21;
  msoShapeLightningBolt = 22;
  msoShapeSun = 23;
  msoShapeMoon = 24;
  msoShapeArc = 25;
  msoShapeDoubleBracket = 26;
  msoShapeDoubleBrace = 27;
  msoShapePlaque = 28;
  msoShapeLeftBracket = 29;
  msoShapeRightBracket = 30;
  msoShapeLeftBrace = 31;
  msoShapeRightBrace = 32;
  msoShapeRightArrow = 33;
  msoShapeLeftArrow = 34;
  msoShapeUpArrow = 35;
  msoShapeDownArrow = 36;
  msoShapeLeftRightArrow = 37;
  msoShapeUpDownArrow = 38;
  msoShapeQuadArrow = 39;
  msoShapeLeftRightUpArrow = 40;
  msoShapeBentArrow = 41;
  msoShapeUTurnArrow = 42;
  msoShapeLeftUpArrow = 43;
  msoShapeBentUpArrow = 44;
  msoShapeCurvedRightArrow = 45;
  msoShapeCurvedLeftArrow = 46;
  msoShapeCurvedUpArrow = 47;
  msoShapeCurvedDownArrow = 48;
  msoShapeStripedRightArrow = 49;
  msoShapeNotchedRightArrow = 50;
  msoShapePentagon = 51;
  msoShapeChevron = 52;
  msoShapeRightArrowCallout = 53;
  msoShapeLeftArrowCallout = 54;
  msoShapeUpArrowCallout = 55;
  msoShapeDownArrowCallout = 56;
  msoShapeLeftRightArrowCallout = 57;
  msoShapeUpDownArrowCallout = 58;
  msoShapeQuadArrowCallout = 59;
  msoShapeCircularArrow = 60;
  msoShapeFlowchartProcess = 61;
  msoShapeFlowchartAlternateProcess = 62;
  msoShapeFlowchartDecision = 63;
  msoShapeFlowchartData = 64;
  msoShapeFlowchartPredefinedProcess = 65;
  msoShapeFlowchartInternalStorage = 66;
  msoShapeFlowchartDocument = 67;
  msoShapeFlowchartMultidocument = 68;
  msoShapeFlowchartTerminator = 69;
  msoShapeFlowchartPreparation = 70;
  msoShapeFlowchartManualInput = 71;
  msoShapeFlowchartManualOperation = 72;
  msoShapeFlowchartConnector = 73;
  msoShapeFlowchartOffpageConnector = 74;
  msoShapeFlowchartCard = 75;
  msoShapeFlowchartPunchedTape = 76;
  msoShapeFlowchartSummingJunction = 77;
  msoShapeFlowchartOr = 78;
  msoShapeFlowchartCollate = 79;
  msoShapeFlowchartSort = 80;
  msoShapeFlowchartExtract = 81;
  msoShapeFlowchartMerge = 82;
  msoShapeFlowchartStoredData = 83;
  msoShapeFlowchartDelay = 84;
  msoShapeFlowchartSequentialAccessStorage = 85;
  msoShapeFlowchartMagneticDisk = 86;
  msoShapeFlowchartDirectAccessStorage = 87;
  msoShapeFlowchartDisplay = 88;
  msoShapeExplosion1 = 89;
  msoShapeExplosion2 = 90;
  msoShape4pointStar = 91;
  msoShape5pointStar = 92;
  msoShape8pointStar = 93;
  msoShape16pointStar = 94;
  msoShape24pointStar = 95;
  msoShape32pointStar = 96;
  msoShapeUpRibbon = 97;
  msoShapeDownRibbon = 98;
  msoShapeCurvedUpRibbon = 99;
  msoShapeCurvedDownRibbon = 100;
  msoShapeVerticalScroll = 101;
  msoShapeHorizontalScroll = 102;
  msoShapeWave = 103;
  msoShapeDoubleWave = 104;
  msoShapeRectangularCallout = 105;
  msoShapeRoundedRectangularCallout = 106;
  msoShapeOvalCallout = 107;
  msoShapeCloudCallout = 108;
  msoShapeLineCallout1 = 109;
  msoShapeLineCallout2 = 110;
  msoShapeLineCallout3 = 111;
  msoShapeLineCallout4 = 112;
  msoShapeLineCallout1AccentBar = 113;
  msoShapeLineCallout2AccentBar = 114;
  msoShapeLineCallout3AccentBar = 115;
  msoShapeLineCallout4AccentBar = 116;
  msoShapeLineCallout1NoBorder = 117;
  msoShapeLineCallout2NoBorder = 118;
  msoShapeLineCallout3NoBorder = 119;
  msoShapeLineCallout4NoBorder = 120;
  msoShapeLineCallout1BorderandAccentBar = 121;
  msoShapeLineCallout2BorderandAccentBar = 122;
  msoShapeLineCallout3BorderandAccentBar = 123;
  msoShapeLineCallout4BorderandAccentBar = 124;
  msoShapeActionButtonCustom = 125;
  msoShapeActionButtonHome = 126;
  msoShapeActionButtonHelp = 127;
  msoShapeActionButtonInformation = 128;
  msoShapeActionButtonBackorPrevious = 129;
  msoShapeActionButtonForwardorNext = 130;
  msoShapeActionButtonBeginning = 131;
  msoShapeActionButtonEnd = 132;
  msoShapeActionButtonReturn = 133;
  msoShapeActionButtonDocument = 134;
  msoShapeActionButtonSound = 135;
  msoShapeActionButtonMovie = 136;
  msoShapeBalloon = 137;
  msoShapeNotPrimitive = 138;

{ MsoShapeType }

  msoShapeTypeMixed = -2;
  msoAutoShape = 1;
  msoCallout = 2;
  msoChart = 3;
  msoComment = 4;
  msoFreeform = 5;
  msoGroup = 6;
  msoEmbeddedOLEObject = 7;
  msoFormControl = 8;
  msoLine = 9;
  msoLinkedOLEObject = 10;
  msoLinkedPicture = 11;
  msoOLEControlObject = 12;
  msoPicture = 13;
  msoPlaceholder = 14;
  msoTextEffect = 15;
  msoMedia = 16;
  msoTextBox = 17;
  msoScriptAnchor = 18;
  msoTable = 19;

{ MsoFlipCmd }

  msoFlipHorizontal = 0;
  msoFlipVertical = 1;

{ MsoTriState }

  msoTrue = -1;
  msoFalse = 0;
  msoCTrue = 1;
  msoTriStateToggle = -3;
  msoTriStateMixed = -2;

{ MsoColorType }

  msoColorTypeMixed = -2;
  msoColorTypeRGB = 1;
  msoColorTypeScheme = 2;

{ MsoPictureColorType }

  msoPictureMixed = -2;
  msoPictureAutomatic = 1;
  msoPictureGrayscale = 2;
  msoPictureBlackAndWhite = 3;
  msoPictureWatermark = 4;

{ MsoCalloutAngleType }

  msoCalloutAngleMixed = -2;
  msoCalloutAngleAutomatic = 1;
  msoCalloutAngle30 = 2;
  msoCalloutAngle45 = 3;
  msoCalloutAngle60 = 4;
  msoCalloutAngle90 = 5;

{ MsoCalloutDropType }

  msoCalloutDropMixed = -2;
  msoCalloutDropCustom = 1;
  msoCalloutDropTop = 2;
  msoCalloutDropCenter = 3;
  msoCalloutDropBottom = 4;

{ MsoCalloutType }

  msoCalloutMixed = -2;
  msoCalloutOne = 1;
  msoCalloutTwo = 2;
  msoCalloutThree = 3;
  msoCalloutFour = 4;

{ MsoBlackWhiteMode }

  msoBlackWhiteMixed = -2;
  msoBlackWhiteAutomatic = 1;
  msoBlackWhiteGrayScale = 2;
  msoBlackWhiteLightGrayScale = 3;
  msoBlackWhiteInverseGrayScale = 4;
  msoBlackWhiteGrayOutline = 5;
  msoBlackWhiteBlackTextAndLine = 6;
  msoBlackWhiteHighContrast = 7;
  msoBlackWhiteBlack = 8;
  msoBlackWhiteWhite = 9;
  msoBlackWhiteDontShow = 10;

{ MsoMixedType }

  msoIntegerMixed = 32768;
  msoSingleMixed = $80000000;

{ MsoTextOrientation }

  msoTextOrientationMixed = -2;
  msoTextOrientationHorizontal = 1;
  msoTextOrientationUpward = 2;
  msoTextOrientationDownward = 3;
  msoTextOrientationVerticalFarEast = 4;
  msoTextOrientationVertical = 5;
  msoTextOrientationHorizontalRotatedFarEast = 6;

{ MsoScaleFrom }

  msoScaleFromTopLeft = 0;
  msoScaleFromMiddle = 1;
  msoScaleFromBottomRight = 2;

{ MsoBarPosition }

  msoBarLeft = 0;
  msoBarTop = 1;
  msoBarRight = 2;
  msoBarBottom = 3;
  msoBarFloating = 4;
  msoBarPopup = 5;
  msoBarMenuBar = 6;

{ MsoBarProtection }

  msoBarNoProtection = 0;
  msoBarNoCustomize = 1;
  msoBarNoResize = 2;
  msoBarNoMove = 4;
  msoBarNoChangeVisible = 8;
  msoBarNoChangeDock = 16;
  msoBarNoVerticalDock = 32;
  msoBarNoHorizontalDock = 64;

{ MsoBarType }

  msoBarTypeNormal = 0;
  msoBarTypeMenuBar = 1;
  msoBarTypePopup = 2;

{ MsoControlType }

  msoControlCustom = 0;
  msoControlButton = 1;
  msoControlEdit = 2;
  msoControlDropdown = 3;
  msoControlComboBox = 4;
  msoControlButtonDropdown = 5;
  msoControlSplitDropdown = 6;
  msoControlOCXDropdown = 7;
  msoControlGenericDropdown = 8;
  msoControlGraphicDropdown = 9;
  msoControlPopup = 10;
  msoControlGraphicPopup = 11;
  msoControlButtonPopup = 12;
  msoControlSplitButtonPopup = 13;
  msoControlSplitButtonMRUPopup = 14;
  msoControlLabel = 15;
  msoControlExpandingGrid = 16;
  msoControlSplitExpandingGrid = 17;
  msoControlGrid = 18;
  msoControlGauge = 19;
  msoControlGraphicCombo = 20;
  msoControlPane = 21;
  msoControlActiveX = 22;

{ MsoButtonState }

  msoButtonUp = 0;
  msoButtonDown = -1;
  msoButtonMixed = 2;

{ MsoControlOLEUsage }

  msoControlOLEUsageNeither = 0;
  msoControlOLEUsageServer = 1;
  msoControlOLEUsageClient = 2;
  msoControlOLEUsageBoth = 3;

{ MsoButtonStyleHidden }

  msoButtonWrapText = 4;
  msoButtonTextBelow = 8;

{ MsoButtonStyle }

  msoButtonAutomatic = 0;
  msoButtonIcon = 1;
  msoButtonCaption = 2;
  msoButtonIconAndCaption = 3;
  msoButtonIconAndWrapCaption = 7;
  msoButtonIconAndCaptionBelow = 11;
  msoButtonWrapCaption = 14;
  msoButtonIconAndWrapCaptionBelow = 15;

{ MsoComboStyle }

  msoComboNormal = 0;
  msoComboLabel = 1;

{ MsoOLEMenuGroup }

  msoOLEMenuGroupNone = -1;
  msoOLEMenuGroupFile = 0;
  msoOLEMenuGroupEdit = 1;
  msoOLEMenuGroupContainer = 2;
  msoOLEMenuGroupObject = 3;
  msoOLEMenuGroupWindow = 4;
  msoOLEMenuGroupHelp = 5;

{ MsoMenuAnimation }

  msoMenuAnimationNone = 0;
  msoMenuAnimationRandom = 1;
  msoMenuAnimationUnfold = 2;
  msoMenuAnimationSlide = 3;

{ MsoBarRow }

  msoBarRowFirst = 0;
  msoBarRowLast = -1;

{ MsoCommandBarButtonHyperlinkType }

  msoCommandBarButtonHyperlinkNone = 0;
  msoCommandBarButtonHyperlinkOpen = 1;
  msoCommandBarButtonHyperlinkInsertPicture = 2;

{ MsoHyperlinkType }

  msoHyperlinkRange = 0;
  msoHyperlinkShape = 1;
  msoHyperlinkInlineShape = 2;

{ MsoExtraInfoMethod }

  msoMethodGet = 0;
  msoMethodPost = 1;

{ MsoAnimationType }

  msoAnimationIdle = 1;
  msoAnimationGreeting = 2;
  msoAnimationGoodbye = 3;
  msoAnimationBeginSpeaking = 4;
  msoAnimationRestPose = 5;
  msoAnimationCharacterSuccessMajor = 6;
  msoAnimationGetAttentionMajor = 11;
  msoAnimationGetAttentionMinor = 12;
  msoAnimationSearching = 13;
  msoAnimationPrinting = 18;
  msoAnimationGestureRight = 19;
  msoAnimationWritingNotingSomething = 22;
  msoAnimationWorkingAtSomething = 23;
  msoAnimationThinking = 24;
  msoAnimationSendingMail = 25;
  msoAnimationListensToComputer = 26;
  msoAnimationDisappear = 31;
  msoAnimationAppear = 32;
  msoAnimationGetArtsy = 100;
  msoAnimationGetTechy = 101;
  msoAnimationGetWizardy = 102;
  msoAnimationCheckingSomething = 103;
  msoAnimationLookDown = 104;
  msoAnimationLookDownLeft = 105;
  msoAnimationLookDownRight = 106;
  msoAnimationLookLeft = 107;
  msoAnimationLookRight = 108;
  msoAnimationLookUp = 109;
  msoAnimationLookUpLeft = 110;
  msoAnimationLookUpRight = 111;
  msoAnimationSaving = 112;
  msoAnimationGestureDown = 113;
  msoAnimationGestureLeft = 114;
  msoAnimationGestureUp = 115;
  msoAnimationEmptyTrash = 116;

{ MsoButtonSetType }

  msoButtonSetNone = 0;
  msoButtonSetOK = 1;
  msoButtonSetCancel = 2;
  msoButtonSetOkCancel = 3;
  msoButtonSetYesNo = 4;
  msoButtonSetYesNoCancel = 5;
  msoButtonSetBackClose = 6;
  msoButtonSetNextClose = 7;
  msoButtonSetBackNextClose = 8;
  msoButtonSetRetryCancel = 9;
  msoButtonSetAbortRetryIgnore = 10;
  msoButtonSetSearchClose = 11;
  msoButtonSetBackNextSnooze = 12;
  msoButtonSetTipsOptionsClose = 13;
  msoButtonSetYesAllNoCancel = 14;

{ MsoIconType }

  msoIconNone = 0;
  msoIconAlert = 2;
  msoIconTip = 3;
  msoIconAlertInfo = 4;
  msoIconAlertWarning = 5;
  msoIconAlertQuery = 6;
  msoIconAlertCritical = 7;

{ MsoBalloonType }

  msoBalloonTypeButtons = 0;
  msoBalloonTypeBullets = 1;
  msoBalloonTypeNumbers = 2;

{ MsoModeType }

  msoModeModal = 0;
  msoModeAutoDown = 1;
  msoModeModeless = 2;

{ MsoBalloonErrorType }

  msoBalloonErrorNone = 0;
  msoBalloonErrorOther = 1;
  msoBalloonErrorTooBig = 2;
  msoBalloonErrorOutOfMemory = 3;
  msoBalloonErrorBadPictureRef = 4;
  msoBalloonErrorBadReference = 5;
  msoBalloonErrorButtonlessModal = 6;
  msoBalloonErrorButtonModeless = 7;
  msoBalloonErrorBadCharacter = 8;
  msoBalloonErrorCOMFailure = 9;
  msoBalloonErrorCharNotTopmostForModal = 10;
  msoBalloonErrorTooManyControls = 11;

{ MsoWizardActType }

  msoWizardActInactive = 0;
  msoWizardActActive = 1;
  msoWizardActSuspend = 2;
  msoWizardActResume = 3;

{ MsoWizardMsgType }

  msoWizardMsgLocalStateOn = 1;
  msoWizardMsgLocalStateOff = 2;
  msoWizardMsgShowHelp = 3;
  msoWizardMsgSuspending = 4;
  msoWizardMsgResuming = 5;

{ MsoBalloonButtonType }

  msoBalloonButtonYesToAll = -15;
  msoBalloonButtonOptions = -14;
  msoBalloonButtonTips = -13;
  msoBalloonButtonClose = -12;
  msoBalloonButtonSnooze = -11;
  msoBalloonButtonSearch = -10;
  msoBalloonButtonIgnore = -9;
  msoBalloonButtonAbort = -8;
  msoBalloonButtonRetry = -7;
  msoBalloonButtonNext = -6;
  msoBalloonButtonBack = -5;
  msoBalloonButtonNo = -4;
  msoBalloonButtonYes = -3;
  msoBalloonButtonCancel = -2;
  msoBalloonButtonOK = -1;
  msoBalloonButtonNull = 0;

{ DocProperties }

  offPropertyTypeNumber = 1;
  offPropertyTypeBoolean = 2;
  offPropertyTypeDate = 3;
  offPropertyTypeString = 4;
  offPropertyTypeFloat = 5;

{ MsoDocProperties }

  msoPropertyTypeNumber = 1;
  msoPropertyTypeBoolean = 2;
  msoPropertyTypeDate = 3;
  msoPropertyTypeString = 4;
  msoPropertyTypeFloat = 5;

{ MsoAppLanguageID }

  msoLanguageIDInstall = 1;
  msoLanguageIDUI = 2;
  msoLanguageIDHelp = 3;
  msoLanguageIDExeMode = 4;
  msoLanguageIDUIPrevious = 5;

{ MsoFarEastLineBreakLanguageID }

  MsoFarEastLineBreakLanguageJapanese = 1041;
  MsoFarEastLineBreakLanguageKorean = 1042;
  MsoFarEastLineBreakLanguageSimplifiedChinese = 2052;
  MsoFarEastLineBreakLanguageTraditionalChinese = 1028;

{ MsoFeatureInstall }

  msoFeatureInstallNone = 0;
  msoFeatureInstallOnDemand = 1;
  msoFeatureInstallOnDemandWithUI = 2;

{ MsoScriptLanguage }

  msoScriptLanguageJava = 1;
  msoScriptLanguageVisualBasic = 2;
  msoScriptLanguageASP = 3;
  msoScriptLanguageOther = 4;

{ MsoScriptLocation }

  msoScriptLocationInHead = 1;
  msoScriptLocationInBody = 2;

{ MsoFileFindOptions }

  msoOptionsNew = 1;
  msoOptionsAdd = 2;
  msoOptionsWithin = 3;

{ MsoFileFindView }

  msoViewFileInfo = 1;
  msoViewPreview = 2;
  msoViewSummaryInfo = 3;

{ MsoFileFindSortBy }

  msoFileFindSortbyAuthor = 1;
  msoFileFindSortbyDateCreated = 2;
  msoFileFindSortbyLastSavedBy = 3;
  msoFileFindSortbyDateSaved = 4;
  msoFileFindSortbyFileName = 5;
  msoFileFindSortbySize = 6;
  msoFileFindSortbyTitle = 7;

{ MsoFileFindListBy }

  msoListbyName = 1;
  msoListbyTitle = 2;

{ MsoLastModified }

  msoLastModifiedYesterday = 1;
  msoLastModifiedToday = 2;
  msoLastModifiedLastWeek = 3;
  msoLastModifiedThisWeek = 4;
  msoLastModifiedLastMonth = 5;
  msoLastModifiedThisMonth = 6;
  msoLastModifiedAnyTime = 7;

{ MsoSortBy }

  msoSortByFileName = 1;
  msoSortBySize = 2;
  msoSortByFileType = 3;
  msoSortByLastModified = 4;

{ MsoSortOrder }

  msoSortOrderAscending = 1;
  msoSortOrderDescending = 2;

{ MsoConnector }

  msoConnectorAnd = 1;
  msoConnectorOr = 2;

{ MsoCondition }

  msoConditionFileTypeAllFiles = 1;
  msoConditionFileTypeOfficeFiles = 2;
  msoConditionFileTypeWordDocuments = 3;
  msoConditionFileTypeExcelWorkbooks = 4;
  msoConditionFileTypePowerPointPresentations = 5;
  msoConditionFileTypeBinders = 6;
  msoConditionFileTypeDatabases = 7;
  msoConditionFileTypeTemplates = 8;
  msoConditionIncludes = 9;
  msoConditionIncludesPhrase = 10;
  msoConditionBeginsWith = 11;
  msoConditionEndsWith = 12;
  msoConditionIncludesNearEachOther = 13;
  msoConditionIsExactly = 14;
  msoConditionIsNot = 15;
  msoConditionYesterday = 16;
  msoConditionToday = 17;
  msoConditionTomorrow = 18;
  msoConditionLastWeek = 19;
  msoConditionThisWeek = 20;
  msoConditionNextWeek = 21;
  msoConditionLastMonth = 22;
  msoConditionThisMonth = 23;
  msoConditionNextMonth = 24;
  msoConditionAnytime = 25;
  msoConditionAnytimeBetween = 26;
  msoConditionOn = 27;
  msoConditionOnOrAfter = 28;
  msoConditionOnOrBefore = 29;
  msoConditionInTheNext = 30;
  msoConditionInTheLast = 31;
  msoConditionEquals = 32;
  msoConditionDoesNotEqual = 33;
  msoConditionAnyNumberBetween = 34;
  msoConditionAtMost = 35;
  msoConditionAtLeast = 36;
  msoConditionMoreThan = 37;
  msoConditionLessThan = 38;
  msoConditionIsYes = 39;
  msoConditionIsNo = 40;

{ MsoFileType }

  msoFileTypeAllFiles = 1;
  msoFileTypeOfficeFiles = 2;
  msoFileTypeWordDocuments = 3;
  msoFileTypeExcelWorkbooks = 4;
  msoFileTypePowerPointPresentations = 5;
  msoFileTypeBinders = 6;
  msoFileTypeDatabases = 7;
  msoFileTypeTemplates = 8;

{ MsoLanguageID }

  msoLanguageIDMixed = -2;
  msoLanguageIDNone = 0;
  msoLanguageIDNoProofing = 1024;
  msoLanguageIDAfrikaans = 1078;
  msoLanguageIDAlbanian = 1052;
  msoLanguageIDArabicAlgeria = 5121;
  msoLanguageIDArabicBahrain = 15361;
  msoLanguageIDArabicEgypt = 3073;
  msoLanguageIDArabicIraq = 2049;
  msoLanguageIDArabicJordan = 11265;
  msoLanguageIDArabicKuwait = 13313;
  msoLanguageIDArabicLebanon = 12289;
  msoLanguageIDArabicLibya = 4097;
  msoLanguageIDArabicMorocco = 6145;
  msoLanguageIDArabicOman = 8193;
  msoLanguageIDArabicQatar = 16385;
  msoLanguageIDArabic = 1025;
  msoLanguageIDArabicSyria = 10241;
  msoLanguageIDArabicTunisia = 7169;
  msoLanguageIDArabicUAE = 14337;
  msoLanguageIDArabicYemen = 9217;
  msoLanguageIDArmenian = 1067;
  msoLanguageIDAssamese = 1101;
  msoLanguageIDAzeriCyrillic = 2092;
  msoLanguageIDAzeriLatin = 1068;
  msoLanguageIDBasque = 1069;
  msoLanguageIDByelorussian = 1059;
  msoLanguageIDBengali = 1093;
  msoLanguageIDBulgarian = 1026;
  msoLanguageIDBurmese = 1109;
  msoLanguageIDCatalan = 1027;
  msoLanguageIDChineseHongKong = 3076;
  msoLanguageIDChineseMacao = 5124;
  msoLanguageIDSimplifiedChinese = 2052;
  msoLanguageIDChineseSingapore = 4100;
  msoLanguageIDTraditionalChinese = 1028;
  msoLanguageIDCroatian = 1050;
  msoLanguageIDCzech = 1029;
  msoLanguageIDDanish = 1030;
  msoLanguageIDBelgianDutch = 2067;
  msoLanguageIDDutch = 1043;
  msoLanguageIDEnglishAUS = 3081;
  msoLanguageIDEnglishBelize = 10249;
  msoLanguageIDEnglishCanadian = 4105;
  msoLanguageIDEnglishCaribbean = 9225;
  msoLanguageIDEnglishIreland = 6153;
  msoLanguageIDEnglishJamaica = 8201;
  msoLanguageIDEnglishNewZealand = 5129;
  msoLanguageIDEnglishPhilippines = 13321;
  msoLanguageIDEnglishSouthAfrica = 7177;
  msoLanguageIDEnglishTrinidad = 11273;
  msoLanguageIDEnglishUK = 2057;
  msoLanguageIDEnglishUS = 1033;
  msoLanguageIDEnglishZimbabwe = 12297;
  msoLanguageIDEstonian = 1061;
  msoLanguageIDFaeroese = 1080;
  msoLanguageIDFarsi = 1065;
  msoLanguageIDFinnish = 1035;
  msoLanguageIDBelgianFrench = 2060;
  msoLanguageIDFrenchCameroon = 11276;
  msoLanguageIDFrenchCanadian = 3084;
  msoLanguageIDFrenchCotedIvoire = 12300;
  msoLanguageIDFrench = 1036;
  msoLanguageIDFrenchLuxembourg = 5132;
  msoLanguageIDFrenchMali = 13324;
  msoLanguageIDFrenchMonaco = 6156;
  msoLanguageIDFrenchReunion = 8204;
  msoLanguageIDFrenchSenegal = 10252;
  msoLanguageIDSwissFrench = 4108;
  msoLanguageIDFrenchWestIndies = 7180;
  msoLanguageIDFrenchZaire = 9228;
  msoLanguageIDFrisianNetherlands = 1122;
  msoLanguageIDGaelicIreland = 2108;
  msoLanguageIDGaelicScotland = 1084;
  msoLanguageIDGalician = 1110;
  msoLanguageIDGeorgian = 1079;
  msoLanguageIDGermanAustria = 3079;
  msoLanguageIDGerman = 1031;
  msoLanguageIDGermanLiechtenstein = 5127;
  msoLanguageIDGermanLuxembourg = 4103;
  msoLanguageIDSwissGerman = 2055;
  msoLanguageIDGreek = 1032;
  msoLanguageIDGujarati = 1095;
  msoLanguageIDHebrew = 1037;
  msoLanguageIDHindi = 1081;
  msoLanguageIDHungarian = 1038;
  msoLanguageIDIcelandic = 1039;
  msoLanguageIDIndonesian = 1057;
  msoLanguageIDItalian = 1040;
  msoLanguageIDSwissItalian = 2064;
  msoLanguageIDJapanese = 1041;
  msoLanguageIDKannada = 1099;
  msoLanguageIDKashmiri = 1120;
  msoLanguageIDKazakh = 1087;
  msoLanguageIDKhmer = 1107;
  msoLanguageIDKirghiz = 1088;
  msoLanguageIDKonkani = 1111;
  msoLanguageIDKorean = 1042;
  msoLanguageIDLao = 1108;
  msoLanguageIDLatvian = 1062;
  msoLanguageIDLithuanian = 1063;
  msoLanguageIDMacedonian = 1071;
  msoLanguageIDMalaysian = 1086;
  msoLanguageIDMalayBruneiDarussalam = 2110;
  msoLanguageIDMalayalam = 1100;
  msoLanguageIDMaltese = 1082;
  msoLanguageIDManipuri = 1112;
  msoLanguageIDMarathi = 1102;
  msoLanguageIDMongolian = 1104;
  msoLanguageIDNepali = 1121;
  msoLanguageIDNorwegianBokmol = 1044;
  msoLanguageIDNorwegianNynorsk = 2068;
  msoLanguageIDOriya = 1096;
  msoLanguageIDPolish = 1045;
  msoLanguageIDBrazilianPortuguese = 1046;
  msoLanguageIDPortuguese = 2070;
  msoLanguageIDPunjabi = 1094;
  msoLanguageIDRhaetoRomanic = 1047;
  msoLanguageIDRomanianMoldova = 2072;
  msoLanguageIDRomanian = 1048;
  msoLanguageIDRussianMoldova = 2073;
  msoLanguageIDRussian = 1049;
  msoLanguageIDSamiLappish = 1083;
  msoLanguageIDSanskrit = 1103;
  msoLanguageIDSerbianCyrillic = 3098;
  msoLanguageIDSerbianLatin = 2074;
  msoLanguageIDSesotho = 1072;
  msoLanguageIDSindhi = 1113;
  msoLanguageIDSlovak = 1051;
  msoLanguageIDSlovenian = 1060;
  msoLanguageIDSorbian = 1070;
  msoLanguageIDSpanishArgentina = 11274;
  msoLanguageIDSpanishBolivia = 16394;
  msoLanguageIDSpanishChile = 13322;
  msoLanguageIDSpanishColombia = 9226;
  msoLanguageIDSpanishCostaRica = 5130;
  msoLanguageIDSpanishDominicanRepublic = 7178;
  msoLanguageIDSpanishEcuador = 12298;
  msoLanguageIDSpanishElSalvador = 17418;
  msoLanguageIDSpanishGuatemala = 4106;
  msoLanguageIDSpanishHonduras = 18442;
  msoLanguageIDMexicanSpanish = 2058;
  msoLanguageIDSpanishNicaragua = 19466;
  msoLanguageIDSpanishPanama = 6154;
  msoLanguageIDSpanishParaguay = 15370;
  msoLanguageIDSpanishPeru = 10250;
  msoLanguageIDSpanishPuertoRico = 20490;
  msoLanguageIDSpanishModernSort = 3082;
  msoLanguageIDSpanish = 1034;
  msoLanguageIDSpanishUruguay = 14346;
  msoLanguageIDSpanishVenezuela = 8202;
  msoLanguageIDSutu = 1072;
  msoLanguageIDSwahili = 1089;
  msoLanguageIDSwedishFinland = 2077;
  msoLanguageIDSwedish = 1053;
  msoLanguageIDTajik = 1064;
  msoLanguageIDTamil = 1097;
  msoLanguageIDTatar = 1092;
  msoLanguageIDTelugu = 1098;
  msoLanguageIDThai = 1054;
  msoLanguageIDTibetan = 1105;
  msoLanguageIDTsonga = 1073;
  msoLanguageIDTswana = 1074;
  msoLanguageIDTurkish = 1055;
  msoLanguageIDTurkmen = 1090;
  msoLanguageIDUkrainian = 1058;
  msoLanguageIDUrdu = 1056;
  msoLanguageIDUzbekCyrillic = 2115;
  msoLanguageIDUzbekLatin = 1091;
  msoLanguageIDVenda = 1075;
  msoLanguageIDVietnamese = 1066;
  msoLanguageIDWelsh = 1106;
  msoLanguageIDXhosa = 1076;
  msoLanguageIDZulu = 1077;

{ MsoScreenSize }

  msoScreenSize544x376 = 0;
  msoScreenSize640x480 = 1;
  msoScreenSize720x512 = 2;
  msoScreenSize800x600 = 3;
  msoScreenSize1024x768 = 4;
  msoScreenSize1152x882 = 5;
  msoScreenSize1152x900 = 6;
  msoScreenSize1280x1024 = 7;
  msoScreenSize1600x1200 = 8;
  msoScreenSize1800x1440 = 9;
  msoScreenSize1920x1200 = 10;

{ MsoCharacterSet }

  msoCharacterSetArabic = 1;
  msoCharacterSetCyrillic = 2;
  msoCharacterSetEnglishWesternEuropeanOtherLatinScript = 3;
  msoCharacterSetGreek = 4;
  msoCharacterSetHebrew = 5;
  msoCharacterSetJapanese = 6;
  msoCharacterSetKorean = 7;
  msoCharacterSetMultilingualUnicode = 8;
  msoCharacterSetSimplifiedChinese = 9;
  msoCharacterSetThai = 10;
  msoCharacterSetTraditionalChinese = 11;
  msoCharacterSetVietnamese = 12;

{ MsoEncoding }

  msoEncodingThai = 874;
  msoEncodingJapaneseShiftJIS = 932;
  msoEncodingSimplifiedChineseGBK = 936;
  msoEncodingKorean = 949;
  msoEncodingTraditionalChineseBig5 = 950;
  msoEncodingUnicodeLittleEndian = 1200;
  msoEncodingUnicodeBigEndian = 1201;
  msoEncodingCentralEuropean = 1250;
  msoEncodingCyrillic = 1251;
  msoEncodingWestern = 1252;
  msoEncodingGreek = 1253;
  msoEncodingTurkish = 1254;
  msoEncodingHebrew = 1255;
  msoEncodingArabic = 1256;
  msoEncodingBaltic = 1257;
  msoEncodingVietnamese = 1258;
  msoEncodingAutoDetect = 50001;
  msoEncodingJapaneseAutoDetect = 50932;
  msoEncodingSimplifiedChineseAutoDetect = 50936;
  msoEncodingKoreanAutoDetect = 50949;
  msoEncodingTraditionalChineseAutoDetect = 50950;
  msoEncodingCyrillicAutoDetect = 51251;
  msoEncodingGreekAutoDetect = 51253;
  msoEncodingArabicAutoDetect = 51256;
  msoEncodingISO88591Latin1 = 28591;
  msoEncodingISO88592CentralEurope = 28592;
  msoEncodingISO88593Latin3 = 28593;
  msoEncodingISO88594Baltic = 28594;
  msoEncodingISO88595Cyrillic = 28595;
  msoEncodingISO88596Arabic = 28596;
  msoEncodingISO88597Greek = 28597;
  msoEncodingISO88598Hebrew = 28598;
  msoEncodingISO88599Turkish = 28599;
  msoEncodingISO885915Latin9 = 28605;
  msoEncodingISO2022JPNoHalfwidthKatakana = 50220;
  msoEncodingISO2022JPJISX02021984 = 50221;
  msoEncodingISO2022JPJISX02011989 = 50222;
  msoEncodingISO2022KR = 50225;
  msoEncodingISO2022CNTraditionalChinese = 50227;
  msoEncodingISO2022CNSimplifiedChinese = 50229;
  msoEncodingMacRoman = 10000;
  msoEncodingMacJapanese = 10001;
  msoEncodingMacTraditionalChineseBig5 = 10002;
  msoEncodingMacKorean = 10003;
  msoEncodingMacArabic = 10004;
  msoEncodingMacHebrew = 10005;
  msoEncodingMacGreek1 = 10006;
  msoEncodingMacCyrillic = 10007;
  msoEncodingMacSimplifiedChineseGB2312 = 10008;
  msoEncodingMacRomania = 10010;
  msoEncodingMacUkraine = 10017;
  msoEncodingMacLatin2 = 10029;
  msoEncodingMacIcelandic = 10079;
  msoEncodingMacTurkish = 10081;
  msoEncodingMacCroatia = 10082;
  msoEncodingEBCDICUSCanada = 37;
  msoEncodingEBCDICInternational = 500;
  msoEncodingEBCDICMultilingualROECELatin2 = 870;
  msoEncodingEBCDICGreekModern = 875;
  msoEncodingEBCDICTurkishLatin5 = 1026;
  msoEncodingEBCDICGermany = 20273;
  msoEncodingEBCDICDenmarkNorway = 20277;
  msoEncodingEBCDICFinlandSweden = 20278;
  msoEncodingEBCDICItaly = 20280;
  msoEncodingEBCDICLatinAmericaSpain = 20284;
  msoEncodingEBCDICUnitedKingdom = 20285;
  msoEncodingEBCDICJapaneseKatakanaExtended = 20290;
  msoEncodingEBCDICFrance = 20297;
  msoEncodingEBCDICArabic = 20420;
  msoEncodingEBCDICGreek = 20423;
  msoEncodingEBCDICHebrew = 20424;
  msoEncodingEBCDICKoreanExtended = 20833;
  msoEncodingEBCDICThai = 20838;
  msoEncodingEBCDICIcelandic = 20871;
  msoEncodingEBCDICTurkish = 20905;
  msoEncodingEBCDICRussian = 20880;
  msoEncodingEBCDICSerbianBulgarian = 21025;
  msoEncodingEBCDICJapaneseKatakanaExtendedAndJapanese = 50930;
  msoEncodingEBCDICUSCanadaandJapanese = 50931;
  msoEncodingEBCDICKoreanExtendedAndKorean = 50933;
  msoEncodingEBCDICSimplifiedChineseExtendedAndSimplifiedChinese = 50935;
  msoEncodingEBCDICUSCanadaAndTraditionalChinese = 50937;
  msoEncodingEBCDICJapaneseLatinExtendedAndJapanese = 50939;
  msoEncodingOEMUnitedStates = 437;
  msoEncodingOEMGreek437G = 737;
  msoEncodingOEMBaltic = 775;
  msoEncodingOEMMultilingualLatinI = 850;
  msoEncodingOEMMultilingualLatinII = 852;
  msoEncodingOEMCyrillic = 855;
  msoEncodingOEMTurkish = 857;
  msoEncodingOEMPortuguese = 860;
  msoEncodingOEMIcelandic = 861;
  msoEncodingOEMHebrew = 862;
  msoEncodingOEMCanadianFrench = 863;
  msoEncodingOEMArabic = 864;
  msoEncodingOEMNordic = 865;
  msoEncodingOEMCyrillicII = 866;
  msoEncodingOEMModernGreek = 869;
  msoEncodingEUCJapanese = 51932;
  msoEncodingEUCChineseSimplifiedChinese = 51936;
  msoEncodingEUCKorean = 51949;
  msoEncodingEUCTaiwaneseTraditionalChinese = 51950;
  msoEncodingArabicASMO = 708;
  msoEncodingArabicTransparentASMO = 720;
  msoEncodingKoreanJohab = 1361;
  msoEncodingTaiwanCNS = 20000;
  msoEncodingTaiwanTCA = 20001;
  msoEncodingTaiwanEten = 20002;
  msoEncodingTaiwanIBM5550 = 20003;
  msoEncodingTaiwanTeleText = 20004;
  msoEncodingTaiwanWang = 20005;
  msoEncodingIA5IRV = 20105;
  msoEncodingIA5German = 20106;
  msoEncodingIA5Swedish = 20107;
  msoEncodingIA5Norwegian = 20108;
  msoEncodingUSASCII = 20127;
  msoEncodingT61 = 20261;
  msoEncodingISO6937NonSpacingAccent = 20269;
  msoEncodingKOI8R = 20866;
  msoEncodingExtAlphaLowercase = 21027;
  msoEncodingKOI8U = 21866;
  msoEncodingEuropa3 = 29001;
  msoEncodingHZGBSimplifiedChinese = 52936;
  msoEncodingUTF7 = 65000;
  msoEncodingUTF8 = 65001;

{ MsoHTMLProjectOpen }

  msoHTMLProjectOpenSourceView = 1;
  msoHTMLProjectOpenTextView = 2;

{ MsoHTMLProjectState }

  msoHTMLProjectStateDocumentLocked = 1;
  msoHTMLProjectStateProjectLocked = 2;
  msoHTMLProjectStateDocumentProjectUnlocked = 3;

const

{ Component class GUIDs }
  Class_CommandBars: TGUID = '{55F88893-7708-11D1-ACEB-006008961DA5}';
  Class_CommandBarComboBox: TGUID = '{55F88897-7708-11D1-ACEB-006008961DA5}';
  Class_CommandBarButton: TGUID = '{55F88891-7708-11D1-ACEB-006008961DA5}';

type

{ Forward declarations: Interfaces }
  IAccessible = interface;
  IAccessibleDisp = dispinterface;
  _IMsoDispObj = interface;
  _IMsoDispObjDisp = dispinterface;
  _IMsoOleAccDispObj = interface;
  _IMsoOleAccDispObjDisp = dispinterface;
  _CommandBars = interface;
  _CommandBarsDisp = dispinterface;
  CommandBar = interface;
  CommandBarDisp = dispinterface;
  CommandBarControls = interface;
  CommandBarControlsDisp = dispinterface;
  CommandBarControl = interface;
  CommandBarControlDisp = dispinterface;
  _CommandBarButton = interface;
  _CommandBarButtonDisp = dispinterface;
  CommandBarPopup = interface;
  CommandBarPopupDisp = dispinterface;
  _CommandBarComboBox = interface;
  _CommandBarComboBoxDisp = dispinterface;
  _CommandBarActiveX = interface;
  _CommandBarActiveXDisp = dispinterface;
  Adjustments = interface;
  AdjustmentsDisp = dispinterface;
  CalloutFormat = interface;
  CalloutFormatDisp = dispinterface;
  ColorFormat = interface;
  ColorFormatDisp = dispinterface;
  ConnectorFormat = interface;
  ConnectorFormatDisp = dispinterface;
  FillFormat = interface;
  FillFormatDisp = dispinterface;
  FreeformBuilder = interface;
  FreeformBuilderDisp = dispinterface;
  GroupShapes = interface;
  GroupShapesDisp = dispinterface;
  LineFormat = interface;
  LineFormatDisp = dispinterface;
  ShapeNode = interface;
  ShapeNodeDisp = dispinterface;
  ShapeNodes = interface;
  ShapeNodesDisp = dispinterface;
  PictureFormat = interface;
  PictureFormatDisp = dispinterface;
  ShadowFormat = interface;
  ShadowFormatDisp = dispinterface;
  Script = interface;
  ScriptDisp = dispinterface;
  Scripts = interface;
  ScriptsDisp = dispinterface;
  Shape = interface;
  ShapeDisp = dispinterface;
  ShapeRange = interface;
  ShapeRangeDisp = dispinterface;
  Shapes = interface;
  ShapesDisp = dispinterface;
  TextEffectFormat = interface;
  TextEffectFormatDisp = dispinterface;
  TextFrame = interface;
  TextFrameDisp = dispinterface;
  ThreeDFormat = interface;
  ThreeDFormatDisp = dispinterface;
  IMsoDispCagNotifySink = interface;
  IMsoDispCagNotifySinkDisp = dispinterface;
  Balloon = interface;
  BalloonDisp = dispinterface;
  BalloonCheckboxes = interface;
  BalloonCheckboxesDisp = dispinterface;
  BalloonCheckbox = interface;
  BalloonCheckboxDisp = dispinterface;
  BalloonLabels = interface;
  BalloonLabelsDisp = dispinterface;
  BalloonLabel = interface;
  BalloonLabelDisp = dispinterface;
  AnswerWizardFiles = interface;
  AnswerWizardFilesDisp = dispinterface;
  AnswerWizard = interface;
  AnswerWizardDisp = dispinterface;
  Assistant = interface;
  AssistantDisp = dispinterface;
  DocumentProperty = interface;
  DocumentProperties = interface;
  IFoundFiles = interface;
  IFoundFilesDisp = dispinterface;
  IFind = interface;
  IFindDisp = dispinterface;
  FoundFiles = interface;
  FoundFilesDisp = dispinterface;
  PropertyTest = interface;
  PropertyTestDisp = dispinterface;
  PropertyTests = interface;
  PropertyTestsDisp = dispinterface;
  FileSearch = interface;
  FileSearchDisp = dispinterface;
  COMAddIn = interface;
  COMAddInDisp = dispinterface;
  COMAddIns = interface;
  COMAddInsDisp = dispinterface;
  LanguageSettings = interface;
  LanguageSettingsDisp = dispinterface;
  ICommandBarsEvents = interface;
  ICommandBarsEventsDisp = dispinterface;
  _CommandBarsEvents = dispinterface;
  ICommandBarComboBoxEvents = interface;
  ICommandBarComboBoxEventsDisp = dispinterface;
  _CommandBarComboBoxEvents = dispinterface;
  ICommandBarButtonEvents = interface;
  ICommandBarButtonEventsDisp = dispinterface;
  _CommandBarButtonEvents = dispinterface;
  WebPageFont = interface;
  WebPageFontDisp = dispinterface;
  WebPageFonts = interface;
  WebPageFontsDisp = dispinterface;
  HTMLProjectItem = interface;
  HTMLProjectItemDisp = dispinterface;
  HTMLProjectItems = interface;
  HTMLProjectItemsDisp = dispinterface;
  HTMLProject = interface;
  HTMLProjectDisp = dispinterface;
  MsoDebugOptions = interface;
  MsoDebugOptionsDisp = dispinterface;

{ Forward declarations: CoClasses }

{ Forward declarations: Enums }
  MsoLineDashStyle = TOleEnum;
  MsoLineStyle = TOleEnum;
  MsoArrowheadStyle = TOleEnum;
  MsoArrowheadWidth = TOleEnum;
  MsoArrowheadLength = TOleEnum;
  MsoFillType = TOleEnum;
  MsoGradientStyle = TOleEnum;
  MsoGradientColorType = TOleEnum;
  MsoTextureType = TOleEnum;
  MsoPresetTexture = TOleEnum;
  MsoPatternType = TOleEnum;
  MsoPresetGradientType = TOleEnum;
  MsoShadowType = TOleEnum;
  MsoPresetTextEffect = TOleEnum;
  MsoPresetTextEffectShape = TOleEnum;
  MsoTextEffectAlignment = TOleEnum;
  MsoPresetLightingDirection = TOleEnum;
  MsoPresetLightingSoftness = TOleEnum;
  MsoPresetMaterial = TOleEnum;
  MsoPresetExtrusionDirection = TOleEnum;
  MsoPresetThreeDFormat = TOleEnum;
  MsoExtrusionColorType = TOleEnum;
  MsoAlignCmd = TOleEnum;
  MsoDistributeCmd = TOleEnum;
  MsoConnectorType = TOleEnum;
  MsoHorizontalAnchor = TOleEnum;
  MsoVerticalAnchor = TOleEnum;
  MsoOrientation = TOleEnum;
  MsoZOrderCmd = TOleEnum;
  MsoSegmentType = TOleEnum;
  MsoEditingType = TOleEnum;
  MsoAutoShapeType = TOleEnum;
  MsoShapeType = TOleEnum;
  MsoFlipCmd = TOleEnum;
  MsoTriState = TOleEnum;
  MsoColorType = TOleEnum;
  MsoPictureColorType = TOleEnum;
  MsoCalloutAngleType = TOleEnum;
  MsoCalloutDropType = TOleEnum;
  MsoCalloutType = TOleEnum;
  MsoBlackWhiteMode = TOleEnum;
  MsoMixedType = TOleEnum;
  MsoTextOrientation = TOleEnum;
  MsoScaleFrom = TOleEnum;
  MsoBarPosition = TOleEnum;
  MsoBarProtection = TOleEnum;
  MsoBarType = TOleEnum;
  MsoControlType = TOleEnum;
  MsoButtonState = TOleEnum;
  MsoControlOLEUsage = TOleEnum;
  MsoButtonStyleHidden = TOleEnum;
  MsoButtonStyle = TOleEnum;
  MsoComboStyle = TOleEnum;
  MsoOLEMenuGroup = TOleEnum;
  MsoMenuAnimation = TOleEnum;
  MsoBarRow = TOleEnum;
  MsoCommandBarButtonHyperlinkType = TOleEnum;
  MsoHyperlinkType = TOleEnum;
  MsoExtraInfoMethod = TOleEnum;
  MsoAnimationType = TOleEnum;
  MsoButtonSetType = TOleEnum;
  MsoIconType = TOleEnum;
  MsoBalloonType = TOleEnum;
  MsoModeType = TOleEnum;
  MsoBalloonErrorType = TOleEnum;
  MsoWizardActType = TOleEnum;
  MsoWizardMsgType = TOleEnum;
  MsoBalloonButtonType = TOleEnum;
  DocProperties = TOleEnum;
  MsoDocProperties = TOleEnum;
  MsoAppLanguageID = TOleEnum;
  MsoFarEastLineBreakLanguageID = TOleEnum;
  MsoFeatureInstall = TOleEnum;
  MsoScriptLanguage = TOleEnum;
  MsoScriptLocation = TOleEnum;
  MsoFileFindOptions = TOleEnum;
  MsoFileFindView = TOleEnum;
  MsoFileFindSortBy = TOleEnum;
  MsoFileFindListBy = TOleEnum;
  MsoLastModified = TOleEnum;
  MsoSortBy = TOleEnum;
  MsoSortOrder = TOleEnum;
  MsoConnector = TOleEnum;
  MsoCondition = TOleEnum;
  MsoFileType = TOleEnum;
  MsoLanguageID = TOleEnum;
  MsoScreenSize = TOleEnum;
  MsoCharacterSet = TOleEnum;
  MsoEncoding = TOleEnum;
  MsoHTMLProjectOpen = TOleEnum;
  MsoHTMLProjectState = TOleEnum;

  MsoRGBType = Integer;

  IAccessible = interface(IDispatch)
    ['{618736E0-3C3D-11CF-810C-00AA00389B71}']
    function Get_accParent: IDispatch; safecall;
    function Get_accChildCount: Integer; safecall;
    function Get_accChild(varChild: OleVariant): IDispatch; safecall;
    function Get_accName(varChild: OleVariant): WideString; safecall;
    function Get_accValue(varChild: OleVariant): WideString; safecall;
    function Get_accDescription(varChild: OleVariant): WideString; safecall;
    function Get_accRole(varChild: OleVariant): OleVariant; safecall;
    function Get_accState(varChild: OleVariant): OleVariant; safecall;
    function Get_accHelp(varChild: OleVariant): WideString; safecall;
    function Get_accHelpTopic(out pszHelpFile: WideString; varChild: OleVariant): Integer; safecall;
    function Get_accKeyboardShortcut(varChild: OleVariant): WideString; safecall;
    function Get_accFocus: OleVariant; safecall;
    function Get_accSelection: OleVariant; safecall;
    function Get_accDefaultAction(varChild: OleVariant): WideString; safecall;
    procedure accSelect(flagsSelect: Integer; varChild: OleVariant); safecall;
    procedure accLocation(out pxLeft, pyTop, pcxWidth, pcyHeight: Integer; varChild: OleVariant); safecall;
    function accNavigate(navDir: Integer; varStart: OleVariant): OleVariant; safecall;
    function accHitTest(xLeft, yTop: Integer): OleVariant; safecall;
    procedure accDoDefaultAction(varChild: OleVariant); safecall;
    procedure Set_accName(varChild: OleVariant; const Value: WideString); safecall;
    procedure Set_accValue(varChild: OleVariant; const Value: WideString); safecall;
    property accParent: IDispatch read Get_accParent;
    property accChildCount: Integer read Get_accChildCount;
    property accChild[varChild: OleVariant]: IDispatch read Get_accChild;
    property accName[varChild: OleVariant]: WideString read Get_accName write Set_accName;
    property accValue[varChild: OleVariant]: WideString read Get_accValue write Set_accValue;
    property accDescription[varChild: OleVariant]: WideString read Get_accDescription;
    property accRole[varChild: OleVariant]: OleVariant read Get_accRole;
    property accState[varChild: OleVariant]: OleVariant read Get_accState;
    property accHelp[varChild: OleVariant]: WideString read Get_accHelp;
    property accHelpTopic[out pszHelpFile: WideString; varChild: OleVariant]: Integer read Get_accHelpTopic;
    property accKeyboardShortcut[varChild: OleVariant]: WideString read Get_accKeyboardShortcut;
    property accFocus: OleVariant read Get_accFocus;
    property accSelection: OleVariant read Get_accSelection;
    property accDefaultAction[varChild: OleVariant]: WideString read Get_accDefaultAction;
  end;

{ DispInterface declaration for Dual Interface IAccessible }

  IAccessibleDisp = dispinterface
    ['{618736E0-3C3D-11CF-810C-00AA00389B71}']
    property accParent: IDispatch readonly dispid -5000;
    property accChildCount: Integer readonly dispid -5001;
    property accChild[varChild: OleVariant]: IDispatch readonly dispid -5002;
    property accName[varChild: OleVariant]: WideString dispid -5003;
    property accValue[varChild: OleVariant]: WideString dispid -5004;
    property accDescription[varChild: OleVariant]: WideString readonly dispid -5005;
    property accRole[varChild: OleVariant]: OleVariant readonly dispid -5006;
    property accState[varChild: OleVariant]: OleVariant readonly dispid -5007;
    property accHelp[varChild: OleVariant]: WideString readonly dispid -5008;
    property accHelpTopic[out pszHelpFile: WideString; varChild: OleVariant]: Integer readonly dispid -5009;
    property accKeyboardShortcut[varChild: OleVariant]: WideString readonly dispid -5010;
    property accFocus: OleVariant readonly dispid -5011;
    property accSelection: OleVariant readonly dispid -5012;
    property accDefaultAction[varChild: OleVariant]: WideString readonly dispid -5013;
    procedure accSelect(flagsSelect: Integer; varChild: OleVariant); dispid -5014;
    procedure accLocation(out pxLeft, pyTop, pcxWidth, pcyHeight: Integer; varChild: OleVariant); dispid -5015;
    function accNavigate(navDir: Integer; varStart: OleVariant): OleVariant; dispid -5016;
    function accHitTest(xLeft, yTop: Integer): OleVariant; dispid -5017;
    procedure accDoDefaultAction(varChild: OleVariant); dispid -5018;
  end;

  _IMsoDispObj = interface(IDispatch)
    ['{000C0300-0000-0000-C000-000000000046}']
    function Get_Application: IDispatch; safecall;
    function Get_Creator: Integer; safecall;
    property Application: IDispatch read Get_Application;
    property Creator: Integer read Get_Creator;
  end;

{ DispInterface declaration for Dual Interface _IMsoDispObj }

  _IMsoDispObjDisp = dispinterface
    ['{000C0300-0000-0000-C000-000000000046}']
    property Application: IDispatch readonly dispid 1610743808;
    property Creator: Integer readonly dispid 1610743809;
  end;

  _IMsoOleAccDispObj = interface(IAccessible)
    ['{000C0301-0000-0000-C000-000000000046}']
    function Get_Application: IDispatch; safecall;
    function Get_Creator: Integer; safecall;
    property Application: IDispatch read Get_Application;
    property Creator: Integer read Get_Creator;
  end;

{ DispInterface declaration for Dual Interface _IMsoOleAccDispObj }

  _IMsoOleAccDispObjDisp = dispinterface
    ['{000C0301-0000-0000-C000-000000000046}']
    property Application: IDispatch readonly dispid 1610809344;
    property Creator: Integer readonly dispid 1610809345;
  end;

  _CommandBars = interface(_IMsoDispObj)
    ['{000C0302-0000-0000-C000-000000000046}']
    function Get_ActionControl: CommandBarControl; safecall;
    function Get_ActiveMenuBar: CommandBar; safecall;
    function Add(Name, Position, MenuBar, Temporary: OleVariant): CommandBar; safecall;
    function Get_Count: SYSINT; safecall;
    function Get_DisplayTooltips: WordBool; safecall;
    procedure Set_DisplayTooltips(Value: WordBool); safecall;
    function Get_DisplayKeysInTooltips: WordBool; safecall;
    procedure Set_DisplayKeysInTooltips(Value: WordBool); safecall;
    function FindControl(Type_, Id, Tag, Visible: OleVariant): CommandBarControl; safecall;
    function Get_Item(Index: OleVariant): CommandBar; safecall;
    function Get_LargeButtons: WordBool; safecall;
    procedure Set_LargeButtons(Value: WordBool); safecall;
    function Get_MenuAnimationStyle: MsoMenuAnimation; safecall;
    procedure Set_MenuAnimationStyle(Value: MsoMenuAnimation); safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_Parent: IDispatch; safecall;
    procedure ReleaseFocus; safecall;
    function Get_IdsString(ids: SYSINT; out pbstrName: WideString): SYSINT; safecall;
    function Get_TmcGetName(tmc: SYSINT; out pbstrName: WideString): SYSINT; safecall;
    function Get_AdaptiveMenus: WordBool; safecall;
    procedure Set_AdaptiveMenus(Value: WordBool); safecall;
    function FindControls(Type_, Id, Tag, Visible: OleVariant): CommandBarControls; safecall;
    function AddEx(TbidOrName, Position, MenuBar, Temporary, TbtrProtection: OleVariant): CommandBar; safecall;
    function Get_DisplayFonts: WordBool; safecall;
    procedure Set_DisplayFonts(Value: WordBool); safecall;
    property ActionControl: CommandBarControl read Get_ActionControl;
    property ActiveMenuBar: CommandBar read Get_ActiveMenuBar;
    property Count: SYSINT read Get_Count;
    property DisplayTooltips: WordBool read Get_DisplayTooltips write Set_DisplayTooltips;
    property DisplayKeysInTooltips: WordBool read Get_DisplayKeysInTooltips write Set_DisplayKeysInTooltips;
    property Item[Index: OleVariant]: CommandBar read Get_Item; default;
    property LargeButtons: WordBool read Get_LargeButtons write Set_LargeButtons;
    property MenuAnimationStyle: MsoMenuAnimation read Get_MenuAnimationStyle write Set_MenuAnimationStyle;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Parent: IDispatch read Get_Parent;
    property IdsString[ids: SYSINT; out pbstrName: WideString]: SYSINT read Get_IdsString;
    property TmcGetName[tmc: SYSINT; out pbstrName: WideString]: SYSINT read Get_TmcGetName;
    property AdaptiveMenus: WordBool read Get_AdaptiveMenus write Set_AdaptiveMenus;
    property DisplayFonts: WordBool read Get_DisplayFonts write Set_DisplayFonts;
  end;

{ DispInterface declaration for Dual Interface _CommandBars }

  _CommandBarsDisp = dispinterface
    ['{000C0302-0000-0000-C000-000000000046}']
    property ActionControl: CommandBarControl readonly dispid 1610809344;
    property ActiveMenuBar: CommandBar readonly dispid 1610809345;
    function Add(Name, Position, MenuBar, Temporary: OleVariant): CommandBar; dispid 1610809346;
    property Count: SYSINT readonly dispid 1610809347;
    property DisplayTooltips: WordBool dispid 1610809348;
    property DisplayKeysInTooltips: WordBool dispid 1610809350;
    function FindControl(Type_, Id, Tag, Visible: OleVariant): CommandBarControl; dispid 1610809352;
    property Item[Index: OleVariant]: CommandBar readonly dispid 0; default;
    property LargeButtons: WordBool dispid 1610809354;
    property MenuAnimationStyle: MsoMenuAnimation dispid 1610809356;
    property _NewEnum: IUnknown readonly dispid -4;
    property Parent: IDispatch readonly dispid 1610809359;
    procedure ReleaseFocus; dispid 1610809360;
    property IdsString[ids: SYSINT; out pbstrName: WideString]: SYSINT readonly dispid 1610809361;
    property TmcGetName[tmc: SYSINT; out pbstrName: WideString]: SYSINT readonly dispid 1610809362;
    property AdaptiveMenus: WordBool dispid 1610809363;
    function FindControls(Type_, Id, Tag, Visible: OleVariant): CommandBarControls; dispid 1610809365;
    function AddEx(TbidOrName, Position, MenuBar, Temporary, TbtrProtection: OleVariant): CommandBar; dispid 1610809366;
    property DisplayFonts: WordBool dispid 1610809367;
  end;

  CommandBar = interface(_IMsoOleAccDispObj)
    ['{000C0304-0000-0000-C000-000000000046}']
    function Get_BuiltIn: WordBool; safecall;
    function Get_Context: WideString; safecall;
    procedure Set_Context(const Value: WideString); safecall;
    function Get_Controls: CommandBarControls; safecall;
    procedure Delete; safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function FindControl(Type_, Id, Tag, Visible, Recursive: OleVariant): CommandBarControl; safecall;
    function Get_Height: SYSINT; safecall;
    procedure Set_Height(Value: SYSINT); safecall;
    function Get_Index: SYSINT; safecall;
    function Get_InstanceId: Integer; safecall;
    function Get_Left: SYSINT; safecall;
    procedure Set_Left(Value: SYSINT); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_NameLocal: WideString; safecall;
    procedure Set_NameLocal(const Value: WideString); safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Position: MsoBarPosition; safecall;
    procedure Set_Position(Value: MsoBarPosition); safecall;
    function Get_RowIndex: SYSINT; safecall;
    procedure Set_RowIndex(Value: SYSINT); safecall;
    function Get_Protection: MsoBarProtection; safecall;
    procedure Set_Protection(Value: MsoBarProtection); safecall;
    procedure Reset; safecall;
    procedure ShowPopup(x, y: OleVariant); safecall;
    function Get_Top: SYSINT; safecall;
    procedure Set_Top(Value: SYSINT); safecall;
    function Get_Type_: MsoBarType; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Width: SYSINT; safecall;
    procedure Set_Width(Value: SYSINT); safecall;
    function Get_AdaptiveMenu: WordBool; safecall;
    procedure Set_AdaptiveMenu(Value: WordBool); safecall;
    property BuiltIn: WordBool read Get_BuiltIn;
    property Context: WideString read Get_Context write Set_Context;
    property Controls: CommandBarControls read Get_Controls;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Height: SYSINT read Get_Height write Set_Height;
    property Index: SYSINT read Get_Index;
    property InstanceId: Integer read Get_InstanceId;
    property Left: SYSINT read Get_Left write Set_Left;
    property Name: WideString read Get_Name write Set_Name;
    property NameLocal: WideString read Get_NameLocal write Set_NameLocal;
    property Parent: IDispatch read Get_Parent;
    property Position: MsoBarPosition read Get_Position write Set_Position;
    property RowIndex: SYSINT read Get_RowIndex write Set_RowIndex;
    property Protection: MsoBarProtection read Get_Protection write Set_Protection;
    property Top: SYSINT read Get_Top write Set_Top;
    property Type_: MsoBarType read Get_Type_;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Width: SYSINT read Get_Width write Set_Width;
    property AdaptiveMenu: WordBool read Get_AdaptiveMenu write Set_AdaptiveMenu;
  end;

{ DispInterface declaration for Dual Interface CommandBar }

  CommandBarDisp = dispinterface
    ['{000C0304-0000-0000-C000-000000000046}']
    property BuiltIn: WordBool readonly dispid 1610874880;
    property Context: WideString dispid 1610874881;
    property Controls: CommandBarControls readonly dispid 1610874883;
    procedure Delete; dispid 1610874884;
    property Enabled: WordBool dispid 1610874885;
    function FindControl(Type_, Id, Tag, Visible, Recursive: OleVariant): CommandBarControl; dispid 1610874887;
    property Height: SYSINT dispid 1610874888;
    property Index: SYSINT readonly dispid 1610874890;
    property InstanceId: Integer readonly dispid 1610874891;
    property Left: SYSINT dispid 1610874892;
    property Name: WideString dispid 1610874894;
    property NameLocal: WideString dispid 1610874896;
    property Parent: IDispatch readonly dispid 1610874898;
    property Position: MsoBarPosition dispid 1610874899;
    property RowIndex: SYSINT dispid 1610874901;
    property Protection: MsoBarProtection dispid 1610874903;
    procedure Reset; dispid 1610874905;
    procedure ShowPopup(x, y: OleVariant); dispid 1610874906;
    property Top: SYSINT dispid 1610874907;
    property Type_: MsoBarType readonly dispid 1610874909;
    property Visible: WordBool dispid 1610874910;
    property Width: SYSINT dispid 1610874912;
    property AdaptiveMenu: WordBool dispid 1610874914;
  end;

  CommandBarControls = interface(_IMsoDispObj)
    ['{000C0306-0000-0000-C000-000000000046}']
    function Add(Type_, Id, Parameter, Before, Temporary: OleVariant): CommandBarControl; safecall;
    function Get_Count: SYSINT; safecall;
    function Get_Item(Index: OleVariant): CommandBarControl; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_Parent: CommandBar; safecall;
    property Count: SYSINT read Get_Count;
    property Item[Index: OleVariant]: CommandBarControl read Get_Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Parent: CommandBar read Get_Parent;
  end;

{ DispInterface declaration for Dual Interface CommandBarControls }

  CommandBarControlsDisp = dispinterface
    ['{000C0306-0000-0000-C000-000000000046}']
    function Add(Type_, Id, Parameter, Before, Temporary: OleVariant): CommandBarControl; dispid 1610809344;
    property Count: SYSINT readonly dispid 1610809345;
    property Item[Index: OleVariant]: CommandBarControl readonly dispid 0; default;
    property _NewEnum: IUnknown readonly dispid -4;
    property Parent: CommandBar readonly dispid 1610809348;
  end;

  CommandBarControl = interface(_IMsoOleAccDispObj)
    ['{000C0308-0000-0000-C000-000000000046}']
    function Get_BeginGroup: WordBool; safecall;
    procedure Set_BeginGroup(Value: WordBool); safecall;
    function Get_BuiltIn: WordBool; safecall;
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function Get_Control: IDispatch; safecall;
    function Copy(Bar, Before: OleVariant): CommandBarControl; safecall;
    procedure Delete(Temporary: OleVariant); safecall;
    function Get_DescriptionText: WideString; safecall;
    procedure Set_DescriptionText(const Value: WideString); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Execute; safecall;
    function Get_Height: SYSINT; safecall;
    procedure Set_Height(Value: SYSINT); safecall;
    function Get_HelpContextId: SYSINT; safecall;
    procedure Set_HelpContextId(Value: SYSINT); safecall;
    function Get_HelpFile: WideString; safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    function Get_Id: SYSINT; safecall;
    function Get_Index: SYSINT; safecall;
    function Get_InstanceId: Integer; safecall;
    function Move(Bar, Before: OleVariant): CommandBarControl; safecall;
    function Get_Left: SYSINT; safecall;
    function Get_OLEUsage: MsoControlOLEUsage; safecall;
    procedure Set_OLEUsage(Value: MsoControlOLEUsage); safecall;
    function Get_OnAction: WideString; safecall;
    procedure Set_OnAction(const Value: WideString); safecall;
    function Get_Parent: CommandBar; safecall;
    function Get_Parameter: WideString; safecall;
    procedure Set_Parameter(const Value: WideString); safecall;
    function Get_Priority: SYSINT; safecall;
    procedure Set_Priority(Value: SYSINT); safecall;
    procedure Reset; safecall;
    procedure SetFocus; safecall;
    function Get_Tag: WideString; safecall;
    procedure Set_Tag(const Value: WideString); safecall;
    function Get_TooltipText: WideString; safecall;
    procedure Set_TooltipText(const Value: WideString); safecall;
    function Get_Top: SYSINT; safecall;
    function Get_Type_: MsoControlType; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Width: SYSINT; safecall;
    procedure Set_Width(Value: SYSINT); safecall;
    function Get_IsPriorityDropped: WordBool; safecall;
    procedure Reserved1; safecall;
    procedure Reserved2; safecall;
    procedure Reserved3; safecall;
    procedure Reserved4; safecall;
    procedure Reserved5; safecall;
    procedure Reserved6; safecall;
    procedure Reserved7; safecall;
    property BeginGroup: WordBool read Get_BeginGroup write Set_BeginGroup;
    property BuiltIn: WordBool read Get_BuiltIn;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Control: IDispatch read Get_Control;
    property DescriptionText: WideString read Get_DescriptionText write Set_DescriptionText;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Height: SYSINT read Get_Height write Set_Height;
    property HelpContextId: SYSINT read Get_HelpContextId write Set_HelpContextId;
    property HelpFile: WideString read Get_HelpFile write Set_HelpFile;
    property Id: SYSINT read Get_Id;
    property Index: SYSINT read Get_Index;
    property InstanceId: Integer read Get_InstanceId;
    property Left: SYSINT read Get_Left;
    property OLEUsage: MsoControlOLEUsage read Get_OLEUsage write Set_OLEUsage;
    property OnAction: WideString read Get_OnAction write Set_OnAction;
    property Parent: CommandBar read Get_Parent;
    property Parameter: WideString read Get_Parameter write Set_Parameter;
    property Priority: SYSINT read Get_Priority write Set_Priority;
    property Tag: WideString read Get_Tag write Set_Tag;
    property TooltipText: WideString read Get_TooltipText write Set_TooltipText;
    property Top: SYSINT read Get_Top;
    property Type_: MsoControlType read Get_Type_;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Width: SYSINT read Get_Width write Set_Width;
    property IsPriorityDropped: WordBool read Get_IsPriorityDropped;
  end;

{ DispInterface declaration for Dual Interface CommandBarControl }

  CommandBarControlDisp = dispinterface
    ['{000C0308-0000-0000-C000-000000000046}']
    property Application: IDispatch readonly dispid 1610809344;
    property Creator: Integer readonly dispid 1610809345;
    property BeginGroup: WordBool dispid 1610874880;
    property BuiltIn: WordBool readonly dispid 1610874882;
    property Caption: WideString dispid 1610874883;
    property Control: IDispatch readonly dispid 1610874885;
    function Copy(Bar, Before: OleVariant): CommandBarControl; dispid 1610874886;
    procedure Delete(Temporary: OleVariant); dispid 1610874887;
    property DescriptionText: WideString dispid 1610874888;
    property Enabled: WordBool dispid 1610874890;
    procedure Execute; dispid 1610874892;
    property Height: SYSINT dispid 1610874893;
    property HelpContextId: SYSINT dispid 1610874895;
    property HelpFile: WideString dispid 1610874897;
    property Id: SYSINT readonly dispid 1610874899;
    property Index: SYSINT readonly dispid 1610874900;
    property InstanceId: Integer readonly dispid 1610874901;
    function Move(Bar, Before: OleVariant): CommandBarControl; dispid 1610874902;
    property Left: SYSINT readonly dispid 1610874903;
    property OLEUsage: MsoControlOLEUsage dispid 1610874904;
    property OnAction: WideString dispid 1610874906;
    property Parent: CommandBar readonly dispid 1610874908;
    property Parameter: WideString dispid 1610874909;
    property Priority: SYSINT dispid 1610874911;
    procedure Reset; dispid 1610874913;
    procedure SetFocus; dispid 1610874914;
    property Tag: WideString dispid 1610874915;
    property TooltipText: WideString dispid 1610874917;
    property Top: SYSINT readonly dispid 1610874919;
    property Type_: MsoControlType readonly dispid 1610874920;
    property Visible: WordBool dispid 1610874921;
    property Width: SYSINT dispid 1610874923;
    property IsPriorityDropped: WordBool readonly dispid 1610874925;
    procedure Reserved1; dispid 1610874926;
    procedure Reserved2; dispid 1610874927;
    procedure Reserved3; dispid 1610874928;
    procedure Reserved4; dispid 1610874929;
    procedure Reserved5; dispid 1610874930;
    procedure Reserved6; dispid 1610874931;
    procedure Reserved7; dispid 1610874932;
  end;

  _CommandBarButton = interface(CommandBarControl)
    ['{000C030E-0000-0000-C000-000000000046}']
    function Get_BuiltInFace: WordBool; safecall;
    procedure Set_BuiltInFace(Value: WordBool); safecall;
    procedure CopyFace; safecall;
    function Get_FaceId: SYSINT; safecall;
    procedure Set_FaceId(Value: SYSINT); safecall;
    procedure PasteFace; safecall;
    function Get_ShortcutText: WideString; safecall;
    procedure Set_ShortcutText(const Value: WideString); safecall;
    function Get_State: MsoButtonState; safecall;
    procedure Set_State(Value: MsoButtonState); safecall;
    function Get_Style: MsoButtonStyle; safecall;
    procedure Set_Style(Value: MsoButtonStyle); safecall;
    function Get_HyperlinkType: MsoCommandBarButtonHyperlinkType; safecall;
    procedure Set_HyperlinkType(Value: MsoCommandBarButtonHyperlinkType); safecall;
    property BuiltInFace: WordBool read Get_BuiltInFace write Set_BuiltInFace;
    property FaceId: SYSINT read Get_FaceId write Set_FaceId;
    property ShortcutText: WideString read Get_ShortcutText write Set_ShortcutText;
    property State: MsoButtonState read Get_State write Set_State;
    property Style: MsoButtonStyle read Get_Style write Set_Style;
    property HyperlinkType: MsoCommandBarButtonHyperlinkType read Get_HyperlinkType write Set_HyperlinkType;
  end;

{ DispInterface declaration for Dual Interface _CommandBarButton }

  _CommandBarButtonDisp = dispinterface
    ['{000C030E-0000-0000-C000-000000000046}']
    property BuiltInFace: WordBool dispid 1610940416;
    procedure CopyFace; dispid 1610940418;
    property FaceId: SYSINT dispid 1610940419;
    procedure PasteFace; dispid 1610940421;
    property ShortcutText: WideString dispid 1610940422;
    property State: MsoButtonState dispid 1610940424;
    property Style: MsoButtonStyle dispid 1610940426;
    property HyperlinkType: MsoCommandBarButtonHyperlinkType dispid 1610940428;
  end;

  CommandBarPopup = interface(CommandBarControl)
    ['{000C030A-0000-0000-C000-000000000046}']
    function Get_CommandBar: CommandBar; safecall;
    function Get_Controls: CommandBarControls; safecall;
    function Get_OLEMenuGroup: MsoOLEMenuGroup; safecall;
    procedure Set_OLEMenuGroup(Value: MsoOLEMenuGroup); safecall;
    property CommandBar: CommandBar read Get_CommandBar;
    property Controls: CommandBarControls read Get_Controls;
    property OLEMenuGroup: MsoOLEMenuGroup read Get_OLEMenuGroup write Set_OLEMenuGroup;
  end;

{ DispInterface declaration for Dual Interface CommandBarPopup }

  CommandBarPopupDisp = dispinterface
    ['{000C030A-0000-0000-C000-000000000046}']
    property CommandBar: CommandBar readonly dispid 1610940416;
    property Controls: CommandBarControls readonly dispid 1610940417;
    property OLEMenuGroup: MsoOLEMenuGroup dispid 1610940418;
  end;

  _CommandBarComboBox = interface(CommandBarControl)
    ['{000C030C-0000-0000-C000-000000000046}']
    procedure AddItem(const Text: WideString; Index: OleVariant); safecall;
    procedure Clear; safecall;
    function Get_DropDownLines: SYSINT; safecall;
    procedure Set_DropDownLines(Value: SYSINT); safecall;
    function Get_DropDownWidth: SYSINT; safecall;
    procedure Set_DropDownWidth(Value: SYSINT); safecall;
    function Get_List(Index: SYSINT): WideString; safecall;
    procedure Set_List(Index: SYSINT; const Value: WideString); safecall;
    function Get_ListCount: SYSINT; safecall;
    function Get_ListHeaderCount: SYSINT; safecall;
    procedure Set_ListHeaderCount(Value: SYSINT); safecall;
    function Get_ListIndex: SYSINT; safecall;
    procedure Set_ListIndex(Value: SYSINT); safecall;
    procedure RemoveItem(Index: SYSINT); safecall;
    function Get_Style: MsoComboStyle; safecall;
    procedure Set_Style(Value: MsoComboStyle); safecall;
    function Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    property DropDownLines: SYSINT read Get_DropDownLines write Set_DropDownLines;
    property DropDownWidth: SYSINT read Get_DropDownWidth write Set_DropDownWidth;
    property List[Index: SYSINT]: WideString read Get_List write Set_List;
    property ListCount: SYSINT read Get_ListCount;
    property ListHeaderCount: SYSINT read Get_ListHeaderCount write Set_ListHeaderCount;
    property ListIndex: SYSINT read Get_ListIndex write Set_ListIndex;
    property Style: MsoComboStyle read Get_Style write Set_Style;
    property Text: WideString read Get_Text write Set_Text;
  end;

{ DispInterface declaration for Dual Interface _CommandBarComboBox }

  _CommandBarComboBoxDisp = dispinterface
    ['{000C030C-0000-0000-C000-000000000046}']
    procedure AddItem(const Text: WideString; Index: OleVariant); dispid 1610940416;
    procedure Clear; dispid 1610940417;
    property DropDownLines: SYSINT dispid 1610940418;
    property DropDownWidth: SYSINT dispid 1610940420;
    property List[Index: SYSINT]: WideString dispid 1610940422;
    property ListCount: SYSINT readonly dispid 1610940424;
    property ListHeaderCount: SYSINT dispid 1610940425;
    property ListIndex: SYSINT dispid 1610940427;
    procedure RemoveItem(Index: SYSINT); dispid 1610940429;
    property Style: MsoComboStyle dispid 1610940430;
    property Text: WideString dispid 1610940432;
  end;

  _CommandBarActiveX = interface(CommandBarControl)
    ['{000C030D-0000-0000-C000-000000000046}']
    function Get_ControlCLSID: WideString; safecall;
    procedure Set_ControlCLSID(const Value: WideString); safecall;
    function Get_QueryControlInterface(const bstrIid: WideString): IUnknown; safecall;
    procedure SetInnerObjectFactory(pUnk: IUnknown); safecall;
    procedure EnsureControl; safecall;
    procedure Set_InitWith(Value: IUnknown); safecall;
    property ControlCLSID: WideString read Get_ControlCLSID write Set_ControlCLSID;
    property QueryControlInterface[const bstrIid: WideString]: IUnknown read Get_QueryControlInterface;
    property InitWith: IUnknown write Set_InitWith;
  end;

{ DispInterface declaration for Dual Interface _CommandBarActiveX }

  _CommandBarActiveXDisp = dispinterface
    ['{000C030D-0000-0000-C000-000000000046}']
    property ControlCLSID: WideString dispid 1610940416;
    property QueryControlInterface[const bstrIid: WideString]: IUnknown readonly dispid 1610940418;
    procedure SetInnerObjectFactory(pUnk: IUnknown); dispid 1610940419;
    procedure EnsureControl; dispid 1610940420;
    property InitWith: IUnknown writeonly dispid 1610940421;
  end;

  Adjustments = interface(_IMsoDispObj)
    ['{000C0310-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_Count: SYSINT; safecall;
    function Get_Item(Index: SYSINT): Single; safecall;
    procedure Set_Item(Index: SYSINT; Value: Single); safecall;
    property Parent: IDispatch read Get_Parent;
    property Count: SYSINT read Get_Count;
    property Item[Index: SYSINT]: Single read Get_Item write Set_Item; default;
  end;

{ DispInterface declaration for Dual Interface Adjustments }

  AdjustmentsDisp = dispinterface
    ['{000C0310-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    property Count: SYSINT readonly dispid 2;
    property Item[Index: SYSINT]: Single dispid 0; default;
  end;

  CalloutFormat = interface(_IMsoDispObj)
    ['{000C0311-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    procedure AutomaticLength; safecall;
    procedure CustomDrop(Drop: Single); safecall;
    procedure CustomLength(Length: Single); safecall;
    procedure PresetDrop(DropType: MsoCalloutDropType); safecall;
    function Get_Accent: MsoTriState; safecall;
    procedure Set_Accent(Value: MsoTriState); safecall;
    function Get_Angle: MsoCalloutAngleType; safecall;
    procedure Set_Angle(Value: MsoCalloutAngleType); safecall;
    function Get_AutoAttach: MsoTriState; safecall;
    procedure Set_AutoAttach(Value: MsoTriState); safecall;
    function Get_AutoLength: MsoTriState; safecall;
    function Get_Border: MsoTriState; safecall;
    procedure Set_Border(Value: MsoTriState); safecall;
    function Get_Drop: Single; safecall;
    function Get_DropType: MsoCalloutDropType; safecall;
    function Get_Gap: Single; safecall;
    procedure Set_Gap(Value: Single); safecall;
    function Get_Length: Single; safecall;
    function Get_Type_: MsoCalloutType; safecall;
    procedure Set_Type_(Value: MsoCalloutType); safecall;
    property Parent: IDispatch read Get_Parent;
    property Accent: MsoTriState read Get_Accent write Set_Accent;
    property Angle: MsoCalloutAngleType read Get_Angle write Set_Angle;
    property AutoAttach: MsoTriState read Get_AutoAttach write Set_AutoAttach;
    property AutoLength: MsoTriState read Get_AutoLength;
    property Border: MsoTriState read Get_Border write Set_Border;
    property Drop: Single read Get_Drop;
    property DropType: MsoCalloutDropType read Get_DropType;
    property Gap: Single read Get_Gap write Set_Gap;
    property Length: Single read Get_Length;
    property Type_: MsoCalloutType read Get_Type_ write Set_Type_;
  end;

{ DispInterface declaration for Dual Interface CalloutFormat }

  CalloutFormatDisp = dispinterface
    ['{000C0311-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    procedure AutomaticLength; dispid 10;
    procedure CustomDrop(Drop: Single); dispid 11;
    procedure CustomLength(Length: Single); dispid 12;
    procedure PresetDrop(DropType: MsoCalloutDropType); dispid 13;
    property Accent: MsoTriState dispid 100;
    property Angle: MsoCalloutAngleType dispid 101;
    property AutoAttach: MsoTriState dispid 102;
    property AutoLength: MsoTriState readonly dispid 103;
    property Border: MsoTriState dispid 104;
    property Drop: Single readonly dispid 105;
    property DropType: MsoCalloutDropType readonly dispid 106;
    property Gap: Single dispid 107;
    property Length: Single readonly dispid 108;
    property Type_: MsoCalloutType dispid 109;
  end;

  ColorFormat = interface(_IMsoDispObj)
    ['{000C0312-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_RGB: MsoRGBType; safecall;
    procedure Set_RGB(Value: MsoRGBType); safecall;
    function Get_SchemeColor: SYSINT; safecall;
    procedure Set_SchemeColor(Value: SYSINT); safecall;
    function Get_Type_: MsoColorType; safecall;
    property Parent: IDispatch read Get_Parent;
    property RGB: MsoRGBType read Get_RGB write Set_RGB;
    property SchemeColor: SYSINT read Get_SchemeColor write Set_SchemeColor;
    property Type_: MsoColorType read Get_Type_;
  end;

{ DispInterface declaration for Dual Interface ColorFormat }

  ColorFormatDisp = dispinterface
    ['{000C0312-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    property RGB: MsoRGBType dispid 0;
    property SchemeColor: SYSINT dispid 100;
    property Type_: MsoColorType readonly dispid 101;
  end;

  ConnectorFormat = interface(_IMsoDispObj)
    ['{000C0313-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    procedure BeginConnect(const ConnectedShape: Shape; ConnectionSite: SYSINT); safecall;
    procedure BeginDisconnect; safecall;
    procedure EndConnect(const ConnectedShape: Shape; ConnectionSite: SYSINT); safecall;
    procedure EndDisconnect; safecall;
    function Get_BeginConnected: MsoTriState; safecall;
    function Get_BeginConnectedShape: Shape; safecall;
    function Get_BeginConnectionSite: SYSINT; safecall;
    function Get_EndConnected: MsoTriState; safecall;
    function Get_EndConnectedShape: Shape; safecall;
    function Get_EndConnectionSite: SYSINT; safecall;
    function Get_Type_: MsoConnectorType; safecall;
    procedure Set_Type_(Value: MsoConnectorType); safecall;
    property Parent: IDispatch read Get_Parent;
    property BeginConnected: MsoTriState read Get_BeginConnected;
    property BeginConnectedShape: Shape read Get_BeginConnectedShape;
    property BeginConnectionSite: SYSINT read Get_BeginConnectionSite;
    property EndConnected: MsoTriState read Get_EndConnected;
    property EndConnectedShape: Shape read Get_EndConnectedShape;
    property EndConnectionSite: SYSINT read Get_EndConnectionSite;
    property Type_: MsoConnectorType read Get_Type_ write Set_Type_;
  end;

{ DispInterface declaration for Dual Interface ConnectorFormat }

  ConnectorFormatDisp = dispinterface
    ['{000C0313-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    procedure BeginConnect(const ConnectedShape: Shape; ConnectionSite: SYSINT); dispid 10;
    procedure BeginDisconnect; dispid 11;
    procedure EndConnect(const ConnectedShape: Shape; ConnectionSite: SYSINT); dispid 12;
    procedure EndDisconnect; dispid 13;
    property BeginConnected: MsoTriState readonly dispid 100;
    property BeginConnectedShape: Shape readonly dispid 101;
    property BeginConnectionSite: SYSINT readonly dispid 102;
    property EndConnected: MsoTriState readonly dispid 103;
    property EndConnectedShape: Shape readonly dispid 104;
    property EndConnectionSite: SYSINT readonly dispid 105;
    property Type_: MsoConnectorType dispid 106;
  end;

  FillFormat = interface(_IMsoDispObj)
    ['{000C0314-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    procedure Background; safecall;
    procedure OneColorGradient(Style: MsoGradientStyle; Variant: SYSINT; Degree: Single); safecall;
    procedure Patterned(Pattern: MsoPatternType); safecall;
    procedure PresetGradient(Style: MsoGradientStyle; Variant: SYSINT; PresetGradientType: MsoPresetGradientType); safecall;
    procedure PresetTextured(PresetTexture: MsoPresetTexture); safecall;
    procedure Solid; safecall;
    procedure TwoColorGradient(Style: MsoGradientStyle; Variant: SYSINT); safecall;
    procedure UserPicture(const PictureFile: WideString); safecall;
    procedure UserTextured(const TextureFile: WideString); safecall;
    function Get_BackColor: ColorFormat; safecall;
    procedure Set_BackColor(const Value: ColorFormat); safecall;
    function Get_ForeColor: ColorFormat; safecall;
    procedure Set_ForeColor(const Value: ColorFormat); safecall;
    function Get_GradientColorType: MsoGradientColorType; safecall;
    function Get_GradientDegree: Single; safecall;
    function Get_GradientStyle: MsoGradientStyle; safecall;
    function Get_GradientVariant: SYSINT; safecall;
    function Get_Pattern: MsoPatternType; safecall;
    function Get_PresetGradientType: MsoPresetGradientType; safecall;
    function Get_PresetTexture: MsoPresetTexture; safecall;
    function Get_TextureName: WideString; safecall;
    function Get_TextureType: MsoTextureType; safecall;
    function Get_Transparency: Single; safecall;
    procedure Set_Transparency(Value: Single); safecall;
    function Get_Type_: MsoFillType; safecall;
    function Get_Visible: MsoTriState; safecall;
    procedure Set_Visible(Value: MsoTriState); safecall;
    property Parent: IDispatch read Get_Parent;
    property BackColor: ColorFormat read Get_BackColor write Set_BackColor;
    property ForeColor: ColorFormat read Get_ForeColor write Set_ForeColor;
    property GradientColorType: MsoGradientColorType read Get_GradientColorType;
    property GradientDegree: Single read Get_GradientDegree;
    property GradientStyle: MsoGradientStyle read Get_GradientStyle;
    property GradientVariant: SYSINT read Get_GradientVariant;
    property Pattern: MsoPatternType read Get_Pattern;
    property PresetGradientType: MsoPresetGradientType read Get_PresetGradientType;
    property PresetTexture: MsoPresetTexture read Get_PresetTexture;
    property TextureName: WideString read Get_TextureName;
    property TextureType: MsoTextureType read Get_TextureType;
    property Transparency: Single read Get_Transparency write Set_Transparency;
    property Type_: MsoFillType read Get_Type_;
    property Visible: MsoTriState read Get_Visible write Set_Visible;
  end;

{ DispInterface declaration for Dual Interface FillFormat }

  FillFormatDisp = dispinterface
    ['{000C0314-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    procedure Background; dispid 10;
    procedure OneColorGradient(Style: MsoGradientStyle; Variant: SYSINT; Degree: Single); dispid 11;
    procedure Patterned(Pattern: MsoPatternType); dispid 12;
    procedure PresetGradient(Style: MsoGradientStyle; Variant: SYSINT; PresetGradientType: MsoPresetGradientType); dispid 13;
    procedure PresetTextured(PresetTexture: MsoPresetTexture); dispid 14;
    procedure Solid; dispid 15;
    procedure TwoColorGradient(Style: MsoGradientStyle; Variant: SYSINT); dispid 16;
    procedure UserPicture(const PictureFile: WideString); dispid 17;
    procedure UserTextured(const TextureFile: WideString); dispid 18;
    property BackColor: ColorFormat dispid 100;
    property ForeColor: ColorFormat dispid 101;
    property GradientColorType: MsoGradientColorType readonly dispid 102;
    property GradientDegree: Single readonly dispid 103;
    property GradientStyle: MsoGradientStyle readonly dispid 104;
    property GradientVariant: SYSINT readonly dispid 105;
    property Pattern: MsoPatternType readonly dispid 106;
    property PresetGradientType: MsoPresetGradientType readonly dispid 107;
    property PresetTexture: MsoPresetTexture readonly dispid 108;
    property TextureName: WideString readonly dispid 109;
    property TextureType: MsoTextureType readonly dispid 110;
    property Transparency: Single dispid 111;
    property Type_: MsoFillType readonly dispid 112;
    property Visible: MsoTriState dispid 113;
  end;

  FreeformBuilder = interface(_IMsoDispObj)
    ['{000C0315-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    procedure AddNodes(SegmentType: MsoSegmentType; EditingType: MsoEditingType; X1, Y1, X2, Y2, X3, Y3: Single); safecall;
    function ConvertToShape: Shape; safecall;
    property Parent: IDispatch read Get_Parent;
  end;

{ DispInterface declaration for Dual Interface FreeformBuilder }

  FreeformBuilderDisp = dispinterface
    ['{000C0315-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    procedure AddNodes(SegmentType: MsoSegmentType; EditingType: MsoEditingType; X1, Y1, X2, Y2, X3, Y3: Single); dispid 10;
    function ConvertToShape: Shape; dispid 11;
  end;

  GroupShapes = interface(_IMsoDispObj)
    ['{000C0316-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_Count: SYSINT; safecall;
    function Item(Index: OleVariant): Shape; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Parent: IDispatch read Get_Parent;
    property Count: SYSINT read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

{ DispInterface declaration for Dual Interface GroupShapes }

  GroupShapesDisp = dispinterface
    ['{000C0316-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    property Count: SYSINT readonly dispid 2;
    function Item(Index: OleVariant): Shape; dispid 0;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

  LineFormat = interface(_IMsoDispObj)
    ['{000C0317-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_BackColor: ColorFormat; safecall;
    procedure Set_BackColor(const Value: ColorFormat); safecall;
    function Get_BeginArrowheadLength: MsoArrowheadLength; safecall;
    procedure Set_BeginArrowheadLength(Value: MsoArrowheadLength); safecall;
    function Get_BeginArrowheadStyle: MsoArrowheadStyle; safecall;
    procedure Set_BeginArrowheadStyle(Value: MsoArrowheadStyle); safecall;
    function Get_BeginArrowheadWidth: MsoArrowheadWidth; safecall;
    procedure Set_BeginArrowheadWidth(Value: MsoArrowheadWidth); safecall;
    function Get_DashStyle: MsoLineDashStyle; safecall;
    procedure Set_DashStyle(Value: MsoLineDashStyle); safecall;
    function Get_EndArrowheadLength: MsoArrowheadLength; safecall;
    procedure Set_EndArrowheadLength(Value: MsoArrowheadLength); safecall;
    function Get_EndArrowheadStyle: MsoArrowheadStyle; safecall;
    procedure Set_EndArrowheadStyle(Value: MsoArrowheadStyle); safecall;
    function Get_EndArrowheadWidth: MsoArrowheadWidth; safecall;
    procedure Set_EndArrowheadWidth(Value: MsoArrowheadWidth); safecall;
    function Get_ForeColor: ColorFormat; safecall;
    procedure Set_ForeColor(const Value: ColorFormat); safecall;
    function Get_Pattern: MsoPatternType; safecall;
    procedure Set_Pattern(Value: MsoPatternType); safecall;
    function Get_Style: MsoLineStyle; safecall;
    procedure Set_Style(Value: MsoLineStyle); safecall;
    function Get_Transparency: Single; safecall;
    procedure Set_Transparency(Value: Single); safecall;
    function Get_Visible: MsoTriState; safecall;
    procedure Set_Visible(Value: MsoTriState); safecall;
    function Get_Weight: Single; safecall;
    procedure Set_Weight(Value: Single); safecall;
    property Parent: IDispatch read Get_Parent;
    property BackColor: ColorFormat read Get_BackColor write Set_BackColor;
    property BeginArrowheadLength: MsoArrowheadLength read Get_BeginArrowheadLength write Set_BeginArrowheadLength;
    property BeginArrowheadStyle: MsoArrowheadStyle read Get_BeginArrowheadStyle write Set_BeginArrowheadStyle;
    property BeginArrowheadWidth: MsoArrowheadWidth read Get_BeginArrowheadWidth write Set_BeginArrowheadWidth;
    property DashStyle: MsoLineDashStyle read Get_DashStyle write Set_DashStyle;
    property EndArrowheadLength: MsoArrowheadLength read Get_EndArrowheadLength write Set_EndArrowheadLength;
    property EndArrowheadStyle: MsoArrowheadStyle read Get_EndArrowheadStyle write Set_EndArrowheadStyle;
    property EndArrowheadWidth: MsoArrowheadWidth read Get_EndArrowheadWidth write Set_EndArrowheadWidth;
    property ForeColor: ColorFormat read Get_ForeColor write Set_ForeColor;
    property Pattern: MsoPatternType read Get_Pattern write Set_Pattern;
    property Style: MsoLineStyle read Get_Style write Set_Style;
    property Transparency: Single read Get_Transparency write Set_Transparency;
    property Visible: MsoTriState read Get_Visible write Set_Visible;
    property Weight: Single read Get_Weight write Set_Weight;
  end;

{ DispInterface declaration for Dual Interface LineFormat }

  LineFormatDisp = dispinterface
    ['{000C0317-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    property BackColor: ColorFormat dispid 100;
    property BeginArrowheadLength: MsoArrowheadLength dispid 101;
    property BeginArrowheadStyle: MsoArrowheadStyle dispid 102;
    property BeginArrowheadWidth: MsoArrowheadWidth dispid 103;
    property DashStyle: MsoLineDashStyle dispid 104;
    property EndArrowheadLength: MsoArrowheadLength dispid 105;
    property EndArrowheadStyle: MsoArrowheadStyle dispid 106;
    property EndArrowheadWidth: MsoArrowheadWidth dispid 107;
    property ForeColor: ColorFormat dispid 108;
    property Pattern: MsoPatternType dispid 109;
    property Style: MsoLineStyle dispid 110;
    property Transparency: Single dispid 111;
    property Visible: MsoTriState dispid 112;
    property Weight: Single dispid 113;
  end;

  ShapeNode = interface(_IMsoDispObj)
    ['{000C0318-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_EditingType: MsoEditingType; safecall;
    function Get_Points: OleVariant; safecall;
    function Get_SegmentType: MsoSegmentType; safecall;
    property Parent: IDispatch read Get_Parent;
    property EditingType: MsoEditingType read Get_EditingType;
    property Points: OleVariant read Get_Points;
    property SegmentType: MsoSegmentType read Get_SegmentType;
  end;

{ DispInterface declaration for Dual Interface ShapeNode }

  ShapeNodeDisp = dispinterface
    ['{000C0318-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    property EditingType: MsoEditingType readonly dispid 100;
    property Points: OleVariant readonly dispid 101;
    property SegmentType: MsoSegmentType readonly dispid 102;
  end;

  ShapeNodes = interface(_IMsoDispObj)
    ['{000C0319-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_Count: SYSINT; safecall;
    function Item(Index: OleVariant): ShapeNode; safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure Delete(Index: SYSINT); safecall;
    procedure Insert(Index: SYSINT; SegmentType: MsoSegmentType; EditingType: MsoEditingType; X1, Y1, X2, Y2, X3, Y3: Single); safecall;
    procedure SetEditingType(Index: SYSINT; EditingType: MsoEditingType); safecall;
    procedure SetPosition(Index: SYSINT; X1, Y1: Single); safecall;
    procedure SetSegmentType(Index: SYSINT; SegmentType: MsoSegmentType); safecall;
    property Parent: IDispatch read Get_Parent;
    property Count: SYSINT read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

{ DispInterface declaration for Dual Interface ShapeNodes }

  ShapeNodesDisp = dispinterface
    ['{000C0319-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    property Count: SYSINT readonly dispid 2;
    function Item(Index: OleVariant): ShapeNode; dispid 0;
    property _NewEnum: IUnknown readonly dispid -4;
    procedure Delete(Index: SYSINT); dispid 11;
    procedure Insert(Index: SYSINT; SegmentType: MsoSegmentType; EditingType: MsoEditingType; X1, Y1, X2, Y2, X3, Y3: Single); dispid 12;
    procedure SetEditingType(Index: SYSINT; EditingType: MsoEditingType); dispid 13;
    procedure SetPosition(Index: SYSINT; X1, Y1: Single); dispid 14;
    procedure SetSegmentType(Index: SYSINT; SegmentType: MsoSegmentType); dispid 15;
  end;

  PictureFormat = interface(_IMsoDispObj)
    ['{000C031A-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    procedure IncrementBrightness(Increment: Single); safecall;
    procedure IncrementContrast(Increment: Single); safecall;
    function Get_Brightness: Single; safecall;
    procedure Set_Brightness(Value: Single); safecall;
    function Get_ColorType: MsoPictureColorType; safecall;
    procedure Set_ColorType(Value: MsoPictureColorType); safecall;
    function Get_Contrast: Single; safecall;
    procedure Set_Contrast(Value: Single); safecall;
    function Get_CropBottom: Single; safecall;
    procedure Set_CropBottom(Value: Single); safecall;
    function Get_CropLeft: Single; safecall;
    procedure Set_CropLeft(Value: Single); safecall;
    function Get_CropRight: Single; safecall;
    procedure Set_CropRight(Value: Single); safecall;
    function Get_CropTop: Single; safecall;
    procedure Set_CropTop(Value: Single); safecall;
    function Get_TransparencyColor: MsoRGBType; safecall;
    procedure Set_TransparencyColor(Value: MsoRGBType); safecall;
    function Get_TransparentBackground: MsoTriState; safecall;
    procedure Set_TransparentBackground(Value: MsoTriState); safecall;
    property Parent: IDispatch read Get_Parent;
    property Brightness: Single read Get_Brightness write Set_Brightness;
    property ColorType: MsoPictureColorType read Get_ColorType write Set_ColorType;
    property Contrast: Single read Get_Contrast write Set_Contrast;
    property CropBottom: Single read Get_CropBottom write Set_CropBottom;
    property CropLeft: Single read Get_CropLeft write Set_CropLeft;
    property CropRight: Single read Get_CropRight write Set_CropRight;
    property CropTop: Single read Get_CropTop write Set_CropTop;
    property TransparencyColor: MsoRGBType read Get_TransparencyColor write Set_TransparencyColor;
    property TransparentBackground: MsoTriState read Get_TransparentBackground write Set_TransparentBackground;
  end;

{ DispInterface declaration for Dual Interface PictureFormat }

  PictureFormatDisp = dispinterface
    ['{000C031A-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    procedure IncrementBrightness(Increment: Single); dispid 10;
    procedure IncrementContrast(Increment: Single); dispid 11;
    property Brightness: Single dispid 100;
    property ColorType: MsoPictureColorType dispid 101;
    property Contrast: Single dispid 102;
    property CropBottom: Single dispid 103;
    property CropLeft: Single dispid 104;
    property CropRight: Single dispid 105;
    property CropTop: Single dispid 106;
    property TransparencyColor: MsoRGBType dispid 107;
    property TransparentBackground: MsoTriState dispid 108;
  end;

  ShadowFormat = interface(_IMsoDispObj)
    ['{000C031B-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    procedure IncrementOffsetX(Increment: Single); safecall;
    procedure IncrementOffsetY(Increment: Single); safecall;
    function Get_ForeColor: ColorFormat; safecall;
    procedure Set_ForeColor(const Value: ColorFormat); safecall;
    function Get_Obscured: MsoTriState; safecall;
    procedure Set_Obscured(Value: MsoTriState); safecall;
    function Get_OffsetX: Single; safecall;
    procedure Set_OffsetX(Value: Single); safecall;
    function Get_OffsetY: Single; safecall;
    procedure Set_OffsetY(Value: Single); safecall;
    function Get_Transparency: Single; safecall;
    procedure Set_Transparency(Value: Single); safecall;
    function Get_Type_: MsoShadowType; safecall;
    procedure Set_Type_(Value: MsoShadowType); safecall;
    function Get_Visible: MsoTriState; safecall;
    procedure Set_Visible(Value: MsoTriState); safecall;
    property Parent: IDispatch read Get_Parent;
    property ForeColor: ColorFormat read Get_ForeColor write Set_ForeColor;
    property Obscured: MsoTriState read Get_Obscured write Set_Obscured;
    property OffsetX: Single read Get_OffsetX write Set_OffsetX;
    property OffsetY: Single read Get_OffsetY write Set_OffsetY;
    property Transparency: Single read Get_Transparency write Set_Transparency;
    property Type_: MsoShadowType read Get_Type_ write Set_Type_;
    property Visible: MsoTriState read Get_Visible write Set_Visible;
  end;

{ DispInterface declaration for Dual Interface ShadowFormat }

  ShadowFormatDisp = dispinterface
    ['{000C031B-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    procedure IncrementOffsetX(Increment: Single); dispid 10;
    procedure IncrementOffsetY(Increment: Single); dispid 11;
    property ForeColor: ColorFormat dispid 100;
    property Obscured: MsoTriState dispid 101;
    property OffsetX: Single dispid 102;
    property OffsetY: Single dispid 103;
    property Transparency: Single dispid 104;
    property Type_: MsoShadowType dispid 105;
    property Visible: MsoTriState dispid 106;
  end;

  Script = interface(_IMsoDispObj)
    ['{000C0341-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_Extended: WideString; safecall;
    procedure Set_Extended(const Value: WideString); safecall;
    function Get_Id: WideString; safecall;
    procedure Set_Id(const Value: WideString); safecall;
    function Get_Language: MsoScriptLanguage; safecall;
    procedure Set_Language(Value: MsoScriptLanguage); safecall;
    function Get_Location: MsoScriptLocation; safecall;
    procedure Delete; safecall;
    function Get_Shape: IDispatch; safecall;
    function Get_ScriptText: WideString; safecall;
    procedure Set_ScriptText(const Value: WideString); safecall;
    property Parent: IDispatch read Get_Parent;
    property Extended: WideString read Get_Extended write Set_Extended;
    property Id: WideString read Get_Id write Set_Id;
    property Language: MsoScriptLanguage read Get_Language write Set_Language;
    property Location: MsoScriptLocation read Get_Location;
    property Shape: IDispatch read Get_Shape;
    property ScriptText: WideString read Get_ScriptText write Set_ScriptText;
  end;

{ DispInterface declaration for Dual Interface Script }

  ScriptDisp = dispinterface
    ['{000C0341-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1610809344;
    property Extended: WideString dispid 1610809345;
    property Id: WideString dispid 1610809347;
    property Language: MsoScriptLanguage dispid 1610809349;
    property Location: MsoScriptLocation readonly dispid 1610809351;
    procedure Delete; dispid 1610809352;
    property Shape: IDispatch readonly dispid 1610809353;
    property ScriptText: WideString dispid 0;
  end;

  Scripts = interface(_IMsoDispObj)
    ['{000C0340-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Item(Index: OleVariant): Script; safecall;
    function Add(Anchor: IDispatch; Location: MsoScriptLocation; Language: MsoScriptLanguage; const Id, Extended, ScriptText: WideString): Script; safecall;
    procedure Delete; safecall;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

{ DispInterface declaration for Dual Interface Scripts }

  ScriptsDisp = dispinterface
    ['{000C0340-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1610809344;
    property Count: Integer readonly dispid 1610809345;
    property _NewEnum: IUnknown readonly dispid -4;
    function Item(Index: OleVariant): Script; dispid 0;
    function Add(Anchor: IDispatch; Location: MsoScriptLocation; Language: MsoScriptLanguage; const Id, Extended, ScriptText: WideString): Script; dispid 1610809348;
    procedure Delete; dispid 1610809349;
  end;

  Shape = interface(_IMsoDispObj)
    ['{000C031C-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    procedure Apply; safecall;
    procedure Delete; safecall;
    function Duplicate: Shape; safecall;
    procedure Flip(FlipCmd: MsoFlipCmd); safecall;
    procedure IncrementLeft(Increment: Single); safecall;
    procedure IncrementRotation(Increment: Single); safecall;
    procedure IncrementTop(Increment: Single); safecall;
    procedure PickUp; safecall;
    procedure RerouteConnections; safecall;
    procedure ScaleHeight(Factor: Single; RelativeToOriginalSize: MsoTriState; fScale: MsoScaleFrom); safecall;
    procedure ScaleWidth(Factor: Single; RelativeToOriginalSize: MsoTriState; fScale: MsoScaleFrom); safecall;
    procedure Select(Replace: OleVariant); safecall;
    procedure SetShapesDefaultProperties; safecall;
    function Ungroup: ShapeRange; safecall;
    procedure ZOrder(ZOrderCmd: MsoZOrderCmd); safecall;
    function Get_Adjustments: Adjustments; safecall;
    function Get_AutoShapeType: MsoAutoShapeType; safecall;
    procedure Set_AutoShapeType(Value: MsoAutoShapeType); safecall;
    function Get_BlackWhiteMode: MsoBlackWhiteMode; safecall;
    procedure Set_BlackWhiteMode(Value: MsoBlackWhiteMode); safecall;
    function Get_Callout: CalloutFormat; safecall;
    function Get_ConnectionSiteCount: SYSINT; safecall;
    function Get_Connector: MsoTriState; safecall;
    function Get_ConnectorFormat: ConnectorFormat; safecall;
    function Get_Fill: FillFormat; safecall;
    function Get_GroupItems: GroupShapes; safecall;
    function Get_Height: Single; safecall;
    procedure Set_Height(Value: Single); safecall;
    function Get_HorizontalFlip: MsoTriState; safecall;
    function Get_Left: Single; safecall;
    procedure Set_Left(Value: Single); safecall;
    function Get_Line: LineFormat; safecall;
    function Get_LockAspectRatio: MsoTriState; safecall;
    procedure Set_LockAspectRatio(Value: MsoTriState); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Nodes: ShapeNodes; safecall;
    function Get_Rotation: Single; safecall;
    procedure Set_Rotation(Value: Single); safecall;
    function Get_PictureFormat: PictureFormat; safecall;
    function Get_Shadow: ShadowFormat; safecall;
    function Get_TextEffect: TextEffectFormat; safecall;
    function Get_TextFrame: TextFrame; safecall;
    function Get_ThreeD: ThreeDFormat; safecall;
    function Get_Top: Single; safecall;
    procedure Set_Top(Value: Single); safecall;
    function Get_Type_: MsoShapeType; safecall;
    function Get_VerticalFlip: MsoTriState; safecall;
    function Get_Vertices: OleVariant; safecall;
    function Get_Visible: MsoTriState; safecall;
    procedure Set_Visible(Value: MsoTriState); safecall;
    function Get_Width: Single; safecall;
    procedure Set_Width(Value: Single); safecall;
    function Get_ZOrderPosition: SYSINT; safecall;
    function Get_Script: Script; safecall;
    function Get_AlternativeText: WideString; safecall;
    procedure Set_AlternativeText(const Value: WideString); safecall;
    property Parent: IDispatch read Get_Parent;
    property Adjustments: Adjustments read Get_Adjustments;
    property AutoShapeType: MsoAutoShapeType read Get_AutoShapeType write Set_AutoShapeType;
    property BlackWhiteMode: MsoBlackWhiteMode read Get_BlackWhiteMode write Set_BlackWhiteMode;
    property Callout: CalloutFormat read Get_Callout;
    property ConnectionSiteCount: SYSINT read Get_ConnectionSiteCount;
    property Connector: MsoTriState read Get_Connector;
    property ConnectorFormat: ConnectorFormat read Get_ConnectorFormat;
    property Fill: FillFormat read Get_Fill;
    property GroupItems: GroupShapes read Get_GroupItems;
    property Height: Single read Get_Height write Set_Height;
    property HorizontalFlip: MsoTriState read Get_HorizontalFlip;
    property Left: Single read Get_Left write Set_Left;
    property Line: LineFormat read Get_Line;
    property LockAspectRatio: MsoTriState read Get_LockAspectRatio write Set_LockAspectRatio;
    property Name: WideString read Get_Name write Set_Name;
    property Nodes: ShapeNodes read Get_Nodes;
    property Rotation: Single read Get_Rotation write Set_Rotation;
    property PictureFormat: PictureFormat read Get_PictureFormat;
    property Shadow: ShadowFormat read Get_Shadow;
    property TextEffect: TextEffectFormat read Get_TextEffect;
    property TextFrame: TextFrame read Get_TextFrame;
    property ThreeD: ThreeDFormat read Get_ThreeD;
    property Top: Single read Get_Top write Set_Top;
    property Type_: MsoShapeType read Get_Type_;
    property VerticalFlip: MsoTriState read Get_VerticalFlip;
    property Vertices: OleVariant read Get_Vertices;
    property Visible: MsoTriState read Get_Visible write Set_Visible;
    property Width: Single read Get_Width write Set_Width;
    property ZOrderPosition: SYSINT read Get_ZOrderPosition;
    property Script: Script read Get_Script;
    property AlternativeText: WideString read Get_AlternativeText write Set_AlternativeText;
  end;

{ DispInterface declaration for Dual Interface Shape }

  ShapeDisp = dispinterface
    ['{000C031C-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    procedure Apply; dispid 10;
    procedure Delete; dispid 11;
    function Duplicate: Shape; dispid 12;
    procedure Flip(FlipCmd: MsoFlipCmd); dispid 13;
    procedure IncrementLeft(Increment: Single); dispid 14;
    procedure IncrementRotation(Increment: Single); dispid 15;
    procedure IncrementTop(Increment: Single); dispid 16;
    procedure PickUp; dispid 17;
    procedure RerouteConnections; dispid 18;
    procedure ScaleHeight(Factor: Single; RelativeToOriginalSize: MsoTriState; fScale: MsoScaleFrom); dispid 19;
    procedure ScaleWidth(Factor: Single; RelativeToOriginalSize: MsoTriState; fScale: MsoScaleFrom); dispid 20;
    procedure Select(Replace: OleVariant); dispid 21;
    procedure SetShapesDefaultProperties; dispid 22;
    function Ungroup: ShapeRange; dispid 23;
    procedure ZOrder(ZOrderCmd: MsoZOrderCmd); dispid 24;
    property Adjustments: Adjustments readonly dispid 100;
    property AutoShapeType: MsoAutoShapeType dispid 101;
    property BlackWhiteMode: MsoBlackWhiteMode dispid 102;
    property Callout: CalloutFormat readonly dispid 103;
    property ConnectionSiteCount: SYSINT readonly dispid 104;
    property Connector: MsoTriState readonly dispid 105;
    property ConnectorFormat: ConnectorFormat readonly dispid 106;
    property Fill: FillFormat readonly dispid 107;
    property GroupItems: GroupShapes readonly dispid 108;
    property Height: Single dispid 109;
    property HorizontalFlip: MsoTriState readonly dispid 110;
    property Left: Single dispid 111;
    property Line: LineFormat readonly dispid 112;
    property LockAspectRatio: MsoTriState dispid 113;
    property Name: WideString dispid 115;
    property Nodes: ShapeNodes readonly dispid 116;
    property Rotation: Single dispid 117;
    property PictureFormat: PictureFormat readonly dispid 118;
    property Shadow: ShadowFormat readonly dispid 119;
    property TextEffect: TextEffectFormat readonly dispid 120;
    property TextFrame: TextFrame readonly dispid 121;
    property ThreeD: ThreeDFormat readonly dispid 122;
    property Top: Single dispid 123;
    property Type_: MsoShapeType readonly dispid 124;
    property VerticalFlip: MsoTriState readonly dispid 125;
    property Vertices: OleVariant readonly dispid 126;
    property Visible: MsoTriState dispid 127;
    property Width: Single dispid 128;
    property ZOrderPosition: SYSINT readonly dispid 129;
    property Script: Script readonly dispid 130;
    property AlternativeText: WideString dispid 131;
  end;

  ShapeRange = interface(_IMsoDispObj)
    ['{000C031D-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_Count: SYSINT; safecall;
    function Item(Index: OleVariant): Shape; safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure Align(AlignCmd: MsoAlignCmd; RelativeTo: MsoTriState); safecall;
    procedure Apply; safecall;
    procedure Delete; safecall;
    procedure Distribute(DistributeCmd: MsoDistributeCmd; RelativeTo: MsoTriState); safecall;
    function Duplicate: ShapeRange; safecall;
    procedure Flip(FlipCmd: MsoFlipCmd); safecall;
    procedure IncrementLeft(Increment: Single); safecall;
    procedure IncrementRotation(Increment: Single); safecall;
    procedure IncrementTop(Increment: Single); safecall;
    function Group: Shape; safecall;
    procedure PickUp; safecall;
    function Regroup: Shape; safecall;
    procedure RerouteConnections; safecall;
    procedure ScaleHeight(Factor: Single; RelativeToOriginalSize: MsoTriState; fScale: MsoScaleFrom); safecall;
    procedure ScaleWidth(Factor: Single; RelativeToOriginalSize: MsoTriState; fScale: MsoScaleFrom); safecall;
    procedure Select(Replace: OleVariant); safecall;
    procedure SetShapesDefaultProperties; safecall;
    function Ungroup: ShapeRange; safecall;
    procedure ZOrder(ZOrderCmd: MsoZOrderCmd); safecall;
    function Get_Adjustments: Adjustments; safecall;
    function Get_AutoShapeType: MsoAutoShapeType; safecall;
    procedure Set_AutoShapeType(Value: MsoAutoShapeType); safecall;
    function Get_BlackWhiteMode: MsoBlackWhiteMode; safecall;
    procedure Set_BlackWhiteMode(Value: MsoBlackWhiteMode); safecall;
    function Get_Callout: CalloutFormat; safecall;
    function Get_ConnectionSiteCount: SYSINT; safecall;
    function Get_Connector: MsoTriState; safecall;
    function Get_ConnectorFormat: ConnectorFormat; safecall;
    function Get_Fill: FillFormat; safecall;
    function Get_GroupItems: GroupShapes; safecall;
    function Get_Height: Single; safecall;
    procedure Set_Height(Value: Single); safecall;
    function Get_HorizontalFlip: MsoTriState; safecall;
    function Get_Left: Single; safecall;
    procedure Set_Left(Value: Single); safecall;
    function Get_Line: LineFormat; safecall;
    function Get_LockAspectRatio: MsoTriState; safecall;
    procedure Set_LockAspectRatio(Value: MsoTriState); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Nodes: ShapeNodes; safecall;
    function Get_Rotation: Single; safecall;
    procedure Set_Rotation(Value: Single); safecall;
    function Get_PictureFormat: PictureFormat; safecall;
    function Get_Shadow: ShadowFormat; safecall;
    function Get_TextEffect: TextEffectFormat; safecall;
    function Get_TextFrame: TextFrame; safecall;
    function Get_ThreeD: ThreeDFormat; safecall;
    function Get_Top: Single; safecall;
    procedure Set_Top(Value: Single); safecall;
    function Get_Type_: MsoShapeType; safecall;
    function Get_VerticalFlip: MsoTriState; safecall;
    function Get_Vertices: OleVariant; safecall;
    function Get_Visible: MsoTriState; safecall;
    procedure Set_Visible(Value: MsoTriState); safecall;
    function Get_Width: Single; safecall;
    procedure Set_Width(Value: Single); safecall;
    function Get_ZOrderPosition: SYSINT; safecall;
    function Get_Script: Script; safecall;
    function Get_AlternativeText: WideString; safecall;
    procedure Set_AlternativeText(const Value: WideString); safecall;
    property Parent: IDispatch read Get_Parent;
    property Count: SYSINT read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Adjustments: Adjustments read Get_Adjustments;
    property AutoShapeType: MsoAutoShapeType read Get_AutoShapeType write Set_AutoShapeType;
    property BlackWhiteMode: MsoBlackWhiteMode read Get_BlackWhiteMode write Set_BlackWhiteMode;
    property Callout: CalloutFormat read Get_Callout;
    property ConnectionSiteCount: SYSINT read Get_ConnectionSiteCount;
    property Connector: MsoTriState read Get_Connector;
    property ConnectorFormat: ConnectorFormat read Get_ConnectorFormat;
    property Fill: FillFormat read Get_Fill;
    property GroupItems: GroupShapes read Get_GroupItems;
    property Height: Single read Get_Height write Set_Height;
    property HorizontalFlip: MsoTriState read Get_HorizontalFlip;
    property Left: Single read Get_Left write Set_Left;
    property Line: LineFormat read Get_Line;
    property LockAspectRatio: MsoTriState read Get_LockAspectRatio write Set_LockAspectRatio;
    property Name: WideString read Get_Name write Set_Name;
    property Nodes: ShapeNodes read Get_Nodes;
    property Rotation: Single read Get_Rotation write Set_Rotation;
    property PictureFormat: PictureFormat read Get_PictureFormat;
    property Shadow: ShadowFormat read Get_Shadow;
    property TextEffect: TextEffectFormat read Get_TextEffect;
    property TextFrame: TextFrame read Get_TextFrame;
    property ThreeD: ThreeDFormat read Get_ThreeD;
    property Top: Single read Get_Top write Set_Top;
    property Type_: MsoShapeType read Get_Type_;
    property VerticalFlip: MsoTriState read Get_VerticalFlip;
    property Vertices: OleVariant read Get_Vertices;
    property Visible: MsoTriState read Get_Visible write Set_Visible;
    property Width: Single read Get_Width write Set_Width;
    property ZOrderPosition: SYSINT read Get_ZOrderPosition;
    property Script: Script read Get_Script;
    property AlternativeText: WideString read Get_AlternativeText write Set_AlternativeText;
  end;

{ DispInterface declaration for Dual Interface ShapeRange }

  ShapeRangeDisp = dispinterface
    ['{000C031D-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    property Count: SYSINT readonly dispid 2;
    function Item(Index: OleVariant): Shape; dispid 0;
    property _NewEnum: IUnknown readonly dispid -4;
    procedure Align(AlignCmd: MsoAlignCmd; RelativeTo: MsoTriState); dispid 10;
    procedure Apply; dispid 11;
    procedure Delete; dispid 12;
    procedure Distribute(DistributeCmd: MsoDistributeCmd; RelativeTo: MsoTriState); dispid 13;
    function Duplicate: ShapeRange; dispid 14;
    procedure Flip(FlipCmd: MsoFlipCmd); dispid 15;
    procedure IncrementLeft(Increment: Single); dispid 16;
    procedure IncrementRotation(Increment: Single); dispid 17;
    procedure IncrementTop(Increment: Single); dispid 18;
    function Group: Shape; dispid 19;
    procedure PickUp; dispid 20;
    function Regroup: Shape; dispid 21;
    procedure RerouteConnections; dispid 22;
    procedure ScaleHeight(Factor: Single; RelativeToOriginalSize: MsoTriState; fScale: MsoScaleFrom); dispid 23;
    procedure ScaleWidth(Factor: Single; RelativeToOriginalSize: MsoTriState; fScale: MsoScaleFrom); dispid 24;
    procedure Select(Replace: OleVariant); dispid 25;
    procedure SetShapesDefaultProperties; dispid 26;
    function Ungroup: ShapeRange; dispid 27;
    procedure ZOrder(ZOrderCmd: MsoZOrderCmd); dispid 28;
    property Adjustments: Adjustments readonly dispid 100;
    property AutoShapeType: MsoAutoShapeType dispid 101;
    property BlackWhiteMode: MsoBlackWhiteMode dispid 102;
    property Callout: CalloutFormat readonly dispid 103;
    property ConnectionSiteCount: SYSINT readonly dispid 104;
    property Connector: MsoTriState readonly dispid 105;
    property ConnectorFormat: ConnectorFormat readonly dispid 106;
    property Fill: FillFormat readonly dispid 107;
    property GroupItems: GroupShapes readonly dispid 108;
    property Height: Single dispid 109;
    property HorizontalFlip: MsoTriState readonly dispid 110;
    property Left: Single dispid 111;
    property Line: LineFormat readonly dispid 112;
    property LockAspectRatio: MsoTriState dispid 113;
    property Name: WideString dispid 115;
    property Nodes: ShapeNodes readonly dispid 116;
    property Rotation: Single dispid 117;
    property PictureFormat: PictureFormat readonly dispid 118;
    property Shadow: ShadowFormat readonly dispid 119;
    property TextEffect: TextEffectFormat readonly dispid 120;
    property TextFrame: TextFrame readonly dispid 121;
    property ThreeD: ThreeDFormat readonly dispid 122;
    property Top: Single dispid 123;
    property Type_: MsoShapeType readonly dispid 124;
    property VerticalFlip: MsoTriState readonly dispid 125;
    property Vertices: OleVariant readonly dispid 126;
    property Visible: MsoTriState dispid 127;
    property Width: Single dispid 128;
    property ZOrderPosition: SYSINT readonly dispid 129;
    property Script: Script readonly dispid 130;
    property AlternativeText: WideString dispid 131;
  end;

  Shapes = interface(_IMsoDispObj)
    ['{000C031E-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_Count: SYSINT; safecall;
    function Item(Index: OleVariant): Shape; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function AddCallout(Type_: MsoCalloutType; Left, Top, Width, Height: Single): Shape; safecall;
    function AddConnector(Type_: MsoConnectorType; BeginX, BeginY, EndX, EndY: Single): Shape; safecall;
    function AddCurve(SafeArrayOfPoints: OleVariant): Shape; safecall;
    function AddLabel(Orientation: MsoTextOrientation; Left, Top, Width, Height: Single): Shape; safecall;
    function AddLine(BeginX, BeginY, EndX, EndY: Single): Shape; safecall;
    function AddPicture(const FileName: WideString; LinkToFile, SaveWithDocument: MsoTriState; Left, Top, Width, Height: Single): Shape; safecall;
    function AddPolyline(SafeArrayOfPoints: OleVariant): Shape; safecall;
    function AddShape(Type_: MsoAutoShapeType; Left, Top, Width, Height: Single): Shape; safecall;
    function AddTextEffect(PresetTextEffect: MsoPresetTextEffect; const Text, FontName: WideString; FontSize: Single; FontBold, FontItalic: MsoTriState; Left, Top: Single): Shape; safecall;
    function AddTextbox(Orientation: MsoTextOrientation; Left, Top, Width, Height: Single): Shape; safecall;
    function BuildFreeform(EditingType: MsoEditingType; X1, Y1: Single): FreeformBuilder; safecall;
    function Range(Index: OleVariant): ShapeRange; safecall;
    procedure SelectAll; safecall;
    function Get_Background: Shape; safecall;
    function Get_Default: Shape; safecall;
    property Parent: IDispatch read Get_Parent;
    property Count: SYSINT read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Background: Shape read Get_Background;
    property Default: Shape read Get_Default;
  end;

{ DispInterface declaration for Dual Interface Shapes }

  ShapesDisp = dispinterface
    ['{000C031E-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    property Count: SYSINT readonly dispid 2;
    function Item(Index: OleVariant): Shape; dispid 0;
    property _NewEnum: IUnknown readonly dispid -4;
    function AddCallout(Type_: MsoCalloutType; Left, Top, Width, Height: Single): Shape; dispid 10;
    function AddConnector(Type_: MsoConnectorType; BeginX, BeginY, EndX, EndY: Single): Shape; dispid 11;
    function AddCurve(SafeArrayOfPoints: OleVariant): Shape; dispid 12;
    function AddLabel(Orientation: MsoTextOrientation; Left, Top, Width, Height: Single): Shape; dispid 13;
    function AddLine(BeginX, BeginY, EndX, EndY: Single): Shape; dispid 14;
    function AddPicture(const FileName: WideString; LinkToFile, SaveWithDocument: MsoTriState; Left, Top, Width, Height: Single): Shape; dispid 15;
    function AddPolyline(SafeArrayOfPoints: OleVariant): Shape; dispid 16;
    function AddShape(Type_: MsoAutoShapeType; Left, Top, Width, Height: Single): Shape; dispid 17;
    function AddTextEffect(PresetTextEffect: MsoPresetTextEffect; const Text, FontName: WideString; FontSize: Single; FontBold, FontItalic: MsoTriState; Left, Top: Single): Shape; dispid 18;
    function AddTextbox(Orientation: MsoTextOrientation; Left, Top, Width, Height: Single): Shape; dispid 19;
    function BuildFreeform(EditingType: MsoEditingType; X1, Y1: Single): FreeformBuilder; dispid 20;
    function Range(Index: OleVariant): ShapeRange; dispid 21;
    procedure SelectAll; dispid 22;
    property Background: Shape readonly dispid 100;
    property Default: Shape readonly dispid 101;
  end;

  TextEffectFormat = interface(_IMsoDispObj)
    ['{000C031F-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    procedure ToggleVerticalText; safecall;
    function Get_Alignment: MsoTextEffectAlignment; safecall;
    procedure Set_Alignment(Value: MsoTextEffectAlignment); safecall;
    function Get_FontBold: MsoTriState; safecall;
    procedure Set_FontBold(Value: MsoTriState); safecall;
    function Get_FontItalic: MsoTriState; safecall;
    procedure Set_FontItalic(Value: MsoTriState); safecall;
    function Get_FontName: WideString; safecall;
    procedure Set_FontName(const Value: WideString); safecall;
    function Get_FontSize: Single; safecall;
    procedure Set_FontSize(Value: Single); safecall;
    function Get_KernedPairs: MsoTriState; safecall;
    procedure Set_KernedPairs(Value: MsoTriState); safecall;
    function Get_NormalizedHeight: MsoTriState; safecall;
    procedure Set_NormalizedHeight(Value: MsoTriState); safecall;
    function Get_PresetShape: MsoPresetTextEffectShape; safecall;
    procedure Set_PresetShape(Value: MsoPresetTextEffectShape); safecall;
    function Get_PresetTextEffect: MsoPresetTextEffect; safecall;
    procedure Set_PresetTextEffect(Value: MsoPresetTextEffect); safecall;
    function Get_RotatedChars: MsoTriState; safecall;
    procedure Set_RotatedChars(Value: MsoTriState); safecall;
    function Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function Get_Tracking: Single; safecall;
    procedure Set_Tracking(Value: Single); safecall;
    property Parent: IDispatch read Get_Parent;
    property Alignment: MsoTextEffectAlignment read Get_Alignment write Set_Alignment;
    property FontBold: MsoTriState read Get_FontBold write Set_FontBold;
    property FontItalic: MsoTriState read Get_FontItalic write Set_FontItalic;
    property FontName: WideString read Get_FontName write Set_FontName;
    property FontSize: Single read Get_FontSize write Set_FontSize;
    property KernedPairs: MsoTriState read Get_KernedPairs write Set_KernedPairs;
    property NormalizedHeight: MsoTriState read Get_NormalizedHeight write Set_NormalizedHeight;
    property PresetShape: MsoPresetTextEffectShape read Get_PresetShape write Set_PresetShape;
    property PresetTextEffect: MsoPresetTextEffect read Get_PresetTextEffect write Set_PresetTextEffect;
    property RotatedChars: MsoTriState read Get_RotatedChars write Set_RotatedChars;
    property Text: WideString read Get_Text write Set_Text;
    property Tracking: Single read Get_Tracking write Set_Tracking;
  end;

{ DispInterface declaration for Dual Interface TextEffectFormat }

  TextEffectFormatDisp = dispinterface
    ['{000C031F-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    procedure ToggleVerticalText; dispid 10;
    property Alignment: MsoTextEffectAlignment dispid 100;
    property FontBold: MsoTriState dispid 101;
    property FontItalic: MsoTriState dispid 102;
    property FontName: WideString dispid 103;
    property FontSize: Single dispid 104;
    property KernedPairs: MsoTriState dispid 105;
    property NormalizedHeight: MsoTriState dispid 106;
    property PresetShape: MsoPresetTextEffectShape dispid 107;
    property PresetTextEffect: MsoPresetTextEffect dispid 108;
    property RotatedChars: MsoTriState dispid 109;
    property Text: WideString dispid 110;
    property Tracking: Single dispid 111;
  end;

  TextFrame = interface(_IMsoDispObj)
    ['{000C0320-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_MarginBottom: Single; safecall;
    procedure Set_MarginBottom(Value: Single); safecall;
    function Get_MarginLeft: Single; safecall;
    procedure Set_MarginLeft(Value: Single); safecall;
    function Get_MarginRight: Single; safecall;
    procedure Set_MarginRight(Value: Single); safecall;
    function Get_MarginTop: Single; safecall;
    procedure Set_MarginTop(Value: Single); safecall;
    function Get_Orientation: MsoTextOrientation; safecall;
    procedure Set_Orientation(Value: MsoTextOrientation); safecall;
    property Parent: IDispatch read Get_Parent;
    property MarginBottom: Single read Get_MarginBottom write Set_MarginBottom;
    property MarginLeft: Single read Get_MarginLeft write Set_MarginLeft;
    property MarginRight: Single read Get_MarginRight write Set_MarginRight;
    property MarginTop: Single read Get_MarginTop write Set_MarginTop;
    property Orientation: MsoTextOrientation read Get_Orientation write Set_Orientation;
  end;

{ DispInterface declaration for Dual Interface TextFrame }

  TextFrameDisp = dispinterface
    ['{000C0320-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    property MarginBottom: Single dispid 100;
    property MarginLeft: Single dispid 101;
    property MarginRight: Single dispid 102;
    property MarginTop: Single dispid 103;
    property Orientation: MsoTextOrientation dispid 104;
  end;

  ThreeDFormat = interface(_IMsoDispObj)
    ['{000C0321-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    procedure IncrementRotationX(Increment: Single); safecall;
    procedure IncrementRotationY(Increment: Single); safecall;
    procedure ResetRotation; safecall;
    procedure SetThreeDFormat(PresetThreeDFormat: MsoPresetThreeDFormat); safecall;
    procedure SetExtrusionDirection(PresetExtrusionDirection: MsoPresetExtrusionDirection); safecall;
    function Get_Depth: Single; safecall;
    procedure Set_Depth(Value: Single); safecall;
    function Get_ExtrusionColor: ColorFormat; safecall;
    function Get_ExtrusionColorType: MsoExtrusionColorType; safecall;
    procedure Set_ExtrusionColorType(Value: MsoExtrusionColorType); safecall;
    function Get_Perspective: MsoTriState; safecall;
    procedure Set_Perspective(Value: MsoTriState); safecall;
    function Get_PresetExtrusionDirection: MsoPresetExtrusionDirection; safecall;
    function Get_PresetLightingDirection: MsoPresetLightingDirection; safecall;
    procedure Set_PresetLightingDirection(Value: MsoPresetLightingDirection); safecall;
    function Get_PresetLightingSoftness: MsoPresetLightingSoftness; safecall;
    procedure Set_PresetLightingSoftness(Value: MsoPresetLightingSoftness); safecall;
    function Get_PresetMaterial: MsoPresetMaterial; safecall;
    procedure Set_PresetMaterial(Value: MsoPresetMaterial); safecall;
    function Get_PresetThreeDFormat: MsoPresetThreeDFormat; safecall;
    function Get_RotationX: Single; safecall;
    procedure Set_RotationX(Value: Single); safecall;
    function Get_RotationY: Single; safecall;
    procedure Set_RotationY(Value: Single); safecall;
    function Get_Visible: MsoTriState; safecall;
    procedure Set_Visible(Value: MsoTriState); safecall;
    property Parent: IDispatch read Get_Parent;
    property Depth: Single read Get_Depth write Set_Depth;
    property ExtrusionColor: ColorFormat read Get_ExtrusionColor;
    property ExtrusionColorType: MsoExtrusionColorType read Get_ExtrusionColorType write Set_ExtrusionColorType;
    property Perspective: MsoTriState read Get_Perspective write Set_Perspective;
    property PresetExtrusionDirection: MsoPresetExtrusionDirection read Get_PresetExtrusionDirection;
    property PresetLightingDirection: MsoPresetLightingDirection read Get_PresetLightingDirection write Set_PresetLightingDirection;
    property PresetLightingSoftness: MsoPresetLightingSoftness read Get_PresetLightingSoftness write Set_PresetLightingSoftness;
    property PresetMaterial: MsoPresetMaterial read Get_PresetMaterial write Set_PresetMaterial;
    property PresetThreeDFormat: MsoPresetThreeDFormat read Get_PresetThreeDFormat;
    property RotationX: Single read Get_RotationX write Set_RotationX;
    property RotationY: Single read Get_RotationY write Set_RotationY;
    property Visible: MsoTriState read Get_Visible write Set_Visible;
  end;

{ DispInterface declaration for Dual Interface ThreeDFormat }

  ThreeDFormatDisp = dispinterface
    ['{000C0321-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1;
    procedure IncrementRotationX(Increment: Single); dispid 10;
    procedure IncrementRotationY(Increment: Single); dispid 11;
    procedure ResetRotation; dispid 12;
    procedure SetThreeDFormat(PresetThreeDFormat: MsoPresetThreeDFormat); dispid 13;
    procedure SetExtrusionDirection(PresetExtrusionDirection: MsoPresetExtrusionDirection); dispid 14;
    property Depth: Single dispid 100;
    property ExtrusionColor: ColorFormat readonly dispid 101;
    property ExtrusionColorType: MsoExtrusionColorType dispid 102;
    property Perspective: MsoTriState dispid 103;
    property PresetExtrusionDirection: MsoPresetExtrusionDirection readonly dispid 104;
    property PresetLightingDirection: MsoPresetLightingDirection dispid 105;
    property PresetLightingSoftness: MsoPresetLightingSoftness dispid 106;
    property PresetMaterial: MsoPresetMaterial dispid 107;
    property PresetThreeDFormat: MsoPresetThreeDFormat readonly dispid 108;
    property RotationX: Single dispid 109;
    property RotationY: Single dispid 110;
    property Visible: MsoTriState dispid 111;
  end;

  IMsoDispCagNotifySink = interface(IDispatch)
    ['{000C0359-0000-0000-C000-000000000046}']
    procedure InsertClip(pClipMoniker, pItemMoniker: IUnknown); safecall;
    procedure WindowIsClosing; safecall;
  end;

{ DispInterface declaration for Dual Interface IMsoDispCagNotifySink }

  IMsoDispCagNotifySinkDisp = dispinterface
    ['{000C0359-0000-0000-C000-000000000046}']
    procedure InsertClip(pClipMoniker, pItemMoniker: IUnknown); dispid 1;
    procedure WindowIsClosing; dispid 2;
  end;

  Balloon = interface(_IMsoDispObj)
    ['{000C0324-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_Checkboxes: IDispatch; safecall;
    function Get_Labels: IDispatch; safecall;
    procedure Set_BalloonType(Value: MsoBalloonType); safecall;
    function Get_BalloonType: MsoBalloonType; safecall;
    procedure Set_Icon(Value: MsoIconType); safecall;
    function Get_Icon: MsoIconType; safecall;
    procedure Set_Heading(const Value: WideString); safecall;
    function Get_Heading: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function Get_Text: WideString; safecall;
    procedure Set_Mode(Value: MsoModeType); safecall;
    function Get_Mode: MsoModeType; safecall;
    procedure Set_Animation(Value: MsoAnimationType); safecall;
    function Get_Animation: MsoAnimationType; safecall;
    procedure Set_Button(Value: MsoButtonSetType); safecall;
    function Get_Button: MsoButtonSetType; safecall;
    procedure Set_Callback(const Value: WideString); safecall;
    function Get_Callback: WideString; safecall;
    procedure Set_Private_(Value: Integer); safecall;
    function Get_Private_: Integer; safecall;
    procedure SetAvoidRectangle(Left, Top, Right, Bottom: SYSINT); safecall;
    function Get_Name: WideString; safecall;
    function Show: MsoBalloonButtonType; safecall;
    procedure Close; safecall;
    property Parent: IDispatch read Get_Parent;
    property Checkboxes: IDispatch read Get_Checkboxes;
    property Labels: IDispatch read Get_Labels;
    property BalloonType: MsoBalloonType read Get_BalloonType write Set_BalloonType;
    property Icon: MsoIconType read Get_Icon write Set_Icon;
    property Heading: WideString read Get_Heading write Set_Heading;
    property Text: WideString read Get_Text write Set_Text;
    property Mode: MsoModeType read Get_Mode write Set_Mode;
    property Animation: MsoAnimationType read Get_Animation write Set_Animation;
    property Button: MsoButtonSetType read Get_Button write Set_Button;
    property Callback: WideString read Get_Callback write Set_Callback;
    property Private_: Integer read Get_Private_ write Set_Private_;
    property Name: WideString read Get_Name;
  end;

{ DispInterface declaration for Dual Interface Balloon }

  BalloonDisp = dispinterface
    ['{000C0324-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1610809344;
    property Checkboxes: IDispatch readonly dispid 1610809345;
    property Labels: IDispatch readonly dispid 1610809346;
    property BalloonType: MsoBalloonType dispid 1610809347;
    property Icon: MsoIconType dispid 1610809349;
    property Heading: WideString dispid 1610809351;
    property Text: WideString dispid 1610809353;
    property Mode: MsoModeType dispid 1610809355;
    property Animation: MsoAnimationType dispid 1610809357;
    property Button: MsoButtonSetType dispid 1610809359;
    property Callback: WideString dispid 1610809361;
    property Private_: Integer dispid 1610809363;
    procedure SetAvoidRectangle(Left, Top, Right, Bottom: SYSINT); dispid 1610809365;
    property Name: WideString readonly dispid 1610809366;
    function Show: MsoBalloonButtonType; dispid 1610809367;
    procedure Close; dispid 1610809368;
  end;

  BalloonCheckboxes = interface(_IMsoDispObj)
    ['{000C0326-0000-0000-C000-000000000046}']
    function Get_Name: WideString; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Item(Index: SYSINT): IDispatch; safecall;
    function Get_Count: SYSINT; safecall;
    procedure Set_Count(Value: SYSINT); safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Name: WideString read Get_Name;
    property Parent: IDispatch read Get_Parent;
    property Item[Index: SYSINT]: IDispatch read Get_Item; default;
    property Count: SYSINT read Get_Count write Set_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

{ DispInterface declaration for Dual Interface BalloonCheckboxes }

  BalloonCheckboxesDisp = dispinterface
    ['{000C0326-0000-0000-C000-000000000046}']
    property Name: WideString readonly dispid 1610809344;
    property Parent: IDispatch readonly dispid 1610809345;
    property Item[Index: SYSINT]: IDispatch readonly dispid 0; default;
    property Count: SYSINT dispid 1610809347;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

  BalloonCheckbox = interface(_IMsoDispObj)
    ['{000C0328-0000-0000-C000-000000000046}']
    function Get_Item: WideString; safecall;
    function Get_Name: WideString; safecall;
    function Get_Parent: IDispatch; safecall;
    procedure Set_Checked(Value: WordBool); safecall;
    function Get_Checked: WordBool; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function Get_Text: WideString; safecall;
    property Item: WideString read Get_Item;
    property Name: WideString read Get_Name;
    property Parent: IDispatch read Get_Parent;
    property Checked: WordBool read Get_Checked write Set_Checked;
    property Text: WideString read Get_Text write Set_Text;
  end;

{ DispInterface declaration for Dual Interface BalloonCheckbox }

  BalloonCheckboxDisp = dispinterface
    ['{000C0328-0000-0000-C000-000000000046}']
    property Item: WideString readonly dispid 0;
    property Name: WideString readonly dispid 1610809345;
    property Parent: IDispatch readonly dispid 1610809346;
    property Checked: WordBool dispid 1610809347;
    property Text: WideString dispid 1610809349;
  end;

  BalloonLabels = interface(_IMsoDispObj)
    ['{000C032E-0000-0000-C000-000000000046}']
    function Get_Name: WideString; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Item(Index: SYSINT): IDispatch; safecall;
    function Get_Count: SYSINT; safecall;
    procedure Set_Count(Value: SYSINT); safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Name: WideString read Get_Name;
    property Parent: IDispatch read Get_Parent;
    property Item[Index: SYSINT]: IDispatch read Get_Item; default;
    property Count: SYSINT read Get_Count write Set_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

{ DispInterface declaration for Dual Interface BalloonLabels }

  BalloonLabelsDisp = dispinterface
    ['{000C032E-0000-0000-C000-000000000046}']
    property Name: WideString readonly dispid 1610809344;
    property Parent: IDispatch readonly dispid 1610809345;
    property Item[Index: SYSINT]: IDispatch readonly dispid 0; default;
    property Count: SYSINT dispid 1610809347;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

  BalloonLabel = interface(_IMsoDispObj)
    ['{000C0330-0000-0000-C000-000000000046}']
    function Get_Item: WideString; safecall;
    function Get_Name: WideString; safecall;
    function Get_Parent: IDispatch; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function Get_Text: WideString; safecall;
    property Item: WideString read Get_Item;
    property Name: WideString read Get_Name;
    property Parent: IDispatch read Get_Parent;
    property Text: WideString read Get_Text write Set_Text;
  end;

{ DispInterface declaration for Dual Interface BalloonLabel }

  BalloonLabelDisp = dispinterface
    ['{000C0330-0000-0000-C000-000000000046}']
    property Item: WideString readonly dispid 0;
    property Name: WideString readonly dispid 1610809345;
    property Parent: IDispatch readonly dispid 1610809346;
    property Text: WideString dispid 1610809347;
  end;

  AnswerWizardFiles = interface(_IMsoDispObj)
    ['{000C0361-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_Item(Index: SYSINT): WideString; safecall;
    function Get_Count: SYSINT; safecall;
    procedure Add(const FileName: WideString); safecall;
    procedure Delete(const FileName: WideString); safecall;
    property Parent: IDispatch read Get_Parent;
    property Item[Index: SYSINT]: WideString read Get_Item; default;
    property Count: SYSINT read Get_Count;
  end;

{ DispInterface declaration for Dual Interface AnswerWizardFiles }

  AnswerWizardFilesDisp = dispinterface
    ['{000C0361-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1610809344;
    property Item[Index: SYSINT]: WideString readonly dispid 0; default;
    property Count: SYSINT readonly dispid 1610809346;
    procedure Add(const FileName: WideString); dispid 1610809347;
    procedure Delete(const FileName: WideString); dispid 1610809348;
  end;

  AnswerWizard = interface(_IMsoDispObj)
    ['{000C0360-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    function Get_Files: AnswerWizardFiles; safecall;
    procedure ClearFileList; safecall;
    procedure ResetFileList; safecall;
    property Parent: IDispatch read Get_Parent;
    property Files: AnswerWizardFiles read Get_Files;
  end;

{ DispInterface declaration for Dual Interface AnswerWizard }

  AnswerWizardDisp = dispinterface
    ['{000C0360-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1610809344;
    property Files: AnswerWizardFiles readonly dispid 1610809345;
    procedure ClearFileList; dispid 1610809346;
    procedure ResetFileList; dispid 1610809347;
  end;

  Assistant = interface(_IMsoDispObj)
    ['{000C0322-0000-0000-C000-000000000046}']
    function Get_Parent: IDispatch; safecall;
    procedure Move(xLeft, yTop: SYSINT); safecall;
    procedure Set_Top(Value: SYSINT); safecall;
    function Get_Top: SYSINT; safecall;
    procedure Set_Left(Value: SYSINT); safecall;
    function Get_Left: SYSINT; safecall;
    procedure Help; safecall;
    function StartWizard(On_: WordBool; const Callback: WideString; PrivateX: Integer; Animation, CustomTeaser, Top, Left, Bottom, Right: OleVariant): Integer; safecall;
    procedure EndWizard(WizardID: Integer; varfSuccess: WordBool; Animation: OleVariant); safecall;
    procedure ActivateWizard(WizardID: Integer; act: MsoWizardActType; Animation: OleVariant); safecall;
    procedure ResetTips; safecall;
    function Get_NewBalloon: Balloon; safecall;
    function Get_BalloonError: MsoBalloonErrorType; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Animation: MsoAnimationType; safecall;
    procedure Set_Animation(Value: MsoAnimationType); safecall;
    function Get_Reduced: WordBool; safecall;
    procedure Set_Reduced(Value: WordBool); safecall;
    procedure Set_AssistWithHelp(Value: WordBool); safecall;
    function Get_AssistWithHelp: WordBool; safecall;
    procedure Set_AssistWithWizards(Value: WordBool); safecall;
    function Get_AssistWithWizards: WordBool; safecall;
    procedure Set_AssistWithAlerts(Value: WordBool); safecall;
    function Get_AssistWithAlerts: WordBool; safecall;
    procedure Set_MoveWhenInTheWay(Value: WordBool); safecall;
    function Get_MoveWhenInTheWay: WordBool; safecall;
    procedure Set_Sounds(Value: WordBool); safecall;
    function Get_Sounds: WordBool; safecall;
    procedure Set_FeatureTips(Value: WordBool); safecall;
    function Get_FeatureTips: WordBool; safecall;
    procedure Set_MouseTips(Value: WordBool); safecall;
    function Get_MouseTips: WordBool; safecall;
    procedure Set_KeyboardShortcutTips(Value: WordBool); safecall;
    function Get_KeyboardShortcutTips: WordBool; safecall;
    procedure Set_HighPriorityTips(Value: WordBool); safecall;
    function Get_HighPriorityTips: WordBool; safecall;
    procedure Set_TipOfDay(Value: WordBool); safecall;
    function Get_TipOfDay: WordBool; safecall;
    procedure Set_GuessHelp(Value: WordBool); safecall;
    function Get_GuessHelp: WordBool; safecall;
    procedure Set_SearchWhenProgramming(Value: WordBool); safecall;
    function Get_SearchWhenProgramming: WordBool; safecall;
    function Get_Item: WideString; safecall;
    function Get_FileName: WideString; safecall;
    procedure Set_FileName(const Value: WideString); safecall;
    function Get_Name: WideString; safecall;
    function Get_On_: WordBool; safecall;
    procedure Set_On_(Value: WordBool); safecall;
    property Parent: IDispatch read Get_Parent;
    property Top: SYSINT read Get_Top write Set_Top;
    property Left: SYSINT read Get_Left write Set_Left;
    property NewBalloon: Balloon read Get_NewBalloon;
    property BalloonError: MsoBalloonErrorType read Get_BalloonError;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Animation: MsoAnimationType read Get_Animation write Set_Animation;
    property Reduced: WordBool read Get_Reduced write Set_Reduced;
    property AssistWithHelp: WordBool read Get_AssistWithHelp write Set_AssistWithHelp;
    property AssistWithWizards: WordBool read Get_AssistWithWizards write Set_AssistWithWizards;
    property AssistWithAlerts: WordBool read Get_AssistWithAlerts write Set_AssistWithAlerts;
    property MoveWhenInTheWay: WordBool read Get_MoveWhenInTheWay write Set_MoveWhenInTheWay;
    property Sounds: WordBool read Get_Sounds write Set_Sounds;
    property FeatureTips: WordBool read Get_FeatureTips write Set_FeatureTips;
    property MouseTips: WordBool read Get_MouseTips write Set_MouseTips;
    property KeyboardShortcutTips: WordBool read Get_KeyboardShortcutTips write Set_KeyboardShortcutTips;
    property HighPriorityTips: WordBool read Get_HighPriorityTips write Set_HighPriorityTips;
    property TipOfDay: WordBool read Get_TipOfDay write Set_TipOfDay;
    property GuessHelp: WordBool read Get_GuessHelp write Set_GuessHelp;
    property SearchWhenProgramming: WordBool read Get_SearchWhenProgramming write Set_SearchWhenProgramming;
    property Item: WideString read Get_Item;
    property FileName: WideString read Get_FileName write Set_FileName;
    property Name: WideString read Get_Name;
    property On_: WordBool read Get_On_ write Set_On_;
  end;

{ DispInterface declaration for Dual Interface Assistant }

  AssistantDisp = dispinterface
    ['{000C0322-0000-0000-C000-000000000046}']
    property Parent: IDispatch readonly dispid 1610809344;
    procedure Move(xLeft, yTop: SYSINT); dispid 1610809345;
    property Top: SYSINT dispid 1610809346;
    property Left: SYSINT dispid 1610809348;
    procedure Help; dispid 1610809350;
    function StartWizard(On_: WordBool; const Callback: WideString; PrivateX: Integer; Animation, CustomTeaser, Top, Left, Bottom, Right: OleVariant): Integer; dispid 1610809351;
    procedure EndWizard(WizardID: Integer; varfSuccess: WordBool; Animation: OleVariant); dispid 1610809352;
    procedure ActivateWizard(WizardID: Integer; act: MsoWizardActType; Animation: OleVariant); dispid 1610809353;
    procedure ResetTips; dispid 1610809354;
    property NewBalloon: Balloon readonly dispid 1610809355;
    property BalloonError: MsoBalloonErrorType readonly dispid 1610809356;
    property Visible: WordBool dispid 1610809357;
    property Animation: MsoAnimationType dispid 1610809359;
    property Reduced: WordBool dispid 1610809361;
    property AssistWithHelp: WordBool dispid 1610809363;
    property AssistWithWizards: WordBool dispid 1610809365;
    property AssistWithAlerts: WordBool dispid 1610809367;
    property MoveWhenInTheWay: WordBool dispid 1610809369;
    property Sounds: WordBool dispid 1610809371;
    property FeatureTips: WordBool dispid 1610809373;
    property MouseTips: WordBool dispid 1610809375;
    property KeyboardShortcutTips: WordBool dispid 1610809377;
    property HighPriorityTips: WordBool dispid 1610809379;
    property TipOfDay: WordBool dispid 1610809381;
    property GuessHelp: WordBool dispid 1610809383;
    property SearchWhenProgramming: WordBool dispid 1610809385;
    property Item: WideString readonly dispid 0;
    property FileName: WideString dispid 1610809388;
    property Name: WideString readonly dispid 1610809390;
    property On_: WordBool dispid 1610809391;
  end;

  DocumentProperty = interface(IDispatch)
    ['{2DF8D04E-5BFA-101B-BDE5-00AA0044DE52}']
    function Get_Parent: IDispatch; stdcall;
    function Delete: HResult; stdcall;
    function Get_Name(lcid: Integer; out Retval: WideString): HResult; stdcall;
    function Set_Name(lcid: Integer; const Value: WideString): HResult; stdcall;
    function Get_Value(lcid: Integer; out Retval: OleVariant): HResult; stdcall;
    function Set_Value(lcid: Integer; Value: OleVariant): HResult; stdcall;
    function Get_Type_(lcid: Integer; out Retval: MsoDocProperties): HResult; stdcall;
    function Set_Type_(lcid: Integer; Value: MsoDocProperties): HResult; stdcall;
    function Get_LinkToContent(out Retval: WordBool): HResult; stdcall;
    function Set_LinkToContent(Value: WordBool): HResult; stdcall;
    function Get_LinkSource(out Retval: WideString): HResult; stdcall;
    function Set_LinkSource(const Value: WideString): HResult; stdcall;
    function Get_Application(out Retval: IDispatch): HResult; stdcall;
    function Get_Creator(out Retval: Integer): HResult; stdcall;
    property Parent: IDispatch read Get_Parent;
  end;

  DocumentProperties = interface(IDispatch)
    ['{2DF8D04D-5BFA-101B-BDE5-00AA0044DE52}']
    function Get_Parent: IDispatch; stdcall;
    function Get_Item(Index: OleVariant; lcid: Integer; out Retval: DocumentProperty): HResult; stdcall;
    function Get_Count(out Retval: Integer): HResult; stdcall;
    function Add(const Name: WideString; LinkToContent: WordBool; Type_, Value, LinkSource: OleVariant; lcid: Integer; out Retval: DocumentProperty): HResult; stdcall;
    function Get__NewEnum(out Retval: IUnknown): HResult; stdcall;
    function Get_Application(out Retval: IDispatch): HResult; stdcall;
    function Get_Creator(out Retval: Integer): HResult; stdcall;
    property Parent: IDispatch read Get_Parent;
  end;

  IFoundFiles = interface(IDispatch)
    ['{000C0338-0000-0000-C000-000000000046}']
    function Get_Item(Index: SYSINT): WideString; safecall;
    function Get_Count: SYSINT; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[Index: SYSINT]: WideString read Get_Item; default;
    property Count: SYSINT read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

{ DispInterface declaration for Dual Interface IFoundFiles }

  IFoundFilesDisp = dispinterface
    ['{000C0338-0000-0000-C000-000000000046}']
    property Item[Index: SYSINT]: WideString readonly dispid 0; default;
    property Count: SYSINT readonly dispid 1610743809;
  end;

  IFind = interface(IDispatch)
    ['{000C0337-0000-0000-C000-000000000046}']
    function Get_SearchPath: WideString; safecall;
    function Get_Name: WideString; safecall;
    function Get_SubDir: WordBool; safecall;
    function Get_Title: WideString; safecall;
    function Get_Author: WideString; safecall;
    function Get_Keywords: WideString; safecall;
    function Get_Subject: WideString; safecall;
    function Get_Options: MsoFileFindOptions; safecall;
    function Get_MatchCase: WordBool; safecall;
    function Get_Text: WideString; safecall;
    function Get_PatternMatch: WordBool; safecall;
    function Get_DateSavedFrom: OleVariant; safecall;
    function Get_DateSavedTo: OleVariant; safecall;
    function Get_SavedBy: WideString; safecall;
    function Get_DateCreatedFrom: OleVariant; safecall;
    function Get_DateCreatedTo: OleVariant; safecall;
    function Get_View: MsoFileFindView; safecall;
    function Get_SortBy: MsoFileFindSortBy; safecall;
    function Get_ListBy: MsoFileFindListBy; safecall;
    function Get_SelectedFile: SYSINT; safecall;
    function Get_Results: IFoundFiles; safecall;
    function Show: SYSINT; safecall;
    procedure Set_SearchPath(const Value: WideString); safecall;
    procedure Set_Name(const Value: WideString); safecall;
    procedure Set_SubDir(Value: WordBool); safecall;
    procedure Set_Title(const Value: WideString); safecall;
    procedure Set_Author(const Value: WideString); safecall;
    procedure Set_Keywords(const Value: WideString); safecall;
    procedure Set_Subject(const Value: WideString); safecall;
    procedure Set_Options(Value: MsoFileFindOptions); safecall;
    procedure Set_MatchCase(Value: WordBool); safecall;
    procedure Set_Text(const Value: WideString); safecall;
    procedure Set_PatternMatch(Value: WordBool); safecall;
    procedure Set_DateSavedFrom(Value: OleVariant); safecall;
    procedure Set_DateSavedTo(Value: OleVariant); safecall;
    procedure Set_SavedBy(const Value: WideString); safecall;
    procedure Set_DateCreatedFrom(Value: OleVariant); safecall;
    procedure Set_DateCreatedTo(Value: OleVariant); safecall;
    procedure Set_View(Value: MsoFileFindView); safecall;
    procedure Set_SortBy(Value: MsoFileFindSortBy); safecall;
    procedure Set_ListBy(Value: MsoFileFindListBy); safecall;
    procedure Set_SelectedFile(Value: SYSINT); safecall;
    procedure Execute; safecall;
    procedure Load(const bstrQueryName: WideString); safecall;
    procedure Save(const bstrQueryName: WideString); safecall;
    procedure Delete(const bstrQueryName: WideString); safecall;
    function Get_FileType: Integer; safecall;
    procedure Set_FileType(Value: Integer); safecall;
    property SearchPath: WideString read Get_SearchPath write Set_SearchPath;
    property Name: WideString read Get_Name write Set_Name;
    property SubDir: WordBool read Get_SubDir write Set_SubDir;
    property Title: WideString read Get_Title write Set_Title;
    property Author: WideString read Get_Author write Set_Author;
    property Keywords: WideString read Get_Keywords write Set_Keywords;
    property Subject: WideString read Get_Subject write Set_Subject;
    property Options: MsoFileFindOptions read Get_Options write Set_Options;
    property MatchCase: WordBool read Get_MatchCase write Set_MatchCase;
    property Text: WideString read Get_Text write Set_Text;
    property PatternMatch: WordBool read Get_PatternMatch write Set_PatternMatch;
    property DateSavedFrom: OleVariant read Get_DateSavedFrom write Set_DateSavedFrom;
    property DateSavedTo: OleVariant read Get_DateSavedTo write Set_DateSavedTo;
    property SavedBy: WideString read Get_SavedBy write Set_SavedBy;
    property DateCreatedFrom: OleVariant read Get_DateCreatedFrom write Set_DateCreatedFrom;
    property DateCreatedTo: OleVariant read Get_DateCreatedTo write Set_DateCreatedTo;
    property View: MsoFileFindView read Get_View write Set_View;
    property SortBy: MsoFileFindSortBy read Get_SortBy write Set_SortBy;
    property ListBy: MsoFileFindListBy read Get_ListBy write Set_ListBy;
    property SelectedFile: SYSINT read Get_SelectedFile write Set_SelectedFile;
    property Results: IFoundFiles read Get_Results;
    property FileType: Integer read Get_FileType write Set_FileType;
  end;

{ DispInterface declaration for Dual Interface IFind }

  IFindDisp = dispinterface
    ['{000C0337-0000-0000-C000-000000000046}']
    property SearchPath: WideString dispid 0;
    property Name: WideString dispid 1610743809;
    property SubDir: WordBool dispid 1610743810;
    property Title: WideString dispid 1610743811;
    property Author: WideString dispid 1610743812;
    property Keywords: WideString dispid 1610743813;
    property Subject: WideString dispid 1610743814;
    property Options: MsoFileFindOptions dispid 1610743815;
    property MatchCase: WordBool dispid 1610743816;
    property Text: WideString dispid 1610743817;
    property PatternMatch: WordBool dispid 1610743818;
    property DateSavedFrom: OleVariant dispid 1610743819;
    property DateSavedTo: OleVariant dispid 1610743820;
    property SavedBy: WideString dispid 1610743821;
    property DateCreatedFrom: OleVariant dispid 1610743822;
    property DateCreatedTo: OleVariant dispid 1610743823;
    property View: MsoFileFindView dispid 1610743824;
    property SortBy: MsoFileFindSortBy dispid 1610743825;
    property ListBy: MsoFileFindListBy dispid 1610743826;
    property SelectedFile: SYSINT dispid 1610743827;
    property Results: IFoundFiles readonly dispid 1610743828;
    function Show: SYSINT; dispid 1610743829;
    procedure Execute; dispid 1610743850;
    procedure Load(const bstrQueryName: WideString); dispid 1610743851;
    procedure Save(const bstrQueryName: WideString); dispid 1610743852;
    procedure Delete(const bstrQueryName: WideString); dispid 1610743853;
    property FileType: Integer dispid 1610743854;
  end;

  FoundFiles = interface(_IMsoDispObj)
    ['{000C0331-0000-0000-C000-000000000046}']
    function Get_Item(Index: SYSINT; lcid: Integer): WideString; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[Index: SYSINT; lcid: Integer]: WideString read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

{ DispInterface declaration for Dual Interface FoundFiles }

  FoundFilesDisp = dispinterface
    ['{000C0331-0000-0000-C000-000000000046}']
    property Application: IDispatch readonly dispid 1610743808;
    property Creator: Integer readonly dispid 1610743809;
    property Item[Index: SYSINT; lcid: Integer]: WideString readonly dispid 0; default;
    property Count: Integer readonly dispid 4;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

  PropertyTest = interface(_IMsoDispObj)
    ['{000C0333-0000-0000-C000-000000000046}']
    function Get_Name: WideString; safecall;
    function Get_Condition: MsoCondition; safecall;
    function Get_Value: OleVariant; safecall;
    function Get_SecondValue: OleVariant; safecall;
    function Get_Connector: MsoConnector; safecall;
    property Name: WideString read Get_Name;
    property Condition: MsoCondition read Get_Condition;
    property Value: OleVariant read Get_Value;
    property SecondValue: OleVariant read Get_SecondValue;
    property Connector: MsoConnector read Get_Connector;
  end;

{ DispInterface declaration for Dual Interface PropertyTest }

  PropertyTestDisp = dispinterface
    ['{000C0333-0000-0000-C000-000000000046}']
    property Name: WideString readonly dispid 0;
    property Condition: MsoCondition readonly dispid 2;
    property Value: OleVariant readonly dispid 3;
    property SecondValue: OleVariant readonly dispid 4;
    property Connector: MsoConnector readonly dispid 5;
  end;

  PropertyTests = interface(_IMsoDispObj)
    ['{000C0334-0000-0000-C000-000000000046}']
    function Get_Item(Index: SYSINT; lcid: Integer): PropertyTest; safecall;
    function Get_Count: Integer; safecall;
    procedure Add(const Name: WideString; Condition: MsoCondition; Value, SecondValue: OleVariant; Connector: MsoConnector); safecall;
    procedure Remove(Index: SYSINT); safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Item[Index: SYSINT; lcid: Integer]: PropertyTest read Get_Item; default;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

{ DispInterface declaration for Dual Interface PropertyTests }

  PropertyTestsDisp = dispinterface
    ['{000C0334-0000-0000-C000-000000000046}']
    property Application: IDispatch readonly dispid 1610743808;
    property Creator: Integer readonly dispid 1610743809;
    property Item[Index: SYSINT; lcid: Integer]: PropertyTest readonly dispid 0; default;
    property Count: Integer readonly dispid 4;
    procedure Add(const Name: WideString; Condition: MsoCondition; Value, SecondValue: OleVariant; Connector: MsoConnector); dispid 5;
    procedure Remove(Index: SYSINT); dispid 6;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

  FileSearch = interface(_IMsoDispObj)
    ['{000C0332-0000-0000-C000-000000000046}']
    function Get_SearchSubFolders: WordBool; safecall;
    procedure Set_SearchSubFolders(Value: WordBool); safecall;
    function Get_MatchTextExactly: WordBool; safecall;
    procedure Set_MatchTextExactly(Value: WordBool); safecall;
    function Get_MatchAllWordForms: WordBool; safecall;
    procedure Set_MatchAllWordForms(Value: WordBool); safecall;
    function Get_FileName: WideString; safecall;
    procedure Set_FileName(const Value: WideString); safecall;
    function Get_FileType: MsoFileType; safecall;
    procedure Set_FileType(Value: MsoFileType); safecall;
    function Get_LastModified: MsoLastModified; safecall;
    procedure Set_LastModified(Value: MsoLastModified); safecall;
    function Get_TextOrProperty: WideString; safecall;
    procedure Set_TextOrProperty(const Value: WideString); safecall;
    function Get_LookIn: WideString; safecall;
    procedure Set_LookIn(const Value: WideString); safecall;
    function Execute(SortBy: MsoSortBy; SortOrder: MsoSortOrder; AlwaysAccurate: WordBool): SYSINT; safecall;
    procedure NewSearch; safecall;
    function Get_FoundFiles: FoundFiles; safecall;
    function Get_PropertyTests: PropertyTests; safecall;
    property SearchSubFolders: WordBool read Get_SearchSubFolders write Set_SearchSubFolders;
    property MatchTextExactly: WordBool read Get_MatchTextExactly write Set_MatchTextExactly;
    property MatchAllWordForms: WordBool read Get_MatchAllWordForms write Set_MatchAllWordForms;
    property FileName: WideString read Get_FileName write Set_FileName;
    property FileType: MsoFileType read Get_FileType write Set_FileType;
    property LastModified: MsoLastModified read Get_LastModified write Set_LastModified;
    property TextOrProperty: WideString read Get_TextOrProperty write Set_TextOrProperty;
    property LookIn: WideString read Get_LookIn write Set_LookIn;
    property FoundFiles: FoundFiles read Get_FoundFiles;
    property PropertyTests: PropertyTests read Get_PropertyTests;
  end;

{ DispInterface declaration for Dual Interface FileSearch }

  FileSearchDisp = dispinterface
    ['{000C0332-0000-0000-C000-000000000046}']
    property Application: IDispatch readonly dispid 1610743808;
    property Creator: Integer readonly dispid 1610743809;
    property SearchSubFolders: WordBool dispid 1;
    property MatchTextExactly: WordBool dispid 2;
    property MatchAllWordForms: WordBool dispid 3;
    property FileName: WideString dispid 4;
    property FileType: MsoFileType dispid 5;
    property LastModified: MsoLastModified dispid 6;
    property TextOrProperty: WideString dispid 7;
    property LookIn: WideString dispid 8;
    function Execute(SortBy: MsoSortBy; SortOrder: MsoSortOrder; AlwaysAccurate: WordBool): SYSINT; dispid 9;
    procedure NewSearch; dispid 10;
    property FoundFiles: FoundFiles readonly dispid 11;
    property PropertyTests: PropertyTests readonly dispid 12;
  end;

  COMAddIn = interface(_IMsoDispObj)
    ['{000C033A-0000-0000-C000-000000000046}']
    function Get_Description: WideString; safecall;
    procedure Set_Description(const Value: WideString); safecall;
    function Get_ProgId: WideString; safecall;
    function Get_Guid: WideString; safecall;
    function Get_Connect: WordBool; safecall;
    procedure Set_Connect(Value: WordBool); safecall;
    function Get_Object_: IDispatch; safecall;
    procedure Set_Object_(Value: IDispatch); safecall;
    function Get_Parent: IDispatch; safecall;
    property Description: WideString read Get_Description write Set_Description;
    property ProgId: WideString read Get_ProgId;
    property Guid: WideString read Get_Guid;
    property Connect: WordBool read Get_Connect write Set_Connect;
    property Object_: IDispatch read Get_Object_ write Set_Object_;
    property Parent: IDispatch read Get_Parent;
  end;

{ DispInterface declaration for Dual Interface COMAddIn }

  COMAddInDisp = dispinterface
    ['{000C033A-0000-0000-C000-000000000046}']
    property Description: WideString dispid 0;
    property ProgId: WideString readonly dispid 3;
    property Guid: WideString readonly dispid 4;
    property Connect: WordBool dispid 6;
    property Object_: IDispatch dispid 7;
    property Parent: IDispatch readonly dispid 8;
  end;

  COMAddIns = interface(_IMsoDispObj)
    ['{000C0339-0000-0000-C000-000000000046}']
    function Item(var Index: OleVariant): COMAddIn; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    procedure Update; safecall;
    function Get_Parent: IDispatch; safecall;
    procedure SetAppModal(varfModal: WordBool); safecall;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Parent: IDispatch read Get_Parent;
  end;

{ DispInterface declaration for Dual Interface COMAddIns }

  COMAddInsDisp = dispinterface
    ['{000C0339-0000-0000-C000-000000000046}']
    function Item(var Index: OleVariant): COMAddIn; dispid 0;
    property Count: Integer readonly dispid 1;
    procedure Update; dispid 2;
    property Parent: IDispatch readonly dispid 3;
    procedure SetAppModal(varfModal: WordBool); dispid 4;
  end;

  LanguageSettings = interface(_IMsoDispObj)
    ['{000C0353-0000-0000-C000-000000000046}']
    function Get_LanguageID(Id: MsoAppLanguageID): SYSINT; safecall;
    function Get_LanguagePreferredForEditing(lid: MsoLanguageID): WordBool; safecall;
    property LanguageID[Id: MsoAppLanguageID]: SYSINT read Get_LanguageID;
    property LanguagePreferredForEditing[lid: MsoLanguageID]: WordBool read Get_LanguagePreferredForEditing;
  end;

{ DispInterface declaration for Dual Interface LanguageSettings }

  LanguageSettingsDisp = dispinterface
    ['{000C0353-0000-0000-C000-000000000046}']
    property LanguageID[Id: MsoAppLanguageID]: SYSINT readonly dispid 1;
    property LanguagePreferredForEditing[lid: MsoLanguageID]: WordBool readonly dispid 2;
  end;

  ICommandBarsEvents = interface(IDispatch)
    ['{55F88892-7708-11D1-ACEB-006008961DA5}']
    procedure OnUpdate; stdcall;
  end;

{ DispInterface declaration for Dual Interface ICommandBarsEvents }

  ICommandBarsEventsDisp = dispinterface
    ['{55F88892-7708-11D1-ACEB-006008961DA5}']
    procedure OnUpdate; dispid 1;
  end;

  _CommandBarsEvents = dispinterface
    ['{000C0352-0000-0000-C000-000000000046}']
    procedure OnUpdate; dispid 1;
  end;

  ICommandBarComboBoxEvents = interface(IDispatch)
    ['{55F88896-7708-11D1-ACEB-006008961DA5}']
    procedure Change(const Ctrl: _CommandBarComboBox); stdcall;
  end;

{ DispInterface declaration for Dual Interface ICommandBarComboBoxEvents }

  ICommandBarComboBoxEventsDisp = dispinterface
    ['{55F88896-7708-11D1-ACEB-006008961DA5}']
    procedure Change(const Ctrl: _CommandBarComboBox); dispid 1;
  end;

  _CommandBarComboBoxEvents = dispinterface
    ['{000C0354-0000-0000-C000-000000000046}']
    procedure Change(const Ctrl: _CommandBarComboBox); dispid 1;
  end;

  ICommandBarButtonEvents = interface(IDispatch)
    ['{55F88890-7708-11D1-ACEB-006008961DA5}']
    procedure Click(const Ctrl: _CommandBarButton; var CancelDefault: WordBool); stdcall;
  end;

{ DispInterface declaration for Dual Interface ICommandBarButtonEvents }

  ICommandBarButtonEventsDisp = dispinterface
    ['{55F88890-7708-11D1-ACEB-006008961DA5}']
    procedure Click(const Ctrl: _CommandBarButton; var CancelDefault: WordBool); dispid 1;
  end;

  _CommandBarButtonEvents = dispinterface
    ['{000C0351-0000-0000-C000-000000000046}']
    procedure Click(const Ctrl: _CommandBarButton; var CancelDefault: WordBool); dispid 1;
  end;

  WebPageFont = interface(_IMsoDispObj)
    ['{000C0913-0000-0000-C000-000000000046}']
    function Get_ProportionalFont: WideString; safecall;
    procedure Set_ProportionalFont(const Value: WideString); safecall;
    function Get_ProportionalFontSize: Single; safecall;
    procedure Set_ProportionalFontSize(Value: Single); safecall;
    function Get_FixedWidthFont: WideString; safecall;
    procedure Set_FixedWidthFont(const Value: WideString); safecall;
    function Get_FixedWidthFontSize: Single; safecall;
    procedure Set_FixedWidthFontSize(Value: Single); safecall;
    property ProportionalFont: WideString read Get_ProportionalFont write Set_ProportionalFont;
    property ProportionalFontSize: Single read Get_ProportionalFontSize write Set_ProportionalFontSize;
    property FixedWidthFont: WideString read Get_FixedWidthFont write Set_FixedWidthFont;
    property FixedWidthFontSize: Single read Get_FixedWidthFontSize write Set_FixedWidthFontSize;
  end;

{ DispInterface declaration for Dual Interface WebPageFont }

  WebPageFontDisp = dispinterface
    ['{000C0913-0000-0000-C000-000000000046}']
    property ProportionalFont: WideString dispid 10;
    property ProportionalFontSize: Single dispid 11;
    property FixedWidthFont: WideString dispid 12;
    property FixedWidthFontSize: Single dispid 13;
  end;

  WebPageFonts = interface(_IMsoDispObj)
    ['{000C0914-0000-0000-C000-000000000046}']
    function Get_Count: SYSINT; safecall;
    function Get_Item(Index: MsoCharacterSet): WebPageFont; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Count: SYSINT read Get_Count;
    property Item[Index: MsoCharacterSet]: WebPageFont read Get_Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

{ DispInterface declaration for Dual Interface WebPageFonts }

  WebPageFontsDisp = dispinterface
    ['{000C0914-0000-0000-C000-000000000046}']
    property Count: SYSINT readonly dispid 1;
    property Item[Index: MsoCharacterSet]: WebPageFont readonly dispid 0; default;
    property _NewEnum: IUnknown readonly dispid -4;
  end;

  HTMLProjectItem = interface(_IMsoDispObj)
    ['{000C0358-0000-0000-C000-000000000046}']
    function Get_Name: WideString; safecall;
    function Get_IsOpen: WordBool; safecall;
    procedure LoadFromFile(const FileName: WideString); safecall;
    procedure Open(OpenKind: MsoHTMLProjectOpen); safecall;
    procedure SaveCopyAs(const FileName: WideString); safecall;
    function Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function Get_Parent: IDispatch; safecall;
    property Name: WideString read Get_Name;
    property IsOpen: WordBool read Get_IsOpen;
    property Text: WideString read Get_Text write Set_Text;
    property Parent: IDispatch read Get_Parent;
  end;

{ DispInterface declaration for Dual Interface HTMLProjectItem }

  HTMLProjectItemDisp = dispinterface
    ['{000C0358-0000-0000-C000-000000000046}']
    property Name: WideString readonly dispid 0;
    property IsOpen: WordBool readonly dispid 4;
    procedure LoadFromFile(const FileName: WideString); dispid 5;
    procedure Open(OpenKind: MsoHTMLProjectOpen); dispid 6;
    procedure SaveCopyAs(const FileName: WideString); dispid 7;
    property Text: WideString dispid 8;
    property Parent: IDispatch readonly dispid 10;
  end;

  HTMLProjectItems = interface(_IMsoDispObj)
    ['{000C0357-0000-0000-C000-000000000046}']
    function Item(var Index: OleVariant): HTMLProjectItem; safecall;
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_Parent: IDispatch; safecall;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Parent: IDispatch read Get_Parent;
  end;

{ DispInterface declaration for Dual Interface HTMLProjectItems }

  HTMLProjectItemsDisp = dispinterface
    ['{000C0357-0000-0000-C000-000000000046}']
    function Item(var Index: OleVariant): HTMLProjectItem; dispid 0;
    property Count: Integer readonly dispid 1;
    property Parent: IDispatch readonly dispid 2;
  end;

  HTMLProject = interface(_IMsoDispObj)
    ['{000C0356-0000-0000-C000-000000000046}']
    function Get_State: MsoHTMLProjectState; safecall;
    procedure RefreshProject(Refresh: WordBool); safecall;
    procedure RefreshDocument(Refresh: WordBool); safecall;
    function Get_HTMLProjectItems: HTMLProjectItems; safecall;
    function Get_Parent: IDispatch; safecall;
    procedure Open(OpenKind: MsoHTMLProjectOpen); safecall;
    property State: MsoHTMLProjectState read Get_State;
    property HTMLProjectItems: HTMLProjectItems read Get_HTMLProjectItems;
    property Parent: IDispatch read Get_Parent;
  end;

{ DispInterface declaration for Dual Interface HTMLProject }

  HTMLProjectDisp = dispinterface
    ['{000C0356-0000-0000-C000-000000000046}']
    property State: MsoHTMLProjectState readonly dispid 0;
    procedure RefreshProject(Refresh: WordBool); dispid 1;
    procedure RefreshDocument(Refresh: WordBool); dispid 2;
    property HTMLProjectItems: HTMLProjectItems readonly dispid 3;
    property Parent: IDispatch readonly dispid 4;
    procedure Open(OpenKind: MsoHTMLProjectOpen); dispid 5;
  end;

  MsoDebugOptions = interface(_IMsoDispObj)
    ['{000C035A-0000-0000-C000-000000000046}']
    function Get_FeatureReports: SYSINT; safecall;
    procedure Set_FeatureReports(Value: SYSINT); safecall;
    property FeatureReports: SYSINT read Get_FeatureReports write Set_FeatureReports;
  end;

{ DispInterface declaration for Dual Interface MsoDebugOptions }

  MsoDebugOptionsDisp = dispinterface
    ['{000C035A-0000-0000-C000-000000000046}']
    property FeatureReports: SYSINT dispid 4;
  end;



implementation

uses ComObj;


end.
