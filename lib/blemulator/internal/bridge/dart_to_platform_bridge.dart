part of internal;

class DartToPlatformBridge {
  MethodChannel _dartToPlatformChannel;

  DartToPlatformBridge() {
    _dartToPlatformChannel = new MethodChannel(ChannelName.dartToPlatform);
  }

  Future<void> simulate() =>
      _dartToPlatformChannel.invokeMethod(PlatformMethodName.simulate);

  Future<void> publishScanResult(ScanResult scanResult) =>
      _dartToPlatformChannel.invokeMethod(
          SimulationPlatformMethodName.publishScanResult, <String, dynamic>{
        SimulationArgumentName.name: scanResult.name,
        SimulationArgumentName.id: scanResult.id,
        SimulationArgumentName.mtu: scanResult.mtu,
        SimulationArgumentName.rssi: scanResult.rssi,
        SimulationArgumentName.isConnectable: scanResult.isConnectable,
        SimulationArgumentName.txPowerLevel: scanResult.txPowerLevel,
        SimulationArgumentName.manufacturerData: scanResult.manufacturerData,
        SimulationArgumentName.serviceData: scanResult.serviceData,
        SimulationArgumentName.serviceUuids: scanResult.serviceUuids,
        SimulationArgumentName.localName: scanResult.localName,
        SimulationArgumentName.solicitedServiceUuids:
            scanResult.solicitedServiceUuids,
        SimulationArgumentName.overflowUuids: scanResult.overflowUuids,
      });

  Future<void> publishConnectionState(SimulatedPeripheral peripheral,
          PeripheralConnectionState connectionState) =>
      _dartToPlatformChannel.invokeMethod(
          SimulationPlatformMethodName.publishConnectionState,
          <String, dynamic>{
            SimulationArgumentName.id: peripheral.id,
            SimulationArgumentName.connectionState: _connectionStateToString(connectionState),
          });

  String _connectionStateToString(PeripheralConnectionState state) {
    switch (state) {
      case PeripheralConnectionState.connecting:
        return "CONNECTING";
      case PeripheralConnectionState.connected:
        return "CONNECTED";
      case PeripheralConnectionState.disconnecting:
        return "DISCONNECTING";
      case PeripheralConnectionState.disconnected:
        return "DISCONNECTED";
      default:
        return null;
    }
  }
}
