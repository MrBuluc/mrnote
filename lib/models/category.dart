class Category {
  int? categoryID;
  late String categoryTitle;
  late int categoryColor;

  Category(this.categoryTitle,
      this.categoryColor); // Use when add category, because db creates id.

  Category.withID(this.categoryID, this.categoryTitle,
      this.categoryColor); // when read db, use it.

  Category.fromMap(Map<String, dynamic> map) {
    categoryTitle = map['categoryTitle'];
    categoryID = map['categoryID'];
    categoryColor =
        map["categoryColor"] != null ? map["categoryColor"] : 4293914607;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['categoryID'] = categoryID;
    map['categoryTitle'] = categoryTitle;
    map['categoryColor'] = categoryColor;

    return map;
  }
}
