import 'package:daku/SavedPosts/Card.dart';
import 'package:daku/controller/database_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

// ignore: must_be_immutable
class SavedPosts extends StatelessWidget {
  Direction direction;
  int position = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Posts'),
      ),
      body: Container(
        child: GetX<DatabaseCtrl>(
            init: DatabaseCtrl(),
            builder: (controller) {
              print(controller.nodeList.length);
              if (controller.nodeList.length == 0) {
                return Center(
                  child: Text(
                    'No Post Added yet',
                    style: Theme.of(context).textTheme.headline1.copyWith(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                        ),
                  ),
                );
              } else {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Cards(
                        posts: controller.nodeList,
                        onProgress: (progress, direction) {
                          final titleHeight = (60 + 48);

                          var newOffset = progress * titleHeight / 100;
                          if (direction == Direction.AWAY) {
                            newOffset += (position * titleHeight);
                          }

                          if (direction == Direction.BACK) {
                            newOffset = ((position) * titleHeight) - newOffset;
                          }

                          if (progress == 100 && direction == Direction.NONE) {
                            if (this.direction == Direction.AWAY) {
                              position += 1;
                            } else {
                              position -= 1;
                            }
                          }
                          this.direction = direction;
                        },
                      ),
                    ]);
              }
            }),
      ),
    );
  }
}
