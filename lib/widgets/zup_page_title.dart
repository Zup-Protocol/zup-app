import 'package:flutter/material.dart';

class ZupPageTitle extends StatelessWidget {
  const ZupPageTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    );
  }
}
