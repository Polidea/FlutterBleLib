import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_ble_lib/blemulator/blemulator.dart';

class SensorTag extends SimulatedPeripheral {

  TemperatureDataCharacteristic dataCharacteristic;

  SensorTag(
      {String id = "4B:99:4C:34:DE:77",
      String name = "SensorTag",
      String localName = "SensorTag"})
      : super(
            name: name,
            id: id,
            advertisementInterval: Duration(milliseconds: 800),
            services: [
              SimulatedService(
                  uuid: "F000AA00-0451-4000-B000-000000000000",
                  isAdvertised: true,
                  characteristics: [
                    TemperatureDataCharacteristic(),
                    TemperatureConfigCharacteristic(),
                    SimulatedCharacteristic(
                        uuid: "F000AA03-0451-4000-B000-000000000000",
                        value: Uint8List.fromList([50]),
                        convenienceName: "IR Temperature Period"),
                  ],
                  convenienceName: "Temperature service"),
              SimulatedService(
                  uuid: "F000AA10-0451-4000-B000-000000000000",
                  isAdvertised: true,
                  characteristics: [
                    SimulatedCharacteristic(
                        uuid: "F000AA12-0451-4000-B000-000000000000",
                        value: Uint8List.fromList([0, 0]),
                        convenienceName: "Accelerometer Config"),
                    SimulatedCharacteristic(
                        uuid: "F000AA13-0451-4000-B000-000000000000",
                        value: Uint8List.fromList([0, 0]),
                        convenienceName: "Accelerometer Period"),
                  ],
                  convenienceName: "Accelerometer Service")
            ]) {
    scanInfo.localName = localName;
    dataCharacteristic = services()
        .firstWhere(
            (service) => service.uuid == "F000AA00-0451-4000-B000-000000000000")
        .characteristics()
        .firstWhere((characteristic) =>
            characteristic is TemperatureDataCharacteristic);
  }

  @override
  Future<bool> onConnectRequest() async {
    await Future.delayed(Duration(milliseconds: 200));
    return super.onConnectRequest();
  }

  @override
  Future<void> onConnect() async {
    await super.onConnect();
    _startEmittingTemperatureUpdates();
  }

  void _startEmittingTemperatureUpdates() async {
    while (isConnected()) {
      await Future.delayed(Duration(milliseconds: 300));
      await dataCharacteristic.write(getValueToWrite());
    }
  }

  Uint8List getValueToWrite() {
    if (dataCharacteristic.isEnabled) {
      Random random = Random();
      return Uint8List.fromList([
        random.nextInt(200),
        random.nextInt(200),
        random.nextInt(200),
        random.nextInt(200)
      ]);
    } else
      return Uint8List.fromList([0, 0, 0, 0]);
  }
}

class TemperatureDataCharacteristic extends SimulatedCharacteristic {
  bool isEnabled = false;

  TemperatureDataCharacteristic()
      : super(
          uuid: "F000AA01-0451-4000-B000-000000000000",
          value: Uint8List.fromList([101, 254, 64, 12]),
          convenienceName: "IR Temperature Data",
          isNotifiable: true,
        );
}

class TemperatureConfigCharacteristic extends SimulatedCharacteristic {
  TemperatureConfigCharacteristic()
      : super(
          uuid: "F000AA02-0451-4000-B000-000000000000",
          value: Uint8List.fromList([0]),
          convenienceName: "IR Temperature Config",
        );

  @override
  Future<void> write(Uint8List value) async {
    await super.write(value);
    TemperatureDataCharacteristic dataCharacteristic =
        service.characteristics().firstWhere(
              (characteristic) =>
                  characteristic is TemperatureDataCharacteristic,
            );
    dataCharacteristic.isEnabled = value.first == 1;
  }
}
