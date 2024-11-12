import 'package:flutter/services.dart';

class TokenAmountInputFormatter extends TextInputFormatter {
  String removeNotAllowedCharacters(String from) {
    RegExp notAllowed = RegExp(r'[^0-9.]');

    String formattedString = from.replaceAll(",", '.').replaceAll(notAllowed, '');
    if (".".allMatches(formattedString).length > 1) formattedString = formattedString.replaceFirst(".", "");

    return formattedString;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    TextEditingValue formattedText = TextEditingValue(text: removeNotAllowedCharacters(newValue.text));

    return formattedText.copyWith(
      selection: TextSelection.collapsed(
        offset: newValue.selection.baseOffset.clamp(0, formattedText.text.length),
      ),
    );
  }
}
