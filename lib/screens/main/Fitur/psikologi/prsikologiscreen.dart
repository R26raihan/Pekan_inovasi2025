import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pekan_innovasi/screens/main/chatbot/servicechatbot.dart';

class Psikologi extends StatefulWidget {
  const Psikologi({super.key});

  @override
  _PsikologiState createState() => _PsikologiState();
}

class _PsikologiState extends State<Psikologi> with SingleTickerProviderStateMixin {
  late final FlutterTts _flutterTts;
  final List<String> _paragraphs = [
    'PTSD adalah kondisi mental yang bisa muncul setelah seseorang mengalami atau melihat kejadian yang sangat menakutkan.',
    'Di halaman ini, Anda akan menjawab 20 pertanyaan sederhana untuk memeriksa apakah Anda memiliki tanda-tanda PTSD.',
    'Jawab semua pertanyaan dengan jujur agar Anda tahu hasilnya dan mendapat saran apa yang harus dilakukan selanjutnya.',
  ];

  final List<int> _responses = List.generate(20, (_) => -1);
  final ScrollController _scrollController = ScrollController();

  bool _showInstructions = true;
  bool _isSpeaking = false;
  int _currentParagraphIndex = 0;
  int _totalScore = 0;
  bool _showScore = false;
  String? _botResponse;
  bool _loadingBot = false;
  bool _showResultScreen = false;

  late AnimationController _animationController;
  late Animation<double> _botAnimation;
  late Animation<double> _textAnimation;

  final ChatbotService _chatbotService = ChatbotService();

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _initTTS();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _botAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initTTS() async {
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    _speakParagraph(0);
  }

  Future<void> _speakParagraph(int index) async {
    if (index >= _paragraphs.length || !_showInstructions) return;

    setState(() {
      _currentParagraphIndex = index;
      _isSpeaking = true;
    });

    await _flutterTts.speak(_paragraphs[index]);
    await _flutterTts.awaitSpeakCompletion(true);

    setState(() {
      _isSpeaking = false;
    });

    if (index + 1 < _paragraphs.length) {
      await Future.delayed(const Duration(milliseconds: 300));
      _speakParagraph(index + 1);
    } else {
      setState(() {
        _showInstructions = false;
        _flutterTts.stop();
      });
    }
  }

  void _toggleTTS() {
    if (_isSpeaking) {
      _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      _speakParagraph(_currentParagraphIndex);
    }
  }

  void _calculateScore() async {
    if (_responses.contains(-1)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Perhatian', style: TextStyle(color: Colors.tealAccent)),
          content: const Text(
            'Silakan jawab semua pertanyaan terlebih dahulu',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey.shade900,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.tealAccent)),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _totalScore = _responses.reduce((a, b) => a + b);
      _showScore = true;
      _botResponse = null;
      _loadingBot = true;
      _showResultScreen = true; // Pindah ke layar hasil
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.reset();
      _animationController.forward();
    });

    final String prompt = "Skor PTSD saya adalah $_totalScore/80. Tolong berikan saran untuk kondisi saya.";
    final String response = await _chatbotService.getBotReply(prompt);

    print("Response from bot: $response"); // Debugging log

    setState(() {
      _botResponse = response;
      _loadingBot = false;
    });

    if (_botResponse != null) {
      _speakText(_botResponse!); // Baca respon via TTS
    }
  }

  Future<void> _speakText(String text) async {
    setState(() => _isSpeaking = true);
    await _flutterTts.speak(text);
    await _flutterTts.awaitSpeakCompletion(true);
    setState(() => _isSpeaking = false);
  }

  String _getInterpretation() {
    if (_totalScore < 20) return 'Gejala PTSD Minimal';
    if (_totalScore < 40) return 'Gejala PTSD Ringan';
    if (_totalScore < 60) return 'Gejala PTSD Sedang';
    return 'Gejala PTSD Berat - Segera konsultasi dengan profesional';
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade900,
      child: _showResultScreen
          ? _buildBotResultScreen()
          : _showInstructions
              ? Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      minHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 100,
                      ),
                      child: _buildHeader(),
                    ),
                  ),
                )
              : Center(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 80,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(20, (index) => _buildQuestionItem(index)),
                          _buildScoreSection(),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildBotResultScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _botAnimation,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.tealAccent,
                  backgroundImage: const AssetImage('images/botpsikologi.png'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_loadingBot)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Colors.tealAccent),
              ),
            if (_botResponse != null)
              FadeTransition(
                opacity: _textAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: Colors.blueGrey.shade800,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _botResponse!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.tealAccent,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (_botResponse != null && !_isSpeaking) {
                  _speakText(_botResponse!);
                }
              },
              icon: Icon(_isSpeaking ? Icons.volume_off : Icons.volume_up),
              label: Text(_isSpeaking ? "Berhenti" : "Dengarkan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _botAnimation,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.tealAccent.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.tealAccent,
              backgroundImage: const AssetImage('images/botpsikologi.png'),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FadeTransition(
          opacity: _textAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(minHeight: 150),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueGrey.shade900,
                    Colors.tealAccent.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.tealAccent, width: 1.5),
              ),
              child: Stack(
                children: [
                  Text(
                    _paragraphs[_currentParagraphIndex],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.tealAccent,
                      height: 1.4,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildMuteButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMuteButton() {
    return GestureDetector(
      onTap: _toggleTTS,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade800,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.tealAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.tealAccent.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          _isSpeaking ? Icons.volume_up : Icons.volume_off,
          size: 18,
          color: Colors.tealAccent,
        ),
      ),
    );
  }

  Widget _buildQuestionItem(int index) {
    return Card(
      color: Colors.blueGrey.shade800,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${_getQuestion(index)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(5, (i) => _buildRadioOption(index, i)),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(int questionIndex, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RadioListTile<int>(
        title: Text(
          _getOptionLabel(value),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        value: value,
        groupValue: _responses[questionIndex],
        dense: true,
        contentPadding: EdgeInsets.zero,
        toggleable: true,
        activeColor: Colors.tealAccent,
        onChanged: (int? value) {
          setState(() => _responses[questionIndex] = value ?? -1);
        },
      ),
    );
  }

  Widget _buildScoreSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.tealAccent.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _calculateScore,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.blueGrey.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'HITUNG SKOR SAYA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_showScore)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade800,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    'SKOR TOTAL: $_totalScore/80',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getInterpretation(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.tealAccent,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getQuestion(int index) {
    switch (index) {
      case 0:
        return 'Sering tiba-tiba teringat kejadian buruk yang membuat Anda terganggu?';
      case 1:
        return 'Pernah mimpi buruk tentang kejadian buruk yang mengganggu Anda?';
      case 2:
        return 'Pernah merasa seolah-olah kejadian buruk itu terjadi lagi?';
      case 3:
        return 'Merasa sangat terganggu saat sesuatu mengingatkan Anda pada kejadian buruk?';
      case 4:
        return 'Pernah merasa jantungan, sesak napas, atau berkeringat saat teringat kejadian buruk?';
      case 5:
        return 'Berusaha menghindari memikirkan atau merasakan apa pun tentang kejadian buruk?';
      case 6:
        return 'Menghindari orang, tempat, atau hal yang mengingatkan pada kejadian buruk?';
      case 7:
        return 'Sulit mengingat bagian penting dari kejadian buruk itu?';
      case 8:
        return 'Merasa diri Anda buruk, orang lain tidak bisa dipercaya, atau dunia sangat berbahaya?';
      case 9:
        return 'Menyalahkan diri sendiri atau orang lain atas kejadian buruk itu?';
      case 10:
        return 'Sering merasa sangat takut, marah, bersalah, atau malu?';
      case 11:
        return 'Tidak lagi menikmati kegiatan yang dulu Anda suka?';
      case 12:
        return 'Merasa jauh atau tidak dekat dengan orang lain?';
      case 13:
        return 'Sulit merasa bahagia atau sayang pada orang terdekat?';
      case 14:
        return 'Mudah marah atau bertindak agresif?';
      case 15:
        return 'Sering melakukan hal berisiko yang bisa membahayakan diri Anda?';
      case 16:
        return 'Selalu merasa sangat waspada atau hati-hati?';
      case 17:
        return 'Mudah kaget atau merasa terkejut?';
      case 18:
        return 'Sulit fokus atau berkonsentrasi?';
      case 19:
        return 'Sulit tidur atau sering terbangun di malam hari?';
      default:
        return '';
    }
  }

  String _getOptionLabel(int i) {
    switch (i) {
      case 0:
        return 'Tidak sama sekali';
      case 1:
        return 'Sedikit';
      case 2:
        return 'Sedang';
      case 3:
        return 'Cukup';
      case 4:
        return 'Sangat';
      default:
        return '';
    }
  }
}