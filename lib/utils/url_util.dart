import 'package:url_launcher/url_launcher.dart';

launchThisURL(String passedUrl) async {
  final url = Uri.parse(passedUrl);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    // Handle the case where the URL cannot be launched
    // ignore: avoid_print
    print('Could not launch $url');
  }
}
