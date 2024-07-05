import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voice/secrets.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];

  // Function to determine if the prompt is related to generating art
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo-16k",
          "messages": [
            {
              "role": "user",
              "content":
                  "Do you want to generate an AI picture, image, art or anything similar? $prompt. Answer with a yes or no",
            },
          ],
        }),
      );

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'].trim();

        if (content.toLowerCase() == 'yes' || content.toLowerCase() == 'yes.') {
          return await dallEAPI(prompt);
        } else {
          return await chatGPTAPI(prompt);
        }
      } else {
        return 'Error: ${res.statusCode} ${res.reasonPhrase}';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo-16k",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'].trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      } else {
        return 'Error: ${res.statusCode} ${res.reasonPhrase}';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        String Imageurl = jsonDecode(res.body)['data'][0]['url'];
        Imageurl = Imageurl.trim();

        messages.add({
          'role': 'assistant',
          'content': Imageurl,
        });
        return Imageurl;
      } else {
        return 'Error: ${res.statusCode} ${res.reasonPhrase}';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }
}
