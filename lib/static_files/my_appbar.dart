import 'package:flutter/material.dart';

import 'my_color.dart';

AppBar myAppBar(String _title){
  return AppBar(
    backgroundColor: MyColor.yellow,
    title: Text(
      _title,
      style: const TextStyle(color: MyColor.purple),
    ),
    centerTitle: true,
    iconTheme: const IconThemeData(
      color: MyColor.purple,
    ),
    elevation: 0,
  );
}