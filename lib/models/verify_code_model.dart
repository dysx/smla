class VerifyCodeModel {
  VerifyCodeModel({
    this.code,
    this.enableAutoLogin,
    this.channelType,
  });

  VerifyCodeModel.fromJson(dynamic json) {
    code = json['code'];
    enableAutoLogin = json['enableAutoLogin'];
    channelType = json['channelType'];
  }

  String? code;
  bool? enableAutoLogin;
  int? channelType;

  VerifyCodeModel copyWith({
    String? code,
    bool? enableAutoLogin,
    int? channelType,
  }) =>
      VerifyCodeModel(
        code: code ?? this.code,
        enableAutoLogin: enableAutoLogin ?? this.enableAutoLogin,
        channelType: channelType ?? this.channelType,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    map['enableAutoLogin'] = enableAutoLogin;
    map['channelType'] = channelType;
    return map;
  }
}
