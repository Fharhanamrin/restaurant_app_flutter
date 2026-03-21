import 'package:test/test.dart';

void main() {
  test('Ekspektasi variabel result bernilai Result(0)', () {
    final result = Result(0);
    expect(result, equals(Result(0)));
  });
}

class Result {
  final int value;

  Result(this.value);
  @override
  bool operator ==(covariant Result other) {
    if (identical(this, other)) return true;
    return other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
