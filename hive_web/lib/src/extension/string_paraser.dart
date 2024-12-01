import 'package:flutter/material.dart';

extension StringParserExtension on String {
  RichText toRichText({
    int indentLevel = 0,
    TextStyle? textStyle,
    Color classColor = Colors.blue,
    FontWeight valueWeight = FontWeight.bold,
  }) {
    final List<TextSpan> children = [];
    final indent = '     ' * indentLevel; // 5 spacji jako tabulatory

    final headerMatch = RegExp(r'^(\w+)\s*\{').firstMatch(this);
    if (headerMatch != null) {
      children.add(TextSpan(
        text: '$indent${headerMatch.group(1)}\n',
        style: textStyle?.copyWith(color: classColor) ??
            TextStyle(
              fontWeight: FontWeight.bold,
              color: classColor,
            ),
      ));
      final remainingText = substring(headerMatch.end).trim();
      children.addAll(
        remainingText._toTextSpans(
          indentLevel: indentLevel + 1,
          textStyle: textStyle,
          classColor: classColor,
          valueWeight: valueWeight,
        ),
      );
    } else {
      children.addAll(
        _toTextSpans(
          indentLevel: indentLevel,
          textStyle: textStyle,
          classColor: classColor,
          valueWeight: valueWeight,
        ),
      );
    }

    return RichText(
      text: TextSpan(children: children, style: textStyle),
    );
  }
}

extension _TextSpanHelper on String {
  List<TextSpan> _toTextSpans({
    int indentLevel = 0,
    TextStyle? textStyle,
    Color classColor = Colors.blue,
    FontWeight valueWeight = FontWeight.bold,
  }) {
    final List<TextSpan> children = [];
    final indent = '     ' * indentLevel;

    final keyValuePairRegExp =
        RegExp(r'(\w+):\s*([^,{}[\]]+|\{[^{}]*\}|\[[^\[\]]*\])');
    final matches = keyValuePairRegExp.allMatches(this);

    for (final match in matches) {
      final key = match.group(1)!;
      final value = match.group(2)!;

      if (value.startsWith('{')) {
        children.add(TextSpan(
          text: '$indent$key:\n',
          style: textStyle,
        ));
        children.addAll(
          value._toTextSpans(
            indentLevel: indentLevel + 1,
            textStyle: textStyle,
            classColor: classColor,
            valueWeight: valueWeight,
          ),
        );
      } else if (value.startsWith('[')) {
        children.add(TextSpan(
          text: '$indent$key: [\n',
          style: textStyle,
        ));
        final items = _extractListItems(value);
        for (final item in items) {
          if (item.startsWith('{')) {
            children.addAll(
              item._toTextSpans(
                indentLevel: indentLevel + 2,
                textStyle: textStyle,
                classColor: classColor,
                valueWeight: valueWeight,
              ),
            );
          } else {
            children.add(TextSpan(
              text: '${'     ' * (indentLevel + 2)}$item\n',
              style: textStyle?.copyWith(fontWeight: valueWeight),
            ));
          }
        }
        children.add(TextSpan(
          text: '$indent]\n',
          style: textStyle,
        ));
      } else {
        final valueStyle = textStyle?.copyWith(fontWeight: valueWeight) ??
            const TextStyle(fontWeight: FontWeight.bold);

        children.add(TextSpan(
          text: '$indent$key: ',
          style: textStyle,
        ));

        if (RegExp(r'^\w+\s*\{').hasMatch(value)) {
          // Jeśli wartość jest obiektem, kolorujemy jako klasę
          children.add(TextSpan(
            text: '$value\n',
            style: textStyle?.copyWith(color: classColor) ??
                TextStyle(color: classColor),
          ));
        } else {
          // Zwykła wartość
          children.add(TextSpan(
            text: '$value\n',
            style: valueStyle,
          ));
        }
      }
    }

    return children;
  }

  List<String> _extractListItems(String listString) {
    final items = <String>[];
    int bracketBalance = 0;
    final buffer = StringBuffer();

    for (int i = 1; i < listString.length - 1; i++) {
      final char = listString[i];

      if (char == ',' && bracketBalance == 0) {
        items.add(buffer.toString().trim());
        buffer.clear();
      } else {
        if (char == '{') bracketBalance++;
        if (char == '}') bracketBalance--;
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      items.add(buffer.toString().trim());
    }

    return items;
  }
}
