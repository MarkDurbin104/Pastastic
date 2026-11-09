/*  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                                        บ
    บ                qin() = Function to process input data                  บ
    บ                                                                        บ
    บ                     Roger T. Stevens 7-16-90                           บ
    บ                                                                        บ
    ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include "qrender.hpp"

Vector get_vector(void) ;
Quaternion get_quaternion(void) ;

extern Vector background,ambient,diffuse,specular;
extern int b, Flip,divergence_boundary,max_iterations,Xres,Yres,flag;
extern float LightPhi,LightTheta,ViewPhi,Xmax,Xmin,Ymax,Ymin,Zmax,Zmin;
extern Quaternion c;
extern char ObjectFile[32];
extern char file_in[32];

char string_buf[32];
char string_types[128][32] = {"BACKGROUND","AMB","DIFF","SREFLECT",
	"REFLECT","FILE_NAME","FLIP","LIGHT_PHI","LIGHT_THETA","VIEW_PHI",
	"XRES","YRES","XMAX","XMIN","YMAX","YMIN","ZMAX","ZMIN",
	"QUATERNION","MAX_SIZE","MAX_ITERATIONS","JULIA","DRAGON",NULL};
FILE *fget;

int qin(void)
{
	int Type;

	fget = fopen(file_in,"rb");	
	while (!feof(fget)) 
	{
    	Type = get_string(string_buf); 
		switch(Type)
		{
			case BACKGROUND:
				background = get_vector();
				break;
			case AMB:
				ambient = get_vector();
				break;
			case DIFF:
				diffuse = get_vector();
				break;
			case SREFLECT:
				get_string(string_buf);
				b = atoi(string_buf);
				break;
			case REFLECT:
				specular = get_vector();
				break;
			case FILE_NAME:
				get_string(string_buf);
				strcpy(ObjectFile,string_buf);
				break;
			case FLIP:
				get_string(string_buf);
				Flip = atoi(string_buf);
				break;
			case LIGHT_PHI:
				get_string(string_buf);
				LightPhi = atof(string_buf);
			  	LightPhi *= 0.017453925;
				break;
			case LIGHT_THETA:
				get_string(string_buf);
				LightTheta = atof(string_buf);
			  	LightTheta *= 0.017453925;
				break;
			case VIEW_PHI:
				get_string(string_buf);
				ViewPhi = atof(string_buf);
			  	ViewPhi *= 0.017453925;
				break;
			case XRES:
				get_string(string_buf);
				Xres = atoi(string_buf);
				break;
			case YRES:
				get_string(string_buf);
				Yres = atoi(string_buf);
				break;
			case XMAX:
				get_string(string_buf);
				Xmax = atof(string_buf);
				break;
			case XMIN:
				get_string(string_buf);
				Xmin = atof(string_buf);
				break;
			case YMAX:
				get_string(string_buf);
				Ymax = atof(string_buf);
				break;
			case YMIN:
				get_string(string_buf);
				Ymin = atof(string_buf);
				break;
			case ZMAX:
				get_string(string_buf);
				Zmax = atof(string_buf);
				break;
			case ZMIN:
				get_string(string_buf);
				Zmin = atof(string_buf);
				break;
			case QUATERNION:
				c = get_quaternion();
				break;
			case MAX_SIZE:
				get_string(string_buf);
				divergence_boundary = atof(string_buf);
				break;
			case MAX_ITERATIONS:
				get_string(string_buf);
				max_iterations = atoi(string_buf);
				break;
			case JULIA:
				flag = 0;
				break;
			case DRAGON:
				flag = 1;
				break;
			case Null:
				break;
			default:
				cout << "Illegal input parameter type " << Type << " buffer: '" 
					<< string_buf << "'.\n";
				exit(0);
		}
	}
	fclose(fget);	
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

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                     Get Vector from file                      บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector get_vector(void) 
{
	Vector result;
	get_string(string_buf);
	result.x = atof(string_buf);
	get_string(string_buf);
	result.y = atof(string_buf);
	get_string(string_buf);
	result.z = atof(string_buf);
	return(result);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                   Get Quaternion from file                    บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quaternion get_quaternion(void) 
{
	Quaternion result;
	get_string(string_buf);
	result.real = atof(string_buf);
	get_string(string_buf);
	result.i = atof(string_buf);
	get_string(string_buf);
	result.j = atof(string_buf);
	get_string(string_buf);
	result.k = atof(string_buf);
	return(result);
}

