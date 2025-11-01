import 'dart:convert';
import 'package:http/http.dart' as http;

// 🔹 Replace with your Edge Function URL
// const String deleteUserUrl = 'https://xcmlnqspnqyzwthobyrm.supabase.co/functions/v1/delete_user';
const String deleteUserUrl =
    'https://xcmlnqspnqyzwthobyrm.supabase.co/functions/v1/delete-user';

Future<void> deleteProfile({required String userId}) async {
  final uri = Uri.parse(deleteUserUrl);

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'uuid': userId}),
  );

  if (response.statusCode == 200) {
    // Success
    return;
  } else {
    // Throw error to catch in _confirmDelete()
    final error = jsonDecode(response.body)['error'];
    throw Exception(error);
  }
}
