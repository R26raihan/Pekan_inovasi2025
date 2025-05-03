import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'servicechatbot.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _chatbotService = ChatbotService();
  bool _isLoading = false;

  // Voice variables
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _speechText = '';
  bool _isWidgetActive = true; // Track widget lifecycle

  // Animation variables
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<double> _audioLevels = [];
  Timer? _audioLevelTimer;
  bool _showVoiceUI = false;

  @override
  void initState() {
    super.initState();
    _isWidgetActive = true;
    _loadMessages();
    _initializeSpeech();
    _initializeTts();

    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        if (mounted && _isWidgetActive) {
          setState(() {});
        }
      });
    _animationController.repeat(reverse: true);
  }

  void _initializeSpeech() {
    _speech = stt.SpeechToText();
    _speechText = '';
    _isListening = false;
    _showVoiceUI = false;
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('id-ID');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
  }

  @override
  void dispose() {
    _isWidgetActive = false;
    _animationController.dispose();
    _audioLevelTimer?.cancel();
    _controller.dispose();
    _speech.stop();
    _speech.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? messagesJson = prefs.getString('chat_messages');
    if (messagesJson != null) {
      final List<dynamic> messagesList = jsonDecode(messagesJson);
      if (mounted && _isWidgetActive) {
        setState(() {
          _messages.addAll(
            messagesList.map((m) => _Message.fromJson(m)).toList(),
          );
        });
      }
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String messagesJson = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('chat_messages', messagesJson);
  }

  Future<void> _clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages');
    if (mounted && _isWidgetActive) {
      setState(() {
        _messages.clear();
      });
    }
  }

  void _sendMessage([String? text]) async {
    final msg = text?.trim() ?? _controller.text.trim();
    if (msg.isEmpty) return;

    if (mounted && _isWidgetActive) {
      setState(() {
        _messages.add(_Message(text: msg, isUser: true));
        _isLoading = true;
        _controller.clear();
        _showVoiceUI = false;
      });
    }
    await _saveMessages();

    try {
      // Dapatkan respons dari chatbot
      dynamic response = await _chatbotService.getBotReply(msg);
      print('Raw response: $response'); // Debugging respons mentah

      String? reasoning;
      String botReply;

      // Cek apakah respons adalah JSON atau string
      if (response is String) {
        botReply = response;
      } else if (response is Map && response.containsKey('choices')) {
        var choice = response['choices'][0]['message'];
        reasoning = choice['reasoning']?.toString();
        botReply = choice['content']?.toString() ?? 'Maaf, tidak ada respons.';
      } else {
        botReply = 'Maaf, respons tidak valid.';
      }

      if (mounted && _isWidgetActive) {
        setState(() {
          // Tambahkan reasoning sebagai pesan terpisah jika ada
          if (reasoning != null && reasoning.isNotEmpty) {
            _messages.add(_Message(
              text: 'Berpikir: $reasoning',
              isUser: false,
              isReasoning: true,
            ));
          }
          // Tambahkan respons utama
          _messages.add(_Message(text: botReply, isUser: false));
          _isLoading = false;
        });
      }
      await _saveMessages();
      if (_isWidgetActive) {
        await _speak(botReply);
      }
    } catch (e) {
      if (mounted && _isWidgetActive) {
        setState(() {
          _messages.add(_Message(text: 'Maaf, terjadi kesalahan: $e', isUser: false));
          _isLoading = false;
        });
      }
      await _saveMessages();
    }
  }

  Future<void> _startListening() async {
    if (!_isWidgetActive) return;

    // Reset speech state
    _speech.cancel();
    _initializeSpeech();

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && mounted && _isWidgetActive) {
          _stopListening();
          if (_speechText.isNotEmpty) {
            _sendMessage(_speechText);
          }
        }
      },
      onError: (error) {
        print('Speech error: $error');
        if (mounted && _isWidgetActive) {
          setState(() {
            _isListening = false;
            _showVoiceUI = false;
          });
        }
      },
    );

    if (available && mounted && _isWidgetActive) {
      setState(() {
        _isListening = true;
        _showVoiceUI = true;
        _speechText = '';
        _audioLevels = List.generate(20, (index) => 0.0);
      });

      _speech.listen(
        onResult: (val) {
          if (mounted && _isWidgetActive) {
            setState(() {
              _speechText = val.recognizedWords;
            });
          }
        },
        localeId: 'id_ID',
        listenMode: stt.ListenMode.confirmation,
      );

      _audioLevelTimer?.cancel();
      _audioLevelTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (mounted && _isWidgetActive) {
          setState(() {
            _audioLevels.removeAt(0);
            _audioLevels.add(Random().nextDouble() * 30 + 5);
          });
        } else {
          timer.cancel();
        }
      });
    } else {
      if (mounted && _isWidgetActive) {
        setState(() {
          _isListening = false;
          _showVoiceUI = false;
        });
      }
    }
  }

  Future<void> _stopListening() async {
    if (!_isWidgetActive) return;

    await _speech.stop();
    _audioLevelTimer?.cancel();
    if (mounted && _isWidgetActive) {
      setState(() {
        _isListening = false;
        if (_speechText.isEmpty) {
          _showVoiceUI = false;
        }
      });
    }
  }

  Future<void> _speak(String text) async {
    // Clean text from markdown symbols for better TTS
    text = text.replaceAll(RegExp(r'\*\*'), '');
    await _flutterTts.stop(); // Hentikan TTS sebelumnya
    await _flutterTts.speak(text);
  }

  Widget _buildBotMessage(String text, {bool isReasoning = false}) {
    // Handle markdown bold (**text**) for non-reasoning messages
    if (!isReasoning) {
      List<InlineSpan> spans = [];
      final parts = text.split(RegExp(r'(\*\*[^\*]+\*\*)')); // Match **text** with content

      for (var part in parts) {
        if (part.startsWith('**') && part.endsWith('**') && part.length > 4) {
          spans.add(TextSpan(
            text: part.substring(2, part.length - 2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ));
        } else {
          spans.add(TextSpan(
            text: part,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ));
        }
      }

      return SelectableText.rich(
        TextSpan(children: spans),
      );
    } else {
      // Reasoning ditampilkan dengan gaya italic dan warna lebih pudar
      return SelectableText(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      );
    }
  }

  Widget _buildVoiceUI() {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _stopListening,
          child: Container(
            color: Colors.black.withOpacity(0.7),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (_isListening)
                  ...List.generate(10, (index) {
                    final size = _audioLevels[index % _audioLevels.length] * 2;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.tealAccent.withOpacity(0.2),
                      ),
                    );
                  }),
                Transform.scale(
                  scale: _animation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.tealAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              _isListening ? 'Sedang mendengarkan...' : 'Tekan untuk berbicara',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_speechText.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _speechText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (_isListening)
              SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _audioLevels.map((level) {
                    return Container(
                      width: 4,
                      height: level,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        onClearChat: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Hapus Riwayat Chat'),
              content: const Text('Apakah Anda yakin ingin menghapus semua riwayat chat?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('BATAL'),
                ),
                TextButton(
                  onPressed: () {
                    _clearMessages();
                    Navigator.pop(context);
                  },
                  child: const Text('HAPUS'),
                ),
              ],
            ),
          );
        },
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueGrey.shade900,
                  Colors.blueGrey.shade800,
                ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, idx) {
                      if (_isLoading && idx == _messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset('images/BOT.png', width: 30, height: 30),
                                const SizedBox(width: 8),
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final msg = _messages[idx];
                      return Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? Colors.tealAccent.withOpacity(0.3)
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!msg.isUser) ...[
                                Image.asset('images/BOT.png', width: 30, height: 30),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: msg.isUser
                                    ? Text(
                                        msg.text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      )
                                    : _buildBotMessage(msg.text, isReasoning: msg.isReasoning),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1, color: Colors.white24),
                Container(
                  color: Colors.blueGrey.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          color: Colors.tealAccent,
                        ),
                        onPressed: _isListening ? _stopListening : _startListening,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.tealAccent,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Ketik atau tekan mic untuk bicara...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.blueGrey.shade800,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.tealAccent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.blueGrey,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showVoiceUI) _buildVoiceUI(),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final bool isReasoning;

  _Message({
    required this.text,
    required this.isUser,
    this.isReasoning = false,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'isReasoning': isReasoning,
      };

  factory _Message.fromJson(Map<String, dynamic> json) => _Message(
        text: json['text'],
        isUser: json['isUser'],
        isReasoning: json['isReasoning'] ?? false,
      );
}

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClearChat;

  const MainAppBar({super.key, required this.onClearChat});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Image.asset(
                'images/logo.png',
                height: 30,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: 12),
              Text(
                'Peduli Lindungi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete_rounded,
                color: Colors.tealAccent,
              ),
              onPressed: onClearChat,
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_rounded,
                color: Colors.tealAccent,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.tealAccent,
              ),
              onPressed: () {},
            ),
          ],
        ),
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}