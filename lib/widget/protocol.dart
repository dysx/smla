import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:SmartLoan/util/extension.dart';

import '../routers/app_routes.dart';
import '../util/plat_form_utils.dart';

class Protocol extends StatefulWidget {
  Protocol({
    Key? key,
    this.isAgree = false,
    this.checkBoxOnPress
  }) : super(key: key);

  late bool isAgree;
  final Function(bool)? checkBoxOnPress;

  @override
  State<Protocol> createState() => _ProtocolState();
}

class _ProtocolState extends State<Protocol> {

  // bool isAgree = true;
  // 隐私协议
  String prefix = 'Estoy de acuerdo con <';
  String termsOfService = 'Condiciones del servicio';
  String and = '> y <';
  String privacyPolicy = 'Política de privacidad';
  String end = '>';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            bool isAgree = !widget.isAgree;
            setState(() {
              widget.isAgree = isAgree;
            });
            widget.checkBoxOnPress?.call(isAgree);
          },
          child: (widget.isAgree ? "ic_selected" : "ic_unselect").icon(width: 17.r, height: 17.r),
        ),
        SizedBox(width: 10.w),
        Expanded(
            child: Text.rich(
              textSpan(
                prefix,
                false,
                children: [
                  textSpan(termsOfService, true, onTap: (){
                    // debugPrint('用户协议');
                    Get.toNamed(AppRoutes.deal, arguments: {
                      "url": "http://testmexico-smartloan-3003.gccloud.xyz/#/termsCondition"});
                    PlatFormUtils().log('loginPhone_termOfService');

                  }),
                  textSpan(and, false),
                  textSpan(privacyPolicy, true, onTap: (){
                    // debugPrint('隐私协议');
                    Get.toNamed(AppRoutes.deal, arguments: {
                      "url": "http://testmexico-smartloan-3003.gccloud.xyz/#/provicy"});
                    PlatFormUtils().log('loginPhone_privacy');

                  }),
                  textSpan(end, false),
                ]
              ),
              softWrap: true,
            )
        )
      ],
    );
  }

  TextSpan textSpan(String text, bool highLight, {Function? onTap, List<InlineSpan>? children}) {
    TextStyle normalStyle = const TextStyle(fontSize: 12, color: Colors.black);
    TextStyle highLightStyle = TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold);

    return TextSpan(
      text: text,
      style: highLight == true ? highLightStyle : normalStyle,
      children: children,
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          onTap?.call();
        }
    );
  }
}