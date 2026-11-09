Sub MAIN
FilePageSetup .Tab = "3", .PaperSize = "9", .TopMargin = "1" + Chr$(34), .BottomMargin = "1" + Chr$(34), .LeftMargin = "1.5" + Chr$(34), .RightMargin = "0.5" + Chr$(34), .Gutter = "0" + Chr$(34), .PageWidth = "8.27" + Chr$(34), .PageHeight = "11.69" + Chr$(34), .Orientation = 0, .FirstPage = 0, .OtherPages = 0, .VertAlign = 0, .ApplyPropsTo = 4, .FacingPages = 0, .HeaderDistance = "0.8" + Chr$(34), .FooterDistance = "0.8" + Chr$(34), .SectionStart = 2, .OddAndEvenPages = 0, .DifferentFirstPage = 1, .Endnotes = 0, .LineNum = 0, .StartingNum = "", .FromText = "", .CountBy = "0", .NumMode = -1
RightPara
Insert "UNISYS"
InsertPara
Insert "22 Southwark Bridge Road"
InsertPara
Insert "London  SE1 9HB"
LineUp 2
StartOfLine 1
Font "Times New Roman"
FormatFont .Points = "36", .Underline = 0, .Color = 6, .Strikethrough = 0, .Superscript = 0, .Subscript = 0, .Hidden = 0, .SmallCaps = 0, .AllCaps = 0, .Spacing = "0 pt", .Position = "0 pt", .Kerning = 0, .KerningMin = "", .Tab = "0", .Font = "Unisys", .Bold = 0, .Italic = 0, .Outline = 0, .Shadow = 0
LineDown 3
InsertPara
LeftPara
InsertPara
InsertPara
InsertPara
InsertPara
CenterPara
Insert "'C' Programmers Reference"
InsertPara
Insert "for"
InsertPara
Insert "Erase Polygon"
CharLeft 5, 1
LineUp 2, 1
StartOfLine 1
FontSize 20
LineDown 1
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
LeftPara
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
InsertPara
FontSize 8
Insert "Mark Durbin "
InsertDateTime .DateTimePic = "d MMMM, yyyy", .InsertAsField = 0
InsertPara
FontSize 12
InsertBreak .Type = 0
ViewHeader
ShowPrevHeaderFooter
ShowNextHeaderFooter
FontSize 8
Font "Arial"
Insert "'C' Programmers Reference" + Chr$(9) + "Erase Polygon" + Chr$(9) + "Page"
InsertPageField
CharLeft 1, 1
FontSize 8
Font "Arial"
CharLeft 1
Insert " "
GoToHeaderFooter
Insert "UNISYS" + Chr$(9) + "confidential" + Chr$(9)
InsertDateField
StartOfLine 1
MoveToolbar "Formatting", 1, -2, 28
Font "Arial"
FontSize 8
StartOfLine
CharRight 6, 1
FormatFont .Points = "14", .Underline = 0, .Color = 6, .Strikethrough = 0, .Superscript = 0, .Subscript = 0, .Hidden = 0, .SmallCaps = 0, .AllCaps = 0, .Spacing = "0 pt", .Position = "0 pt", .Kerning = 0, .KerningMin = "", .Tab = "0", .Font = "Unisys", .Bold = 0, .Italic = 0, .Outline = 0, .Shadow = 0
CloseViewHeaderFooter

TableInsertTable .ConvertFrom = "", .NumColumns = "2", .NumRows = "1", .InitialColWidth = "Auto", .Format = "0", .Apply = "167"
Insert "Function"
NextCell
Insert "DoPolyErase"
NextCell
MarkIndexEntry .Entry = "DoPolyErase"
TableSelectTable
TableAutoFormat .Format = 6, .Borders = 1, .Shading = 1, .Font = 1, .Color = 1, .AutoFit = 1, .HeadingRows = 1, .FirstColumn = 1, .LastRow = 0, .LastColumn = 0
TableColumnWidth .PrevColumn
TableColumnWidth .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34), .NextColumn
TableColumnWidth .ColumnWidth = "5" + Chr$(34), .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34)
RightPara
LineDown 1
LineUp 1
CharRight 2, 1
FontSize 10
CharLeft 1
LineUp 1
EndOfLine
StartOfLine 1
FormatFont .Color = 7
LineDown 1
NextCell
NextCell
Insert "Synopsis"
NextCell
Insert "Erase the polygon by rectangular region"
NextCell
NextCell
NextCell
Insert "Prototype"
NextCell
Insert "BOOL DoPolyErase(XYPOINT *poly,int numply,int increment);"
NextCell
NextCell
NextCell
Insert "Module"
NextCell
Insert "ERASEPLY.C"
NextCell
NextCell
NextCell
Insert "Description"
NextCell
Insert "Erase the polygon by passing over each point in the polygon in the  direction top to bottom and marking all the intersecting blocks for deletion once the entire polygon has been covered, any adjacent rectangles of the same width are merged. "
NextCell
NextCell
NextCell
Insert "Passed"
NextCell
Insert "XYPOINT *poly  - The polygon points"
NextCell
NextCell
NextCell
Insert " "
NextCell
Insert "int numply  - The number of points in the polygon"
NextCell
NextCell
NextCell
Insert " "
NextCell
Insert "int increment  - The minimum height of each rectangle"

NextCell
NextCell
NextCell
Insert "Return Value"
NextCell
Insert "BOOL  - always TRUE                                                              */"
NextCell
NextCell
NextCell
Insert "Called By"
NextCell
Insert "erase_polygon."
NextCell
NextCell
NextCell
Insert "Calls"
NextCell
Insert "GetUpLowBounds, GetPointsofIntersection, YAdjRect, EraseRect."
NextCell
NextCell
NextCell
Insert "See Also"
NextCell
Insert "EraseRect, erase_polygon, GetAngle, GetPointsofIntersection, GetUpLowBounds, Imcmp, YAdjRect."
LineDown 1
InsertPara
Font "Courier New"
FontSize 8
Bold
InsertPara
Insert "BOOL DoPolyErase(XYPOINT *poly,int numply,int increment)"
InsertPara
Insert "{"
InsertPara
Insert "    NUMB minY,maxY;     /* upper and lower bounds */"
InsertPara
Insert "    NUMB tmpy;          /* Y co-ordinate index counter */"
InsertPara
Insert "    NUMB *imap;         /* intersection map */"
InsertPara
Insert "    PLIST *pnts;        /* rectangle points structure */"
InsertPara
Insert "    PLIST *firstp=NULL; /* first point in list of rectangle points */"
InsertPara
Insert "    BOOL found;         /* flag to signify end of merge */"
InsertPara
Insert ""
InsertPara
Insert "    GetUpLowBounds(&minY,&maxY,poly,numply);     /* get upper & lower bounds */"
InsertPara
Insert ""
InsertPara
Insert "    for (tmpy=minY;tmpy<maxY;tmpy+=increment) {"
InsertPara
Insert "        imap=GetPointsofIntersection(tmpy,poly,numply);"
InsertPara
Insert "        while ((imap!=NULL)&&(*imap>=0)) {          /* list ok and not at end */"
InsertPara
Insert "            if ((pnts=malloc(sizeof(PLIST)))==NULL) return(FALSE);"
InsertPara
Insert "            pnts->X =*(imap++);"
InsertPara
Insert "            pnts->Y =tmpy;"
InsertPara
Insert "            pnts->X1=*(imap++);"
InsertPara
Insert "            pnts->Y1=tmpy+increment;"
InsertPara
Insert "            pnts->next=firstp;                                /* add to list */"
InsertPara
Insert "            firstp=pnts;                              /* reset start of list */"
InsertPara
Insert "        }"
InsertPara
Insert "    }"
InsertPara
Insert "    GetPointsofIntersection(-1,NULL,0);                  /* free used memory */"
InsertPara
Insert "    do {"
InsertPara
Insert "        pnts=firstp;"
InsertPara
Insert "        found=FALSE;"
InsertPara
Insert "        while (pnts!=NULL) {                     /* join adjacent rectangles */"
InsertPara
Insert "            if (YAdjRect(pnts,firstp)) found=TRUE;"
InsertPara
Insert "            pnts=pnts->next;"
InsertPara
Insert "        }"
InsertPara
Insert "    } while (found);"
InsertPara
Insert "    EraseRect(firstp);                                       /* do the erase */"
InsertPara
Insert "    return(TRUE);"
InsertPara
Insert "}"
InsertPara
Font "Times New Roman"
FontSize 12
Bold
InsertBreak .Type = 0
TableInsertTable .ConvertFrom = "", .NumColumns = "2", .NumRows = "1", .InitialColWidth = "Auto", .Format = "0", .Apply = "167"
Insert "Function"
NextCell
Insert "EraseRect"
NextCell
MarkIndexEntry .Entry = "EraseRect"
TableSelectTable
TableAutoFormat .Format = 6, .Borders = 1, .Shading = 1, .Font = 1, .Color = 1, .AutoFit = 1, .HeadingRows = 1, .FirstColumn = 1, .LastRow = 0, .LastColumn = 0
TableColumnWidth .PrevColumn
TableColumnWidth .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34), .NextColumn
TableColumnWidth .ColumnWidth = "5" + Chr$(34), .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34)
RightPara
LineDown 1
LineUp 1
CharRight 2, 1
FontSize 10
CharLeft 1
LineUp 1
EndOfLine
StartOfLine 1
FormatFont .Color = 7
LineDown 1
NextCell
NextCell
Insert "Synopsis"
NextCell
Insert "Call the GMLI erase_region command for each rectangle in the list"
NextCell
NextCell
NextCell
Insert "Prototype"
NextCell
Insert "void EraseRect(PLIST *p);"
NextCell
NextCell
NextCell
Insert "Module"
NextCell
Insert "ERASEPLY.C"
NextCell
NextCell
NextCell
Insert "Description"
NextCell
Insert "Call the GMLI erase_region command for each rectangle in the list, as each region is erased free the memory associated with the rectangle's list entry "
NextCell
NextCell
NextCell
Insert "Passed"
NextCell
Insert "PLIST *p  - The first element in the rectangle point list"

NextCell
NextCell
NextCell
Insert "Return Value"
NextCell
Insert "None"
NextCell
NextCell
NextCell
Insert "Modifies"
NextCell
Insert "p "
NextCell
NextCell
NextCell
Insert "Called By"
NextCell
Insert "DoPolyErase."
NextCell
NextCell
NextCell
Insert "See Also"
NextCell
Insert "DoPolyErase, erase_polygon, GetAngle, GetPointsofIntersection, GetUpLowBounds, Imcmp, YAdjRect."
LineDown 1
InsertPara
Font "Courier New"
FontSize 8
Bold
InsertPara
Insert "void EraseRect(PLIST *p)"
InsertPara
Insert "{"
InsertPara
Insert "    PLIST *prev;                      /* spare pointer for removing blocks */"
InsertPara
Insert "    char command[GMLI_MAX_PARM_SIZE]; /* space for command block */"
InsertPara
Insert "    while (p!=NULL) {"
InsertPara
Insert ""
InsertPara
Insert "        /* call to GML to erase region */"
InsertPara
Insert "        sprintf(command," + Chr$(34) + "erase area (%f,%f)(%f,%f)\n" + Chr$(34) + ","
InsertPara
Insert "            (double)p->X,(double)p->Y,(double)p->X1,(double)p->Y1);"
InsertPara
Insert ""
InsertPara
Insert "        if (!gmli_call_appl(command)) { /* error in call */"
InsertPara
Insert "            msg_issue(" + Chr$(34) + "erase_polygon: erase area failed" + Chr$(34) + ",'e');"
InsertPara
Insert "            return; "
InsertPara
Insert "        }"
InsertPara
Insert ""
InsertPara
Insert "        prev=p;"
InsertPara
Insert "        p=p->next;"
InsertPara
Insert "        free(prev);   /* free used block */"
InsertPara
Insert "    }"
InsertPara
Insert "}"
InsertPara
Font "Times New Roman"
FontSize 12
Bold
InsertBreak .Type = 0
TableInsertTable .ConvertFrom = "", .NumColumns = "2", .NumRows = "1", .InitialColWidth = "Auto", .Format = "0", .Apply = "167"
Insert "Function"
NextCell
Insert "erase_polygon"
NextCell
MarkIndexEntry .Entry = "erase_polygon"
TableSelectTable
TableAutoFormat .Format = 6, .Borders = 1, .Shading = 1, .Font = 1, .Color = 1, .AutoFit = 1, .HeadingRows = 1, .FirstColumn = 1, .LastRow = 0, .LastColumn = 0
TableColumnWidth .PrevColumn
TableColumnWidth .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34), .NextColumn
TableColumnWidth .ColumnWidth = "5" + Chr$(34), .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34)
RightPara
LineDown 1
LineUp 1
CharRight 2, 1
FontSize 10
CharLeft 1
LineUp 1
EndOfLine
StartOfLine 1
FormatFont .Color = 7
LineDown 1
NextCell
NextCell
Insert "Synopsis"
NextCell
Insert "erase a polygon using rectangular regions - called by GML"
NextCell
NextCell
NextCell
Insert "Prototype"
NextCell
Insert "BOOL erase_polygon(void);"
NextCell
NextCell
NextCell
Insert "Module"
NextCell
Insert "ERASEPLY.C"
NextCell
NextCell
NextCell
Insert "Description"
NextCell
Insert "This function is called repeatedly to collect arguments off the command line from GMLI on the first call the two parameters " + Chr$(34) + "add" + Chr$(34) + " the number of polygons and the increment size should be passed. On subsequent  calls the parameters should be the X and Y co-ordinates of one point in the polygon.  When all the points have been collected this function then calls DoPolyErase to do the work and then it frees the memory allocated  for the polygon points and returns FALSE. Any failure will also return FALSE "
NextCell
NextCell
NextCell
Insert "Return Value"
NextCell
Insert "BOOL  - TRUE if more parameters are required else FALSE"
NextCell
NextCell
NextCell
Insert "Modifies"
NextCell
Insert "numpolypoint currentpolypoint "
NextCell
NextCell
NextCell
Insert "Calls"
NextCell
Insert "DoPolyErase."
NextCell
NextCell
NextCell
Insert "See Also"
NextCell
Insert "DoPolyErase, EraseRect, GetAngle, GetPointsofIntersection, GetUpLowBounds, Imcmp, YAdjRect."
LineDown 1
InsertPara
Font "Courier New"
FontSize 8
Bold
InsertPara
Insert "BOOL erase_polygon(void)"
InsertPara
Insert "{"
InsertPara
Insert "    char parameter[GMLI_MAX_PARM_SIZE];  /* Space for parameter */"
InsertPara
Insert "    static int state=0;                  /* current parameter state */"
InsertPara
Insert "    static XYPOINT *polypoint=NULL;      /* Space for poly points */"
InsertPara
Insert "    static int increment=3;              /* increment size */"
InsertPara
Insert "    static NUMB numpolypoint=0;          /* number of poly points */"
InsertPara
Insert "    static NUMB currentpolypoint;        /* current poly point */"
InsertPara
Insert ""
InsertPara
Insert "    if (!gmli_get_value(parameter)) {                     /* get a parameter */"
InsertPara
Insert "        msg_issue(" + Chr$(34) + "erase_polygon: Failed to get parameter" + Chr$(34) + ",'e');"
InsertPara
Insert "        state=0;"
InsertPara
Insert "        return(FALSE);"
InsertPara
Insert "    }"
InsertPara
Insert "    if (state==0) {                                         /* initial state */"
InsertPara
Insert "        if (strcmp(parameter," + Chr$(34) + "add" + Chr$(34) + ")) {                      /* must be " + Chr$(34) + "add" + Chr$(34) + " */"
InsertPara
Insert "            msg_issue(" + Chr$(34) + "erase_polygon: parameter out of sequence" + Chr$(34) + ",'e');"
InsertPara
Insert "            return(FALSE);"
InsertPara
Insert "        }"
InsertPara
Insert "        if (!gmli_get_value(parameter)) {                 /* get a parameter */"
InsertPara
Insert "            msg_issue(" + Chr$(34) + "erase_polygon: Failed to get parameter" + Chr$(34) + ",'e');"
InsertPara
Insert "            return(FALSE);"
InsertPara
Insert "        }"
InsertPara
Insert "        numpolypoint=ATON(parameter); /* set number of points to receive */"
InsertPara
Insert "        if (numpolypoint<=0) {"
InsertPara
Insert "            msg_issue(" + Chr$(34) + "erase_polygon: Invalid number of poly points" + Chr$(34) + ",'e');"
InsertPara
Insert "            return(FALSE);"
InsertPara
Insert "        }"
InsertPara
Insert "        currentpolypoint=0;                          /* reset to start point */"
InsertPara
Insert "        if (polypoint!=NULL) free(polypoint);        /* free if error before */"
InsertPara
Insert "        polypoint=malloc((int)numpolypoint*sizeof(XYPOINT));"
InsertPara
Insert "        if (polypoint==NULL) {"
InsertPara
Insert "            msg_issue(" + Chr$(34) + "erase_polygon: Insufficient Memory for this operation" + Chr$(34) + ",'e');"
InsertPara
Insert "            return(FALSE);"
InsertPara
Insert "        }"
InsertPara
Insert "        if (!gmli_get_value(parameter)) {                 /* get a parameter */"
InsertPara
Insert "            msg_issue(" + Chr$(34) + "erase_polygon: Failed to get parameter" + Chr$(34) + ",'e');"
InsertPara
Insert "            return(FALSE);"
InsertPara
Insert "        }"
InsertPara
Insert "        increment=atoi(parameter); /* set the increment value */"
InsertPara
Insert "        state++;                                               /* next state */"
InsertPara
Insert "    } else {"
InsertPara
Insert "        polypoint[(int)currentpolypoint].X=ATON(parameter);     /* X Co-ord. */"
InsertPara
Insert "        if (!gmli_get_value(parameter)) {"
InsertPara
Insert "            state=0;"
InsertPara
Insert "            msg_issue(" + Chr$(34) + "erase_polygon: Failed to get parameter" + Chr$(34) + ",'e');"
InsertPara
Insert "            return(FALSE);"
InsertPara
Insert "        }"
InsertPara
Insert "        polypoint[(int)currentpolypoint].Y=ATON(parameter);     /* Y Co-ord. */"
InsertPara
Insert "        currentpolypoint++;"
InsertPara
Insert "        if (currentpolypoint==numpolypoint) {             /* reached maximum */"
InsertPara
Insert "            state=0;                                          /* reset state */"
InsertPara
Insert "            if (!DoPolyErase(polypoint,(int)numpolypoint,increment)) {"
InsertPara
Insert "                msg_issue(" + Chr$(34) + "erase_polygon: Erase Failed!" + Chr$(34) + ",'e');"
InsertPara
Insert "            }"
InsertPara
Insert "            if (polypoint!=NULL) free(polypoint);         /* free used space */"
InsertPara
Insert "            polypoint=NULL;"
InsertPara
Insert "            return(FALSE);                               /* signal last call */"
InsertPara
Insert "        }"
InsertPara
Insert "    }"
InsertPara
Insert "    return(TRUE);                             /* signal more points expected */"
InsertPara
Insert "}"
InsertPara
Font "Times New Roman"
FontSize 12
Bold
InsertBreak .Type = 0
TableInsertTable .ConvertFrom = "", .NumColumns = "2", .NumRows = "1", .InitialColWidth = "Auto", .Format = "0", .Apply = "167"
Insert "Function"
NextCell
Insert "GetAngle"
NextCell
MarkIndexEntry .Entry = "GetAngle"
TableSelectTable
TableAutoFormat .Format = 6, .Borders = 1, .Shading = 1, .Font = 1, .Color = 1, .AutoFit = 1, .HeadingRows = 1, .FirstColumn = 1, .LastRow = 0, .LastColumn = 0
TableColumnWidth .PrevColumn
TableColumnWidth .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34), .NextColumn
TableColumnWidth .ColumnWidth = "5" + Chr$(34), .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34)
RightPara
LineDown 1
LineUp 1
CharRight 2, 1
FontSize 10
CharLeft 1
LineUp 1
EndOfLine
StartOfLine 1
FormatFont .Color = 7
LineDown 1
NextCell
NextCell
Insert "Synopsis"
NextCell
Insert "Get the angle between two points"
NextCell
NextCell
NextCell
Insert "Prototype"
NextCell
Insert "double GetAngle(NUMB x,NUMB y,XYPOINT *b);"
NextCell
NextCell
NextCell
Insert "Module"
NextCell
Insert "ERASEPLY.C"
NextCell
NextCell
NextCell
Insert "Description"
NextCell
Insert "Get the angle between two points "
NextCell
NextCell
NextCell
Insert "Passed"
NextCell
Insert "NUMB x  - The X coordinate of the first point"
NextCell
NextCell
NextCell
Insert " "
NextCell
Insert "NUMB y  - The Y coordinate of the first point"
NextCell
NextCell
NextCell
Insert " "
NextCell
Insert "XYPOINT *b  - The second point"

NextCell
NextCell
NextCell
Insert "Return Value"
NextCell
Insert "double  - The angle between the two points                                         */"
NextCell
NextCell
NextCell
Insert "Called By"
NextCell
Insert "GetPointsofIntersection."
NextCell
NextCell
NextCell
Insert "See Also"
NextCell
Insert "DoPolyErase, EraseRect, erase_polygon, GetPointsofIntersection, GetUpLowBounds, Imcmp, YAdjRect."
LineDown 1
InsertPara
Font "Courier New"
FontSize 8
Bold
InsertPara
Insert "double GetAngle(NUMB x,NUMB y,XYPOINT *b)"
InsertPara
Insert "{"
InsertPara
Insert "    double dx=b->X-x;   /* delta x */"
InsertPara
Insert "    double dy=b->Y-y;   /* delta y */"
InsertPara
Insert "    if ((dx==0)&&(dy==0)) return 0;         /* avoid domain error in atan2() */"
InsertPara
Insert "    /* return angle so that top=0 right=90 bottom=180 left=270 degrees */"
InsertPara
Insert "    return 180.0-(atan2(dx,dy)*(180.0/M_PI));"
InsertPara
Insert "}"
InsertPara
Font "Times New Roman"
FontSize 12
Bold
InsertBreak .Type = 0
TableInsertTable .ConvertFrom = "", .NumColumns = "2", .NumRows = "1", .InitialColWidth = "Auto", .Format = "0", .Apply = "167"
Insert "Function"
NextCell
Insert "GetPointsofIntersection"
NextCell
MarkIndexEntry .Entry = "GetPointsofIntersection"
TableSelectTable
TableAutoFormat .Format = 6, .Borders = 1, .Shading = 1, .Font = 1, .Color = 1, .AutoFit = 1, .HeadingRows = 1, .FirstColumn = 1, .LastRow = 0, .LastColumn = 0
TableColumnWidth .PrevColumn
TableColumnWidth .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34), .NextColumn
TableColumnWidth .ColumnWidth = "5" + Chr$(34), .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34)
RightPara
LineDown 1
LineUp 1
CharRight 2, 1
FontSize 10
CharLeft 1
LineUp 1
EndOfLine
StartOfLine 1
FormatFont .Color = 7
LineDown 1
NextCell
NextCell
Insert "Synopsis"
NextCell
Insert "Get all the points along a line that are intersected by the polygon"
NextCell
NextCell
NextCell
Insert "Prototype"
NextCell
Insert "NUMB *GetPointsofIntersection(NUMB y,XYPOINT *poly,int numply);"
NextCell
NextCell
NextCell
Insert "Module"
NextCell
Insert "ERASEPLY.C"
NextCell
NextCell
NextCell
Insert "Description"
NextCell
Insert "Get all the points along a line that are intersected by the polygon, returning a list sorted from left to right "
NextCell
NextCell
NextCell
Insert "Passed"
NextCell
Insert "NUMB y  - The Y co-ordinate if the line"
NextCell
NextCell
NextCell
Insert " "
NextCell
Insert "XYPOINT *poly  - The polygon points"
NextCell
NextCell
NextCell
Insert " "
NextCell
Insert "int numply  - The number of points in the polygon"

NextCell
NextCell
NextCell
Insert "Return Value"
NextCell
Insert "NUMB *  - a sorted list of points, (-1) indicating the end of the list             */"
NextCell
NextCell
NextCell
Insert "Modifies"
NextCell
Insert "angle poly "
NextCell
NextCell
NextCell
Insert "Called By"
NextCell
Insert "DoPolyErase."
NextCell
NextCell
NextCell
Insert "Calls"
NextCell
Insert "GetAngle, Imcmp."
NextCell
NextCell
NextCell
Insert "See Also"
NextCell
Insert "DoPolyErase, EraseRect, erase_polygon, GetAngle, GetUpLowBounds, Imcmp, YAdjRect."
LineDown 1
InsertPara
Font "Courier New"
FontSize 8
Bold
InsertPara
Insert "NUMB *GetPointsofIntersection(NUMB y,XYPOINT *poly,int numply)"
InsertPara
Insert "{"
InsertPara
Insert "    static NUMB *Imap=NULL;     /* intersection mapping list */"
InsertPara
Insert "    int i;                      /* index counter of poly points */"
InsertPara
Insert "    int iofs;                   /* ofset in intersection mapping list */"
InsertPara
Insert "    double angle;               /* angle of poly line */"
InsertPara
Insert ""
InsertPara
Insert "    /* allocate room for 200 intersections */"
InsertPara
Insert "    if (Imap==NULL) Imap=malloc(200*sizeof(NUMB)); "
InsertPara
Insert ""
InsertPara
Insert "    if (y<0) {          /* -tive y - free used memory */"
InsertPara
Insert "        free(Imap);"
InsertPara
Insert "        Imap=NULL;"
InsertPara
Insert "        return(Imap);"
InsertPara
Insert "    }"
InsertPara
Insert ""
InsertPara
Insert "    iofs=0;                             "
InsertPara
Insert "    for (i=0;i<numply-1;i++) {"
InsertPara
Insert "        /* if polyline dissects line */"
InsertPara
Insert "        if (((poly->Y<y)&&((poly+1)->Y>=y))||((poly->Y>=y)&&((poly+1)->Y<y))) {"
InsertPara
Insert "            /* calculate intersection point */"
InsertPara
Insert "            angle=GetAngle(poly->X,poly->Y,poly+1);"
InsertPara
Insert "            Imap[iofs++]=poly->X-(tan(angle*(M_PI/180.0))*(y-poly->Y));"
InsertPara
Insert "        }                "
InsertPara
Insert "        poly++;"
InsertPara
Insert "    }"
InsertPara
Insert "    "
InsertPara
Insert "    if (iofs)     /* re-order from left to right */"
InsertPara
Insert "        qsort(Imap,iofs,sizeof(NUMB),(QSPTR)Imcmp);"
InsertPara
Insert ""
InsertPara
Insert "    Imap[iofs++]=(-1);                                      /* end of list */"
InsertPara
Insert "    return(Imap);"
InsertPara
Insert "}"
InsertPara
Font "Times New Roman"
FontSize 12
Bold
InsertBreak .Type = 0
TableInsertTable .ConvertFrom = "", .NumColumns = "2", .NumRows = "1", .InitialColWidth = "Auto", .Format = "0", .Apply = "167"
Insert "Function"
NextCell
Insert "GetUpLowBounds"
NextCell
MarkIndexEntry .Entry = "GetUpLowBounds"
TableSelectTable
TableAutoFormat .Format = 6, .Borders = 1, .Shading = 1, .Font = 1, .Color = 1, .AutoFit = 1, .HeadingRows = 1, .FirstColumn = 1, .LastRow = 0, .LastColumn = 0
TableColumnWidth .PrevColumn
TableColumnWidth .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34), .NextColumn
TableColumnWidth .ColumnWidth = "5" + Chr$(34), .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34)
RightPara
LineDown 1
LineUp 1
CharRight 2, 1
FontSize 10
CharLeft 1
LineUp 1
EndOfLine
StartOfLine 1
FormatFont .Color = 7
LineDown 1
NextCell
NextCell
Insert "Synopsis"
NextCell
Insert "Get the upper and lower bounds of the polygon"
NextCell
NextCell
NextCell
Insert "Prototype"
NextCell
Insert "void GetUpLowBounds(NUMB *y,NUMB *y1,XYPOINT *poly,int numply);"
NextCell
NextCell
NextCell
Insert "Module"
NextCell
Insert "ERASEPLY.C"
NextCell
NextCell
NextCell
Insert "Description"
NextCell
Insert "Get the upper and lower bounds of the polygon "
NextCell
NextCell
NextCell
Insert "Passed"
NextCell
Insert "NUMB *y  - The address of returned top Y co-ordinate"
NextCell
NextCell
NextCell
Insert " "
NextCell
Insert "NUMB *y1  - The address of returned bottom Y co-ordinate"
NextCell
NextCell
NextCell
Insert " "
NextCell
Insert "XYPOINT *poly  - The polygon points"
NextCell
NextCell
NextCell
Insert " "
NextCell
Insert "int numply  - The number of points in the polygon"

NextCell
NextCell
NextCell
Insert "Return Value"
NextCell
Insert "None"
NextCell
NextCell
NextCell
Insert "Modifies"
NextCell
Insert "y1 poly y "
NextCell
NextCell
NextCell
Insert "Called By"
NextCell
Insert "DoPolyErase."
NextCell
NextCell
NextCell
Insert "See Also"
NextCell
Insert "DoPolyErase, EraseRect, erase_polygon, GetAngle, GetPointsofIntersection, Imcmp, YAdjRect."
LineDown 1
InsertPara
Font "Courier New"
FontSize 8
Bold
InsertPara
Insert "void GetUpLowBounds(NUMB *y,NUMB *y1,XYPOINT *poly,int numply)"
InsertPara
Insert "{"
InsertPara
Insert "    int counter;              /* index counter */"
InsertPara
Insert "    *y1=*y=poly->Y;"
InsertPara
Insert "    for (counter=1;counter<numply;counter++) {      /* all points in polygon */"
InsertPara
Insert "        poly++;                                     "
InsertPara
Insert "        if (poly->Y<*y) {                           "
InsertPara
Insert "            *y=poly->Y;"
InsertPara
Insert "        } else if (poly->Y>*y1) {"
InsertPara
Insert "            *y1=poly->Y;"
InsertPara
Insert "        }"
InsertPara
Insert "    }"
InsertPara
Insert "}"
InsertPara
Font "Times New Roman"
FontSize 12
Bold
InsertBreak .Type = 0
TableInsertTable .ConvertFrom = "", .NumColumns = "2", .NumRows = "1", .InitialColWidth = "Auto", .Format = "0", .Apply = "167"
Insert "Function"
NextCell
Insert "Imcmp"
NextCell
MarkIndexEntry .Entry = "Imcmp"
TableSelectTable
TableAutoFormat .Format = 6, .Borders = 1, .Shading = 1, .Font = 1, .Color = 1, .AutoFit = 1, .HeadingRows = 1, .FirstColumn = 1, .LastRow = 0, .LastColumn = 0
TableColumnWidth .PrevColumn
TableColumnWidth .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34), .NextColumn
TableColumnWidth .ColumnWidth = "5" + Chr$(34), .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34)
RightPara
LineDown 1
LineUp 1
CharRight 2, 1
FontSize 10
CharLeft 1
LineUp 1
EndOfLine
StartOfLine 1
FormatFont .Color = 7
LineDown 1
NextCell
NextCell
Insert "Synopsis"
NextCell
Insert "Integer compare function for qsort()"
NextCell
NextCell
NextCell
Insert "Prototype"
NextCell
Insert "int Imcmp(NUMB *a,NUMB *b);"
NextCell
NextCell
NextCell
Insert "Module"
NextCell
Insert "ERASEPLY.C"
NextCell
NextCell
NextCell
Insert "Description"
NextCell
Insert "Integer compare function for qsort() "
NextCell
NextCell
NextCell
Insert "Passed"
NextCell
Insert "NUMB *a  - The address of the first integer"
NextCell
NextCell
NextCell
Insert " "
NextCell
Insert "NUMB *b  - The address of the second integer"

NextCell
NextCell
NextCell
Insert "Return Value"
NextCell
Insert "int  - a<b - (-1) a==b - 0 a>b - 1                                              */"
NextCell
NextCell
NextCell
Insert "Called By"
NextCell
Insert "GetPointsofIntersection."
NextCell
NextCell
NextCell
Insert "See Also"
NextCell
Insert "DoPolyErase, EraseRect, erase_polygon, GetAngle, GetPointsofIntersection, GetUpLowBounds, YAdjRect."
LineDown 1
InsertPara
Font "Courier New"
FontSize 8
Bold
InsertPara
Insert "int Imcmp(NUMB *a,NUMB *b)"
InsertPara
Insert "{"
InsertPara
Insert "    if (*a==*b) return 0;"
InsertPara
Insert "    if (*a>*b) return 1;"
InsertPara
Insert "    return -1;"
InsertPara
Insert "}"
InsertPara
Font "Times New Roman"
FontSize 12
Bold
InsertBreak .Type = 0
TableInsertTable .ConvertFrom = "", .NumColumns = "2", .NumRows = "1", .InitialColWidth = "Auto", .Format = "0", .Apply = "167"
Insert "Function"
NextCell
Insert "YAdjRect"
NextCell
MarkIndexEntry .Entry = "YAdjRect"
TableSelectTable
TableAutoFormat .Format = 6, .Borders = 1, .Shading = 1, .Font = 1, .Color = 1, .AutoFit = 1, .HeadingRows = 1, .FirstColumn = 1, .LastRow = 0, .LastColumn = 0
TableColumnWidth .PrevColumn
TableColumnWidth .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34), .NextColumn
TableColumnWidth .ColumnWidth = "5" + Chr$(34), .PrevColumn
TableColumnWidth .ColumnWidth = "1.2" + Chr$(34)
RightPara
LineDown 1
LineUp 1
CharRight 2, 1
FontSize 10
CharLeft 1
LineUp 1
EndOfLine
StartOfLine 1
FormatFont .Color = 7
LineDown 1
NextCell
NextCell
Insert "Synopsis"
NextCell
Insert "Merge two adjacent rectangles of the same height"
NextCell
NextCell
NextCell
Insert "Prototype"
NextCell
Insert "BOOL YAdjRect(PLIST *p,PLIST *l);"
NextCell
NextCell
NextCell
Insert "Module"
NextCell
Insert "ERASEPLY.C"
NextCell
NextCell
NextCell
Insert "Description"
NextCell
Insert "Merge two adjacent rectangles of the same height "
NextCell
NextCell
NextCell
Insert "Passed"
NextCell
Insert "PLIST *p  - The Current rectangle"
NextCell
NextCell
NextCell
Insert " "
NextCell
Insert "PLIST *l  - The list of all rectangles"

NextCell
NextCell
NextCell
Insert "Return Value"
NextCell
Insert "BOOL  - TRUE if the rectangle was merged with an adjacent one                    */"
NextCell
NextCell
NextCell
Insert "Modifies"
NextCell
Insert "l p "
NextCell
NextCell
NextCell
Insert "Called By"
NextCell
Insert "DoPolyErase."
NextCell
NextCell
NextCell
Insert "See Also"
NextCell
Insert "DoPolyErase, EraseRect, erase_polygon, GetAngle, GetPointsofIntersection, GetUpLowBounds, Imcmp."
LineDown 1
InsertPara
Font "Courier New"
FontSize 8
Bold
InsertPara
Insert "BOOL YAdjRect(PLIST *p,PLIST *l)"
InsertPara
Insert "{"
InsertPara
Insert "    PLIST *lastl;   /* previous point in list */"
InsertPara
Insert ""
InsertPara
Insert "    while (l!=NULL) {"
InsertPara
Insert "        lastl=l;"
InsertPara
Insert "        l=l->next;"
InsertPara
Insert "        if (l!=NULL) {"
InsertPara
Insert "            /* rectangles same width and start pos */"
InsertPara
Insert "            if ((l!=p)&&(l->X==p->X)&&(l->X1==p->X1)) {"
InsertPara
Insert "                /* touching along bottom edge */"
InsertPara
Insert "                if ((l->Y==p->Y1)||(l->Y==p->Y1+1)) { "
InsertPara
Insert "                    p->Y1=l->Y1;         /* adjust edge down */"
InsertPara
Insert "                    lastl->next=l->next; /* remove rectangle form list */"
InsertPara
Insert "                    free(l);"
InsertPara
Insert "                    return(TRUE); /* found touching rectangle */"
InsertPara
Insert "                }"
InsertPara
Insert "                /* touching along top edge */"
InsertPara
Insert "                if ((l->Y1==p->Y)||(l->Y1+1==p->Y)) {"
InsertPara
Insert "                    p->Y=l->Y;           /* adjust edge up */"
InsertPara
Insert "                    lastl->next=l->next; /* remove rectangle form list */"
InsertPara
Insert "                    free(l);"
InsertPara
Insert "                    return(TRUE); /* found touching rectangle */"
InsertPara
Insert "                }"
InsertPara
Insert "            }    "
InsertPara
Insert "            l=l->next;"
InsertPara
Insert "        }"
InsertPara
Insert "    }"
InsertPara
Insert "    return (FALSE); /* did not find touching rectangle */"
InsertPara
Insert "}"
InsertPara
Font "Times New Roman"
FontSize 12
Bold
InsertBreak .Type = 0
InsertIndex .Type = 0, .HeadingSeparator = 2, .RightAlignPageNumbers = 0, .Columns = 3, .Replace = 0
End Sub
