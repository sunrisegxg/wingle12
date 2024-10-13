import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class Search extends StatelessWidget {
  const Search({super.key, required this.prefixIcon});
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black38 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.grey[700],),
            SizedBox(width: 15,),
            Text(
              "Search",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
