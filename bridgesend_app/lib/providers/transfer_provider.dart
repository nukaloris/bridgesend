import 'package:flutter/material.dart';
import '../models/file_model.dart';
import '../models/message_model.dart';

class TransferProvider extends ChangeNotifier {
  List<FileModel> _selectedFiles = [];
  List<MessageModel> _messages = [];
  double _transferProgress = 0.0;
  bool _isTransferring = false;
  String _transferStatus = '';
  String _currentFileName = '';

  List<FileModel> get selectedFiles => _selectedFiles;
  List<MessageModel> get messages => _messages;
  double get transferProgress => _transferProgress;
  bool get isTransferring => _isTransferring;
  String get transferStatus => _transferStatus;
  String get currentFileName => _currentFileName;

  void addFile(FileModel file) {
    _selectedFiles.add(file);
    notifyListeners();
  }

  void removeFile(FileModel file) {
    _selectedFiles.remove(file);
    notifyListeners();
  }

  void clearFiles() {
    _selectedFiles.clear();
    notifyListeners();
  }

  void addMessage(String text, {bool isSent = true, FileModel? attachedFile}) {
    _messages.add(MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isSent: isSent,
      timestamp: DateTime.now(),
      attachedFile: attachedFile,
    ));
    notifyListeners();
  }

  Future<void> startTransfer() async {
    if (_selectedFiles.isEmpty) return;

    _isTransferring = true;
    _transferProgress = 0.0;
    _transferStatus = 'Preparing transfer...';
    notifyListeners();

    for (int i = 0; i < _selectedFiles.length; i++) {
      final file = _selectedFiles[i];
      _currentFileName = file.name;
      _transferStatus = 'Sending ${file.name}...';
      notifyListeners();

      // Simulate file transfer with realistic progress
      for (int p = 0; p <= 100; p += 5) {
        await Future.delayed(Duration(milliseconds: 50 + (file.size ~/ 100000)));
        _transferProgress = ((i + (p / 100)) / _selectedFiles.length);
        _transferStatus = 'Transferring ${file.name} - ${p}%';
        notifyListeners();
      }

      // Add message when file is sent
      addMessage('📎 ${file.name} (${file.sizeFormatted})', isSent: true, attachedFile: file);
    }

    _transferStatus = 'Transfer complete!';
    await Future.delayed(const Duration(seconds: 1));
    
    _isTransferring = false;
    _transferProgress = 0.0;
    _transferStatus = '';
    _currentFileName = '';
    _selectedFiles.clear();
    notifyListeners();
  }

  void cancelTransfer() {
    _isTransferring = false;
    _transferProgress = 0.0;
    _transferStatus = 'Transfer cancelled';
    notifyListeners();
    
    Future.delayed(const Duration(seconds: 2), () {
      _transferStatus = '';
      notifyListeners();
    });
  }
}
