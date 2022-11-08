import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:process_run/shell.dart';

import 'detailtableItem.dart';
import 'error_message.dart';
import 'movie.dart';
import 'movie_result.dart';

Future<void> main() async {
  final server = await createServer();
  print('Server started: ${server.address} port ${server.port}');

  await handleRequests(server);
}

Future<void> handleRequests(HttpServer server) async {
  await for (HttpRequest request in server) {
    if (request.uri.path.contains("search")) {
      var q = request.uri.queryParameters.containsKey("q")
          ? request.uri.queryParameters["q"].toString()
          : "";

      request.response.write(await searchByName(q));
    } else if (request.uri.path.contains("load")) {
      if (!request.uri.queryParameters.containsKey("link")) {
        request.response.write({"success": false});
      } else {
        String link = request.uri.queryParameters["link"].toString();

        request.response
            .write(await runScript(link: "https://w.egybest.org$link"));
      }
    } else if (request.uri.path.contains("trending")) {
      request.response.write(await newMovies());
    } else if (request.uri.path.contains("detail")) {
      print("detailss");
      var id = request.uri.queryParameters.containsKey("id")
          ? request.uri.queryParameters["id"].toString()
          : "";
      print(id);

      request.response.write(await getDetailMovie(id: id));
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
  try {
    var shell = Shell();
    var result = await shell.run("python3 script.py $link");

    print("=>${result.outLines.last}");
    var name = jsonDecode(result.outLines.last);
    var file = File("./${name["file"]}");
    var fileContent = await file.readAsString();

    return jsonEncode({"link": fileContent});
  } catch (e) {
    return jsonEncode({"error": e.toString()});
  }
}

Future<String> searchByName(String search) async {
//Getting the response from the targeted url
  final response = await http.Client()
      .get(Uri.parse('https://w.egybest.org/explore/?q=$search'));
  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    try {
      var responseMovieList = document.getElementsByClassName('movie');
      List<Map<String, dynamic>> resultList = [];
      List<Movie> resultMovies = [];
      MovieResponse movieResponse = MovieResponse();

      for (var item in responseMovieList) {
        var map = <String, String>{};
        Movie movie = Movie();

        movie.title = item.getElementsByClassName("title").first.text;
        movie.backdropPath = item.attributes["href"].toString();
        movie.posterPath =
            item.getElementsByTagName("img").first.attributes["src"].toString();
        try {
          movie.quality = item.getElementsByClassName("ribbon").first.text;
          movie.voteCount =
              int.parse(item.getElementsByClassName("rating").first.text);
          movie.voteAverage =
              double.parse(item.getElementsByClassName("rating").first.text);
        } catch (e) {
          movie.voteCount = -1;
        }

        resultList.add(movie.toMap());
        resultMovies.add(movie);
      }
      movieResponse.results = resultMovies;
      return jsonEncode(movieResponse.toMap());
    } catch (e) {
      return ErrorMessage(message: e.toString()).toMap().toString();
    }
  } else {
    return 'ERROR: ${response.statusCode}';
  }
}

Future<String> newMovies() async {
//Getting the response from the targeted url
  final response =
      await http.Client().get(Uri.parse('https://w.egybest.org/movies/'));
  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    try {
      var responseMovieList = document.getElementsByClassName('movie');
      List<Map<String, dynamic>> resultList = [];
      List<Movie> resultMovies = [];
      MovieResponse movieResponse = MovieResponse();

      for (var item in responseMovieList) {
        var map = <String, String>{};
        Movie movie = Movie();
        try {
          movie.title = item.getElementsByClassName("title").first.text;
          movie.id = item.attributes["href"].toString();
          movie.backdropPath = item.attributes["href"].toString();

          movie.posterPath = item
              .getElementsByTagName("img")
              .first
              .attributes["src"]
              .toString();
          movie.quality = item.getElementsByClassName("ribbon").first.text;
          movie.voteCount =
              int.parse(item.getElementsByClassName("rating").first.text);
          movie.voteAverage =
              double.parse(item.getElementsByClassName("rating").first.text);
        } catch (e) {
          movie.voteCount = -1;
        }

        resultList.add(movie.toMap());
        resultMovies.add(movie);
      }
      movieResponse.results = resultMovies;
      return jsonEncode(movieResponse.toMap());
    } catch (e) {
      return ErrorMessage(message: e.toString()).toMap().toString();
    }
  } else {
    return 'ERROR: ${response.statusCode}';
  }
}

Future<String> getDetailMovie({required String id}) async {
  final response =
      await http.Client().get(Uri.parse('https://w.egybest.org/$id'));
  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    var movieTable = document.getElementsByClassName('movieTable');
    String imageURL = await getImageHD(id: id);
    List<TableItemDetail> tableDetailList = [];

    for (var item in movieTable) {
      var tableTR = item.getElementsByTagName("tr");

      for (var tabItem in tableTR) {
        var tableTD = tabItem.getElementsByTagName("td");
        tableDetailList.add(TableItemDetail(
            title: tableTD.first.text,
            value: (tableTD.length > 1) ? tableTD[1].text : "--"));
      }
    }

    try {
      Map<String, dynamic> detail = listItemsToMap(tableDetailList);
      detail.addAll({"image": imageURL});
      return jsonEncode(detail);
    } catch (e) {
      return ErrorMessage(message: e.toString()).toMap().toString();
    }
  } else {
    return 'ERROR: ${response.statusCode}';
  }
}

Future<String> getImageHD({required id}) async {
  final response =
      await http.Client().get(Uri.parse('https://w.egybest.org/$id'));

  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    var imageDiv;

    try {
      imageDiv = document
          .getElementsByClassName('movie_cover')
          .first
          .getElementsByTagName("img")
          .first
          .attributes["src"];
    } catch (E) {}

    // print(imageDiv.first.getElementsByTagName("img").first.attributes["src"]);
    try {
      return imageDiv.toString();
    } catch (e) {
      return ErrorMessage(message: e.toString()).toMap().toString();
    }
  } else {
    return 'ERROR: ${response.statusCode}';
  }
}
