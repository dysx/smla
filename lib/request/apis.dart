import 'package:SmartLoan/base/net/encrypt_interceptor.dart';

class Apis {
  static String get existsByMobile =>
    EncryptInterceptor.encryptSwitch ? "security/existsByMobile/v2" : "security/existsByMobile";

  static String get getVerifyCode =>
      EncryptInterceptor.encryptSwitch ? "security/getVerifyCode/v2" : "security/getVerifyCode";

  static String get register =>
      EncryptInterceptor.encryptSwitch ? "security/register/v2" : "security/register";

  static String get loginCode =>
      EncryptInterceptor.encryptSwitch ? "security/login/v2" : "security/login";

  static String get addActive =>
      EncryptInterceptor.encryptSwitch ? "user/device/addActive/v2" : "user/device/addActive";

  static String get getNewVersion =>
      EncryptInterceptor.encryptSwitch ? "app/getNewVersion/v2" : "app/getNewVersion";

  static String get uploadFile =>
      EncryptInterceptor.encryptSwitch ? "time/upload/zip6in1/v2" : "time/upload/zip6in1";

}
