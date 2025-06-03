import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('How to Play'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "🎮 CONTROLS",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text("- ↑ Arrow Up → Move up", style: TextStyle(color: Colors.white)),
              Text("- ↓ Arrow Down → Move down", style: TextStyle(color: Colors.white)),
              Text("- ← Arrow Left → Move left", style: TextStyle(color: Colors.white)),
              Text("- → Arrow Right → Move right", style: TextStyle(color: Colors.white)),
              Text("- Enter → Boost speed", style: TextStyle(color: Colors.white)),

              SizedBox(height: 30),
              Text(
                "🐍 GAMEPLAY",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                "- Control the snake using your keyboard.",
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                "- Eat food to grow and earn points.",
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                "- Avoid hitting the wall or yourself.",
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 30),
              Text(
                "🔴 PRESS ESC TO RETURN TO THE MAIN MENU",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InformationScreen extends StatefulWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Ekran geldikten sonra otomatik odak alması için
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.pop(context); // ESC tuşu ile geri dön
            }
          }
        },
        child: const InformationPage(),
      ),
    );
  }
}
