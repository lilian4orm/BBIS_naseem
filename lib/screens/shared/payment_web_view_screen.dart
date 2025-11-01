import 'package:BBInaseem/static_files/my_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class PaymentInAppWebViewScreen extends StatefulWidget {
  final String url;
  const PaymentInAppWebViewScreen({super.key, required this.url});

  @override
  State<PaymentInAppWebViewScreen> createState() =>
      _PaymentInAppWebViewScreenState();
}

class _PaymentInAppWebViewScreenState extends State<PaymentInAppWebViewScreen> {
  double progress = 0;
  final isLoading = false.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الدفع'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: Obx(
            () => isLoading.value && progress < 1.0
                ? LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  )
                : Container(),
          ),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true,
          ),
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
          ),
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
          ),
        ),
        onWebViewCreated: (controller) {},
        onProgressChanged: (controller, progressValue) {
          progress = progressValue / 100;
          isLoading.value = progress < 1.0;
        },
        onLoadStart: (controller, url) {
          isLoading.value = true;
        },
        onLoadStop: (controller, url) async {
          isLoading.value = false;

          // await _fillField(
          //   cardNumber: '5213720304238582',
          //   date: '01/32',
          //   ccv: '642',
          // );
        },
        onLoadError: (controller, url, code, message) {
          isLoading.value = false;
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final url = navigationAction.request.url;
          if (url == null) {
            return NavigationActionPolicy.ALLOW;
          }

          final urlStr = url.toString();

          if (urlStr.startsWith(paymentRedirectURL)) {
            if (urlStr.contains("SUCCESS")) {
              Get.back(result: true);
            } else {
              Get.back(result: false);
            }

            return NavigationActionPolicy.CANCEL;
          }

          return NavigationActionPolicy.ALLOW;
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED,
          );
        },
      ),
    );
  }
}
