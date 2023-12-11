import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdk_credit/sdk_method_channel.dart';

void main() {
  MethodChannelSdk platform = MethodChannelSdk();
  const MethodChannel channel = MethodChannel('sdk_credit');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
