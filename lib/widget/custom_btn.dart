import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:SmartLoan/util/extension.dart';

class CustomBtn extends StatelessWidget {
  const CustomBtn({
    Key? key,
    this.backgroundColor,
    this.content,
    this.onPress,
    this.radius,
  }) : super(key: key);

  final double? radius;
  final Color? backgroundColor;
  final String? content;
  final Function? onPress;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? const Color(0xffED7622), // 设置背景颜色为橙色
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 90), // 设置圆角半径为20
        ),
      ),
      onPressed: () {
        onPress?.call();
      },
      child: Center(
        child: (content ?? '').text(color: Colors.white),
      )
    );
  }
}
