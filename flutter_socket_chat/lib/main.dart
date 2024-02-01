import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_socket_chat/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

const serverUrl = 'http://192.168.50.206:3000';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Real-Time Chat',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Message> _messages = [];
  late io.Socket socket;

  @override
  void initState() {
    super.initState();

    socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'], // protokoły komunikacji
    });

    socket.on('receiveMessage', (data) {
      setState(() {
        _messages.add(Message.fromJson(data));
      });
    });

    socket.onError((err) => log('Error: $err'));

    socket.on('chatHistory', (data) {
      setState(() {
        _messages = List<Message>.from(data.map((item) => Message.fromJson(item)));
      });
    });
  }

  void _sendMessage(String message) {
    socket.emit('sendMessage', {'text': message});
    _messageController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Czat'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages.reversed.toList()[index];
                  return ListTile(
                    title: Text(
                      message.senderId,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      message.text,
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Wpisz wiadomość...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      ),
                      onSubmitted: (value) => _sendMessage(value),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _sendMessage(_messageController.text);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}
