import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Container(width: double.infinity, height: 100, color: Colors.white),
            
            ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: screenWidth,
                  maxHeight: screenHeight / 2,
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  children: [
                    Container(height: 100, color: Colors.white, margin: EdgeInsets.all(12),),
                    Container(height: 100, color: Colors.white, margin: EdgeInsets.all(12),),
                    Container(height: 100, color: Colors.white, margin: EdgeInsets.all(12),),
                    Container(height: 100, color: Colors.white, margin: EdgeInsets.all(12),),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}
