import 'dart:async';
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';

class PeerDiscoveryService {
  static final List<PeerDevice> _discoveredPeers = [];
  static Timer? _broadcastTimer;
  static String? _myDeviceId;
  static String? _myDeviceName;
  static Function(List<PeerDevice>)? _onPeersUpdated;
  
  static void init(String deviceName, Function(List<PeerDevice>) onUpdate) {
    _myDeviceId = DateTime.now().millisecondsSinceEpoch.toString();
    _myDeviceName = deviceName;
    _onPeersUpdated = onUpdate;
    
    // Listen to localStorage changes (cross-tab)
    html.window.onStorage.listen((event) {
      if (event.key == 'bridgesend_peers') {
        _updatePeersFromStorage();
      }
    });
    
    // Start broadcasting presence
    _startBroadcasting();
    
    // Load existing peers
    _updatePeersFromStorage();
  }
  
  static void _startBroadcasting() {
    _broadcastTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _broadcastPresence();
    });
  }
  
  static void _broadcastPresence() {
    final peers = _getStoredPeers();
    peers[_myDeviceId!] = {
      'id': _myDeviceId,
      'name': _myDeviceName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': 'phone',
    };
    
    html.window.localStorage['bridgesend_peers'] = jsonEncode(peers);
  }
  
  static Map<String, dynamic> _getStoredPeers() {
    final stored = html.window.localStorage['bridgesend_peers'];
    if (stored == null || stored.isEmpty) return {};
    try {
      return jsonDecode(stored);
    } catch (e) {
      return {};
    }
  }
  
  static void _updatePeersFromStorage() {
    final stored = _getStoredPeers();
    final now = DateTime.now().millisecondsSinceEpoch;
    final List<PeerDevice> activePeers = [];
    
    stored.forEach((id, data) {
      // Don't include self
      if (id != _myDeviceId) {
        final timestamp = data['timestamp'] as int;
        // Only show peers that broadcast in last 10 seconds
        if (now - timestamp < 10000) {
          activePeers.add(PeerDevice(
            id: id,
            name: data['name'] ?? 'Unknown Device',
            type: data['type'] ?? 'phone',
          ));
        }
      }
    });
    
    _discoveredPeers.clear();
    _discoveredPeers.addAll(activePeers);
    _onPeersUpdated?.call(_discoveredPeers);
  }
  
  static void stop() {
    _broadcastTimer?.cancel();
    final peers = _getStoredPeers();
    peers.remove(_myDeviceId);
    html.window.localStorage['bridgesend_peers'] = jsonEncode(peers);
  }
  
  static void connectToPeer(PeerDevice peer) {
    html.window.localStorage['bridgesend_connection'] = jsonEncode({
      'peerId': peer.id,
      'peerName': peer.name,
      'connectedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  static PeerDevice? getConnectedPeer() {
    final stored = html.window.localStorage['bridgesend_connection'];
    if (stored == null || stored.isEmpty) return null;
    try {
      final data = jsonDecode(stored);
      return PeerDevice(
        id: data['peerId'],
        name: data['peerName'],
        type: 'phone',
      );
    } catch (e) {
      return null;
    }
  }
  
  static void disconnect() {
    html.window.localStorage.remove('bridgesend_connection');
  }
}

class PeerDevice {
  final String id;
  final String name;
  final String type;
  
  PeerDevice({
    required this.id,
    required this.name,
    required this.type,
  });
  
  IconData get icon {
    switch (type) {
      case 'laptop':
        return Icons.laptop_mac;
      case 'desktop':
        return Icons.desktop_windows;
      default:
        return Icons.smartphone;
    }
  }
}
