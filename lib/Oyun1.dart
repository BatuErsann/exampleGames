import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: PuzzleGame(),
  ));
}

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({Key? key}) : super(key: key);

  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  List<int> arr = List.generate(16, (index) => index)..shuffle();

  void restartGame() {
    setState(() {
      arr.shuffle();
    });
  }

  void checkWin() {
    bool isWin = true;
    for (int i = 0; i < arr.length; i++) {
      if (arr[i] != i) {
        isWin = false;
        break;
      }
    }
    if (isWin) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: const Text('You have successfully completed the puzzle!'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Play Again'),
                onPressed: () {
                  Navigator.of(context).pop();
                  restartGame();
                },
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
      appBar: AppBar(title: const Text('Puzzle Game')),
      body: GridView.builder(
        itemCount: 16,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemBuilder: (context, index) {
          return Draggable<int>(
            data: arr[index],
            feedback: Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              child: Image.asset('assets/imageonline/card${arr[index]}.png'),
            ),
            childWhenDragging: Container(),
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(2),
                  child: Image.asset('assets/imageonline/card${arr[index]}.png'),
                );
              },
              onWillAccept: (data) => true,
              onAccept: (data) {
                setState(() {
                  int dataIndex = arr.indexOf(data!);
                  arr[dataIndex] = arr[index];
                  arr[index] = data;
                  checkWin();
                });
              },
            ),
          );
        },
      ),
    );
  }
}
