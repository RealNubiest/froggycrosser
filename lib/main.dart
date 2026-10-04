import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:froggycrosser/class/score.dart';
import 'package:froggycrosser/screen/game.dart';
import 'package:froggycrosser/screen/highscore.dart';
import 'package:froggycrosser/screen/home.dart';
import 'package:froggycrosser/screen/login.dart';
import 'package:froggycrosser/screen/result.dart';

GoRouter getAppRouter() {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: isLoggedIn,
    redirect: (context, state) {
      final login = state.uri.path == "/login";

      if (!isLoggedIn.value && !login) {
        return "/login";
      }

      if (isLoggedIn.value && login) {
        return "/";
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const Home()),
      GoRoute(path: '/login', builder: (context, state) => const Login()),
      GoRoute(path: '/game', name: 'game', builder: (context, state) => const Game()),
      GoRoute(
        path: '/result',
        name: 'result',
        builder: (context, state) {
          final score = int.tryParse(state.uri.queryParameters['score'] ?? '0') ?? 0;
          final frogs = int.tryParse(state.uri.queryParameters['frogs'] ?? '0') ?? 0;
          return Result(score, frogs);
        },
      ),
      GoRoute(path: '/highscore', name: 'highscore', builder: (context, state) => const HighScore()),
    ],
  );
}

// ignore: non_constant_identifier_names
String active_user = "";
final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);

Future<void> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  active_user = prefs.getString("user_id") ?? '';
  isLoggedIn.value = active_user.isNotEmpty;
}

void doLogout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("user_id");
  isLoggedIn.value = false;
}

// Mengambil semua high score (format JSON) dan mengurutkan dari yang tertinggi
Future<List<Score>> getHighScores() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> data = prefs.getStringList("high_scores") ?? [];
  List<Score> scores = data.map((s) => Score.fromJson(jsonDecode(s))).toList();
  scores.sort((a, b) => b.point.compareTo(a.point));
  return scores;
}

// Simpan skor hanya jika lebih tinggi dari skor terbaik user sebelumnya.
// Return true jika skor ini adalah high score baru.
Future<bool> checkTopPoint(int userPoint, int frogs) async {
  final prefs = await SharedPreferences.getInstance();
  List<Score> scores = await getHighScores();

  int index = scores.indexWhere((s) => s.user == active_user);
  if (index != -1 && scores[index].point >= userPoint) {
    return false;
  }
  if (index != -1) {
    scores.removeAt(index);
  }

  scores.add(Score(user: active_user, point: userPoint, frogs: frogs));
  scores.sort((a, b) => b.point.compareTo(a.point));
  await prefs.setStringList(
    "high_scores",
    scores.map((s) => jsonEncode(s.toJson())).toList(),
  );
  return true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await checkUser();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Froggy Crosser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      routerConfig: getAppRouter(),
    );
  }
}
