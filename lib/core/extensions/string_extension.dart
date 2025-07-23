extension StringExtension on String {
  bool get isEmptyOrZero => isEmpty || num.tryParse(this) == 0;

  bool get isNotEmptyOrZero => !isEmptyOrZero;
}
