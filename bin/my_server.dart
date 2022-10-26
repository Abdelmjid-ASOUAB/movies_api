import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:process_run/shell.dart';

Future<void> main() async {
  final server = await createServer();
  print('Server started: ${server.address} port ${server.port}');

  await handleRequests(server);
}

Future<void> handleRequests(HttpServer server) async {
  await for (HttpRequest request in server) {
    if (request.uri.path.contains("search")) {
      print(request.uri);
      print(request.headers);

      request.response.write(await searchByName("superman of"));
    } else if (request.uri.path.contains("load")) {
      String link = request.headers["movie_link"]!.first;

      request.response
          .write(await runScript(link: "https://w.egybest.org$link"));
    }

    await request.response.close();
  }
}

Future<HttpServer> createServer() async {
  final address = InternetAddress.loopbackIPv4;
  const port = 4040;
  return await HttpServer.bind(address, port);
}

Future<String> runScript({required link}) async {
  var shell = Shell();
  var result = await shell.run("python3 script.py $link");

  print("=>${result.outLines.last}");
  var name = jsonDecode(result.outLines.last);
  var file = File("./${name["file"]}");
  var fileContent = await file.readAsString();

  return jsonEncode({"link": fileContent});
}

Future<String> searchByName(String search) async {
//Getting the response from the targeted url
  final response = await http.Client()
      .get(Uri.parse('https://egybest.org/explore/?q=$search'));
  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    try {
      var responseMovieList = document.getElementsByClassName('movie');
      List<Map<String, String>> resultList = [];

      for (var item in responseMovieList) {
        var map = <String, String>{};

        map["name"] = item.getElementsByClassName("title").first.text;
        map["url"] = item.attributes["href"].toString();
        map["image"] =
            item.getElementsByTagName("img").first.attributes["src"].toString();

        resultList.add(map);
      }

      return jsonEncode(resultList);
    } catch (e) {
      return 'ERROR!';
    }
  } else {
    return 'ERROR: ${response.statusCode}';
  }
}
