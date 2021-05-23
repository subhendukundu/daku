import 'package:daku/controller/database_ctrl.dart';
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
            .toStringAsFixed(1),
      );
      if (persent == null) {
        persent = 1;
      }

      return CircularPercentIndicator(
        radius: MediaQuery.of(context).size.height * 0.1,
        lineWidth: 5.0,
        animation: true,
        percent: persent,
        center: new Text(
          ((persent) * 100).toString().substring(0, 2),
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        footer: Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
          ),
          child: new Text(
            'Total Right Swiped',
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.02),
          ),
        ),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: Colors.green,
      );
    },
  );
}
