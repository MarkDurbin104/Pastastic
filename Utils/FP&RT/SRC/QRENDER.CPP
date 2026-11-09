/*  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                                        บ
    บ                    Z-Buffer Rendering Program                          บ
    บ                                                                        บ
    บ                     Roger T. Stevens 7-24-90                           บ
    บ                                                                        บ
    ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include "qrender.hpp"

void cls(int color);
void plot(int x, int y, int color);
void setMode(int mode);
void Pixel(int x, int y, int color);

char ObjectFile[32];
char file_in[32];
int Xres, Yres, Zres=255;
int Height[2][800];
int Scaling,max_color=63,max_iterations,flag;
Vector view;    // global view vector
Vector light;   // global light vector
float ViewPhi, ViewTheta,SinViewPhi, CosViewPhi, LightPhi, LightTheta,
	Xmax,Xmin,Ymax,Ymin,Zmax,Zmin,divergence_boundary;
FILE *fget, *fsave;
int m,i, j, k, p, p0, p1, horizon;
Vector Pix, newPix, oldPix;
float h,temp;
char FileNameOut[32];
int Tilt,Flip;
Vector ambient;  // percentage of ambient light 
Vector diffuse;  // percentage of diffuse light from reflection  - grainular 
Vector specular;  // percentage of specular light from reflection - Euclidian }
Vector background;
int b  = 2;    // shininess 
int Type, type, integer;
char red[800],green[800], blue[800];
Quaternion c;

/*  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                            Main Program                                บ
    ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/
main(int argc, char *argv[])
{
	strcpy(file_in, argv[1]);
	printf("Z-Buffer Rendering Program\n\n");
  	for(i=0; i<2; i++)
        for(j=0; j<=Yres; j++)
        	Height[i][j] = 0;
  	qin();	
	strcpy(FileNameOut,ObjectFile);
    strcat(ObjectFile, ".zbf");
    strcat(FileNameOut, ".raw");
	cout << "\nSaving " << FileNameOut << "\n";
	fsave = fopen(FileNameOut,"wb");
	cout << "\nLoading " << ObjectFile << "\n";
	getch();
	fget = fopen(ObjectFile,"rb");
	cout << "Read file open\n";
	SinViewPhi = sin(ViewPhi);
  	CosViewPhi = cos(ViewPhi);
  	view = Vector(0, -CosViewPhi, SinViewPhi);
  	light = Vector(sin(LightTheta) * cos(LightPhi), sin(LightTheta) * 
		sin(LightPhi), cos(LightTheta));
  	fread(&Xres,2,1,fget);
  	fread(&Yres,2,1,fget);
	cout << "Resolution is " << Xres << " pixels by " << Yres << " rows.\n";
	cout << "Hit any key to continue...\n";
	getch();
	setMode(0x0E);
  	fread(&Scaling,2,1,fget);
  	fwrite(&Xres,2,1,fsave);
  	fwrite(&Yres,2,1,fsave);
  	fwrite(&Scaling,2,1,fsave);
	fread(&Height[0][0],2,Yres+1,fget);  
 	for (i=0; i<(Xres-1); i++)
	{
		fread(&Height[(i+1)%2][0],2,Yres+1,fget);	  
      	p0 =  (float)Zres * ((Height[i % 2][0] / (float)Scaling) * CosViewPhi);
        horizon = p0;
        for (j=0; j<Yres; j++)
		{
            red[j] = background.x*max_color;
            green[j] = background.y*max_color;
            blue[j] = background.z*max_color;
        }
        for (j=1; j<Yres; j++)
		{
            p1 = (float)Zres * ((j / ((float)Zres)) * SinViewPhi +
                (Height[i % 2][j] / (float)Scaling) * CosViewPhi);
            if (p1 > horizon)
            {
				oldPix = Intensity(i, j);
                Pixel(i, p1, oldPix.y/3);
                if (Height[i % 2][j] !=0) 
				{
                    red[p1] = oldPix.x;
                    green[p1] = oldPix.y;
                    blue[p1] = oldPix.z;
                }
				else
				{
		            red[p1] = background.x*max_color;
        		    green[p1] = background.y*max_color;
		            blue[p1] = background.z*max_color;
				}
				p = p1 - 1;
				newPix = Intensity(i, j-1);
					while (p > horizon)
					{
						h = (float)(p - p0) / (float)(p1 - p0);
            	        Pix = ((oldPix * h) + (newPix * (1 - h)))/max_color;
                	    Pixel(i, p, Pix.y/3);
                    	if (Height[i % 2][j] !=0) 
						{
    	                    red[p] = Pix.x;
        	                green[p] = Pix.y;
            	            blue[p] = Pix.z;
                	    }
						else
						{
		        		    red[p] = background.x*max_color;
		        		    green[p] = background.y*max_color;
				            blue[p] = background.z*max_color;
						}
						p--;
				}
			horizon = p1;
            }


            p0 = p1;
		}
       	fwrite(&i,2,1,fsave);
		fwrite(&red[0],1,Yres+1,fsave);
		fwrite(&green[0],1,Yres+1,fsave);
		fwrite(&blue[0],1,Yres+1,fsave);
	}
	getch();
	cout << "\nษออออออออออออออออออออออออออออออออออออออออออออป\n" 
         << "บ                                            บ\n" 
	     << "บ           Processing Complete.             บ\n";
	printf("บ        Data in File: %12s          บ\n",FileNameOut);
    cout << "บ                                            บ\n"
         << "ศออออออออออออออออออออออออออออออออออออออออออออผ\n";
  	fclose(fget);
  	fclose(fsave);
}

/*             ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
               บ                                                         บ
               บ                 cls() = Clears the Screen               บ
               บ                                                         บ
               ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

                 void cls(int color)
                 {
		     union REGS reg;

                     reg.x.ax = 0x0600;
                     reg.x.cx = 0;
                     reg.x.dx = 0x184F;
                     reg.h.bh = color;
                     int86(0x10,&reg,&reg);
                 }

/*             ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
               บ                                                         บ
               บ         plot() = Plots a point at (x,y) in color        บ
               บ    for Enhanced Graphics Adapter, using Turbo C port    บ
               บ    output functions                                     บ
               ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/


                 void plot(int x, int y, int color)
                 {
                     #define dataOut(reg, value)   {outp(0x3CE, reg);\
                                                    outp(0x3CF, value);}
                     #define EGAaddress 0xA0000000L

                      unsigned char mask, dummy;
                     char far *color_address;

                     color_address = (char far *) (EGAaddress +
                                    ((long)y * 80L + ((long)x / 8L)));
                     mask = 0x80 >> (x % 8);
                     dummy = *color_address;
                     dataOut(0,color);
                     dataOut(1,0x0F);
                     dataOut(3,0);
                     dataOut(8,mask);
                     *color_address &= 0xFF;
                     dataOut(0,0);
                     dataOut(1,0);
                     dataOut(3,0);
                     dataOut(8,0xFF);
                 }

/* ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
   บ                                                         บ
   บ               setMode() = Sets Video Mode               บ
   บ                                                         บ
   ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

               union REGS reg;

	       void setMode(int mode)
                 {
                         reg.h.ah = 0;
                         reg.h.al = mode;
                         int86 (0x10,&reg,&reg);
                 }


/* ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
   บ                                                         บ
   บ       Pixel() = plots two adjacent pixels on screen     บ
   บ                                                         บ
   ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Pixel(int x, int y, int color)
{
    plot(2*x, Yres-y, color);
    plot(2*x+1, Yres-y, color);
}

/* ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
   บ                                                         บ
   บ      Intensity() = Finds light intensity at a point     บ
   บ                                                         บ
   ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Intensity(int i, int j)
{
	Vector n1, n2, difference, normal, reflected,temp;
	float CosTheta,	CosAlpha;

    n1 = Vector((Xmax-Xmin)/(Xres+1), 0, (float)( Height[(i+1)%2][j] - Height[i%2][j]));
	n2 = Vector(0, (Ymax-Ymin)/(Yres+1), (float)(Height[i%2][j+1] - Height[i%2][j]));
    normal = n1 ^ n2;
    normal = ~normal;
    CosTheta = normal % light;      
    if (CosTheta < 0)
    	return(ambient * max_color); 
    else
    {
		reflected = (normal - light) * (2.0*CosTheta);
        CosAlpha = view % reflected;
        temp = specular * pow(CosAlpha, b) + ambient + (diffuse * CosTheta);
		temp = temp * max_color;
		return(temp);
	}
}

