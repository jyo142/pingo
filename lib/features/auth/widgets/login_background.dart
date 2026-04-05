import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pingo/core/constants/image_assets.dart';

class PingoBackground extends StatelessWidget {
  const PingoBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌈 Base Gradient (slightly richer)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF5B4FE9), // deeper purple
                Color(0xFF3A7BD5), // blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // ✨ Stronger Glow (top focus)
        Positioned(
          top: -120,
          left: -80,
          right: -80,
          child: Container(
            height: 350,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
                radius: 0.9,
              ),
            ),
          ),
        ),

        // 🌫️ Soft overlay gradient (fixes blending)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.08)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: 0.25,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.50,
              child: Image.asset(
                ImageAssets.city,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
