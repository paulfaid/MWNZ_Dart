import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  final portPattern = RegExp(r'CompaniesApi serving at http://[^:]+:(\d+)');

  Future<void> executeAgainstServer(Future<void> Function(String host) func) async {
    // sart the server
    final proc = await TestProcess.start(
      'dart',
      ['bin/companies_api.dart'],
      environment: {'PORT': '0'},
    );

    final output = await proc.stdout.next;
    final match = portPattern.firstMatch(output)!;
    final port = int.parse(match[1]!);

    try {
      // execute the actual test func
      await func('http://localhost:$port');
    } finally {
      // stop the server
      await proc.kill();
    }
  }

  test('should return valid company data for id:1', () async {
    await executeAgainstServer((host) async {
      final response = await get(Uri.parse('$host/v1/companies/1'));
      expect(response.statusCode, 200);
      expect(response.headers, containsPair('content-type', 'application/json'));
      expect(response.body, contains('id'));
      expect(response.body, contains('name'));
      expect(response.body, contains('description'));
    });
  });

  test('should return error for id:0', () async {
    await executeAgainstServer((host) async {
      final response = await get(Uri.parse('$host/v1/companies/0'));
      expect(response.statusCode, 404);
      expect(response.body, contains('Not Found'));
    });
  });
}
