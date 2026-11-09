/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	บ                                                               บ
	บ             Header File for Ray Tracing Program               บ
	บ                                                               บ
	บ                By Roger T. Stevens - 3/1/90                   บ
	บ                                                               บ
	ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "vmath.hpp"


/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ                      Object Definitions                       บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#define PATT_HEADER        0
#define LINE               1
#define SPHERE             2
#define PARALLELOGRAM      3
#define TRIANGLE           4
#define LAMP               5
#define OBSERVER           6
#define GROUND             7
#define SKY                8
#define BBOX               9
#define RING               10
#define QUADRATIC          11
#define BEGIN_BBOX         12
#define END_BBOX           13
#define BEGIN_INSTANCES    14
#define END_INSTANCES      15
#define AMB                16
#define DIFF               17
#define MIRROR             18
#define TRANS              19
#define DENSITY            20
#define INDEX              21
#define DITHER             22
#define SREFLECT           23
#define REFLECT            24
#define LOC                25
#define	RADIUS             26
#define PAttern            27
#define REMOVE             28
#define XMULT              29
#define YMULT              30
#define NAME               31
#define DIST               32
#define LOOKAT             33
#define V1                 34
#define V2                 35
#define ZENITH             36
#define HORIZ              37
#define RAD_1              38
#define RAD_2              39
#define A                  40
#define B                  41
#define C                  42
#define D                  43
#define E                  44
#define	XMAX               45
#define YMAX               46
#define ZMAX               47
#define XMIN               48
#define YMIN               49
#define ZMIN               50
#define DIR                51
#define FOC_LENGTH         52
#define FIRST_SCAN         53
#define DEFAULT            54
#define FILE_NAME          55
#define LAST_SCAN          56
#define XRES               57
#define YRES               58	
#define X_SIZE			   59
#define Y_SIZE             60
#define START_X            61
#define START_Y            62
#define END_X              63
#define END_Y              64
#define PAREN              65
#define NO_SHADOW          66
#define NO_LAMP            67
#define THRESHOLD          68
#define UP                 69
#define INSTANCE_OF        70
#define SCALE              71
#define RECTANGLE          72
#define CIRCLE             73
#define POLYGON            74
#define COLOR              75
#define POINT              76
#define CONE               77
#define HEIGHT             78
#define FRACTAL            79
#define DIMENSION          80
#define SCALAR             81
#define NUll               82
#define last_no            83 


/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ                       Useful Constants                        บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#define TRUE  1
#define FALSE 0
#define SMALL         0.001
#define ASPECT        1.0        // aspect ratio
#define CNUM         63          // number of shades of color minus one
#define MAX_IX        4          // maximum x interpolation 
#define MAX_IY        4          // maximum y interpolation 
#define max_pixel   800          // maximum of RGB array size (dots per row)
extern int XSIZE;
extern int YSIZE;
extern int CENTERX;
extern int CENTERY;
extern int XSIZE4;

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ                   Color Data Definitions                      บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

class color_data 
{
	public:
	Vector		amb,           // ambient lighting 
                diff,          // diffuse lighting 
                mirror,        // % light reflected
                trans,         // % light transmitted
                density;       // density 
  	float       reflect,       // percent specularly reflected
                index;         // index if refraction 
  	short       sreflect,      // specular refl coefficient
                dither;        // color dithering
	color_data operator=(color_data&);
};
 


/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ               Class definition for Line                       บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

class Line
{
	public:
	Vector loc,dir;
	int flag;
};

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ               Class definition for Lamp                       บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

class Lamp
{
	public:
	Vector loc;
	float radius, distance;
	Lamp * next_lamp;
};

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ               Class definition for a Pattern                  บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

class Pattern 
{
	public:
	short		type;               // type of pattern 
	float   	xsize,              // pattern size in x direction
            	ysize,              // pattern size in y direction
            	startx,             // x coordinate starting position
            	starty,             // y coordinate starting position
            	endx,               // x coordinate ending position
            	endy,               // y coordinate ending position
            	radius;             // radius of circle pattern
  	color_data  col_data;           // color information 
  	char    	name[32];           // name of pattern
  	Pattern     *child,
				*sibling,
				*link;
};

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ                Class Definitions for Object                   บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

class Object 
{
	public:
	unsigned char		type,         // object type 
						flag;
	char          		name[16];     // object name 
  	Vector        		loc,          // object location 
                		vect1,        // three vectors 
                		vect2,
                		vect3,
                		lower,        // lower bound
                		upper,        // upper bound
						norm;
	float         		cterm,        // used for quadratic surfaces only 
						yterm,
                		xmult,        // x  multiplier for patterns 
                		ymult,        // y multiplier for pattern
                        n1,           // precomputed values
                        len1,
                        len2,
                        cos1,
                        sin1,
                        cos2,
                        sin2;
  	color_data          *col_data;     // color information 
  	Object          	*nextobj, 	  // address of next object in list
                    	*child;       // address of child for bounding boxes 
  	Pattern             *pattern,     // address of pattern structure 
                		*remove;      // address of struct to remove obj section
	Object operator=(Object &);
	void FindNorm(Vector * normal, Vector * position);		//
	void Position (float * pos1, float *pos2, Vector *location);	//
	int CollisionTest(Line * line, float *t);			//
	void FindBbox(Vector * v1, Vector * v2);			//
	void Scale_Instance(Vector *mult, int fflag);			//
};

class Sphere: public Object
{
	public:
	Sphere();
	void FindNorm(Vector * normal, Vector * position);
	void Position (float * pos1, float *pos2, Vector *location);
	int CollisionTest(Line * line, float *t);
	void FindBbox(Vector * v1, Vector * v2);
	void Scale_Instance(Vector *mult, int fflag);
};

class Triangle: public Object
{
	public:
	Triangle();
	void FindNorm(Vector * normal, Vector * position);
	void Position (float * pos1, float *pos2, Vector *location);
	int CollisionTest(Line * line, float *t);
	void FindBbox(Vector * v1, Vector * v2);
	void Scale_Instance(Vector *mult, int fflag);
};

class Parallelogram: public Object
{
	public:
	Parallelogram();
	void FindNorm(Vector * normal, Vector * position);
	void Position (float * pos1, float *pos2, Vector *location);
	int CollisionTest(Line * line, float *t);
	void FindBbox(Vector * v1, Vector * v2);
	void Scale_Instance(Vector *mult, int fflag);
};

class Ring: public Object
{
	public:
	Ring();
	void FindNorm(Vector * normal, Vector * position);
	void Position (float * pos1, float *pos2, Vector *location);
	int CollisionTest(Line * line, float *t);
	void FindBbox(Vector * v1, Vector * v2);
	void Scale_Instance(Vector *mult, int fflag);
};

class Quadratic: public Object
{
	public:
	Quadratic();
	void FindNorm(Vector * normal, Vector * position);
	void Position (float * pos1, float *pos2, Vector *location);
	int CollisionTest(Line * line, float *t);
	void FindBbox(Vector * v1, Vector * v2);
	void Scale_Instance(Vector *mult, int fflag);
};


class BBox: public Object
{
	int CollisionTest(Line * line, float *t);
	void FindBbox(Vector * v1, Vector * v2);
};

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ                    Structure for the World                    บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

typedef struct world 
{
	Object 			* stack,            // list of objects in picture
            		* instances;        // list of user defined primitives
	Lamp            * lamps;            // list of lamps
	Line            * line;             
  	int       		objcount,           // number of objects
            		lampcount,          // number of lamps
            		first_scan,         // first scan line
            		last_scan;          // last scan line
  	long      		ray_intersects,     // statistics
            		primary_traced,
            		to_lamp,
            		refl_trans,
            		bbox_intersects,
            		intersect_tests,
            		pixels_hit,
            		pattern_matches;
  	Vector    		obsright,         // observer right direction
            		obsup,            // observer up direction
					obsloc,           // location of observer
					obsdir,	          // direction in which observer looks
                    skycolor_horiz,   // sky color at horizon 
            		skycolor_zenith;  // sky color at zenith
	float			sky_dither;
  	Pattern *	patlist;              // list of pattern addresses
  	float     		flength,          // focal length 
            		globindex;        // global index of refraction 
  	char      		outfile[32];      // output file name 
  	FILE      		*filept;          // output file pointer 
	float           threshold;
	float           int_threshold,
					fractal_dim,
					fractal_scalar;
	int				level;
	
} 
World;

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

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ                Structure of Default Values                    บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

typedef struct def_struct 
{
	color_data 		col_data;      // default colorinfo
  	short 		shadow;            // compute shadows ? 
  	float 		threshold;         // cutoff point for min refl, refl rays 
  	short 		ithreshold;        // integer version of above 
} 
DEF;

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ                      Set up of Variables                      บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

extern World WORLD;         // the world of objects in the scene
extern DEF     def;         // default values for some parameters
extern int     linenumber;  // line counter 


/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ               Function Prototypes for RENDER.C                บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void init_world(void);
void init_color(void);
void World_Stats(void);
void Open_File();
void Close_File();
void scanner(Object * test);

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ               Function Prototypes for INPUT.C                 บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Pattern *Attach_Pattern();
int GetAttrib(int type,char string_buf[]);
Pattern *Get_Circle_Pattern();
int get_color_data(int type, color_data *col_data);
Object * get_data();
int GetLamp();
int LoadWorld();
Object * Get_Object(int type,Object *queue);
Object * GetParallelogram();
int GetPattern();
Pattern *Get_Poly_Pattern();
Pattern *Get_Rect_Pattern();
Object * GetRing();
Object * GetSphere();
int get_string(char string_buf[]);
Pattern *Get_SubPattern(int type);
Object * GetTriangle();
Object * GetQuadratic();
void Make_Bbox(Object *node);
Object * Name_Find(Object * obj,char *name);
Object * Move_Instance(Object * obj, int fflag);
void Offset_Instance(Object * obj,Vector * offset,int fflag);
Object * Get_Instance_Of();
void Fractal_comp(Triangle * newobj);
Object * Make_fractal_triangles(Vector loc, Vector vect1, Vector vect2, 
	Vector vect3, Object * queue, int level);

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ                Function Prototypes for RAY.C                  บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Trace_Scene();
void DiffuseColor(Vector * color,color_data * col_data,Vector * norm,Vector * loc,
	Line * oline);
void Dump_Line(int lineno,char r[],char g[],char b[]);
void AmbientColor(Vector * color, color_data * col_data, Vector * norm, Vector * loc);
void TransparentColor(Vector * color, color_data * col_data,Vector * norm,Vector * loc,
	Line * line,float inmult);
void ReflectColor(Vector * color,color_data * col_data,Vector * norm,Vector * loc,
	Line * line,float inmult);
void SkyColor(Line * line,Vector * color);
void Dither(Vector * color,float dither);
void Dither(Vector * color,color_data * col_data);
Object * Intersect(Object * CurrObj,Line * line,float *shortest_time,
	short shadow_flag, short init_flag,Vector * atten);
int Trace_Ray(Line * line,Vector * color,float multiplier);
int Find_Color(Object * obj,Pattern *pattern, Vector * location, 
	color_data *c_data, float x_mult, float y_mult);



