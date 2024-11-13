import 'package:flutter/material.dart';

class Food extends StatelessWidget {
  const Food({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Schedule'),
      ),
      body: Center(
        child: Image.asset("assets/img/logo.png"),
      ),
    );
  }
}
