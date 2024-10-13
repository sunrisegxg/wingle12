import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerColumn extends StatelessWidget {
  const ShimmerColumn({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.black54 : Colors.black26,
      highlightColor: isDarkMode ? Colors.white30 : Colors.white38,
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0, top: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipOval(
              child: Container(
                color: Colors.black54,
                width: 50,
                height: 50,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                width: 50,
                height: 15,
              ),
            )
          ],
        ),
      ),
    );
  }
}
