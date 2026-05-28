import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class FilePickerService {
  static Future<FileData?> pickFile() async {
    if (!kIsWeb) return null;
    
    final completer = Completer<FileData?>();
    final input = html.FileUploadInputElement();
    input.multiple = false;
    
    input.onChange.listen((event) {
      if (input.files!.isEmpty) {
        completer.complete(null);
        return;
      }
      
      final file = input.files!.first;
      final reader = html.FileReader();
      
      reader.onLoadEnd.listen((event) {
        completer.complete(FileData(
          name: file.name,
          size: file.size,
          bytes: reader.result as Uint8List,
        ));
      });
      
      reader.onError.listen((event) {
        completer.complete(null);
      });
      
      reader.readAsArrayBuffer(file);
    });
    
    input.click();
    return completer.future;
  }
  
  static String getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return '🖼️';
    if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) return '🎬';
    if (['mp3', 'wav', 'ogg'].contains(ext)) return '🎵';
    if (['pdf'].contains(ext)) return '📄';
    if (['doc', 'docx'].contains(ext)) return '📝';
    if (['txt', 'md'].contains(ext)) return '📃';
    return '📎';
  }
}

class FileData {
  final String name;
  final int size;
  final Uint8List bytes;
  
  FileData({required this.name, required this.size, required this.bytes});
  
  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
