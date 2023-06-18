import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_pos/controller/category_controller.dart';
import 'package:six_pos/data/model/response/category_model.dart';
import 'package:six_pos/util/color_resources.dart';
import 'package:six_pos/util/dimensions.dart';
import 'package:six_pos/util/images.dart';
import 'package:six_pos/util/styles.dart';
import 'package:six_pos/view/base/custom_drawer.dart';
import 'package:six_pos/view/base/custom_header.dart';
import 'package:six_pos/view/base/custom_search_field.dart';
import 'package:six_pos/view/base/no_data_screen.dart';
import 'package:six_pos/view/base/product_shimmer.dart';
import 'package:six_pos/view/screens/product/widget/category_item_card_widget.dart';
import 'package:six_pos/view/screens/product/widget/item_card_widget.dart';
import 'package:six_pos/view/screens/product/widget/product_search_dialog.dart';

import '../../base/custom_app_bar.dart';
import '../pos/pos_screen_homeSide.dart';

class ItemsScreen extends StatefulWidget {
  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      Get.find<CategoryController>().getSearchProductList('');
      Get.find<CategoryController>().changeSelectedIndex(0);
      if (Get.find<CategoryController>().categoryList.isNotEmpty) {
        Get.find<CategoryController>().getCategoryWiseProductList(
            Get.find<CategoryController>().categoryList[0].id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool rat = (screenWidth / screenHeight) > 1;
    return Scaffold(
      appBar: CustomAppBar(isBackButtonExist: false),
      endDrawer: CustomDrawer(),
      body: Column(
        children: [
          CustomHeader(
            title: 'Waiting For Sale'.tr,
            headerImage: Images.product,
          ),
          GetBuilder<CategoryController>(builder: (categoryController) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                  vertical: Dimensions.PADDING_SIZE_SMALL),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButton<String>(
                      value: categoryController
                          .categoryList[
                              categoryController.categorySelectedIndex]
                          .name,
                      items: categoryController.categoryList
                          .map((Categories _category) {
                        return DropdownMenuItem<String>(
                          value: _category.name,
                          child: Text(_category.name),
                        );
                      }).toList(),
                      onChanged: (String selectedCategoryName) {
                        int selectedCategoryIndex = categoryController
                            .categoryList
                            .indexWhere((category) =>
                                category.name == selectedCategoryName);
                        if (selectedCategoryIndex != -1) {
                          Get.find<CategoryController>()
                              .changeSelectedIndex(selectedCategoryIndex);
                          Get.find<CategoryController>()
                              .getCategoryWiseProductList(categoryController
                                  .categoryList[selectedCategoryIndex].id);
                        }
                      },
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 30.0,
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 7,
                    child: CustomSearchField(
                      controller: searchController,
                      hint: 'search_product_by_name_or_barcode'.tr,
                      prefix: Icons.search,
                      iconPressed: () => () {},
                      onSubmit: (text) => () {},
                      onChanged: (value) {
                        categoryController.getSearchProductList(value);
                      },
                      isFilter: false,
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(
              child: Stack(
            children: [
              GetBuilder<CategoryController>(
                builder: (categoryController) {
                  return categoryController.categoryList.length != 0
                      ? Row(children: [
                          Container(
                            width: 0,
                            margin: EdgeInsets.only(top: 3),
                            height: double.infinity,
                            decoration: BoxDecoration(
                                color: ColorResources
                                    .getCategoryWithProductColor(),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(
                                        Dimensions.PADDING_SIZE_LARGE))),
                            // child: DropdownButton<String>(
                            //   value: categoryController
                            //       .categoryList[
                            //           categoryController.categorySelectedIndex]
                            //       .name,
                            //   items: categoryController.categoryList
                            //       .map((Categories _category) {
                            //     return DropdownMenuItem<String>(
                            //       value: _category.name,
                            //       child: Text(_category.name),
                            //     );
                            //   }).toList(),
                            //   onChanged: (String selectedCategoryName) {
                            //     int selectedCategoryIndex = categoryController
                            //         .categoryList
                            //         .indexWhere((category) =>
                            //             category.name == selectedCategoryName);
                            //     if (selectedCategoryIndex != -1) {
                            //       Get.find<CategoryController>()
                            //           .changeSelectedIndex(
                            //               selectedCategoryIndex);
                            //       Get.find<CategoryController>()
                            //           .getCategoryWiseProductList(
                            //               categoryController
                            //                   .categoryList[
                            //                       selectedCategoryIndex]
                            //                   .id);
                            //     }
                            //   },
                            //   isExpanded: true,
                            //   icon: Icon(Icons.arrow_drop_down),
                            //   iconSize: 30.0,
                            //   elevation: 16,
                            //   style: TextStyle(color: Colors.black),
                            //   underline: Container(
                            //     height: 2,
                            //     color: Colors.grey[400],
                            //   ),
                            // ),
                          ),
                          SizedBox(
                              width: Dimensions.PADDING_SIZE_MEDIUM_BORDER),
                          categoryController.categoriesProductList != null
                              ? categoryController
                                          .categoriesProductList.length !=
                                      0
                                  ? Expanded(
                                      child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${'all_product_from'.tr}',
                                                style: fontSizeRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall),
                                              ),
                                              // SizedBox(
                                              //     width: Dimensions
                                              //         .PADDING_SIZE_SMALL),
                                              Expanded(
                                                child: Text(
                                                  ' ${categoryController.categoryList[categoryController.categorySelectedIndex].name}',
                                                  textAlign: TextAlign.start,
                                                  maxLines: 3,
                                                  style:
                                                      fontSizeRegular.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: Dimensions
                                                  .PADDING_SIZE_EXTRA_SMALL,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  flex: rat
                                                      ? 6
                                                      : 10, // GridView.builder takes 70% of the width
                                                  child: GridView.builder(
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 5,
                                                            mainAxisSpacing:
                                                                0.5,
                                                            mainAxisExtent: 86,
                                                            childAspectRatio:
                                                                2.2 / 1),
                                                    padding: EdgeInsets.all(0),
                                                    itemCount: categoryController
                                                        .categoriesProductList
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ItemCardWidget(
                                                        categoriesProduct:
                                                            categoryController
                                                                    .categoriesProductList[
                                                                index],
                                                        index: index,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                rat
                                                    ? Expanded(
                                                        flex: 4,
                                                        child:
                                                            FractionallySizedBox(
                                                          widthFactor: 1.0,
                                                          heightFactor: 1.0,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .black,
                                                                width: 0.1,
                                                              ),
                                                            ),
                                                            child:
                                                                Transform.scale(
                                                              scale: 0.8,
                                                              child:
                                                                  PosScreen(),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Expanded(
                                                        child: Text(""),
                                                        flex: 0,
                                                      )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                Dimensions.PADDING_SIZE_DEFAULT)
                                      ],
                                    ))
                                  : Expanded(child: NoDataScreen())
                              : Expanded(child: ProductShimmer()),
                        ])
                      : NoDataScreen();
                },
              ),
              ProductSearchDialog(),
            ],
          )),
        ],
      ),
    );
  }
}
