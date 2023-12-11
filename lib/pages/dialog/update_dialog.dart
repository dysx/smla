import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:SmartLoan/util/common_utils.dart';
import 'package:SmartLoan/util/extension.dart';
import 'package:SmartLoan/widget/custom_btn.dart';

import '../../util/plat_form_utils.dart';

class VersionDialog extends Dialog {
  VersionDialog({
    this.forceUpdate = false,
    this.onTap
  });

  bool forceUpdate;
  Function? onTap;

  String dialogTitle = "Nueva versión disponible";
  String dialogContent = "Por favor, actualice a la última  versión";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
                width: 300.w,
                margin: EdgeInsets.only(bottom: forceUpdate ? 0 : 50.h),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      "dialog_bg".img(width: 300.w, fit: BoxFit.fitWidth),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 20.h
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.s,
                          children: [
                            dialogTitle.text(fontSize: 20, fontWeight: FontWeight.bold),
                            SizedBox(height: 10.h),
                            dialogContent.text(),
                            SizedBox(height: 20.h),
                            CustomBtn(
                              content: 'Confirmar',
                              backgroundColor: Color(0xFF4B41A6),
                              onPress: () {
                                onTap?.call();
                              },
                            ),
                            SizedBox(height: 10.h)
                          ],
                        ),
                      ),
                    ],
                  ),
                )
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: forceUpdate ? SizedBox() : GestureDetector(
                  onTap: (){
                    PlatFormUtils().log('updateConfirm_no');
                    Get.back();
                  },
                  child: Center(
                    child: Icon(Icons.cancel_outlined, color: Colors.white, size: 40.r),
                  ),
                )
            )
          ],
        ),
      ),
      onWillPop: () async {
        return false;
      }
    );
  }

  Widget btn(Text content, { Color? color, Function? onPress }) {
    return GestureDetector(
      onTap: () {
        onPress?.call();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? Color(0xFF1846C3),
          borderRadius: BorderRadius.circular(45),
        ),
        child: content,
      ),
    );
  }

}