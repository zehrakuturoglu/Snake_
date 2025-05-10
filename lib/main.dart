import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'start_menu.dart';
import 'information_page.dart';

void main() {
  runApp(const SnakeGame());
}

class SnakeGame extends StatelessWidget {
  const SnakeGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartMenuPage(),
        '/game': (context) => const GameScreen(),
        '/settings': (context) => const InformationPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
