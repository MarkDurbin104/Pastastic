/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                             บ
  บ   newtgen = PROGRAM TO MAP THE GENERALIZED NEWTON'S METHOD  บ
  บ                                                             บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

#include <stdio.h>
#include <dos.h>
#include <stream.hpp>
#include <math.h>
#include <conio.h>

void cls(int color);
void move_cursor(int type,int color);
void plot(int x, int y, int color);
void setMode(int mode);
void writChar(char ch, int color, int page);

class complex {
     float real,imaginary;
public:
     complex(float r=0, float i = 0)
     { real = r; imaginary = i; }

     complex(complex &);
     complex operator+(complex &);
     complex operator-(complex &);
     complex operator*(complex &);
     complex operator/(complex &);
     complex operator*(float &);
     int operator==(complex &);
     void print(char * name = "");
     float mag();
     float r();
     float i();
};
complex::complex(complex & othercomplex)
{
     real = othercomplex.real; imaginary = othercomplex.imaginary;
}

complex complex::operator+(complex & arg)
{
     complex result;
     result.real = real + arg.real;
     result.imaginary = imaginary + arg.imaginary;
     return result;
}

complex complex::operator-(complex & arg)
{
     complex result;
     result.real = real - arg.real;
     result.imaginary = imaginary - arg.imaginary;
     return result;
}
complex complex::operator*(complex & arg)
{
     complex result;
     result.real = real * arg.real - imaginary * arg.imaginary;
     result.imaginary = real * arg.imaginary + imaginary * arg.real;
     return result;
}
complex complex::operator*(float & arg)
{
     complex result;
     result.real = real * arg;
     result.imaginary = imaginary * arg;
     return result;
}
complex complex::operator/(complex & arg)
{
     float temp;
     complex result;
     temp = arg.real*arg.real + arg.imaginary*arg.imaginary;
     result.real = (real * arg.real + imaginary * arg.imaginary)/temp;
     result.imaginary = (imaginary * arg.real - real *
          arg.imaginary)/temp;
     return result;
}


int complex::operator==(complex &rvalue)
{
     if ((real == rvalue.real) && (imaginary==rvalue.imaginary))
          return 1;
     else
          return 0;
}
void complex::print(char * name) 
{

     cout << name << ": ";
     if (imaginary >= 0)
          cout << real << " + " << imaginary << "i\n";
     else
          cout << real << " " << imaginary << "i\n";
}

float complex::mag()
{
     float temp;
     temp = sqrt(real * real + imaginary * imaginary);
     return temp;
}

float complex::r()
{
     float temp;
     temp = real;
     return temp;
}

float complex::i()
{
     float temp;
     temp = imaginary;
     return temp;
}


char strings[80];
int col,row,i,j,flag=0,flag2=0;
int max_iterations = 64;
int max_size = 4;
float Xmax= 2.0, Xmin= -2.0, Ymax=1.20, Ymin=-1.20,deltaX,deltaY;
complex z,zz,c,one(1,0),point_two(.2,0),old_z;
complex f,f_prime,z_power;
float arguments[10]; 
float temp;
const int maxcol = 639;
const int maxrow = 349;
const int max_colors = 16;

main()
{
     int color, row, col, degree;

     for (i=0; i<10; i++)
     {
          arguments[i] = 0;
		  cout << "\nEnter " << i << "th coefficient: ";
          cin >> arguments[i];
     }
     setMode(16);
	for (i=9; i>=0; i--)
 	{
	 	if (arguments[i] != 0)
	 	{
			degree = i;
			break;
		}
	}
     cls(7);
     deltaX = (Xmax - Xmin)/(maxcol + 1);
     deltaY = (Ymax - Ymin)/(maxrow + 1);
     old_z = complex(42,42);
        for (col=0; col<=maxcol; col++)
        {
          if (kbhit() != 0) break;
          for (row=0; row<=maxrow; row++)
                {
               z = complex(Xmin + col * deltaX,Ymax - row * deltaY);
               i = 0;
               while (i<max_iterations)
               {
                    f = 0;
					f_prime = 0;
                    z_power = 1;
                    for(j=0; j<degree; j++)
                    { 
                         f = f + z_power * arguments[j];
                         f_prime = f_prime + (z_power * arguments[j+1]) *
                         	(float)(j+1);
                         z_power = z*z_power;
                    }
                    f = f + z_power * arguments[degree];
                    z = z - f/f_prime; 
                    if (z == old_z)
                         break;
                    old_z = z;
                    i++;
               }
               color = i%16;
               plot(col, row, color);
          }
     }
     getch();
}

/* ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
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

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
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

/*  ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
    บ                                                         บ
    บ               setMode() = Sets Video Mode               บ
    บ                                                         บ
    ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

union REGS reg;
void setMode(int mode)
{
     reg.h.ah = 0;
     reg.h.al = mode;
     int86 (0x10,&reg,&reg);
}
 
