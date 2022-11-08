class TableItemDetail {
  String title;
  String value;

  TableItemDetail({this.title = "--", this.value = "--"});

  Map<String, dynamic> toMap() {
    return {"title": title, "value": value};
  }
}

Map<String, dynamic> listItemsToMap(List<TableItemDetail> items) {
  return {"detail_items": items.map((element) => element.toMap()).toList()};
}
