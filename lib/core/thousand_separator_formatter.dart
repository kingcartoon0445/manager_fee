import 'package:flutter/services.dart';

/// TextInputFormatter that adds thousand separators (.) to numbers
/// Example: 1000 -> 1.000, 1000000 -> 1.000.000
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is empty, return it as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all existing dots to get the raw number
    String rawText = newValue.text.replaceAll('.', '');

    // If the result is not a valid number, reject the change
    if (rawText.isNotEmpty && int.tryParse(rawText) == null) {
      return oldValue;
    }

    // Format the number with thousand separators
    String formattedText = _formatWithThousandsSeparator(rawText);

    // Calculate the new cursor position
    int newOffset = _calculateCursorPosition(
      oldValue.text,
      newValue.text,
      formattedText,
      oldValue.selection.baseOffset,
      newValue.selection.baseOffset,
    );

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  /// Formats a number string with thousand separators
  String _formatWithThousandsSeparator(String number) {
    if (number.isEmpty) return '';

    // Reverse the string to make it easier to add separators
    String reversed = number.split('').reversed.join('');
    String formatted = '';

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted += '.';
      }
      formatted += reversed[i];
    }

    // Reverse back to get the final formatted string
    return formatted.split('').reversed.join('');
  }

  /// Calculates the correct cursor position after formatting
  int _calculateCursorPosition(
    String oldText,
    String newText,
    String formattedText,
    int oldOffset,
    int newOffset,
  ) {
    // If cursor is at the end, keep it at the end
    if (newOffset >= newText.length) {
      return formattedText.length;
    }

    // Count how many digits are before the cursor in the new unformatted text
    String newTextWithoutDots = newText.replaceAll('.', '');
    int digitsBeforeCursor = newTextWithoutDots
        .substring(0,
            newOffset - (newText.substring(0, newOffset).split('.').length - 1))
        .length;

    // Find the position in formatted text that has the same number of digits before it
    int digitCount = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (formattedText[i] != '.') {
        digitCount++;
      }
      if (digitCount == digitsBeforeCursor) {
        return i + 1;
      }
    }

    return formattedText.length;
  }

  /// Helper method to parse formatted number string back to double
  static double? parseFormattedNumber(String formattedText) {
    if (formattedText.isEmpty) return null;
    String rawText = formattedText.replaceAll('.', '');
    return double.tryParse(rawText);
  }
}
