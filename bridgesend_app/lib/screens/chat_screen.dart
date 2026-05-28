import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device_model.dart';
import '../models/file_model.dart';
import '../models/message_model.dart';
import '../providers/transfer_provider.dart';
import '../services/file_picker_service.dart';

class ChatScreen extends StatefulWidget {
  final DeviceModel connectedDevice;

  const ChatScreen({super.key, required this.connectedDevice});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransferProvider>(context, listen: false).addMessage(
        'Connected to ${widget.connectedDevice.name}',
        isSent: false,
      );
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    Provider.of<TransferProvider>(context, listen: false).addMessage(text, isSent: true);
    _messageController.clear();
    _scrollToBottom();

    // Simulate reply
    Future.delayed(const Duration(milliseconds: 800), () {
      Provider.of<TransferProvider>(context, listen: false).addMessage(
        'Got your message: "$text"',
        isSent: false,
      );
      _scrollToBottom();
    });
  }

  Future<void> _pickAndSendFile() async {
    if (_isPickingFile) return;
    
    setState(() => _isPickingFile = true);
    
    try {
      final fileData = await FilePickerService.pickFile();
      if (fileData != null) {
        final fileModel = FileModel(
          name: fileData.name,
          path: 'web-file',
          size: fileData.size,
          type: _getFileType(fileData.name),
          modified: DateTime.now(),
        );
        
        final transferProvider = Provider.of<TransferProvider>(context, listen: false);
        transferProvider.addFile(fileModel);
        _showTransferDialog(transferProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    } finally {
      setState(() => _isPickingFile = false);
    }
  }

  String _getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return 'image';
    if (['mp4', 'mov', 'avi'].contains(ext)) return 'video';
    if (['mp3', 'wav', 'ogg'].contains(ext)) return 'audio';
    if (['pdf', 'doc', 'docx', 'txt'].contains(ext)) return 'document';
    return 'other';
  }

  void _showTransferDialog(TransferProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2027),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: provider.isTransferring
              ? _buildTransferProgress(provider)
              : _buildSendConfirmation(provider, setState),
        ),
      ),
    );
  }

  Widget _buildTransferProgress(TransferProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: provider.transferProgress,
                  strokeWidth: 6,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E3FD)),
                ),
              ),
              Text(
                '${(provider.transferProgress * 100).toInt()}%',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            provider.transferStatus,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (provider.currentFileName.isNotEmpty)
            Text(
              provider.currentFileName,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    provider.cancelTransfer();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendConfirmation(TransferProvider provider, StateSetter modalSetState) {
    final totalSize = provider.selectedFiles.fold<int>(0, (sum, file) => sum + file.size);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFADB7FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.send, size: 40, color: Color(0xFFADB7FF)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ready to Send',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Sending ${provider.selectedFiles.length} file(s) (${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB)',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: provider.selectedFiles.length,
              itemBuilder: (context, index) {
                final file = provider.selectedFiles[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                                      Text(
                      FilePickerService.getFileIcon(file.name),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            file.sizeFormatted,
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                      onPressed: () {
                        provider.removeFile(file);
                        modalSetState(() {});
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await provider.startTransfer();
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A8EFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Send Now'),
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.connectedDevice.name, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00E3FD), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Connected', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<TransferProvider>(
              builder: (context, provider, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                if (provider.messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No messages yet', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Send a message or file to start', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          
          if (Provider.of<TransferProvider>(context).isTransferring)
            Consumer<TransferProvider>(
              builder: (context, provider, _) => Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: provider.transferProgress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E3FD)),
                    ),
                    const SizedBox(height: 4),
                    Text(provider.transferStatus, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          
          // Input bar with file button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E16),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: _isPickingFile 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.attach_file, color: Colors.white),
                  onPressed: _isPickingFile ? null : _pickAndSendFile,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message or attach file...',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF4A8EFF), Color(0xFF00E3FD)]),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isSent = message.isSent;
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSent ? const Color(0xFFADB7FF).withOpacity(0.15) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isSent ? const Radius.circular(12) : const Radius.circular(4),
                  bottomRight: isSent ? const Radius.circular(4) : const Radius.circular(12),
                ),
              ),
              child: Text(message.text, style: const TextStyle(color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message.formattedTime, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  if (isSent) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle, size: 12, color: Color(0xFF00E3FD)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
