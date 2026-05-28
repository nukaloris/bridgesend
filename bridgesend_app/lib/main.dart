import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/device_model.dart';
import 'models/file_model.dart';
import 'models/message_model.dart';
import 'providers/device_provider.dart';
import 'providers/transfer_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BridgeSendApp());
}

class BridgeSendApp extends StatelessWidget {
  const BridgeSendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => TransferProvider()),
      ],
      child: MaterialApp(
        title: 'BridgeSend',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A192F),
          primaryColor: const Color(0xFFADB7FF),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFADB7FF),
            secondary: Color(0xFF00E3FD),
            surface: Color(0xFF10131B),
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
