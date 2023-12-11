import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommonUtils {
  static void showToast(String msg) {
    Fluttertoast.showToast(msg: msg, backgroundColor: Colors.black45, fontSize: 14);
  }

  static Future showAnimDialog(BuildContext context, Dialog dialog) async {
    await showGeneralDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.4),
        barrierDismissible: false,
        barrierLabel: "",
        transitionDuration: const Duration(milliseconds: 200),
        transitionBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, child) {
          return Transform.scale(
            scale: anim1.value,
            child: Opacity(
              opacity: anim1.value,
              child: child,
            ),
          );
        },
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return dialog;
        }
    );
  }

}


