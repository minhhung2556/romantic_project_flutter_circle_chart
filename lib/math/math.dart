import 'dart:math' as math;

export 'affineTransform.dart';
export 'objectives.dart';

double sqrt(double a) => math.sqrt(a);
double pow(double a, double b) => math.pow(a, b).toDouble();
double abs(double a) => a < 0 ? -a : a;
int round(double a) => a.round();
double atan(double a) => math.atan(a);
double cos(double a) => math.cos(a);
double sin(double a) => math.sin(a);
const pi = math.pi;

const kDegToRad = math.pi / 180.0;
const kRadToDeg = 180.0 / math.pi;

double toRad(double degree) => degree * kDegToRad;

double factorial(double x) {
  if (x < 3) {
    if (x < 2)
      return 1;
    else
      return 2;
  } else {
    double res = 1;
    for (double i = 2; i <= x; i++) {
      res *= i;
    }
    return res;
  }
}

const int sign_mask = 0x80000000;
const double b = 0.596227;
double atan2(double y, double x) {
  // Extract the sign bits
  int ux_s = sign_mask & x.round();
  int uy_s = sign_mask & y.round();

  // Determine the quadrant offset
  double q = ((~ux_s & uy_s) >> 29 | ux_s >> 30).toDouble();

  // Calculate the arctangent in the first quadrant
  double bxy_a = abs(b * x * y);
  double num = bxy_a + y * y;
  double atan_1q = num / (x * x + bxy_a + num);

// Translate it to the proper quadrant
  int uatan_2q = (ux_s ^ uy_s) | atan_1q.round();
  return q + uatan_2q.toDouble();
}
