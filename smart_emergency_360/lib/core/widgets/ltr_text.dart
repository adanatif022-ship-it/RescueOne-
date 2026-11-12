import 'package:flutter/material.dart';

/// Text that always reads left-to-right - for phone numbers, coordinates
/// and incident numbers. In the Arabic (RTL) interface "+967777123456"
/// would otherwise render as "967777123456+".
class LtrText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const LtrText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textDirection: TextDirection.ltr,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Wraps [text] in Unicode left-to-right isolate marks so it keeps its
/// order when embedded inside a longer Arabic sentence.
String ltrIsolate(String text) => '\u2066$text\u2069';
