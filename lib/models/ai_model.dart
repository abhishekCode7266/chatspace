class AiPromptModel {
  final String id;
  final String prompt;
  final String response;
  final DateTime timestamp;
  final String type; // 'chat', 'summary', 'translate', 'image', 'document'
  final String? imageUrl;

  AiPromptModel({
    required this.id,
    required this.prompt,
    required this.response,
    required this.timestamp,
    this.type = 'chat',
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prompt': prompt,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'imageUrl': imageUrl,
    };
  }

  factory AiPromptModel.fromMap(Map<String, dynamic> map) {
    return AiPromptModel(
      id: map['id'] as String? ?? '',
      prompt: map['prompt'] as String? ?? '',
      response: map['response'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      type: map['type'] as String? ?? 'chat',
      imageUrl: map['imageUrl'] as String?,
    );
  }
}
