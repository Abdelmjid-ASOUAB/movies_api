class Movie {
  String id = "";
  String title = "";
  bool adult = false;
  String posterPath = "";
  String overview = "";
  String releaseDate = "";
  List<String> genreIds = [];
  String originalTitle = "";
  String originalLanguage = "en";
  String backdropPath = "";
  double popularity = 0;
  int voteCount = 0;
  bool video = true;
  double voteAverage = 0;
  String quality = "";

  Movie(
      {this.id = "",
      this.title = "",
      this.adult = false,
      this.posterPath = "",
      this.overview = "",
      this.releaseDate = "",
      this.genreIds = const [],
      this.originalTitle = "",
      this.originalLanguage = "en",
      this.backdropPath = "",
      this.popularity = 0,
      this.voteCount = 0,
      this.quality = "",
      this.video = true,
      this.voteAverage = 0});

  Map<String, dynamic> toMap() {
    return {
      "poster_path": posterPath,
      "adult": adult,
      "overview": "",
      "id": "${backdropPath.split("/")[1]}/${backdropPath.split("/")[2]}",
      "release_date": releaseDate,
      "genre_ids": genreIds,
      "original_title": originalTitle,
      "original_language": originalLanguage,
      "title": title,
      "backdrop_path": backdropPath,
      "popularity": popularity,
      "vote_count": voteCount,
      "video": video,
      "quality": quality,
      "vote_average": voteAverage,
    };
  }
}
