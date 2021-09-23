class CategoryModel {
  late String catId;
  late String vendorId;
  late String catName;
  late String imageUrl;

  CategoryModel(this.catId, this.vendorId, this.catName, this.imageUrl);

  CategoryModel.fromJson(Map<String, dynamic> json) {
    catId = json['category_id'];
    vendorId = json['vendor_id'];
    catName = json['category_name'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.catId;
    data['vendor_id'] = this.vendorId;
    data['category_name'] = this.catName;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}
