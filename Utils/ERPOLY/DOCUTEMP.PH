"add"
"erase
"erase_polygon:
"erase_polygon: Failed to get parameter"
(!gmli_
(!gmli_get_value(parameter)) {                 /* get a parameter */
(FALSE);
(Imap
(NUMB)
(TRUE);
(TRUE); /* found touching rectangle */
(l!=NULL) {
(poly
)currentpolypoint].
)numpolypoint
)p->
*GetPointsofIntersection(NUMB
*a,NUMB
*p,PLIST
*poly
*poly,int
*y,NUMB
*y1,XYPOINT
,'e');
/* 
BOOL
BOOL  - TRUE if
Call the GMLI erase_region command for each rectangle in the list
Called By
Calls
Co-ord.
Description
DoPolyErase
ERASEPLY.C
Erase
EraseRect
FALSE
Failed
Function
GML
Get all the points along a line that are intersected by the polygon
Get the angle between two points
Get the upper and lower bounds of the polygon
GetAngle
GetPointsofIntersection
GetUpLowBounds
Imap
Imcmp
Integer compare function for qsort()
Merge two adjacent rectangles of the same height
Modifies
Module
NUMB
NUMB *
PLIST *
Passed
Prototype
Return Value
Source
Synopsys
TRUE
The
Value
XYPOINT *poly  - The polygon points
YAdjRect
address
adjacent
adjust
all
along
and
angle
are
between
block
bottom
bounds
call
co-ordinate
code
collect
command
compare
coordinate
counter
current
double
each
edge
else
erase
erase_polygon
erase_region
error
first
for
found
free
free(l);
free(polypoint);
from
function
get
height
increment
index
int
int numply  - The number of points in the polygon
integer
intersect
intersection
l=l->next;
lastl->next=l->next; /* remove rectangle form list */
left
line
list
lower
mapping
memory
merge
msg_issue(
number
numply
numpolypoint
parameter
pnts->
point
points
poly
polygon
polypoint[(
qsort(
rectangle
rectangular
region
remov
reset
return
right
same
second
should
sign
sizeof
sorted
source code 
start
state
static
that
the
touching
two
upper
used
void
while
x,NUMB
y,XYPOINT
