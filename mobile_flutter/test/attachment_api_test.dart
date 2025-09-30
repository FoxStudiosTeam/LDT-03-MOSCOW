import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for AttachmentApi
void main() {
  final instance = Openapi().getAttachmentApi();

  group(AttachmentApi, () {
    // Attach files to project ⚠️⚠️⚠️IT IGNORES NOT FOUND ERROR - SO ATTACHMENT MAY BE LOST IF ID IS INCORRECT⚠️⚠️⚠️
    //
    //Future<Attachments> uploadProject(String id) async
    test('test uploadProject', () async {
      // TODO
    });

    // Attach files to punishment_item ⚠️⚠️⚠️IT IGNORES NOT FOUND ERROR - SO ATTACHMENT MAY BE LOST IF ID IS INCORRECT⚠️⚠️⚠️
    //
    //Future<Attachments> uploadPunishmentItem(String id) async
    test('test uploadPunishmentItem', () async {
      // TODO
    });

    // Attach files to reports ⚠️⚠️⚠️IT IGNORES NOT FOUND ERROR - SO ATTACHMENT MAY BE LOST IF ID IS INCORRECT⚠️⚠️⚠️
    //
    //Future<Attachments> uploadReports(String id) async
    test('test uploadReports', () async {
      // TODO
    });

  });
}
