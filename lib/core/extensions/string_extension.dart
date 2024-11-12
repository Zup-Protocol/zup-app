extension StringExtension on String {
  bool get isEmptyOrZero => isEmpty || this == "0";

  bool get isNotEmptyOrZero => !isEmptyOrZero;
}
