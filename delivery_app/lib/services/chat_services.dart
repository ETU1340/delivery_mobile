import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat.dart';
import '../utils/api_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
class DiscussionService {
  final String baseUrl;

  DiscussionService({required this.baseUrl});

  Future<Discussion> getDiscussion(String delivererId, String managerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    print(token);
    final response = await http.get(
      Uri.parse(ApiUrls.chat+'/'+delivererId+'/'+managerId),
      headers: {'x-auth-token': '$token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body)['discussion'];
      return Discussion.fromJson(data);
    } else {
      throw Exception('Failed to load discussion');
    }
  }
}
