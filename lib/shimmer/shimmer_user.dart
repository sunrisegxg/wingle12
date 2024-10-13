import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerUser extends StatelessWidget {
  const ShimmerUser({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.black54 : Colors.black26,
      highlightColor: isDarkMode ? Colors.white30 : Colors.white38,
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: ClipOval(
          child: Container(
            color: Colors.black54,
            width: 50,
            height: 50,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 100),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            width: 5,
            height: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(right: 150),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            width: 5,
            height: 15,
          ),
        ),
      ),
    );
  }
}