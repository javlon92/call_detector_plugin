import 'package:flutter/material.dart';
import 'dart:async';
import 'package:call_detector_plugin_example/src/src.dart';
import 'dart:developer' as developer;

@pragma('vm:entry-point')
void main() => runZonedGuarded<void>(
      () => runApp(
        const MyApp(),
      ),
      (error, stackTrace) => developer.log(
        'A global error has occurred: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'background',
        level: 900,
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CallDetector Plugin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const MyHomePage(),
        '/first_page': (context) => const FirstPage(),
        '/second_page': (context) => const SecondPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('MyHomePage'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/first_page');
          },
          style: TextButton.styleFrom(backgroundColor: Colors.amber),
          child: Text(
            'Open FirstPage',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }
}
