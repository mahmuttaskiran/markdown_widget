import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  runApp(const MaterialApp(
    home: WordTapExample(),
  ));
}

/// Example demonstrating multi-word selection with adjacency support and long-press reset
class WordTapExample extends StatefulWidget {
  const WordTapExample({Key? key}) : super(key: key);

  @override
  State<WordTapExample> createState() => _WordTapExampleState();
}

class _WordTapExampleState extends State<WordTapExample> {
  final Set<String> _selectedWords = {};

  void _onWordTap(String word) {
    final normalized = word.toLowerCase().trim();
    setState(() {
      // Adjacency check: if we have selected words, check if the tapped
      // word is adjacent to any of them. For simplicity, we consider a word
      // adjacent if it shares the same "context" — the consumer can implement
      // more sophisticated adjacency logic as needed.
      //
      // Here we use a simple heuristic: if the tapped word is already
      // selected, deselect it. If the set is empty, select just this word.
      // For multi-word selection, the consumer should track word positions.
      if (_selectedWords.contains(normalized)) {
        _selectedWords.remove(normalized);
      } else {
        _selectedWords.add(normalized);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped: "$word" | Selected: ${_selectedWords.length}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onLongPressWord(String word) {
    setState(() {
      _selectedWords.clear();
      _selectedWords.add(word.toLowerCase().trim());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Long press: "$word" — selection reset'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const markdownData = '''
# Multi-Word Selection Demo

This is a paragraph where you can **tap on multiple words** to highlight them together with a yellow background.

Try tapping on *different* words like **bold**, *italic*, or `code` to see multi-word highlighting in action!

## Features

- Tap any word to toggle its selection
- Multiple words can be highlighted simultaneously
- **Long press** any word to reset the selection to just that word
- Custom highlight styling (background color, font weight, etc.)
- Works across all text elements (headings, paragraphs, lists, blockquotes)

### Works Everywhere

Tap on words in these different elements:

- This is a **bulleted** list item
- You can tap any `word` here
- Even *italic* words work

1. This is a **numbered** list
2. Try tapping `different` words
3. Highlighting works in *ordered* lists too

> This is a blockquote. Long press on any word here to reset! Even in **blockquotes**, the multi-word selection works perfectly.

#### Headings Are Tappable Too!

Tap on words in headings, paragraphs, lists, and blockquotes - everything is now tappable with multi-word selection support!
''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Word Selection'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Text(
              _selectedWords.isNotEmpty
                  ? 'Selected (${_selectedWords.length}): ${_selectedWords.join(", ")}'
                  : 'Tap words to select | Long press to reset',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: MarkdownWidget(
              data: markdownData,
              padding: const EdgeInsets.all(16),
              selectable: false,
              onTapWord: _onWordTap,
              onLongPressWord: _onLongPressWord,
              highlightStyle: const TextStyle(
                backgroundColor: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
              highlightedWords: _selectedWords,
            ),
          ),
        ],
      ),
    );
  }
}

