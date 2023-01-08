import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:websocket_chat_app/ChatPage.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter name", style: TextStyle(fontSize: 32.0)),
            Container(
              padding: const EdgeInsets.fromLTRB(96, 16, 96, 0),
              child: TextField(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                controller: nameController,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatPage(
                              user: _createUser(nameController.text),
                              channel: _connectWebSocket())));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 109, 97, 224)),
                child: const Text("Join Chat"))
          ],
        ),
      ),
    );
  }

  types.User _createUser(String name) {
    return types.User(id: const Uuid().v4(), firstName: name);
  }

  IOWebSocketChannel _connectWebSocket() {
    return IOWebSocketChannel.connect('ws://192.168.100.106:8080/chat');
  }
}
