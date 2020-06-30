class Category{

  int categoryID;
  String categoryTitle;

  Category(this.categoryTitle);// Use when add category, because db creates id.

  Category.withID(this.categoryID, this.categoryTitle); // when read db, use it.

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();

    map['categoryID'] = categoryID;
    map['categoryTitle'] = categoryTitle;

    return map;
  }

  Category.fromMap(Map<String, dynamic> map){

    this.categoryTitle = map['categoryTitle'];
    this.categoryID = map['categoryID'];
  }

  @override
  String toString() {
    return 'Category{categoryID: $categoryID, categoryTitle: $categoryTitle}';
  }
}