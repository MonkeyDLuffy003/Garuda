import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const GarudaApp());
}

class GarudaApp extends StatelessWidget {
  const GarudaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garuda Research',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: accentTeal),
        textTheme: GoogleFonts.outfitTextTheme(),
        scaffoldBackgroundColor: bgColor,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: splashGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.air, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text('GARUDA', style: TextStyle(
                    fontSize: 36, fontWeight: FontWeight.w900,
                    color: Colors.white, letterSpacing: 6)),
                  const SizedBox(height: 8),
                  Text('RESEARCH VOICE AGENT BOT', style: TextStyle(
                    fontSize: 12, letterSpacing: 3,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w300)),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 32, height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withOpacity(0.7))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
