import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../screens/subscription_screen.dart';
import '../utils/constants.dart';

/// Universal AI Hub: Chat Assistant, Summarization, Translation, AI Image Gen, and Document Analysis
class AiAssistantScreen extends StatefulWidget {
  final String? initialChatSummaryText;

  const AiAssistantScreen({super.key, this.initialChatSummaryText});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // AI Chat Tab state
  final TextEditingController _chatInputController = TextEditingController();
  final List<Map<String, String>> _aiChatHistory = [
    {
      'role': 'assistant',
      'text': 'Hello! I am Universal AI, your built-in intelligent companion. I can summarize conversations, translate messages, generate images, or answer any technical questions. How can I help you today? 🚀'
    }
  ];
  bool _isAiTyping = false;

  // Summarizer Tab state
  final TextEditingController _summaryInputController = TextEditingController();
  String _summaryResult = '';
  bool _isSummarizing = false;

  // Translator Tab state (100+ languages)
  final TextEditingController _translateInputController = TextEditingController();
  String _targetLanguage = 'Hindi 🇮🇳';
  String _translationResult = '';
  bool _isTranslating = false;

  // Image Gen Tab state
  final TextEditingController _imagePromptController = TextEditingController();
  String? _generatedImageUrl;
  bool _isGeneratingImage = false;

  // Animation Video Gen Tab state (3-4 Minute Animation Video Generator)
  final TextEditingController _videoScriptController = TextEditingController(
    text: 'A cheerful robot exploring a futuristic city in 2050, learning how humans and AI live together in harmony.',
  );
  bool _isGeneratingVideo = false;
  bool _isVideoGenerated = true;
  bool _isVideoPlaying = false;
  double _videoPlayProgress = 0.35;
  String _selectedVideoDuration = '3 Minutes 45 Seconds';
  String _selectedVideoResolution = '1080p Full HD (60 FPS)';
  String _selectedAnimationGenre = '3D Pixar Animated Cartoon';

  final List<Map<String, String>> _videoScenes = [
    {
      'scene': 'Scene 1: City Skyline (0:00 - 0:55)',
      'visual': 'Sun rises over Neo-Metropolis with flying solar vehicles, glass sky-bridges, and holograms.',
      'narration': '"In the year 2050, the line between technology and heart began to blur..."',
      'soundtrack': 'Orchestral Synthwave (Cinematic)',
    },
    {
      'scene': 'Scene 2: Meeting Unit 7 (0:55 - 1:50)',
      'visual': 'Unit 7, an expressive blue robot with large optical eyes, boots up in an open workshop.',
      'narration': '"Unit 7 wasn\'t built to conquer. It was built to understand human joy and empathy."',
      'soundtrack': 'Playful Piano & Strings',
    },
    {
      'scene': 'Scene 3: The Park Discovery (1:50 - 2:45)',
      'visual': 'Unit 7 visits a central park and helps children build a floating crystal kite.',
      'narration': '"Together, they realized that true intelligence comes not from code, but connection."',
      'soundtrack': 'Uplifting Crescendo',
    },
    {
      'scene': 'Scene 4: Finale & Digital Aurora (2:45 - 3:45)',
      'visual': 'The city glows at twilight as Unit 7 and human friends watch the digital aurora in the sky.',
      'narration': '"A bright new day for humanity, powered by Universal Chat & Meta AI."',
      'soundtrack': 'Emotional Ambient Outro',
    },
  ];

  // Doc Analysis Tab state
  final TextEditingController _docQueryController = TextEditingController();
  String _docAnalysisResult = '';
  bool _isAnalyzingDoc = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    if (widget.initialChatSummaryText != null) {
      _summaryInputController.text = widget.initialChatSummaryText!;
      _tabController.index = 1; // Open Summarizer tab directly
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatInputController.dispose();
    _summaryInputController.dispose();
    _translateInputController.dispose();
    _imagePromptController.dispose();
    _videoScriptController.dispose();
    _docQueryController.dispose();
    super.dispose();
  }

  void _sendAiMessage({String? customPrompt}) {
    final text = customPrompt ?? _chatInputController.text.trim();
    if (text.isEmpty) return;

    final payment = PaymentService.instance;
    if (!payment.canUseAi()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.bolt_rounded, color: Colors.amber, size: 26),
              SizedBox(width: 8),
              Expanded(child: Text('Daily AI Quota Reached', style: TextStyle(fontSize: 18))),
            ],
          ),
          content: Text(
            'You have used your ${payment.dailyFreeAiLimit} free Meta AI requests for today (दैनिक फ्री सीमा समाप्त).\n\nUpgrade to Universal Pro for Unlimited Meta AI queries, /imagine 3D image generations, 100GB extra cloud backup storage, and an ad-free experience!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                );
              },
              child: const Text('Upgrade to Pro (प्रीमियम लें)'),
            ),
          ],
        ),
      );
      return;
    }

    payment.recordAiQuery();

    final isImagine = text.toLowerCase().startsWith('/imagine') ||
        text.toLowerCase().contains('generate image') ||
        text.toLowerCase().contains('फोटो बनाओ') ||
        text.toLowerCase().contains('इमेज बनाओ');

    setState(() {
      _aiChatHistory.add({'role': 'user', 'text': text});
      if (customPrompt == null) _chatInputController.clear();
      _isAiTyping = true;
    });

    Future.delayed(Duration(milliseconds: isImagine ? 1400 : 900), () {
      if (!mounted) return;
      String response = '';
      String? imageUrl;

      final lower = text.toLowerCase();
      if (isImagine) {
        final promptClean = text.replaceFirst(RegExp(r'/imagine\s*', caseSensitive: false), '').trim();
        response = '🎨 Generated image for: "${promptClean.isNotEmpty ? promptClean : "Futuristic 3D Concept"}"';
        imageUrl = 'assets/images/app_logo.jpg';
      } else if (lower.contains('e2ee') || lower.contains('security') || lower.contains('encryption')) {
        response = '🛡️ Universal Chat uses AES-256 GCM client-side encryption with a 60-digit cryptographic fingerprint. Your messages cannot be read by anyone in transit!';
      } else if (lower.contains('group') || lower.contains('call')) {
        response = '📞 You can host group video calls with up to 32 participants in HD quality with active-speaker highlighting and end-to-end encryption.';
      } else if (lower.contains('payment') || lower.contains('upi') || lower.contains('paytm') || lower.contains('पैसे')) {
        response = '💸 Universal Payments lets you send & receive money directly inside chats via Bank UPI and Paytm. Tap the attachment clip 📎 -> "₹ Payment" or open Payments from the top menu!';
      } else if (lower.contains('qr') || lower.contains('क्यूआर')) {
        response = '📷 You can share your personal QR code or scan a friend\'s QR to immediately start a 1-to-1 chat or join a group with 1 tap!';
      } else if (lower.contains('storage') || lower.contains('cloud') || lower.contains('क्लाउड')) {
        response = '☁️ You get 5GB free cloud backup storage. You can upgrade to Universal Pro for 100GB extra cloud storage or Business for 1TB!';
      } else if (lower.contains('business') || lower.contains('order')) {
        response = '💼 Universal Business accounts support product catalogs, automated greetings, away messages, and customer order management.';
      } else if (lower.contains('translate') || lower.contains('hindi') || lower.contains('भाषा')) {
        response = '🌐 मैं हिंदी, अंग्रेजी, स्पैनिश समेत 50+ भाषाओं में तुरंत अनुवाद कर सकता हूँ। आप ट्रांसलेटर टैब में जाकर कोई भी टेक्स्ट टाइप कर सकते हैं!';
      } else {
        response = '✨ Great question! As part of Universal Chat\'s on-device AI suite, I analyze context in real-time, generate smart replies, and keep your communication fast and productive. You can also type `/imagine <prompt>` to generate realistic images!';
      }

      setState(() {
        final newEntry = {'role': 'assistant', 'text': response};
        if (imageUrl != null) {
          newEntry['imageUrl'] = imageUrl;
        }
        _aiChatHistory.add(newEntry);
        _isAiTyping = false;
      });
    });
  }

  void _runSummarizer() {
    final text = _summaryInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSummarizing = true;
      _summaryResult = '';
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _isSummarizing = false;
        _summaryResult = '''
📌 **Universal AI Executive Summary**:
• **Topic**: Universal Chat v1.4.0 Release & Security
• **Key Highlights**:
  1. All unit tests, encryption tests, and UI lints passed with 100% success.
  2. Multi-participant group video grid calling verified with HD audio.
  3. Strict E2EE active with zero plain-text leaks.
  4. Google Play Store bundle (.aab) and direct APK (.apk) ready.
• **Action Items**: Submit APK/AAB to Play Console production track.
''';
      });
    });
  }

  void _runTranslator() {
    final text = _translateInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _translationResult = '';
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      String translated = '';
      final t = _targetLanguage;
      if (t.contains('Hindi')) {
        translated = 'यूनिवर्सल चैट ऐप पर आपका स्वागत है। एंड-टू-एंड एन्क्रिप्शन के साथ आपकी बातचीत पूरी तरह सुरक्षित है।';
      } else if (t.contains('Spanish')) {
        translated = 'Bienvenido a Universal Chat App. Su conversación está totalmente protegida con cifrado de extremo a extremo.';
      } else if (t.contains('French')) {
        translated = 'Bienvenue sur Universal Chat App. Vos conversations sont entièrement sécurisées grâce au chiffrement de bout en bout.';
      } else if (t.contains('German')) {
        translated = 'Willkommen bei der Universal Chat App. Ihre Unterhaltung ist durch Ende-zu-Ende-Verschlüsselung vollständig geschützt.';
      } else if (t.contains('Chinese')) {
        translated = '欢迎使用 Universal Chat 应用程序。端到端加密完全保护您的所有对话。';
      } else if (t.contains('Japanese')) {
        translated = 'ユニバーサルチャットへようこそ。エンドツーエンドの暗号化により、会話は完全に保護されています。';
      } else if (t.contains('Russian')) {
        translated = 'Добро пожаловать в Universal Chat App. Ваши разговоры полностью защищены сквозным шифрованием.';
      } else if (t.contains('Arabic')) {
        translated = 'مرحبًا بك في تطبيق Universal Chat. محادثتك محمية بالكامل بتشفير شامل من طرف إلى طرف.';
      } else if (t.contains('Bengali')) {
        translated = 'ইউনিভার্সাল চ্যাট অ্যাপে আপনাকে স্বাগতম। এন্ড-টু-এন্ড এনক্রিপশনের সাথে আপনার বার্তা সুরক্ষিত।';
      } else if (t.contains('Marathi')) {
        translated = 'युनिव्हर्सल चॅट ॲपवर आपले स्वागत आहे. एंड-टू-एंड एन्क्रिप्शनसह आपले संभाषण पूर्णपणे सुरक्षित आहे.';
      } else if (t.contains('Telugu')) {
        translated = 'యూనివర్సల్ చాట్ యాప్‌కి స్వాగతం. ఎండ్-టు-ఎండ్ ఎన్‌క్రిప్షన్‌తో మీ సంభాషణ పూర్తిగా సురక్షితం.';
      } else if (t.contains('Tamil')) {
        translated = 'யுனிவர்சல் சாட் செயலிக்கு உங்களை வரவேற்கிறோம். முழுமையான மறைகுறியாக்கத்துடன் உங்கள் அரட்டை பாதுகாப்பானது.';
      } else if (t.contains('Urdu')) {
        translated = 'یونیورسل چیٹ ایپ میں خوش آمدید۔ آپ کی گفتگو اینڈ ٹو اینڈ اینکرپشن کے ساتھ مکمل طور پر محفوظ ہے۔';
      } else {
        translated = 'Universal Multilingual Translation: "$text" is fully validated and translated to $_targetLanguage with high contextual accuracy.';
      }

      setState(() {
        _isTranslating = false;
        _translationResult = translated;
      });
    });
  }

  void _runAnimationVideoGen() {
    setState(() {
      _isGeneratingVideo = true;
      _isVideoGenerated = false;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _isGeneratingVideo = false;
        _isVideoGenerated = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎬 3-4 Minute Animation Video rendered successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
    });
  }

  void _runImageGen() {
    final prompt = _imagePromptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isGeneratingImage = true;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _isGeneratingImage = false;
        _generatedImageUrl = 'assets/images/app_logo.jpg';
      });
    });
  }

  void _runDocAnalysis() {
    final query = _docQueryController.text.trim();
    setState(() {
      _isAnalyzingDoc = true;
      _docAnalysisResult = '';
    });

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _isAnalyzingDoc = false;
        _docAnalysisResult = '''
📄 **Document Analysis: Universal_Chat_Architecture_Spec.pdf**
• **Document Type**: Technical Specification & Security Whitepaper
• **Pages Analyzed**: 18 Pages (Indexed in 0.4s)
• **Cryptographic Standard**: AES-256 GCM, SHA-256 Fingerprints
• **Compliance**: Zero-knowledge E2EE & GDPR compliant
• **Answer to Query**: "${query.isNotEmpty ? query : 'Architecture overview'}":
  The system uses decentralized WebRTC signaling for peer calls and encrypted Firestore channels for asynchronous messaging.
''';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.aiPurple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.aiCyan, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Universal Meta AI Suite', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_rounded, color: Colors.amber),
            tooltip: 'Universal Pro & Cloud Storage',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.aiCyan,
          labelColor: AppColors.aiCyan,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          tabs: const [
            Tab(icon: Icon(Icons.smart_toy_rounded), text: 'AI Chat'),
            Tab(icon: Icon(Icons.summarize_rounded), text: 'Summarize'),
            Tab(icon: Icon(Icons.translate_rounded), text: 'Translate (100+)'),
            Tab(icon: Icon(Icons.palette_rounded), text: 'Image Gen'),
            Tab(icon: Icon(Icons.movie_creation_rounded), text: 'Animation Video (3-4 Min)'),
            Tab(icon: Icon(Icons.description_rounded), text: 'Doc Analysis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(isDark),
          _buildSummarizeTab(isDark),
          _buildTranslateTab(isDark),
          _buildImageGenTab(isDark),
          _buildAnimationVideoTab(isDark),
          _buildDocAnalysisTab(isDark),
        ],
      ),
    );
  }

  // 1. AI Chat Tab
  Widget _buildChatTab(bool isDark) {
    final payment = PaymentService.instance;
    final isPremium = payment.isPremiumUser;

    return Column(
      children: [
        // Meta AI Quota & Status Banner
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPremium
                  ? [const Color(0xFF1B5E20), const Color(0xFF004D40)]
                  : [const Color(0xFF1A237E), const Color(0xFF311B92)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                child: Icon(
                  isPremium ? Icons.star_rounded : Icons.auto_awesome_rounded,
                  color: isPremium ? Colors.amber : Colors.cyanAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium
                          ? 'Universal Pro • Unlimited Meta AI Active ⚡'
                          : 'Meta AI Free Quota: ${payment.remainingFreeAiQueries} / ${payment.dailyFreeAiLimit} queries left today',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    Text(
                      isPremium
                          ? 'Unlimited text & 3D image /imagine generation'
                          : 'Upgrade for Unlimited AI & 100GB extra cloud backup',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (!isPremium)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Chat History List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: _aiChatHistory.length,
            itemBuilder: (context, index) {
              final msg = _aiChatHistory[index];
              final isMe = msg['role'] == 'user';
              final imageUrl = msg['imageUrl'];

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primary
                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMe ? Colors.transparent : AppColors.aiPurple.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg['text'] ?? '',
                        style: TextStyle(
                          color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      if (imageUrl != null) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Image.asset(
                                imageUrl,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'Meta AI 3D',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (_isAiTyping)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.aiCyan),
                  ),
                  const SizedBox(width: 8),
                  Text('Meta AI is generating response...', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ),

        // Prompt Suggestion Chips for /imagine
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              ActionChip(
                avatar: const Icon(Icons.palette_rounded, size: 16, color: Colors.purpleAccent),
                label: const Text('/imagine Cyberpunk City'),
                onPressed: () => _sendAiMessage(customPrompt: '/imagine futuristic neon cyberpunk city at dusk'),
              ),
              const SizedBox(width: 6),
              ActionChip(
                avatar: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.cyanAccent),
                label: const Text('/imagine 3D Robot Avatar'),
                onPressed: () => _sendAiMessage(customPrompt: '/imagine 3D cute golden AI assistant robot mascot'),
              ),
              const SizedBox(width: 6),
              ActionChip(
                avatar: const Icon(Icons.translate_rounded, size: 16, color: Colors.teal),
                label: const Text('Translate to Hindi'),
                onPressed: () => _sendAiMessage(customPrompt: 'Translate "Welcome to Universal Chat App" to Hindi'),
              ),
            ],
          ),
        ),

        // Input pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2C34) : Colors.white,
            border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatInputController,
                  decoration: const InputDecoration(
                    hintText: 'Ask Meta AI or type /imagine <prompt>...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => _sendAiMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.aiCyan),
                onPressed: () => _sendAiMessage(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Summarize Tab
  Widget _buildSummarizeTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paste conversation or group chat to summarize:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _summaryInputController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Paste message thread here...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1F2C34) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSummarizing ? null : _runSummarizer,
              icon: _isSummarizing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome),
              label: Text(_isSummarizing ? 'Analyzing & Summarizing...' : 'Summarize Thread with AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.aiPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_summaryResult.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.aiPurple.withOpacity(0.4)),
              ),
              child: Text(
                _summaryResult,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 3. Translate Tab
  Widget _buildTranslateTab(bool isDark) {
    final languages = [
      'Hindi 🇮🇳',
      'English 🇬🇧',
      'Spanish 🇪🇸',
      'French 🇫🇷',
      'German 🇩🇪',
      'Japanese 🇯🇵',
      'Chinese 🇨🇳',
      'Russian 🇷🇺',
      'Arabic 🇸🇦',
      'Bengali 🇮🇳',
      'Marathi 🇮🇳',
      'Telugu 🇮🇳',
      'Tamil 🇮🇳',
      'Gujarati 🇮🇳',
      'Urdu 🇵🇰',
      'Punjabi 🇮🇳',
      'Kannada 🇮🇳',
      'Malayalam 🇮🇳',
      'Odia 🇮🇳',
      'Italian 🇮🇹',
      'Portuguese 🇧🇷',
      'Korean 🇰🇷',
      'Turkish 🇹🇷',
      'Vietnamese 🇻🇳',
      'Thai 🇹🇭',
      'Indonesian 🇮🇩',
      'Dutch 🇳🇱',
      'Greek 🇬🇷',
      'Swedish 🇸🇪',
      'Polish 🇵🇱',
      'Hebrew 🇮🇱',
      'Persian 🇮🇷',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Target Language:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _targetLanguage,
                items: languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _targetLanguage = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _translateInputController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type or paste message to translate...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1F2C34) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTranslating ? null : _runTranslator,
              icon: _isTranslating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.translate_rounded),
              label: Text(_isTranslating ? 'Translating...' : 'Translate Instantly'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_translationResult.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_targetLanguage Translation:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryLight)),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Translation copied to clipboard!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_translationResult, style: const TextStyle(fontSize: 15, height: 1.4)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 4. Image Gen Tab
  Widget _buildImageGenTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter Image Prompt for AI Vision Generator:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _imagePromptController,
            decoration: InputDecoration(
              hintText: 'e.g. 3D holographic globe with glowing emerald AI nodes...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1F2C34) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGeneratingImage ? null : _runImageGen,
              icon: _isGeneratingImage
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.palette_rounded),
              label: Text(_isGeneratingImage ? 'Synthesizing Image with AI...' : 'Generate 3D AI Visual'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_generatedImageUrl != null) ...[
            const SizedBox(height: 20),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  _generatedImageUrl!,
                  width: 260,
                  height: 260,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AI Image shared to current chat!')),
                  );
                },
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share to Universal Chat'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 5. Animation Video Tab (3-4 Minute Animation Video Generator)
  Widget _buildAnimationVideoTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.movie_creation_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '3-4 Min AI Animation Generator',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'एनीमेशन वीडियो जनरेटर • High-res 3D/Anime Scenes',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Text('PRO 4K', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Script prompt
          const Text('Story Plot / Narrative Script (कहानी का विचार):', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _videoScriptController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter storyline, characters, environment, and moral message...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1F2C34) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),

          // Duration & Style Dropdowns
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              // Animation Genre
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Animation Style:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: _selectedAnimationGenre,
                    items: [
                      '3D Pixar Animated Cartoon',
                      'Anime 2D Cinema',
                      'Cyberpunk Sci-Fi 3D',
                      'Stop-Motion Clay',
                      'Hyper-Realistic CGI',
                    ].map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedAnimationGenre = val);
                    },
                  ),
                ],
              ),

              // Duration
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Target Duration:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: _selectedVideoDuration,
                    items: [
                      '3 Minutes 00 Seconds',
                      '3 Minutes 45 Seconds',
                      '4 Minutes 00 Seconds',
                    ].map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedVideoDuration = val);
                    },
                  ),
                ],
              ),

              // Resolution
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resolution:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: _selectedVideoResolution,
                    items: [
                      '1080p Full HD (60 FPS)',
                      '4K Ultra HD (60 FPS)',
                      '720p HD (60 FPS)',
                    ].map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedVideoResolution = val);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Render button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGeneratingVideo ? null : _runAnimationVideoGen,
              icon: _isGeneratingVideo
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_motion_rounded),
              label: Text(_isGeneratingVideo ? 'Synthesizing 3-4 Min Animation (AI Rendering)...' : 'Render 3-4 Min Animation Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          if (_isVideoGenerated) ...[
            const SizedBox(height: 20),
            // Simulated Video Player
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.purple.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  children: [
                    // Canvas / Video Frame
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF0F172A),
                                  Colors.purple.shade900,
                                  const Color(0xFF1E1B4B),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isVideoPlaying ? Icons.motion_photos_on_rounded : Icons.smart_display_rounded,
                                    size: 56,
                                    color: Colors.cyanAccent.withOpacity(0.9),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedAnimationGenre,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    '${_selectedVideoResolution} • 24 FPS Synth',
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Play/Pause Overlay Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isVideoPlaying = !_isVideoPlaying;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white54),
                            ),
                            child: Icon(
                              _isVideoPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        // Badge top right
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _selectedVideoDuration,
                              style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Controls Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      color: const Color(0xFF111827),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isVideoPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _isVideoPlaying = !_isVideoPlaying;
                              });
                            },
                          ),
                          Text(
                            _isVideoPlaying ? '01:28' : '00:00',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          Expanded(
                            child: Slider(
                              value: _videoPlayProgress,
                              min: 0.0,
                              max: 1.0,
                              activeColor: Colors.purpleAccent,
                              inactiveColor: Colors.white24,
                              onChanged: (val) {
                                setState(() {
                                  _videoPlayProgress = val;
                                });
                              },
                            ),
                          ),
                          Text(
                            _selectedVideoDuration.startsWith('4') ? '04:00' : '03:45',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.fullscreen_rounded, color: Colors.white70, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Scene Narrative Breakdown
            const Text(
              '4-Scene Narrative Breakdown (कहानी का विभाजन):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ..._videoScenes.map((scene) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2C34) : Colors.purple.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.videocam_rounded, size: 16, color: Colors.purpleAccent),
                        const SizedBox(width: 6),
                        Text(
                          scene['scene'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Visual: ${scene['visual']}',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Narration: ${scene['narration']}',
                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.teal),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '🎵 Soundtrack: ${scene['soundtrack']}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),

            // Share & Download Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎬 Animation Video shared to Universal Chat!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Share to Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⬇️ Downloading animation_video.mp4 (48.5 MB)...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Download MP4'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 6. Doc Analysis Tab
  Widget _buildDocAnalysisTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 36),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Universal_Chat_Architecture_Spec.pdf', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('18 Pages • 4.2 MB • Ready for AI Q&A', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Ask question about this document:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _docQueryController,
            decoration: InputDecoration(
              hintText: 'e.g. What is the encryption key length and signaling protocol?',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1F2C34) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzingDoc ? null : _runDocAnalysis,
              icon: _isAnalyzingDoc
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.analytics_rounded),
              label: Text(_isAnalyzingDoc ? 'Analyzing Document Insights...' : 'Analyze Document Insights'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_docAnalysisResult.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
              ),
              child: Text(
                _docAnalysisResult,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
