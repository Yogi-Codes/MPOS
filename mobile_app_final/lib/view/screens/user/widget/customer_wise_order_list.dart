import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_pos/controller/customer_controller.dart';
import 'package:six_pos/data/model/response/order_model.dart';
import 'package:six_pos/util/dimensions.dart';
import 'package:six_pos/view/base/no_data_screen.dart';
import 'package:six_pos/view/screens/order/widget/order_card_widget.dart';


class CustomerWiseOrderListView extends StatelessWidget {
  final int customerId;
  final ScrollController scrollController;
  const CustomerWiseOrderListView({Key key, this.scrollController, this.customerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int offset = 1;
    scrollController?.addListener(() {
      if(scrollController.position.maxScrollExtent == scrollController.position.pixels
          && Get.find<CustomerController>().customerWiseOrderList.length != 0
          && !Get.find<CustomerController>().isLoading) {
        int pageSize;
        pageSize = Get.find<CustomerController>().customerWiseOrderListLength;

        if(offset < pageSize) {
          offset++;
          print('end of the page');
          Get.find<CustomerController>().showBottomLoader();
          Get.find<CustomerController>().getCustomerWiseOrderListList(customerId, offset);
        }
      }

    });

    return GetBuilder<CustomerController>(
      builder: (customerWiseOrderController) {
        List<Orders> customerWiseOrderList;
        customerWiseOrderList = customerWiseOrderController.customerWiseOrderList;

        return Column(children: [

          !customerWiseOrderController.isFirst ? customerWiseOrderList.length != 0 ?
          ListView.builder(
            shrinkWrap: true,
              itemCount: customerWiseOrderList.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (ctx,index){
                return OrderCardWidget(order: customerWiseOrderList[index]);

              }): NoDataScreen() : SizedBox(),
          customerWiseOrderController.isLoading ? Center(child: Padding(
            padding: EdgeInsets.all(Dimensions.ICON_SIZE_EXTRA_SMALL),
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
          )) : SizedBox.shrink(),

        ]);
      },
    );
  }
}
