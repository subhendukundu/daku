import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' hide Node;
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';
import 'package:daku/models/DbNode.dart';
import '../models/post.dart';

final String tableLiked = 'liked';

class SqlCtrl extends GetxController {
  Database _database;
  static SqlCtrl _helper;
  RxList<DbNode> nodeList = RxList<DbNode>();
  Rx<int> leftSwiped = RxInt(0);
  Rx<int> rightSwiped = RxInt(0);
  bool userLoggedIn = false;

  onInit() {
    super.onInit();
    initializeDatabase();
  }

  onReady() {
    super.onReady();
    getData();
  }

  SqlCtrl._createInstance();
  factory SqlCtrl() {
    if (_helper == null) {
      _helper = SqlCtrl._createInstance();
    }
    return _helper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    var database;
    try {
      String _path = await getDatabasesPath() + 'like.db';
      database = await openDatabase(
        _path,
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE $tableLiked(id INTEGER,displayImage text not null,name text not null,description text not null,slug text not null,media STRING)",
          );
        },
      );
    } catch (e) {
      print(e);
    }
    return database;
  }

  void leftSwipeIncreement(info) async {
    int value = GetStorage().read('LeftSwiped');
    int saveValue = value + 1;
    leftSwiped.value = saveValue;

    GetStorage().write('LeftSwiped', saveValue);
  }

  void insert(Node info) async {
    // ignore: deprecated_member_use
    List<dynamic> likedList = List<dynamic>();
    likedList = GetStorage().read('LikedList') as List;
    if (likedList != null) {
      bool result = likedList.contains(info.id);
      if (!result) {
        //* Adding Data To List And List to GetStorage
        likedList.add(info.id);
        GetStorage().write('LikedList', likedList);
        Fluttertoast.showToast(
            msg: "Post is Added to Favourite",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);

        // *Sasving Data for Analytics

        int value = GetStorage().read('RightSwiped');
        int saveValue = value + 1;
        rightSwiped.value = saveValue;
        GetStorage().write('RightSwiped', saveValue);
      } else {
        Fluttertoast.showToast(
            msg: "This Post is already saved",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      likedList.add(info.id);
      GetStorage().write('LikedList', likedList);
    }
  }

  setUserLogginFalse() {
    userLoggedIn = false;
  }

  getData() async {
    var db = await this.database;
    var result = await db.query(tableLiked);
    // ignore: deprecated_member_use
    List<DbNode> list = List<DbNode>();
    result.forEach((element) {
      list.add(DbNode.fromJson(element));
    });
    nodeList.value = list;
    leftSwiped.value = GetStorage().read('LeftSwiped');
    rightSwiped.value = GetStorage().read('RightSwiped');
  }

  deleteTable() async {
    var db = await this.database;
    db.delete(tableLiked).then((value) {
      print(value);
    });
  }
}
