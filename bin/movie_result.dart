import 'movie.dart';

class MovieResponse {
  final int page;
  List<Movie> results;
  final int totalPage;
  final int totalResults;

  MovieResponse({
    this.results = const [],
    this.totalPage = 1,
    this.totalResults = 10,
    this.page = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      "page": page,
      "total_page": totalPage,
      "total_results": totalResults,
      "results": results.map((e) => e.toMap()).toList(),
    };
  }
}
