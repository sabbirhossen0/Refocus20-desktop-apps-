import 'dart:async';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  runApp(const MyApp());

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: "Green Screen Reminder",
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GreenScreen(),
    );
  }
}

class GreenScreen extends StatefulWidget {
  const GreenScreen({super.key});

  @override
  State<GreenScreen> createState() => _GreenScreenState();
}

class _GreenScreenState extends State<GreenScreen> with WindowListener {
  Timer? _periodicTimer;
  Timer? _countdownTimer;
  bool _isGreenScreenVisible = false;
  int _countdown = 20;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    _startPeriodicTimer();
  }

  void _startPeriodicTimer() {
    _periodicTimer = Timer.periodic(const Duration(minutes: 20), (timer) {
      _showGreenScreen();
    });
  }

  void _showGreenScreen() async {
    setState(() {
      _isGreenScreenVisible = true;
      _countdown = 20; // Reset countdown to 20 seconds
    });

    // Show and maximize window
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();

    // Start countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _hideGreenScreen();
      }
    });
  }

  void _hideGreenScreen() async {
    setState(() {
      _isGreenScreenVisible = false;
    });
    await windowManager.minimize();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _countdownTimer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isGreenScreenVisible ? Colors.green : Colors.white,
      body: Center(
        child: _isGreenScreenVisible
            ? Text(
          '$_countdown',
          style: const TextStyle(
            fontSize: 100,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
            : Container(
          color: Colors.green,
              child: const Text(
                        'Green Screen Reminder',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
            ),
      ),
    );
  }
}
