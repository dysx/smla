class NewVersionModel {
  NewVersionModel({
    this.link,
    this.forcedUpdate,
    this.versionCode,
    this.versionName,
    this.h5VersionCode,
  });

  NewVersionModel.fromJson(dynamic json) {
    link = json['link'];
    forcedUpdate = json['forcedUpdate'];
    versionCode = json['versionCode'];
    versionName = json['versionName'];
    h5VersionCode = json['h5VersionCode'];
  }

  String? link;
  bool? forcedUpdate;
  String? versionCode;
  String? versionName;
  num? h5VersionCode;

  NewVersionModel copyWith({
    String? link,
    bool? forcedUpdate,
    String? versionCode,
    String? versionName,
    num? h5VersionCode,
  }) =>
      NewVersionModel(
        link: link ?? this.link,
        forcedUpdate: forcedUpdate ?? this.forcedUpdate,
        versionCode: versionCode ?? this.versionCode,
        versionName: versionName ?? this.versionName,
        h5VersionCode: h5VersionCode ?? this.h5VersionCode,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['link'] = link;
    map['forcedUpdate'] = forcedUpdate;
    map['versionCode'] = versionCode;
    map['versionName'] = versionName;
    map['h5VersionCode'] = h5VersionCode;
    return map;
  }
}
