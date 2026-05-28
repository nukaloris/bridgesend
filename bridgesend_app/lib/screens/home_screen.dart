import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../models/device_model.dart';
import 'chat_screen.dart';
import 'device_discovery_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFADB7FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.signal_cellular_alt, color: Color(0xFFADB7FF), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BridgeSend', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFADB7FF))),
                        Text('Ready to Connect', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.person, color: Colors.white54, size: 24),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Main Send Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeviceDiscoveryScreen()),
                );
              },
              child: Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF4A8EFF), Color(0xFF00E3FD)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A8EFF).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 44, color: Colors.white),
                      SizedBox(height: 8),
                      Text('Send', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAction(Icons.description, 'Files'),
                  _buildQuickAction(Icons.image, 'Photos'),
                  _buildQuickAction(Icons.link, 'Links'),
                  _buildQuickAction(Icons.qr_code_scanner, 'Scan'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Connected Device Status
            if (deviceProvider.isConnected && deviceProvider.connectedDevice != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF00E3FD).withOpacity(0.1), const Color(0xFF4A8EFF).withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00E3FD).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFF00E3FD), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connected to ${deviceProvider.connectedDevice!.name}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        deviceProvider.disconnect();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Disconnected')),
                        );
                      },
                      child: const Text('Disconnect', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Nearby Devices Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nearby Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  GestureDetector(
                    onTap: () => deviceProvider.startScan(),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00E3FD), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          deviceProvider.isScanning ? 'Searching...' : 'Tap to Scan',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Devices List
            Expanded(
              child: deviceProvider.devices.isEmpty && !deviceProvider.isScanning
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.devices, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No devices found', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('Open this app in another browser tab', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: deviceProvider.devices.length,
                      itemBuilder: (context, index) {
                        final device = deviceProvider.devices[index];
                        return _buildDeviceCard(context, device);
                      },
                    ),
            ),
            
            const SizedBox(height: 20),
            
            // Demo hint
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Open this app in another browser tab to see other devices appear here!',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFADB7FF), size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, DeviceModel device) {
    return GestureDetector(
      onTap: () {
        // Store connection info before navigating
        Provider.of<DeviceProvider>(context, listen: false).connectToDevice(device);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(connectedDevice: device)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFADB7FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(device.icon, color: const Color(0xFFADB7FF), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.wifi, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('Local Network', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4A8EFF), Color(0xFF00E3FD)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Connect', style: TextStyle(fontSize: 11, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
