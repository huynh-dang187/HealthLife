import 'package:flutter/material.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:lottie/lottie.dart';

class TempHomePage extends StatelessWidget {
  const TempHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Lottie.asset(
              Assets.lottie.intro.intro,
              width: 238,
              height: 105,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Lựa chọn số 1 cho sức khỏe của bạn")],
          ),
        ],
      ),
    );
  }
}
