import 'dart:async';

import 'package:flutter/cupertino.dart';

// 倒计时时间
const int kDefaultCountDown = 60;

class SmsState {

  late String phone;
  late bool existed;
  bool isShowVoice1 = true;
  bool isShowVoice2 = false;
  bool isShowVoice3 = false;
  bool sendVoiceCode = false;
  TextEditingController smsCtrl = TextEditingController();
  FocusNode smsFNode = FocusNode();

  // 倒计时
  int countDown = kDefaultCountDown;
  Timer? timer;
  bool get isGetCodeEnable => countDown == kDefaultCountDown;

  bool isAgree = true;

}
