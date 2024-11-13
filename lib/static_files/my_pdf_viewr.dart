import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'my_color.dart';

class PdfViewer extends StatefulWidget {
  final String url;

  const PdfViewer({Key? key, required this.url}) : super(key: key);

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  List<int>? _documentBytes;

  _saveNetworkPdf(String path) async {
    final Directory directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    final savePath = p.join(directory.path, path.split('/').last);
    try {
      var file = File(savePath);
      file.writeAsBytes(_documentBytes!, flush: true);
      Get.snackbar("نجاح", "تم حفظ الملف بنجاح",
          backgroundColor: MyColor.green, colorText: MyColor.white0);
    } catch (e) {
      Logger().e(e);
      Get.snackbar("خطأ", 'الرجاء التاكد من اتصالك في الانترنت',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                if(_documentBytes !=null){
                  _saveNetworkPdf(widget.url);
                }
              },
              icon: const Icon(Icons.download))
        ],
      ),
      body: SfPdfViewer.network(
        widget.url,
        enableDoubleTapZooming: true,
        onDocumentLoaded: (details) {
          _documentBytes = details.document.saveSync();
        },
        onDocumentLoadFailed: (details) {
          Get.snackbar("خطأ", 'الرجاء التاكد من اتصالك في الانترنت',
              colorText: MyColor.white0, backgroundColor: MyColor.red);
        },
      ),
    );
  }
}

class PdfViewerAssets extends StatefulWidget {
  final String filePDF;

  const PdfViewerAssets({super.key, required this.filePDF});

  @override
  State<PdfViewerAssets> createState() => _PdfViewerAssetsState();
}

class _PdfViewerAssetsState extends State<PdfViewerAssets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.yellow,
      ),
      body: SfPdfViewer.asset(
        widget.filePDF,
        enableDoubleTapZooming: true,
      ),
    );
  }
}
