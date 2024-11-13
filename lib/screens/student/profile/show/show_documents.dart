import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../static_files/my_color.dart';

class ShowDocument extends StatelessWidget {
  final Map data;
  final String url;
  const ShowDocument({Key? key, required this.data, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.purple,
        title: const Text(
          "المستمسكات",
          style: TextStyle(color: MyColor.yellow),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if(data['certificate_national_id'] != null)
              Container(
                  padding: const EdgeInsets.only(right: 40, left: 40, top: 40),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("البطاقة الوطنية"),
                      ),
                      _imgShow(url + data['certificate_national_id']),
                      const Divider()
                    ],
                  )),
            if(data['certificate_national_old'] != null)
              Container(
                  padding: const EdgeInsets.only(right: 40, left: 40, top: 40),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("هوية الاحوال المدنية"),
                      ),
                      _imgShow(url + data['certificate_national_old']),
                      const Divider()
                    ],
                  )),

            if(data['certificate_passport'] != null)
              Container(
                  padding: const EdgeInsets.only(right: 40, left: 40, top: 40),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("الجواز"),
                      ),
                      _imgShow(url + data['certificate_passport']),
                      const Divider()
                    ],
                  )),
            if(data['certificate_nationality'] != null)
              Container(
                  padding: const EdgeInsets.only(right: 40, left: 40, top: 40),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("شهادة الجنسية"),
                      ),
                      _imgShow(url + data['certificate_nationality']),
                      const Divider()
                    ],
                  )),
            if(data['certificate_address'] != null)
              Container(
                  padding: const EdgeInsets.only(right: 40, left: 40, top: 40),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("بطاقة السكن"),
                      ),
                      _imgShow(url + data['certificate_address']),
                      const Divider()
                    ],
                  )),

          ],
        ),
      ),
    );
  }
  Widget _imgShow(String url){
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child:CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
        const CircularProgressIndicator(),
        errorWidget: (context, url, error) =>
        const Icon(Icons.error),
      ),
    );
  }
}
