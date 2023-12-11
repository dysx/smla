class LoginDataModel {
  LoginDataModel({
    this.token,
    this.userId,
    this.mobile,
    this.packageName,
  });

  LoginDataModel.fromJson(dynamic json) {
    token = json['token'];
    userId = json['userId'].toString();
    mobile = json['mobile'];
    packageName = json['packageName'];
  }

  String? token;
  String? userId;
  String? mobile;
  String? packageName;

  LoginDataModel copyWith({
    String? token,
    String? userId,
    String? mobile,
    String? packageName,
  }) =>
      LoginDataModel(
        token: token ?? this.token,
        userId: userId ?? this.userId,
        mobile: userId ?? this.mobile,
        packageName: userId ?? this.packageName,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = token;
    map['userId'] = userId;
    map['mobile'] = mobile;
    map['packageName'] = packageName;
    return map;
  }
}
