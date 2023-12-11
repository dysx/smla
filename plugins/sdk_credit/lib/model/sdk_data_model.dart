///
/// SDK参数Model
///
///
class SdkDataModel {
  String? action;
  String? id;
  Data? data;
  String? callback;

  // 数据
  String? appStr;
  String? contactStr;
  String? devicesStr;
  String? photoStr;
  String? locationStr;
  String? smsStr;
  String? callStr;

  SdkDataModel({
    this.action,
    this.id,
    this.data,
    this.callback,
  });

  SdkDataModel.fromJson(Map<String, dynamic> json) {
    action = json['action'];
    id = json['id'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    callback = json['callback'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['action'] = action;
    data['id'] = id;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['callback'] = callback;
    return data;
  }
}

class Data {
  String? orderNo;
  String? userId;
  bool? isSubmit;
  bool? appList;
  bool? sms;
  bool? exif;
  bool? device;
  bool? contact;
  bool? location;

  Data({
    this.orderNo,
    this.userId,
    this.isSubmit,
    this.appList,
    this.sms,
    this.exif,
    this.device,
    this.contact,
    this.location,
  });

  Data.fromJson(Map<String, dynamic> json) {
    orderNo = json['orderNo'];
    userId = json['userId'];
    isSubmit = json['isSubmit'];
    appList = json['appList'];
    sms = json['sms'];
    exif = json['exif'];
    device = json['device'];
    contact = json['contact'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderNo'] = orderNo;
    data['userId'] = userId;
    data['isSubmit'] = isSubmit;
    data['appList'] = appList;
    data['sms'] = sms;
    data['exif'] = exif;
    data['device'] = device;
    data['contact'] = contact;
    data['location'] = location;
    return data;
  }
}
