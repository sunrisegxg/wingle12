import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    //light vs dark mode for correct bubble colors
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color:isCurrentUser
          ? (isDarkMode ? Colors.blue.shade600 : Colors.blue.shade500)
          : (isDarkMode ? Theme.of(context).colorScheme.background : Colors.white),
        borderRadius: BorderRadius.circular(12)
      ),
      padding: const EdgeInsets.all(16.0),
      margin: isCurrentUser ? const EdgeInsets.only(top: 5, bottom: 5, left: 80, right: 20) : const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 80),
      child: Text(message,
       style: TextStyle(color: isCurrentUser
                          ? Colors.white
                          : (isDarkMode ? Colors.white : Colors.black)),
      ),
    );
  }
}