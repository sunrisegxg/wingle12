

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';

class DynamicLinkProvider {
  //create the link
  Future<String> createLink(String refCode) async {
    final String url = "http://com.example.app?ref=$refCode";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      link: Uri.parse(url),
      uriPrefix: "https://wingle19.page.link",
      androidParameters: const AndroidParameters(packageName: "com.example.app", minimumVersion: 0),
      // iosParameters: const IOSParameters(bundleId: "com.example.com", minimumVersion: "0"),
    );
    final FirebaseDynamicLinks link = await FirebaseDynamicLinks.instance;
    final refLink = await link.buildShortLink(parameters);
    return refLink.shortUrl.toString();
  }

  //Init dynamic links
  void initDynamicLink() async {
    final instanceLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (instanceLink != null) {
      final Uri refLink = instanceLink.link;
      Share.share("This is the link ${refLink.data}");
    }
  }
}