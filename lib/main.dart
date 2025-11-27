import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options_template.dart';
import 'services/firebase_service.dart';
import 'pages/cv_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  } catch (e) {
    // If Firebase options are not filled, continue without Firebase.
    // Running `flutterfire configure` will generate `lib/firebase_options.dart`.
    // For now we log the error and continue.
    // ignore: avoid_print
    print('Firebase initialization failed or not configured: $e');
  }

  // Attempt anonymous sign-in if Firebase is available.
  try {
    final svc = FirebaseService();
    await svc.signInAnonymously();
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Database',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CV Database Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to the CV Database'),
            const SizedBox(height: 12),
            Text(
              'Button tapped: $_counter times',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text('Increment'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CvListPage()));
              },
              child: const Text('Open CVs'),
            ),
          ],
        ),
      ),
    );
  }
}
