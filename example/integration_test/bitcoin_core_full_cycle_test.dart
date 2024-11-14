import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:payjoin_flutter/uri.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('fetch_ohttp_keys', () {
    setUp(() async {});

    test('test fetch_ohttp_keys', () async {
      // Create the directory and relay URLs
      final directory = await Url.fromStr('https://payjo.in');
      final relay = await Url.fromStr('https://pj.bobspacebkk.com');

      // Call the fetch_ohttp_keys function
      final result =
          await fetchOhttpKeys(ohttpRelay: relay, payjoinDirectory: directory);

      // Assert the result (this is a placeholder, adjust based on expected behavior)
      expect(result, isNotNull);
      // Add more assertions based on what fetch_ohttp_keys is supposed to return
    });
  });
}
