/*          
			ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ  objects.c = Functions belonging to each of the classes       บ
            บ              derived from the Object class.                   บ
            บ                                                               บ
            บ                 By Roger T. Stevens 6/30/90                   บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include "render.hpp"

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                      Sphere Constructor                       บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Sphere::Sphere()
{
	type = SPHERE;
	nextobj = NULL;
	child = NULL;
	pattern = NULL;
	remove = NULL;
	name[0] = NULL;
	xmult = 1;
	ymult = 1;
	upper = Vector();
	lower = Vector();
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                    Triangle Constructor                       บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Triangle::Triangle()
{
	type = TRIANGLE;
	nextobj = NULL;
	child = NULL;
	pattern = NULL;
	remove = NULL;
	name[0] = NULL;
	xmult = 1;
	ymult = 1;
	upper = Vector();
	lower = Vector();
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                      Ring Constructor                         บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Ring::Ring()
{
	type = RING;
	nextobj = NULL;
	child = NULL;
	pattern = NULL;
	remove = NULL;
	name[0] = NULL;
	xmult = 1;
	ymult = 1;
	upper = Vector();
	lower = Vector();
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                 Parallelogram Constructor                     บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Parallelogram::Parallelogram()
{
	type = PARALLELOGRAM;
	nextobj = NULL;
	child = NULL;
	pattern = NULL;
	remove = NULL;
	name[0] = NULL;
	xmult = 1;
	ymult = 1;
	upper = Vector();
	lower = Vector();
	vect3 = Vector();
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                    Quadratic Constructor                      บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quadratic::Quadratic()
{
	type = QUADRATIC;
	nextobj = NULL;
	child = NULL;
	pattern = NULL;
	remove = NULL;
	name[0] = NULL;
	cterm = 0;
	yterm = 0;
	xmult = 1;
	ymult = 1;
	upper = Vector();
	lower = Vector();
}


/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ              Normal finder for generic object                 บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Object::FindNorm(Vector * normal, Vector * position)
{
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                   Normal finder for sphere                    บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Sphere::FindNorm(Vector * normal, Vector * position)
{
	 	* normal = *position - loc;
	  	* normal = ~ *normal;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ               Normal finder for parallelogram                 บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Parallelogram::FindNorm(Vector * normal, Vector * position)
{
	*normal = norm;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                 Normal finder for triangle                    บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Triangle::FindNorm(Vector * normal, Vector * position)
{
	*normal = norm;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                   Normal finder for ring                      บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Ring::FindNorm(Vector * normal, Vector * position)
{
	*normal = norm;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                 Normal finder for quadratic                   บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Quadratic::FindNorm(Vector * normal, Vector * position)
{
	Vector newpos,newdir;
	
	newpos = *position - loc;
	if ((vect1.x == 0) && (vect1.y == 1) && (vect1.z == 0))
	{
		*normal = vect2 * newpos;
		*normal = ~ *normal;
	}
	else
	{
		newpos = newpos.Rotate(cos1, sin1, cos2, sin2);
		newdir = vect2 * newpos;
		*normal = newdir.Rev_Rotate(cos1, sin1, cos2, sin2);
	}
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ             Find Bounding Box for Generic Object              บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Object::FindBbox(Vector * v1, Vector * v2)
{}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                Find Bounding Box for Sphere                   บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Sphere::FindBbox(Vector * v1, Vector * v2)
{
	v1->x=loc.x-vect1.x;
  	v2->x=loc.x+vect1.x;
  	v1->y=loc.y-vect1.x;
	v2->y=loc.y+vect1.x;
	v1->z=loc.z-vect1.x;
	v2->z=loc.z+vect1.x;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ             Find Bounding Box for Parallelogram               บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Parallelogram::FindBbox(Vector * v1, Vector * v2)
{
	Vector point2, point3, point4;

	point2 = loc + vect1;
	point3 = loc + vect2;
	point4 = point3 + vect1;
	v1->x=MIN(point2.x,point3.x);
	v1->x=MIN(v1->x,point4.x);
	v1->x=MIN(v1->x,loc.x);
	v1->y=MIN(point2.y,point3.y);
	v1->y=MIN(v1->y,point4.y);
	v1->y=MIN(v1->y,loc.y);
	v1->z=MIN(point2.z,point3.z);
	v1->z=MIN(v1->z,point4.z);
	v1->z=MIN(v1->z,loc.z);
	v2->x=MAX(point2.x,point3.x);
	v2->x=MAX(v2->x,point4.x);
	v2->x=MAX(v2->x,loc.x);
	v2->y=MAX(point2.y,point3.y);
	v2->y=MAX(v2->y,point4.y);
	v2->y=MAX(v2->y,loc.y);
	v2->z=MAX(point2.z,point3.z);
	v2->z=MAX(v2->z,point4.z);
	v2->z=MAX(v2->z,loc.z);
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                Find Bounding Box for Triangle                 บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Triangle::FindBbox(Vector * v1, Vector * v2)
{
	Vector point2, point3;

	point2 = loc + vect1;
	point3 = loc + vect2;
	v1->x=MIN(point2.x,point3.x);
	v1->x=MIN(v1->x,loc.x);
	v1->y=MIN(point2.y,point3.y);
	v1->y=MIN(v1->y,loc.y);
	v1->z=MIN(point2.z,point3.z);
	v1->z=MIN(v1->z,loc.z);
	v2->x=MAX(point2.x,point3.x);
	v2->x=MAX(v2->x,loc.x);
	v2->y=MAX(point2.y,point3.y);
	v2->y=MAX(v2->y,loc.y);
	v2->z=MAX(point2.z,point3.z);
	v2->z=MAX(v2->z,loc.z);
}
  
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ              Find Bounding Box for Bounding Box               บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void BBox::FindBbox(Vector * v1, Vector * v2)
{
	*v1 = lower;
	*v2 = upper;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                 Find Bounding Box for Ring                    บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/
  
void Ring::FindBbox(Vector * v1, Vector * v2)
{
	v1->x = loc.x-vect3.y;
	v2->x = loc.x+vect3.y;
	v1->y = loc.y-vect3.y;
	v2->y = loc.y+vect3.y;
	v1->z = loc.z-vect3.y;
	v2->z = loc.z+vect3.y;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ               Find Bounding Box for Quadratic                 บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Quadratic::FindBbox(Vector * v1, Vector * v2)
{
	*v1 = lower;
	*v2 = upper;
	*v1 = *v1 + loc;
	*v2 = *v2 + loc;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ          Change scale of user defined generic Object          บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Object::Scale_Instance(Vector * mult,int fflag)
{
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ               Change scale of user defined Sphere             บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Sphere::Scale_Instance(Vector * mult, int fflag)
{
	float size;

	size = Min(mult->x,mult->y,mult->z);
	loc = loc * *mult;
	vect1.x *= size;
	child->Scale_Instance(mult,FALSE);
  	if (!fflag)
    	nextobj->Scale_Instance(mult,FALSE);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ           Change scale of user defined Parallelogram          บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/


void Parallelogram::Scale_Instance(Vector * mult, int fflag)
{

	loc = loc * *mult;
	vect1 = vect1 * *mult;
	vect2 = vect2 * *mult;
	child->Scale_Instance(mult,FALSE);
  	if (!fflag)
    	nextobj->Scale_Instance(mult,FALSE);
}	

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ               Change scale of user defined Ring               บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Ring::Scale_Instance(Vector * mult, int fflag)
{
	float size;

	size = Min(mult->x,mult->y,mult->z);
	loc = loc * *mult;
	vect1 = vect1 * *mult;
	vect2 = vect2 * *mult;
	vect3.x *= size;
	vect3.y *= size;
	child->Scale_Instance(mult,FALSE);
  	if (!fflag)
    	nextobj->Scale_Instance(mult,FALSE);
}	

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ             Change scale of user defined Triangle             บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Triangle::Scale_Instance(Vector * mult, int fflag)
{

	loc = loc * *mult;
	vect1 = vect1 * *mult;
	vect2 = vect2 * *mult;
	child->Scale_Instance(mult,FALSE);
  	if (!fflag)
    	nextobj->Scale_Instance(mult,FALSE);
}	

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ             Change scale of user defined Quadratic            บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Quadratic::Scale_Instance(Vector * mult, int fflag)
{
	float size;

	upper = upper * *mult;
	lower = lower * *mult;
	loc = loc * *mult;
	child->Scale_Instance(mult,FALSE);
  	if (!fflag)
    	nextobj->Scale_Instance(mult,FALSE);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ        Determine position variables for generic object        บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Object :: Position(float * pos1, float *pos2, Vector * location)
{
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ              Determine position variables for sphere          บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/  

void Sphere :: Position(float * pos1, float *pos2, Vector * location)

{
	Vector delta;

    delta = * location - loc;
    *pos1 = atan2(delta.x,delta.y) * vect1.x;
    *pos2 = atan2(sqrt((delta.x * delta.x) + (delta.y * delta.y)), delta.z) * 
		vect1.x;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ             Determine position variables for triangle         บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Triangle :: Position(float * pos1, float *pos2, Vector * location)
{
	Vector delta;
	float length1, length2;

    delta = * location - loc;
    length1 = sqrt(vect1 % vect1);
    length2 = sqrt(vect2 % vect2);
    *pos1 = (delta % vect1)/length1;
    *pos2 = (delta % vect2)/length2;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ          Determine position variables for parallelogram       บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Parallelogram :: Position(float * pos1, float *pos2, Vector * location)
{
	Vector delta;
	float length1, length2;

    delta = * location - loc;
    length1 = sqrt(vect1 % vect1);
    length2 = sqrt(vect2 % vect2);
    *pos1 = (delta % vect1)/length1;
    *pos2 = (delta % vect2)/length2;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ              Determine position variables for ring            บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Ring :: Position(float * pos1, float *pos2, Vector * location)
{
	Vector delta;
	float length1, length2;

    delta = * location - loc;
    length1 = sqrt(vect1 % vect1);
    length2 = sqrt(vect2 % vect2);
    *pos1 = (delta % vect1)/length1;
    *pos2 = (delta % vect2)/length2;
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ           Determine position variables for quadratic          บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Quadratic :: Position(float * pos1, float *pos2, Vector * location)
{
	Vector newpos;

	newpos = *location - loc;
	*pos1 = newpos.x;      
	*pos2 = newpos.y;     
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                   Generic intersection test                   บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

int Object :: CollisionTest(Line * line, float *t)
{return(0);}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ           Test for intersection of line with sphere           บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

int Sphere :: CollisionTest(Line * line, float *t)
{
	float a,b,c,d,t1;
  	Vector temp;

	temp = loc - line->loc;
	c = (temp % temp) - n1;
  	b = -2*(line->dir % temp);                     
  	a = line->dir % line->dir;                     
  	d = b*b - 4.0*a*c;
  	if (d<=0) 
		return(FALSE);                       
  	d=sqrt(d); *t=(-b+d)/(a+a);
   	t1=(-b-d)/(a+a);
	if (*t<=SMALL && t1 <=SMALL)
		return(FALSE);
	if (t1 > *t)
	{
		if (*t < SMALL)
			*t = t1;
	}
	else
		if (t1 > SMALL)
			*t = t1;
	return(TRUE);
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ          Test for intersection of line with triangle          บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

  int Triangle :: CollisionTest(Line * line, float *t)
{
	Vector delta, location;
  	float dot, pos1, pos2,gu[3],gv[3];
	int i,j,crossing_no;

  	dot = norm % line->dir;
  	if (fabs(dot)<SMALL) 
		return(FALSE);
  	pos1 = n1;
  	pos2 = norm % line->loc;
  	*t=(pos1-pos2)/dot;
  	location = line->loc + (line->dir * *t);
	delta = location - loc;
	if ((fabs(norm.x) > fabs(norm.y)) && (fabs(norm.x) > fabs(norm.z)))
	{
		gu[0] = - delta.y;
		gv[0] = - delta.z;
		gu[1] = vect1.y - delta.y;
		gv[1] = vect1.z - delta.z;
		gu[2] = vect2.y - delta.y;
		gv[2] = vect2.z - delta.z;
	}
	else
	{
		if (fabs(norm.y) > fabs(norm.z))
		{
			gu[0] = - delta.x;
			gv[0] = - delta.z;
			gu[1] = vect1.x - delta.x;
			gv[1] = vect1.z - delta.z;
			gu[2] = vect2.x - delta.x;
			gv[2] = vect2.z - delta.z;
		}
		else
		{
			gu[0] = - delta.x;
			gv[0] = - delta.y;
			gu[1] = vect1.x - delta.x;
			gv[1] = vect1.y - delta.y;
			gu[2] = vect2.x - delta.x;
			gv[2] = vect2.y - delta.y;
		}
	}

	crossing_no = 0;
	for (i=0; i<3; i++)
	{
		j = (i + 1) % 3;
 		if (((gv[i] < 0) && (gv[j] >= 0)) || ((gv[j] < 0) && (gv[i] >= 0)))
		{
			if ((gu[i]>=0) && (gu[j] >= 0))
				crossing_no++;
			else
			{
				if((gu[i]>=0) || (gu[j] >= 0))
				{
					if (gu[i] - gv[i] * (gu[j] - gu[i]) / (gv[j] - gv[i])
						> 0)
						crossing_no++;
				}
		  	}
		}
	}
	if ((crossing_no % 2) == 0)
		return(FALSE);
	return(TRUE);
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ       Test for intersection of line with parallelogram        บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/
  
int Parallelogram :: CollisionTest(Line * line, float *t)
{
	Vector delta, location;
	float dot,pos1,pos2,gu[4],gv[4];
	int i,j,crossing_no;

  	dot = norm % line->dir;
  	if (fabs(dot)<SMALL) 
		return(FALSE);
  	pos1 = n1;
  	pos2 = norm % line->loc;
  	*t=(pos1-pos2)/dot;
  	location = line->loc + (line->dir * *t);
  	delta = location - loc;
	if ((fabs(norm.x) > fabs(norm.y)) && (fabs(norm.x) > fabs(norm.z)))
	{
		gu[0] = - delta.y;
		gv[0] = - delta.z;
		gu[1] = vect1.y - delta.y;
		gv[1] = vect1.z - delta.z;
		gu[2] = vect2.y + vect1.y - delta.y;
		gv[2] = vect2.z + vect1.z - delta.z;
		gu[3] = vect2.y - delta.y;
		gv[3] = vect2.z - delta.z;
	}
	else
	{
		if (fabs(norm.y) >= fabs(norm.z))
		{
			gu[0] = - delta.x;
			gv[0] = - delta.z;
			gu[1] = vect1.x - delta.x;
			gv[1] = vect1.z - delta.z;
			gu[2] = vect2.x + vect1.x - delta.x;
			gv[2] = vect2.z + vect1.z - delta.z;
			gu[3] = vect2.x - delta.x;
			gv[3] = vect2.z - delta.z;
		}
		else
		{
			gu[0] = - delta.x;
			gv[0] = - delta.y;
			gu[1] = vect1.x - delta.x;
			gv[1] = vect1.y - delta.y;
			gu[2] = vect2.x + vect1.x - delta.x;
			gv[2] = vect2.y + vect1.y - delta.y;
			gu[3] = vect2.x - delta.x;
			gv[3] = vect2.y - delta.y;	
		}
	}
	crossing_no = 0;
	for (i=0; i<4; i++)
	{
		j = (i + 1) % 4;
 		if (((gv[i] < 0) && (gv[j] >= 0)) || ((gv[j] < 0) && (gv[i] >= 0)))
		{
			if ((gu[i]>=0) && (gu[j] >= 0))
				crossing_no++;
			else
			{
				if((gu[i]>=0) || (gu[j] >= 0))
				{
					if (gu[i] - gv[i] * (gu[j] - gu[i]) / (gv[j] - gv[i])
						> 0)
						crossing_no++;
				}
		  	}
		}
	}
	if ((crossing_no % 2) == 0)
		return(FALSE);
	return(TRUE);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ            Test for intersection of line with ring            บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/
  
int Ring :: CollisionTest(Line * line, float *t)
{
  	Vector delta, location;
  	float dot, rad, pos1, pos2;
  	dot  = norm % line->dir;
  	if (fabs(dot)<SMALL) 
		return(FALSE);
  	pos1 = n1;
  	pos2 = norm % line->loc;
  	*t=(pos1-pos2)/dot;
  	location = line->loc + (line->dir * *t);
	delta = location - loc;
	rad = sqrt(delta % delta);
 	if (rad<(vect3.x) || rad>(vect3.y))
    	return(FALSE);
 	return(TRUE);
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ          Test for intersection of line with quadratic         บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/
  
int Quadratic :: CollisionTest(Line * line, float *t)
{
	float a,b,c,d, t1;
  	Vector location, loc1, tempdir;
  	Line newline;

  	newline.loc = line->loc - loc;
	if ((vect1.x == 0) && (vect1.y == 1) && (vect1.z == 0))
		newline.dir = line->dir;
	else
	{
		newline.dir = line->dir.Rotate(cos1, sin1, cos2, sin2);
		newline.loc = newline.loc.Rotate(cos1, sin1, cos2, sin2);
	} 
	if (yterm == 0)
	{
	 	c = -(cterm) + vect2.x * newline.loc.x * newline.loc.x +
			vect2.y * newline.loc.y * newline.loc.y +
			vect2.z * newline.loc.z * newline.loc.z;
	  	b = 2*(vect2.x * newline.loc.x * newline.dir.x +
 			vect2.y * newline.loc.y * newline.dir.y +
        	vect2.z * newline.loc.z * newline.dir.z);
		a = vect2.x * newline.dir.x * newline.dir.x +
    	  	vect2.y * newline.dir.y * newline.dir.y +
      		vect2.z * newline.dir.z * newline.dir.z;
	}
  	else
	{
	 	c = -(cterm) + vect2.x * newline.loc.x * newline.loc.x -
			yterm * newline.loc.y +
			vect2.z * newline.loc.z * newline.loc.z;
	  	b = 2*(vect2.x * newline.loc.x * newline.dir.x -
 			yterm * newline.dir.y +
        	vect2.z * newline.loc.z * newline.dir.z);
		a = vect2.x * newline.dir.x * newline.dir.x +
    	  	vect2.z * newline.dir.z * newline.dir.z;
	}
	d = b * b - 4.0*a*c;
  	if (d<0) 
		return(FALSE);                           
  	d = sqrt(d); 
	*t = (-b+d)/(a+a);
    t1 = (-b-d)/(a+a);
  	location = newline.loc + (newline.dir * *t);
	loc1 = newline.loc + (newline.dir * t1);
  	if ((location.x < lower.x) ||                
      	(location.x > upper.x) ||
      	(location.y < lower.y) ||
      	(location.y > upper.y) ||
      	(location.z < lower.z) ||
      	(location.z > upper.z))    
		*t = -1;
  	if ((loc1.x < lower.x) ||                  
      	(loc1.x > upper.x) ||
      	(loc1.y < lower.y) ||
      	(loc1.y > upper.y) ||
      	(loc1.z < lower.z) ||
      	(loc1.z > upper.z))   
		t1 = -1;
	if (*t<=SMALL && t1 <=SMALL)
		return(FALSE);
	if (t1 > *t)
	{
		if (*t < SMALL)
			*t = t1;
	}
	else
		if (t1 > SMALL)
			*t = t1;
	return(TRUE);
}
  
/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ        Test for intersection of line with bounding box        บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

int BBox :: CollisionTest(Line * line, float *t)
{
  	float tminx, tmaxx, tminy, tmaxy,
  	tminz, tmaxz, tmin, tmax, t1,t2;

	*t=10;
  	if (fabs(line->dir.x) < SMALL) 
	{
		if ((lower.x < line->loc.x) &&
        	(upper.x > line->loc.x)) 
		{
			tminx = -3e30; 
			tmaxx = 3e30;
        } 
		else 
			return(FALSE);
  	} 
	else 
	{
    	t1 = (lower.x-line->loc.x)/line->dir.x;
    	t2 = (upper.x-line->loc.x)/line->dir.x;
	    tminx = MIN(t1,t2);
    	tmaxx = MAX(t1,t2);
	    if (tmaxx<0) 
			return(FALSE);
  	}
  	if (fabs(line->dir.y) < SMALL) 
	{
    	if ((lower.y < line->loc.y) &&
        	(upper.y > line->loc.y)) 
		{
        	tminy = -3e30; 
			tmaxy=3e30;
        } 
		else 
			return(FALSE);
  	} 
	else 
	{
    	t1 = (lower.y-line->loc.y)/line->dir.y;
	    t2 = (upper.y-line->loc.y)/line->dir.y;
    	tminy = MIN(t1,t2);
    	tmaxy = MAX(t1,t2);
    	if (tmaxy<0) 
			return(FALSE);
  	}
  	if (fabs(line->dir.z) < SMALL) 
	{
    	if ((lower.z < line->loc.z) &&
        	(upper.z > line->loc.z)) 
		{
        	tminz = -3e30; 
			tmaxz=3e30;
        } 
		else 
			return(FALSE);
  	} 
	else 
	{
    	t1 = (lower.z-line->loc.z)/line->dir.z;
    	t2 = (upper.z-line->loc.z)/line->dir.z;
    	tminz = MIN(t1,t2);
    	tmaxz = MAX(t1,t2);
    	if (tmaxz<0) 
			return(FALSE);
  	}
	tmin = Max(tminx,tminy,tminz);
  	tmax = Min(tmaxx,tmaxy,tmaxz);
  	if (tmax<tmin) 
		return(FALSE);
  	return(TRUE);
}

