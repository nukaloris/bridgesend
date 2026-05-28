import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FilePreviewService {
  static Future<Uint8List?> pickFile() async {
    if (!kIsWeb) {
      return null;
    }
    
    final completer = Completer<Uint8List?>();
    
    final input = html.FileUploadInputElement();
    input.accept = 'image/*,video/*,application/pdf,.txt,.jpg,.png,.gif';
    input.multiple = false;
    
    input.onChange.listen((event) {
      if (input.files!.isEmpty) {
        completer.complete(null);
        return;
      }
      
      final file = input.files!.first;
      final reader = html.FileReader();
      
      reader.onLoadEnd.listen((event) {
        completer.complete(reader.result as Uint8List?);
      });
      
      reader.onError.listen((event) {
        completer.complete(null);
      });
      
      reader.readAsArrayBuffer(file);
    });
    
    input.click();
    return completer.future;
  }
  
  static String getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) return 'image';
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) return 'video';
    if (['mp3', 'wav', 'ogg', 'm4a'].contains(ext)) return 'audio';
    if (['pdf', 'doc', 'docx', 'txt', 'md'].contains(ext)) return 'document';
    return 'other';
  }
}
