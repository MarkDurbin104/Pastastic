/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ            ray.c = Functions related to ray tracing           บ
            บ                                                               บ
            บ                   By Roger T. Stevens 6-30-90                 บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include <stdlib.h>
#include <math.h>
#include <conio.h>
#include "render.hpp"

int level;

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ         Trace_Scene() = Ray tracing of entire scene           บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/
#define I asm

void cls(void)
{
I	mov ax,0xA000
I	mov es,ax
I	mov ax,0x5555
I	xor di,di
I	mov cx,32000
I	rep stosw
}
void grafix(void)
{
I	mov ax,0x13
I	int 0x10
}
void endgraf(void)
{
I   mov ax,0x0003
I   int 0x10
}
void plot(unsigned char *scr,char r,char g,char b)
{
	*scr=r;
}
void Trace_Scene()
{
	int x,y;
	unsigned char *scr=(unsigned char *)0xA0000000L;
	char red[max_pixel], green[max_pixel], blue[max_pixel];
  	Vector color;
  	Line line;
  	float xf, yf;
	grafix();
	cls();
	for (y=WORLD.first_scan; y<=WORLD.last_scan; y++) 
	{
//		cout << "Tracing line #: " << y << "\n";
		yf=((float)(CENTERY-y))/(WORLD.flength);
		for (x=0; x<XSIZE; x++) 
		{
      		xf=((float)(CENTERX-x))/(WORLD.flength);
		    line.loc = WORLD.obsloc;
    		line.dir = WORLD.obsdir;
      		line.dir = line.dir + WORLD.obsright * xf + WORLD.obsup * yf;
			level = 0;
			Trace_Ray(&line,&color,1.0);
      		WORLD.primary_traced++;
			red[x] = color.x;
			green[x] = color.y;
			blue[x] = color.z;
			plot(scr++,color.x,color.y,color.z);
		}
		if (kbhit()) {
			endgraf();
			getch();
			cout << "Tracing line #: " << y << "\n";
			exit(-1);
		}
    	Dump_Line(y,red,green,blue);
  	}
	getch();
	endgraf();
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ        Trace_Ray() = Ray traces for a line of display         บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

int Trace_Ray(Line * line,Vector * color,float multiplier)
{
	Vector new_position, new_direction, close_obj_loc, close_obj_norm;
  	float Shortest_time, divisor;
  	Object * Closest_object;
  	color_data col_data;

	*color = Vector();
	level++;
	if (level > 48)
		return(FALSE);
	if (multiplier < WORLD.threshold) 
		return(FALSE);
  	Closest_object=Intersect(WORLD.stack,line,&Shortest_time,FALSE,TRUE,NULL);
  	if (Closest_object!=NULL) 
	{
 		close_obj_loc = line->loc + (line->dir * Shortest_time);   
		Closest_object->FindNorm(&close_obj_norm,&close_obj_loc);
    	if ((close_obj_norm % line->dir) >0)
      		close_obj_norm  = -close_obj_norm;       
		Find_Color(Closest_object,Closest_object->pattern,&close_obj_loc,&col_data,
		Closest_object->xmult,Closest_object->ymult);
    	AmbientColor(color,&col_data,&close_obj_norm,&close_obj_loc);
    	DiffuseColor(color,&col_data,&close_obj_norm,&close_obj_loc,line);
    	TransparentColor(color,&col_data,&close_obj_norm,&close_obj_loc,line,multiplier);
    	ReflectColor(color,&col_data,&close_obj_norm,&close_obj_loc,line,multiplier);
    	Dither(color,&col_data);
  	} 
	else 
    	SkyColor(line,color);
	if (color->x > CNUM || color->y > CNUM || color->z > CNUM) 
	{
    	divisor = (float)Max(color->x,color->y,color->z) / (float)CNUM;
		*color = *color / divisor;
	}
  	return(Closest_object!=NULL);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ         Intersect() = Finds first object hit by ray           บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object * Intersect(Object * CurrObj,Line * line,float *Shortest_time,
	short shadow_flag, short init_flag,Vector * atten)
{
	static Object * Closest_object;
  	Vector loc;
  	Object * obj;
  	short collision;
  	static short stop;
  	float t;
  
	obj = CurrObj;
  	if (init_flag) 
	{
    	*Shortest_time=3e30;
    	Closest_object=NULL;
    	stop=FALSE;
  	}
  	while (obj!=NULL && !stop) 
	{
		collision = obj->CollisionTest(line,&t);
    	WORLD.intersect_tests++;
    	if (collision && (t>SMALL))
		{
			if (obj->type == BBOX)
			{
	        	WORLD.bbox_intersects++;
    	    	Intersect(obj->child,line,Shortest_time,shadow_flag,
					FALSE,atten);
      		}
			else
			{
				if(obj->remove != NULL) 
				{
					loc = line->loc + line->dir * t;
		    		if (Find_Color(obj,obj->remove,&loc,NULL, 1.0, 1.0))
			    	obj=obj->nextobj;
	        		continue;
		    	}
				WORLD.ray_intersects++;
        		if (shadow_flag && t<1) 
				{
					if ((obj->col_data->trans.x < WORLD.int_threshold) &&
              		(obj->col_data->trans.y < WORLD.int_threshold) &&
              		(obj->col_data->trans.z < WORLD.int_threshold)) 
					{
	            		Closest_object = obj;
            			return(obj);
          			} 
					else 
					{
						if (atten != NULL) 
						{
							*atten = *atten * (obj->col_data->trans * 
								obj->col_data->trans) / (float)(CNUM * CNUM);
		            	}
        			}
        		}
        		if ((!shadow_flag) && (t<*Shortest_time)) 
				{
					*Shortest_time  = t;
					Closest_object = obj;
        		}
      		} 
    	}
    	obj=obj->nextobj;
	}
	return(Closest_object);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ   DiffuseColor() = Computes specular reflections and color    บ
            บ                   emitted by object                           บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void DiffuseColor(Vector * color,color_data * col_data,Vector *
	norm,Vector * loc, Line * oline)
{
	Line  line;
	Object * CurrObj;
	Lamp * lamp;	
	float dot, distance, time, t1, t2;
	Vector reflect, attenuate;

	line.loc = *loc;
  	lamp = WORLD.lamps;
  	while (lamp!=NULL) 
	{
    	line.dir = lamp->loc - *loc;
    	attenuate = Vector(1,1,1);
   		CurrObj=Intersect(WORLD.stack,&line,&time,TRUE,TRUE,&attenuate);
      	WORLD.to_lamp++;
	    if (CurrObj==NULL) 
		{
      		distance = line.dir % line.dir;
			line.dir = ~ line.dir;
			if (col_data->diff.x>0 || col_data->diff.y>0 || col_data->diff.z>0) 
			{
        		t1 = *norm % line.dir;
	        	if (t1>0) 
				{
          			t2 = lamp->distance*t1/sqrt(distance);
	          		*color = *color + ((attenuate * col_data->diff) * t2);
    	    	}
      		}
	      	if (col_data->sreflect>0) 
			{              
				dot = line.dir % *norm;
				reflect = -line.dir + *norm * dot + *norm * dot;
		        t1 = -(reflect % oline->dir);
    		    if (t1>0.6) 
				{
          			t2 = pow(t1,col_data->sreflect)*lamp->distance/sqrt(distance);
	          		t2 *= (float)col_data->reflect/(float)CNUM;
					*color = *color + attenuate * (t2 * CNUM);
	        	}
    	  	}
	    }
    	lamp=lamp->next_lamp;
	}
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ              AmbientColor() = Add ambient color               บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void AmbientColor(Vector * color, color_data * col_data, Vector * norm,
	Vector * loc)
{
	*color = *color + col_data->amb * (col_data->diff / (float)CNUM);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ  TransparentColor() = Traces ray through transparent medium   บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void TransparentColor(Vector * color, color_data * col_data,Vector * norm,
	Vector * loc, Line * line,float inmult)
{
	Line newline;
  	Vector col1, refract, distance, displacement, attenuation;
	float glassdist,current_index, multiplier, side1;
  	int maxtrans;
	static Vector old_position;

	if ((col_data->trans.x < WORLD.int_threshold) &&
    	(col_data->trans.y < WORLD.int_threshold) &&
      	(col_data->trans.z < WORLD.int_threshold)) 
		return;
	if (line->flag) 
	{
	    current_index = col_data->index/WORLD.globindex;
	    displacement = *loc - old_position;
	    cout << "Displacement: " << displacement << "\n";
		glassdist = sqrt(displacement % displacement);
  	} 
	else 
	{
	    current_index = WORLD.globindex/col_data->index;
	    old_position = *loc;
  	}
	newline.loc = *loc;
  	side1 = *norm % (-line->dir);
	refract = -(*norm * side1) - line->dir; 	
	refract = refract * (1-current_index);
  	newline.dir = line->dir + refract;
	newline.dir = ~ newline.dir;
  	maxtrans = Max(col_data->trans.x,col_data->trans.y,col_data->trans.z);
	newline.flag = !(line->flag);
  	multiplier = inmult * (float)maxtrans/(float)CNUM;
  	Trace_Ray(&newline,&col1,multiplier);
  	WORLD.refl_trans++;
  	*color = *color + col1;
	if (line->flag) 
	{
		cout << "Density: " << col_data->density << "\n";
		cout << "glassdist: " << glassdist << "\n";
		attenuation = col_data->density * (*color * glassdist);	
		*color = *color - attenuation.min(*color);
		cout << "Attenuation: " << attenuation << "\n";
  	}
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ        ReflectColor() = Traces ray bounced off object         บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void ReflectColor(Vector * color,color_data * col_data,Vector * norm,Vector *
	loc, Line * line,float inmult)
{
	Vector col1;
  	Line newline;
  	float multiplier,dot;
  	int maxmirror;
  	
	if ((col_data->mirror.x < WORLD.int_threshold) &&
    	(col_data->mirror.y < WORLD.int_threshold) &&
      	(col_data->mirror.z < WORLD.int_threshold)) return;
	newline.loc = *loc;
	dot = -(line->dir % *norm);
	newline.dir = line->dir + *norm * dot + *norm * dot;
  	maxmirror = Max(col_data->mirror.x,col_data->mirror.y,col_data->mirror.z);
  	multiplier = inmult * (float)maxmirror/CNUM;
	Trace_Ray(&newline,&col1,multiplier);
	WORLD.refl_trans++;
	*color = *color + col1 * (col_data->mirror / (float)CNUM);  
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                SkyColor() = Computes sky color                บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void SkyColor(Line * line,Vector * color)
{
	float length, horiz, zenith;

  	length = line->dir % line->dir;
  	zenith = line->dir.y * line->dir.y / length;
	horiz  = (line->dir.x * line->dir.x + line->dir.z * line->dir.z)/
		length;
	*color = *color + WORLD.skycolor_zenith * zenith +
		WORLD.skycolor_horiz * horiz;
	Dither(color,WORLD.sky_dither);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ             Dither() = Color dithering functions              บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#define MINCOL 10

void Dither(Vector * color,float dither)
{
	float r,g,b;
	
	if (dither==0) return;
	if (dither>0) 
	{
    	r=((float)rand()/16383) - 1; 
    	g=((float)rand()/16383) - 1; 
    	b=((float)rand()/16383) - 1; 
    	if (color->x<MINCOL) 
			r=fabs(r);
    	if (color->y<MINCOL) 
			g=fabs(g);
    	if (color->z<MINCOL) 
			b=fabs(b);
    	*color= *color + Vector(r*dither,g*dither,b*dither);
	}
}

void Dither(Vector * color,color_data * col_data)
{
	float r,g,b;

  	if (col_data->dither==0) 
		return;
	if (col_data->dither>0) 
	{
    	r=((float)rand()/16383) - 1; 
    	g=((float)rand()/16383) - 1; 
    	b=((float)rand()/16383) - 1; 
    	if (color->x<MINCOL) 
			r=fabs(r);
    	if (color->y<MINCOL) 
			g=fabs(g);
	    if (color->z<MINCOL) 
			b=fabs(b);
    	*color= *color + Vector(r*col_data->dither,g*col_data->dither,
			b*col_data->dither);
	} 
	else 
	{
    	r=((float)rand()/16383) - 1; 
    	if ((color->x+color->y+color->z)>(3*MINCOL)) 
			r=fabs(r);
    	*color= *color + Vector(r*col_data->dither,r*col_data->dither,
			r*col_data->dither);
	}
}



/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ       Dump_line() = Sends a line of data to disk file         บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Dump_Line(int lineno, char *red, char *green, char *blue)
{
	fwrite(&lineno,sizeof(int),1,WORLD.filept);
    fwrite(red,sizeof(char),XSIZE,WORLD.filept);
    fwrite(green,sizeof(char),XSIZE,WORLD.filept);
    fwrite(blue,sizeof(char),XSIZE,WORLD.filept);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ     Find_Color() = Finds the color of a point on an object    บ
		    บ                    surface, returning either pattern or       บ
            บ                    default color information.                 บ
            บ                                                               บ
            บ                  By Roger T. Stevens - 2-3-90                 บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

int Find_Color(Object * obj, Pattern *pattern, Vector * location, 
	color_data * c_data,float x_mult, float y_mult)
{
	Pattern *patt;
	float x,y, pos1, pos2;
	int modx, mody;
	float radius_sq, x_cir, y_cir, x1, x2, y1, y2;
  	Pattern *line_segment;
  	int number = 0;

  	if (pattern==NULL) 
	{
	    *c_data = *(obj->col_data);
    	return(FALSE);
  	}
	obj->Position(&pos1, &pos2, location);
  	pos1 /= x_mult;                            
  	pos2 /= y_mult;                            
  	modx = (int)(pos1 / (pattern->xsize));
  	if (pos1<0) modx--;
  	mody = (int)(pos2 / (pattern->ysize));
  	if (pos2<0) mody--;
  	x = pos1 - ((float)modx * pattern->xsize);
  	y = pos2 - ((float)mody * pattern->ysize);
  	patt = pattern->child;
  	while (patt!=NULL) 
	{
    	WORLD.pattern_matches++;
		switch(patt->type)
		{
			case RECTANGLE:
					 	if ((x>patt->startx) && (x<patt->endx) &&
							(y>patt->starty) && (y<patt->endy))
						{
				      		*c_data = patt->col_data;
							return(TRUE);
						}
						break;
			case CIRCLE:
						x_cir = x - patt->radius;
						y_cir = y - patt->radius;
						radius_sq = x_cir*x_cir + y_cir*y_cir;
						if (radius_sq <= (patt->radius*patt->radius))
						{
				      		*c_data = patt->col_data;
							return(TRUE);
						}
						break;
			case POLYGON:
						while (line_segment->link != NULL)
						{
							x1 = line_segment->startx - x;
							x2 = line_segment->link->startx - x;
							y1 = line_segment->starty - y;
							y2 = line_segment->link->starty - y;
							if ((x1<=0) && (x2<=0))
						{
						if ((y1==0) && (y2==0))
							number++;
						else
						{
							if (y1*y2 <= 0)
								if (x1 - (y1*(x2-x1)/(y2-y1))> 0)
							    	number++;
						}
					}
					line_segment = line_segment->link;
				}
				if ((number % 2) == 0)
					break;
				else
				{
				    *c_data = patt->col_data;
					return(TRUE);
				}
		}
		patt = patt->sibling;
  	}
	*c_data = *(obj->col_data);
	return(FALSE);
}



