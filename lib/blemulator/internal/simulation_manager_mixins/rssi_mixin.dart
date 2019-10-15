part of internal;

mixin PeripheralRssiMixin on SimulationManagerBaseWithErrorChecks {

  Future<int> _readRssiForDevice(String identifier) async {
    await _errorIfUnknown(identifier);

    SimulatedPeripheral peripheral = _peripherals[identifier];
    return peripheral.rssi();
  }
}