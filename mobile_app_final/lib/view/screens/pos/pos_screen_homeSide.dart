import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:six_pos/controller/cart_controller.dart';
import 'package:six_pos/controller/transaction_controller.dart';
import 'package:six_pos/data/model/body/place_order_body.dart';
import 'package:six_pos/data/model/response/account_model.dart';
import 'package:six_pos/data/model/response/cart_model.dart';
import 'package:six_pos/data/model/response/temporary_cart_for_customer.dart'
    as customer;
import 'package:six_pos/helper/price_converter.dart';
import 'package:six_pos/util/dimensions.dart';
import 'package:six_pos/util/images.dart';
import 'package:six_pos/util/styles.dart';
import 'package:six_pos/view/base/animated_custom_dialog.dart';
import 'package:six_pos/view/base/custom_app_bar.dart';
import 'package:six_pos/view/base/custom_button.dart';
import 'package:six_pos/view/base/custom_divider.dart';
import 'package:six_pos/view/base/custom_header.dart';
import 'package:six_pos/view/base/custom_snackbar.dart';
import 'package:six_pos/view/base/custom_text_field.dart';
import 'package:six_pos/view/screens/pos/widget/cart_pricing_widget.dart';
import 'package:six_pos/view/screens/pos/widget/confirm_purchase_dialog.dart';
import 'package:six_pos/view/screens/pos/widget/coupon_apply_widget.dart';
import 'package:six_pos/view/screens/pos/widget/customer_search_dialog.dart';
import 'package:six_pos/view/screens/pos/widget/extra_discount_and_coupon_dialog.dart';
import 'package:six_pos/view/screens/pos/widget/item_card_widget.dart';
import 'package:six_pos/view/screens/user/add_new_suppliers_and_customers.dart';
import 'package:promptpay/promptpay.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../base/custom_drawer.dart';

var qrCodeSvg1 = '''
      <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" viewBox="0 0 200 200">
        <rect x="0" y="0" width="200" height="200" fill="#f3e5ab"/>
        <rect x="65" y="40" width="70" height="120" fill="#fdd8a8"/>
        <rect x="85" y="70" width="30" height="50" fill="#ffb076"/>
        <circle cx="50" cy="100" r="40" fill="#fece8d"/>
        <circle cx="150" cy="100" r="40" fill="#fece8d"/>
        <circle cx="50" cy="100" r="20" fill="#ff9c58"/>
        <circle cx="150" cy="100" r="20" fill="#ff9c58"/>
        <path d="M100 130c0 12.15-9.85 22-22 22s-22-9.85-22-22" fill="#ff7043"/>
        <path d="M70 30c-5.238 0-10.17 1.32-14.23 3.639L61.19 70h28.62l5.429-36.36C80.17 31.32 75.24 30 70 30zm0 20c-8.271 0-15 6.729-15 15h30c0-8.271-6.729-15-15-15z" fill="#8d6e63"/>
        <path d="M70 30c-5.238 0-10.17 1.32-14.23 3.639L61.19 70h28.62l5.429-36.36C80.17 31.32 75.24 30 70 30z" fill="#6b4e42"/>
      </svg>
    ''';
List<String> bankList = [
  'ธนาคารกสิกรไทย',
  'ธนาคารกรุงเทพ',
  'ธนาคารกรุงไทย',
  'ธนาคารกรุงศรีอยุธยา',
  'ธนาคารทหารไทย',
  'ธนาคารไทยพาณิชย์',
  'ธนาคารกรุงศรี',
  'ธนาคารออมสิน',
  'ธนาคารซีไอเอ็มบีไทย',
  'ธนาคารทิสโก้'
];

class PosScreen extends StatefulWidget {
  final bool fromMenu;

  const PosScreen({Key key, this.fromMenu = false}) : super(key: key);

  @override
  State<PosScreen> createState() => _PosScreenState();
}

String generateBarcode(
  Barcode bc,
  String data, {
  double width,
  double height,
  double fontHeight,
}) {
  // Create the Barcode
  final svg = bc.toSvg(
    data,
    width: width ?? 200,
    height: height ?? 80,
    fontHeight: fontHeight,
  );

  return svg; // Return the SVG data as a string
}

class _PosScreenState extends State<PosScreen> {
  final ScrollController _scrollController = ScrollController();
  String selectedOption = "";
  String selectedBank = "";
  String last4digit = "";
  double subTotal = 0,
      productDiscount = 0,
      total = 0,
      payable = 0,
      couponAmount = 0,
      extraDiscount = 0,
      productTax = 0,
      xxDiscount = 0;

  TextEditingController _textEditingController = TextEditingController();
  int userId = 0;
  String customerName = '';

  @override
  void initState() {
    super.initState();
    Get.find<CartController>().collectedCashController.text = '0';
    Get.find<CartController>().extraDiscountController.text = '0';
    if (Get.find<CartController>().customerSelectedName == '') {
      Get.find<CartController>().searchCustomerController.text =
          'walking customer';

      // Get.find<CartController>().setCustomerInfo( 0,  'walking customer', 'NULL', true);
    }
  }

  Future<void> genQr() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var promptpayDataWithAmount = PromptPay.generateQRData(
        _textEditingController.text == ""
            ? prefs.getString("qr")
            : _textEditingController.text,
        amount: total);

    prefs.setString("qr", _textEditingController.text);

    bool isQRValid = PromptPay.isQRDataValid(promptpayDataWithAmount);

    if (isQRValid) {
      qrCodeSvg1 = generateBarcode(
        Barcode.qrCode(),
        promptpayDataWithAmount,
        height: 200,
      );
      print("Valid");
      setState(() {});
    } else {
      print("Invalid");
    }
  }

  Uint8List svgToMemoryImage(String svg) {
    // Convert the SVG string to a Uint8List
    final bytes = utf8.encode(svg);
    final base64 = base64Encode(bytes);
    final imageDataUrl = 'data:image/svg+xml;base64,$base64';
    final imageDataBytes = base64Decode(base64);

    // Create a MemoryImage from the Uint8List
    return Uint8List.fromList(imageDataBytes);
  }

  @override
  Widget build(BuildContext context) {
    var rng = Random();
    for (var i = 0; i < 10; i++) {
      print(rng.nextInt(10000));
    }

    return Scaffold(
      body: Container(
        child: RefreshIndicator(
          color: Theme.of(context).cardColor,
          backgroundColor: Theme.of(context).primaryColor,
          onRefresh: () async {
            return true;
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                  child: GetBuilder<CartController>(builder: (cartController) {
                productDiscount = 0;
                total = 0;
                productTax = 0;
                subTotal = 0;
                if (cartController.customerCartList.isNotEmpty) {
                  subTotal = cartController.amount;
                  for (int i = 0;
                      i <
                          cartController
                              .customerCartList[cartController.customerIndex]
                              .cart
                              .length;
                      i++) {
                    productDiscount = cartController
                                .customerCartList[cartController.customerIndex]
                                .cart[i]
                                .product
                                .discountType ==
                            'amount'
                        ? productDiscount +
                            (cartController
                                    .customerCartList[
                                        cartController.customerIndex]
                                    .cart[i]
                                    .product
                                    .discount) *
                                (cartController
                                    .customerCartList[
                                        cartController.customerIndex]
                                    .cart[i]
                                    .quantity)
                        : productDiscount +
                            (((cartController
                                            .customerCartList[
                                                cartController.customerIndex]
                                            .cart[i]
                                            .product
                                            .discount /
                                        100) *
                                    cartController
                                        .customerCartList[
                                            cartController.customerIndex]
                                        .cart[i]
                                        .product
                                        .sellingPrice)) *
                                (cartController
                                    .customerCartList[
                                        cartController.customerIndex]
                                    .cart[i]
                                    .quantity);
                    productTax = productTax +
                        (((cartController
                                        .customerCartList[
                                            cartController.customerIndex]
                                        .cart[i]
                                        .product
                                        .tax /
                                    100) *
                                cartController
                                    .customerCartList[
                                        cartController.customerIndex]
                                    .cart[i]
                                    .product
                                    .sellingPrice)) *
                            (cartController
                                .customerCartList[cartController.customerIndex]
                                .cart[i]
                                .quantity);
                  }
                }

                if (cartController.customerCartList.isNotEmpty) {
                  couponAmount = cartController
                          .customerCartList[cartController.customerIndex]
                          .couponAmount ??
                      0;
                  xxDiscount = cartController
                          .customerCartList[cartController.customerIndex]
                          .extraDiscount ??
                      0;
                }

                extraDiscount = double.parse(
                    PriceConverter.discountCalculationWithOutSymbol(
                        context,
                        subTotal,
                        xxDiscount,
                        cartController.selectedDiscountType));
                total = subTotal -
                    productDiscount -
                    couponAmount -
                    extraDiscount +
                    productTax;
                payable = total;

                return Column(
                  children: [
                    GetBuilder<TransactionController>(
                        builder: (transactionController) {
                      return Column(
                        children: [
                          CustomButton(
                              buttonText: 'place_order'.tr,
                              onPressed: () {
                                if (cartController
                                    .customerCartList[Get.find<CartController>()
                                        .customerIndex]
                                    .cart
                                    .isEmpty) {
                                  showCustomSnackBar(
                                      'please_select_at_least_one_product'.tr);
                                } else if (transactionController
                                            .selectedFromAccountId ==
                                        1 &&
                                    cartController.collectedCashController.text
                                        .trim()
                                        .isEmpty) {
                                  showCustomSnackBar('please_pay_first'.tr);
                                } else if (transactionController
                                            .selectedFromAccountId ==
                                        1 &&
                                    double.parse(cartController
                                            .collectedCashController.text
                                            .trim()) <
                                        total.roundToDouble()) {
                                  showCustomSnackBar(
                                      'please_pay_full_amount'.tr);
                                } else {
                                  showAnimatedDialog(
                                      context,
                                      ConfirmPurchaseDialog(
                                          onYesPressed: cartController.isLoading
                                              ? null
                                              : () {
                                                  List<Cart> carts = [];
                                                  productDiscount = 0;
                                                  productTax = 0;
                                                  for (int index = 0;
                                                      index <
                                                          cartController
                                                              .customerCartList[
                                                                  cartController
                                                                      .customerIndex]
                                                              .cart
                                                              .length;
                                                      index++) {
                                                    CartModel cart = cartController
                                                        .customerCartList[
                                                            cartController
                                                                .customerIndex]
                                                        .cart[index];
                                                    carts.add(Cart(
                                                      cart.product.id
                                                          .toString(),
                                                      cart.price.toString(),
                                                      cart.product.discountType ==
                                                              'amount'
                                                          ? productDiscount +
                                                                  cart.product
                                                                      .discount ??
                                                              0
                                                          : productDiscount +
                                                              ((cart.product
                                                                          .discount /
                                                                      100) *
                                                                  cart.product
                                                                      .sellingPrice),
                                                      cart.quantity,
                                                      productTax +
                                                          ((cart.product.tax /
                                                                  100) *
                                                              cart.product
                                                                  .sellingPrice),
                                                    ));
                                                  }

                                                  PlaceOrderBody
                                                      _placeOrderBody =
                                                      PlaceOrderBody(
                                                    cart: carts,
                                                    couponDiscountAmount:
                                                        cartController
                                                            .couponCodeAmount,
                                                    couponCode: cartController
                                                        .couponController.text,
                                                    orderAmount:
                                                        cartController.amount,
                                                    userId: cartController
                                                        .customerId,
                                                    collectedCash: transactionController
                                                                .selectedFromAccountId ==
                                                            0
                                                        ? double.parse(
                                                            cartController
                                                                .customerWalletController
                                                                .text
                                                                .trim())
                                                        : transactionController
                                                                    .selectedFromAccountId ==
                                                                1
                                                            ? double.parse(
                                                                cartController
                                                                    .collectedCashController
                                                                    .text
                                                                    .trim())
                                                            : 0.0,
                                                    extraDiscountType:
                                                        cartController
                                                            .selectedDiscountType,
                                                    extraDiscount: cartController
                                                            .extraDiscountController
                                                            .text
                                                            .trim()
                                                            .isEmpty
                                                        ? 0.0
                                                        : double.parse(PriceConverter
                                                            .discountCalculationWithOutSymbol(
                                                                context,
                                                                subTotal,
                                                                cartController
                                                                    .extraDiscountAmount,
                                                                cartController
                                                                    .selectedDiscountType)),
                                                    returnedAmount: cartController
                                                        .returnToCustomerAmount,
                                                    type: Get.find<
                                                            TransactionController>()
                                                        .selectedFromAccountId,
                                                    transactionRef: transactionController
                                                                    .selectedFromAccountId !=
                                                                0 &&
                                                            transactionController
                                                                    .selectedFromAccountId !=
                                                                1
                                                        ? cartController
                                                            .collectedCashController
                                                            .text
                                                            .trim()
                                                        : '',
                                                  );
                                                  if (!cartController
                                                      .singleClick) {
                                                    cartController
                                                        .placeOrder(
                                                            _placeOrderBody)
                                                        .then((value) {
                                                      if (value.isOk) {
                                                        couponAmount = 0;
                                                        extraDiscount = 0;
                                                      }
                                                    });
                                                  }
                                                }),
                                      dismissible: false,
                                      isFlip: false);
                                }
                              }),
                          selectedOption == "Promptpay"
                              ? SvgPicture.string(
                                  qrCodeSvg1,

                                  height: 300,
                                  width: 200,

                                  // You can customize other properties of the SVG image as needed
                                  // such as color, semantics, alignment, etc.
                                )
                              : Container(),
                          selectedOption == "Promptpay"
                              ? CustomTextField(
                                  hintText: "prompt id",
                                  controller: _textEditingController,
                                  // onChanged: () {},
                                )
                              : Container(),
                          selectedOption == "Promptpay"
                              ? Container(
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            child: TextButton(
                                              onPressed: () => {genQr()},
                                              child: Text("Generate Qr"),
                                            ),
                                            decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                border: Border.all(
                                                    width: .5,
                                                    color: Theme.of(context)
                                                        .hintColor
                                                        .withOpacity(.7)),
                                                borderRadius: BorderRadius
                                                    .circular(Dimensions
                                                        .PADDING_SIZE_MEDIUM_BORDER)),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              : Container(),
                          selectedOption == "Debit Card"
                              ? Container(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      DropdownButtonFormField<String>(
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedBank = newValue;
                                            print("selectedBank");
                                            print(selectedBank);
                                          });
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'เลือกธนาคาร',
                                        ),
                                        items: bankList
                                            .map<DropdownMenuItem<String>>(
                                                (String bank) {
                                          return DropdownMenuItem<String>(
                                            value: bank,
                                            child: Text(bank),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 16.0),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText:
                                              'เลขที่บัญชี 4 หลักสุดท้าย',
                                        ),
                                        onChanged: (value) {
                                          // setState(() {
                                          //   var last4Digits = value;
                                          // });
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          CustomTextField(
                            hintText: 'balance_hint'.tr,
                            isEnabled: transactionController
                                            .selectedFromAccountId ==
                                        0 &&
                                    Get.find<CartController>().customerId != 0
                                ? false
                                : true,
                            controller: transactionController
                                            .selectedFromAccountId ==
                                        0 &&
                                    Get.find<CartController>().customerId != 0
                                ? cartController.customerWalletController
                                : cartController.collectedCashController,
                            inputType:
                                transactionController.selectedFromAccountId == 1
                                    ? TextInputType.number
                                    : TextInputType.text,
                            onChanged: (value) {
                              cartController.getReturnAmount(payable);
                            },
                          ),
                          PricingWidget(
                              title: 'total'.tr,
                              amount:
                                  '${PriceConverter.priceWithSymbol(total)}',
                              isTotal: true),
                        ],
                      );
                    }),
                    Column(
                      children: [
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        GetBuilder<CartController>(
                            builder: (customerController) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(
                                Dimensions.PADDING_SIZE_DEFAULT,
                                0,
                                Dimensions.PADDING_SIZE_DEFAULT,
                                0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomTextField(
                                            controller: customerController
                                                .searchCustomerController,
                                            onChanged: (value) {
                                              customerController
                                                  .searchCustomer(value);
                                            },
                                            suffixIcon: Images.search_icon,
                                            suffix: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Stack(
                                      children: [
                                        CustomButton(
                                          buttonText: 'add_customer'.tr,
                                          buttonColor: Theme.of(context)
                                              .secondaryHeaderColor,
                                          onPressed: () => Get.to(
                                              () => AddNewSuppliersOrCustomer(
                                                    isCustomer: true,
                                                  )),
                                        ),
                                        CustomerSearchDialog(),
                                      ],
                                    ),
                                    SizedBox(
                                        height: Dimensions.PADDING_SIZE_SMALL),
                                    CustomButton(
                                      buttonText: 'new_order'.tr,
                                      onPressed: () {
                                        String customerId =
                                            '${customerController.customerId}';
                                        customer.TemporaryCartListModel
                                            customerCart =
                                            customer.TemporaryCartListModel(
                                          cart: [],
                                          userIndex: customerId != '0'
                                              ? int.parse(customerId)
                                              : rng.nextInt(10000),
                                          userId: customerId != '0'
                                              ? int.parse(customerId)
                                              : int.parse(customerId),
                                          customerName: customerId == '0'
                                              ? 'wc-${rng.nextInt(10000)}'
                                              : '${customerController.customerSelectedName} ${customerController.customerSelectedMobile}',
                                          customerBalance: customerController
                                              .customerBalance,
                                        );
                                        Get.find<CartController>()
                                            .addToCartListForUser(customerCart,
                                                clear: true);
                                      },
                                    ),
                                  ],
                                )),
                                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                                Expanded(
                                    child: Column(
                                  children: [
                                    Text(
                                      '${'current_customer_status'.tr} :',
                                      style: fontSizeRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall),
                                    ),
                                    customerController.customerCartList != null
                                        ? Container(
                                            height: 25,
                                            child: Column(children: [
                                              Padding(
                                                padding: const EdgeInsets
                                                        .symmetric(
                                                    vertical: Dimensions
                                                        .PADDING_SIZE_EXTRA_SMALL),
                                                child: Text(
                                                  '${customerController.customerSelectedName ?? ''}',
                                                  style: fontSizeMedium.copyWith(
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor),
                                                ),
                                              ),
                                              Text(
                                                '${customerController.customerSelectedMobile != 'NULL' ? customerController.customerSelectedMobile ?? '' : ''}',
                                                style: fontSizeMedium.copyWith(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor),
                                              ),
                                            ]))
                                        : SizedBox(),
                                    SizedBox(
                                        height: Dimensions
                                            .PADDING_SIZE_CUSTOMER_BOTTOM),
                                    CustomButton(
                                        buttonText: 'clear_all_cart'.tr,
                                        textColor:
                                            Theme.of(context).primaryColor,
                                        isClear: true,
                                        buttonColor:
                                            Theme.of(context).hintColor,
                                        onPressed: () {
                                          Get.find<CartController>()
                                              .removeAllCartList();
                                        }),
                                  ],
                                )),
                              ],
                            ),
                          );
                        }),
                        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                        GetBuilder<CartController>(
                            builder: (customerCartController) {
                          return customerCartController
                                      .customerCartList.length >
                                  0
                              ? Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      Dimensions.PADDING_SIZE_DEFAULT,
                                      0,
                                      Dimensions.PADDING_SIZE_DEFAULT,
                                      0),
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.PADDING_SIZE_SMALL),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        border: Border.all(
                                            width: .5,
                                            color: Theme.of(context)
                                                .hintColor
                                                .withOpacity(.7)),
                                        borderRadius: BorderRadius.circular(
                                            Dimensions
                                                .PADDING_SIZE_MEDIUM_BORDER)),
                                    child: DropdownButton<int>(
                                      value: customerCartController.customerIds[
                                          cartController.customerIndex],
                                      items: customerCartController.customerIds
                                          .map((int value) {
                                        print(
                                            '=======------${customerCartController.customerIds}/$value/${customerCartController.customerIndex}');
                                        return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(
                                                customerCartController
                                                        .customerCartList[
                                                            (customerCartController
                                                                .customerIds
                                                                .indexOf(
                                                                    value))]
                                                        .customerName ??
                                                    '',
                                                style: fontSizeRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall)));
                                      }).toList(),
                                      onChanged: (int value) async {
                                        //print('--id---${Get.find<CustomerController>().customerList[(customerCartController.customerIds.indexOf(value))].id}');
                                        await customerCartController
                                            .setCustomerIndex(
                                                cartController.customerIds
                                                    .indexOf(value),
                                                true);
                                        customerCartController.setCustomerInfo(
                                            customerCartController
                                                .customerCartList[
                                                    customerCartController
                                                        .customerIndex]
                                                .userId,
                                            customerCartController
                                                .customerCartList[
                                                    (customerCartController
                                                        .customerIndex)]
                                                .customerName,
                                            '',
                                            customerCartController
                                                .customerCartList[
                                                    (customerCartController
                                                        .customerIndex)]
                                                .customerBalance,
                                            true);
                                        Get.find<TransactionController>()
                                            .addCustomerBalanceIntoAccountList(
                                                Accounts(
                                                    id: 0,
                                                    account:
                                                        'customer balance'));
                                        Get.find<TransactionController>()
                                            .setAccountIndex(1, 'from', true);
                                        customerCartController
                                            .getReturnAmount(payable);
                                      },
                                      isExpanded: true,
                                      underline: SizedBox(),
                                    ),
                                  ),
                                )
                              : SizedBox();
                        }),
                        SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              Dimensions.PADDING_SIZE_DEFAULT,
                              0,
                              Dimensions.PADDING_SIZE_DEFAULT,
                              0),
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(.06),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 6, child: Text('item_info'.tr)),
                              Expanded(flex: 2, child: Text('qty'.tr)),
                              Expanded(flex: 1, child: Text('price'.tr)),
                            ],
                          ),
                        ),
                        cartController.customerCartList.length > 0
                            ? GetBuilder<CartController>(
                                builder: (custController) {
                                return ListView.builder(
                                    itemCount: cartController
                                        .customerCartList[
                                            custController.customerIndex]
                                        .cart
                                        .length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (itemContext, index) {
                                      return ItemCartWidget(
                                          cartModel: cartController
                                              .customerCartList[
                                                  custController.customerIndex]
                                              .cart[index],
                                          index: index);
                                    });
                              })
                            : SizedBox(),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.FONT_SIZE_DEFAULT),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      'bill_summery'.tr,
                                      style: fontSizeMedium.copyWith(
                                          fontSize: Dimensions.FONT_SIZE_LARGE),
                                    )),
                                    Container(
                                        width: 120,
                                        height: 40,
                                        child: CustomButton(
                                          buttonText: 'edit_discount'.tr,
                                          onPressed: () {
                                            showAnimatedDialog(context,
                                                ExtraDiscountAndCouponDialog(),
                                                dismissible: false,
                                                isFlip: false);
                                          },
                                        )),
                                  ],
                                ),
                              ),
                              PricingWidget(
                                  title: 'subtotal'.tr,
                                  amount:
                                      '${PriceConverter.priceWithSymbol(subTotal)}'),
                              PricingWidget(
                                  title: 'product_discount'.tr,
                                  amount:
                                      '${PriceConverter.priceWithSymbol(productDiscount)}'),
                              PricingWidget(
                                title: 'coupon_discount'.tr,
                                amount:
                                    '${PriceConverter.priceWithSymbol(couponAmount)}',
                                isCoupon: true,
                                onTap: () {
                                  showAnimatedDialog(context, CouponDialog(),
                                      dismissible: false, isFlip: false);
                                },
                              ),
                              PricingWidget(
                                  title: 'extra_discount'.tr,
                                  amount:
                                      '${PriceConverter.discountCalculation(context, subTotal, cartController.extraDiscountAmount, cartController.selectedDiscountType)}'),
                              PricingWidget(
                                  title: 'vat'.tr,
                                  amount:
                                      '${PriceConverter.priceWithSymbol(productTax)}'),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.PADDING_SIZE_DEFAULT),
                                child: CustomDivider(
                                  height: .4,
                                  color: Theme.of(context)
                                      .hintColor
                                      .withOpacity(1),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    Dimensions.PADDING_SIZE_DEFAULT,
                                    Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                    Dimensions.PADDING_SIZE_DEFAULT,
                                    Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                child: Text(
                                  'payment_via'.tr,
                                  style: fontSizeRegular.copyWith(
                                      color: Theme.of(context).hintColor),
                                ),
                              ),
                              GetBuilder<TransactionController>(
                                  builder: (accountController) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      Dimensions.PADDING_SIZE_DEFAULT,
                                      0,
                                      Dimensions.PADDING_SIZE_DEFAULT,
                                      0),
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 50,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: Dimensions
                                                  .PADDING_SIZE_SMALL),
                                          decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).cardColor,
                                              border: Border.all(
                                                  width: .5,
                                                  color: Theme.of(context)
                                                      .hintColor
                                                      .withOpacity(.7)),
                                              borderRadius: BorderRadius
                                                  .circular(Dimensions
                                                      .PADDING_SIZE_MEDIUM_BORDER)),
                                          child: DropdownButton<int>(
                                            value: accountController
                                                .fromAccountIndex,
                                            items: accountController
                                                .fromAccountIds
                                                .map((int value) {
                                              return DropdownMenuItem<int>(
                                                  value: value,
                                                  child: Text(accountController
                                                      .accountList[
                                                          (accountController
                                                              .fromAccountIds
                                                              .indexOf(value))]
                                                      .account));
                                            }).toList(),
                                            onChanged: (int value) {
                                              accountController.setAccountIndex(
                                                  value, 'from', true);
                                              selectedOption = accountController
                                                  .accountList[
                                                      (accountController
                                                          .fromAccountIds
                                                          .indexOf(value))]
                                                  .account;
                                              print('Selected mode');

                                              print(accountController
                                                  .accountList[
                                                      (accountController
                                                          .fromAccountIds
                                                          .indexOf(value))]
                                                  .account);

                                              cartController
                                                  .collectedCashController
                                                  .clear();
                                              cartController
                                                  .getReturnAmount(payable);
                                              setState(() {});
                                            },
                                            isExpanded: true,
                                            underline: SizedBox(),
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                Dimensions.PADDING_SIZE_SMALL),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              GetBuilder<TransactionController>(
                                  builder: (transactionController) {
                                // print(
                                //     '============xyz=========>${transactionController.selectedFromAccountId}');
                                return Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      Dimensions.PADDING_SIZE_DEFAULT,
                                      Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                      Dimensions.PADDING_SIZE_DEFAULT,
                                      Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            transactionController
                                                        .selectedFromAccountId ==
                                                    0
                                                ? 'customer_balance'.tr
                                                : transactionController
                                                            .selectedFromAccountId ==
                                                        1
                                                    ? 'collected_cash'.tr
                                                    : 'transaction_reference'
                                                        .tr,
                                            style: fontSizeRegular.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                      ),
                                      Row(children: [
                                        transactionController
                                                    .selectedFromAccountId ==
                                                0
                                            ? SizedBox()
                                            : Icon(Icons.edit,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                        GetBuilder<CartController>(
                                            builder: (customerController) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: transactionController
                                                              .selectedFromAccountId ==
                                                          0
                                                      ? Theme.of(context)
                                                          .hintColor
                                                      : Theme.of(context)
                                                          .secondaryHeaderColor,
                                                  width: transactionController
                                                              .selectedFromAccountId ==
                                                          0
                                                      ? 0
                                                      : 1),
                                              borderRadius: BorderRadius
                                                  .circular(Dimensions
                                                      .PADDING_SIZE_MEDIUM_BORDER),
                                            ),
                                            child: Text(""),
                                          );
                                        })
                                      ])
                                    ],
                                  ),
                                );
                              }),
                              GetBuilder<TransactionController>(
                                  builder: (transactionController) {
                                return transactionController
                                                .selectedFromAccountId ==
                                            0 ||
                                        transactionController
                                                .selectedFromAccountId ==
                                            1
                                    ? Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            Dimensions.PADDING_SIZE_DEFAULT,
                                            0,
                                            Dimensions.PADDING_SIZE_DEFAULT,
                                            Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL),
                                        child: Row(
                                          children: [
                                            Text(
                                                transactionController
                                                                .selectedFromAccountId ==
                                                            0 &&
                                                        Get.find<CartController>()
                                                                .customerId !=
                                                            0
                                                    ? 'remaining_balance'.tr
                                                    : transactionController
                                                                .selectedFromAccountId ==
                                                            1
                                                        ? 'returned_amount'.tr
                                                        : '',
                                                style: fontSizeRegular.copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColor)),
                                            Spacer(),
                                            Padding(
                                              padding: const EdgeInsets
                                                      .symmetric(
                                                  horizontal: Dimensions
                                                      .PADDING_SIZE_SMALL,
                                                  vertical: Dimensions
                                                      .PADDING_SIZE_EXTRA_SMALL),
                                              child: Text(
                                                  '${PriceConverter.priceWithSymbol(cartController.returnToCustomerAmount)}',
                                                  style:
                                                      fontSizeRegular.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor)),
                                            )
                                          ],
                                        ),
                                      )
                                    : SizedBox();
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                                    vertical: Dimensions.PADDING_SIZE_DEFAULT),
                                child: CustomDivider(
                                  height: .4,
                                  color: Theme.of(context)
                                      .hintColor
                                      .withOpacity(1),
                                ),
                              ),
                              GetBuilder<TransactionController>(
                                  builder: (transactionController) {
                                return Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      Dimensions.PADDING_SIZE_DEFAULT,
                                      0,
                                      Dimensions.PADDING_SIZE_DEFAULT,
                                      Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  height: 50,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: CustomButton(
                                        buttonText: 'cancel'.tr,
                                        isClear: true,
                                        textColor:
                                            Theme.of(context).primaryColor,
                                        buttonColor:
                                            Theme.of(context).hintColor,
                                        onPressed: () {
                                          subTotal = 0;
                                          productDiscount = 0;
                                          total = 0;
                                          payable = 0;
                                          couponAmount = 0;
                                          extraDiscount = 0;
                                          productTax = 0;
                                          cartController
                                              .customerCartList[
                                                  Get.find<CartController>()
                                                      .customerIndex]
                                              .cart
                                              .clear();
                                          cartController.removeAllCart();
                                        },
                                      )),
                                      SizedBox(
                                        width: Dimensions.PADDING_SIZE_SMALL,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              SizedBox(
                                height: Dimensions.PADDING_SIZE_REVENUE_BOTTOM,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }))
            ],
          ),
        ),
      ),
    );
  }
}
