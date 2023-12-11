import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:SmartLoan/util/common_utils.dart';
import 'package:SmartLoan/util/extension.dart';
import 'package:SmartLoan/widget/custom_btn.dart';

class PermissionsDialog extends Dialog {
  const PermissionsDialog({super.key, this.onReject, this.onAgree});

  final Function? onReject;
  final Function? onAgree;

  @override
  Widget build(BuildContext context) {
    return PermissionDialogContent(
      onAgree: onAgree,
      onReject: onReject,
    );
  }

  Future show(BuildContext context) async {
    await CommonUtils.showAnimDialog(context, this);
  }
}

class PermissionDialogContent extends StatefulWidget {
  const PermissionDialogContent({Key? key, this.onReject, this.onAgree}) : super(key: key);

  final Function? onReject;
  final Function? onAgree;

  @override
  State<PermissionDialogContent> createState() => _PermissionDialogContentState();
}

class _PermissionDialogContentState extends State<PermissionDialogContent> {
  String permissionTitle = "Permission";
  String permissionHeader =
      "In order to assess your eligibility and expedite loan payments, we require the following permissions";
  String agree = "Agree";
  String deny = "Deny";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: WillPopScope(
          child: Container(
            margin: EdgeInsets.only(top: 80.h),
            // width: 200,
            // height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                topOfDialog(),
                SizedBox(height: 10.h),
                Expanded(
                    child: Container(
                  padding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 15.h),
                  color: Colors.white,
                  child: Column(
                    children: [
                      // header(),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                        decoration: const BoxDecoration(
                            color: Color(0xFFE4F5E6), borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: permissionsList(),
                      )),
                      SizedBox(height: 15.h),
                      btnGroup(context)
                    ],
                  ),
                ))
              ],
            ),
          ),
          onWillPop: () async {
            return false;
          }),
    );
  }

  Widget topOfDialog() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              permissionTitle.text(fontSize: 30),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(height: 10.h),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: const Color(0xffE2E2E2)),
                color: const Color(0xffF3F3F5)),
            child: permissionHeader.text(fontSize: 15),
            // child: Text(smlPoliciesConfig.languageMap['permissionHeader'].toString(),
            //     style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget btnGroup(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              widget.onReject?.call();
              // 退出app
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            },
            child: SizedBox(
              height: 45.h,
              child: Center(
                child: deny.text(),
              ).decorationBox(radius: 90.r, boxBorder: Border.all(color: const Color(0xffE2E2E2))),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: SizedBox(
            height: 45.h,
            child: CustomBtn(
              backgroundColor: const Color(0xff1579FB),
              content: agree,
              onPress: () {
                widget.onAgree?.call();
                Get.back();
              },
            ),
          ),
        )
      ],
    );
  }

  Widget permissionsList() {
    return Column(
      children: [
        "1.Uploaded and transmitted names and phone numbers will be used to facilitate your selection of emergency contacts from your address book, while we use this data to prevent fraud and determine your credit eligibility, we do not use address book data to con"
            .text(),
        "2.We only collect and monitor financial transaction SMS, including the name of the counter party, transaction description and transaction amount, for credit risk assessment. This credit risk assessment enables faster and faster loan payments. You will not "
            .text(),
        "3.Get your location, as soon as you confirm that you are a user in Nigeria, we only provide loans in Nigeria."
            .text()
      ],
    );
  }
}
