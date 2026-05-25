import 'package:flutter/material.dart';

///the basic node
abstract class SpanNode {
  InlineSpan build();

  SpanNode? _parent;

  TextStyle? style;

  TextStyle? get parentStyle => _parent?.style;

  SpanNode? get parent => _parent;

  ///use [_acceptParent] to accept a parent
  void _acceptParent(SpanNode node) {
    _parent = node;
    onAccepted(node);
  }

  ///when this node was accepted by it's parent, [onAccepted] will be triggered
  void onAccepted(SpanNode parent) {}
}

///this node will accept other SpanNode as children
abstract class ElementNode extends SpanNode {
  final List<SpanNode> children = [];

  ///use [accept] to add a child
  void accept(SpanNode? node) {
    if (node != null) children.add(node);
    node?._acceptParent(this);
  }

  @override
  InlineSpan build() => childrenSpan;

  TextSpan get childrenSpan => TextSpan(
      children:
          List.generate(children.length, (index) => children[index].build()));
}

///the default concrete node for ElementNode
class ConcreteElementNode extends ElementNode {
  final String tag;

  ConcreteElementNode({this.tag = '', TextStyle? style}) {
    this.style = style ?? const TextStyle();
  }

  @override
  InlineSpan build() => childrenSpan;
}

///text node only displays text
class TextNode extends SpanNode {
  final String text;

  TextNode({this.text = '', TextStyle? style}) {
    this.style = style ?? const TextStyle();
  }

  @override
  InlineSpan build() => TextSpan(text: text, style: style?.merge(parentStyle));
}

///text node that supports word-level tap detection with adjacency-aware multi-selection
class TappableTextNode extends SpanNode {
  final String text;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final TextStyle? highlightStyle;
  final Set<String>? highlightedWords;

  TappableTextNode({
    this.text = '',
    TextStyle? style,
    this.onSelectionChanged,
    this.highlightStyle,
    this.highlightedWords,
  }) {
    this.style = style ?? const TextStyle();
  }

  /// Cached ordered list of word parts (non-whitespace) from the text
  List<String>? _orderedWords;

  List<String> get _words {
    _orderedWords ??= splitTextWithSpaces(text)
        .where((p) => p.trim().isNotEmpty)
        .toList();
    return _orderedWords!;
  }

  /// Shared flattened word list from the parent element, enabling cross-node
  /// adjacency when styled segments (bold, italic, code) create separate
  /// TappableTextNode instances within the same paragraph or list item.
  List<String>? parentWordContext;

  /// Where this node's words begin in [parentWordContext].
  int wordContextStartIndex = 0;

  @override
  InlineSpan build() {
    if (onSelectionChanged == null) {
      return TextSpan(text: text, style: style?.merge(parentStyle));
    }

    final parts = splitTextWithSpaces(text);
    final List<InlineSpan> spans = [];

    for (final part in parts) {
      if (part.trim().isEmpty) {
        spans.add(TextSpan(text: part, style: style?.merge(parentStyle)));
      } else {
        spans.add(_createTappableWordSpan(part));
      }
    }

    return TextSpan(children: spans);
  }

  /// Handles a word tap with adjacency logic:
  /// - If the tapped word is adjacent (immediately before/after) any
  ///   currently selected word in this text node, it adds to the selection.
  /// - Otherwise, replaces the selection with just the tapped word.
  void _handleWordTap(String word) {
    final currentSelection = highlightedWords ?? <String>{};
    if (onSelectionChanged == null) return;

    if (currentSelection.isEmpty) {
      onSelectionChanged!({word});
      return;
    }

    final bool isAdjacent = _isAdjacentToSelection(word, currentSelection);

    if (isAdjacent) {
      final newSelection = Set<String>.from(currentSelection)..add(word);
      onSelectionChanged!(newSelection);
    } else {
      onSelectionChanged!({word});
    }
  }

  /// Handles a long press: resets selection to just the pressed word
  void _handleLongPress(String word) {
    onSelectionChanged?.call({word});
  }

  /// Checks if [word] is positionally adjacent to any word in [selection].
  /// Uses [parentWordContext] (the parent's flattened word list) when set,
  /// falling back to the local [_words] list.
  bool _isAdjacentToSelection(String word, Set<String> selection) {
    final context = parentWordContext ?? _words;
    final wordIndex = context.indexOf(word);
    if (wordIndex == -1) return false;

    for (final selected in selection) {
      final selectedIndex = context.indexOf(selected);
      if (selectedIndex != -1 && (selectedIndex - wordIndex).abs() == 1) {
        return true;
      }
    }
    return false;
  }

  /// Splits text into words and spaces, preserving all whitespace
  List<String> splitTextWithSpaces(String text) {
    final List<String> parts = [];
    final RegExp wordPattern = RegExp(r'\S+|\s+');
    final matches = wordPattern.allMatches(text);

    for (final match in matches) {
      parts.add(match.group(0)!);
    }

    return parts;
  }

  WidgetSpan _createTappableWordSpan(String word) {
    final normalized = word.toLowerCase().trim();
    final isHighlighted = highlightedWords != null &&
        highlightedWords!.any((w) => w.toLowerCase().trim() == normalized);

    final baseStyle = style?.merge(parentStyle);
    final effectiveStyle = isHighlighted && highlightStyle != null
        ? baseStyle?.merge(highlightStyle!)
        : baseStyle;

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleWordTap(word),
        onLongPress: () => _handleLongPress(word),
        child: Text(word, style: effectiveStyle),
      ),
    );
  }

  /// Injects a shared word context into all [TappableTextNode] descendants
  /// of [element], enabling cross-node adjacency detection for styled text
  /// segments (bold, italic, code) that exist in separate sibling nodes.
  static void injectWordContext(ElementNode element) {
    final tappableNodes = <TappableTextNode>[];
    _collectTappableTextNodes(element, tappableNodes);

    if (tappableNodes.length <= 1) return;

    final allWords = <String>[];
    for (final node in tappableNodes) {
      node.wordContextStartIndex = allWords.length;
      allWords.addAll(node._words);
    }

    for (final node in tappableNodes) {
      node.parentWordContext = allWords;
    }
  }

  static void _collectTappableTextNodes(
      SpanNode node, List<TappableTextNode> result) {
    if (node is TappableTextNode) {
      result.add(node);
    } else if (node is ElementNode) {
      for (final child in node.children) {
        _collectTappableTextNodes(child, result);
      }
    }
  }
}
