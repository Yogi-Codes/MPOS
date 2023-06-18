import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:six_pos/controller/order_controller.dart';
import 'package:six_pos/controller/splash_controller.dart';
import 'package:six_pos/helper/date_converter.dart';
import 'package:six_pos/helper/price_converter.dart';
import 'package:six_pos/util/dimensions.dart';
import 'package:six_pos/util/images.dart';
import 'package:six_pos/util/styles.dart';
import 'package:six_pos/view/base/custom_app_bar.dart';
import 'package:six_pos/view/base/custom_divider.dart';
import 'package:six_pos/view/base/custom_drawer.dart';
import 'package:six_pos/view/base/custom_header.dart';
import 'package:six_pos/view/screens/pos_printer/invoice_print.dart';

import 'widget/invoice_element_view.dart';

class InVoiceScreen extends StatefulWidget {
  final int orderId;
  const InVoiceScreen({Key key, this.orderId}) : super(key: key);

  @override
  State<InVoiceScreen> createState() => _InVoiceScreenState();
}

class _InVoiceScreenState extends State<InVoiceScreen> {
  Future<void> _loadData() async {
    await Get.find<OrderController>().getInvoiceData(widget.orderId);
    printAuto();
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format,
      String title,
      double tax,
      double discount,
      double totalPayable,
      var id,
      List<String> N,
      List<double> C,
      String address,
      String method,
      String date) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final ThaiFont = await PdfGoogleFonts.notoSerifThaiBlack();
    final EnglishFont = await PdfGoogleFonts.openSansBold();

    final logoImage = pw.MemoryImage(
        (await rootBundle.load(Images.mpos_super_shop)).buffer.asUint8List());
    const double fontsize = 9;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.all(10),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                height: 70,
                child: pw.Center(
                  child: pw.Image(logoImage),
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.SizedBox(
                  width: 120,
                  child: pw.FittedBox(
                    child: pw.Text(title,
                        style: pw.TextStyle(
                            font: EnglishFont, color: PdfColors.black)),
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text(address,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      color: PdfColors.black,
                      fontSize: fontsize,
                      font: EnglishFont)),
              pw.Text('----------------------------------------------',
                  style:
                      pw.TextStyle(color: PdfColors.black, fontSize: fontsize)),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Expanded(
                  child: pw.Text('รหัสคำสั่งซื้อ :# ',
                      style: pw.TextStyle(
                          color: PdfColors.blue500,
                          fontSize: fontsize,
                          font: ThaiFont)),
                ),
                pw.Expanded(
                  child: pw.Text(id.toString() + '                ',
                      style: pw.TextStyle(
                          color: PdfColors.blue500,
                          fontSize: fontsize,
                          font: EnglishFont)),
                ),
                pw.Expanded(
                  child: pw.Text('วิธีการชำระเงิน',
                      style: pw.TextStyle(
                          color: PdfColors.blue500,
                          fontSize: fontsize,
                          font: ThaiFont)),
                ),
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Expanded(
                  child: pw.Text(
                      DateConverter.dateTimeStringToMonthAndTime(date) +
                          '                 ',
                      style: pw.TextStyle(
                          color: PdfColors.blue500,
                          fontSize: fontsize,
                          font: EnglishFont)),
                ),
                pw.Expanded(
                  child: pw.Text(method.tr.toString(),
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: fontsize,
                          font: EnglishFont)),
                ),
              ]),
              pw.Text('----------------------------------------------',
                  style:
                      pw.TextStyle(color: PdfColors.black, fontSize: fontsize)),
              for (int i = 0; i < N.length; i++)
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Expanded(
                        child: pw.Text('${i + 1}',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontSize: fontsize,
                                font: EnglishFont)),
                      ),
                      pw.Expanded(
                        child: pw.Text('${N[i].toString()}',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontSize: fontsize,
                                font: EnglishFont)),
                      ),
                      pw.Expanded(
                        child: pw.Text(C[i].toString(),
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontSize: fontsize,
                                font: EnglishFont)),
                      ),
                    ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Expanded(
                  child: pw.Text('ส่วนลด',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: fontsize,
                          font: ThaiFont)),
                ),
                pw.Expanded(
                  child: pw.Text(discount.toStringAsFixed(2),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: fontsize,
                          font: EnglishFont)),
                ),
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Expanded(
                  child: pw.Text('สภาษีมูลค่าเพิ่มรวม',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: fontsize,
                          font: ThaiFont)),
                ),
                pw.Expanded(
                  child: pw.Text(tax.toStringAsFixed(2),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: fontsize,
                          font: EnglishFont)),
                ),
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Expanded(
                  child: pw.Text('ยอดชำระเงินทั้งหมด ',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: fontsize,
                          font: ThaiFont)),
                ),
                pw.Expanded(
                  child: pw.Text(
                      totalPayable.roundToDouble().toStringAsFixed(2),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: fontsize,
                          font: EnglishFont)),
                ),
              ]),
              pw.Text('----------------------------------------------',
                  style:
                      pw.TextStyle(color: PdfColors.black, fontSize: fontsize)),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Expanded(
                  child: pw.Text('terms_and_condition'.tr,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: fontsize,
                          font: ThaiFont)),
                ),
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.Expanded(
                  child: pw.Text('terms_and_condition_details'.tr,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: fontsize,
                          font: ThaiFont)),
                ),
              ]),
              pw.Text('----------------------------------------------',
                  style:
                      pw.TextStyle(color: PdfColors.black, fontSize: fontsize)),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    return Uint8List.fromList(pdfBytes);
  }

  double printAuto() {
    var a;
    final invoiceController = Get.find<OrderController>();
    final shopController = Get.find<SplashController>();
    final PdfPageFormat pdfPageFormat = PdfPageFormat.roll57;
    Permission.location.request();
    _getbyte(List<String> N, List<double> C) async {
      a = await _generatePdf(
          pdfPageFormat,
          'Receipt',
          invoiceController.totalTaxAmount,
          invoiceController.discountOnProduct,
          totalPayableAmount,
          invoiceController.invoice.id,
          N,
          C,
          shopController.configModel.businessInfo.shopAddress,
          invoiceController.invoice.account.account,
          invoiceController.invoice.createdAt);
      print("perm");
      print(Permission.storage.request().isGranted);

      await Printing.layoutPdf(onLayout: (_) => a);
      // print(a.runtimeType);
      // String appDocDir =
      //     '/Android/data/';
      // String fileName =
      //     'my_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      // File file =
      //     File('$appDocDir/$fileName');
      // await file.writeAsBytes(a);
      // await OpenFile.open(file.path);
    }

    Navigator.pop(context);
    print("==============================================");
    List<String> name = [];
    List<double> cost = [];
    final regexN = RegExp(r'selling_price":(\d+)');
    for (int i = 0; i < invoiceController.invoice.details.length; i++) {
      final inputString =
          invoiceController.invoice.details[i].productDetails.toString();
      print("-------------------------||=>");
      print(invoiceController.invoice.details[i].productDetails);
      final regex = RegExp(r'"selling_price":"(\d+)"');
      final regexN = RegExp(r'"name":"([^"]+)"');
      final matchN = regexN.firstMatch(inputString);
      final match = regex.firstMatch(inputString);
      var price = double.parse(match.group(1));
      cost.add(price);
      final product = matchN.group(1);
      name.add(product);
    }

    _getbyte(name, cost);
  }

  double totalPayableAmount = 0;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: GetBuilder<SplashController>(builder: (shopController) {
        return SingleChildScrollView(
          child: GetBuilder<OrderController>(builder: (invoiceController) {
            if (invoiceController.invoice != null &&
                invoiceController.invoice.orderAmount != null) {
              totalPayableAmount = invoiceController.invoice.orderAmount +
                  invoiceController.totalTaxAmount -
                  invoiceController.invoice.extraDiscount -
                  invoiceController.invoice.couponDiscountAmount;
            }
            return Column(
              children: [
                CustomHeader(
                    title: 'invoice'.tr, headerImage: Images.people_icon),
                Padding(
                  padding:
                      const EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(flex: 3, child: SizedBox.shrink()),
                      Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        child: Container(
                          width: 80,
                          padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_SMALL,
                              vertical: Dimensions.PADDING_SIZE_SMALL),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                Dimensions.PADDING_SIZE_BORDER),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                        child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: Icon(
                                            Icons.bluetooth,
                                            color: Colors.blue,
                                          ),
                                          title: Text('Print over Bluetooth '),
                                          onTap: () {
                                            var a;

                                            final PdfPageFormat pdfPageFormat =
                                                PdfPageFormat.roll57;
                                            Permission.location.request();
                                            _getbyte(List<String> N,
                                                List<double> C) async {
                                              a = await _generatePdf(
                                                  pdfPageFormat,
                                                  'Receipt',
                                                  invoiceController
                                                      .totalTaxAmount,
                                                  invoiceController
                                                      .discountOnProduct,
                                                  totalPayableAmount,
                                                  invoiceController.invoice.id,
                                                  N,
                                                  C,
                                                  shopController.configModel
                                                      .businessInfo.shopAddress,
                                                  invoiceController
                                                      .invoice.account.account,
                                                  invoiceController
                                                      .invoice.createdAt);
                                              print("perm");
                                              print(Permission.storage
                                                  .request()
                                                  .isGranted);

                                              Permission.bluetooth.request();
                                              Navigator.pop(context);
                                              print(N);
                                              List<Map<String, dynamic>>
                                                  combined = [];

                                              for (int i = 0;
                                                  i < N.length;
                                                  i++) {
                                                Map<String, dynamic> newMap = {
                                                  "name": N[i],
                                                  "city": C[i]
                                                };
                                                combined.add(newMap);
                                              }
                                              print("LIST");
                                              Get.to(() => PrintPage(combined));
                                            }

                                            Navigator.pop(context);

                                            List<String> name = [];
                                            List<double> cost = [];
                                            final regexN =
                                                RegExp(r'selling_price":(\d+)');
                                            for (int i = 0;
                                                i <
                                                    invoiceController
                                                        .invoice.details.length;
                                                i++) {
                                              final inputString =
                                                  invoiceController.invoice
                                                      .details[i].productDetails
                                                      .toString();
                                              print(
                                                  "-------------------------||=>");
                                              print(invoiceController.invoice
                                                  .details[i].productDetails);
                                              final regex = RegExp(
                                                  r'"selling_price":"(\d+)"');
                                              final regexN =
                                                  RegExp(r'"name":"([^"]+)"');
                                              final matchN = regexN
                                                  .firstMatch(inputString);
                                              final match =
                                                  regex.firstMatch(inputString);
                                              var price =
                                                  double.parse(match.group(1));
                                              cost.add(price);
                                              final product = matchN.group(1);
                                              name.add(product);
                                            }

                                            _getbyte(name, cost);
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(
                                            Icons.wifi,
                                            color: Colors.blue,
                                          ),
                                          title: Text('Print over Any Printer'),
                                          onTap: () {
                                            var a;

                                            final PdfPageFormat pdfPageFormat =
                                                PdfPageFormat.roll57;
                                            Permission.location.request();
                                            _getbyte(List<String> N,
                                                List<double> C) async {
                                              a = await _generatePdf(
                                                  pdfPageFormat,
                                                  'Receipt',
                                                  invoiceController
                                                      .totalTaxAmount,
                                                  invoiceController
                                                      .discountOnProduct,
                                                  totalPayableAmount,
                                                  invoiceController.invoice.id,
                                                  N,
                                                  C,
                                                  shopController.configModel
                                                      .businessInfo.shopAddress,
                                                  invoiceController
                                                      .invoice.account.account,
                                                  invoiceController
                                                      .invoice.createdAt);
                                              print("perm");
                                              print(Permission.storage
                                                  .request()
                                                  .isGranted);

                                              await Printing.layoutPdf(
                                                  onLayout: (_) => a);
                                              // print(a.runtimeType);
                                              // String appDocDir =
                                              //     '/Android/data/';
                                              // String fileName =
                                              //     'my_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
                                              // File file =
                                              //     File('$appDocDir/$fileName');
                                              // await file.writeAsBytes(a);
                                              // await OpenFile.open(file.path);
                                            }

                                            Navigator.pop(context);
                                            print(
                                                "==============================================");
                                            List<String> name = [];
                                            List<double> cost = [];
                                            final regexN =
                                                RegExp(r'selling_price":(\d+)');
                                            for (int i = 0;
                                                i <
                                                    invoiceController
                                                        .invoice.details.length;
                                                i++) {
                                              final inputString =
                                                  invoiceController.invoice
                                                      .details[i].productDetails
                                                      .toString();
                                              print(
                                                  "-------------------------||=>");
                                              print(invoiceController.invoice
                                                  .details[i].productDetails);
                                              final regex = RegExp(
                                                  r'"selling_price":"(\d+)"');
                                              final regexN =
                                                  RegExp(r'"name":"([^"]+)"');
                                              final matchN = regexN
                                                  .firstMatch(inputString);
                                              final match =
                                                  regex.firstMatch(inputString);
                                              var price =
                                                  double.parse(match.group(1));
                                              cost.add(price);
                                              final product = matchN.group(1);
                                              name.add(product);
                                            }

                                            _getbyte(name, cost);
                                          },
                                        ),
                                      ],
                                    ));
                                  });
                            },
                            child: Center(
                                child: Row(
                              children: [
                                Container(
                                    child: Icon(
                                  Icons.event_note_outlined,
                                  color: Theme.of(context).cardColor,
                                  size: 15,
                                )),
                                SizedBox(
                                    width:
                                        Dimensions.PADDING_SIZE_MEDIUM_BORDER),
                                Text(
                                  'print'.tr,
                                  style: fontSizeRegular.copyWith(
                                      color: Theme.of(context).cardColor),
                                ),
                              ],
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                    Text(
                      'Mpos Super Shop',
                      style: fontSizeBold.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.FONT_SIZE_OVER_OVER_LARGE,
                      ),
                    ),
                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Text(
                      shopController.configModel.businessInfo.shopAddress,
                      style: fontSizeRegular.copyWith(
                          color: Theme.of(context).hintColor),
                    ),
                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Text(
                      shopController.configModel.businessInfo.shopPhone,
                      style: fontSizeRegular.copyWith(
                          color: Theme.of(context).hintColor),
                    ),
                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Text(shopController.configModel.businessInfo.shopEmail,
                        style: fontSizeRegular.copyWith(
                            color: Theme.of(context).hintColor)),
                    SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Text(shopController.configModel.businessInfo.vat ?? 'vat',
                        style: fontSizeRegular.copyWith(
                            color: Theme.of(context).hintColor)),
                  ],
                ),
                GetBuilder<OrderController>(builder: (orderController) {
                  return orderController.invoice != null &&
                          orderController.invoice.orderAmount != null
                      ? Padding(
                          padding:
                              EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                          child: Column(
                            children: [
                              CustomDivider(color: Theme.of(context).hintColor),
                              SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${'invoice'.tr.toUpperCase()} # ${widget.orderId}',
                                      style: fontSizeBold.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontSize:
                                              Dimensions.FONT_SIZE_LARGE)),
                                  Text('payment_method'.tr,
                                      style: fontSizeBold.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontSize:
                                              Dimensions.FONT_SIZE_LARGE)),
                                ],
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${DateConverter.dateTimeStringToMonthAndTime(orderController.invoice.createdAt)}',
                                      style: fontSizeRegular),
                                  Text(
                                      '${'paid_by'.tr} ${invoiceController.invoice.account != null ? invoiceController.invoice.account.account : 'customer balance'}',
                                      style: fontSizeRegular.copyWith(
                                        color: Theme.of(context).hintColor,
                                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                      )),
                                ],
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                              CustomDivider(color: Theme.of(context).hintColor),
                              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                              InvoiceElementView(
                                  serial: 'sl'.tr,
                                  title: 'product_info'.tr,
                                  quantity: 'qty'.tr,
                                  price: 'price'.tr,
                                  isBold: true),
                              SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                              Container(
                                child: ListView.builder(
                                  itemBuilder: (con, index) {
                                    return Container(
                                      height: 50,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Text((index + 1).toString()),
                                            SizedBox(
                                                width: Dimensions
                                                    .PADDING_SIZE_DEFAULT),
                                            Expanded(
                                                child: Text(
                                              jsonDecode(orderController
                                                  .invoice
                                                  .details[index]
                                                  .productDetails)['name'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .PADDING_SIZE_LARGE),
                                              child: Text(orderController
                                                  .invoice
                                                  .details[index]
                                                  .quantity
                                                  .toString()),
                                            ),
                                            Text(
                                                '${PriceConverter.priceWithSymbol(orderController.invoice.details[index].price)}'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount:
                                      orderController.invoice.details.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.PADDING_SIZE_DEFAULT),
                                child: CustomDivider(
                                    color: Theme.of(context).hintColor),
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'subtotal'.tr,
                                          style: fontSizeRegular.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        Text(PriceConverter.priceWithSymbol(
                                            orderController
                                                .invoice.orderAmount)),
                                      ],
                                    ),
                                    SizedBox(
                                        height: Dimensions.PADDING_SIZE_SMALL),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'product_discount'.tr,
                                          style: fontSizeRegular.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        Text(PriceConverter.priceWithSymbol(
                                            invoiceController
                                                .discountOnProduct)),
                                      ],
                                    ),
                                    SizedBox(
                                        height: Dimensions.PADDING_SIZE_SMALL),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'coupon_discount'.tr,
                                          style: fontSizeRegular.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        Text(PriceConverter.priceWithSymbol(
                                            orderController
                                                .invoice.couponDiscountAmount)),
                                      ],
                                    ),
                                    SizedBox(
                                        height: Dimensions.PADDING_SIZE_SMALL),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'extra_discount'.tr,
                                          style: fontSizeRegular.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        Text(PriceConverter.priceWithSymbol(
                                            orderController
                                                .invoice.extraDiscount)),
                                      ],
                                    ),
                                    SizedBox(
                                        height: Dimensions.PADDING_SIZE_SMALL),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'tax'.tr,
                                          style: fontSizeRegular.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        Text(PriceConverter.priceWithSymbol(
                                            invoiceController.totalTaxAmount)),
                                      ],
                                    ),
                                    SizedBox(
                                        height: Dimensions.PADDING_SIZE_SMALL),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical:
                                        Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                child: CustomDivider(
                                    color: Theme.of(context).hintColor),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'total'.tr,
                                    style: fontSizeBold.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: Dimensions.FONT_SIZE_LARGE),
                                  ),
                                  Text(
                                      PriceConverter.priceWithSymbol(
                                          totalPayableAmount.roundToDouble()),
                                      style: fontSizeBold.copyWith(
                                          fontSize:
                                              Dimensions.FONT_SIZE_LARGE)),
                                ],
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'change/neglected'.tr,
                                    style: fontSizeRegular.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_DEFAULT),
                                  ),
                                  Text(
                                      PriceConverter.priceWithSymbol(
                                          orderController
                                                  .invoice.collectedCash -
                                              totalPayableAmount),
                                      style: fontSizeRegular.copyWith(
                                          fontSize:
                                              Dimensions.FONT_SIZE_DEFAULT)),
                                ],
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                              Column(
                                children: [
                                  Text('terms_and_condition'.tr,
                                      style: fontSizeMedium.copyWith(
                                          fontSize: Dimensions
                                              .FONT_SIZE_EXTRA_LARGE)),
                                  SizedBox(
                                    height: Dimensions.PADDING_SIZE_SMALL,
                                  ),
                                  Text(
                                    'terms_and_condition_details'.tr,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: fontSizeRegular.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_SMALL),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.PADDING_SIZE_LARGE),
                                child: CustomDivider(
                                    color: Theme.of(context).hintColor),
                              ),
                              Column(
                                children: [
                                  Text('${'powered_by'.tr} ${'MPOS'}',
                                      style: fontSizeMedium.copyWith(
                                          fontSize: Dimensions
                                              .FONT_SIZE_EXTRA_LARGE)),
                                  SizedBox(
                                    height: Dimensions.PADDING_SIZE_SMALL,
                                  ),
                                  Text(
                                    '${'shop_online'.tr} ${shopController.configModel.businessInfo.shopName}',
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: fontSizeRegular.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_SMALL),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      Dimensions.PADDING_SIZE_CUSTOMER_BOTTOM),
                            ],
                          ),
                        )
                      : SizedBox();
                }),
              ],
            );
          }),
        );
      }),
    );
  }
}
