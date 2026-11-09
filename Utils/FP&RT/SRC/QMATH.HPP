/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ vmath.hpp=Header File for Three Dimensional Vector Mathematicsบ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include <stream.hpp>
#include <math.h>

class Vector {
	public:
	float x, y, z;

	Vector();
	Vector(float x1, float y1, float z1);
	Vector(Vector &);
	Vector operator+(Vector &);
	Vector operator-(Vector &);
	Vector operator-();
	Vector operator=(Vector &);
	Vector operator*(Vector &);
	Vector operator*(float );
	Vector operator/(float );
	float operator%(Vector &);	// Dot product
	Vector operator^(Vector &);	// Cross product
	Vector operator~();             // Normalize vector
	Vector min(Vector &);
	Vector max(Vector &);
	Vector Rotate(float cos1, float sin1, float cos2, float sin2);
	Vector Rev_Rotate(float cos1, float sin1, float cos2, float sin2);
	friend ostream &operator<<(ostream&,Vector&);
};


/*          ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
            บ                                                               บ
            บ      qmath.hpp = Header File for Quaternion Mathematics       บ
            บ                                                               บ
            ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/


class Quaternion 
{
	public:
	float real, i, j, k;
	Quaternion();
	Quaternion (float real1, float i1, float j1, float k1);
	Quaternion (Quaternion &);
	Quaternion operator+(Quaternion &);
	Quaternion operator-(Quaternion &);
	Quaternion operator-();
	Quaternion operator=(Quaternion &);
	Quaternion operator*(Quaternion &);
	Quaternion operator*(float);
	Quaternion operator/(float);
	Quaternion operator/(Quaternion &);
	Quaternion operator~();             // Normalize quaternion
	Quaternion sqr();
	friend ostream &operator<<(ostream&,Quaternion&);
	friend float mag(Quaternion&);
	friend float mag_sq(Quaternion&);
};


