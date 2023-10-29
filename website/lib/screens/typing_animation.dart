import 'dart:async';

import 'package:flutter/material.dart';

class TypingAnimation extends StatefulWidget {
  const TypingAnimation(ScrollController scrollController, {super.key});

  @override
  _TypingAnimationState createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<TypingAnimation> {
  int activeDotIndex = 0;
  List<bool> dotStates = [true, false, false];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startBlinking();
  }

  void startBlinking() {
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        dotStates[activeDotIndex] = false;
        activeDotIndex = (activeDotIndex + 1) % 3;
        dotStates[activeDotIndex] = true;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Dot(isVisible: dotStates[0]),
          const SizedBox(width: 5),
          Dot(isVisible: dotStates[1]),
          const SizedBox(width: 5),
          Dot(isVisible: dotStates[2]),
        ],
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final bool isVisible;

  const Dot({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 69, 185, 94),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}