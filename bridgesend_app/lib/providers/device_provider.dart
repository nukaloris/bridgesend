import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/peer_discovery.dart';

class DeviceProvider extends ChangeNotifier {
  List<DeviceModel> _devices = [];
  bool _isScanning = false;
  bool _isConnected = false;
  PeerDevice? _connectedPeer;

  List<DeviceModel> get devices => _devices;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  DeviceModel? get connectedDevice => _isConnected && _connectedPeer != null 
      ? DeviceModel(
          id: _connectedPeer!.id,
          name: _connectedPeer!.name,
          type: _connectedPeer!.type,
          connectionType: 'local',
          isConnected: true,
        )
      : null;

  DeviceProvider() {
    _initDiscovery();
  }
  
  void _initDiscovery() {
    // Start peer discovery
    PeerDiscoveryService.init('My Device', (peers) {
      _devices = peers.map((peer) => DeviceModel(
        id: peer.id,
        name: peer.name,
        type: peer.type,
        connectionType: 'local',
        isConnected: false,
      )).toList();
      notifyListeners();
    });
    
    // Check for existing connection
    final connected = PeerDiscoveryService.getConnectedPeer();
    if (connected != null) {
      _connectedPeer = connected;
      _isConnected = true;
      notifyListeners();
    }
  }

  Future<void> startScan() async {
    _isScanning = true;
    notifyListeners();
    
    // Force refresh peers
    await Future.delayed(Duration(seconds: 1));
    _isScanning = false;
    notifyListeners();
  }

  void connectToDevice(DeviceModel device) {
    _connectedPeer = PeerDevice(
      id: device.id,
      name: device.name,
      type: device.type,
    );
    _isConnected = true;
    
    PeerDiscoveryService.connectToPeer(_connectedPeer!);
    notifyListeners();
  }
  
  void disconnect() {
    _isConnected = false;
    _connectedPeer = null;
    PeerDiscoveryService.disconnect();
    notifyListeners();
  }
}
