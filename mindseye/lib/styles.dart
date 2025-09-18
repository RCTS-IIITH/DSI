// lib/styles.dart

import 'package:flutter/material.dart';

class FadeInAnimation extends StatelessWidget {
  final Duration delay;
  final Widget child;

  const FadeInAnimation(
      {super.key,
      this.delay = const Duration(milliseconds: 0),
      required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500),
      tween: Tween(begin: 0, end: 1),
      builder: (_, opacity, child) => Opacity(opacity: opacity, child: child),
      child: child,
    );
  }
}

class CardSection extends StatelessWidget {
  final Color color;
  final Widget child;

  const CardSection({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
