import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:logging/logging.dart';

var logger = Logger("Our Logger");

class userForm {
  List user;
  userForm({required this.user});
  Map<String, dynamic> toJson() => {
        'user': user,
      };
}

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

  final String? _apiKey = Platform.environment['OPENAI_API_KEY'];

  Future<String> _getResponse(String prompt) async {
    if (_apiKey == null) {
      // OpenApiKey not set
      logger.warning("OpenApiKey not set");
    }
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

  void _handleSystemPrompt(String sysPrompt, String safeNsalary) async {
    setState(() {
      _messages.add({'role': 'system', 'content': safeNsalary});
    });
    setState(() {
      _messages.add({'role': 'system', 'content': sysPrompt});
    });
  }

  // Get [safe] and [salary] from the database
  Future<dynamic> _retrieveSafeSalary(user) async {
    final url = Uri.parse('http://127.0.0.1:8000/chatbot');
    final headers = {'Content-Type': 'application/json'};

    final user_ = userForm(
      user: user,
    );

    final body = json.encode(user_.toJson());

    final response = await http.post(url, headers: headers, body: body);
    String safeNsalary;
    if (response.statusCode == 200) {
      safeNsalary = json.decode(response.body);
      logger.info(safeNsalary);
    } else {
      throw Exception('Failed to send');
    }
    return safeNsalary;
  }

  String sysPrompt = """
      You are an intelligent assistant and will be used in a family banking platform. Typically users will ask you content related to managing their financial position.
      If the query is not financial question make sure to let them know that you are not designed for that in a professional manner. Yet, if if it is a conversation starter like 'how are you?' go ahead interact with them.
      Your main task is the following (in addition to the above potential prompts) 
      If the user asks 'how much is it safe to spend?' or a question that semantically looks like inform them the above prompt of the amount safe to spend now and on the 28th after the salary is released.
      Make your respones short and to the point, and strictly not more than 20 words / tokens.
      If the values are not provided to you yet, reply with I can not process your request right now, in a polite manner.
      """;

  Widget _buildTextComposer() {
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
                    _retrieveSafeSalary(widget.user)
                        .then((value) => _handleSystemPrompt(sysPrompt, value));
                    if (_textController.text.isNotEmpty) {
                      _handleSubmitted(_textController.text);
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.none,
      backgroundColor: Color.fromARGB(255, 171, 182, 231),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Chatbot Assistant',
              style: TextStyle(
                color: Color.fromARGB(255, 96, 120, 226),
                fontSize: 44,

                // fontWeight: FontWeight,
              ),
              // style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Flexible(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              // reverse: true,
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index]['role'] == 'user'
                  ? _buildUserMessage(_messages[index]['content']!)
                  : _messages[index]['role'] == 'assistant'
                      ? _buildAssistantMessage(_messages[index]['content']!)
                      : const SizedBox.shrink(),
            ),
          ),
          const Divider(height: 1.0),
          _buildTextComposer(),
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
