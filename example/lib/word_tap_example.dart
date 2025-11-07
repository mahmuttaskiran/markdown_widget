import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  runApp(const MaterialApp(
    home: WordTapExample(),
  ));
}

/// Example demonstrating the onTapWord callback and word highlighting functionality
class WordTapExample extends StatefulWidget {
  const WordTapExample({Key? key}) : super(key: key);

  @override
  State<WordTapExample> createState() => _WordTapExampleState();
}

class _WordTapExampleState extends State<WordTapExample> {
  String? lastTappedWord;

  void _onWordTap(String word) {
    setState(() {
      lastTappedWord = word;
    });

    // Show a snackbar with the tapped word
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped word: "$word"'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const markdownData = '''
# Word Tap & Highlight Demo

This is a paragraph where you can **tap on any word** to see it highlighted with a yellow background.

Try tapping on *different* words like **bold**, *italic*, or `code` to see the highlighting in action!

## Features

- Tap any word in any markdown element to highlight it
- Custom highlight styling (background color, font weight, etc.)
- Preserves formatting (bold, italic, code)
- Maintains text layout and spacing
- Works with markdown links and other inline elements
- **NEW**: Word tapping now works in ALL text-containing elements!

### Works Everywhere

Tap on words in these different elements:

- This is a **bulleted** list item
- You can tap any `word` here
- Even *italic* words work

1. This is a **numbered** list
2. Try tapping `different` words
3. Highlighting works in *ordered* lists too

> This is a blockquote. Try tapping on any word here! Even in **blockquotes**, the word tap functionality works perfectly.

#### Headings Are Tappable Too!

Tap on words in headings, paragraphs, lists, and blockquotes - everything is now tappable with just a single configuration at the MarkdownWidget level!
''';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Tap Example'),
      ),
      body: Column(
        children: [
          // Status display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Text(
              lastTappedWord != null ? 'Last tapped word: "$lastTappedWord"' : 'Tap any word in the markdown below',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Markdown content with word tap functionality
          // Note: No custom config needed! Just pass the callbacks directly to MarkdownWidget
          Expanded(
            child: MarkdownWidget(
              data: markdownData,
              padding: const EdgeInsets.all(16),
              selectable: false,
              onTapWord: _onWordTap,
              highlightStyle: const TextStyle(
                backgroundColor: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
              highlightedWord: lastTappedWord,
            ),
          ),
        ],
      ),
    );
  }
}

