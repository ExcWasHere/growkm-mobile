import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';
import '../theme/lexa_colors.dart';
import 'lexa_repo.dart';
import '../models/lexa_models.dart';
import '../widgets/lexa_header.dart';
import '../widgets/lexa_input.dart';
import '../widgets/lexa_bubble.dart';
import '../widgets/lexa_questions.dart';
import '../widgets/lexa_drawer.dart';
import '../widgets/lexa_typing.dart';

class LexaChatPage extends StatefulWidget {
  final ChatContextStepType? initialContextStepType;
  final String? initialContextLabel;

  const LexaChatPage({
    super.key,
    this.initialContextStepType,
    this.initialContextLabel,
  });

  @override
  State<LexaChatPage> createState() => _LexaChatPageState();
}

class _LexaChatPageState extends State<LexaChatPage> {
  final _repository = LexaRepository.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();

  List<ChatMessage> _messages = [];
  String? _sessionId;
  bool _sending = false;

  List<ChatSessionSummary> _sessions = [];
  bool _sessionsLoading = false;

  LexaUserSnapshot? _userSnapshot;

  @override
  void initState() {
    super.initState();
    _loadGreeting();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadGreeting() async {
    try {
      final snapshot = await _repository.fetchUserSnapshot();
      if (!mounted) return;
      setState(() {
        _userSnapshot = snapshot;
        _messages = [_buildGreetingMessage(snapshot)];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _messages = [_buildGreetingMessage(null)]);
    }
  }

  ChatMessage _buildGreetingMessage(LexaUserSnapshot? snapshot) {
    if (widget.initialContextLabel != null) {
      return ChatMessage(
        role: ChatRole.assistant,
        content: 'Halo ${snapshot?.name ?? ''}! 👋 Saya siap bantu kamu soal '
            '**${widget.initialContextLabel}**. Apa yang ingin kamu ketahui?',
      );
    }
    final name = snapshot?.name ?? 'Sobat UMKM';
    final businessName = snapshot?.businessName ?? 'usahamu';
    return ChatMessage(
      role: ChatRole.assistant,
      content: 'Halo **$name**! 👋 Saya **Lexa**, asisten perizinan usahamu. '
          'Tanya apa saja soal proses perizinan dan formalisasi usaha **$businessName** ya!',
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage([String? text]) async {
    final messageText = (text ?? _inputController.text).trim();
    if (messageText.isEmpty || _sending) return;

    final isFirstMessage = _sessionId == null;

    setState(() {
      _messages = [..._messages, ChatMessage(role: ChatRole.user, content: messageText)];
      _sending = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final result = await _repository.sendMessage(
        message: messageText,
        sessionId: _sessionId,
        contextStepType: isFirstMessage ? widget.initialContextStepType : null,
      );
      if (!mounted) return;
      setState(() {
        if (_sessionId == null && result.sessionId != null) {
          _sessionId = result.sessionId;
        }
        _messages = [..._messages, ChatMessage(role: ChatRole.assistant, content: result.aiResponse)];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages = [
          ..._messages,
          const ChatMessage(role: ChatRole.assistant, content: 'Maaf, koneksi bermasalah. Coba lagi ya! 🙏'),
        ];
      });
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _startNewChat() {
    setState(() {
      _sessionId = null;
      _messages = [_buildGreetingMessage(_userSnapshot)];
    });
    Navigator.of(context).maybePop(); // tutup drawer kalau lagi kebuka
    WidgetsBinding.instance.addPostFrameCallback((_) => _inputFocusNode.requestFocus());
  }

  Future<void> _fetchSessions() async {
    setState(() => _sessionsLoading = true);
    try {
      final sessions = await _repository.fetchSessions();
      if (!mounted) return;
      setState(() => _sessions = sessions);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat riwayat chat')),
      );
    } finally {
      if (mounted) setState(() => _sessionsLoading = false);
    }
  }

  Future<void> _openHistory() async {
    _scaffoldKey.currentState?.openEndDrawer();
    await _fetchSessions();
  }

  Future<void> _loadSession(String id) async {
    try {
      final detail = await _repository.fetchSessionDetail(id);
      if (!mounted) return;
      setState(() {
        if (detail.messages.isNotEmpty) _messages = detail.messages;
        _sessionId = id;
      });
      Navigator.of(context).maybePop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat sesi ini')),
      );
    }
  }

  Future<void> _deleteSession(String id) async {
    try {
      await _repository.deleteSession(id);
      if (!mounted) return;
      setState(() => _sessions = _sessions.where((s) => s.id != id).toList());
      if (id == _sessionId) _startNewChat();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus sesi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        endDrawer: LexaSessionDrawer(
          loading: _sessionsLoading,
          sessions: _sessions,
          activeSessionId: _sessionId,
          onNewChat: _startNewChat,
          onSelect: _loadSession,
          onDelete: _deleteSession,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LexaColors.amber200),
                boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 3))],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  LexaHeader(onToggleHistory: _openHistory, onNewChat: _startNewChat),
                  if (_messages.length <= 1) LexaQuickQuestions(onTap: _sendMessage),
                  Expanded(child: _buildMessageList()),
                  LexaInputBar(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    loading: _sending,
                    onSend: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(14),
      itemCount: _messages.length + (_sending ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index >= _messages.length) return const LexaTypingIndicator();
        return LexaMessageBubble(message: _messages[index]);
      },
    );
  }
}