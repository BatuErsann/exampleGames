import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(PuzzleGame());
}

class PuzzleGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle Game',
      home: PuzzleBoard(),
    );
  }
}

class PuzzleBoard extends StatefulWidget {
  @override
  _PuzzleBoardState createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> {
  late List<int> puzzleTiles;
  late int emptyIndex;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    puzzleTiles = List.generate(16, (index) => index);
    emptyIndex = 15;
    shuffleTiles();
  }

  void shuffleTiles() {
    final random = Random();
    for (int i = puzzleTiles.length - 1; i > 0; i--) {
      int n = random.nextInt(i + 1);
      int temp = puzzleTiles[i];
      puzzleTiles[i] = puzzleTiles[n];
      puzzleTiles[n] = temp;
    }
    setState(() {});
  }

  void moveTile(int index) {
    if ((index - 1 == emptyIndex && (index % 4 != 0)) ||
        (index + 1 == emptyIndex && (emptyIndex % 4 != 0)) ||
        index - 4 == emptyIndex ||
        index + 4 == emptyIndex) {
      int temp = puzzleTiles[index];
      puzzleTiles[index] = puzzleTiles[emptyIndex];
      puzzleTiles[emptyIndex] = temp;
      emptyIndex = index;
      checkGameComplete();
      setState(() {});
    }
  }

  void checkGameComplete() {
    bool isComplete = true;
    for (int i = 0; i < puzzleTiles.length - 1; i++) {
      if (puzzleTiles[i] != i) {
        isComplete = false;
        break;
      }
    }
    if (isComplete) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content: Text('You solved the puzzle!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  startGame();
                },
                child: Text('Play Again'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Game'),
      ),
      body: GridView.builder(
        itemCount: 16,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              moveTile(index);
            },
            child: Container(
              margin: EdgeInsets.all(4),
              color:
                  puzzleTiles[index] == 15 ? Colors.transparent : Colors.blue,
              child: Center(
                child: Text(
                  '${puzzleTiles[index]}',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
