import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class WebViewPage extends StatefulWidget {
  WebViewPage({this.url, this.title});
  String url, title;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.09,
                ),
                Expanded(
                  child: WebView(
                    initialUrl:
                        'https://www.producthunt.com/posts/${widget.url}',
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageFinished: (finish) {
                      setState(() {
                        isLoading = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Stack(),
            Container(
                height: MediaQuery.of(context).size.height * 0.09,
                padding: EdgeInsets.only(top: 24, left: 0),
                child: Row(children: [
                  Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[400],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    width: MediaQuery.of(context).size.width * 0.06,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isLoading ? 'Loading...' : widget.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.018,
                            )),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Text(
                            'https://www.producthunt.com/posts/${widget.url}',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.015,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                color: Colors.black),
          ],
        ),
      ),
    );
  }
}
