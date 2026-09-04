enum ChatRole { user, assistant }
extension ChatRoleX on ChatRole {
  String get wireValue => this == ChatRole.user ? 'user' : 'assistant';

  static ChatRole fromWire(String? value) {
    return value == 'user' ? ChatRole.user : ChatRole.assistant;
  }
}

class ChatMessage {
  final ChatRole role;
  final String content;
  const ChatMessage({required this.role, required this.content});
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: ChatRoleX.fromWire(json['role'] as String?),
      content: json['content'] as String? ?? '',
    );
  }
}

class ChatSessionSummary {
  final String id;
  final DateTime updatedAt;
  final String? title;
  final String? preview;

  const ChatSessionSummary({
    required this.id,
    required this.updatedAt,
    this.title,
    this.preview,
  });

  String get displayPreview => preview ?? title ?? 'Sesi percakapan';

  factory ChatSessionSummary.fromJson(Map<String, dynamic> json) {
    return ChatSessionSummary(
      id: json['id'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      title: json['title'] as String?,
      preview: json['preview'] as String?,
    );
  }
}

class ChatSessionDetail {
  final String id;
  final List<ChatMessage> messages;
  const ChatSessionDetail({required this.id, required this.messages});

  factory ChatSessionDetail.fromJson(Map<String, dynamic> json) {
    final messagesJson = json['messages'] as List<dynamic>? ?? [];
    return ChatSessionDetail(
      id: json['id'] as String? ?? '',
      messages: messagesJson
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChatSendResult {
  final String? sessionId;
  final String aiResponse;
  const ChatSendResult({required this.sessionId, required this.aiResponse});

  factory ChatSendResult.fromJson(Map<String, dynamic> json) {
    return ChatSendResult(
      sessionId: json['session_id'] as String?,
      aiResponse: json['ai_response'] as String? ?? '',
    );
  }
}

class LexaUserSnapshot {
  final String name;
  final String? businessName;

  const LexaUserSnapshot({required this.name, this.businessName});

  factory LexaUserSnapshot.fromJson(Map<String, dynamic>? data) {
    final userJson = data?['user'] as Map<String, dynamic>?;
    final bpJson = data?['business_profile'] as Map<String, dynamic>?;
    return LexaUserSnapshot(
      name: userJson?['name'] as String? ?? 'Sobat UMKM',
      businessName: bpJson?['business_name'] as String?,
    );
  }
}

enum ChatContextStepType { nib, sppIrt, halal, bpom, merek, sertifikatStandar }

extension ChatContextStepTypeX on ChatContextStepType {
  String get wireValue => switch (this) {
        ChatContextStepType.nib => 'nib',
        ChatContextStepType.sppIrt => 'spp_irt',
        ChatContextStepType.halal => 'halal',
        ChatContextStepType.bpom => 'bpom',
        ChatContextStepType.merek => 'merek',
        ChatContextStepType.sertifikatStandar => 'sertifikat_standar',
      };
}