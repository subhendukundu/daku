import 'dart:convert';

import 'package:daku/configs/constants.dart';
import 'package:daku/models/post.dart';
import 'package:daku/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class GetSavedPosts extends StatefulWidget {
  const GetSavedPosts() : super();

  @override
  _GetSavedPostsState createState() => _GetSavedPostsState();
}

class _GetSavedPostsState extends State<GetSavedPosts> {
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
      // print(data);
      return data['access_token'];
    } else {
      throw Exception('Failed to load token');
    }
  }

  @override
  void initState() {
    super.initState();
    // ignore: deprecated_member_use
    List<dynamic> likedList = List<dynamic>();
    likedList = GetStorage().read('LikedList') as List;
    print(likedList);
    // getAuthToken().then((value) {
    //   print(value);
    // });
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
    return Scaffold();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body:
//       GraphQLProvider(
//         client: client,
//         child: CacheProvider(
//           child: Query(
//             options: QueryOptions(
//               document: gql(readPostById),
//               variables: <String, dynamic>{'id': '295397'},
//               //pollInterval: 10,
//             ),
//             builder: (QueryResult result, {refetch, FetchMore fetchMore}) {
//               if (result.hasException) {
//                 return Text(result.exception.toString());
//               }

//               if (result.isLoading && result.data == null) {
//                 return Center(
//                   child: Loader(),
//                 );
//               }

//               if (result.data == null && !result.hasException) {
//                 return const Text('No data found');
//               }

//               final edges = (result.data['post']);
//               final Map pageInfo = result.data['posts']['pageInfo'];
//               final String fetchMoreCursor = pageInfo['endCursor'];
//               final opts = FetchMoreOptions(
//                 variables: {'after': fetchMoreCursor},
//                 updateQuery: (previousResultData, fetchMoreResultData) {
//                   final posts = [
//                     ...fetchMoreResultData['posts']['edges'] as List<dynamic>
//                   ];

//                   fetchMoreResultData['posts']['edges'] = posts;
//                   return fetchMoreResultData;
//                 },
//               );

//               onFetchMore() {
//                 fetchMore(opts);
//               }

//               final List<Post> posts = edges.map((edge) {
//                 // print(edge);
//                 final post = Post.fromJson(edge);
//                 return post;
//               }).toList();

//               return Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Cards(
//                     //   posts: nodeList.value,
//                     //   onProgress: (progress, direction) {
//                     //     final titleHeight = (60 + 48);

//                     //     var newOffset = progress * titleHeight / 100;
//                     //     if (direction == Direction.AWAY) {
//                     //       newOffset += (position * titleHeight);
//                     //     }

//                     //     if (direction == Direction.BACK) {
//                     //       newOffset = ((position) * titleHeight) - newOffset;
//                     //     }

//                     //     if (progress == 100 && direction == Direction.NONE) {
//                     //       if (this.direction == Direction.AWAY) {
//                     //         position += 1;
//                     //       } else {
//                     //         position -= 1;
//                     //       }
//                     //     }
//                     //     this.direction = direction;
//                     //   },
//                     // ),
//                   ]);
//               // return MyHomePage(
//               //   key: UniqueKey(),
//               //   posts: posts,
//               //   onFetchMore: onFetchMore,
//               // );
//             },
//           ),
//         ),
//       ),
//     );
  }
}
