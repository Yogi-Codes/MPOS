import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:six_pos/data/api/api_client.dart';
import 'package:six_pos/data/model/body/place_order_body.dart';
import 'package:six_pos/data/model/response/cart_model.dart';
import 'package:six_pos/data/model/response/temporary_cart_for_customer.dart';
import 'package:six_pos/util/app_constants.dart';

class CartRepo{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CartRepo({@required this.apiClient, @required this.sharedPreferences});

  List<CartModel> getCartList() {
    List<String> carts = [];
    if(sharedPreferences.containsKey(AppConstants.CART_LIST)) {
      carts = sharedPreferences.getStringList(AppConstants.CART_LIST);
    }
    List<CartModel> cartList = [];
    carts.forEach((cart) => cartList.add(CartModel.fromJson(jsonDecode(cart))) );
    return cartList;
  }

  void addToCartList(List<CartModel> cartProductList) {
    List<String> carts = [];
    cartProductList.forEach((cartModel) => carts.add(jsonEncode(cartModel)) );
    sharedPreferences.setStringList(AppConstants.CART_LIST, carts);
  }

  List<TemporaryCartListModel> getCustomerCartList() {
    List<String> customerCarts = [];
    if(sharedPreferences.containsKey(AppConstants.CUSTOMER_CART_LIST)) {
      customerCarts = sharedPreferences.getStringList(AppConstants.CUSTOMER_CART_LIST);
    }
    List<TemporaryCartListModel> customerCart = [];
    customerCarts.forEach((cart) => customerCart.add(TemporaryCartListModel.fromJson(jsonDecode(cart))) );
    return customerCart;
  }

  void addToCartListForCustomer(List<TemporaryCartListModel> customerCartList) {
    List<String> customerCarts = [];
    customerCartList.forEach((customerCartModel) => customerCarts.add(jsonEncode(customerCartModel)) );
    sharedPreferences.setStringList(AppConstants.CUSTOMER_CART_LIST, customerCarts);
  }

  Future<Response> getCouponDiscount(String couponCode, int userId, double orderAmount) async {
    return await apiClient.getData('${AppConstants.GET_COUPON_DISCOUNT}?code=$couponCode&user_id=$userId&order_amount=$orderAmount');
  }

  Future<Response> placeOrder(PlaceOrderBody placeOrderBody) async {
    return await apiClient.postData('${AppConstants.PLACE_ORDER_URI}', placeOrderBody.toJson());
  }

  Future<Response> getProductFromScan(String productCode) async {
    return await apiClient.getData('${AppConstants.GET_PRODUCT_FROM_PRODUCT_CODE}?product_code=$productCode');
  }

  Future<Response> customerSearch(String name) async {
    return await apiClient.getData('${AppConstants.CUSTOMER_SEARCH_URI}?name=$name');
  }

}