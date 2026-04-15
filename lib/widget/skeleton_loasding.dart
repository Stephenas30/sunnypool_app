import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoading extends StatelessWidget {
  const SkeletonLoading({super.key});

  static const _cardColor = Color(0xFF1A1A1A);
  static const _borderColor = Color(0x26FFD54F);

  Widget _block({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: borderRadius ?? BorderRadius.circular(10),
      ),
    );
  }

  Widget _surface({required Widget child, double? height}) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final actionCardWidth = (screenWidth - 16 * 2 - 12) / 2;

    return Shimmer.fromColors(
      baseColor: const Color(0xFF252525),
      highlightColor: const Color(0xFF3A3A3A),
      period: const Duration(milliseconds: 1200),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _surface(
                height: 188,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _block(width: screenWidth * 0.45, height: 20),
                    _block(width: screenWidth * 0.30, height: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _block(width: screenWidth * 0.35, height: 12),
                        const SizedBox(height: 10),
                        _block(width: double.infinity, height: 8),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _surface(
                height: 100,
                child: Row(
                  children: [
                    _block(
                      width: 44,
                      height: 44,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _block(width: 84, height: 18),
                          const SizedBox(height: 8),
                          _block(width: 140, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    List.generate(
                      4,
                      (_) => _surface(
                        height: 92,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _block(
                              width: 28,
                              height: 28,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(height: 10),
                            _block(width: actionCardWidth * 0.6, height: 11),
                          ],
                        ),
                      ),
                    ).map((card) {
                      return SizedBox(width: actionCardWidth, child: card);
                    }).toList(),
              ),
              const SizedBox(height: 16),
              _surface(
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(width: 170, height: 18),
                    const SizedBox(height: 14),
                    _block(
                      width: double.infinity,
                      height: 1,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      5,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            _block(
                              width: 18,
                              height: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: _block(height: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
