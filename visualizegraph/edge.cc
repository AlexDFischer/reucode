#include "math.h"
#include <iostream>
#include <vector>
#include <stdlib.h>
using namespace std;

class DV {
public:
  double x[3];
  DV (double vx=0, double vy=0, double vz=0) {
    x[0] = vx; x[1] = vy; x[2] = vz;
  }
  DV operator* (double s) const { return DV(x[0] * s, x[1] * s, x[2] * s); }
  DV operator/ (double s) const { return DV(x[0] / s, x[1] / s, x[2] / s); }
  double length () const {
    return sqrt(x[0] * x[0] + x[1] * x[1] + x[2] * x[2]);
  }
  DV unit () const { return *this / length(); }
  DV operator+ (const DV &v) const {
    return DV(x[0] + v.x[0], x[1] + v.x[1], x[2] + v.x[2]);
  }
  DV operator- (const DV &v) const {
    return DV(x[0] - v.x[0], x[1] - v.x[1], x[2] - v.x[2]);
  }
  DV cross (const DV &v) const {
    return DV(x[1] * v.x[2] - x[2] * v.x[1],
              x[2] * v.x[0] - x[0] * v.x[2],
              x[0] * v.x[1] - x[1] * v.x[0]);
  }
};

ostream &operator<< (ostream &out, const DV &v) {
  return out << v.x[0] << " " << v.x[1] << " " << v.x[2];
}

istream &operator>> (istream &in, DV &v) {
  return in >> v.x[0] >> v.x[1] >> v.x[2];
}

int main (int argc, char *argv[]) {
  double width = 1e-3;
  if (argc > 1)
    width  = atof(argv[1]);
  cerr << "width " << width << endl;

  vector<DV> verts;
  DV v;
  while (cin >> v)
    verts.push_back(v);

  int n = verts.size() / 2;
  cerr << "n " << n << endl;

  cout << "# vtk DataFile Version 3.0" << endl
       << "vtk output" << endl
       << "ASCII" << endl
       << "DATASET POLYDATA" << endl
       << "POINTS " << 6 * n << " double" << endl;

  DV rndm(1.234, 5.678, 9.101);

  for (int i = 0; i < n; i++) {
    DV a = verts[2 * i];
    DV b = verts[2 * i + 1];
    DV ab = b - a;
    DV u0 = ab.cross(rndm).unit();
    DV u90 = ab.cross(u0).unit();
    double s120 = sqrt(3.0) / 2;
    DV u120 = u0 * -0.5 + u90 * s120;
    DV u240 = u0 * -0.5 - u90 * s120;
    cout << a + u0 * width << endl;
    cout << a + u120 * width << endl;
    cout << a + u240 * width << endl;
    cout << b + u0 * width << endl;
    cout << b + u120 * width << endl;
    cout << b + u240 * width << endl;
  }

  cout << "POLYGONS " << 5 * n << " " << 23 * n << endl;

  for (int i = 0; i < n; i++) {
    double m = 6 * i;
    cout << "3 " << m+2 << " " << m+1 << " " << m << endl;
    cout << "3 " << m+3 << " " << m+4 << " " << m+5 << endl;
    for (int j = 0; j < 3; j++) {
      int k = (j+1)%3;
      cout << "4 " << m+j << " " << m+k << " " << m+3+k << " " << m+3+j << endl;
    }
  }
}
