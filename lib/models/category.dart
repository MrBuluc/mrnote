class Category {
  int categoryID;
  String categoryTitle;
  int categoryColor;

  Category(this.categoryTitle,
      this.categoryColor); // Use when add category, because db creates id.

  Category.withID(this.categoryID, this.categoryTitle,
      this.categoryColor); // when read db, use it.

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['categoryID'] = categoryID;
    map['categoryTitle'] = categoryTitle;
    map['categoryColor'] = categoryColor;

    return map;
  }

  Category.fromMap(Map<String, dynamic> map) {
    this.categoryTitle = map['categoryTitle'];
    this.categoryID = map['categoryID'];
    this.categoryColor =
        map["categoryColor"] != null ? map["categoryColor"] : 4293914607;
  }

  @override
  String toString() {
    return 'Category{categoryID: $categoryID, categoryTitle: $categoryTitle}';
  }
}
