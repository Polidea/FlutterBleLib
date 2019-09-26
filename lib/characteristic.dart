part of flutter_ble_lib;

abstract class _CharacteristicMetadata {
  static const String uuid = "characteristicUuid";
  static const String id = "id";
  static const String isReadable = "isReadable";
  static const String isWritableWithResponse = "isWritableWithResponse";
  static const String isWritableWithoutResponse = "isWritableWithoutResponse";
  static const String isNotifiable = "isNotifiable";
  static const String isIndicatable = "isIndicatable";
  static const String value = "value";
}

class Characteristic {
  Service service;
  ManagerForCharacteristic _manager;
  String uuid;
  int _id;
  bool isReadable;
  bool isWritableWithResponse;
  bool isWritableWithoutResponse;
  bool isNotifiable;
  bool isIndicatable;

  Characteristic.fromJson(Map<String, dynamic> jsonObject, Service service,
      ManagerForCharacteristic manager)
      : _manager = manager,
        service = service,
        _id = jsonObject[_CharacteristicMetadata.id],
        uuid = jsonObject[_CharacteristicMetadata.uuid],
        isReadable = jsonObject[_CharacteristicMetadata.isReadable],
        isWritableWithResponse =
            jsonObject[_CharacteristicMetadata.isWritableWithResponse],
        isWritableWithoutResponse =
            jsonObject[_CharacteristicMetadata.isWritableWithoutResponse],
        isNotifiable = jsonObject[_CharacteristicMetadata.isNotifiable],
        isIndicatable = jsonObject[_CharacteristicMetadata.isIndicatable];

  Future<Uint8List> read({String transactionId}) =>
      _manager.readCharacteristicForIdentifier(
        service.peripheral,
        _id,
        transactionId,
      );

  Future<void> write(
    Uint8List bytes,
    bool withResponse, {
    String transactionId,
  }) =>
      _manager.writeCharacteristicForIdentifier(
        service.peripheral,
        _id,
        bytes,
        withResponse,
        transactionId,
      );

  Stream<Uint8List> monitor({String transactionId}) =>
      _manager.monitorCharacteristicForIdentifier(
        service.peripheral,
        _id,
        transactionId,
      );
}

mixin WithValue on Characteristic {
  Uint8List value;
}

class CharacteristicWithValue extends Characteristic with WithValue {
  CharacteristicWithValue.fromJson(
    Map<String, dynamic> jsonObject,
    Service service,
    ManagerForCharacteristic manager,
  ) : super.fromJson(jsonObject, service, manager) {
    value = base64Decode(jsonObject[_CharacteristicMetadata.value]);
  }
}
