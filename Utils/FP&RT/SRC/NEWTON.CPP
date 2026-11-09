/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                                                               บ
            บ              newton = PROGRAM TO MAP THE NEWTON METHOD        บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/
#include <stdio.h>
#include <math.h>
#include <dos.h>
#include <process.h>
#include <stream.hpp>
#include <conio.h>;

void cls(int color);
void move_cursor(int type,int color);
void plot(int x, int y, int color);
void setMode(int mode);
void writChar(char ch, int color, int page);

class complex {
	float real,imaginary;
public:
	complex(float r, float i);
	complex();
	complex(complex &);
	complex operator+(complex &);
	complex operator-(complex &);
	complex operator=(complex &);
	complex operator*(complex &);
	complex operator*(float & );
	complex operator/(complex &);
	complex operator~();
	int operator!=(complex &);
	int operator==(complex &);
	void print(char * name = "");
	float r();
	float i();
};

complex::complex()
{
	real = 0;
	imaginary = 0;
}

complex::complex(float r, float i)
{
	real = r;
	imaginary = i;
}

complex::complex(complex & othercomplex){
	real = othercomplex.real; imaginary = othercomplex.imaginary;
}

complex complex::operator+(complex & arg){
	complex result;
	result.real = real + arg.real;
	result.imaginary = imaginary + arg.imaginary;
	return result;
}

complex complex::operator-(complex & arg){
	complex result;
	result.real = real - arg.real;
	result.imaginary = imaginary - arg.imaginary;
	return result;
}
complex complex::operator*(complex & arg){
	complex result;
	result.real = real * arg.real - imaginary * arg.imaginary;
	result.imaginary = real * arg.imaginary + imaginary * arg.real;
	return result;
}
complex complex::operator*(float & arg){
	complex result;
	result.real = real * arg;
	result.imaginary = imaginary * arg;
	return result;
}
complex complex::operator/(complex & arg){
	float temp;
	complex result;
	temp = arg.real*arg.real + arg.imaginary*arg.imaginary;
	result.real = (real * arg.real + imaginary * arg.imaginary)/temp;
	result.imaginary = (imaginary * arg.real - real * arg.imaginary)/temp;
	return result;
}
complex complex::operator~(void)      //  1/z
{
	float temp;
	complex result;
	temp = real*real + imaginary*imaginary;
	result.real = real/temp;
	result.imaginary = -imaginary/temp;
	return result;
}
complex complex::operator=(complex & rvalue){
	real = rvalue.real;
	imaginary = rvalue.imaginary;
	return *this;
}

int complex::operator==(complex &rvalue)
{
	if ((fabs(real - rvalue.real) < 0.00001) &&
		(fabs(imaginary - rvalue.imaginary) < 0.00001))
		return 1;
	else
		return 0;
}

int complex::operator!=(complex &rvalue)
{
	if ((fabs(real - rvalue.real) < 0.00001) &&
		(fabs(imaginary - rvalue.imaginary) < 0.00001))
		return 0;
	else
		return 1;
}

void complex::print(char * name) {

//	cout << name << ": ";
	printf("%s: ",name);
	if (imaginary >= 0)
//		cout << real << " + " << imaginary << "i\n";
		printf("%f + %fi\n",real,imaginary);
	else
//		cout << real << " " << imaginary << "i\n";
		printf("%f %fi\n",real,imaginary);
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

const int maxcol = 639;
const int maxrow = 349;
const int max_colors = 16;


int max_iterations = 64;
float Xmax= 2.0, Xmin= -2.0, Ymax=1.20, Ymin=-1.20,deltaX,deltaY;
complex z,c,old_z,z_power,z_temp,roots[10],z_sq, z_fourth,z_eighth;
int degree;

main()
{
	int i,j,color, row, col,flag;
    float a,b,threshold=0.2,twopi=6.2831853;
	
	setMode(16);
	cls(7);
//	cout << "Enter degree of equation (3 - 10): ";
//	cin >> degree;
//	cout << "\nEnter '0' for cyclical colors;\n"
//		<< "'1' for colors associated with root: ";
//	cin >> flag;
	printf("Enter degree of equation (3 - 10): ");
	scanf("%d",&degree);
	printf("\nEnter '0' for cyclical colors;\n'1' for colors associated with root: ");
	scanf("%d",&flag);

	if (degree < 3)
		degree = 3;
	if (degree > 10)
		degree = 10;
	if (flag < 0)
		flag = 0;
	if (flag > 1)
		flag = 1;
	a = 1.0/(float)degree;
	b = 1 - a;
	for (i=0; i<degree; i++)
	{
		roots[i] = complex(cos(i*twopi/(float)degree),
			sin(i*twopi/(float)degree));
	roots[i].print("");
	}
	deltaX = (Xmax - Xmin)/(maxcol + 1);
	deltaY = (Ymax - Ymin)/(maxrow + 1);
    for (col=0; col<=maxcol; col++)
    {
		if (kbhit() != 0) break;
		for (row=0; row<=maxrow; row++)
        {
		  	z = complex(Xmin + col * deltaX,Ymax - row * deltaY);
			old_z = complex(10000,10000);
			i = 0;
			while ((z != old_z) && (i<64))
			{
//				z.print("z");
//				old_z.print("old z");
				old_z = z;
//              	        z = z*0.8 + complex(0.2,0)/(z*z*z*z);
				z_temp = ~z;
				z_sq = z_temp*z_temp;
				if (degree>3)
					z_fourth = z_sq*z_sq;
				if (degree>7)
					z_eighth = z_fourth*z_fourth;
				switch(degree)
				{
					case 3:
						z_power = z_temp*z_sq;
						break;
					case 4:
						z_power = z_fourth;
						break;
					case 5:
						z_power = z_temp*z_fourth;
						break;
					case 6:
						z_power = z_sq*z_fourth;
						break;
					case 7:
						z_power = z_temp*z_sq*z_fourth;
						break;
					case 8:
						z_power = z_eighth;
					case 9:
						z_power = z_temp*z_eighth;
						break;
					case 10:
						z_power = z_sq*z_eighth;
				}
				z = z*b + (z_power)*a;
				i++;
			}
//			printf("Start new z\n");
//			z.print("z");
			if (flag == 1)
			{
				color = 15;
				for (j=0; j<degree; j++)
				{
					if (z == roots[j])
						color = 1 + j%8 + 8*(i%2);
				}
			}
			else
				color = i%16;
			plot(col, row, color);
		}
	}
	getch();
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

/*             ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
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