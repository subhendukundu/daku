import 'package:daku/controller/database_ctrl.dart';
import 'package:daku/models/post.dart';
import 'package:daku/saved_posts/web_view.dart';
import 'package:daku/widgets/transition_animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart' hide Node;
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:sign_button/create_button.dart';
import 'package:sign_button/sign_button.dart';
import 'package:url_launcher/url_launcher.dart';

showInfoDialog(BuildContext context, Node post) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          title: Text("Join or Login"),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.height * 0.05,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/logo.png'))),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  Icon(
                    Icons.add,
                    color: Theme.of(context).highlightColor,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.height * 0.05,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/product-hunt-logo-orange-240.png'),
                      ),
                    ),
                  ),
                ]),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Join now to save your favourite products or continue without signIn',
                    style: TextStyle(
                        color: Theme.of(context).highlightColor,
                        fontSize: MediaQuery.of(context).size.height * 0.02),
                  ),
                ),
                SignInButton(
                  imagePosition: ImagePosition.left, // left or right
                  buttonType: ButtonType.google,
                  btnColor: Theme.of(context).secondaryHeaderColor,
                  buttonSize: ButtonSize.small,
                  onPressed: () {
                    kIsWeb
                        ? DatabaseCtrl().signInWithGoogleForWeb().then(
                            (value) {
                              Get.reset();
                              Phoenix.rebirth(context);
                            },
                          )
                        : DatabaseCtrl().authenticationWithGoogle().then(
                            (value) {
                              Get.reset();
                              Phoenix.rebirth(context);
                            },
                          );
                  },
                ),
                MaterialButton(
                  color: Color.fromRGBO(204, 77, 41, 1),
                  shape: StadiumBorder(),
                  onPressed: () async {
                    if (kIsWeb) {
                      final settings = await Hive.openBox('showinfoDialog');
                      settings.put('infoDialog', false);
                      launchURL(post.slug);
                      Navigator.pop(context);
                    } else {
                      GetStorage().write('InfoDialog', false);
                      Navigator.pop(context);
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
                  },
                  elevation: 5.0,
                  child: Container(
                    width: 200,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/product-hunt-logo-orange-240.png'),
                            ),
                          ),
                        ),
                        Text(
                          'Open on ProductHunt',
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).highlightColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}

void launchURL(slug) async {
  final url = 'https://www.producthunt.com/posts/$slug';
  await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}
