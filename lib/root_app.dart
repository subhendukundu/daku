import 'dart:convert';
import 'package:daku/controller/database_ctrl.dart';
import 'package:daku/saved_posts/saved_posts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:sign_button/create_button.dart';
import 'package:sign_button/sign_button.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:url_launcher/url_launcher.dart';
import 'configs/constants.dart';
import 'models/post.dart';
import 'package:http/http.dart' as http;
import 'providers/theme_provider.dart';
import 'widgets/loader.dart';
import 'widgets/profile_card.dart';
import 'widgets/circular_percent.dart';

class RootPage extends StatelessWidget {
  final ThemeProvider themeProvider;
  const RootPage({
    Key key,
    @required this.themeProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daku, A Tinder for Products',
      theme: themeProvider.themeData(),
      initialRoute: '/',
      routes: {
        '/': (context) => Splash(),
      },
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Get.put(DatabaseCtrl());
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen.callback(
      name: 'assets/riv/logo.riv',
      until: () => Future.delayed(
        Duration(
          seconds: 3,
        ),
      ),
      onError: (_, err) {},
      onSuccess: (err) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GraphQLWidgetScreen(),
          ),
        );
      },
      startAnimation: 'start',
    );
  }
}

class GraphQLWidgetScreen extends StatefulWidget {
  const GraphQLWidgetScreen() : super();

  @override
  _GraphQLWidgetScreenState createState() => _GraphQLWidgetScreenState();
}

class _GraphQLWidgetScreenState extends State<GraphQLWidgetScreen> {
  Future<String> getAuthToken() async {
    final response = await http.post(
      Uri.https('api.producthunt.com', 'v2/oauth/token'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        ...discovery,
      }),
    );
    if (response.statusCode <= 400) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Failed to load token');
    }
  }

  @override
  Widget build(BuildContext context) {
    final httpLink = HttpLink(
      apiUrl,
    );

    final authLink = AuthLink(
      getToken: () async {
        final token = await getAuthToken();
        return token == null ? null : 'Bearer $token';
      },
    );

    var link = authLink.concat(httpLink);

    final client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        cache: GraphQLCache(),
        link: httpLink,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: GraphQLProvider(
        client: client,
        child: CacheProvider(
          child: Query(
            options: QueryOptions(
              document: gql(readPosts),
              variables: <String, dynamic>{'after': ''},
              //pollInterval: 10,
            ),
            builder: (QueryResult result, {refetch, FetchMore fetchMore}) {
              if (result.hasException) {
                return Text(
                  result.exception.toString(),
                );
              }

              if (result.isLoading && result.data == null) {
                return Center(
                  child: Loader(),
                );
              }

              if (result.data == null && !result.hasException) {
                return const Text('No data found');
              }
              final edges = (result.data['posts']['edges'] as List<dynamic>);
              final Map pageInfo = result.data['posts']['pageInfo'];
              final String fetchMoreCursor = pageInfo['endCursor'];
              final opts = FetchMoreOptions(
                variables: {'after': fetchMoreCursor},
                updateQuery: (previousResultData, fetchMoreResultData) {
                  final posts = [
                    ...fetchMoreResultData['posts']['edges'] as List<dynamic>
                  ];

                  fetchMoreResultData['posts']['edges'] = posts;
                  return fetchMoreResultData;
                },
              );

              onFetchMore() {
                fetchMore(opts);
              }

              final List<Post> posts = edges.map((edge) {
                // print(edge);
                final post = Post.fromJson(edge);
                return post;
              }).toList();

              return MyHomePage(
                key: UniqueKey(),
                posts: posts,
                onFetchMore: onFetchMore,
              );
            },
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    this.title,
    this.posts,
    this.onFetchMore,
  }) : super(key: key);

  final String title;
  final List<Post> posts;
  final Function onFetchMore;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Post> posts;
  Function onFetchMore;
  SwipeableStackController _controller;
  DatabaseCtrl sql = DatabaseCtrl();
  int position = 0;

  @override
  void initState() {
    super.initState();
    if (GetStorage().read('RightSwiped') == null) {
      GetStorage().write('RightSwiped', 0);
      GetStorage().write('LeftSwiped', 0);
      GetStorage().write('LikedList', []);
    }

    posts = widget.posts;
    onFetchMore = widget.onFetchMore;
    _controller = SwipeableStackController()..addListener(callFetchMore);
  }

  callFetchMore() {
    if (posts.length - 1 <= _controller.currentIndex) {
      onFetchMore();
    }
  }

  void launchURL(slug) async {
    final url = 'https://www.producthunt.com/posts/$slug';
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  void launchPlayStoreURL() async {
    final url =
        'https://play.google.com/store/apps/details?id=io.higgle.dakuapp';
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  void launchGithubURL() async {
    final url = 'https://github.com/subhendukundu/daku';
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  Widget _buildAppBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    double width = MediaQuery.of(context).size?.width;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      title: DatabaseCtrl().ifUserLoggedIn()
          ? GetX<DatabaseCtrl>(
              init: DatabaseCtrl(),
              builder: (controller) {
                return Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            controller.userDataModel.value.imageUrl),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Text(
                          controller.userDataModel.value.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.017),
                        ),
                      ),
                      // subtitle: Text(user.email),
                    ],
                  ),
                );
              },
            )
          : SizedBox(),
      leading: Padding(
        padding: const EdgeInsets.only(
          left: 20,
        ),
        child: Image.asset(
          "assets/images/logo.png",
          width: 40,
        ),
      ),
      actions: [
        if (kIsWeb)
          InkWell(
            onTap: () async {
              launchPlayStoreURL();
            },
            child: Image.asset(
              "assets/images/google-play-badge.png",
              width: width > 500 ? 150 : 100,
              height: 30,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(
            right: 10.0,
          ),
          child: InkWell(
            onTap: () async {
              await themeProvider.toggleThemeData();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: themeProvider.isLightTheme
                  ? Image.asset(
                      "assets/images/moon.png",
                      width: 20,
                    )
                  : Image.asset(
                      "assets/images/sun.png",
                      width: 20,
                    ),
            ),
          ),
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Icon(AntDesign.github),
          ),
          onTap: () async {
            launchGithubURL();
          },
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Icon(
              Icons.favorite,
              color: Theme.of(context).highlightColor,
            ),
          ),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SavedPosts();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    print(
      DatabaseCtrl().ifUserLoggedIn(),
    );
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          // onTap: () =>
          //     Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return SavedPosts();
          // })),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new RoundIconButton.large(
                      icon: Icons.clear,
                      iconColor: Colors.red,
                      onPressed: () {
                        _controller.next(
                          swipeDirection: SwipeDirection.left,
                        );
                      },
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    DatabaseCtrl().ifUserLoggedIn()
                        ? new RoundIconButton.large(
                            icon: Icons.analytics_outlined,
                            iconColor: Theme.of(context).highlightColor,
                            onPressed: analyicsDialog,
                          )
                        : new RoundIconButton.large(
                            icon: Icons.analytics_outlined,
                            iconColor: Theme.of(context).highlightColor,
                            onPressed: loginDialog,
                          ),
                    SizedBox(
                      width: 50,
                    ),
                    new RoundIconButton.large(
                      icon: Icons.favorite,
                      iconColor: Colors.green,
                      onPressed: () {
                        _controller.next(
                          swipeDirection: SwipeDirection.right,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: GetX<DatabaseCtrl>(
          init: DatabaseCtrl(),
          builder: (controller) {
            print(controller.nodeList.length);
            return SwipeableStack(
              controller: _controller,
              onSwipeCompleted: (index, direction) {
                if (direction == SwipeDirection.right) {
                  controller.insert(posts[index].node);
                } else {
                  controller.leftSwipeIncreement(posts[index].node);
                }
              },
              onWillMoveNext: (index, direction) {
                final allowedActions = [
                  SwipeDirection.right,
                  SwipeDirection.left,
                ];
                return allowedActions.contains(direction);
              },
              builder: (context, index, constraints) {
                final Post post = posts[index];
                position = index;
                return Center(
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 300,
                      maxWidth: 500,
                      maxHeight: 680,
                    ),
                    padding: EdgeInsets.all(
                      15,
                    ),
                    color: Colors.transparent,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(
                          color: Color.fromRGBO(168, 179, 207, 0.2),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      elevation: 5,
                      child: ProfileCard(
                        post: post,
                        forSavedCard: false,
                      ),
                    ),
                  ),
                );
              },
              itemCount: posts.length,
            );
          }),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  analyicsDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            title: Text('Analyics'),
            content: buildCircularPercent(context),
            actions: [
              TextButton(
                  child: Text(
                    'LogOut',
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    DatabaseCtrl()..logOut();
                    Get.reset();
                    Phoenix.rebirth(context);
                  }),
            ],
          );
        });
  }

  loginDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                                'assets/images/product-hunt-logo-orange-240.png'))),
                  ),
                ]),
                Text(
                  '1000+ users have joined so far',
                  style: TextStyle(
                      color: Theme.of(context).highlightColor,
                      fontSize: MediaQuery.of(context).size.height * 0.02),
                ),
                SignInButton(
                    imagePosition: ImagePosition.left, // left or right
                    buttonType: ButtonType.google,
                    btnColor: Theme.of(context).secondaryHeaderColor,
                    buttonSize: ButtonSize.small,
                    onPressed: () {
                      kIsWeb
                          ? DatabaseCtrl()
                              .signInWithGoogleForWeb()
                              .then((value) {
                              Get.reset();

                              Phoenix.rebirth(context);
                              analyicsDialog();
                            })
                          : DatabaseCtrl()
                              .authenticationWithGoogle()
                              .then((value) {
                              Get.reset();
                              Phoenix.rebirth(context);
                              analyicsDialog();
                            });
                    }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(callFetchMore);
    _controller.dispose();
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final VoidCallback onPressed;

  RoundIconButton.large({
    this.icon,
    this.iconColor,
    this.onPressed,
  }) : size = 60.0;

  RoundIconButton.small({
    this.icon,
    this.iconColor,
    this.onPressed,
  }) : size = 50.0;

  RoundIconButton({
    this.icon,
    this.iconColor,
    this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(
        bottom: 15,
      ),
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: themeProvider.themeData().cardColor,
        boxShadow: [
          new BoxShadow(
            color: const Color(0x11000000),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: new RawMaterialButton(
        shape: new CircleBorder(),
        elevation: 0.0,
        child: new FaIcon(
          icon,
          color: iconColor,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
