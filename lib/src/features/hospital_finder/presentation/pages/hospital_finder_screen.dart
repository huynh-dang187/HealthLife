import 'package:flutter/material.dart';
import 'package:healthlife/src/core/presentation/widgets/no_data.dart';

class HospitalScreen extends StatelessWidget {
  const HospitalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NoData(),
    );
  }
}
