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

/// A characteristic of a local peripheral's [Service].
///
/// It contains a single value and any number of [Descriptor]s describing that
/// value. The properties of a characteristic determine how you can use
/// a characteristic’s value, and how you access the descriptors.
class Characteristic extends InternalCharacteristic {
  /// The [Service] to which this characteristic belongs.
  Service service;

  ManagerForCharacteristic _manager;

  /// The UUID of this characteristic.
  String uuid;

  /// True if this characteristic can be read.
  bool isReadable;

  /// True if this characteristic can be written with resposne.
  bool isWritableWithResponse;

  /// True if this characteristic can be written without resposne.
  bool isWritableWithoutResponse;

  /// True if this characteristic can be monitored.
  bool isNotifiable;

  bool isIndicatable;

  /// Deserializes characteristic from JSON for [service] with [manager].
  Characteristic.fromJson(Map<String, dynamic> jsonObject, Service service,
      ManagerForCharacteristic manager)
      : super(jsonObject[_CharacteristicMetadata.id]) {
    _manager = manager;
    this.service = service;
    uuid = jsonObject[_CharacteristicMetadata.uuid];
    isReadable = jsonObject[_CharacteristicMetadata.isReadable];
    isWritableWithResponse =
        jsonObject[_CharacteristicMetadata.isWritableWithResponse];
    isWritableWithoutResponse =
        jsonObject[_CharacteristicMetadata.isWritableWithoutResponse];
    isNotifiable = jsonObject[_CharacteristicMetadata.isNotifiable];
    isIndicatable = jsonObject[_CharacteristicMetadata.isIndicatable];
  }

  /// Reads the value of this characteristic.
  ///
  /// The value can be read only if [isReadable] is `true`.
  Future<Uint8List> read({String transactionId}) =>
      _manager.readCharacteristicForIdentifier(
        service.peripheral,
        this,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Writes the value of this characteristic.
  ///
  /// The value can be written only if [isWritableWithResponse] or
  /// [isWritableWithoutResponse] is `true`.
  Future<void> write(
    Uint8List bytes,
    bool withResponse, {
    String transactionId,
  }) =>
      _manager.writeCharacteristicForIdentifier(
        service.peripheral,
        this,
        bytes,
        withResponse,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Returns a [Stream] of values emitted by this characteristic.
  Stream<Uint8List> monitor({String transactionId}) =>
      _manager.monitorCharacteristicForIdentifier(
        service.peripheral,
        this,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Returns a list of [Descriptor]s of this characteristic.
  Future<List<Descriptor>> descriptors() =>
      _manager.descriptorsForCharacteristic(this);

  /// Reads the value of a [Descriptor] identified by [descriptorUuid].
  Future<DescriptorWithValue> readDescriptor(
    String descriptorUuid, {
    String transactionId,
  }) =>
      _manager.readDescriptorForCharacteristic(
        this,
        descriptorUuid,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Writes the [value] of a [Descriptor] identified by [descriptorUuid].
  Future<Descriptor> writeDescriptor(
    String descriptorUuid,
    Uint8List value, {
    String transactionId,
  }) =>
      _manager.writeDescriptorForCharacteristic(
        this,
        descriptorUuid,
        value,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Characteristic &&
          runtimeType == other.runtimeType &&
          service == other.service &&
          _manager == other._manager &&
          uuid == other.uuid &&
          isReadable == other.isReadable &&
          isWritableWithResponse == other.isWritableWithResponse &&
          isWritableWithoutResponse == other.isWritableWithoutResponse &&
          isNotifiable == other.isNotifiable &&
          isIndicatable == other.isIndicatable;

  @override
  int get hashCode =>
      service.hashCode ^
      _manager.hashCode ^
      uuid.hashCode ^
      isReadable.hashCode ^
      isWritableWithResponse.hashCode ^
      isWritableWithoutResponse.hashCode ^
      isNotifiable.hashCode ^
      isIndicatable.hashCode;

  @override
  String toString() {
    return 'Characteristic{service: $service,'
        ' _manager: $_manager,'
        ' uuid: $uuid,'
        ' isReadable: $isReadable,'
        ' isWritableWithResponse: $isWritableWithResponse,'
        ' isWritableWithoutResponse: $isWritableWithoutResponse,'
        ' isNotifiable: $isNotifiable,'
        ' isIndicatable: $isIndicatable}';
  }
}

/// Represents a [Characteristic] with its value.
class CharacteristicWithValue extends Characteristic with WithValue {
  CharacteristicWithValue.fromJson(
    Map<String, dynamic> jsonObject,
    Service service,
    ManagerForCharacteristic manager,
  ) : super.fromJson(jsonObject, service, manager) {
    value = base64Decode(jsonObject[_CharacteristicMetadata.value]);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        super == other &&
            other is CharacteristicWithValue &&
            value?.toString() == other.value?.toString() &&
            runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => super.hashCode;

  @override
  String toString() {
    return super.toString() +
        ' CharacteristicWithValue{value = ${value.toString()}';
  }
}
