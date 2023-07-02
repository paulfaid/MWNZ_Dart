import 'dart:convert';
import 'dart:io';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

const backendUrl = 'https://raw.githubusercontent.com/MiddlewareNewZealand/evaluation-instructions/main/xml-api';

void main() async {
  var app = Router(notFoundHandler: (_) => Response.notFound('Not Found'));

  app.get('/v1/companies/<id|[0-9]+>', _companiesHandler);

  final serverPort = int.parse(Platform.environment['PORT'] ?? '8080');
  final httpServer = await shelf_io.serve(app, 'localhost', serverPort);

  print('CompaniesApi serving at http://localhost:${httpServer.port}');
}

Future<Response> _companiesHandler(Request request, String requestId) async {
  final url = Uri.parse('$backendUrl/$requestId.xml');
  try {
    final backendResponse = await http.get(url);

    if (backendResponse.statusCode != 200) throw Exception('Backend responded with status code: ${backendResponse.statusCode}');

    final doc = XmlDocument.parse(backendResponse.body);

    return Response.ok(
        JsonEncoder.withIndent(' ').convert({
          'id': doc.xpath('/Data/id').first.innerText,
          'name': doc.xpath('/Data/name').first.innerText,
          'description': doc.xpath('/Data/description').first.innerText,
        }),
        headers: {'content-type': 'application/json'});
  } catch (ex) {
    print('Error handling request for requestId: $requestId, error: $ex');
    return Response.notFound('{"error":"not_found","error_description":"The requested resource was not found on the backend service"}',
        headers: {'content-type': 'application/json'});
  }
}
