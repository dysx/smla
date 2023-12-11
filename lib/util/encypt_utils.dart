import 'package:encrypt/encrypt.dart';
import 'package:flutter/cupertino.dart' as material;

class EncryptUtil {
  EncryptUtil._();

  static final EncryptUtil _singleton = EncryptUtil._();
  factory EncryptUtil() => _singleton;

  Encrypter? _encryptor;

  Future init(String packageName) async {
    if (_encryptor != null) return;
    final key = Key.fromUtf8(_generateKey(packageName));
    _encryptor = Encrypter(AES(key, mode: AESMode.ecb, padding: 'PKCS7'));
  }

  String encrypt(String plainText) {
    if (_encryptor == null) {
      material.debugPrint('SmlEncryptUtil not init');
      return plainText;
    } else {
      Encrypted encrypted = _encryptor!.encrypt(plainText, iv: IV.fromUtf8(''));
      return encrypted.base16;
    }
  }

  String decrypt(String plainText) {
    if (_encryptor == null) {
      material.debugPrint('SmlEncryptUtil not init');
      return plainText;
    } else {
      return _encryptor!.decrypt16(plainText, iv: IV.fromUtf8(''));
    }
  }

  String _generateKey(String key) {
    String newKey = '';
    for(int i=0; i< 16; i++) {
      if (i > key.length -1 ) {
        newKey += '0';
      } else {
        newKey += key[i];
      }
    }
    return newKey;
  }

}