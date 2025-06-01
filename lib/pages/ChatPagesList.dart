import 'package:flutter/material.dart';
import 'package:GarageSync/services/auth/auth_service.dart';
import 'package:GarageSync/services/chat/chat_service.dart';
import 'package:GarageSync/component/user_tile.dart';
import 'package:GarageSync/pages/ChatPage.dart';

class ChatListScreen extends StatelessWidget {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        //error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        //loading ...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading ...");
        }
        //return list view
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
      if(userData["email"] != _authService.getCurrentUser()?.email){
        return UserTile(
            text: userData["name"],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    username: userData["name"],
                    reciverEmail: userData["email"],
                    reciverID: userData["uid"],
                  ),
                ),
              );
            });
      }
      else{
        return Container();
      }
  }
}

class ChatItem {
  final String name;
  final String lastMessage;
  final String time;

  ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
  });
}
