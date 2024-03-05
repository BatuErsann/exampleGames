import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class MemoryGame extends StatefulWidget {
  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  List<bool> flipped = List<bool>.filled(18, false);
  List<bool> matched = List<bool>.filled(18, false);
  List<int> cardNumbers = List<int>.generate(18, (index) => index % 9);
  int firstIndex = -1;
  bool canFlip = true;
  bool allMatched = false;

  @override
  void initState() {
    super.initState();
    cardNumbers.shuffle();
  }

  void checkAllMatched() {
    setState(() {
      allMatched = matched.every((element) => element);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GridView.builder(
                    itemCount: 18,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        if (canFlip && !flipped[index]) {
                          setState(() {
                            flipped[index] = true;
                          });
                          if (firstIndex == -1) {
                            firstIndex = index;
                          } else {
                            canFlip = false;
                            if (cardNumbers[firstIndex] == cardNumbers[index]) {
                              // Match found
                              matched[firstIndex] = true;
                              matched[index] = true;
                              firstIndex = -1;
                              canFlip = true;
                              checkAllMatched();
                            } else {
                              // No match
                              Timer(Duration(seconds: 1), () {
                                setState(() {
                                  flipped[firstIndex] = false;
                                  flipped[index] = false;
                                  firstIndex = -1;
                                  canFlip = true;
                                });
                              });
                            }
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: (flipped[index] && matched[index])
                                ? Colors.green
                                : (flipped[index] ? Colors.red : Colors.blue),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: flipped[index]
                              ? Image.asset(
                                  'assets/images/card${cardNumbers[index]}.png',
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/bayes.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (allMatched)
            Container(
              color: Colors.transparent, // Arka planı saydam yapar
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 5, sigmaY: 5), // Arka planı bulanıklaştırır
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.black
                        .withOpacity(0.5), // Yarı saydam siyah bir arka plan
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Tebrikler Kazandınız!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Yeniden başlatmak için tüm değişkenleri sıfırla
                              flipped = List<bool>.filled(18, false);
                              matched = List<bool>.filled(18, false);
                              cardNumbers.shuffle();
                              firstIndex = -1;
                              canFlip = true;
                              allMatched = false;
                            });
                          },
                          child: const Text('Yeniden Başla'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
