import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sdk_method_channel.dart';

abstract class SdkPlatform extends PlatformInterface {
  /// Constructs a WSdk22Platform.
  SdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static SdkPlatform _instance = MethodChannelSdk();

  /// The default instance of [SdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelSdk].
  static SdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SdkPlatform] when
  /// they register themselves.
  static set instance(SdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getAppList() {
    throw UnimplementedError('getAppList() has not been implemented.');
  }

  Future<String?> getContact() {
    throw UnimplementedError('getContact() has not been implemented.');
  }

  Future<String?> getDevice() {
    throw UnimplementedError('getDevice() has not been implemented.');
  }

  Future<String?> getSms() {
    throw UnimplementedError('getSms() has not been implemented.');
  }

  Future<String?> getPhoto() {
    throw UnimplementedError('getPhoto() has not been implemented.');
  }

  Future<String?> getCall() {
    throw UnimplementedError("getCall() has not been implemented");
  }
}
