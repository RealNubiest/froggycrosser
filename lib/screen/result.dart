import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';

class Result extends StatefulWidget {
  final int score;
  final int frogs;
  const Result(this.score, this.frogs, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _ResultState();
  }
}

class _ResultState extends State<Result> with SingleTickerProviderStateMixin {
  bool _isNewHighScore = false;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
    saveScore();
  }

  Future<void> saveScore() async {
    bool isNew = await checkTopPoint(widget.score, widget.frogs);
    if (!mounted) return;
    setState(() {
      _isNewHighScore = isNew;
    });
  }

  String getTitle() {
    if (widget.frogs >= 5) {
      return 'Apex Amphibian';
    } else if (widget.frogs == 4) {
      return 'Highway Navigator';
    } else if (widget.frogs == 3) {
      return 'Agile Hopper';
    } else if (widget.frogs == 2) {
      return 'Pond Explorer';
    } else if (widget.frogs == 1) {
      return 'Daring Tadpole';
    } else {
      return 'Unlucky Amphibian';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: const Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'WAKTU HABIS!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Skor Akhir: ${widget.score}',
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                'Katak Diseberangkan: ${widget.frogs}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  getTitle(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              if (_isNewHighScore)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'NEW HIGH SCORE!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  context.pushReplacement('/game');
                },
                child: const Text('Play Again'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.push('/highscore');
                },
                child: const Text('High Scores'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('Main Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
