part of flutter_ble_lib;

enum LogLevel { NONE, VERBOSE, DEBUG, INFO, WARNING, ERROR }

mixin LogLevelMixin on FlutterBLE {

  Future<void> setLogLevel(LogLevel logLevel) async {
    print("set log level to ${describeEnum(logLevel)}");
    return await _methodChannel.invokeMethod(MethodName.setLogLevel, <String, dynamic>{
      ArgumentName.logLevel: describeEnum(logLevel),
    });
  }

  Future<LogLevel> logLevel() async {
    String logLevelName = await _methodChannel.invokeMethod(MethodName.logLevel);
    return _logLevelFromString(logLevelName);
  }

  LogLevel _logLevelFromString(String logLevelName) {
    print("try to get log level from: $logLevelName");
    return LogLevel.values.firstWhere((e) => e.toString() == 'LogLevel.' + logLevelName);
  }
}