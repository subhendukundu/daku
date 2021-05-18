class UserModel {
  String name;
  String imageUrl;
  int rightSwiped;
  int leftSwipled;
  UserModel({this.imageUrl, this.leftSwipled, this.name, this.rightSwiped});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['Name'],
      imageUrl: json['ImageUrl'],
      leftSwipled: json['LeftSwiped'],
      rightSwiped: json['RightSwiped'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['ImageUrl'] = this.imageUrl;
    data['LeftSwiped'] = this.leftSwipled;
    data['RightSwiped'] = this.rightSwiped;
    return data;
  }
}
