import 'package:GarageSync/component/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:GarageSync/services/auth/auth_service.dart';
import 'package:GarageSync/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatelessWidget {
  final String reciverEmail;
  final String reciverID;
  final String username;

  ChatPage({super.key, required this.username,required this.reciverEmail, required this.reciverID});

  //text controller
  final TextEditingController _messageController = TextEditingController();

  // chat and auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // send message
  void sendMessage() async {
    // if there is something inside the text field
    if (_messageController.text.isNotEmpty) {
      // send message
      await _chatService.sendMessage(reciverID, _messageController.text);

      // clear text field
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(username)),
      body: Column(
        children: [
          // display all messages
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: _chatService.getMessages(reciverID, senderID),
        builder: (context, snapshot) {
          // errors
          if (snapshot.hasError) {
            return const Text("Error");
          }

          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading ...");
          }

          // return list view
          return ListView(
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        });
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    // align message to right if current user
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:  isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(message: data["message"], isCurrentUser: isCurrentUser),
    ]
    ));
  }

  // build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          //textfield should take up most of space
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ),

                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // send button
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.send),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
