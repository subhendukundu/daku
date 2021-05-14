// This example demonstrates the ability to login using an OAuth 2.0 provider,
/// on Android and iOS.
///
/// This example depends on the `url_launcher` and `app_links` packages
/// (https://pub.dev/packages/flutter_appauth), and requires that you set up a
/// GitHub OAuth application using the instructions at
/// https://docs.nhost.io/auth/oauth-providers/github
///
/// Then, in your Nhost project's "Sign-In" settings, set:
///
/// Success redirect URL: `daku://oauth.login.success`.
/// Failure redirect URL: `daku://oauth.login.failure`.
library oauth_providers_example;

import 'package:flutter/material.dart';
import 'package:nhost_flutter_auth/nhost_flutter_auth.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:app_links/app_links.dart';

import 'package:nhost_sdk/nhost_sdk.dart';

/// Fill in this value with the backend URL found on your Nhost project page.
const nhostApiUrl = 'https://backend-44c8ca65.nhost.app';
const nhostGithubLoginUrl = '$nhostApiUrl/auth/providers/google/';

const loginSuccessHost = 'oauth.login.success';
const loginFailureHost = 'oauth.login.failure';

class OAuthExample extends StatefulWidget {
  @override
  _OAuthExampleState createState() => _OAuthExampleState();
}

class _OAuthExampleState extends State<OAuthExample> {
  NhostClient nhostClient;
  AppLinks appLinks;

  @override
  void initState() {
    super.initState();

    // Create a new Nhost client using your project's backend URL.
    nhostClient = NhostClient(baseUrl: nhostApiUrl);

    appLinks = AppLinks(
      onAppLink: (uri, stringUri) async {
        print(uri);
        print(loginSuccessHost);
        if (uri.host == loginSuccessHost) {
          // ignore: unawaited_futures
          nhostClient.auth.completeOAuthProviderLogin(uri);
        }
        await url_launcher.closeWebView();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    nhostClient.close();
  }

  @override
  Widget build(BuildContext context) {
    print(nhostGithubLoginUrl);
    return NhostAuthProvider(
      auth: nhostClient.auth,
      child: MaterialApp(
        title: 'Nhost.io OAuth Example',
        home: Scaffold(
          body: SafeArea(
            child: ExampleProtectedScreen(),
          ),
          // ExampleProtectedScreen(),
        ),
      ),
    );
  }
}

class ExampleProtectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // NhostAuthProvider.of will register this widget so that it rebuilds
    // whenever the user's authentication state changes.
    final auth = NhostAuthProvider.of(context);
    Widget widget;

    switch (auth.authenticationState) {
      case AuthenticationState.loggedIn:
        widget = LoggedInUserDetails();
        break;
      default:
        widget = ProviderLoginForm();
        break;
    }

    return Padding(
      padding: EdgeInsets.all(32),
      child: widget,
    );
  }
}

class ProviderLoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        try {
          await url_launcher.launch(
            nhostGithubLoginUrl,
            forceSafariVC: true,
            enableJavaScript: true,
          );
        } catch (e) {
          print(e.toString());
        }
      },
      child: Text('Authenticate with GitHub'),
    );
  }
}

class SimpleAuthExample extends StatefulWidget {
  @override
  _SimpleAuthExampleState createState() => _SimpleAuthExampleState();
}

class _SimpleAuthExampleState extends State<SimpleAuthExample> {
  NhostClient nhostClient;

  @override
  void initState() {
    super.initState();
    // Create a new Nhost client using your project's backend URL.
    nhostClient = NhostClient(baseUrl: nhostApiUrl);
  }

  @override
  void dispose() {
    super.dispose();
    nhostClient.close();
  }

  @override
  Widget build(BuildContext context) {
    // The NhostAuthProvider widget provides authentication state to its
    // subtree, which can be accessed using NhostAuthProvider.of(BuildContext).
    return NhostAuthProvider(
      auth: nhostClient.auth,
      child: MaterialApp(
        title: 'Nhost.io Simple Flutter Authentication',
        home: Scaffold(
          body: ExampleProtectedScreen(),
        ),
      ),
    );
  }
}

// class ExampleProtectedScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // NhostAuthProvider.of will register this widget so that it rebuilds whenever
//     // the user's authentication state changes.
//     final auth = NhostAuthProvider.of(context);
//     Widget widget;
//     switch (auth.authenticationState) {
//       case AuthenticationState.loggedIn:
//         widget = LoggedInUserDetails();
//         break;
//       case AuthenticationState.loggedOut:
//         widget = LoginForm();
//         break;
//       default:
//         widget = SizedBox();
//         break;
//     }

//     return Padding(
//       padding: EdgeInsets.all(32),
//       child: widget,
//     );
//   }
// }

const rowSpacing = SizedBox(height: 12);

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController;
  TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void tryLogin() async {
    final auth = NhostAuthProvider.of(context);

    try {
      await auth.login(
          email: emailController.text, password: passwordController.text);
    } on ApiException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (_) => tryLogin(),
            ),
            rowSpacing,
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onFieldSubmitted: (_) => tryLogin(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: tryLogin,
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}

class LoggedInUserDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = NhostAuthProvider.of(context);
    final currentUser = auth.currentUser;

    final textTheme = Theme.of(context).textTheme;
    const cellPadding = EdgeInsets.all(4);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome ${currentUser.email}!',
            style: textTheme.headline5,
          ),
          rowSpacing,
          Text('User details:', style: textTheme.caption),
          rowSpacing,
          Table(
            defaultColumnWidth: IntrinsicColumnWidth(),
            children: [
              for (final row in currentUser.toJson().entries)
                TableRow(
                  children: [
                    Padding(
                      padding: cellPadding.copyWith(right: 12),
                      child: Text(row.key),
                    ),
                    Padding(
                      padding: cellPadding,
                      child: Text('${row.value}'),
                    ),
                  ],
                )
            ],
          ),
          rowSpacing,
          ElevatedButton(
            onPressed: () {
              auth.logout();
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
