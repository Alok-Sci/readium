import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void handleShareArticle(String title, String url) {
  Share.share('$title\n\n$url', subject: title);
}

void handleOpenInMedium(url) {
  // Open Medium's article
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
