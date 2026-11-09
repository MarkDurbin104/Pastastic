/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	บ                                                               บ
	บ            fractal.cpp = Functions to treat fractals          บ
	บ                                                               บ
	บ                By Roger T. Stevens - 5/12/90                  บ
	บ                                                               บ
	ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <dos.h>
#include "render.hpp"

/* ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
   บ                                                               บ
   บ    gauss() = Function to generate Gaussian random variable    บ
   บ                                                               บ
   ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

float gauss(unsigned int seed)
{
	
	float x=0;
	int i;

	if (seed != 0)
		srand(seed);
	for (i=0; i<12; i++)
		x += (float)(rand())/32768.0;
	x -= 6.0;
	return(x);
}


  
/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ       Make_fractal_triangles() = Create four new fractal      บ
    บ                                  triangles from a triangle    บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object *Make_fractal_triangles(Vector loc, Vector vect1, Vector vect2,
	Vector vect3, Object *queue, int level)
{
	Vector bisect1, bisect2, bisect3, temp;
	unsigned int seed;
	float temp1, temp2, temp3, mu, max_ht;
	Triangle *newtri0, *newtri1, *newtri2, *newtri3;

	BBox *newobj;
	newtri0 = new Triangle;
	newtri1 = new Triangle;
	newtri2 = new Triangle;
	newtri3 = new Triangle;
	newtri0->col_data = new color_data;
	newtri1->col_data = new color_data;
	newtri2->col_data = new color_data;
	newtri3->col_data = new color_data;
	newobj = new BBox;
	
	newobj->type = BBOX;
	if (level == WORLD.level)
	{
		newobj->nextobj = queue;
		queue = newobj;
	}
	else
		newobj->nextobj = NULL;
	newtri0->loc = loc;
	newtri1->loc = loc + vect1;
	newtri2->loc = loc + vect2;
	bisect1 = loc + vect1 / 2;
	bisect2 = loc + vect2 / 2;
	bisect3 = newtri1->loc + (vect2 - vect1) / 2;
	seed = ((long)(bisect3.x * 10000 + bisect3.y * 100 + bisect3.z))%
		32767 + 2;
	bisect3.y += gauss(seed) * vect3.z;
	bisect3.y = MAX(bisect3.y, 0);
	seed = ((long)(bisect1.x * 10000 + bisect1.y * 100 + bisect1.z))%
		32767 + 2;
	bisect1.y += gauss(seed) * vect3.x;
	bisect1.y = MAX(bisect1.y, 0);
	seed = ((long)(bisect2.x * 10000 + bisect2.y * 100 + bisect2.z))%
		32767 + 2;
	bisect2.y += gauss(seed) * vect3.y;
	bisect2.y = MAX(bisect2.y, 0);
	*newtri0->col_data = def.col_data;
	*newtri1->col_data = def.col_data;
	*newtri2->col_data = def.col_data;
	*newtri3->col_data = def.col_data;
	newtri0->vect1 = bisect1 - newtri0->loc;
	newtri0->vect2 = bisect2 - newtri0->loc;
	newtri1->vect1 = bisect3 - newtri1->loc;
	newtri1->vect2 = bisect1 - newtri1->loc;
	newtri2->vect1 = bisect2 - newtri2->loc;
	newtri2->vect2 = bisect3 - newtri2->loc;
	newtri3->loc = bisect1;
	newtri3->vect1 = bisect3 - newtri3->loc;
	newtri3->vect2 = bisect2 - newtri3->loc;
	Fractal_comp(newtri0);
	Fractal_comp(newtri1);
	Fractal_comp(newtri2);
	Fractal_comp(newtri3);
	if (level > 0)
	{
		level--;
		newobj->child = Make_fractal_triangles(newtri3->loc, newtri3->vect1, 
			newtri3->vect2, newtri3->vect3, queue, level);
		newobj->child->nextobj = Make_fractal_triangles
			(newtri2->loc, newtri2->vect1, newtri2->vect2, newtri2->vect3, 
			queue, level);
		newobj->child->nextobj->nextobj = Make_fractal_triangles(newtri1->loc, 
			newtri1->vect1, newtri1->vect2, newtri1->vect3, queue, level);
		newobj->child->nextobj->nextobj->nextobj = Make_fractal_triangles(newtri0->loc, 
			newtri0->vect1, newtri0->vect2, newtri0->vect3, queue, 
			level);
		newobj->child->nextobj->nextobj->nextobj->nextobj = NULL;
		delete newtri0;
		delete newtri1;
		delete newtri2;
		delete newtri3;
	}
	else
	{
		newtri0->nextobj = NULL;
		newtri1->nextobj = newtri0;
		newtri2->nextobj = newtri1;
		newtri3->nextobj = newtri2;
		newobj->nextobj = NULL;
		newobj->child = newtri3;
		WORLD.objcount += 4;
	}
		if (level == WORLD.level)
			return(queue);
		return(newobj);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ         Fractal_comp() = Computes fractal parameters          บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Fractal_comp(Triangle *newobj)
{
	Vector temp;
	temp = newobj->vect2 - newobj->vect1;
	newobj->vect3.z = temp % temp;
	newobj->vect3.z = pow(newobj->vect3.z/4,WORLD.fractal_dim) *
		WORLD.fractal_scalar;
	newobj->vect3.x = newobj->vect1 % newobj->vect1;
	newobj->vect3.x = pow(newobj->vect3.x/4,WORLD.fractal_dim) *
		WORLD.fractal_scalar;
	newobj->vect3.y = newobj->vect2 % newobj->vect2;
	newobj->vect3.y = pow(newobj->vect3.y/4,WORLD.fractal_dim) * 
		WORLD.fractal_scalar;
	newobj->norm = newobj->vect1 ^ newobj->vect2;
	newobj->norm = ~ newobj->norm;
	newobj->n1 = newobj->norm % newobj->loc;
	newobj->len1 = newobj->vect1 % newobj->vect1;
	newobj->len2 = newobj->vect2 % newobj->vect2;
}
