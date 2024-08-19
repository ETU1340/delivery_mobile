import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
class WebSocketService {
  final WebSocketChannel channel;

  WebSocketService(String url)
      : channel = WebSocketChannel.connect(Uri.parse(url));

void sendLocation(double latitude, double longitude) {
  final locationData = {
    'latitude': latitude,
    'longitude': longitude,
  };
  // Convertir le map en JSON string
  channel.sink.add(jsonEncode(locationData));
}
  void close() {
    channel.sink.close();
  }
}
