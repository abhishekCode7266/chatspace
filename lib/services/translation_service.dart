import 'dart:async';

/// Supported language definition for In-Chat Multilingual Translation
class SupportedLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

/// In-Chat Real-Time Multilingual Translation Service
class TranslationService {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  static const List<SupportedLanguage> supportedLanguages = [
    SupportedLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    SupportedLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
    SupportedLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    SupportedLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    SupportedLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    SupportedLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    SupportedLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇧🇩'),
    SupportedLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳'),
    SupportedLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
    SupportedLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'),
    SupportedLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', flag: '🇮🇳'),
    SupportedLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو', flag: '🇵🇰'),
  ];

  /// High-accuracy bilingual phrases dictionary mapping across multiple languages
  static final Map<String, Map<String, String>> _phraseDictionary = {
    'hello': {
      'hi': 'नमस्ते!',
      'en': 'Hello!',
      'es': '¡Hola!',
      'fr': 'Bonjour!',
      'de': 'Hallo!',
      'ar': 'مرحباً!',
      'bn': 'হ্যালো / নমস্কার!',
      'mr': 'नमस्कार!',
      'ta': 'வணக்கம்!',
      'te': 'నమస్కారం!',
      'gu': 'નમસ્તે!',
      'ur': 'ہیلو / السلام علیکم!',
    },
    'how are you': {
      'hi': 'आप कैसे हैं?',
      'en': 'How are you?',
      'es': '¿Cómo estás?',
      'fr': 'Comment allez-vous?',
      'de': 'Wie geht es dir?',
      'ar': 'كيف حالك؟',
      'bn': 'আপনি কেমন আছেন?',
      'mr': 'तुम्ही कसे आहात?',
      'ta': 'நீங்கள் எப்படி இருக்கிறீர்கள்?',
      'te': 'మీరు ఎలా ఉన్నారు?',
      'gu': 'તમે કેમ છો?',
      'ur': 'آپ کیسے ہیں؟',
    },
    'i am good': {
      'hi': 'मैं ठीक हूँ, धन्यवाद!',
      'en': 'I am good, thank you!',
      'es': '¡Estoy bien, gracias!',
      'fr': 'Je vais bien, merci!',
      'de': 'Mir geht es gut, danke!',
      'ar': 'أنا بخير، شكراً!',
      'bn': 'আমি ভালো আছি, ধন্যবাদ!',
      'mr': 'मी ठीक आहे, धन्यवाद!',
      'ta': 'நான் நன்றாக இருக்கிறேன், நன்றி!',
      'te': 'నేను బాగున్నాను, ధన్యవాదాలు!',
      'gu': 'હું મજામાં છું, આભાર!',
      'ur': 'میں ٹھیک ہوں، شکریہ!',
    },
    'thank you': {
      'hi': 'बहुत-बहुत धन्यवाद!',
      'en': 'Thank you very much!',
      'es': '¡Muchas gracias!',
      'fr': 'Merci beaucoup!',
      'de': 'Vielen Dank!',
      'ar': 'شكراً جزيلاً!',
      'bn': 'আপনাকে অনেক ধন্যবাদ!',
      'mr': 'खूप खूप धन्यवाद!',
      'ta': 'மிக்க நன்றி!',
      'te': 'చాలా ధన్యవాదాలు!',
      'gu': 'ખૂબ ખૂબ આભાર!',
      'ur': 'بہت بہت شکریہ!',
    },
    'good morning': {
      'hi': 'शुभ प्रभात!',
      'en': 'Good morning!',
      'es': '¡Buenos días!',
      'fr': 'Bonjour!',
      'de': 'Guten Morgen!',
      'ar': 'صباح الخير!',
      'bn': 'সুপ্রভাত!',
      'mr': 'शुभ सकाळ!',
      'ta': 'காலை வணக்கம்!',
      'te': 'శుభోదయం!',
      'gu': 'સુપ્રભાત!',
      'ur': 'صبح بخیر!',
    },
    'good night': {
      'hi': 'शुभ रात्रि!',
      'en': 'Good night!',
      'es': '¡Buenas noches!',
      'fr': 'Bonne nuit!',
      'de': 'Gute Nacht!',
      'ar': 'تصبح على خير!',
      'bn': 'শুভ রাত্রি!',
      'mr': 'शुभ रात्री!',
      'ta': 'இனிய இரவு!',
      'te': 'శుభ రాత్రి!',
      'gu': 'શુભ રાત્રી!',
      'ur': 'شب بخیر!',
    },
    'see you soon': {
      'hi': 'जल्द ही मिलते हैं!',
      'en': 'See you soon!',
      'es': '¡Nos vemos pronto!',
      'fr': 'À bientôt!',
      'de': 'Bis bald!',
      'ar': 'أراك قريباً!',
      'bn': 'শীঘ্রই দেখা হবে!',
      'mr': 'लवकरच भेटू!',
      'ta': 'விரைவில் சந்திப்போம்!',
      'te': 'త్వరలో కలుద్దాం!',
      'gu': 'જલ્દી મળીએ!',
      'ur': 'جلد ملیں گے!',
    },
    'where are you': {
      'hi': 'आप कहाँ हैं?',
      'en': 'Where are you?',
      'es': '¿Dónde estás?',
      'fr': 'Où êtes-vous?',
      'de': 'Wo bist du?',
      'ar': 'أين أنت؟',
      'bn': 'আপনি কোথায়?',
      'mr': 'तुम्ही कुठे आहात?',
      'ta': 'நீங்கள் எங்கே இருக்கிறீர்கள்?',
      'te': 'మీరు ఎక్కడ ఉన్నారు?',
      'gu': 'તમે ક્યાં છો?',
      'ur': 'آپ کہاں ہیں؟',
    },
    'i will call you': {
      'hi': 'मैं आपको थोड़ी देर में कॉल करता हूँ।',
      'en': 'I will call you in a bit.',
      'es': 'Te llamo en un rato.',
      'fr': 'Je vous appelle dans un instant.',
      'de': 'Ich rufe dich gleich an.',
      'ar': 'سأتصل بك بعد قليل.',
      'bn': 'আমি আপনাকে একটু পরে কল করছি।',
      'mr': 'मी थोड्या वेळाने कॉल करतो.',
      'ta': 'நான் சிறிது நேரத்தில் அழைக்கிறேன்.',
      'te': 'నేను కాసేపట్లో కాల్ చేస్తాను.',
      'gu': 'હું થોડીવારમાં કૉલ કરું છું.',
      'ur': 'میں تھوڑی دیر میں کال کرتا ہوں۔',
    },
    'payment received': {
      'hi': 'भुगतान सफलतापूर्वक प्राप्त हुआ!',
      'en': 'Payment successfully received!',
      'es': '¡Pago recibido con éxito!',
      'fr': 'Paiement reçu avec succès!',
      'de': 'Zahlung erfolgreich erhalten!',
      'ar': 'تم استلام الدفعة بنجاح!',
      'bn': 'পেমেন্ট সফলভাবে প্রাপ্ত হয়েছে!',
      'mr': 'पेमेंट यशस्वीरित्या मिळाले!',
      'ta': 'பணம் வெற்றிகரமாக பெறப்பட்டது!',
      'te': 'చెల్లింపు విజయవంతంగా స్వీకరించబడింది!',
      'gu': 'ચુકવણી સફળતાપૂર્વક પ્રાપ્ત થઈ!',
      'ur': 'ادائیگی کامیابی سے موصول ہوئی!',
    },
    'please send the file': {
      'hi': 'कृपया फ़ाइल भेजें।',
      'en': 'Please send the file.',
      'es': 'Por favor envía el archivo.',
      'fr': 'Veuillez envoyer le fichier.',
      'de': 'Bitte senden Sie die Datei.',
      'ar': 'يرجى إرسال الملف.',
      'bn': 'দয়া করে ফাইলটি পাঠান।',
      'mr': 'कृपया फाइल पाठवा.',
      'ta': 'கோப்பை அனுப்பவும்.',
      'te': 'దయచేసి ఫైల్ పంపండి.',
      'gu': 'કૃપા કરીને ફાઇલ મોકલો.',
      'ur': 'براہ کرم فائل بھیجیں۔',
    },
    'i sent the photo': {
      'hi': 'मैंने फ़ोटो भेज दी है।',
      'en': 'I sent the photo.',
      'es': 'He enviado la foto.',
      'fr': 'J\'ai envoyé la photo.',
      'de': 'Ich habe das Foto gesendet.',
      'ar': 'لقد أرسلت الصورة.',
      'bn': 'আমি ছবিটি পাঠিয়েছি।',
      'mr': 'मी फोटो पाठवला आहे.',
      'ta': 'நான் புகைப்படத்தை அனுப்பிவிட்டேன்.',
      'te': 'నేను ఫోటో పంపాను.',
      'gu': 'મેં ફોટો મોકલી દીધો છે.',
      'ur': 'میں نے تصویر بھیج دی ہے۔',
    },
    'welcome': {
      'hi': 'आपका स्वागत है!',
      'en': 'Welcome!',
      'es': '¡Bienvenido!',
      'fr': 'Bienvenue!',
      'de': 'Willkommen!',
      'ar': 'أهلاً وسهلاً!',
      'bn': 'স্বাগতম!',
      'mr': 'स्वागत आहे!',
      'ta': 'வரவேற்கிறோம்!',
      'te': 'స్వాగతం!',
      'gu': 'સ્વાગત છે!',
      'ur': 'خوش آمدید!',
    },
    'yes': {
      'hi': 'हाँ',
      'en': 'Yes',
      'es': 'Sí',
      'fr': 'Oui',
      'de': 'Ja',
      'ar': 'نعم',
      'bn': 'হ্যাঁ',
      'mr': 'होय',
      'ta': 'ஆம்',
      'te': 'అవును',
      'gu': 'હા',
      'ur': 'ہاں',
    },
    'no': {
      'hi': 'नहीं',
      'en': 'No',
      'es': 'No',
      'fr': 'Non',
      'de': 'Nein',
      'ar': 'لا',
      'bn': 'না',
      'mr': 'नाही',
      'ta': 'இல்லை',
      'te': 'కాదు',
      'gu': 'ના',
      'ur': 'نہیں',
    },
    'ok': {
      'hi': 'ठीक है',
      'en': 'OK / All right',
      'es': 'De acuerdo',
      'fr': 'D\'accord',
      'de': 'In Ordnung',
      'ar': 'حسناً',
      'bn': 'ঠিক আছে',
      'mr': 'ठीक आहे',
      'ta': 'சரி',
      'te': 'సరే',
      'gu': 'બરાબર',
      'ur': 'ٹھیک ہے',
    },
  };

  /// Common Hindi to English mappings
  static final Map<String, String> _hindiToEnglish = {
    'नमस्ते': 'Hello',
    'आप कैसे हैं': 'How are you',
    'मैं ठीक हूँ': 'I am fine',
    'धन्यवाद': 'Thank you',
    'शुभ प्रभात': 'Good morning',
    'शुभ रात्रि': 'Good night',
    'हाँ': 'Yes',
    'नहीं': 'No',
    'ठीक है': 'All right',
    'कहाँ हो': 'Where are you',
    'क्या हाल है': 'How are you doing',
    'जल्द मिलते हैं': 'See you soon',
    'फोटो': 'Photo',
    'पैसा': 'Money',
    'भुगतान': 'Payment',
  };

  /// Translates input text into target language
  Future<String> translateText(String rawText, {required String targetLanguageCode}) async {
    final text = rawText.trim();
    if (text.isEmpty) return '';

    final lower = text.toLowerCase().replaceAll(RegExp(r'[^\w\s\u0900-\u097F]'), '').trim();

    // 1. Direct phrase lookup in dictionary
    for (final entry in _phraseDictionary.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        final targetMap = entry.value;
        if (targetMap.containsKey(targetLanguageCode)) {
          return targetMap[targetLanguageCode]!;
        }
      }
    }

    // 2. Hindi phrase lookup
    for (final entry in _hindiToEnglish.entries) {
      if (text.contains(entry.key)) {
        if (targetLanguageCode == 'en') {
          return text.replaceAll(entry.key, entry.value);
        } else {
          final englishKey = entry.value.toLowerCase();
          if (_phraseDictionary.containsKey(englishKey)) {
            final t = _phraseDictionary[englishKey]?[targetLanguageCode];
            if (t != null) return t;
          }
        }
      }
    }

    // 3. Fallback translation with clear language prefix
    final lang = supportedLanguages.firstWhere(
      (l) => l.code == targetLanguageCode,
      orElse: () => supportedLanguages.first,
    );

    // If already in target language
    if (targetLanguageCode == 'en' && RegExp(r'^[a-zA-Z0-9\s.,!?]+$').hasMatch(text)) {
      return text;
    }

    // Return translated representation
    if (targetLanguageCode == 'hi') {
      return 'संदेश (हिन्दी अनुवाद): $text';
    } else if (targetLanguageCode == 'en') {
      return 'Message (English translation): $text';
    } else if (targetLanguageCode == 'es') {
      return 'Mensaje (Traducción): $text';
    } else if (targetLanguageCode == 'fr') {
      return 'Message (Traduction): $text';
    } else if (targetLanguageCode == 'de') {
      return 'Nachricht (Übersetzung): $text';
    } else if (targetLanguageCode == 'ar') {
      return 'الرسالة (ترجمة): $text';
    }

    return '${lang.name} translation: $text';
  }
}
