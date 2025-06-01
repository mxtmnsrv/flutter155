import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String? time; // Optional: To display the message time
  final Color?
    currentUserBubbleColor = Colors.indigo; // Bubble color for the current user's message
  final Color? otherUserBubbleColor = Colors.grey[700]; // Bubble color for the other user's message
  final Color? currentUserTextColor = Colors.white; // Text color for the current user
  final Color? otherUserTextColor = Colors.white; // Text color for the other user

  ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    // Use theme colors or default colors if specific ones are not provided
    final bubbleColor = isCurrentUser
        ? (currentUserBubbleColor ?? Theme
        .of(context)
        .colorScheme
        .primary)
        : (otherUserBubbleColor ?? Colors.grey[300]);

    final textColor = isCurrentUser
        ? (currentUserTextColor ?? Colors.white)
        : (otherUserTextColor ?? Colors.black);

    // Align the bubble to the right for the current user, left for others
    final alignment =
    isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // Align the content (message and time) within the bubble
    final crossAxisAlignment =
    isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    // Adjust corner radius for a typical chat bubble look
    final borderRadius = isCurrentUser
        ? const BorderRadius.only(
      topLeft: Radius.circular(12),
      bottomLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomRight: Radius.circular(0), // Flat bottom-right for a tail effect
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(12),
      bottomLeft: Radius.circular(0), // Flat bottom-left for a tail effect
      topRight: Radius.circular(12),
      bottomRight: Radius.circular(12),
    );

    return Container(
      alignment: alignment, // Align the entire bubble container
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery
              .of(context)
              .size
              .width *
              0.75, // Max width for the bubble
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
          boxShadow: [
            // Add a slight shadow for depth
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          crossAxisAlignment, // Align text and time inside the bubble
          mainAxisSize: MainAxisSize.min, // Bubble size to fit content
          children: [
            Text(
              message,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            if (time != null && time!.isNotEmpty) ...[
              const SizedBox(height: 4.0), // Space between message and time
              Text(
                time!,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  // Slightly dimmer color for time
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}