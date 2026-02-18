// lib/chat_detail_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/chat_models.dart';

class ChatDetailPage extends StatefulWidget {
  final Chat chat;
  
  const ChatDetailPage({
    super.key,
    required this.chat,
  });
  
  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _showFormattingToolbar = false;
  bool _showEmojiPicker = false;
  
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm1',
      chatId: '1',
      senderId: 'user1',
      text: 'Привет! Как дела?',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    ChatMessage(
      id: 'm2',
      chatId: '1',
      senderId: 'me',
      text: 'Привет! Всё отлично, работаю над новым проектом',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
      isRead: true,
    ),
    ChatMessage(
      id: 'm3',
      chatId: '1',
      senderId: 'user1',
      text: 'Круто! Можешь показать наработки?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      isRead: true,
    ),
    ChatMessage(
      id: 'm4',
      chatId: '1',
      senderId: 'me',
      text: 'Да, конечно! Вот скриншоты',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      isRead: true,
      type: MessageType.image,
    ),
    ChatMessage(
      id: 'm5',
      chatId: '1',
      senderId: 'user1',
      text: 'Выглядит офигенно! **Особенно этот экран**',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      formatting: [
        MessageFormatting(
          start: 32,
          end: 48,
          type: FormattingType.bold,
        ),
      ],
    ),
    ChatMessage(
      id: 'm6',
      chatId: '1',
      senderId: 'me',
      text: 'Спасибо! Я использовал *Flutter* для анимаций',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      isRead: true,
      formatting: [
        MessageFormatting(
          start: 19,
          end: 26,
          type: FormattingType.italic,
        ),
      ],
    ),
    ChatMessage(
      id: 'm7',
      chatId: '1',
      senderId: 'user1',
      text: 'Flutter - это мощно! Я сам хочу изучить',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      isRead: true,
    ),
    ChatMessage(
      id: 'm8',
      chatId: '1',
      senderId: 'me',
      text: 'Рекомендую! Вот полезные ссылки:',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      isRead: true,
    ),
    ChatMessage(
      id: 'm9',
      chatId: '1',
      senderId: 'me',
      text: 'https://flutter.dev - официальный сайт\nhttps://pub.dev - пакеты',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
      formatting: [
        MessageFormatting(
          start: 0,
          end: 17,
          type: FormattingType.link,
          url: 'https://flutter.dev',
        ),
        MessageFormatting(
          start: 18,
          end: 35,
          type: FormattingType.link,
          url: 'https://pub.dev',
        ),
      ],
    ),
    ChatMessage(
      id: 'm10',
      chatId: '1',
      senderId: 'user1',
      text: 'Спасибо! Буду изучать\n\nP.S. Завтра в 10:00 созвон, не забудь!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      isRead: true,
    ),
    ChatMessage(
      id: 'm11',
      chatId: '1',
      senderId: 'user1',
      text: 'Good morning, did you sleep well?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: true,
    ),
    ChatMessage(
      id: 'm12',
      chatId: '1',
      senderId: 'me',
      text: 'Да, спал отлично! Готов к работе 💪',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      senderId: 'me',
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    Future.delayed(Duration(seconds: 1 + Random().nextInt(3)), () {
      final responses = [
        'Понял тебя!',
        'Интересная мысль!',
        'Согласен с тобой',
        'Давай обсудим это подробнее',
        'Хорошо, я записал',
        'Спасибо за информацию!',
      ];
      
      final responseMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: widget.chat.id,
        senderId: widget.chat.participants.first.id,
        text: responses[Random().nextInt(responses.length)],
        timestamp: DateTime.now().add(const Duration(seconds: 1)),
        isRead: true,
      );

      setState(() {
        _messages.add(responseMessage);
      });

      _scrollToBottom();
    });
  }

  void _toggleFormattingToolbar() {
    setState(() {
      _showFormattingToolbar = !_showFormattingToolbar;
    });
  }

  void _applyFormatting(FormattingType type) {
    final text = _messageController.text;
    final selection = _messageController.selection;
    
    if (!selection.isValid || selection.isCollapsed) {
      return;
    }
    
    String formattedText;
    int newCursorPosition;
    
    final selectedText = text.substring(selection.start, selection.end);
    
    switch (type) {
      case FormattingType.bold:
        formattedText = '**$selectedText**';
        newCursorPosition = selection.baseOffset + 2;
        break;
      case FormattingType.italic:
        formattedText = '*$selectedText*';
        newCursorPosition = selection.baseOffset + 1;
        break;
      case FormattingType.underline:
        formattedText = '__${selectedText}__';
        newCursorPosition = selection.baseOffset + 2;
        break;
      case FormattingType.strikethrough:
        formattedText = '~~${selectedText}~~';
        newCursorPosition = selection.baseOffset + 2;
        break;
      case FormattingType.code:
        formattedText = '`${selectedText}`';
        newCursorPosition = selection.baseOffset + 1;
        break;
      default:
        return;
    }
    
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      formattedText,
    );
    
    _messageController.text = newText;
    _messageController.selection = TextSelection.collapsed(
      offset: newCursorPosition + selectedText.length,
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == 'me';
    
    return Container(
      margin: EdgeInsets.only(
        left: isMe ? 60 : 16,
        right: isMe ? 16 : 60,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe 
                  ? const Color(0xFF5D7CF9)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isMe ? [] : [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageText(message),
                
                if (message.type == MessageType.document)
                  _buildFileAttachment(message),
                
                if (message.type == MessageType.image)
                  _buildImageAttachment(message),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  message.timeFormatted,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
                
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: message.isRead 
                        ? const Color(0xFF5D7CF9)
                        : const Color(0xFF7F8C8D),
                  ),
                ],
                
                if (message.isEdited) ...[
                  const SizedBox(width: 4),
                  Text(
                    'ред.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageText(ChatMessage message) {
    final isMe = message.senderId == 'me';
    
    if (message.formatting.isEmpty) {
      return Text(
        message.text,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: isMe ? Colors.white : const Color(0xFF2C3E50),
        ),
      );
    }
    
    final textSpans = <TextSpan>[];
    int lastIndex = 0;
    
    final formatting = List.from(message.formatting)
      ..sort((a, b) => a.start.compareTo(b.start));
    
    for (final format in formatting) {
      if (format.start > lastIndex) {
        textSpans.add(TextSpan(
          text: message.text.substring(lastIndex, format.start),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isMe ? Colors.white : const Color(0xFF2C3E50),
          ),
        ));
      }
      
      TextStyle style = GoogleFonts.inter(
        fontSize: 14,
        color: isMe ? Colors.white : const Color(0xFF2C3E50),
      );
      
      switch (format.type) {
        case FormattingType.bold:
          style = style.copyWith(fontWeight: FontWeight.w700);
          break;
        case FormattingType.italic:
          style = style.copyWith(fontStyle: FontStyle.italic);
          break;
        case FormattingType.underline:
          style = style.copyWith(decoration: TextDecoration.underline);
          break;
        case FormattingType.strikethrough:
          style = style.copyWith(decoration: TextDecoration.lineThrough);
          break;
        case FormattingType.code:
          style = style.copyWith(
            fontFamily: 'monospace',
            backgroundColor: isMe 
                ? Colors.white.withOpacity(0.2)
                : const Color(0xFFE8EDF2),
          );
          break;
        case FormattingType.link:
          style = style.copyWith(
            color: isMe ? Colors.white : const Color(0xFF5D7CF9),
            decoration: TextDecoration.underline,
          );
          break;
        case FormattingType.spoiler:
          style = style.copyWith(
            color: isMe ? Colors.white.withOpacity(0.7) : const Color(0xFF7F8C8D),
            backgroundColor: isMe 
                ? Colors.white.withOpacity(0.2)
                : const Color(0xFFE8EDF2),
          );
          break;
        default:
          break;
      }
      
      textSpans.add(TextSpan(
        text: message.text.substring(format.start, format.end),
        style: style,
      ));
      
      lastIndex = format.end;
    }
    
    if (lastIndex < message.text.length) {
      textSpans.add(TextSpan(
        text: message.text.substring(lastIndex),
        style: GoogleFonts.inter(
          fontSize: 14,
          color: isMe ? Colors.white : const Color(0xFF2C3E50),
        ),
      ));
    }
    
    return RichText(
      text: TextSpan(children: textSpans),
    );
  }

  Widget _buildFileAttachment(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: Color(0xFF5D7CF9)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'Файл',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                if (message.fileSize != null)
                  Text(
                    '${message.fileSize!.toStringAsFixed(1)} MB',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF7F8C8D),
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.download, color: Color(0xFF5D7CF9)),
        ],
      ),
    );
  }

  Widget _buildImageAttachment(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          height: 150,
          color: const Color(0xFFE8EDF2),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo, color: Color(0xFF5D7CF9), size: 48),
                SizedBox(height: 8),
                Text(
                  'Изображение',
                  style: TextStyle(color: Color(0xFF7F8C8D)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
                    ),
                    
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.chat.participants.first.color.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.chat.participants.first.avatar,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: widget.chat.participants.first.color,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chat.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          
                          Text(
                            widget.chat.participants.first.isOnline
                                ? 'online'
                                : 'был(а) ${widget.chat.participants.first.lastSeen}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          if (_showFormattingToolbar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  _buildFormattingButton(Icons.format_bold, FormattingType.bold),
                  _buildFormattingButton(Icons.format_italic, FormattingType.italic),
                  _buildFormattingButton(Icons.format_underline, FormattingType.underline),
                  _buildFormattingButton(Icons.format_strikethrough, FormattingType.strikethrough),
                  _buildFormattingButton(Icons.code, FormattingType.code),
                  const Spacer(),
                  IconButton(
                    onPressed: _toggleFormattingToolbar,
                    icon: const Icon(Icons.close, color: Color(0xFF7F8C8D)),
                  ),
                ],
              ),
            ),
          
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 120,
                        ),
                        child: TextField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Сообщение...',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFFBDC3C7),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFD),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ),
                    
                    IconButton(
                      onPressed: _toggleFormattingToolbar,
                      icon: Icon(
                        Icons.format_color_text,
                        color: _showFormattingToolbar 
                            ? const Color(0xFF5D7CF9)
                            : const Color(0xFF7F8C8D),
                      ),
                    ),
                    
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showEmojiPicker = !_showEmojiPicker;
                        });
                      },
                      icon: const Icon(Icons.emoji_emotions, color: Color(0xFF5D7CF9)),
                    ),
                    
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5D7CF9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                
                if (_showEmojiPicker)
                  Container(
                    height: 200,
                    color: Colors.white,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 64,
                      itemBuilder: (context, index) {
                        final emojis = ['😀', '😂', '🥰', '😎', '🤔', '😱', '🎉', '🔥', '💯', '🚀', '💪', '👏', '🙏', '👍', '❤️', '✨'];
                        return GestureDetector(
                          onTap: () {
                            _messageController.text += emojis[index % emojis.length];
                          },
                          child: Center(
                            child: Text(
                              emojis[index % emojis.length],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattingButton(IconData icon, FormattingType type) {
    return IconButton(
      onPressed: () => _applyFormatting(type),
      icon: Icon(icon, color: const Color(0xFF5D7CF9)),
    );
  }
}