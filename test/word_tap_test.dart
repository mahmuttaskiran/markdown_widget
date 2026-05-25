import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/widget/span_node.dart';

void main() {
  group('TappableTextNode', () {
    test('should create tappable spans for words', () {
      final node = TappableTextNode(
        text: 'Hello world test',
        onTapWord: (word) {},
      );

      final span = node.build() as TextSpan;

      expect(span.children, isNotNull);
      expect(span.children!.length, greaterThan(0));
    });

    test('should split text correctly preserving whitespace', () {
      final node = TappableTextNode(
        text: 'Hello  world\ttest\n',
        onTapWord: (word) {},
      );

      final parts = node.splitTextWithSpaces('Hello  world\ttest\n');

      expect(parts, [
        'Hello',
        '  ',
        'world',
        '\t',
        'test',
        '\n',
      ]);
    });

    test('should handle punctuation in words', () {
      final node = TappableTextNode(
        text: 'Hello, world! How are you?',
        onTapWord: (word) {},
      );

      final parts = node.splitTextWithSpaces('Hello, world! How are you?');

      expect(parts, [
        'Hello,',
        ' ',
        'world!',
        ' ',
        'How',
        ' ',
        'are',
        ' ',
        'you?',
      ]);
    });

    test('should fallback to regular TextSpan when no callbacks', () {
      final node = TappableTextNode(
        text: 'Hello world',
        onTapWord: null,
        onLongPressWord: null,
      );

      final span = node.build() as TextSpan;

      expect(span.children, isNull);
      expect(span.toPlainText(), equals('Hello world'));
    });

    test('should create WidgetSpan children when tap callback is set', () {
      final node = TappableTextNode(
        text: 'Hello world',
        onTapWord: (word) {},
      );

      final span = node.build() as TextSpan;
      expect(span.children, isNotNull);

      // Should have WidgetSpan for words and TextSpan for whitespace
      final hasWidgetSpan = span.children!.any((c) => c is WidgetSpan);
      expect(hasWidgetSpan, isTrue);
    });

    test('should highlight multiple words from highlightedWords set', () {
      final node = TappableTextNode(
        text: 'Hello world',
        onTapWord: (word) {},
        highlightedWords: {'hello', 'world'},
        highlightStyle: const TextStyle(backgroundColor: Color(0xFFFFFF00)),
      );

      final span = node.build() as TextSpan;
      expect(span.children, isNotNull);

      // Both words should be WidgetSpans (tappable + highlighted)
      final widgetSpans = span.children!.whereType<WidgetSpan>().toList();
      expect(widgetSpans.length, equals(2));
    });

    test('should support long press callback', () {
      final node = TappableTextNode(
        text: 'Hello world',
        onTapWord: (word) {},
        onLongPressWord: (word) {},
      );

      final span = node.build() as TextSpan;
      expect(span.children, isNotNull);

      // Verify WidgetSpans have GestureDetector with onLongPress
      final widgetSpans = span.children!.whereType<WidgetSpan>().toList();
      expect(widgetSpans.isNotEmpty, isTrue);

      final firstWordSpan = widgetSpans.first;
      final gestureDetector = firstWordSpan.child as GestureDetector;
      expect(gestureDetector.onLongPress, isNotNull);
    });
  });
}