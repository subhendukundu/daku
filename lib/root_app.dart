import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:url_launcher/url_launcher.dart';
import 'configs/constants.dart';
import 'models/post.dart';
import 'package:http/http.dart' as http;

import 'providers/theme_provider.dart';
import 'widgets/loader.dart';
import 'widgets/profile_card.dart';

class RootPage extends StatefulWidget with WidgetsBindingObserver {
  final ThemeProvider themeProvider;

  const RootPage({Key key, @required this.themeProvider}) : super(key: key);
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daku, A Tinder for Products',
      theme: widget.themeProvider.themeData(),
      home: GraphQLWidgetScreen(),
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
                return Text(result.exception.toString());
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
                final post = Post.fromJson(edge);
                return post;
              }).toList();

              print('posts, ${posts.length}');

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

  @override
  void initState() {
    super.initState();
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

  Widget _buildAppBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    print(themeProvider.isLightTheme);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
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
        InkWell(
          onTap: () async {
            await themeProvider.toggleThemeData();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
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
      ],
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Row(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SwipeableStack(
        controller: _controller,
        onSwipeCompleted: (index, direction) {
          if (direction == SwipeDirection.right) {
            final Post post = posts[index];
            launchURL(post.node.slug);
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
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                elevation: 5,
                child: ProfileCard(
                  post: post,
                ),
              ),
            ),
          );
        },
        itemCount: posts.length,
      ),
      bottomNavigationBar: _buildBottomBar(),
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
        child: new Icon(
          icon,
          color: iconColor,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
