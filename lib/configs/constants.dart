String tokenUrl = "https://api.producthunt.com/v2/oauth/token";
String apiUrl = "https://graphql.daku.app";
final Map discovery = {
  "client_id": "q4fdxQwVb68M8prZB_ka4PkSlz52rVx8SojS_aLp_tc",
  "client_secret": "YOO2RBBJ5wNsB-kvcVpdiixnDeI0hEbl52Uo1UCO7Tk",
  "grant_type": "client_credentials",
};

const String readPosts = r'''
  query posts($after: String) {
    posts(after: $after) {
      pageInfo {
        endCursor
      }
      edges{
        node {
          id
          name
          description
          slug
          media {
            videoUrl
            url
          }
        }
      }
    }
  }
''';
