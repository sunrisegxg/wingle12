import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.black54 : Colors.black26,
      highlightColor: isDarkMode ? Colors.white30 : Colors.white38,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.black54,
        ),
        height: 320,
      ),
    );
  }
}