import 'dart:math';

// Base class
class Shape {
  double area() => 0;
  double circumference() => 0;

  Shape() {
    print("Shape constructor called");
  }
}

// Circle class extending Shape
class Circle extends Shape {
  double radius;

  // Constructor using sugar syntax with call to super
  Circle(this.radius) : super();

  // Override area
  @override
  double area() => pi * radius * radius;

  // Override circumference
  @override
  double circumference() => 2 * pi * radius;
}

void main() {
  // Create Circle object

  Circle c = Circle(5.0);

  print("Circle with radius: ${c.radius}");
  print("Area: ${c.area()}");
  print("Circumference: ${c.circumference()}");
}
