import 'package:flutter/material.dart';

class ResponsiveAppFrame extends StatelessWidget {
  const ResponsiveAppFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final textScale = media.textScaler.scale(1).clamp(0.9, 1.15).toDouble();

    return MediaQuery(
      data: media.copyWith(textScaler: TextScaler.linear(textScale)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width >= 900
              ? 28.0
              : width >= 700
              ? 20.0
              : 0.0;
          final maxContentWidth = width >= 1100
              ? 840.0
              : width >= 700
              ? 700.0
              : width;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF040404), Color(0xFF0D0F12)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
