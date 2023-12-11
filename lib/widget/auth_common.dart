import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:SmartLoan/util/extension.dart';
import 'package:SmartLoan/widget/custom_btn.dart';
import 'package:SmartLoan/widget/protocol.dart';

class AuthBg extends StatefulWidget {
  const AuthBg({
    Key? key,
    required this.child,
    this.isAgree,
    this.onAgree,
    this.onPress,
  }) : super(key: key);

  final Widget child;
  final bool? isAgree;
  final Function? onAgree;
  final Function? onPress;

  @override
  State<AuthBg> createState() => _AuthBgState();
}

class _AuthBgState extends State<AuthBg> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff1579FB),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(children: [SizedBox()],),
          "coin".img(width: 274.w, height: 128.h, fit: BoxFit.contain),
          Container(
            width: 335.w,
            height: 373.h,
            padding: EdgeInsets.symmetric(
                horizontal: 17.w,
                vertical: 30.h
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.white,
            ),
            child: Column(
              children: [
                "Solicitud en línea las".text(
                    fontSize: 23
                ),
                "24 horas".text(
                    fontSize: 23, fontWeight: FontWeight.bold
                ),
                widget.child,
                CustomBtn(
                  content: 'Apply now!',
                  onPress: () {
                    widget.onPress?.call();
                  },
                ),
                const Expanded(
                  child: SizedBox()
                ),
                Protocol(
                  isAgree: widget.isAgree ?? true,
                  checkBoxOnPress: (value) {
                    widget.onAgree?.call(value);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
