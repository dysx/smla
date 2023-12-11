// extension on String
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:SmartLoan/util/common_utils.dart';

extension StringExt on String {
  Widget img({double? width, double? height, BoxFit? fit}) {
    return Image.asset("assets/images/$this.png", width: width, height: height, fit: fit ?? BoxFit.cover);
  }

  Widget icon({double? width, double? height, BoxFit? fit}) {
    return Image.asset("assets/icon/$this.png", width: width, height: height, fit: fit);
  }

  Text text({int? fontSize, Color? color, FontWeight? fontWeight}) {
    return Text(this,
        style: TextStyle(fontSize: (fontSize ?? 14).sp, color: color ?? Colors.black, fontWeight: fontWeight));
  }

  void showToast() {
    // 需要兼容埋点page
    CommonUtils.showToast(this);
  }
}

extension WidgetExt on Widget {
  Widget decorationBox({
    Color? color,
    double? radius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxBorder? boxBorder,
  }) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
          color: color ?? const Color(0xffF3F4F1),
          border: boxBorder,
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 90))),
      child: this,
    );
  }
}
