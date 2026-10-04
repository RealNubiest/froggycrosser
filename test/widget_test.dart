import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:froggycrosser/main.dart';
import 'package:froggycrosser/class/score.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    active_user = '';
    isLoggedIn.value = false;
  });

  testWidgets('Layar Login tampil jika belum login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('FROGGY CROSSER'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
  });

  testWidgets('Layar Login dilewati jika username sudah tersimpan', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'user_id': 'Froggy'});
    await checkUser();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Play Game'), findsOneWidget);
    expect(find.text('Halo, Froggy!'), findsOneWidget);
  });

  test('Score dapat diubah ke JSON dan kembali', () {
    Score s = Score(user: 'Froggy', point: 250, frogs: 2);
    Score hasil = Score.fromJson(s.toJson());

    expect(hasil.user, 'Froggy');
    expect(hasil.point, 250);
    expect(hasil.frogs, 2);
  });

  test('High score hanya disimpan jika lebih tinggi dari sebelumnya', () async {
    active_user = 'Froggy';

    expect(await checkTopPoint(200, 2), isTrue);
    expect(await checkTopPoint(100, 1), isFalse);
    expect(await checkTopPoint(300, 3), isTrue);

    List<Score> scores = await getHighScores();
    expect(scores.length, 1);
    expect(scores.first.point, 300);
  });

  test('High score terurut dari yang tertinggi', () async {
    active_user = 'A';
    await checkTopPoint(100, 1);
    active_user = 'B';
    await checkTopPoint(400, 4);
    active_user = 'C';
    await checkTopPoint(300, 3);
    active_user = 'D';
    await checkTopPoint(200, 2);

    List<Score> scores = await getHighScores();
    expect(scores.take(3).map((s) => s.user).toList(), ['B', 'C', 'D']);
  });
}
