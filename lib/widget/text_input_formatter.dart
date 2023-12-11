import 'package:flutter/services.dart';

// 输入框限制，手机号最高输入10位，前3位，中间3位，后4位之间需要空格分隔开
// 如果删除到空格。则直接删除空格和前一位
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 限制输入长度
    if (newValue.text.length > 12) {
      return oldValue;
    }

    // 删除
    if (oldValue.text.length > newValue.text.length) {
      String prefix = '';
      String suffix = '';
      int offset = 0;
      bool isLastIsSpace = false;

      // 判断索引是否在最后
      if (oldValue.selection.baseOffset == oldValue.text.length) {
        prefix = oldValue.text;
        offset = prefix.length - 2;
      } else {
        prefix = oldValue.text.substring(0, oldValue.selection.baseOffset);
        suffix = oldValue.text.substring(oldValue.selection.baseOffset);
      }
      isLastIsSpace = prefix.endsWith(' ');

      if (isLastIsSpace) {
        offset = prefix.length - 2;
        // 删除空格
        return TextEditingValue(
          text: prefix.substring(0, offset) + suffix,
          selection: TextSelection.collapsed(offset: offset),
        );
      } else {
        offset = prefix.length - 1;
        // 删除前一位
        return TextEditingValue(
          text: prefix.substring(0, offset),
          selection: TextSelection.collapsed(offset: offset),
        );
      }
    }

    // 输入
    if (newValue.text.length == 3 || newValue.text.length == 7) {
      return TextEditingValue(
        text: '${newValue.text} ',
        selection: TextSelection.collapsed(offset: newValue.text.length + 1),
      );
    }

    return newValue;
  }
}
