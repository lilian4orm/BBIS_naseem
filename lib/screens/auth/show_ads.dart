import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_times.dart';


class ShowAds extends StatefulWidget {
  final Map data;
  final String? tag;
  const ShowAds({Key? key,required this.data,this.tag}) : super(key: key);

  @override
  _ShowAdsState createState() => _ShowAdsState();
}

class _ShowAdsState extends State<ShowAds> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.yellow,
        title: Text(
          widget.data['title'].toString(),
          style: const TextStyle(color: MyColor.purple),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          if (widget.tag != null)
            Hero(
              tag: widget.tag!,
              child: CachedNetworkImage(
                imageUrl: widget.tag!,
                placeholder: (context, url) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                  ],
                ),
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: Text(toDateAndTime(widget.data['created_at'],12),style: const TextStyle(color: MyColor.black),),
          ),
          if (widget.data['description'] != null)
            Container(
              margin: const EdgeInsets.all(20),
              child: Text(
                widget.data['description'].toString(),
                style: const TextStyle(fontSize: 18, color: MyColor.purple),
              ),
            )
        ],
      ),
    );
  }
}
