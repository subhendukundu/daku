import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daku/models/user_model.dart';
import 'package:daku/saved_posts/web_view.dart';
import 'package:daku/widgets/flutter_toast.dart';
import 'package:daku/widgets/info_dialog.dart';
import 'package:daku/widgets/transition_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Node;
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import '../models/post.dart';

class DatabaseCtrl extends GetxController {
  RxList<Node> nodeList = RxList<Node>();
  Rx<UserModel> userDataModel = UserModel().obs;

  onInit() {
    super.onInit();
  }

  onReady() {
    super.onReady();
    if (ifUserLoggedIn()) {
      nodeList.bindStream(getData());
      userDataModel.bindStream(getUserData());
    }
  }

  bool ifUserLoggedIn() {
    if (FirebaseAuth.instance.currentUser != null)
      return true;
    else
      return false;
  }

  String userUid() {
    return FirebaseAuth.instance.currentUser.uid;
  }

  Future<void> authenticationWithGoogle() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );

    final GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth =
        await _signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: _googleAuth.accessToken, idToken: _googleAuth.idToken);

    final User user =
        await _auth.signInWithCredential(credential).then((value) {
      return value.user;
    });
    UserModel userData = UserModel(
        imageUrl: user.photoURL,
        name: user.displayName,
        rightSwiped: 0,
        leftSwipled: 0);

    await FirebaseFirestore.instance
        .collection('UserData')
        .doc(user.uid)
        .get()
        .then((value) {
      if (value.exists) {
        print('Already Signed In');
      } else {
        FirebaseFirestore.instance
            .collection('UserData')
            .doc(user.uid)
            .set(userData.toJson());
      }
    });
  }

  Future<void> signInWithGoogleForWeb() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('email');
    googleProvider.setCustomParameters({
      'login_hint': 'user@example.com',
    });

    // Once signed in, return the UserCredential
    final UserCredential credential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

    UserModel userData = UserModel(
        imageUrl: credential.user.photoURL,
        name: credential.user.displayName,
        rightSwiped: 0,
        leftSwipled: 0);

    await FirebaseFirestore.instance
        .collection('UserData')
        .doc(credential.user.uid)
        .get()
        .then((value) {
      if (value.exists) {
        print('Already Signed In');
      } else {
        FirebaseFirestore.instance
            .collection('UserData')
            .doc(credential.user.uid)
            .set(userData.toJson());
      }
    });
  }

  void insert(Node post, BuildContext context) async {
    if (ifUserLoggedIn()) {
      FirebaseFirestore.instance
          .collection('UserData')
          .doc(userUid())
          .collection('SavedPost')
          .doc(post.id)
          .set(post.toJson());
      rightSwipeIncreement();

      toast(msg: "Post is Added to Favourite");
    } else {
      // for Web
      if (kIsWeb) {
        final settings = await Hive.openBox('showinfoDialog');
        if (settings.get('infoDialog')) {
          showInfoDialog(context, post);
        } else {
          launchURL(post.slug);
        }
      }
      // for mobile
      else {
        if (GetStorage().read('InfoDialog')) {
          showInfoDialog(context, post);
        } else {
          Navigator.push(
            context,
            SizeTransition1(
              WebViewPage(
                title: post.name,
                url: post.slug,
              ),
            ),
          );
        }
      }
    }
  }

  Stream<List<Node>> getData() {
    return FirebaseFirestore.instance
        .collection('UserData')
        .doc(userUid())
        .collection('SavedPost')
        .snapshots()
        .map((QuerySnapshot query) {
      // ignore: deprecated_member_use
      List<Node> noteList = List();
      query.docs.forEach((element) {
        noteList.add(Node.fromJson(element.data()));
      });
      return noteList;
    });
  }

  Stream<UserModel> getUserData() {
    return FirebaseFirestore.instance
        .collection('UserData')
        .doc(userUid())
        .snapshots()
        .map((DocumentSnapshot query) {
      UserModel model;
      model = UserModel.fromJson(query.data());

      return model;
    });
  }

  void rightSwipeIncreement() async {
    int rightSwiped = userDataModel.value.rightSwiped;
    await FirebaseFirestore.instance
        .collection('UserData')
        .doc(userUid())
        .update({'RightSwiped': rightSwiped + 1});
  }

  void leftSwipeIncreement(info) async {
    if (ifUserLoggedIn()) {
      int leftSwiped = userDataModel.value.leftSwipled;
      await FirebaseFirestore.instance
          .collection('UserData')
          .doc(userUid())
          .update({'LeftSwiped': leftSwiped + 1});
    }
  }

  logOut() {
    FirebaseAuth.instance.signOut();
  }
}
