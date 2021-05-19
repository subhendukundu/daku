import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daku/models/user_model.dart';
import 'package:daku/widgets/flutter_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart' hide Node;
import 'package:google_sign_in/google_sign_in.dart';
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

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

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

  void insert(Node info) async {
    if (ifUserLoggedIn()) {
      FirebaseFirestore.instance
          .collection('UserData')
          .doc(userUid())
          .collection('SavedPost')
          .doc(info.id)
          .set(info.toJson());
      rightSwipeIncreement();

      toast(msg: "Post is Added to Favourite");
    } else {
      toast(msg: "Please Login");
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
    int leftSwiped = userDataModel.value.leftSwipled;
    await FirebaseFirestore.instance
        .collection('UserData')
        .doc(userUid())
        .update({'LeftSwiped': leftSwiped + 1});
  }

  logOut() {
    FirebaseAuth.instance.signOut();
  }
}
