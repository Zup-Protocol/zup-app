import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/widgets/zup_header/zup_header.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20).copyWith(bottom: 0),
        child: const Column(
          children: [
            ZupHeader(),
            Expanded(child: RouterOutlet()),
          ],
        ),
      ),
    );
  }
}
