import 'package:flutter/material.dart';
import 'information_page.dart';
import 'game_screen.dart';
import 'package:audioplayers/audioplayers.dart';

// Global player
final AudioPlayer _audioPlayer = AudioPlayer();

class StartMenuPage extends StatefulWidget {
  const StartMenuPage({Key? key}) : super(key: key);

  @override
  State<StartMenuPage> createState() => _StartMenuPageState();
}

class _StartMenuPageState extends State<StartMenuPage> {
  bool _isMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_isMusicPlaying) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource('sounds/gamemusic.mp3'));
        setState(() {
          _isMusicPlaying = true;
        });
      }
    });
  }

  Future<void> _toggleMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/gamemusic.mp3'));
    }
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/snake_cover.jpeg',
            fit: BoxFit.cover,
          ),

          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InformationPage()),
                );
              },
            ),
          ),
          Positioned(
            top: 30,
            right: 10,
            child: IconButton(
              icon: Icon(
                _isMusicPlaying ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _toggleMusic,
            ),
          ),
          Positioned(
            bottom: 170,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _audioPlayer.stop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                child: const Text("Start Game"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
