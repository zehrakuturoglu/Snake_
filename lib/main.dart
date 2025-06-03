import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'start_menu.dart';
import 'information_page.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();//sayfa (route) geçişlerini dinlemek için kullanılır.
void main() {
  runApp(
      const SnakeGame());
}
class SnakeGame extends StatelessWidget {
  const SnakeGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData.dark(),
      initialRoute: '/',
      navigatorObservers: [routeObserver],
      routes: {
        '/': (context) => const StartMenuPage(),
        '/game': (context) =>  GameScreen(playerName: 'UserName'),
        '/settings': (context) => const InformationPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
