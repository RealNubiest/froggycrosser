import 'package:flutter/material.dart';
import 'package:froggycrosser/class/score.dart';
import '../main.dart';

class HighScore extends StatefulWidget {
  const HighScore({super.key});

  @override
  State<HighScore> createState() => _HighScoreState();
}

class _HighScoreState extends State<HighScore> {
  List<Score> topScores = [];

  @override
  void initState() {
    super.initState();
    loadHighScore();
  }

  Future<void> loadHighScore() async {
    List<Score> scores = await getHighScores();
    if (!mounted) return;
    setState(() {
      topScores = scores.take(3).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("High Score"),
      ),
      body: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            size: 100,
            color: Colors.amber,
          ),
          const Text(
            "TOP 3 SCORE",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (topScores.isEmpty) const Text("Belum ada data skor."),
          ...List.generate(topScores.length, (int i) {
            return scoreCard(i, topScores[i]);
          }),
        ],
      ),
    );
  }

  // Kartu skor dengan animasi slide + fade masuk satu per satu
  Widget scoreCard(int i, Score s) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + i * 250),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * 100, 0),
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        elevation: 4,
        child: ListTile(
          leading: Image.asset(
            'assets/images/rank${i + 1}.png',
            width: 50,
            height: 50,
          ),
          title: Text(
            s.user,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${s.frogs} katak'),
          trailing: Text(
            '${s.point}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
