import 'package:url_launcher/url_launcher.dart';

void sendEmail() async {
  final Uri params = Uri(
    scheme: 'mailto',
    path: 'seifibrahim32@gmail.com',
    query:
        encodeQueryParameters(<String, String>{'subject': 'Write your issue'}),
  );
  await launchUrl(params);
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
