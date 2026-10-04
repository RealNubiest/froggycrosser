import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  void showHowToPlayDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Cara Bermain'),
        content: const Text(
          '1. Swipe atas, bawah, kiri, kanan untuk menggerakkan katak.\n'
          '2. Hindari truk, mobil, dan mobil balap di jalan raya.\n'
          '3. Lompat di atas batang kayu untuk menyeberangi sungai. '
          'Jangan jatuh ke air!\n'
          '4. Seberangkan katak sebanyak-banyaknya sebelum waktu habis.\n'
          '5. Tangkap lalat untuk bonus +50 poin.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              this.context.push('/game');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: myDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Froggy Crosser'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/frog.png', width: 150, height: 150),
            const SizedBox(height: 20),
            Text(
              'Halo, $active_user!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: showHowToPlayDialog,
              child: const Text(
                'Play Game',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer myDrawer() {
    return Drawer(
      elevation: 16.0,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(active_user),
            accountEmail: const Text("Froggy Crosser Player"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage("assets/images/frog.png"),
            ),
          ),
          ListTile(
            title: const Text("High Score"),
            leading: const Icon(Icons.emoji_events),
            onTap: () {
              Navigator.pop(context);
              context.push('/highscore');
            },
          ),
          ListTile(
            title: const Text("LOG OUT"),
            leading: const Icon(Icons.logout),
            onTap: () {
              doLogout();
            },
          ),
        ],
      ),
    );
  }
}
