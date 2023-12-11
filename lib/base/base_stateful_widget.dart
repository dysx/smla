import 'package:flutter/material.dart';

abstract class BaseStatefulWidget extends StatefulWidget {
  const BaseStatefulWidget({Key? key}) : super(key: key);

  @override
  State<BaseStatefulWidget> createState() => getState();

  ///子类实现
  State<BaseStatefulWidget> getState();
}

abstract class BaseState<T extends BaseStatefulWidget> extends State<T> with AutomaticKeepAliveClientMixin {
  bool _isHaveKeyboard = true;

  @override
  void initState() {
    super.initState();
  }

  void setIsHaveKeyboard(bool isHaveKeyboard) {
    this._isHaveKeyboard = isHaveKeyboard;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isHaveKeyboard) {
      return Listener(
        onPointerDown: (_) => closeKeyboard(),
        child: buildContent(context),
      );
    }
    return buildContent(context);
  }

  Widget buildContent(BuildContext context);

  /// 是否包括有输入框，默认没有
  Widget? buildBodyWithTextFiled() => null;

  /// 关闭键盘
  void closeKeyboard() {
    // 关闭软键盘四种方式
//              SystemChannels.textInput.invokeMethod('TextInput.hide');
//              FocusScope.of(context).requestFocus(FocusNode());
//              FocusScope.of(context).unfocus();
//              _focusNode.unfocus();
//              FocusManager.instance.primaryFocus.unfocus();
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  bool get wantKeepAlive => false;
}
