/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ       qmath.cpp = Functions for Quaternion Mathematics        บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include <stream.hpp>
#include "qrender.hpp"

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                    Quaternion Constructors                    บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quaternion::Quaternion()
{
	real = 0;
	i = 0; 
	j = 0;
	k = 0;
}

Quaternion::Quaternion(float real1, float i1, float j1, float k1)
{
	real = real1;
	i = i1; 
	j = j1;
	k = k1;
}

Quaternion::Quaternion(Quaternion & arg)
{
	real = arg.real;
	i = arg.i; 
	j = arg.j;
	k = arg.k;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ               Quaterion Overload of + Operator                บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quaternion Quaternion::operator+(Quaternion & arg)
{
	Quaternion result;

	result.real = real + arg.real;
	result.i = i + arg.i;
	result.j = j + arg.j;
	result.k = k + arg.k;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ           Quaternion Overload of - Operator (a - b)           บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quaternion Quaternion::operator-(Quaternion & arg)
{
	Quaternion result;
	
	result.real = real - arg.real;
	result.i = i - arg.i;
	result.j = j - arg.j;
	result.k = k - arg.k;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ           Quaternion Overload of - Operator (-a)              บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quaternion Quaternion::operator-()
{
	Quaternion result;

	result.real = -real;
	result.i = - i;
	result.j = - j;
	result.k = - k;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ Quaternion Overload of * Operator (Quaternion X a Quaternion) บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quaternion Quaternion::operator*(Quaternion & arg)
{
	Quaternion result;

	result.real = real * arg.real - i * arg.i - j * arg.j - k * arg.k; 
	result.i = real * arg.i + i * arg.real + j * arg.k - k * arg.j;
	result.j = real * arg.j + j * arg.real + k * arg.i - i * arg.k;
	result.k = real * arg.k + k * arg.real + i * arg.j - j * arg.i;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ    Quaternion Overload of * Operator (Quaternion X a float    บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quaternion Quaternion::operator*(float arg)
{
	Quaternion result;

	result.real = real * arg;
	result.i = i * arg;
	result.j = j * arg;
	result.k = k * arg;
	return result;
}


/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ               Quaternion Overload of / Operator               บ
            บ              (Quaterion Divided by a Quaternion)              บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quaternion Quaternion::operator/(Quaternion &arg)
{
	Quaternion temp1, temp2, result;

	temp1 = Quaternion(arg.real, -arg.i, -arg.j, -arg.k);
	cout << "Numerator: " << *this << "\n";
	cout << "Denominator: " << arg << "\n";
	cout << "Multiplier: " << temp1 << "\n";
	temp2 = *this * temp1;
	cout << "Numerator product: " << temp2 << "\n";
	temp1 = arg * temp1;
	cout << "Denominator product: " << temp1 << "\n";
	result.real = temp2.real / temp1.real;
	result.i = temp2.i / temp1.real;
	result.j = temp2.j / temp1.real;
	result.k = temp2.k / temp1.real;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ              Quaternion Overload of = Operator                บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quaternion Quaternion::operator=(Quaternion & rvalue)
{
	real = rvalue.real;
	i = rvalue.i;
	j = rvalue.j;
	k = rvalue.k;
	return *this;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ   Quaternion Overload of ~ Operator (Normalize a Quaternion)  บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quaternion Quaternion:: operator~()
{
	Quaternion result;
	float length;

	length = real*real + i*i + j*j + j*j;
	length = sqrt(length);
	result.real = real/length;
	result.i = i/length;
	result.j = j/length;
	result.k = k/length;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                 Print Out Quaternion Contents                 บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

ostream &operator<<(ostream& s,Quaternion& arg)
{
	s << "(" << arg.real << "," << arg.i <<"," << arg.j << "," << arg.k << ")";
	return s;
}


/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ               Function to square a Quaternion                 บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Quaternion Quaternion:: sqr()
{
	Quaternion result;
	float temp;

	temp = 2 * real;
	result.real = real * real - i * i - j * j - k * k;
	result.i = temp * i;
	result.j = temp * j;
	result.k = temp * k;
	return (result);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ  Function to find the square of the magnitude of a Quaternion บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

float mag_sq(Quaternion& arg)
{
	float result;

	result = arg.real*arg.real + arg.i*arg.i;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ        Function to find the magnitude of a Quaternion         บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

float mag(Quaternion& arg)
{
	float result;

	result = arg.real*arg.real + arg.i*arg.i + arg.j*arg.j + arg.k*arg.k;
	return sqrt(result);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ vmath.cpp = Classes for Three Dimensional Vector Mathematics  บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                      Vector Constructors                      บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector::Vector()
{
	x = 0;
	y = 0;
	z = 0;
}

Vector::Vector(float x1, float y1, float z1)
{
	x = x1;
	y = y1;
	z = z1;
}

Vector::Vector(Vector & otherVector)
{
	x = otherVector.x; 
	y = otherVector.y;
	z = otherVector.z;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                 Vector Override of + Operator                 บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::operator+(Vector & arg)
{
	Vector result;
	result.x = x + arg.x;
	result.y = y + arg.y;
	result.z = z + arg.z;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ             Vector Override of - Operator (a - b)             บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::operator-(Vector & arg)
{
	Vector result;
	result.x = x - arg.x;
	result.y = y - arg.y;
	result.z = z - arg.z;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ             Vector Override of - Operator (-a)                บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::operator-()
{
	Vector result;
	result.x = - x;
	result.y = - y;
	result.z = - z;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ     Vector Override of * Operator (Vector Times a Vector)     บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::operator*(Vector & arg)
{
	Vector result;
	result.x = x * arg.x;
	result.y = y * arg.y;
	result.z = z * arg.z;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ     Vector Override of * Operator (Vector Times a Float)      บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::operator*(float arg)
{
	Vector result;
	result.x = x * arg;
	result.y = y * arg;
	result.z = z * arg;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ    Vector Override of / Operator (Vector Divided by a Float)  บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::operator/(float arg)
{
	Vector result;
	result.x = x / arg;
	result.y = y / arg;
	result.z = z / arg;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                Vector Override of = Operator                  บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::operator=(Vector & rvalue)
{
	x = rvalue.x;
	y = rvalue.y;
	z = rvalue.z;
	return *this;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ   Vector Override of % Operator (Dot Product of Two Vectors   บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

float Vector::operator%(Vector & arg)
{
	float result;
	result = x*arg.x + y*arg.y + z*arg.z;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ  Vector Override of ^ Operator (Cross Product of Two Vectors) บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::operator^(Vector & arg)
{
	Vector result;
	result.x = y*arg.z - z*arg.y;
	result.y = z*arg.x - x*arg.z;
	result.z = x*arg.y - y*arg.x;
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ       Vector Override of ~ Operator (Normalize a Vector)      บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::operator~()
{
	Vector result;
	float l;

	l = *this % *this;
	l = sqrt(l);
	result.x = x/l;
	result.y = y/l;
	result.z = z/l;
	return result;
}

	

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ             max = Return the maximum of two vectors           บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::max(Vector & arg)
{
	Vector result;

	result.x = MAX(x,arg.x);
	result.y = MAX(y,arg.y);
	result.z = MAX(z,arg.z);
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ             min = Return the minimum of two vectors           บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::min(Vector & arg)
{
	Vector result;

	result.x = MIN(x,arg.x);
	result.y = MIN(y,arg.y);
	result.z = MIN(z,arg.z);
	return result;
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                         Rotate a Vector                       บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::Rotate(float cos1, float sin1, float cos2, float sin2)
{
	Vector temp, result;
	
	result.x = x * cos1 + z * -sin1;
	temp.y = y;
	temp.z = x * sin1 + z * cos1;
	result.y = temp.y * -cos2 + temp.z * sin2;
	result.z = temp.y * -sin2 + temp.z * -cos2;
	return(result);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                    Reverse Rotate a Vector                    บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Vector Vector::Rev_Rotate(float cos1, float sin1, float cos2, float sin2)
{
	Vector temp, result;
	
	temp.x = x;
	result.y = y * cos2 + z * -sin2;
	temp.z = y * sin2 + z * cos2;
	result.x = temp.x * -cos1 + temp.z * sin1;
	result.z = temp.x * -sin1 + temp.z * -cos1;
	return(result);
}

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                   Print Out Vector Contents                   บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

ostream &operator<<(ostream& s,Vector& arg)
{
	s << "(" << arg.x << "," << arg.y <<"," << arg.z << ")";
	return s;
}



