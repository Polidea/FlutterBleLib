part of internal;

class PlatformToDartBridge {
  SimulationManager _manager;
  MethodChannel _platformToDartChannel;

  PlatformToDartBridge(this._manager) {
    _platformToDartChannel = new MethodChannel(ChannelName.platformToDart);
    _platformToDartChannel.setMethodCallHandler(_handleCall);
  }

  Future<dynamic> _handleCall(MethodCall call) {
    switch (call.method) {
      case DartMethodName.createClient:
        return _createClient(call);
      case DartMethodName.destroyClient:
        return _destroyClient(call);
      case DartMethodName.startDeviceScan:
        return _startDeviceScan(call);
      case DartMethodName.stopDeviceScan:
        return _stopDeviceScan(call);
      case DartMethodName.connectToPeripheral:
        return _connectToDevice(call);
      case DartMethodName.isPeripheralConnected:
        return _isDeviceConnected(call);
      case DartMethodName.disconnectOrCancelConnectionToPeripheral:
        return _disconnectOrCancelConnection(call);
      case DartMethodName.discoverAllServicesAndCharacteristics:
        return _discoverAllServicesAndCharacteristics(call);
      case DartMethodName.readCharacteristicForDevice:
        return _readCharacteristicForDevice(call);
      case DartMethodName.readCharacteristicForService:
        return _readCharacteristicForService(call);
      case DartMethodName.readCharacteristicForIdentifier:
        return _readCharacteristicForIdentifier(call);
      case DartMethodName.writeCharacteristicForDevice:
        return _writeCharacteristicForDevice(call);
      case DartMethodName.writeCharacteristicForService:
        return _writeCharacteristicForService(call);
      case DartMethodName.writeCharacteristicForIdentifier:
        return _writeCharacteristicForIdentifier(call);
      default:
        return Future.error(
          SimulatedBleError(
            BleErrorCode.UnknownError,
            "${call.method} is not implemented",
          ),
        );
    }
  }

  Future<void> _createClient(MethodCall call) {
    return _manager._createClient();
  }

  Future<void> _destroyClient(MethodCall call) {
    return _manager._destroyClient();
  }

  Future<void> _startDeviceScan(MethodCall call) {
    return _manager._startDeviceScan();
  }

  Future<void> _stopDeviceScan(MethodCall call) {
    return _manager._stopDeviceScan();
  }

  Future<void> _connectToDevice(MethodCall call) {
    return _manager._connectToDevice(call.arguments[ArgumentName.id] as String);
  }

  Future<bool> _isDeviceConnected(MethodCall call) {
    return _manager
        ._isDeviceConnected(call.arguments[ArgumentName.id] as String);
  }

  Future<void> _disconnectOrCancelConnection(MethodCall call) {
    return _manager._disconnectOrCancelConnection(
        call.arguments[ArgumentName.id] as String);
  }

  Future<List<dynamic>> _discoverAllServicesAndCharacteristics(
      MethodCall call) async {
    List<SimulatedService> services =
        await _manager.discoverAllServicesAndCharacteristics(
            call.arguments[ArgumentName.id] as String);
    dynamic mapped = services
        .map(
          (service) => <String, dynamic>{
            Metadata.serviceUuid: service.uuid,
            Metadata.serviceId: service.id,
            SimulationArgumentName.characteristics: service
                .characteristics()
                .map(
                  (characteristic) => _convertToMap(
                      call.arguments[ArgumentName.id], characteristic, null),
                )
                .toList(),
          },
        )
        .toList();

    return mapped;
  }

  Future<dynamic> _readCharacteristicForIdentifier(MethodCall call) async {
    Map<dynamic, dynamic> arguments = call.arguments;
    return _manager
        ._readCharacteristicForIdentifier(
            arguments[SimulationArgumentName.characteristicIdentifier])
        .then((characteristic) => _convertToMap(
              arguments[SimulationArgumentName.deviceIdentifier],
              characteristic.characteristic,
              characteristic.value,
            ));
  }

  Future<dynamic> _readCharacteristicForDevice(MethodCall call) async {
    Map<dynamic, dynamic> arguments = call.arguments;
    return _manager
        ._readCharacteristicForDevice(
          arguments[SimulationArgumentName.deviceIdentifier],
          arguments[SimulationArgumentName.serviceUuid],
          arguments[SimulationArgumentName.characteristicUuid],
        )
        .then((characteristic) => _convertToMap(
              arguments[SimulationArgumentName.deviceIdentifier],
              characteristic.characteristic,
              characteristic.value,
            ));
  }

  Future<dynamic> _readCharacteristicForService(MethodCall call) async {
    Map<dynamic, dynamic> arguments = call.arguments;
    return _manager
        ._readCharacteristicForService(
          arguments[SimulationArgumentName.serviceId],
          arguments[SimulationArgumentName.characteristicUuid],
        )
        .then((characteristicResponse) => _convertToMap(
              arguments[SimulationArgumentName.deviceIdentifier],
              characteristicResponse.characteristic,
              characteristicResponse.value,
            ));
  }

  Future<dynamic> _writeCharacteristicForIdentifier(MethodCall call) async {
    Map<dynamic, dynamic> arguments = call.arguments;
    return _manager
        ._writeCharacteristicForIdentifier(
          call.arguments[SimulationArgumentName.characteristicIdentifier],
          call.arguments[SimulationArgumentName.value],
        )
        .then((characteristicResponse) => _convertToMap(
              arguments[SimulationArgumentName.deviceIdentifier],
              characteristicResponse,
              arguments[SimulationArgumentName.value],
            ));
  }

  Future<dynamic> _writeCharacteristicForDevice(MethodCall call) async {
    Map<dynamic, dynamic> arguments = call.arguments;
    return _manager
        ._writeCharacteristicForDevice(
          arguments[SimulationArgumentName.deviceIdentifier],
          arguments[SimulationArgumentName.serviceUuid],
          arguments[SimulationArgumentName.characteristicUuid],
          arguments[SimulationArgumentName.value],
        )
        .then((characteristic) => _convertToMap(
              arguments[SimulationArgumentName.deviceIdentifier],
              characteristic,
              arguments[SimulationArgumentName.value],
            ));
  }

  Future<dynamic> _writeCharacteristicForService(MethodCall call) async {
    Map<dynamic, dynamic> arguments = call.arguments;
    return _manager
        ._writeCharacteristicForService(
          arguments[SimulationArgumentName.serviceId],
          arguments[SimulationArgumentName.characteristicUuid],
          arguments[SimulationArgumentName.value],
        )
        .then((characteristic) => _convertToMap(
              arguments[SimulationArgumentName.deviceIdentifier],
              characteristic,
              arguments[SimulationArgumentName.value],
            ));
  }

  Map<String, dynamic> _convertToMap(
    String peripheralId,
    SimulatedCharacteristic characteristic,
    Uint8List value,
  ) =>
      <String, dynamic>{
        Metadata.deviceIdentifier: peripheralId,
        Metadata.characteristicId: characteristic.id,
        Metadata.characteristicUuid: characteristic.uuid,
        Metadata.value: value,
        Metadata.serviceUuid: characteristic.service.uuid,
        Metadata.serviceId: characteristic.service.id,
        Metadata.isReadable: characteristic.isReadable,
        Metadata.isWritableWithResponse: characteristic.isWritableWithResponse,
        Metadata.isWritableWithoutResponse:
            characteristic.isWritableWithoutResponse,
        Metadata.isNotifiable: characteristic.isNotifiable,
        Metadata.isNotifying: characteristic.isNotifying,
        Metadata.isIndicatable: characteristic.isIndicatable,
      };
}
