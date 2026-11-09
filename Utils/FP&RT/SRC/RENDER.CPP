/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ            Raytrace = Simplified Ray Tracing Program          บ
    บ                                                               บ
    บ                  By Roger T. Stevens - 6/30/90                บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

unsigned _stack = 30000;
#include "render.hpp"
#include <dos.h>
#include <string.h>
 
extern char string_types[128][32];

#define MAXX   800 
int XSIZE = 640;
int YSIZE = 480;
int CENTERX = XSIZE/2;
int CENTERY = YSIZE/2;
int XSIZE4  = XSIZE/4;
int i;
char file_in[32];

World WORLD;      // All of the data to be processed
DEF     def;         // color defaults 
int     linenumber;  

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ               init_world() = Initialize the WORLD             บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/
void init_world(void) 
{
	WORLD.stack      = NULL;
  	WORLD.instances  = NULL;
  	WORLD.patlist    = NULL;
  	WORLD.outfile[0] = NULL;
  	WORLD.lamps      = NULL;
	WORLD.line       = NULL;
  	WORLD.objcount   = 0;
  	WORLD.lampcount  = 0;
  	WORLD.flength    = 250;
  	WORLD.first_scan = 0;
  	WORLD.last_scan  = YSIZE-1;
	WORLD.obsup = Vector(0,1,0);
	WORLD.obsloc = Vector(50,70,115);
  	WORLD.skycolor_zenith = Vector();
  	WORLD.skycolor_horiz  =Vector();
  	WORLD.sky_dither = 0;	
  	WORLD.ray_intersects  =
  	WORLD.pixels_hit      =
  	WORLD.primary_traced  =
  	WORLD.to_lamp         =
  	WORLD.refl_trans      =
  	WORLD.bbox_intersects =
  	WORLD.pattern_matches =
  	WORLD.intersect_tests = 0;
  	WORLD.globindex = 1.00;  
	WORLD.threshold = .1;
	WORLD.int_threshold = WORLD.threshold * CNUM;
	WORLD.fractal_dim = 0.9;
	WORLD.level = 4;
	WORLD.fractal_scalar = 0.002;
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ           init_color() = Sets up default color data           บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void init_color(void) 
{
  	def.col_data.trans   = Vector();
  	def.col_data.mirror  = Vector();
  	def.col_data.amb     = Vector(25,25,25);
  	def.col_data.diff    = Vector(48,27,9);
  	def.col_data.density = Vector(.01, .01, .01);
  	def.col_data.index    = CNUM;
  	def.col_data.dither   = 3;
  	def.col_data.reflect  = 0;
  	def.col_data.sreflect = 10;
  	def.shadow      = TRUE;      
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ           Overload of '=' operator for Object class           บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object Object::operator=(Object & rvalue)
{
	type = rvalue.type;
	strcpy(name,rvalue.name);
	loc = rvalue.loc;
	vect1 = rvalue.vect1;
	vect2 = rvalue.vect2;
	vect3 = rvalue.vect3;
	lower = rvalue.lower;
	upper = rvalue.upper;
	norm = rvalue.norm;
	cterm = rvalue.cterm;
	yterm = rvalue.yterm;
	xmult = rvalue.xmult;
	ymult = rvalue.ymult;
	n1 = rvalue.n1;
	len1 = rvalue.len1;
	len2 = rvalue.len2;
	cos1 = rvalue.cos1;
	sin1 = rvalue.sin1;
	cos2 = rvalue.cos2;
	sin2 = rvalue.sin2;
	col_data = rvalue.col_data;
  	nextobj = rvalue.nextobj;
	child = rvalue.child;
    pattern = rvalue.pattern;
	remove = rvalue.remove;
	return *this;
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ         Overload of '=' operator for color_data class         บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

color_data color_data::operator=(color_data & rvalue)
{
	amb = rvalue.amb;
	diff = rvalue.diff;
	mirror = rvalue.mirror;
	trans = rvalue.trans;
	density = rvalue.density;
	reflect = rvalue.reflect;
	index = rvalue.index;
	sreflect = rvalue.sreflect;
	dither = rvalue.dither;
	return *this;
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ        Function to display ray tracing statistics             บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void World_Stats()
{
	printf("    ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป\n");
	printf("    บ                                                               บ\n");
	printf("    บ                        World Statistics                       บ\n");
	printf("    บ                                                               บ\n");
	printf("    บ    Objects:                            %4d                   บ\n",
		WORLD.objcount);
	printf("    บ    Lamps:                              %4d                   บ\n",
		WORLD.lampcount);
	printf("    บ    Intersect tests:                %8ld                   บ\n",
		WORLD.intersect_tests);
	printf("    บ    Total intersections:            %8ld                   บ\n",
		WORLD.ray_intersects + WORLD.bbox_intersects);
	printf("    บ    Object intersections:           %8ld                   บ\n",
		WORLD.ray_intersects);
	printf("    บ    Bounding Box intersections:     %8ld                   บ\n",
		WORLD.bbox_intersects);
	printf("    บ    Rays traced:                    %8ld                   บ\n",
		WORLD.primary_traced + WORLD.to_lamp + WORLD.refl_trans);
	printf("    บ        Primary:                    %8ld                   บ\n",
		WORLD.primary_traced);
	printf("    บ        To lamps:                   %8ld                   บ\n",
		WORLD.to_lamp);
	printf("    บ        Reflected or Transmitted:   %8ld                   บ\n",
		WORLD.refl_trans);
	printf("    บ    Pattern matches:                %8ld                   บ\n",
		WORLD.pattern_matches);
	printf("    บ    Data set to file:               %12s               บ\n",
		WORLD.outfile);
	printf("    บ                                                               บ\n");
	printf("    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ\n");

}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ           Function to open file and enter image size          บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Open_File()
{
	if ((WORLD.filept=fopen(WORLD.outfile,"wb"))==NULL)
    {
		cout << "Unable to open output file";
		exit(1);
	}
	fputc((unsigned char)(XSIZE &  0xff),WORLD.filept);
  	fputc((unsigned char)(XSIZE >> 8),   WORLD.filept);
  	fputc((unsigned char)(YSIZE &  0xff),WORLD.filept);
  	fputc((unsigned char)(YSIZE >> 8),   WORLD.filept);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ                  Function to close output file                บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Close_File()
{
	if (fclose(WORLD.filept)) 
    {
		cout << "Unable to close output file";
		exit(1);
	}
}


/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ                 Main Program for Ray Tracer                   บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

int _cdecl main(int argc, char *argv[])
{
	Object *test, *test2;

	if (argc < 2)
	{
		cout << "File name required.\n";
		exit(1);
	}
	strcpy(file_in,argv[1]);
	init_world();
	init_color();
	if (!LoadWorld()) 
	{
		cout << "Syntax error in loading world\n";
		exit(1);
	}
	Make_Bbox(WORLD.stack);     /* make bboxes */
	test = WORLD.stack;
	cout << "\nImage size:  " << XSIZE <<" pixels horizontal by "
		<< YSIZE << " pixels vertical.\n";
	cout << "\nFile name is: "<< WORLD.outfile << "\n";
	Open_File();
	Trace_Scene();
	Close_File();
	World_Stats();
	fclose(stdout);
	return(NULL);
}


