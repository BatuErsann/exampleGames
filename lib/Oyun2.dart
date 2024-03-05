import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class GameScene extends StatefulWidget {
  @override
  _GameSceneState createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> {
  List<Offset> objectPositions = [];
  Offset characterPosition = Offset(0.5, 0.9);
  int score = 0;
  int lives = 3; // Can sayısı
  bool gameOver = false;
  final double characterSpeed = 0.01;
  final double objectSpeed = 0.02;
  Timer? objectTimer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  void dispose() {
    objectTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    gameOver = false;
    score = 0;
    lives = 3; // Yeniden başlatıldığında canları sıfırla
    objectPositions.clear();
    objectTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (!gameOver) {
        addRandomObject();
      } else {
        timer.cancel();
      }
    });
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!gameOver) {
        moveCharacter();
        moveObjects();
        checkCollision();
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  void addRandomObject() {
    double randomX = Random().nextDouble();
    objectPositions.add(Offset(randomX, 0));
  }

  void moveCharacter() {
    if (characterPosition.dx < 0) {
      characterPosition = Offset(0, characterPosition.dy);
    }
    if (characterPosition.dx > 1) {
      characterPosition = Offset(1, characterPosition.dy);
    }
  }

  void moveObjects() {
    for (int i = 0; i < objectPositions.length; i++) {
      setState(() {
        objectPositions[i] = Offset(
          objectPositions[i].dx,
          objectPositions[i].dy + objectSpeed,
        );
      });
    }
  }

  void checkCollision() {
    bool collided = false;
    for (int i = 0; i < objectPositions.length; i++) {
      double distance = (characterPosition.dx - objectPositions[i].dx).abs() +
          (characterPosition.dy - objectPositions[i].dy).abs();
      double collisionTolerance = 0.08;
      if (distance < collisionTolerance) {
        setState(() {
          objectPositions.removeAt(i);
          score++;
        });
        collided = true;
        break; // Çarpışma varsa döngüyü sonlandır
      }
    }

    if (!collided) {
      if (objectPositions.isNotEmpty && objectPositions.last.dy > 1.0) {
        objectPositions.removeLast();
        if (lives > 0) {
          setState(() {
            lives--;
          });
          if (lives == 0) {
            gameOver = true;
            showGameOverDialog();
          }
        }
      }
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('You lost the game. Your score: $score'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
              child: Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.white, // Arka plan rengi
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              characterPosition += Offset(
                details.primaryDelta! / MediaQuery.of(context).size.width,
                0,
              );
            });
          },
          child: Container(
            color: const Color.fromARGB(255, 162, 155, 155),
            child: Align(
              alignment: Alignment(characterPosition.dx * 2 - 1, 0.8),
              child: Transform.scale(
                scale: 8.0, // Ölçek faktörü
                child: Image.asset(
                  'assets/hasta_icon.png', // Hasta simgesinin yolunu belirtin
                  width: 50, // Görüntü genişliği
                  height: 50, // Görüntü yüksekliği
                ),
              ),
            ),
          ),
        ),
        ...objectPositions
            .map((position) => Positioned(
                  left: position.dx * MediaQuery.of(context).size.width,
                  top: position.dy * MediaQuery.of(context).size.height,
                  child: Image.asset(
                    'assets/pill_icon.png', // İlaç simgesinin yolunu belirtin
                    width: 30,
                    height: 30,
                    // İsteğe bağlı olarak renk belirleyebilirsiniz
                  ),
                ))
            .toList(),
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            children: List.generate(
              lives,
              (index) => Icon(Icons.favorite, color: Colors.red),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Text(
            'Score: $score',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
