import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  @override
  dynamic user;
  ChatScreen({required this.user});
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final _scrollController = ScrollController();

  List<Map<String, String>> _messages = [];

  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  final String _apiKey = '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';

  Future<String> _getResponse(String prompt) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
    var body = jsonEncode({
      'model': "gpt-3.5-turbo",
      'messages': _messages,
      'max_tokens': 150,
      'temperature': 0.5,
      'n': 1,
      'stop': '\n'
    });
    var response =
        await http.post(Uri.parse(_apiUrl), headers: headers, body: body);
    var data = jsonDecode(response.body);

    return data['choices'][0]['message']['content'];
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
    });
    var response = await _getResponse(_messages[0]['content']!);
    setState(() {
      _messages.add({'role': 'assistant', 'content': response});
    });
    _scrollToBottom();
  }

  void _handleSystemPrompt(String sysPrompt) async {
    setState(() {
      _messages.add({'role': 'system', 'content': sysPrompt});
    });
  }

  String sysPrompt = """
      You are an intelligent assistant and will be used in a family banking platform. Typically users will ask you content related to managing their financial position.
      If the query is not financial question make sure to let them know that you are not designed for that in a professional manner. Yet, if if it is a conversation starter like 'how are you?' go ahead interact with them.
      Your main two tasks are the following (in addition to the above potential prompts) 1. If the user asks 'how much is it safe to spend?' or a question that semantically looks like that say '[safe] dirham' in a financial advisor tone.
      2. if the user asks 'what is the next salary release day' or a question semantically similar to that reply with '[salary] dirham when the salary is released'
      Make your respones short and to the point, and stricly not more than 20 words.
      [safe] and [salary] will be provided to you later. If they, [safe] and [salary], are not provided to you yet, reply with I can not process your request right now, in a polite manner.
      """;
  Widget _buildTextComposer() {
    // Send system prompt here
    _handleSystemPrompt(sysPrompt);

    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                    hintText: 'Enter your message'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _handleSubmitted(_textController.text);
                    }
                  }
                  // ? () => _handleSubmitted(_textController.text)
                  // : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot Assistant'),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (_, int index) => _messages[index]['role'] == 'user'
                  ? _buildUserMessage(_messages[index]['content']!)
                  : _messages[index]['role'] == 'assistant'
                      ? _buildAssistantMessage(_messages[index]['content']!)
                      : const SizedBox.shrink(),
              itemCount: _messages.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }

  Widget _buildAssistantMessage(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 8.0),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(
                message,
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
