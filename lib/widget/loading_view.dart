import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:SmartLoan/res/colors.dart';

class LoadingView {
  static final LoadingView singleton = LoadingView._();

  factory LoadingView() => singleton;

  LoadingView._();

  OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;
  bool isVisible = false;

  Future<T> wrap<T>({
    required Future<T> Function() asyncFunction,
    bool showing = true,
  }) async {
    if (showing) show();
    T data;
    try {
      data = await asyncFunction();
    } on Exception catch (_) {
      rethrow;
    } finally {
      dismiss();
    }
    return data;
  }

  void show() async {
    if (isVisible) return;
    _overlayState = Overlay.of(Get.overlayContext!,rootOverlay: true);
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.black38,
          child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 4.w,
                valueColor: const AlwaysStoppedAnimation(Colours.blue_1579FB),
              )),
        );
      },
    );
    isVisible = true;
    _overlayState?.insert(_overlayEntry!);
  }

  dismiss() async {
    if (!isVisible) return;
    _overlayEntry?.remove();
    isVisible = false;
  }
}
