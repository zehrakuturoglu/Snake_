import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart'; // Klavye dinlemek için şart
import 'package:flutter/foundation.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({Key? key}) : super(key: key);

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  late VideoPlayerController _controller;
  late AudioPlayer _audioPlayer;
  final FocusNode _focusNode = FocusNode(); // Enter basınca çıkmak için

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Ses dosyasını yüklerken hata yakala
    _audioPlayer.play(AssetSource('sounds/gameover.mp3')).catchError((error) {
      debugPrint('Ses oynatılırken hata: $error');
    });

    // Video başlatma
    _controller = VideoPlayerController.asset('assets/video/snakevideo.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      }).catchError((error) {
        debugPrint('Video başlatılamadı: $error');
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }


  @override
  void dispose() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    }
    _controller.dispose();
    _audioPlayer.stop(); // Aktif sesi durdur
    _audioPlayer.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.pop(context);
            }

          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            _controller.value.isInitialized
                ? VideoPlayer(_controller)
                : Container(color: Colors.black),
            Container(
              color: Colors.black.withAlpha((0.5 * 255).toInt()), // Hafif karartı
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Game Over',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20), // Game Over ile Push Enter arası boşluk
                  Text(
                    defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS
                        ? 'Tap to return'
                        : 'Press Enter',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
