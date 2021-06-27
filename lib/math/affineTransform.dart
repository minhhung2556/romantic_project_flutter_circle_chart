import 'math.dart';

List<List<double>> get _emptyMatrix => [
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0]
    ];
List<List<double>> get _identityMatrix => [
      [1.0, 0.0, 0.0],
      [0.0, 1.0, 0.0],
      [0.0, 0.0, 1.0]
    ];

_copyMatrix(List<List<double>> a, List<List<double>> b) {
  for (var i = 0; i < b.length; ++i) {
    for (var j = 0; j < b[i].length; ++j) {
      a[i][j] = b[i][j];
    }
  }
}

class AffineTransform {
  late List<List<double>> M;

  AffineTransform(this.M);

  AffineTransform.identity() {
    M = _identityMatrix;
  }

  void identity() {
    M = _identityMatrix;
  }

  void _multiply(List<List<double>> A) {
    var res = _emptyMatrix;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        res[i][j] = 0.0;
        for (int k = 0; k < 3; k++) res[i][j] += A[i][k] * M[k][j];
      }
    }
    _copyMatrix(M, res);
  }

  void apply(Point p) {
    double x = p.x, y = p.y;
    p.x = M[0][0] * x + M[0][1] * y + M[0][2];
    p.y = M[1][0] * x + M[1][1] * y + M[1][2];
  }

  void applyPolygon(Polygon pn) {
    for (int i = 0; i < pn.count; i++) {
      apply(pn.vertices[i]);
    }
  }

  void applyPoints(List<Point> points) {
    for (int i = 0; i < points.length; i++) {
      apply(points[i]);
    }
  }

  void translate(double tx, double ty) {
    var mt = _identityMatrix;
    mt[0][2] = tx;
    mt[1][2] = ty;
    _multiply(mt);
  }

  void forward(double distance, double angleRad) {
    double dx = distance * cos(angleRad), dy = distance * sin(angleRad);
    translate(dx, dy);
  }

  void rotateOrigin(double alpha) // tam la goc toa do
  {
    var mr = _identityMatrix;
    alpha *= kDegToRad;
    mr[0][0] = mr[1][1] = cos(alpha);
    mr[0][1] = -sin(alpha);
    mr[1][0] = sin(alpha);
    _multiply(mr);
  }

  void rotate(double alpha, Point center) // tam bat ki
  {
    translate(-center.x, -center.y);
    rotateOrigin(alpha);
    translate(center.x, center.y);
  }

  void scaleOrigin(double sx, double sy) // tam la goc toa do
  {
    var msc = _identityMatrix;
    msc[0][0] = sx;
    msc[1][1] = sy;
    _multiply(msc);
  }

  void shearOrigin(double hx, double hy) // tam la goc toa do
  {
    var msh = _identityMatrix;
    msh[0][1] = hx;
    msh[1][0] = hy;
    _multiply(msh);
  }

  void scale(double sx, double sy, Point center) // tam bat ki
  {
    translate(-center.x, -center.y);
    scaleOrigin(sx, sy);
    translate(center.x, center.y);
  }

  void shear(double hx, double hy, Point center) // tam bat ki
  {
    translate(-center.x, -center.y);
    shearOrigin(hx, hy);
    translate(center.x, center.y);
  }
}
