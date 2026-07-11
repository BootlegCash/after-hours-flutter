import 'package:url_launcher/url_launcher.dart';

const passwordResetUri =
    'https://www.afterhoursranked.com/accounts/password_reset/';

Future<bool> openPasswordResetPage() async {
  final uri = Uri.parse(passwordResetUri);
  try {
    if (await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      return true;
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
