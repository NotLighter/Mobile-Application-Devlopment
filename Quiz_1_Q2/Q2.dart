void main() {
  List<int> numbers = [7, 5, 2, 8, 4, 9];

  int sumOdd = 0;
  int smallest = numbers[0];

  for (int i = 0; i < 6; i++) {
    if (numbers[i] % 2 != 0) {
      sumOdd = sumOdd + numbers[i];
    }

    if (numbers[i] < smallest) {
      smallest = numbers[i];
    } else {
      // do nothing
    }
  }

  print("Sum of odd numbers: $sumOdd");
  print("Smallest number: $smallest");
}
