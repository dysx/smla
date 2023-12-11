import 'package:SmartLoan/util/plat_form_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppLaunch {
  static launch(String url) async {
    if (await canLaunchUrlString(url)) {
      launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  static googleLaunch(String iru) async {
    if (iru.startsWith('http')) {
      launch(iru);
    } else {
      if (iru.isEmpty) {
        iru = PlatFormUtils().packageName;
      }
      final Uri toGoogleUri = Uri.https('play.google.com', '/store/apps/details', {'id': iru});
      launch(toGoogleUri.toString());
    }
  }

}