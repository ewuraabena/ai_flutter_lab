import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  
  )
  final String apiKey = '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'; // Replace this with your actual API key
  // final String OtherapiKey= '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';

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({'role': 'user', 'text': message});
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini', // Change to 'gpt-3.5-turbo' if needed
        'messages': [
          {'role': 'system', 'content': 'You are an AI assistant.'},
          {'role': 'user', 'content': message},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String botReply = data['choices'][0]['message']['content'].trim();

      setState(() {
        _messages.add({'role': 'bot', 'text': botReply});
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get response: ${response.body}')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[300] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _isLoading
                      ? null
                      : () {
                          String message = _controller.text.trim();
                          if (message.isNotEmpty) {
                            sendMessage(message);
                            _controller.clear();
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
