typedef          char  CHAR;        // define to be  8 bits
typedef          short INT16;       // define to be 16 bits
typedef          int   INT;         // define to be 32 bits
typedef          long  LONG;        // define to be 32 bits
typedef unsigned char  UCHAR;       // define to be  8 bits unsigned
typedef unsigned short UINT16;      // define to be 16 bits unsigned
typedef unsigned int   UINT;        // define to be 32 bits unsigned
typedef unsigned long  ULONG;       // define to be 32 bits unsigned
typedef          INT   BOOL;        // boolean operator

#define TRUE  1
#define FALSE 0

class XYPoint {
  public:
	INT xp;
	INT yp;
    XYPoint(INT x,INT y) { xp=x; yp=y; }
    XYPoint(void)        { xp=0; yp=0; }
	BOOL operator ==(const XYPoint &p) const { return p.xp==xp && p.yp==yp; }
	operator =(const XYPoint &p) const { xp=p.xp; yp=p.yp; }
};

class Box {
  public:
	XYPoint  tlp;				// top left
	XYPoint  brp;				// bottom right
    Box(INT tl,INT br) { tlp=tl; brp=br; }
    Box(void)          { tlp=XYPoint(); brp=XYPoint(); }
	BOOL operator ==(const Box &b) const { return b.tlp==tlp && b.brp==brp; }
	operator =(const Box &b) const { tlp=b.tlp; brp=b.brp; }
};

class FormField {
	LONG   ident;           // unique field identifier
	string name;            // field name
	string type;            // field type
	XYPNT  pos;             // x/y co-ordinates
	CHAR   attrib;          // field attributes
	INT    size;            // field size
	INT    cls;             // item classification
	BOOL   mandcomp;        // TRUE when mandatory condition is ok
	string mandfunc;        // function for check of mandatory input
	string entryfunc;       // entry function
	string exitfunc;        // exit function
	string picture;         // picture format  (999-XXX.99)
	string range;           // range specifier (1-300,400-450)
	string pattern;         // pattern match   ([0-9][A-Z]??[0-9])
	string default;         // default value
	string itemdata;        // data contained in field
    FormField *next;        // the next field
    FormField *prev;        // the previous field
};

class Form {
	LONG       ident;       // unique form identifier
    string     name;        // form name
    string     type;        // form type
    INT16      access;      // form access level
    BOX        bounds;      // form boundaries
    CHAR       attrib;      // form attributes 
    UCHAR      numflds;     // the number of fields
    FormField *curitem;     // the current item selected
    FormField *firstfld;    // the list of items in order of display
};
