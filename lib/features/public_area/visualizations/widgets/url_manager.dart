import 'package:url_launcher/url_launcher_string.dart';

class UrlManager {
  launchUrl({required String url}) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Não consegui abrir o link $url';
    }
  }

  launchEmail({String email = ''}) async {
    email = email.isNotEmpty ? email : "mailto:marcosmhs@live.com";
    if (await canLaunchUrlString(email)) {
      await launchUrlString(email);
    } else {
      throw 'Não consegui abrir o link';
    }
  }
}
