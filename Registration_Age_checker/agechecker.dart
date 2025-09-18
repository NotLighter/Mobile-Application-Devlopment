import 'dart:io';

void main() {
  // Step 1: Take name and age as input
  print("Enter your name: ");
  String name = stdin.readLineSync()!;

  print("Enter your age: ");
  int age = int.parse(stdin.readLineSync()!);

  if (age < 18) {
    print("Sorry $name, you are not eligible to register.");
    return; // Stop execution
  }

  // Step 2: Ask user how many numbers they want to enter
  stdout.write("How many numbers do you want to enter? ");
  int n = int.parse(stdin.readLineSync()!);

  List<int> numbers = [];

  // Step 3: Take N numbers input
  for (int i = 0; i < n; i++) {
    stdout.write("Enter number ${i + 1}: ");
    int num = int.parse(stdin.readLineSync()!);
    numbers.add(num);
  }

  // Step 4: Calculate required results
  int sumEven = 0, sumOdd = 0;
  int largest = numbers[0];
  int smallest = numbers[0];

  for (int num in numbers) {
    if (num % 2 == 0) {
      sumEven += num;
    } else {
      sumOdd += num;
    }

    if (num > largest) largest = num;
    if (num < smallest) smallest = num;
  }

  // Step 5: Print results
  print("\nResults:");
  print("Sum of even numbers: $sumEven");
  print("Sum of odd numbers: $sumOdd");
  print("Largest number: $largest");
  print("Smallest number: $smallest");
}
