import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO: Replace with your actual API base URL
  final String _baseUrl = 'http://localhost/api';

  Future<Map<String, dynamic>?> getProducer(String googleUid) async {
    final response = await http.get(Uri.parse('$_baseUrl/producers.php?google_uid=$googleUid'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load producer');
    }
  }

  Future<Map<String, dynamic>> createProducer({
    required String googleUid,
    required String userName,
    required String email,
    String? organizationName,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/producers.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String?>{
        'google_uid': googleUid,
        'user_name': userName,
        'email': email,
        'organization_name': organizationName,
        'phone': phone,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create producer: ${response.body}');
    }
  }

  Future<void> updateProducer(int id, Map<String, String?> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/producers.php?id=$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update producer: ${response.body}');
    }
  }

  // Event Methods
  Future<List<dynamic>> getEvents(int producerId) async {
    final response = await http.get(Uri.parse('$_baseUrl/events.php?producer_id=$producerId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<void> createEvent(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create event: ${response.body}');
    }
  }

  Future<void> updateEvent(int eventId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/events.php?id=$eventId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update event: ${response.body}');
    }
  }

  Future<void> deleteEvent(int eventId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/events.php?id=$eventId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete event: ${response.body}');
    }
  }
}
