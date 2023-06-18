import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
import 'package:six_pos/view/screens/order/invoice_screen_old_direct.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as im;

class InVoiceScreen extends StatefulWidget {
  final int orderId;
  const InVoiceScreen({Key key, this.orderId}) : super(key: key);

  @override
  State<InVoiceScreen> createState() => _InVoiceScreenState();
}

class _InVoiceScreenState extends State<InVoiceScreen> {
  Future<void> _loadData() async {
    await Get.find<OrderController>().getInvoiceData(widget.orderId);
  }

  FocusNode _focusNode = FocusNode();

  int _counter = 0;
  Uint8List _imageFile;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  double totalPayableAmount = 0;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<Uint8List> ss() async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    print("pixel");
    print(pixelRatio);
    // double pixelRatio = MediaQuery.of(context).size.width;
    await screenshotController
        .capture(
      pixelRatio: 10,
      // delay: Duration(milliseconds: 10)
    )
        .then((Uint8List image) {
      //Capture Done
      setState(() {
        _imageFile = image;
      });
    }).catchError((onError) {
      print(onError);
    });
    print("image=======");
    return _imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            extraTitle: Text(
          "Invoice Preview".tr,
          style: TextStyle(color: Theme.of(context).primaryColor),
        )),
        endDrawer: CustomDrawer(),
        floatingActionButton: ElevatedButton(
            child: GetBuilder<SplashController>(builder: (shopController) {
          return SingleChildScrollView(
              child: GetBuilder<OrderController>(builder: (invoiceController) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(Duration(seconds: 1), () async {
                Future.delayed(Duration(seconds: 2), () async {
                  Uint8List imag = await ss();
                  Get.to(InVoicePrintScreen(
                    configModel: shopController.configModel,
                    invoice: invoiceController.invoice,
                    orderId: widget.orderId,
                    discountProduct: invoiceController.discountOnProduct,
                    total: totalPayableAmount,
                    printable_im: imag,
                  ));
                });
              });
            });
            return Container(
              width: 80,
              padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_SMALL,
                  vertical: Dimensions.PADDING_SIZE_SMALL),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(Dimensions.PADDING_SIZE_BORDER),
                color: Theme.of(context).primaryColor,
              ),
              child: InkWell(
                onTap: () async {
                  ;

                  Future.delayed(Duration(seconds: 2), () {
                    Get.to(InVoicePrintScreen(
                      configModel: shopController.configModel,
                      invoice: invoiceController.invoice,
                      orderId: widget.orderId,
                      discountProduct: invoiceController.discountOnProduct,
                      total: totalPayableAmount,
                      printable_im: _imageFile,
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
                    SizedBox(width: Dimensions.PADDING_SIZE_MEDIUM_BORDER),
                    Text(
                      'print'.tr,
                      style: fontSizeRegular.copyWith(
                          color: Theme.of(context).cardColor),
                    ),
                  ],
                )),
              ),
            );
          }));
        })),
        body: Container(
          constraints: BoxConstraints(
            maxWidth: 384, // Set the maximum width for the Scaffold
          ),
          child: Screenshot(
            controller: screenshotController,
            child: GetBuilder<SplashController>(builder: (shopController) {
              return SingleChildScrollView(
                child:
                    GetBuilder<OrderController>(builder: (invoiceController) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    print("jumping");
                  });

                  if (invoiceController.invoice != null &&
                      invoiceController.invoice.orderAmount != null) {
                    totalPayableAmount = invoiceController.invoice.orderAmount +
                        invoiceController.totalTaxAmount -
                        invoiceController.invoice.extraDiscount -
                        invoiceController.invoice.couponDiscountAmount;
                  }

                  return Transform.scale(
                    scale: 1,
                    child: Column(
                      children: [
                        // CustomHeader(
                        //     title: 'invoice'.tr, headerImage: Images.people_icon),
                        Padding(
                          padding: const EdgeInsets.all(
                              Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(flex: 3, child: SizedBox.shrink()),
                              Padding(
                                padding: const EdgeInsets.all(
                                    Dimensions.PADDING_SIZE_SMALL),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                            Text(
                              shopController.configModel.businessInfo.shopName,
                              style: fontSizeBold.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: Dimensions.FONT_SIZE_OVER_OVER_LARGE,
                              ),
                            ),
                            SizedBox(
                                height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            Text(
                              shopController
                                  .configModel.businessInfo.shopAddress,
                              style: fontSizeRegular.copyWith(
                                  color: Theme.of(context).hintColor),
                            ),
                            SizedBox(
                                height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            Text(
                              shopController.configModel.businessInfo.shopPhone,
                              style: fontSizeRegular.copyWith(
                                  color: Theme.of(context).hintColor),
                            ),
                            SizedBox(
                                height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            Text(
                                shopController
                                    .configModel.businessInfo.shopEmail,
                                style: fontSizeRegular.copyWith(
                                    color: Theme.of(context).hintColor)),
                            SizedBox(
                                height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            Text(
                                shopController.configModel.businessInfo.vat ??
                                    'vat',
                                style: fontSizeRegular.copyWith(
                                    color: Theme.of(context).hintColor)),
                          ],
                        ),
                        GetBuilder<OrderController>(builder: (orderController) {
                          return orderController.invoice != null &&
                                  orderController.invoice.orderAmount != null
                              ? Padding(
                                  padding: EdgeInsets.all(
                                      Dimensions.PADDING_SIZE_DEFAULT),
                                  child: Column(
                                    children: [
                                      CustomDivider(
                                          color: Theme.of(context).hintColor),
                                      SizedBox(
                                          height:
                                              Dimensions.PADDING_SIZE_DEFAULT),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${'invoice'.tr.toUpperCase()} # ${widget.orderId}',
                                              style: fontSizeBold.copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: Dimensions
                                                      .FONT_SIZE_LARGE)),
                                          Text('payment_method'.tr,
                                              style: fontSizeBold.copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: Dimensions
                                                      .FONT_SIZE_LARGE)),
                                        ],
                                      ),
                                      SizedBox(
                                          height:
                                              Dimensions.PADDING_SIZE_SMALL),
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
                                                color:
                                                    Theme.of(context).hintColor,
                                                fontSize: Dimensions
                                                    .FONT_SIZE_DEFAULT,
                                              )),
                                        ],
                                      ),
                                      SizedBox(
                                          height:
                                              Dimensions.PADDING_SIZE_DEFAULT),
                                      CustomDivider(
                                          color: Theme.of(context).hintColor),
                                      SizedBox(
                                          height:
                                              Dimensions.PADDING_SIZE_LARGE),
                                      InvoiceElementView(
                                          serial: 'sl'.tr,
                                          title: 'product_info'.tr,
                                          quantity: 'qty'.tr,
                                          price: 'price'.tr,
                                          isBold: true),
                                      SizedBox(
                                          height:
                                              Dimensions.PADDING_SIZE_DEFAULT),
                                      Container(
                                        child: ListView.builder(
                                          itemBuilder: (con, index) {
                                            return Container(
                                              height: 50,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        (index + 1).toString()),
                                                    SizedBox(
                                                        width: Dimensions
                                                            .PADDING_SIZE_DEFAULT),
                                                    Expanded(
                                                        child: Text(
                                                      jsonDecode(orderController
                                                              .invoice
                                                              .details[index]
                                                              .productDetails)[
                                                          'name'],
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: Dimensions
                                                              .PADDING_SIZE_LARGE),
                                                      child: Text(
                                                          orderController
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
                                          itemCount: orderController
                                              .invoice.details.length,
                                          physics:
                                              NeverScrollableScrollPhysics()
                                                  .parent,
                                          shrinkWrap: true,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .PADDING_SIZE_DEFAULT),
                                        child: CustomDivider(
                                            color: Theme.of(context).hintColor),
                                      ),
                                      Container(
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'subtotal'.tr,
                                                  style:
                                                      fontSizeRegular.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                ),
                                                Text(PriceConverter
                                                    .priceWithSymbol(
                                                        orderController.invoice
                                                            .orderAmount)),
                                              ],
                                            ),
                                            SizedBox(
                                                height: Dimensions
                                                    .PADDING_SIZE_SMALL),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'product_discount'.tr,
                                                  style:
                                                      fontSizeRegular.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                ),
                                                Text(PriceConverter
                                                    .priceWithSymbol(
                                                        invoiceController
                                                            .discountOnProduct)),
                                              ],
                                            ),
                                            SizedBox(
                                                height: Dimensions
                                                    .PADDING_SIZE_SMALL),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'coupon_discount'.tr,
                                                  style:
                                                      fontSizeRegular.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                ),
                                                Text(PriceConverter.priceWithSymbol(
                                                    orderController.invoice
                                                        .couponDiscountAmount)),
                                              ],
                                            ),
                                            SizedBox(
                                                height: Dimensions
                                                    .PADDING_SIZE_SMALL),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'extra_discount'.tr,
                                                  style:
                                                      fontSizeRegular.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                ),
                                                Text(PriceConverter
                                                    .priceWithSymbol(
                                                        orderController.invoice
                                                            .extraDiscount)),
                                              ],
                                            ),
                                            SizedBox(
                                                height: Dimensions
                                                    .PADDING_SIZE_SMALL),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'tax'.tr,
                                                  style:
                                                      fontSizeRegular.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                ),
                                                Text(PriceConverter
                                                    .priceWithSymbol(
                                                        invoiceController
                                                            .totalTaxAmount)),
                                              ],
                                            ),
                                            SizedBox(
                                                height: Dimensions
                                                    .PADDING_SIZE_SMALL),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL),
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
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize:
                                                    Dimensions.FONT_SIZE_LARGE),
                                          ),
                                          Text(
                                              PriceConverter.priceWithSymbol(
                                                  totalPayableAmount),
                                              style: fontSizeBold.copyWith(
                                                  fontSize: Dimensions
                                                      .FONT_SIZE_LARGE)),
                                        ],
                                      ),
                                      SizedBox(
                                          height:
                                              Dimensions.PADDING_SIZE_DEFAULT),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'change'.tr,
                                            style: fontSizeRegular.copyWith(
                                                fontSize: Dimensions
                                                    .FONT_SIZE_DEFAULT),
                                          ),
                                          Text(
                                              PriceConverter.priceWithSymbol(
                                                  orderController.invoice
                                                          .collectedCash -
                                                      totalPayableAmount),
                                              style: fontSizeRegular.copyWith(
                                                  fontSize: Dimensions
                                                      .FONT_SIZE_DEFAULT)),
                                        ],
                                      ),
                                      SizedBox(
                                          height:
                                              Dimensions.PADDING_SIZE_DEFAULT),
                                      Column(
                                        children: [
                                          Text('terms_and_condition'.tr,
                                              style: fontSizeMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .FONT_SIZE_EXTRA_LARGE)),
                                          SizedBox(
                                            height:
                                                Dimensions.PADDING_SIZE_SMALL,
                                          ),
                                          Text(
                                            'terms_and_condition_details'.tr,
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            style: fontSizeRegular.copyWith(
                                                fontSize:
                                                    Dimensions.FONT_SIZE_SMALL),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical:
                                                Dimensions.PADDING_SIZE_LARGE),
                                        child: CustomDivider(
                                            color: Theme.of(context).hintColor),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                              '${'powered_by'.tr} ${shopController.configModel.businessInfo.shopName}',
                                              style: fontSizeMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .FONT_SIZE_EXTRA_LARGE)),
                                          SizedBox(
                                            height:
                                                Dimensions.PADDING_SIZE_SMALL,
                                          ),
                                          Text(
                                            '${'shop_online'.tr} ${shopController.configModel.businessInfo.shopName}',
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            style: fontSizeRegular.copyWith(
                                                fontSize:
                                                    Dimensions.FONT_SIZE_SMALL),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: Dimensions
                                              .PADDING_SIZE_CUSTOMER_BOTTOM),
                                      TextField(
                                        style: TextStyle(
                                            color: Colors.transparent,
                                            background: Paint()),
                                        focusNode:
                                            _focusNode, // Assign the FocusNode
                                        autofocus: true,
                                        cursorColor: Colors.transparent,

                                        // Set autofocus to true
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        cursorRadius: Radius.zero,
                                        keyboardType: TextInputType.none,
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox();
                        }),
                      ],
                    ),
                  );
                }),
              );
            }),
          ),
        ));
  }
}
