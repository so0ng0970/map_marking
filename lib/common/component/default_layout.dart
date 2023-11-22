// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:map_marking/user/component/main_drawer.dart';

class DefaultLayout extends StatelessWidget {
  Widget body;
  DefaultLayout({
    Key? key,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [],
      ),
      drawer: const MainDrawer(),
      body: body,
    );
  }
}
