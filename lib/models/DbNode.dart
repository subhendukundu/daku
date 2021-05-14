class DbNode {
  int id;
  String name;
  String description;
  String slug;
  String media;
  String displayImage;
  double offset = 0.0;
  double opacity = 0.0;
  double sizeOffset = 0.0;
  double rotation = 0.0;

  DbNode({this.id, this.name, this.description, this.slug, this.media});

  Map<String, dynamic> toJson(mediaId) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['slug'] = this.slug;
    data['media'] = this.media;
    return data;
  }

  DbNode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    slug = json['slug'];
    media = json['media'];
    displayImage = json['displayImage'];
  }
}
