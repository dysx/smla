import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../base/base_util.dart';
import '../sdk.dart';
import 'logger.dart';

class LocationUtil extends BaseUtil {
  static final LocationUtil _singleton = LocationUtil._internal();

  factory LocationUtil() {
    return _singleton;
  }

  LocationUtil._internal();

  @override
  Future<String?> exec(AfEvent? afEvent, {bool isSubmit = false}) async {
    try {
      // AF回调开始
      afEvent?.call('sdk_location_get');
      final rlt = await _assembleData();
      Log().LogD('location data = $rlt');
      // isSubmit = true 即使获取不到也返回默认数据
      if ((rlt?.isNotEmpty ?? false) || isSubmit == true) {
        // AF回调成功
        afEvent?.call('sdk_location_success');
        return (rlt?.isNotEmpty ?? false) ? rlt : _defaultLocation();
      } else {
        afEvent?.call('sdk_fail_location');
      }
    } catch (e) {
      // AF回调失败
      afEvent?.call('sdk_fail_location');
      Log().LogE(e.toString());
    }
    return null;
  }

  ///
  /// 组装数据，根据插件自己组装
  ///
  Future<String?> _assembleData() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      try {
        // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium, forceAndroidLocationManager: true, timeLimit: const Duration(seconds: 10));
        Position? position = await Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);
        if (position != null) {
          return jsonEncode(await _geoCoding(position!));
        } else {
          return _defaultLocation();
        }
      } on Exception catch (e) {
        Log().LogW(e.toString());
        return null;
      }
    } else {
      return null;
    }
  }

  ///
  /// 另一种方法，插件直接返回组装好的字符串
  ///
  Future<Map<String, dynamic>> _geoCoding(Position position) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    return {
      "gps": {
        "latitude": position.latitude,
        "longitude": position.longitude,
      },
      "gps_address_province": placeMarks[0].administrativeArea,
      "gps_address_city": placeMarks[0].locality,
      "gps_address_street": placeMarks[0].thoroughfare,
      "gps_address_address": placeMarks[0].street,
    };
  }

  // 默认数据
  String _defaultLocation() {
    final rlt = {
      "gps_address_province": "NaN",
      "gps_address_city": "NaN",
      "gps_address_street": "NaN",
      "gps_address_address": "NaN",
      "gps": {
        "latitude": "NaN",
        "longitude": "NaN",
      }
    };

    return jsonEncode(rlt);
  }
}
