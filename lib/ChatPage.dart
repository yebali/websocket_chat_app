import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';

class ChatPage extends StatefulWidget {
  final types.User user;
  final IOWebSocketChannel channel;

  late final Stream _receiveStream = channel.stream.asBroadcastStream();

  ChatPage({super.key, required this.user, required this.channel});

  @override
  State<StatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget._receiveStream.listen((event) {
      print("received message : ${event.toString().toMessage()}");
      var message = event.toString().toMessage();

      if (!_messages.contains(message)) {
        setState(() {
          _messages.insert(0, event.toString().toMessage());
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              _disconnectWebSocket();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          )),
      body: Chat(
        messages: _messages,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        user: widget.user,
      ),
    );
  }

  void _sendMessage(types.Message message) {
    widget.channel.sink.add(message.serialize());
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: widget.user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message.text,
    );

    _sendMessage(textMessage);
  }

  void _disconnectWebSocket() {
    widget.channel.sink.close();
  }
}

extension MessageExtension on types.Message {
  String serialize() {
    return json.encode(this);
  }
}

/**
 * {
    "author": {
    "firstName": "dfsef",
    "id": "d327615d-9a37-487f-9130-481e92b9a962"
    },
    "createdAt": 1673186976414,
    "id": "985bff88-a967-4ca8-bd47-738b26377462",
    "type": "text",
    "text": "dfsef joined chat"
    }
 */
extension StringExtension on String {
  types.Message toMessage() {
    Map decoded = json.decode(this);

    return types.TextMessage(
      author: types.User(
          id: decoded["author"]["id"],
          firstName: decoded["author"]["firstName"]),
      createdAt: decoded["createdAt"],
      id: decoded["id"],
      text: decoded["text"],
    );
  }
}
