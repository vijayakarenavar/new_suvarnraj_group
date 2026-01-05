// lib/screens/success_animation_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessAnimationScreen extends StatefulWidget {
  final String orderId;
  const SuccessAnimationScreen({super.key, required this.orderId});

  @override
  State<SuccessAnimationScreen> createState() => _SuccessAnimationScreenState();
}

class _SuccessAnimationScreenState extends State<SuccessAnimationScreen> {
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(seconds: 3)); // Show animation for 3 sec
    if (mounted) {
      Navigator.pop(context); // Close this screen automatically
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button during animation
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: Lottie.asset('assets/order_confirmed.json'),
              ),
              const SizedBox(height: 16),
              Text(
                'Order Confirmed! 🎉',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}