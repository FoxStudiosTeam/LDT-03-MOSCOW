import 'package:flutter/material.dart';
import 'package:mobile_flutter/main.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> downloadTroughBrowser(String id) async {
  final uri = Uri.parse(APIRootURI).resolve('/api/attachmentproxy/file').replace(queryParameters: {"file_id": id});
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch $uri';
  }
}
