import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeApi {
  static Future<void> streamSummary({
    required String youtubeUrl,
    required String depth,
    required Function(String chunk) onChunk,
    required Function() onDone,
    required Function(String error) onError,
  }) async {
    try {
      final request = http.Request(
        'POST',
        Uri.parse('http://10.128.114.29:8000/summarize/youtube/stream'),
      );

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        "youtube_url": youtubeUrl,
        "depth": depth,
      });

      final response = await request.send();

      response.stream
          .transform(utf8.decoder)
          .listen(
            (chunk) {
              onChunk(chunk);
            },
            onDone: onDone,
            onError: (e) {
              onError(e.toString());
            },
          );
    } catch (e) {
      onError(e.toString());
    }
  }
}
