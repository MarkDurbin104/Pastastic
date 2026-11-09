/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ       input.cpp = Functions to read data from disk file       บ
    บ                                                               บ
    บ                By Roger T. Stevens - 6/30/90                  บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <conio.h>
#include "render.hpp"

char string_types[128][32] = {"PATT_HEADER","LINE","SPHERE","PARALLELOGRAM",
	"TRIANGLE","LAMP","OBSERVER","GROUND","SKY","BBOX","RING","QUADRATIC",
	"BEGIN_BBOX","END_BBOX","BEGIN_INSTANCES","END_INSTANCES","AMB","DIFF",
	"MIRROR","TRANS","DENSITY","INDEX","DITHER","SREFLECT","REFLECT","LOC",
	"RADIUS","PATTERN","REMOVE","XMULT","YMULT","NAME","DIST","LOOKAT","V1",
	"V2","ZENITH","HORIZ","RAD_1","RAD_2","A","B","C","D","E","XMAX","YMAX",
	"ZMAX","XMIN","YMIN","ZMIN","DIR","FOC_LENGTH","FIRST_SCAN",
	"DEFAULT","FILE_NAME","LAST_SCAN","XRES","YRES","X_SIZE","Y_SIZE","START_X",
	"START_Y","END_X","END_Y",")","NO_SHADOW","NO_LAMP","THRESHOLD","UP",
	"INSTANCE_OF","SCALE","RECTANGLE","CIRCLE","POLYGON","COLOR","POINT",
	"CONE","HEIGHT","FRACTAL","DIMENSION","SCALAR",NULL};

char string_buf[32];
char name[32];
FILE *fget;
	
/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ       LoadWorld() = Loads the World with data from file       บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

extern int linenumber;
extern char file_in[32];

int LoadWorld()                    
{
	fget = fopen(file_in,"rb");
	WORLD.stack=get_data();
	fclose(fget);
  	return(TRUE);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ    get_data() = Gets data from file and places it in World    บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object * get_data() 
{
  	Object * queue, * temp;
  	BBox * newobj;
	Vector loc,rad,d,v3, upper, lower;
  	int found,type;
	name[0] = NULL; queue=NULL;
  	loc = Vector();
	rad = Vector();
	d = Vector();
	v3 = Vector();
	upper = Vector();
	lower = Vector();
	if (feof(fget)) return(NULL);
	while (!feof(fget)) 
	{
    	type = get_string(string_buf); 
		if (strcmp(string_buf,NULL)==0)
			return(queue);
		found = FALSE;
		if (GetAttrib(type,string_buf))
		{
      		found = TRUE;
			if (name[0] == NULL)
				continue;
			type = get_string(string_buf);
			if (type != BEGIN_BBOX)
			{
				cout << "Error: Name must be followed by 'BEGIN_BBOX'\n";
				exit(1);
			}
		}
		switch(type)
		{
    		case BEGIN_INSTANCES: 
	      		found = TRUE;
				WORLD.instances = get_data();
    			break;
			case END_INSTANCES: 
	      		found = TRUE;
    	  		return(queue);
				break;
			case END_BBOX:
	      		found = TRUE;
    	  		return(queue);
				break;    	
			case BEGIN_BBOX:
	       		newobj = new BBox;
				strcpy(newobj->name,name); 
				newobj->type = BBOX;
				newobj->child = get_data();
       			newobj->nextobj = queue;
       			queue = newobj;
       			found = TRUE;
				break;
    	}
		if (type == FRACTAL)
		{
			if ((temp=Get_Object(type,queue))!=NULL) 
			{
      			found = TRUE;
    	  		queue = temp;
    		}
		}
		else
		{
			if ((temp=Get_Object(type,queue))!=NULL) 
			{
      			found = TRUE;
	      		temp->nextobj=queue;
    	  		queue = temp;
    		}
		}
    	if (!found && !feof(fget)) 
		{
			cout << "Syntax error in reading input data: " << string_buf 
				<< "\n";
			exit(1);
		}
  	}
  	return(queue);
}


/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ       get_string() = Reads a string of data from file         บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

int get_string(char string_buf[])
{
	char ch;
	int flag = 0,i,result,test;

	string_buf[0] = NULL;
	result = last_no;
	while (!feof(fget))
	{
		ch = toupper(fgetc(fget));
		if (flag == 0)
		{	
			if ((isalnum(ch)) || (ch == '.') || (ch == '-') || (ch == ')'))
			{
				string_buf[0] = ch;
				break;
			}
			else
			{
				if (ch == '{')
					flag = 1;
			}
		}
		else
			if (ch == '}')
				flag = 0;
	}
	for (i=1; i<32; i++)
	{
		if (ch == ')')
		{
			string_buf[1] = NULL;
			break;
		}
		ch = toupper(fgetc(fget));
		if ((isalnum(ch)) || (ch == '_') || (ch == '.'))
			string_buf[i] = ch;
		else
		{
			string_buf[i] = NULL;
			break;
		}
	}
	for (i=0; i<last_no; i++)
	{
		if (strcmp(string_buf,string_types[i]) == 0)
		{
			result = i;
			break;
		}	
	}
      cout << "String buffer contains: " << string_buf << " which is type "
		<< result << "\n";

	return(result);
}


/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ   Get_Attrib() = Gets attribute other than object from file   บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

int GetAttrib(int Type,char string_buf[])
{
		int i,type=0,no_param=0,found=TRUE;
		Vector loc,look;
		float radius, distance;
		Lamp * lamps;

		switch(Type)
		{
			case SKY:
				found = TRUE;
				while (type != PAREN && !feof(fget)) 
				{
    				type = get_string(string_buf);
					switch(type)
					{
						case ZENITH:
							WORLD.skycolor_zenith.get_vector();
							WORLD.skycolor_zenith = WORLD.skycolor_zenith
								* (float)CNUM;
							break;
						case HORIZ:
							WORLD.skycolor_horiz.get_vector();
							WORLD.skycolor_horiz = WORLD.skycolor_horiz
								* (float)CNUM;
							break;
						case DITHER:
						    get_string(string_buf);
							WORLD.sky_dither = fabs(atof(string_buf));
							break;
						case PAREN:
							break;
						default:
							found = FALSE;
					}
				}
				break;
			case COLOR:
			  	while (type != PAREN && !feof(fget)) 
				{
			    	type = get_string(string_buf);
				    found = get_color_data(type,&def.col_data);
					if (type == PAREN)
					{
						found = TRUE;
						break;
					}
			    	if (!found) 
					{
						cout << "Undefined parameter " << string_buf << 
						" while loading color data in 'input.cpp'";
						exit(1);
					}
				}
				break;
			case FOC_LENGTH:
				get_string(string_buf);
				WORLD.flength = fabs(atof(string_buf));
				WORLD.flength *= 5;
				break;
			case FILE_NAME:
				get_string(string_buf);
				strcpy(WORLD.outfile,string_buf);
				break;
			case LAMP:
			  	distance = 150;
			  	while (type != PAREN && !feof(fget)) 
				{
			    	type = get_string(string_buf);
					found = TRUE;
					switch(type)
					{
						case LOC:
							loc.get_vector();
			    		  	no_param |= 1;
							break;
						case RADIUS:
							get_string(string_buf);	
	    					radius = fabs(atof(string_buf));
							break;
						case DIST:
							get_string(string_buf);	
	    					distance = fabs(atof(string_buf));
							break;
						case PAREN:
							break;
						default:
							 found = FALSE;
					}
			    	if (!found) 
					{
						cout << "Undefined parameter " << string_buf << 
							" while loading lamp in 'input.cpp'";
						exit(1);
					}
			  	}
			  	if (no_param < 1)
				{
					cout << "Too few parameters for lamp in 'input.cpp'";
					exit(1);
				}
				lamps = new Lamp;
				lamps->loc = loc;
				lamps->radius = radius;
				lamps->distance = distance;
				lamps->next_lamp = WORLD.lamps;
				WORLD.lamps = lamps;
				WORLD.lampcount++;
				break;
			case OBSERVER:
				look = Vector(200,50,0);
				found = TRUE;	
			  	while (type != PAREN && !feof(fget)) 
				{
			    	type = get_string(string_buf);
					switch(type)
					{
						case LOC:
							WORLD.obsloc.get_vector();
							no_param |= 1;
							break;
						case LOOKAT:
							look.get_vector();
			      			no_param |= 2;
							break;
						case UP:
							WORLD.obsup.get_vector();
							break;
						case PAREN:
							break;
						default:
							found = FALSE;
					}
					if (!found) 
					{
						cout << "Undefined parameter " << string_buf << 
							" while loading observer in 'input.cpp'";
						exit(1);
					}
  				}
				WORLD.obsdir = look - WORLD.obsloc;
				WORLD.obsdir = ~WORLD.obsdir;	
				WORLD.obsright = WORLD.obsup ^ WORLD.obsdir;
				WORLD.obsup = WORLD.obsdir ^ WORLD.obsright;
				WORLD.obsup = ~WORLD.obsup;
				WORLD.obsright = ~WORLD.obsright;	
			  	if (no_param != 3)
				{
					cout << "Too few parameters for observer in 'input.cpp'";
					exit(1);
				}
				break;
			case PAttern:
				GetPattern();
				break;
			case XRES:
				get_string(string_buf);
				XSIZE = fabs(atof(string_buf));
				CENTERX = XSIZE / 2;
				XSIZE4 = XSIZE / 4;
				break;
			case YRES:
				get_string(string_buf);
				YSIZE = fabs(atof(string_buf));
				WORLD.last_scan = YSIZE - 1;
				CENTERY = YSIZE / 2;
				break;
			case NAME:
				get_string(name);
				break;
			default:
				found = FALSE;
	}
	return(found);
}		



/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ    get_color_data = Gets the color information from a file    บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

int get_color_data(int type, color_data * col_data)
{
	int found = TRUE;
	char string_buf[32];
	switch(type)
	{
		case AMB:
				col_data->amb.get_vector();
				col_data->amb = col_data->amb * (float)CNUM;
				break;
		case DIFF:
				col_data->diff.get_vector();
				col_data->diff = (col_data->diff) * (float)CNUM;
				break;
  		case MIRROR:
				col_data->mirror.get_vector();
				col_data->mirror = col_data->mirror * (float)CNUM;
  				break;
		case TRANS:
				col_data->trans.get_vector();
				col_data->trans = col_data->trans * (float)CNUM;
				break;
		case DENSITY:
				col_data->density.get_vector();
				col_data->density = col_data->density * (float)CNUM;
				break;
		case INDEX:
                get_string(string_buf);
			    col_data->index = fabs(atof(string_buf));
  				break;
		case DITHER:
			    get_string(string_buf);
				col_data->dither = fabs(atof(string_buf));
				break;
		case SREFLECT:
			    get_string(string_buf);
				col_data->sreflect = fabs(atof(string_buf));
				break;
		case REFLECT:
			    get_string(string_buf);
				col_data->reflect = atof(string_buf)*CNUM;
				break;
		default:
				found = FALSE;
	}
  	return(found);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ GetSphere()=Load a sphere from file and return pointer to it  บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object * GetSphere()
{
  	Sphere * newobj;
  	int type=0,no_param = 0, found;
	float temp;

	newobj = new Sphere;
	newobj->col_data = new color_data;
	*newobj->col_data = def.col_data;
  	while (type != PAREN && !feof(fget)) 
	{
    	type = get_string(string_buf);
	    found = get_color_data(type,newobj->col_data);
		if (found == TRUE)
			continue;
		found = TRUE;
		switch(type)
		{
			case LOC:
				newobj->loc.get_vector();
      			no_param |= 1; 
				break;
			case RADIUS:
				get_string(string_buf);
				temp = fabs(atof(string_buf));
      			newobj->vect1 = Vector(temp,0,0);
				no_param |= 2;
				break;
			case PAttern:
				newobj->pattern=Attach_Pattern();
	   			break;
			case REMOVE:
				newobj->remove=Attach_Pattern();
				break;
			case XMULT:
				get_string(string_buf);
				newobj->xmult = fabs(atof(string_buf));
				break;
			case YMULT:
				get_string(string_buf);
				newobj->ymult = fabs(atof(string_buf));
				break;
			case NAME:
   				get_string(newobj->name);
				break;
			case PAREN:
				break;
			default:
				found = FALSE;
		 }
    	if (!found) 
		{
			cout << "Undefined parameter " << string_buf << 
				" while loading sphere in 'input.cpp'";
			exit(1);
		}
  	}
  	if (no_param != 3)
		{
			cout << "Too few parameters for sphere in 'input.cpp'";
			exit(1);
		}
	newobj->n1 = newobj->vect1.x * newobj->vect1.x;
  	WORLD.objcount++;
  	return(newobj);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ      GetTriangle() = Load a triangle from file and return     บ
    บ                     pointer to it                             บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object * GetTriangle()
{
  	Triangle * newobj;
  	int type=0,no_param = 0, found;
	float temp;

	newobj = new Triangle;
	newobj->col_data = new color_data;
	*newobj->col_data = def.col_data;
  	while (type != PAREN && !feof(fget)) 
	{
    	type = get_string(string_buf);
	    found = get_color_data(type,newobj->col_data);
		if (found == TRUE)
			continue;
		found = TRUE;
		switch(type)
		{
			case LOC:
				newobj->loc.get_vector();
      			no_param |= 1; 
				break;
			case V1:
				newobj->vect1.get_vector();
      			no_param |= 2; 
				break;
    		case V2:
				newobj->vect2.get_vector();
      			no_param |= 4; 
	    		break;
			case PAttern:
				newobj->pattern=Attach_Pattern();
	   			break;
			case REMOVE:
				newobj->remove=Attach_Pattern();
				break;
			case XMULT:
				get_string(string_buf);
				newobj->xmult = fabs(atof(string_buf));
				break;
			case YMULT:
				get_string(string_buf);
				newobj->ymult = fabs(atof(string_buf));
				break;
			case NAME:
   				get_string(newobj->name);
				break;
			case PAREN:
				break;
			default:
				found = FALSE;
		 }
    	if (!found) 
		{
			cout << "Undefined parameter " << string_buf << 
				" while loading triangle in 'input.cpp'";
			exit(1);
		}
  	}
  	if (no_param != 7)
		{
			cout << "Too few parameters for triangle in 'input.cpp'";
			exit(1);
		}
	newobj->norm = newobj->vect1 ^ newobj->vect2;
	newobj->norm = ~ newobj->norm;
	newobj->n1 = newobj->norm % newobj->loc;
	newobj->len1 = newobj->vect1 % newobj->vect1;
	newobj->len2 = newobj->vect2 % newobj->vect2;
  	WORLD.objcount++;
  	return(newobj);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ  GetRing() = Load a ring from file and return pointer to it   บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object * GetRing()
{
  	Ring * newobj;
  	int type=0,no_param = 0, found;
	float temp;

	newobj = new Ring;
	newobj->col_data = new color_data;
	*newobj->col_data = def.col_data;
  	while (type != PAREN && !feof(fget)) 
	{
    	type = get_string(string_buf);
	    found = get_color_data(type,newobj->col_data);
		if (found == TRUE)
			continue;
		found = TRUE;
		switch(type)
		{
			case LOC:
				newobj->loc.get_vector();
      			no_param |= 1; 
				break;
			case V1:
				newobj->vect1.get_vector();
      			no_param |= 2; 
				break;
    		case V2:
				newobj->vect2.get_vector();
      			no_param |= 4; 
	    		break;
			case RAD_1:
				get_string(string_buf);
				newobj->vect3.x = fabs(atof(string_buf));
       			no_param |= 8;
				break;
			case RAD_2:
				get_string(string_buf);
				newobj->vect3.y = fabs(atof(string_buf));
       			no_param |= 16;
				break;
			case PAttern:
				newobj->pattern=Attach_Pattern();
	   			break;
			case REMOVE:
				newobj->remove=Attach_Pattern();
				break;
			case XMULT:
				get_string(string_buf);
				newobj->xmult = fabs(atof(string_buf));
				break;
			case YMULT:
				get_string(string_buf);
				newobj->ymult = fabs(atof(string_buf));
				break;
			case NAME:
   				get_string(newobj->name);
				break;
			case PAREN:
				break;
			default:
				found = FALSE;
		 }
    	if (!found) 
		{
			cout << "Undefined parameter " << string_buf << 
				" while loading ring in 'input.cpp'";
			exit(1);
		}
  	}
  	if (no_param != 31)
	{
		cout << "Too few parameters for ring in 'input.cpp'";
		exit(1);
	}
  	newobj->vect3.z = 0;
	newobj->vect1 = ~ newobj->vect1;
	newobj->vect2 = ~ newobj->vect2;
	newobj->norm = newobj->vect1 ^ newobj->vect2;
	newobj->norm = ~ newobj->norm;
	newobj->n1 = newobj->norm % newobj->loc;
	newobj->len1 = newobj->vect1 % newobj->vect1;
	newobj->len2 = newobj->vect2 % newobj->vect2;
  	WORLD.objcount++;
  	return(newobj);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ    GetParallelogram() = Load a parallelogram from file  and   บ
    บ                         return pointer to it                  บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object * GetParallelogram()
{
  	Parallelogram * newobj;
  	int type=0,no_param = 0, found;
	float temp;

	newobj = new Parallelogram;
	newobj->col_data = new color_data;
	*newobj->col_data = def.col_data;
  	while (type != PAREN && !feof(fget)) 
	{
    	type = get_string(string_buf);
	    found = get_color_data(type,newobj->col_data);
		if (found == TRUE)
			continue;
		found = TRUE;
		switch(type)
		{
			case LOC:
				newobj->loc.get_vector();
      			no_param |= 1; 
				break;
			case V1:
				newobj->vect1.get_vector();
      			no_param |= 2; 
				break;
    		case V2:
				newobj->vect2.get_vector();
      			no_param |= 4; 
	    		break;
			case PAttern:
				newobj->pattern=Attach_Pattern();
	   			break;
			case REMOVE:
				newobj->remove=Attach_Pattern();
				break;
			case XMULT:
				get_string(string_buf);
				newobj->xmult = fabs(atof(string_buf));
				break;
			case YMULT:
				get_string(string_buf);
				newobj->ymult = fabs(atof(string_buf));
				break;
			case NAME:
   				get_string(newobj->name);
				break;
			case PAREN:
				break;
			default:
				found = FALSE;
		 }
    	if (!found) 
		{
			cout << "Undefined parameter " << string_buf << 
				" while loading parallelogram in 'input.cpp'";
			exit(1);
		}
  	}
  	if (no_param != 7)
	{
		cout << "Too few parameters for parallelogram in 'input.cpp'";
		exit(1);
	}
	newobj->norm = newobj->vect1 ^ newobj->vect2;
	newobj->norm = ~ newobj->norm;
	newobj->n1 = newobj->norm % newobj->loc;
	newobj->len1 = newobj->vect1 % newobj->vect1;
	newobj->len2 = newobj->vect2 % newobj->vect2;
	WORLD.objcount++;
  	return(newobj);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ  GetCone() = Load a cone from file and return pointer to it   บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object *GetCone()
{
  	Quadratic * newobj;
  	int type=0,no_param = 0, found;
	float temp;
	Vector newdir;

	newobj = new Quadratic;
	newobj->col_data = new color_data;
	*newobj->col_data = def.col_data;
	newobj->vect1 = Vector(0,1,0);
  	while (type != PAREN && !feof(fget)) 
	{
    	type = get_string(string_buf);
	    found = get_color_data(type,newobj->col_data);
		if (found == TRUE)
			continue;
		found = TRUE;
		switch(type)
		{
			case LOC:
				newobj->loc.get_vector();
      			no_param |= 1; 
				break;
			case RADIUS:
				get_string(string_buf);
				newobj->vect2.x = atof(string_buf);
				no_param |= 2;
				break;
			case HEIGHT:
				get_string(string_buf);
				newobj->vect2.z = atof(string_buf);
				no_param |= 4;
				break;	
			case DIR:
				newobj->vect1.get_vector();
				break;
			case PAttern:
				newobj->pattern=Attach_Pattern();
	   			break;
			case REMOVE:
				newobj->remove=Attach_Pattern();
				break;
			case XMULT:
				get_string(string_buf);
				newobj->xmult = fabs(atof(string_buf));
				break;
			case YMULT:
				get_string(string_buf);
				newobj->ymult = fabs(atof(string_buf));
				break;
			case NAME:
   				get_string(newobj->name);
				break;
			case PAREN:
				break;
			default:
				found = FALSE;
		}
    	if (!found) 
		{
			cout << "Undefined parameter " << string_buf << 
				" while loading cone in 'input.cpp'";
			exit(1);
		}
  	}
  	if (no_param != 7)
	{
		cout << "Too few parameters for cone in 'input.cpp'";
		exit(1);
	}
	newobj->cterm = 0;
	newobj->yterm = 0;
	newobj->lower.x = - newobj->vect2.x;
	newobj->lower.z = - newobj->vect2.x;
	newobj->lower.y = -newobj->vect2.z;
	newobj->upper.x = newobj->vect2.x;
	newobj->upper.z = newobj->vect2.x;
	newobj->upper.y = 0;
	newobj->vect1 = ~ newobj->vect1;
	newobj->vect2.x = newobj->vect2.x * newobj->vect2.x;
	newobj->vect2.y = -newobj->vect2.x * (newobj->vect2.x);
	newobj->vect2.z = newobj->vect2.z * newobj->vect2.z;
	newobj->vect2.x = newobj->vect2.x * newobj->vect2.z;
	newobj->vect2.z = newobj->vect2.x;
	newobj->vect1 = ~ newobj->vect1;
	temp = newobj->vect1.x * newobj->vect1.x +newobj->vect1.z * newobj->vect1.z;
	if (temp == 0)
		newobj->cos1 = 1;
	else
		newobj->cos1 = newobj->vect1.z/sqrt(temp);
	newobj->sin1 = sqrt(1 - newobj->cos1 * newobj->cos1);
	newdir.x = newobj->vect1.x * newobj->cos1 +	newobj->vect1.z * 
		-newobj->sin1;
	newdir.y = newobj->vect1.y;
	newdir.z = newobj->vect1.x * newobj->sin1 +
		newobj->vect1.z * newobj->cos1;
	temp = newdir.y * newdir.y + newdir.z * newdir.z;
	if (temp == 0)
		newobj->cos2 = 1;
	else
		newobj->cos2 = newdir.y/sqrt(temp);
	newobj->sin2 = sqrt(1 - newobj->cos2 * newobj->cos2);
	WORLD.objcount++;
  	return(newobj);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ   GetQuadratic() = Load a quadratic surface from file and     บ
    บ                    return pointer to it                       บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object *GetQuadratic()
{
  	Quadratic * newobj;
  	int type=0,no_param = 0, found;
	float temp;
	Vector newdir;

	newobj = new Quadratic;
	newobj->col_data = new color_data;
	*newobj->col_data = def.col_data;
	newobj->vect1 = Vector(0,1,0);
  	while (type != PAREN && !feof(fget)) 
	{
    	type = get_string(string_buf);
	    found = get_color_data(type,newobj->col_data);
		if (found == TRUE)
			continue;
		found = TRUE;
		switch(type)
		{
			case LOC:
				newobj->loc.get_vector();
      			no_param |= 1; 
				break;
			case A:
				get_string(string_buf);
				newobj->vect2.x = atof(string_buf);
      			no_param |= 2;
				break;
			case B:
				get_string(string_buf);
				newobj->vect2.y = atof(string_buf);
      			no_param |= 4;
				break;
			case C:
				get_string(string_buf);
				newobj->vect2.z = atof(string_buf);
      			no_param |= 8;
				break;
			case D:
				get_string(string_buf);
				newobj->cterm = atof(string_buf);
      			no_param |= 16;
				break;
			case E:
				get_string(string_buf);
				newobj->yterm = atof(string_buf);
      			no_param |= 32;
				break;
			case XMIN:
				get_string(string_buf);
				newobj->lower.x = atof(string_buf);
				break;
			case XMAX:
				get_string(string_buf);
				newobj->upper.x = atof(string_buf);
				break;
			case YMIN:
				get_string(string_buf);
				newobj->lower.y = atof(string_buf);
				break;
			case YMAX:
				get_string(string_buf);
				newobj->upper.y = atof(string_buf);
				break;
			case ZMIN:
				get_string(string_buf);
				newobj->lower.z = atof(string_buf);
				break;
			case ZMAX:
				get_string(string_buf);
				newobj->upper.z = atof(string_buf);
				break;
			case DIR:
				newobj->vect1.get_vector();
				break;
			case PAttern:
				newobj->pattern=Attach_Pattern();
	   			break;
			case REMOVE:
				newobj->remove=Attach_Pattern();
				break;
			case XMULT:
				get_string(string_buf);
				newobj->xmult = fabs(atof(string_buf));
				break;
			case YMULT:
				get_string(string_buf);
				newobj->ymult = fabs(atof(string_buf));
				break;
			case NAME:
   				get_string(newobj->name);
				break;
			case PAREN:
				break;
			default:
				found = FALSE;
		}
    	if (!found) 
		{
			cout << "Undefined parameter " << string_buf << 
				" while loading quadric in 'input.cpp'";
			exit(1);
		}
  	}
  	if ((no_param != 31) && (no_param != 59))
	{
		cout << "Too few parameters for quadric in 'input.cpp'";
		exit(1);
	}
	newobj->vect1 = ~ newobj->vect1;
	temp = newobj->vect1.x * newobj->vect1.x +newobj->vect1.z * newobj->vect1.z;
	if (temp == 0)
		newobj->cos1 = 1;
	else
		newobj->cos1 = newobj->vect1.z/sqrt(temp);
	newobj->sin1 = sqrt(1 - newobj->cos1 * newobj->cos1);
	newdir.x = newobj->vect1.x * newobj->cos1 +	newobj->vect1.z * 
		-newobj->sin1;
	newdir.y = newobj->vect1.y;
	newdir.z = newobj->vect1.x * newobj->sin1 +
		newobj->vect1.z * newobj->cos1;
	temp = newdir.y * newdir.y + newdir.z * newdir.z;
	if (temp == 0)
		newobj->cos2 = 1;
	else
		newobj->cos2 = newdir.y/sqrt(temp);
	newobj->sin2 = sqrt(1 - newobj->cos2 * newobj->cos2);
	WORLD.objcount++;
	cout << "yterm: " << newobj->yterm << "\n";
  	return(newobj);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ      GetFractal() = Load a fractal from file and return       บ
    บ                     pointer to it                             บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object * GetFractal(Object *queue)
{
  	Triangle * newobj;
  	int type=0,no_param = 0, found;
	Vector temp;

	newobj = new Triangle;
	newobj->col_data = new color_data;
	*newobj->col_data = def.col_data;
  	while (type != PAREN && !feof(fget)) 
	{
    	type = get_string(string_buf);
	    found = get_color_data(type,newobj->col_data);
		if (found == TRUE)
			continue;
		found = TRUE;
		switch(type)
		{
			case LOC:
				newobj->loc.get_vector();
      			no_param |= 1; 
				break;
			case V1:
				newobj->vect1.get_vector();
      			no_param |= 2; 
				break;
    		case V2:
				newobj->vect2.get_vector();
      			no_param |= 4; 
	    		break;
			case DIMENSION:
				get_string(string_buf);
				WORLD.fractal_dim = atof(string_buf);
				break;
			case SCALAR:
				get_string(string_buf);
				WORLD.fractal_scalar = atof(string_buf);
				break;
			case PAttern:
				newobj->pattern=Attach_Pattern();
	   			break;
			case REMOVE:
				newobj->remove=Attach_Pattern();
				break;
			case XMULT:
				get_string(string_buf);
				newobj->xmult = fabs(atof(string_buf));
				break;
			case YMULT:
				get_string(string_buf);
				newobj->ymult = fabs(atof(string_buf));
				break;
			case NAME:
				get_string(newobj->name);
				break;				
			case PAREN:
				break;
			default:
				found = FALSE;
		 }
    	if (!found) 
		{
			cout << "Undefined parameter " << string_buf << 
				" while loading fractal triangle in 'input.cpp'";
			exit(1);
		}
  	}
  	if (no_param != 7)
	{
		cout << "Too few parameters for fractal triangle in 'input.cpp'";
		exit(1);
	}
	Fractal_comp(newobj);
	queue = Make_fractal_triangles(newobj->loc, newobj->vect1, newobj->vect2,
		newobj->vect3, queue, WORLD.level);
  	WORLD.objcount++;
  	return(queue);
}


/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บGet_Object()=Load an object from file and return pointer to it บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object * Get_Object(int type, Object *queue)
{
	Object * newobj;

  	newobj=NULL;
  	switch(type)
	{
		case SPHERE:
			newobj=GetSphere();
  			break;
		case PARALLELOGRAM:
			newobj=GetParallelogram();
  			break;
		case TRIANGLE:
			newobj=GetTriangle();
  			break;
		case RING:
			newobj=GetRing();
  			break;
		case QUADRATIC:
			newobj=GetQuadratic();
			break;
		case CONE:
			newobj=GetCone();
			break;
		case FRACTAL:
			newobj = GetFractal(queue);
			break;
		case INSTANCE_OF:
			newobj=Get_Instance_Of();
  			break;
	}
	return(newobj);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ   Attach_Pattern() = Finds pattern matching object pattern    บ
    บ                      name and returns pointer to it           บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Pattern *Attach_Pattern()
{
  	Pattern * pat;

	get_string(string_buf);
  	pat=WORLD.patlist;
  	while (pat!=NULL) 
	{
		if (strcmp(string_buf,pat->name)==0) 
			break;
    	pat=pat->sibling;
  	}
	if (pat==NULL) 
	{
		cout << "Pattern not found\n";
		exit(1);
	}
  	return(pat);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ      Get_Circle_Pattern() = Loads a circle sub-pattern        บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Pattern *Get_Circle_Pattern()
{
  	int type=0,no_param = 0, found;
	Pattern *pattern;
  	color_data col_data;

  	pattern=new Pattern;
	pattern->name[0] = NULL;
	pattern->child = NULL;
	pattern->sibling = NULL;
	pattern->link = NULL;
  	pattern->type = CIRCLE;
  	col_data = def.col_data;
  	while (type != PAREN && !feof(fget)) 
	{
    	type = get_string(string_buf); 
		found = get_color_data(type,&col_data);
      	if (type == RADIUS)
		{
        	get_string(string_buf);
			pattern->radius = abs(atof(string_buf));
        	no_param |= 1; 
			found = TRUE;
      	}
      	if (type == PAREN)
	  	{
			found = TRUE; 
		}
	    if (!found) 
		{
			cout << "Undefined parameter " << string_buf << 
				"in getting circle pattern\n";
			exit(1);
		}
	}
	if (no_param != 1) 
	{
		cout << "Too few parameters in getting circle pattern\n";
		exit(1);
	}
	pattern->col_data = col_data;
  	return(pattern);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ       Get_Rect_Pattern() = Load a rectangle sub-pattern       บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Pattern *Get_Rect_Pattern()
{
  	int type=0, no_param =0, found;
  	Pattern *pattern;
  	color_data col_data;
  
  	pattern=new Pattern;
	pattern->name[0] = NULL;
	pattern->child = NULL;
	pattern->sibling = NULL;
	pattern->link = NULL;
  	pattern->type = RECTANGLE;
  	col_data = def.col_data;
  	while (type != PAREN && !feof(fget)) 
	{
    	type = get_string(string_buf);
		found = get_color_data(type,&col_data);
      	if (found == FALSE)
			found = TRUE;
		else
			continue;
		switch(type)
		{
			case START_X:
				get_string(string_buf);
				pattern->startx = atof(string_buf);
        		no_param |= 1;
				break;
			case START_Y:
				get_string(string_buf);
				pattern->starty = atof(string_buf);
        		no_param |= 2;
				break;
			case END_X:
				get_string(string_buf);
				pattern->endx = atof(string_buf);
        		no_param |= 4;
				break;
			case END_Y:
				get_string(string_buf);
				pattern->endy = atof(string_buf);
        		no_param |= 8;
				break;
			case PAREN:
				break;
			default:
				 found = FALSE;
		}
	    if (!found) 
		{
			cout << "Undefined parameter " << string_buf <<
				" in getting recatangle pattern\n";
			exit(1);
		}
  	}
  	if (no_param != 15)
	{
		cout << "Too few parameters for rectangular pattern";
		exit(1);
	}
  	pattern->col_data = col_data;
  	return(pattern);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ         Get_Poly_Pattern() = Load a polygon pattern           บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Pattern *Get_Poly_Pattern()
{
  	int type=0, no_param = 0, found;
  	Pattern *pattern, *pointpatt;
  	color_data col_data;
  	pattern=new Pattern;
	pattern->name[0] = NULL;
	pattern->child = NULL;
	pattern->sibling = NULL;
	pattern->link = NULL;
  	pattern->type = POLYGON;
  	col_data = def.col_data;
  	while (type != PAREN && !feof(fget)) 
	{
    	found = FALSE;
		type = get_string(string_buf);
		found = get_color_data(type,&col_data);
      	if (found == TRUE)
			continue;
        if (type == POINT) 
		{
    	    pointpatt = new Pattern;
			get_string(string_buf);
        	pointpatt->startx = atof(string_buf);
			get_string(string_buf);
	        pointpatt->starty = atof(string_buf);
    	    no_param += 1; 
        	pointpatt->link = pattern->link;
        	pattern->link = pointpatt;
			found = TRUE;
      	}
		if (type == PAREN)
			break;	
		if (!found) 
		{
			cout << "Undefined parameter " << string_buf <<
				" in getting polygon pattern\n";
			exit(1);
		}
  	}
  	if (no_param < 3)
	{
		cout << "Too few parameters for polygon pattern";
		exit(1);
	}
 	pattern->col_data = col_data;
  	return(pattern);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ            Get_SubPattern() = Load a sub-pattern              บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Pattern *Get_SubPattern(int type)
{
	switch (type)
	{
		case RECTANGLE:
		    return(Get_Rect_Pattern());
  		case CIRCLE:
		    return(Get_Circle_Pattern());
  		case POLYGON:
		    return(Get_Poly_Pattern());
		default:
			return(NULL);
	}
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ        GetPattern() = Load a pattern into pattern list        บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

int GetPattern()
{
  	int type=0, no_param = 0, found= TRUE;
  	Pattern *pattern, *spat;
  	pattern = new Pattern;
	pattern->name[0] = NULL;
	pattern->child = NULL;
	pattern->sibling = NULL;
	pattern->link = NULL;
  	pattern->type = PATT_HEADER;
  	while (type != PAREN && !feof(fget)) 
	{
    	type = get_string(string_buf);
		switch(type)
		{
			case X_SIZE:
         		no_param |= 1;
				get_string(string_buf);
				pattern->xsize = atof(string_buf);
				break;
			case Y_SIZE:
				get_string(string_buf);
				pattern->ysize = atof(string_buf);
         		no_param |= 2;
				break;
			case NAME:
				get_string(pattern->name);
         		no_param |= 4;
				break;
      		default:
				found = FALSE;
		}
		if ((spat=Get_SubPattern(type))!=NULL) 
		{
        	spat->sibling=pattern->child;
         	pattern->child=spat;
         	no_param |= 8; found = TRUE;
      	}
      	if (type == PAREN)
 		{ 
			found = TRUE; 
		}
        if (!found) 
		{
			cout << "Undefined parameter " << string_buf << 
				" in getting pattern\n";
			exit(1);
	  	}
  	}
	if (no_param != 15)
	{
		cout << "Too few parameters in getting pattern\n";
		exit(1);
	}
  	pattern->sibling=WORLD.patlist;
  	WORLD.patlist=pattern;
  	return(TRUE);
}



/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ             Make_BBox() = Create a bounding box               บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Make_Bbox(Object * node)
{
	Object * tnode;
  	Vector v1,v2;
  	if (node->child!=NULL) 
    	Make_Bbox(node->child);
	if (node->nextobj!=NULL) 
	    Make_Bbox(node->nextobj);
	if (node->type==BBOX) 
	{
    	tnode=node->child;
    	node->lower = Vector(3e30, 3e30, 3e30);
    	node->upper = Vector(-3e30, -3e30, -3e30);
    	while (tnode!=NULL) 
		{
			tnode->FindBbox(&v1,&v2);
			node->lower = v1.min(node->lower);
			node->upper = v2.max(node->upper);
	   		tnode=tnode->nextobj;
    	}
  	}
}


/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ     Name_Find() = Finds object in stack with a given names    บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object * Name_Find(Object *obj,char *name)
{
	Object *temp;

	if (obj == NULL)
		return(NULL);
	if (obj->name != NULL)
		if (strcmp(name,obj->name) == 0)
			return(obj);
	if (obj->child != NULL)
		if ((temp = Name_Find(obj->child,name)) != NULL)
			return(temp);
	if (obj->nextobj != NULL)
		if ((temp = Name_Find(obj->nextobj,name)) != NULL)
			return(temp);
	return(NULL);
}
/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ     Get_Instance() = Loads an instance of a set of objects    บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object * Get_Instance_Of()
{
	char name[32];
  	int type = 0,no_param = 0, found=TRUE;
  	Vector  offset, mult;
  	Object * source, * dest;
  
	mult = Vector (1,1,1);
  	while (type != PAREN && !feof(fget))
	{
    	type = get_string(string_buf);
		switch(type)
		{
			case NAME:
				get_string(name);
				no_param |= 1; 
				break;
			case LOC:
				offset.get_vector();
      			no_param |= 2;
				break;
			case SCALE:
				mult.get_vector();
				break;
			case PAREN:
				break;
			default:
				found = FALSE;
		}
	    if (!found) 
		{
			cout << "Undefined parameter " << string_buf << 
				" in getting Instance";
			exit(1);
		}
	}
  	if (no_param != 3) 
	{
		cout << "Too few parameters in getting Instance";
		exit(1);
	}
	if ((source = Name_Find(WORLD.instances,name))==NULL)
    {
		cout << "Undefined instance name: " << name << "\n";
		exit(1);
	}
	dest = Move_Instance(source,TRUE);
	dest->Scale_Instance(&mult,TRUE);
  	Offset_Instance(dest,&offset,TRUE);
	WORLD.objcount++;
	return(dest);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ     Move_Instance() = Moves user defined primitive from       บ
    บ                     WORLD.instance to WORLD.stack             บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Object * Move_Instance(Object *obj, int fflag)
{
	Object * newobj;
  	if (obj==NULL) 
		return(NULL);
	switch(obj->type)
	{
		case SPHERE:
			newobj = new Sphere;
			break;
		case TRIANGLE:
			newobj = new Triangle;
			break;
		case RING:
			newobj = new Ring;
			break;
		case PARALLELOGRAM:
			newobj = new Parallelogram;
			break;
		case QUADRATIC:
			newobj = new Quadratic;
			break;
		case BBOX:
			newobj = new BBox;
			break;
		default:
			newobj = new Object;
	}
	*newobj = *obj;	
  	newobj->child   = Move_Instance(obj->child,FALSE);
  	if (!fflag)
    	newobj->nextobj = Move_Instance(obj->nextobj,FALSE);
  	else
    	newobj->nextobj = NULL;
  	return(newobj);
}

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                               บ
    บ    Offset_Instance() = Offsets a user defined primitive by    บ
    บ                        by vector 'offset'                     บ
    บ                                                               บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Offset_Instance(Object *obj, Vector *offset, int fflag)
{
	if (obj==NULL) 
		return;
	obj->loc = obj->loc + *offset;
	switch(obj->type)
	{
		case SPHERE:
			obj->n1 = obj->vect1.x * obj->vect1.x;
			break;
		case PARALLELOGRAM:
		case TRIANGLE:
		case RING:
			obj->n1 = obj->norm % obj->loc;
	}
	Offset_Instance(obj->child,offset,FALSE);
  	if (!fflag)
    	Offset_Instance(obj->nextobj,offset,FALSE);
}


