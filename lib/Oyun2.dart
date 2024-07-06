import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameScene extends StatefulWidget {
  @override
  _GameSceneState createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> {
  List<Map<String, dynamic>> objectPositions = [];
  Offset characterPosition = Offset(0.5, 0.9);
  int score = 0;
  bool gameOver = false;
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
    objectPositions.clear();
    objectTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!gameOver) {
        addObjects(); // İlaçlar ve zehirler ekleyelim
      } else {
        timer.cancel();
      }
    });
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!gameOver) {
        moveObjects();
        checkCollision();
        if (mounted) {
          setState(() {});
        }
      } else {
        timer.cancel();
      }
    });
  }

  void addObjects() {
    double randomX = Random().nextDouble();
    bool isPoison = Random().nextBool();
    objectPositions.add({'position': Offset(randomX, 0), 'isPoison': isPoison});
  }

  void moveObjects() {
    for (int i = 0; i < objectPositions.length; i++) {
      if (mounted) {
        setState(() {
          objectPositions[i]['position'] = Offset(
            objectPositions[i]['position'].dx,
            objectPositions[i]['position'].dy + objectSpeed,
          );
        });
      }
    }

    // Yere düşen ilaçların ve zehirlerin kaldırılması
    objectPositions.removeWhere((element) => element['position'].dy >= 1.0);
  }

  void checkCollision() {
    bool collided = false;
    for (int i = 0; i < objectPositions.length; i++) {
      double distance = (characterPosition.dx - objectPositions[i]['position'].dx).abs() + (characterPosition.dy - objectPositions[i]['position'].dy).abs();
      double collisionTolerance = 0.08;
      if (distance < collisionTolerance) {
        if (mounted) {
          setState(() {
            if (objectPositions[i]['isPoison']) {
              score -= 5; // Zehir -5 puan
            } else {
              score += 1; // İlaç +1 puan
            }
            objectPositions.removeAt(i);
          });
        }
        collided = true;
        break;
      }
    }

    if (!collided) {
      if (objectPositions.isNotEmpty && objectPositions.last['position'].dy > 1.0) {
        objectPositions.removeLast();
      }
    }

    if (score >= 30) {
      if (mounted) {
        setState(() {
          gameOver = true;
        });
      }
      showGameOverDialog();
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('You won the game! Your score: $score'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
              child: const Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
              color: Color.fromARGB(255, 204, 204, 204),
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
              .map(
                (position) => Positioned(
                  left: (position['position'].dx * MediaQuery.of(context).size.width).clamp(0.0, MediaQuery.of(context).size.width - 30.0),
                  top: (position['position'].dy * MediaQuery.of(context).size.height).clamp(0.0, MediaQuery.of(context).size.height - 30.0),
                  child: Image.asset(
                    position['isPoison'] ? 'assets/poison_icon.png' : 'assets/pill_icon.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              )
              .toList(),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05, // Skor bari biraz daha aşağıda olacak
            left: 20,
            right: 20, // Bari genişletiyoruz
            child: Container(
              height: 40, // Barın yüksekliğini artırıyoruz
              child: LinearProgressIndicator(
                value: score / 30.0,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 146, 219, 29)),
                minHeight: 20, // Çubuğun minimum yüksekliğini artırıyoruz
              ),
            ),
          ),
        ],
      ),
    );
  }
}
