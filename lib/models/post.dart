class Post {
  Node node;

  Post({this.node});

  Post.fromJson(Map<String, dynamic> json) {
    node = json['node'] != null ? new Node.fromJson(json['node']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.node != null) {
      data['node'] = this.node.toJson();
    }
    return data;
  }
}

class Node {
  String id;
  String name;
  String description;
  String slug;
  List<Media> media;
  int votesCount;
  double offset = 0.0;
  double opacity = 0.0;
  double sizeOffset = 0.0;
  double rotation = 0.0;

  Node({this.id, this.name, this.description, this.slug, this.media});

  Node.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    slug = json['slug'];
    if (json['media'] != null) {
      media = [];
      json['media'].forEach((v) {
        media.add(
          new Media.fromJson(v),
        );
      });
    }
    votesCount = json['votesCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['slug'] = this.slug;
    if (this.media != null) {
      data['media'] = this.media.map((v) => v.toJson()).toList();
    }
    data['votesCount'] = this.votesCount;
    return data;
  }
}

class Media {
  String url;
  String videoUrl;

  Media({this.url, this.videoUrl});

  Media.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    videoUrl = json['videoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['videoUrl'] = this.videoUrl;
    return data;
  }
}
