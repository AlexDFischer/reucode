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
  double w = 1;
  if (argc > 1)
    w  = atof(argv[1]);
  cerr << "width " << w << endl;
  
  vector<DV> verts;
  DV p;
  while (cin >> p)
    verts.push_back(p);
    
  int n = verts.size();
  cerr << "n " << n << endl;

  cout << "# vtk DataFile Version 3.0" << endl
       << "vtk output" << endl
       << "ASCII" << endl
       << "DATASET POLYDATA" << endl
       << "POINTS " << 8 * n << " double" << endl;

  DV v[8] = { DV(-w, -w, -w), DV(w, -w, -w), DV(-w, w, -w), DV(w, w, -w),
              DV(-w, -w, w), DV(w, -w, w), DV(-w, w, w), DV(w, w, w) };

  for (int i = 0; i < n; i++) {
    DV c = verts[i];
    for (int j = 0; j < 8; j++)
      cout << c + v[j] << endl;
  }

  cout << "POLYGONS " << 6 * n << " " << 30 * n << endl;

  int vv[6][4] = { { 0, 1, 5, 4 }, { 0, 2, 3, 1 }, { 0, 4, 6, 2 }, 
                   { 7, 6, 4, 5 }, { 7, 5, 1, 3 }, { 7, 3, 2, 6 } };

  for (int i = 0; i < n; i++) {
    double m = 8 * i;
    for (int j = 0; j < 6; j++) {
      cout << "4";
      int *vvj = vv[j];
      for (int k = 0; k < 4; k++)
        cout << " " << m + vvj[k];
      cout << endl;
    }
  }
}
