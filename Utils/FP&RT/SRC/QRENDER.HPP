/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	บ                                                               บ
	บ         Header File for Quaternion Ray Tracing Program        บ
	บ                                                               บ
	บ                By Roger T. Stevens - 7/10/90                  บ
	บ                                                               บ
	ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include <dos.h>
#include <stream.hpp>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <conio.h>
#include <stdlib.h>
#include <ctype.h>
#include "qmath.hpp"

#define BACKGROUND        0
#define AMB               1
#define DIFF              2
#define SREFLECT          3
#define REFLECT           4
#define FILE_NAME         5
#define FLIP              6
#define LIGHT_PHI         7
#define LIGHT_THETA       8
#define VIEW_PHI          9
#define XRES             10
#define YRES             11
#define XMAX             12
#define XMIN             13
#define YMAX             14
#define YMIN             15
#define ZMAX             16
#define ZMIN             17
#define QUATERNION       18
#define MAX_SIZE         19
#define MAX_ITERATIONS   20
#define JULIA            21
#define DRAGON           22
#define Null             23
#define last_no          24 

void compute_color(char FileName[32]);
Vector Intensity(int i, int j);
int get_string(char string_buf[]);
int qin(void);

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ                     Math Definitions                          บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#define MIN(x,y) ((x)<(y) ? (x) : (y))
#define MAX(x,y) ((x)>(y) ? (x) : (y))
#define Max(x,y,z)  (x>y && x>z ? x : (y>z ? y : z))
#define Min(x,y,z)  (x<y && x<z ? x : (y<z ? y : z))


