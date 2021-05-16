import 'package:daku/Controller/DatabaseCtrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

buildCircularPercent(context) {
  return GetX<DatabaseCtrl>(
      init: DatabaseCtrl(),
      builder: (controller) {
        double persent = double.parse(
            (controller.userDataModel.value.rightSwiped /
                    (controller.userDataModel.value.rightSwiped +
                        controller.userDataModel.value.leftSwipled))
                .toStringAsFixed(1));
        return CircularPercentIndicator(
          radius: 100.0,
          lineWidth: 5.0,
          animation: true,
          percent: 1 - persent,
          center: new Text(
            ((1 - persent) * 100).toString().substring(0, 3),
            style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          footer: new Text(
            'Total Right Swiped',
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width * 0.05),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: Colors.green,
        );
      });
}
