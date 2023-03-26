
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:six_pos/controller/product_controller.dart';
import 'package:six_pos/util/color_resources.dart';
import 'package:six_pos/util/dimensions.dart';
import 'package:six_pos/util/images.dart';
import 'package:six_pos/util/styles.dart';
import 'package:six_pos/view/base/custom_app_bar.dart';
import 'package:six_pos/view/base/custom_button.dart';
import 'package:six_pos/view/base/custom_header.dart';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';



class ProductBulkExport extends StatefulWidget {
  const ProductBulkExport({Key key}) : super(key: key);

  @override
  State<ProductBulkExport> createState() => _ProductBulkExportState();
}

class _ProductBulkExportState extends State<ProductBulkExport> {
  ReceivePort _port = ReceivePort();


  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: GetBuilder<ProductController>(
        builder: (exportController) {
          return Column(children: [

            CustomHeader(title: 'bulk_export'.tr, headerImage: Images.import),

            InkWell(
              onTap: () async {
                final status = await Permission.storage.request();
                if(status.isGranted){
                  exportController.bulkExportFile().then((value) async {
                    Directory directory = Directory('/storage/emulated/0/Download');
                    if (!await directory.exists()) directory = await getExternalStorageDirectory();
                    exportController.downloadFile(exportController.bulkExportFilePath,directory.path);
                  });
                }else{
                  print('======permission denied=====');
                }

              },
              child: Container(child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: 100,child: Image.asset(Images.download)),
                  Text('click_download_button'.tr, textAlign: TextAlign.center,
                    style: fontSizeRegular.copyWith(color: ColorResources.DOWNLOAD_FORMAT.withOpacity(.5)),),
                ],)),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT,vertical: Dimensions.PADDING_SIZE_LARGE),
              child: CustomButton(buttonText: 'download'.tr, onPressed: () async {
                exportController.bulkExportFile().then((value) async {
                  final directory = await getApplicationDocumentsDirectory();
                  exportController.downloadFile(exportController.bulkExportFilePath,directory.path);
                });

              },),
            ),

          ],);
        }
      ),
    );
  }
}
