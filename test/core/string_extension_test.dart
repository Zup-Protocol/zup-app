import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/extensions/string_extension.dart';

void main() {
  test("`isEmptyOrZero` should return true if the string is literally empty", () {
    expect("0".isEmptyOrZero, true);
  });

  test("`isEmptyOrZero` should return true if the string is equal to zero", () {
    expect("0".isEmptyOrZero, true);
  });

  test("`isNotEmptyOrZero` should return false if the string is literally empty", () {
    expect("".isNotEmptyOrZero, false);
  });

  test("`isNotEmptyOrZero` should return false if the string is equal to zero", () {
    expect("0".isNotEmptyOrZero, false);
  });
}
