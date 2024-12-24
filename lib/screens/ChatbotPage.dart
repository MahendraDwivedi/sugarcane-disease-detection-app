
import 'dart:io';
import 'dart:convert'; // For encoding/decoding JSON
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotPage extends StatefulWidget {
  final File? selectedImage;

  const ChatbotPage({Key? key, this.selectedImage}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];
  bool isTyping = false;

  final ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  final ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
    "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  @override
  void initState() {
    super.initState();
    _loadMessagesFromStorage();
    if (widget.selectedImage != null) {
      _processImageAndRespond(widget.selectedImage!);
    } else {
      _sendBotGreeting();
    }
  }

  Future<void> _loadMessagesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? messagesJson = prefs.getString('chat_messages');
    if (messagesJson != null) {
      final List<dynamic> decodedMessages = jsonDecode(messagesJson);
      setState(() {
        messages = decodedMessages
            .map((message) => ChatMessage.fromJson(message))
            .toList();
      });
    } else {
      _sendBotGreeting();
    }
  }

  Future<void> _saveMessagesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String messagesJson =
    jsonEncode(messages.map((message) => message.toJson()).toList());
    await prefs.setString('chat_messages', messagesJson);
  }

  void _sendBotGreeting() {
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
          ),
        );
        _saveMessagesToStorage();
      });
    });
  }

  void _processImageAndRespond(File image) async {
    final chatMessage = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: "I have a image . Based on the image,if the image is a sugarcane leaf can you determine if the the sugarcane leaf is healthy or not? If the sugarcane leaf  is diseased, please identify the type of disease and provide a detailed solution, including:\n\n" +
          "- Identification of the Disease: Clearly describe the disease affecting the sugarcane leaf.\n" +
          "- Management Recommendations:\n" +
          "  - Pesticides: Recommend specific pesticides to treat the disease and the correct application instructions.\n" +
          "  - Fertilizer: Suggest the appropriate fertilizer to use, with details on the required amount and the ideal amount of land for it to cover (provide the recommended dosage in kg/ha).\n" +
          "- Visual Analysis: Describe the symptoms visible in the image (e.g., color changes, spots, wilting, etc.) and how these correlate with the disease.",
      medias: [
        ChatMedia(
          url: image.path,
          fileName: image.path.split('/').last,
          type: MediaType.image,
        ),
      ],
    );
    _sendMessage(chatMessage);

    // Simulating a response based on the prompt without passing the prompt elsewhere
    Future.delayed(Duration(seconds: 2), () {
      final botResponse = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
      );
      setState(() {
        messages.insert(0, botResponse);
        _saveMessagesToStorage();
      });
    });
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages.insert(0, chatMessage);
      isTyping = true;
      _addTypingIndicator();
      _saveMessagesToStorage();
    });

    try {
      final String question = chatMessage.text;
      List<Uint8List>? images;

      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }

      gemini.streamGenerateContent(question, images: images).listen((event) {
        String response = event.content?.parts?.fold(
          "",
              (previous, part) {
            if (part is TextPart) {
              return "$previous ${part.text}";
            }
            return previous;
          },
        ) ??
            "🤔 I'm here to help! Could you rephrase or ask something else?";

        response = response.trim().replaceAll('\n\n', '\n');

        final ChatMessage botMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
        );

        setState(() {
          _removeTypingIndicator();
          messages.insert(0, botMessage);
          isTyping = false;
          _saveMessagesToStorage();
        });

        _saveSearchToHistory(question);
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        isTyping = false;
        _removeTypingIndicator();
        messages.insert(
          0,
          ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: "⚠️ Something went wrong. Please try again.",
          ),
        );
        _saveMessagesToStorage();
      });
    }
  }

  void _saveSearchToHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('search_history') ?? [];

    if (!history.contains(query)) {
      history.insert(0, query);
    }

    await prefs.setStringList('search_history', history);
  }

  void _addTypingIndicator() {
    final ChatMessage typingMessage = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text: "...",
    );

    setState(() {
      messages.insert(0, typingMessage);
    });
  }

  void _removeTypingIndicator() {
    if (messages.isNotEmpty &&
        messages.first.user == geminiUser &&
        messages.first.text == "typing-indicator") {
      setState(() {
        messages.removeAt(0);
      });
    }
  }

  void _refreshChat() async {
    setState(() {
      messages.clear();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌿 Cane Guard Bot"),
        backgroundColor: const Color.fromARGB(255, 107, 107, 210),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshChat,
          ),

        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: DashChat(
              inputOptions: InputOptions(
                trailing: [],
              ),
              currentUser: currentUser,
              onSend: _sendMessage,
              messages: messages,
              messageOptions: const MessageOptions(showTime: true),
            ),
          ),
        ],
      ),
    );
  }
}


