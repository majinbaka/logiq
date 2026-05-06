import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormattedNumberInput extends StatefulWidget {
  const FormattedNumberInput({
    super.key,
    required this.controller,
    required this.label,
    required this.requiredErrorText,
    required this.numberErrorText,
    required this.positiveNumberErrorText,
    required this.nonNegativeNumberErrorText,
    this.suffixText,
    this.required = false,
    this.mustBePositive = false,
    this.nonNegative = false,
    this.customValidator,
  });

  final TextEditingController controller;
  final String label;
  final String requiredErrorText;
  final String numberErrorText;
  final String positiveNumberErrorText;
  final String nonNegativeNumberErrorText;
  final String? suffixText;
  final bool required;
  final bool mustBePositive;
  final bool nonNegative;
  final String? Function(String? value)? customValidator;

  static String normalizeNumberText(String value) {
    return value.replaceAll(',', '').trim();
  }

  @override
  State<FormattedNumberInput> createState() => _FormattedNumberInputState();
}

class _FormattedNumberInputState extends State<FormattedNumberInput> {
  static const _formatter = _ThousandsSeparatorFormatter();
  bool _isApplyingFormat = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _formatControllerText();
  }

  @override
  void didUpdateWidget(covariant FormattedNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
    _formatControllerText();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    _formatControllerText();
  }

  void _formatControllerText() {
    if (_isApplyingFormat) return;
    final current = widget.controller.value;
    final formatted = _formatter.formatEditUpdate(
      const TextEditingValue(text: ''),
      current,
    );
    if (formatted.text == current.text) return;
    _isApplyingFormat = true;
    widget.controller.value = formatted;
    _isApplyingFormat = false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: const [_ThousandsSeparatorFormatter()],
      decoration: InputDecoration(
        labelText: widget.label,
        suffixText: widget.suffixText,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        final text = FormattedNumberInput.normalizeNumberText(value ?? '');
        if (text.isEmpty) {
          if (widget.required) return widget.requiredErrorText;
          return null;
        }
        if (num.tryParse(text) == null) {
          return widget.numberErrorText;
        }
        final parsed = num.parse(text);
        if (widget.mustBePositive && parsed <= 0) {
          return widget.positiveNumberErrorText;
        }
        if (widget.nonNegative && parsed < 0) {
          return widget.nonNegativeNumberErrorText;
        }
        return widget.customValidator?.call(value);
      },
    );
  }
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  const _ThousandsSeparatorFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final normalized = _normalize(raw);
    final parts = normalized.split('.');
    final whole = parts.first;
    final decimal = parts.length > 1 ? parts.last : null;
    final grouped = _groupThousands(whole);
    final formatted = decimal == null ? grouped : '$grouped.$decimal';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _normalize(String input) {
    final sb = StringBuffer();
    var hasDot = false;
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      if (char == '.') {
        if (hasDot) continue;
        hasDot = true;
        sb.write(char);
        continue;
      }
      if (_isDigit(char)) {
        sb.write(char);
      }
    }

    var value = sb.toString();
    if (value.startsWith('.')) value = '0$value';
    if (!value.contains('.')) {
      return _stripLeadingZeros(value);
    }

    final parts = value.split('.');
    final whole = _stripLeadingZeros(parts.first);
    final decimal = parts.last;
    return '$whole.$decimal';
  }

  String _stripLeadingZeros(String value) {
    final stripped = value.replaceFirst(RegExp(r'^0+'), '');
    return stripped.isEmpty ? '0' : stripped;
  }

  bool _isDigit(String char) {
    return char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  }

  String _groupThousands(String value) {
    final rev = value.split('').reversed.toList(growable: false);
    final out = <String>[];
    for (var i = 0; i < rev.length; i++) {
      if (i > 0 && i % 3 == 0) out.add(',');
      out.add(rev[i]);
    }
    return out.reversed.join();
  }
}
