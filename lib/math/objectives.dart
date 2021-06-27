class Vector {
  double B;
  double A;

  Vector([this.A = 0, this.B = 0]);
}

class Point {
  double x;
  double y;

  Point([this.x = 0.0, this.y = 0.0]);

  static Point zero = Point(0.0, 0.0);

  factory Point.fromMap(Map<String, dynamic> map) {
    return new Point(
      map['x'] as double,
      map['y'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'x': this.x,
      'y': this.y,
    } as Map<String, dynamic>;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

/// Ax + By + C = 0
class LineEquation {
  double A = 0;
  double B = 0;
  double C = 0;

  bool isNull() {
    bool ans = false;
    if (A == 0 && B == 0 && C == 0)
      ans = true;
    else if (A == 0 && B == 0)
      ans = true;
    else
      ans = false;
    return ans;
  }
}

class Polygon {
  final List<Point> vertices;

  Polygon(this.vertices) : assert(vertices != null);

  Point gravityCenter() {
    if (vertices.isEmpty) return Point(0, 0);
    double x = 0.0, y = 0.0;
    for (int i = 0; i < count; i++) {
      x += vertices[i].x;
      y += vertices[i].y;
    }
    return Point(x / count, y / count);
  }

  int get count => vertices.length;
}

class Circle {
  final Point center;
  final double R;

  Circle(this.center, this.R);
}
