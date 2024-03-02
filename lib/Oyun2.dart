import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameScene extends StatefulWidget {
  @override
  _GameSceneState createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> {
  List<Offset> objectPositions = [];
  Offset characterPosition = Offset(0.5, 0.9);
  int score = 0;
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
    for (int i = 0; i < objectPositions.length; i++) {
      double distance = (characterPosition.dx - objectPositions[i].dx).abs() +
          (characterPosition.dy - objectPositions[i].dy).abs();
      // Tolerans değerini burada belirleyebiliriz, örneğin 0.05
      double collisionTolerance = 0.08;
      if (distance < collisionTolerance) {
        setState(() {
          objectPositions.removeAt(i);
          score++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
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
            color: Colors.white24,
            child: Align(
              alignment: Alignment(characterPosition.dx * 2 - 1, 1),
              child: Icon(Icons.face, size: 50, color: Colors.yellow),
            ),
          ),
        ),
        ...objectPositions
            .map((position) => Positioned(
                  left: position.dx * MediaQuery.of(context).size.width,
                  top: position.dy * MediaQuery.of(context).size.height,
                  child: Icon(Icons.star, size: 30, color: Colors.yellow),
                ))
            .toList(),
        Positioned(
          top: 10,
          left: 10,
          child: Text(
            'Score: $score',
            style: const TextStyle(
              fontSize: 20,
              color: Colors.red, // Puan rengini buradan ayarlayabilirsiniz
            ),
          ),
        ),
      ],
    );
  }
}




/*
Bu kod, karakterin x ve y konumlarını (Offset olarak),
nesnelerin x ve y konumlarını (Offset listesi olarak) tutar. Her zaman diliminde (Timer.periodic) karakterin ve nesnelerin pozisyonları güncellenir. Nesnelerin düşüş hızı ayarlanabilir (objectSpeed) ve karakterin hareket hızı ayarlanabilir (characterSpeed). checkCollision fonksiyonu karakterle nesneler arasındaki mesafeyi hesaplar ve çarpışma durumunda puanı artırır.
Son olarak, puan durumu ekranda sol üst köşede görüntülenir.
*/