import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../services/ai_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();

  /// 🔥 MULTI CHAT (SIMPLE)
  List<List<Map<String, String>>> allChats = [[]];
  int currentChatIndex = 0;

  List<Map<String, String>> get messages => allChats[currentChatIndex];

  bool isLoading = false;

  FlutterTts flutterTts = FlutterTts();
  bool isVoiceOn = true;

  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  /// 🔊 SPEAK
  Future speak(String text) async {
    if (!isVoiceOn) return;
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  /// 🎤 VOICE
  void startListening() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);
      speech.listen(onResult: (result) {
        _controller.text = result.recognizedWords;
      });
    }
  }

  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  /// 📩 SEND MESSAGE
  Future sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      isLoading = true;
    });

    _controller.clear();

    String reply = await AIService.getResponse(text);

    setState(() {
      messages.add({"sender": "bot", "text": reply});
      isLoading = false;
    });

    speak(reply);
  }

  /// ➕ NEW CHAT
  void newChat() {
    setState(() {
      allChats.add([]);
      currentChatIndex = allChats.length - 1;
    });
  }

  /// 🗑 DELETE CHAT
  void deleteChat() {
    if (allChats.length <= 1) return;

    setState(() {
      allChats.removeAt(currentChatIndex);
      currentChatIndex = 0;
    });
  }

  /// 📜 PREVIOUS CHAT
  void previousChat() {
    if (allChats.length > 1) {
      setState(() {
        currentChatIndex =
            (currentChatIndex - 1 + allChats.length) % allChats.length;
      });
    }
  }

  /// 💬 MESSAGE UI
  Widget buildMessage(Map<String, String> message) {
    bool isUser = message["sender"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
            colors: [Colors.green, Colors.teal],
          )
              : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message["text"]!,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),

      /// 🔥 APPBAR WITH + MENU
      appBar: AppBar(
        title: const Text("Eco Chat AI"),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              if (value == "new") {
                newChat();
              } else if (value == "delete") {
                deleteChat();
              } else if (value == "previous") {
                previousChat();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "new",
                child: Text("➕ New Chat"),
              ),
              const PopupMenuItem(
                value: "delete",
                child: Text("🗑 Delete Chat"),
              ),
              const PopupMenuItem(
                value: "previous",
                child: Text("📜 Previous Chat"),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [

          /// 💬 CHAT
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          /// 🤖 LOADING
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 10),
                  Text("AI is thinking..."),
                ],
              ),
            ),

          /// 🔥 INPUT
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [

                  /// 🎤 MIC
                  IconButton(
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.green,
                    ),
                    onPressed:
                    isListening ? stopListening : startListening,
                  ),

                  /// TEXT
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Ask something...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  /// SEND
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}