// import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  const MyTextBox({super.key, required this.text, required this.sectionName, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // bool isDarkMode =
    //     Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //section name
            Text(
              sectionName,
              style: TextStyle(fontSize: 18,),
            ),
            //edit button
            Row(
              children: [
                //text
                Container(
                  width: 160,
                  child: Text(
                    maxLines: 1, // Giới hạn số dòng
                    overflow: TextOverflow.ellipsis, // Hiển thị dấu ...
                    text,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
                const SizedBox(width: 5,),
                Icon(
                  Icons.edit,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}