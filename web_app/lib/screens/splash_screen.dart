import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_app/screens/chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        ),
      );  
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 154, 30, 21), Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        ),
        child: Column(
          children: [
            const SizedBox(height: 120,),
            Image.asset('assets/images/logo.png', width: 300, height: 300),
            const SizedBox(height: 190),
            const Text("Powered By: ", style: TextStyle(color: Colors.white, fontSize: 16,)),
            const SizedBox(height: 30,),
            Image.asset('assets/images/alibaba.png', width: 150, height: 100)
          ],
        )
      ),
    );
  }
}