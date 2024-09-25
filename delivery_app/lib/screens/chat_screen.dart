import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Pour formater l'heure
import 'package:delivery_app/services/socket_service.dart';
import 'package:delivery_app/services/chat_services.dart';
import 'package:delivery_app/models/chat.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Package pour notifications
import '../utils/api_urls.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String delivererId;
  final String managerId;
  final String role;
  final String name;

  ChatScreen({
    required this.roomId,
    required this.delivererId,
    required this.managerId,
    required this.role,
    required this.name,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late DiscussionService _discussionService;
  final DateFormat _timeFormat = DateFormat('HH:mm'); // Format d'heure
  String managerName = "Manager RABE"; // Ajout du nom du manager (à remplacer par une info réelle)

  // Notification setup
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _discussionService = DiscussionService(baseUrl: ApiUrls.socketUrl);

    // Initialiser les notifications locales
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: _onSelectNotification);

    final socketService = Provider.of<SocketService>(context, listen: false);

    // Charger les messages existants
    _loadDiscussion();

    // Rejoindre une salle de discussion spécifique
    socketService.joinRoom(widget.roomId);

    // Écouter les messages reçus
    socketService.onMessageReceived((messageData) {
      messageData['timestamp'] = _timeFormat.format(messageData['timestamp']);
      setState(() {
        _messages.add(messageData);
      });

      // Envoyer une notification pour chaque message reçu
      _showNotification(messageData['message'], widget.roomId, messageData['senderName']);
    });

    // Charger les informations du manager
    _loadManagerInfo();
  }

  // Méthode pour afficher la notification locale
  Future<void> _showNotification(String message,String roomId,String senderName) async {
    // ignore: prefer_const_constructors
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'channel_id', // ID du canal de notification
    'channel_name', // Nom du canal
    channelDescription: 'This is the description of the channel', // Nouvelle clé pour la description
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    playSound: true,
  );


    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      '$senderName vous a envoyé un message',
      message,
      platformChannelSpecifics,
      payload: roomId,
    );
  }

    // Méthode appelée lors du clic sur la notification
  Future<void> _onSelectNotification(String? payload) async {
    if (payload != null) {
      // Rediriger vers l'écran de chat en utilisant le roomId
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatScreen(
          roomId: payload,
          delivererId: widget.delivererId,
          managerId: widget.managerId,
          role: widget.role,
          name: widget.name
        ),
      ));
    }
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
            'timestamp': _timeFormat.format(message.timestamp), // Formater l'heure
          };
        }).toList());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de charger la discussion')),
      );
    }
  }

  Future<void> _loadManagerInfo() async {
    // Remplacer par le service réel pour récupérer les informations du manager
    setState(() {
      managerName = "Manager RAKOTO"; // Exemple de nom (remplacer avec les données réelles)
    });
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
        widget.name
      );

      setState(() {
        _messages.add({
          'senderId': widget.delivererId,
          'message': _controller.text,
          'timestamp': _timeFormat.format(DateTime.now()), // Formater l'heure
        });
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discussion avec le Manager', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Section des informations du manager
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('http://delivery.psad.hco.mg/uploads/other/default_man.png'), // Placeholder de l'image du manager
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      managerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
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
                  icon: Icon(Icons.send, color: Colors.blue),
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
