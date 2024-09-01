/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_app/services/socket_service.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String delivererId;
  final String managerId;
  final String role;

  ChatScreen({required this.roomId, required this.delivererId, required this.managerId, required this.role});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);

    // Rejoindre une salle de discussion spécifique
    socketService.joinRoom(widget.roomId);

    // Écouter les messages reçus
    socketService.onMessageReceived((messageData) {
      setState(() {
        _messages.add(messageData);
      });
    });
  }

  void _sendMessage() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (_controller.text.isNotEmpty) {
      socketService.sendMessage(
        widget.delivererId,
        widget.role,
        widget.managerId,
        _controller.text,
        widget.roomId,
      );

      setState(() {
        _messages.add({
          'senderId': widget.delivererId,
          'message': _controller.text,
          'timestamp': DateTime.now().toIso8601String(),
        });
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discussion avec le Manager'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSentByMe = message['senderId'] == widget.delivererId;

                return ListTile(
                  title: Align(
                    alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSentByMe ? Colors.blueAccent : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['message'],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  subtitle: Align(
                    alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      message['timestamp'],
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
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
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Envoyer un message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:delivery_app/services/socket_service.dart';
import 'package:delivery_app/services/chat_services.dart';
import 'package:delivery_app/models/chat.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String delivererId;
  final String managerId;
  final String role;

  ChatScreen({
    required this.roomId,
    required this.delivererId,
    required this.managerId,
    required this.role,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late DiscussionService _discussionService;

  @override
  void initState() {
    super.initState();
    _discussionService = DiscussionService(baseUrl: 'http://localhost:8080');

    final socketService = Provider.of<SocketService>(context, listen: false);

    // Charger les messages existants
    _loadDiscussion();

    // Rejoindre une salle de discussion spécifique
    socketService.joinRoom(widget.roomId);

    // Écouter les messages reçus
    socketService.onMessageReceived((messageData) {
      setState(() {
        _messages.add(messageData);
      });
    });
  }

  Future<void> _loadDiscussion() async {
    try {
      Discussion discussion =
          await _discussionService.getDiscussion(widget.delivererId, widget.managerId);

      setState(() {
        _messages.addAll(discussion.messages.map((message) {
          return {
            'senderId': message.senderId,
            'message': message.message,
            'timestamp': message.timestamp.toIso8601String(),
          };
        }).toList());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load discussion')),
      );
    }
  }

  void _sendMessage() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (_controller.text.isNotEmpty) {
      socketService.sendMessage(
        widget.delivererId,
        widget.managerId,
        _controller.text,
        widget.roomId,
        widget.role,
      );

      setState(() {
        _messages.add({
          'senderId': widget.delivererId,
          'message': _controller.text,
          'timestamp': DateTime.now().toIso8601String(),
        });
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discussion avec le Manager'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSentByMe = message['senderId'] == widget.delivererId;

                return ListTile(
                  title: Align(
                    alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSentByMe ? Colors.blueAccent : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['message'],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  subtitle: Align(
                    alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      message['timestamp'],
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
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
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Envoyer un message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

