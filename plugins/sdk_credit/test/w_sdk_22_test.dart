import 'package:flutter_test/flutter_test.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sdk_credit/sdk.dart';
import 'package:sdk_credit/sdk_method_channel.dart';
import 'package:sdk_credit/sdk_platform_interface.dart';

class MockWSdk22Platform
    with MockPlatformInterfaceMixin
    implements SdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> getAppList() {
    // TODO: implement getAppList
    throw UnimplementedError();
  }

  @override
  Future<String?> getContact() {
    // TODO: implement getContact
    throw UnimplementedError();
  }

  @override
  Future<String?> getDevice() {
    // TODO: implement getDevice
    throw UnimplementedError();
  }

  @override
  Future<String?> getPhoto() {
    // TODO: implement getPhoto
    throw UnimplementedError();
  }

  @override
  Future<String?> getSms() {
    // TODO: implement getSms
    throw UnimplementedError();
  }
}

void main() {
  final SdkPlatform initialPlatform = SdkPlatform.instance;

  test('$MethodChannelSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSdk>());
  });

  test('getPlatformVersion', () async {
    SdkPlugin wSdk22Plugin = SdkPlugin();
    MockWSdk22Platform fakePlatform = MockWSdk22Platform();
    SdkPlatform.instance = fakePlatform;

    // expect(await wSdk22Plugin.getPlatformVersion(), '42');
  });
}
