/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ vmath.cpp = Classes for Three Dimensional Vector Mathematics  บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include "render.hpp"
#include <iostream.h>

extern char string_buf[32];

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

/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ                     Get Vector from stdin                     บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

void Vector::get_vector() 
{
	get_string(string_buf);
	x = atof(string_buf);
	get_string(string_buf);
	y = atof(string_buf);
	get_string(string_buf);
	z = atof(string_buf);
}


