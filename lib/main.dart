import 'package:flutter/material.dart';
import 'MemoryGame.dart';
import 'Oyun2.dart'; // Oyun 2 için GameScene dosyasını içe aktarın
import 'Oyun1.dart';

void main() {
  runApp(MaterialApp(
    home: OyunSecimEkrani(),
  ));
}

class OyunSecimEkrani extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Oyun Seçimi"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Oyun 1"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PuzzleGame(),
                ),
              );
            },
          ),
          ListTile(
            title: Text("Oyun 2"), // Yeni seçenek: Oyun 2
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GameScene()), // Oyun 2 ekranını aç
              );
            },
          ),
          ListTile(
            title: Text("Hafıza Oyunu"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MemoryGame()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class Oyun1 {}
